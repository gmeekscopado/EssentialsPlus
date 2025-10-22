/**
 * @description Test class for ACME_AccountProvider
 * @author ACME Corporation
 * @date 2024
 */
@IsTest
private class ACME_AccountProviderTest {
    
    @TestSetup
    static void setupTestData() {
        // Create existing account
        Account existingAccount = new Account(
            Name = 'Existing Company',
            Industry = 'Technology',
            Type = 'Customer - Direct',
            AnnualRevenue = 2000000
        );
        insert existingAccount;
        
        // Create high-priority accounts
        List<Account> highPriorityAccounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            highPriorityAccounts.add(new Account(
                Name = 'High Priority Account ' + i,
                Industry = 'Financial Services',
                Type = 'Customer - Direct',
                AnnualRevenue = 1500000 + (i * 500000)
            ));
        }
        insert highPriorityAccounts;
        
        // Create test lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'New Company',
            Email = 'test.lead@test.com',
            Phone = '555-123-0000',
            Industry = 'Manufacturing',
            Status = 'Open - Not Contacted'
        );
        insert testLead;
    }
    
    @IsTest
    static void testFindExistingAccount() {
        Lead testLead = [SELECT Id, Company, Industry, Phone, OwnerId FROM Lead LIMIT 1];
        String existingCompanyName = 'Existing Company';
        
        Test.startTest();
        Id accountId = ACME_AccountProvider.findOrCreateAccount(existingCompanyName, testLead);
        Test.stopTest();
        
        System.assertNotEquals(null, accountId, 'Should return existing account ID');
        
        Account foundAccount = [SELECT Id, Name FROM Account WHERE Id = :accountId];
        System.assertEquals(existingCompanyName, foundAccount.Name, 'Should find the existing account');
    }
    
    @IsTest
    static void testCreateNewAccount() {
        Lead testLead = [SELECT Id, Company, Industry, Phone, OwnerId FROM Lead LIMIT 1];
        String newCompanyName = 'Brand New Company';
        
        Test.startTest();
        Id accountId = ACME_AccountProvider.findOrCreateAccount(newCompanyName, testLead);
        Test.stopTest();
        
        System.assertNotEquals(null, accountId, 'Should return new account ID');
        
        Account newAccount = [SELECT Id, Name, Industry, Type FROM Account WHERE Id = :accountId];
        System.assertEquals(newCompanyName, newAccount.Name, 'Should create account with correct name');
        System.assertEquals(testLead.Industry, newAccount.Industry, 'Should set industry from lead');
        System.assertEquals('Prospect', newAccount.Type, 'Should set type to Prospect');
    }
    
    @IsTest
    static void testGetHighPriorityAccounts() {
        Test.startTest();
        List<Account> highPriorityAccounts = ACME_AccountProvider.getHighPriorityAccounts();
        Test.stopTest();
        
        System.assertNotEquals(null, highPriorityAccounts, 'Should return accounts list');
        System.assert(highPriorityAccounts.size() > 0, 'Should return high-priority accounts');
        
        for (Account acc : highPriorityAccounts) {
            System.assert(acc.AnnualRevenue > 1000000, 'All accounts should have high revenue');
            System.assert(acc.Type.contains('Customer'), 'Should be customer accounts');
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
    static void testBulkAccountCreation() {
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            testLeads.add(new Lead(
                FirstName = 'Bulk',
                LastName = 'Lead ' + i,
                Company = 'Bulk Company ' + i,
                Email = 'bulk.lead' + i + '@test.com',
                Industry = 'Technology',
                Status = 'Open - Not Contacted'
            ));
        }
        insert testLeads;
        
        Test.startTest();
        List<Id> accountIds = new List<Id>();
        for (Lead lead : testLeads) {
            Id accountId = ACME_AccountProvider.findOrCreateAccount(lead.Company, lead);
            accountIds.add(accountId);
        }
        Test.stopTest();
        
        System.assertEquals(5, accountIds.size(), 'Should create 5 accounts');
        
        List<Account> createdAccounts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
        System.assertEquals(5, createdAccounts.size(), 'All accounts should be created');
    }
}