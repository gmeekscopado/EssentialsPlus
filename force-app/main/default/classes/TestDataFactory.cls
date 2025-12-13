@isTest
public class TestDataFactory {
    private static User testUser;

    // Private constructor to prevent instantiation
    private TestDataFactory() {}

    /**
     * @description Creates a single, reusable test user to be used as the owner for all test records.
     * @return A valid User record.
     */
    public static User getTestUser() {
        if (testUser == null) {
            testUser = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
                FirstName = 'Test',
                LastName = 'User',
                Email = 'test.user@example.com',
                Username = 'test.user' + System.currentTimeMillis() + '@example.com',
                CompanyName = 'ACME',
                Title = 'Tester',
                Alias = 'tuser',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
            insert testUser;
        }
        return testUser;
    }

    /**
     * @description Creates a list of valid Account records.
     * @param count The number of accounts to create.
     * @param doInsert If true, the records will be inserted into the database.
     * @return A list of Account records.
     */
    public static List<Account> createAccounts(Integer count, Boolean doInsert) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                Industry = 'Technology',
                AnnualRevenue = 1000000
            ));
        }
        if (doInsert) {
            insert accounts;
        }
        return accounts;
    }

    /**
     * @description Creates a list of valid Lead records.
     * @param count The number of leads to create.
     * @param doInsert If true, the records will be inserted into the database.
     * @return A list of Lead records.
     */
    public static List<Lead> createLeads(Integer count, Boolean doInsert) {
        User owner = getTestUser();
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < count; i++) {
            leads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead' + i,
                Company = 'Test Corp',
                Status = 'Open - Not Contacted',
                OwnerId = owner.Id // Ensures a valid owner is always assigned
            ));
        }
        if (doInsert) {
            insert leads;
        }
        return leads;
    }

    /**
     * @description Creates a list of valid Contact records for a given Account.
     * @param count The number of contacts to create.
     * @param accountId The ID of the parent Account.
     * @param doInsert If true, the records will be inserted into the database.
     * @return A list of Contact records.
     */
    public static List<Contact> createContacts(Integer count, Id accountId, Boolean doInsert) {
        User owner = getTestUser();
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact' + i,
                Email = 'test.contact' + i + '@example.com',
                AccountId = accountId,
                OwnerId = owner.Id
            ));
        }
        if (doInsert) {
            insert contacts;
        }
        return contacts;
    }
}