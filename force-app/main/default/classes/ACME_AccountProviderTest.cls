/**
 * @description Test class for ACME_AccountProvider
 * @author ACME Corporation
 * @date 2024
 */
@isTest
private class ACME_AccountProviderTest {

    /**
     * @description Test setup method to create test data
     */
    @testSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(
            Name = 'High Revenue Corp',
            AnnualRevenue = 2000000,
            Industry = 'Technology'
        ));
        testAccounts.add(new Account(
            Name = 'Medium Revenue Inc',
            AnnualRevenue = 500000,
            Industry = 'Finance'
        ));
        insert testAccounts;
    }

    /**
     * @description Test finding existing account by company name
     */
    @isTest
    static void testFindExistingAccount() {
        // Create test lead
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'High Revenue Corp',
            Email = 'john.doe@highrevenue.com',
            Status = 'Open - Not Contacted',
            OwnerId = UserInfo.getUserId()
        );
        insert testLead;

        Test.startTest();
        Id accountId = ACME_AccountProvider.findOrCreateAccount(testLead);
        Test.stopTest();

        Account result = [SELECT Id, Name FROM Account WHERE Id = :accountId];
        System.assertNotEquals(null, result, 'Account should be found');
        System.assertEquals('High Revenue Corp', result.Name, 'Account name should match');
    }

    /**
     * @description Test creating new account when not found
     */
    @isTest
    static void testCreateNewAccount() {
        // Create test lead with non-existing company
        Lead testLead = new Lead(
            FirstName = 'Jane',
            LastName = 'Smith',
            Company = 'New Company LLC',
            Email = 'jane.smith@newcompany.com',
            Status = 'Open - Not Contacted',
            Industry = 'Retail',
            OwnerId = UserInfo.getUserId()
        );
        insert testLead;

        Test.startTest();
        Id accountId = ACME_AccountProvider.findOrCreateAccount(testLead);
        Test.stopTest();

        Account result = [SELECT Id, Name FROM Account WHERE Id = :accountId];
        System.assertNotEquals(null, result, 'Account should be created');
        System.assertEquals('New Company LLC', result.Name, 'Account name should match lead company');
    }

    /**
     * @description Test null lead handling
     */
    @isTest
    static void testNullLead() {
        Test.startTest();
        try {
            ACME_AccountProvider.findOrCreateAccount(null);
            System.assert(false, 'Should have thrown exception');
        } catch (Exception e) {
            System.assert(true, 'Exception thrown as expected');
        }
        Test.stopTest();
    }

    /**
     * @description Test retrieving high value accounts
     */
    @isTest
    static void testGetHighValueAccounts() {
        Test.startTest();
        List<Account> highValueAccounts = ACME_AccountProvider.getHighValueAccounts();
        Test.stopTest();

        System.assertNotEquals(null, highValueAccounts, 'Should return list of accounts');
        System.assertEquals(1, highValueAccounts.size(), 'Should find one high revenue account');
        System.assertEquals('High Revenue Corp', highValueAccounts[0].Name, 'Account name should match');
    }

    /**
     * @description Test error handling for account creation
     */
    @isTest
    static void testAccountCreationError() {
        // Create lead with missing required field (Company)
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'User',
            Company = null,
            Email = 'test@example.com',
            Status = 'Open - Not Contacted'
        );

        Test.startTest();
        try {
            ACME_AccountProvider.findOrCreateAccount(testLead);
            System.assert(false, 'Should have thrown exception for null company');
        } catch (Exception e) {
            System.assert(true, 'Exception thrown as expected');
        }
        Test.stopTest();
    }
}