@isTest
private class AssetTriggerTest {

    @testSetup
    static void makeData(){
        // Create an Account and a Contact to satisfy the requirements of the
        // "Asset Compliance Task Creation" flow.
        Account acc = new Account(Name='Test Account');
        insert acc;

        Contact con = new Contact(LastName='Test Contact', AccountId=acc.Id);
        insert con;

        // Create the test Asset and associate the Contact to it.
        // This is the critical addition to prevent the flow from failing.
        Asset asset = new Asset(
            Name='Test Asset',
            AccountId=acc.Id,
            ContactId=con.Id,
            Status='Installed'
        );
        insert asset;
    }

    private static testMethod void testBlockDirectDecommission() {
        Asset assetToUpdate = [SELECT Id, Status FROM Asset WHERE Name = 'Test Asset' LIMIT 1];
        
        Test.startTest();
        try {
            assetToUpdate.Status = 'Obsolete';
            update assetToUpdate;
            // If the trigger doesn't stop the update, fail the test.
            System.assert(false, 'The trigger should have prevented the status change to Obsolete.');
        } catch (DmlException e) {
            // Verify that the trigger's specific error message was thrown.
            System.assert(e.getMessage().contains('Directly setting status to Obsolete is not allowed'), 'The error message from the trigger is incorrect.');
        }
        Test.stopTest();
    }

    private static testMethod void testRequestDecommission() {
        Asset assetToUpdate = [SELECT Id, Status FROM Asset WHERE Name = 'Test Asset' LIMIT 1];

        Test.startTest();
        assetToUpdate.Status = 'Pending Decommission';
        update assetToUpdate;
        Test.stopTest();

        // Verify the Action_Audit__c record was created successfully.
        Action_Audit__c audit = [SELECT Id, Status__c FROM Action_Audit__c WHERE Asset__c = :assetToUpdate.Id];
        System.assertNotEquals(null, audit, 'An Action_Audit__c record should have been created.');
        System.assertEquals('Pending', audit.Status__c, 'The audit record should be in a Pending state.');
    }
}