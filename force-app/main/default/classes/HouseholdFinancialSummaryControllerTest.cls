@isTest
private class HouseholdFinancialSummaryControllerTest {

    @TestSetup
    static void makeData(){
        Account acc1 = new Account(Name='Test Account 1');
        insert acc1;

        Contact con1 = new Contact(AccountId=acc1.Id, LastName='Smith');
        Contact con2 = new Contact(AccountId=acc1.Id, LastName='Jones');
        insert new List<Contact>{con1, con2};

        Financial_Account__c finAcc1 = new Financial_Account__c(Contact__c=con1.Id, Name='Smith Checking', Balance__c=100000);
        Financial_Account__c finAcc2 = new Financial_Account__c(Contact__c=con2.Id, Name='Jones Savings', Balance__c=250000.50);
        insert new List<Financial_Account__c>{finAcc1, finAcc2};

        Account acc2 = new Account(Name='Test Account 2');
        insert acc2;
        Contact con3 = new Contact(AccountId=acc2.Id, LastName='No-Balance');
        insert con3;

        Account acc3 = new Account(Name='Test Account 3');
        insert acc3;
    }

    @isTest
    static void testGetSummary_MultipleContactsAndAccounts() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];

        Test.startTest();
        HouseholdFinancialSummaryController.HouseholdSummary result = HouseholdFinancialSummaryController.getHouseholdSummary(acc.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(2, result.contacts.size());
        System.assertEquals(350000.50, result.totalAUM);
    }

    @isTest
    static void testGetSummary_NoFinancialAccounts() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1];

        Test.startTest();
        HouseholdFinancialSummaryController.HouseholdSummary result = HouseholdFinancialSummaryController.getHouseholdSummary(acc.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.contacts.size());
        System.assertEquals(0, result.totalAUM);
    }

    @isTest
    static void testGetSummary_NoContacts() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 3' LIMIT 1];

        Test.startTest();
        HouseholdFinancialSummaryController.HouseholdSummary result = HouseholdFinancialSummaryController.getHouseholdSummary(acc.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(0, result.contacts.size());
        System.assertEquals(0, result.totalAUM);
    }

    @isTest
    static void testGetSummary_NullAccountId() {
        Exception caughtException = null;
        Test.startTest();
        try {
            HouseholdFinancialSummaryController.getHouseholdSummary(null);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'An exception should have been thrown for null account ID.');
        System.assert(caughtException instanceof AuraHandledException);
    }
}