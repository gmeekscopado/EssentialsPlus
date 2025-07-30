@isTest
public class AccountValidationTest {
    
    /**
     * Test valid Account creation
     */
    @isTest
    static void testValidAccount() {
        // Get actual picklist values dynamically
        List<Schema.PicklistEntry> accountPicklistValues = Account.Account_Picklist__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> picklistTestValues = Account.Picklist_Test__c.getDescribe().getPicklistValues();
        
        Account validAccount = new Account(
            Name = 'Rebel Athletic',
            Account_Picklist__c = accountPicklistValues[0].getValue(),
            Picklist_Test__c = picklistTestValues[0].getValue(),
            Customer_Since__c = Date.today()
        );
        
        Test.startTest();
        insert validAccount;
        Test.stopTest();
        
        // Verify account was created
        Account inserted = [SELECT Name FROM Account WHERE Id = :validAccount.Id];
        System.assertEquals('Rebel Athletic', inserted.Name);
    }
    
    /**
     * Test another valid Account
     */
    @isTest
    static void testAnotherValidAccount() {
        // Get actual picklist values dynamically
        List<Schema.PicklistEntry> accountPicklistValues = Account.Account_Picklist__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> picklistTestValues = Account.Picklist_Test__c.getDescribe().getPicklistValues();
        
        Account validAccount = new Account(
            Name = 'Test Company Inc',
            Account_Picklist__c = accountPicklistValues[0].getValue(),
            Picklist_Test__c = picklistTestValues[0].getValue(),
            Customer_Since__c = Date.today().addDays(-30)
        );
        
        Test.startTest();
        insert validAccount;
        Test.stopTest();
        
        // Verify account was created
        Account inserted = [SELECT Name FROM Account WHERE Id = :validAccount.Id];
        System.assertEquals('Test Company Inc', inserted.Name);
    }
}