@isTest
private class OpportunityComplianceTriggerTest {

    @TestSetup
    static void makeData(){
        // Create a test account
        Account testAcct = new Account(Name='Test Account');
        insert testAcct;

        // Create a test opportunity
        Opportunity opp = new Opportunity(
            Name='Test Opp',
            StageName='Prospecting',
            CloseDate=System.today().addDays(30),
            AccountId=testAcct.Id,
            Brand_Tier__c = '1'
        );
        insert opp;
    }

    @isTest
    static void testTriggerBlocksUpdate_MissingDocs() {
        // Get the test opportunity
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Name='Test Opp' LIMIT 1];

        // Try to update the stage to 'Closed Won' without documents
        Test.startTest();
        Database.SaveResult result = Database.update(new Opportunity(Id=opp.Id, StageName='Closed Won'), false);
        Test.stopTest();

        // Verify that the update failed
        System.assert(!result.isSuccess(), 'The trigger should have blocked the update.');
        
        // Verify the error message
        Database.Error error = result.getErrors()[0];
        System.assert(error.getMessage().contains('Action required: The following compliance documents are missing:'), 
                      'The error message is not correct.');
    }

    @isTest
    static void testTriggerAllowsUpdate_WithDocs() {
        // Get the test opportunity
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Name='Test Opp' LIMIT 1];

        // Create and attach the required documents
        ContentVersion cv1 = new ContentVersion(
            Title = 'Business Tax ID Form',
            PathOnClient = 'Business_Tax_ID_Form.pdf',
            VersionData = Blob.valueOf('Test Content')
        );
        insert cv1;
        cv1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id];

        ContentVersion cv2 = new ContentVersion(
            Title = 'Articles of Incorporation',
            PathOnClient = 'Articles_of_Incorporation.pdf',
            VersionData = Blob.valueOf('Test Content')
        );
        insert cv2;
        cv2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv2.Id];

        // Link the documents to the opportunity
        insert new ContentDocumentLink(
            ContentDocumentId = cv1.ContentDocumentId,
            LinkedEntityId = opp.Id,
            ShareType = 'V'
        );

        insert new ContentDocumentLink(
            ContentDocumentId = cv2.ContentDocumentId,
            LinkedEntityId = opp.Id,
            ShareType = 'V'
        );

        // Try to update the stage to 'Closed Won'
        Test.startTest();
        Database.SaveResult result = Database.update(new Opportunity(Id=opp.Id, StageName='Closed Won'), false);
        Test.stopTest();

        // Verify that the update was successful
        System.assert(result.isSuccess(), 'The trigger should have allowed the update, but it failed.');
    }
}