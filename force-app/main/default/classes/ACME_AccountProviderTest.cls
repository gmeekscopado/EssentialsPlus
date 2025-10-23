/**
 * @description Test class for ACME_AccountProvider
 * @author ACME Corporation
 * @date 2024
 */
@IsTest
private class ACME_AccountProviderTest {

    @TestSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(
            Name = 'ACME Corporation',
            Industry = 'Technology',
            Type = 'Customer - Direct',
            CustomerPriority__c = 'High',
            AnnualRevenue = 2000000
        ));
        testAccounts.add(new Account(
            Name = 'Test Company Inc',
            Industry = 'Manufacturing',
            Type = 'Prospect',
            CustomerPriority__c = 'Medium',
            AnnualRevenue = 500000
        ));
        insert testAccounts;

        // Create test lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'New Lead Company',
            Email = 'test@lead.com',
            Status = 'Open - Not Contacted',
            Industry = 'Technology',
            Phone = '555-1234567',
            First_Contact__c = Date.today()
        );
        insert testLead;
    }

    @IsTest
    static void testFindOrCreateAccountExisting() {
        Lead testLead = [SELECT Id, FirstName, LastName, Company, Industry, Phone, OwnerId FROM Lead LIMIT 1];

        Test.startTest();
        Id accountId = ACME_AccountProvider.findOrCreateAccount('ACME Corporation', testLead);
        Test.stopTest();

        // Should find existing account
        Account existingAccount = [SELECT Id, Name FROM Account WHERE Name = 'ACME Corporation' LIMIT 1];
        System.assertEquals(existingAccount.Id, accountId, 'Should find existing account');
    }

    @IsTest
    static void testFindOrCreateAccountNew() {
        Lead testLead = [SELECT Id, FirstName, LastName, Company, Industry, Phone, OwnerId FROM Lead LIMIT 1];

        Test.startTest();
        Id accountId = ACME_AccountProvider.findOrCreateAccount('Brand New Company', testLead);
        Test.stopTest();

        System.assertNotEquals(null, accountId, 'Should create new account');
        
        Account newAccount = [SELECT Id, Name, Industry, Type FROM Account WHERE Id = :accountId];
        System.assertEquals('Brand New Company', newAccount.Name, 'Should create account with correct name');
        System.assertEquals('Technology', newAccount.Industry, 'Should inherit industry from lead');
        System.assertEquals('Prospect', newAccount.Type, 'Should set type as Prospect');
    }

    @IsTest
    static void testGetHighPriorityAccounts() {
        Test.startTest();
        List<Account> highPriorityAccounts = ACME_AccountProvider.getHighPriorityAccounts();
        Test.stopTest();

        System.assertNotEquals(null, highPriorityAccounts, 'Should return account list');
        
        for (Account acc : highPriorityAccounts) {
            System.assert(
                acc.Type == 'Customer - Direct' || acc.Type == 'Customer - Channel',
                'Should return customer accounts only'
            );
            System.assert(acc.AnnualRevenue > 1000000, 'Should return high revenue accounts');
        }
    }

    @IsTest 
    static void testFindOrCreateAccountException() {
        Test.startTest();
        try {
            ACME_AccountProvider.findOrCreateAccount(null, null);
            System.assert(false, 'Should have thrown an exception');
        } catch (ACME_AccountProvider.AcmeDataException e) {
            System.assert(true, 'Expected AcmeDataException was thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void testFindOrCreateAccountWithEmptyName() {
        Lead testLead = [SELECT Id, FirstName, LastName, Company, Industry, Phone, OwnerId FROM Lead LIMIT 1];

        Test.startTest();
        try {
            ACME_AccountProvider.findOrCreateAccount('', testLead);
            System.assert(false, 'Should have thrown an exception for empty name');
        } catch (Exception e) {
            System.assert(true, 'Expected exception for empty name');
        }
        Test.stopTest();
    }
}
