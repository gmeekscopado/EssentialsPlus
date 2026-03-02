/**
 * @description Centralized factory for creating test data for ACME applications.
 * @author ACME Corporation
 * @date 2025-12-15
 */
@IsTest
public class TestDataFactory {

    /**
     * @description Private constructor to prevent instantiation of the factory class.
     */
    private TestDataFactory() {
        // This class is not meant to be instantiated.
    }

    /**
     * @description Creates and inserts a specified number of test accounts.
     * @param count The number of accounts to create.
     * @return A list of the newly created Account records.
     */
    public static List<Account> createTestAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                Industry = 'Technology',
                AnnualRevenue = 1000000
            ));
        }
        insert accounts;
        return accounts;
    }

    /**
     * @description Creates and inserts a specified number of test contacts associated with the first available test account.
     * @param count The number of contacts to create.
     * @return A list of the newly created Contact records.
     */
    public static List<Contact> createTestContacts(Integer count) {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        if (accounts.isEmpty()) {
            throw new TestDataException('An account must exist to create contacts.');
        }

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            String title = (Math.mod(i, 2) == 0) ? 'Test Manager ' + i : 'Test Director ' + i;
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact' + i,
                Email = 'test.contact' + i + '@acme.com',
                AccountId = accounts[0].Id,
                Title = title
            ));
        }
        insert contacts;
        return contacts;
    }

    /**
     * @description Creates a specified number of test leads.
     * @param count The number of leads to create.
     * @param doInsert A boolean indicating whether the records should be inserted.
     * @return A list of the newly created Lead records.
     */
    public static List<Lead> createTestLeads(Integer count, Boolean doInsert) {
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < count; i++) {
            leads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead' + i,
                Company = 'ACME Corp',
                Email = 'test.lead' + i + '@acme.com',
                OwnerId = testUser.Id
            ));
        }
        if (doInsert) {
            insert leads;
        }
        return leads;
    }
    
    /**
     * @description Overloaded method to create and insert leads by default.
     */
    public static List<Lead> createTestLeads(Integer count) {
        return createTestLeads(count, true);
    }

    /**
     * @description Custom exception for test data factory errors.
     */
    public class TestDataException extends Exception {
        // Intentionally left empty
    }
}