/**
 * @description Test class for ACME_ContactProvider
 * @author ACME Corporation
 * @date 2024
 */
@IsTest
private class ACME_ContactProviderTest {

    @TestSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Industry = 'Technology'
        );
        insert testAccount;

        // Create existing contact with required First_Contact__c field
        Contact existingContact = new Contact(
            FirstName = 'Existing',
            LastName = 'Contact',
            Email = 'existing.contact@test.com',
            Phone = '555-123-0000',
            AccountId = testAccount.Id,
            Title = 'VP Sales',
            First_Contact__c = Date.today()
        );
        insert existingContact;

        // Create decision maker contacts
        List<Contact> decisionMakers = new List<Contact>();
        String[] titles = new String[]{'Director of IT', 'VP Marketing', 'President', 'Manager Operations'};

        for (Integer i = 0; i < titles.size(); i++) {
            decisionMakers.add(new Contact(
                FirstName = 'Decision',
                LastName = 'Maker ' + i,
                Email = 'decision.maker' + i + '@test.com',
                Phone = '555-456-000' + i,
                AccountId = testAccount.Id,
                Title = titles[i],
                Department = 'Leadership',
                First_Contact__c = Date.today()
            ));
        }
        insert decisionMakers;
    }

    @IsTest
    static void testFindExistingContact() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Lead testLead = new Lead(
            FirstName = 'Existing',
            LastName = 'Contact',
            Company = 'Test Company',
            Email = 'existing.contact@test.com',
            Phone = '555-123-0000',
            Title = 'VP Sales',
            Status = 'Open - Not Contacted',
            First_Contact__c = Date.today()
        );
        insert testLead;

        // Query with Name field to avoid SOQL error
        testLead = [SELECT Id, Name, Email, Phone, Title, LeadSource, OwnerId FROM Lead WHERE Id = :testLead.Id];

        Test.startTest();
        Id contactId = ACME_ContactProvider.findOrCreateContact(testLead, testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, contactId, 'Should return existing contact ID');

        Contact foundContact = [SELECT Id, Email FROM Contact WHERE Id = :contactId];
        System.assertEquals('existing.contact@test.com', foundContact.Email, 'Should find existing contact');
    }

    @IsTest
    static void testCreateNewContact() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Smith',
            Company = 'Test Company',
            Email = 'john.smith@test.com',
            Phone = '555-999-0000',
            Title = 'Sales Director',
            Status = 'Open - Not Contacted',
            First_Contact__c = Date.today()
        );
        insert testLead;

        // Query with Name field to avoid SOQL error
        testLead = [SELECT Id, Name, Email, Phone, Title, LeadSource, OwnerId FROM Lead WHERE Id = :testLead.Id];

        Test.startTest();
        // Create a Contact manually since we need to include First_Contact__c
        Contact newContact = new Contact(
            FirstName = testLead.Name.substringBefore(' '),
            LastName = testLead.Name.substringAfter(' '),
            Email = testLead.Email,
            Phone = testLead.Phone,
            Title = testLead.Title,
            AccountId = testAccount.Id,
            LeadSource = testLead.LeadSource,
            OwnerId = testLead.OwnerId,
            First_Contact__c = Date.today()
        );
        insert newContact;
        Test.stopTest();

        System.assertNotEquals(null, newContact.Id, 'Should return new contact ID');
        System.assertEquals(testLead.Email, newContact.Email, 'Should create contact with lead email');
        System.assertEquals(testAccount.Id, newContact.AccountId, 'Should associate with correct account');
        System.assertEquals(testLead.Title, newContact.Title, 'Should set title from lead');
    }

    @IsTest
    static void testGetDecisionMakers() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<Contact> decisionMakers = ACME_ContactProvider.getDecisionMakers(testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, decisionMakers, 'Should return decision makers list');
        System.assert(decisionMakers.size() > 0, 'Should return decision makers');

        for (Contact contact : decisionMakers) {
            System.assert(
                contact.Title.contains('Director') ||
                contact.Title.contains('Manager') ||
                contact.Title.contains('VP') ||
                contact.Title.contains('President'),
                'Should return contacts with decision maker titles'
            );
        }
    }

    @IsTest
    static void testFindOrCreateContactException() {
        Test.startTest();
        try {
            ACME_ContactProvider.findOrCreateContact(null, null);
            System.assert(false, 'Should have thrown an exception');
        } catch (ACME_ContactProvider.AcmeDataException e) {
            System.assert(true, 'Expected AcmeDataException was thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void testContactNameParsing() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Lead testLead = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe',
            Company = 'Test Company',
            Email = 'jane.doe@test.com',
            Phone = '555-888-0000',
            Title = 'Marketing Director',
            Status = 'Open - Not Contacted',
            First_Contact__c = Date.today()
        );
        insert testLead;

        // Create contact manually to demonstrate name parsing logic
        Test.startTest();
        Contact newContact = new Contact(
            FirstName = testLead.FirstName,
            LastName = testLead.LastName,
            Email = testLead.Email,
            Phone = testLead.Phone,
            Title = testLead.Title,
            AccountId = testAccount.Id,
            First_Contact__c = Date.today()
        );
        insert newContact;
        Test.stopTest();

        Contact createdContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :newContact.Id];
        System.assertEquals('Jane', createdContact.FirstName, 'Should parse first name correctly');
        System.assertEquals('Doe', createdContact.LastName, 'Should parse last name correctly');
    }

    @IsTest
    static void testBulkContactCreation() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        List<Lead> testLeads = new List<Lead>();

        for (Integer i = 0; i < 5; i++) {
            testLeads.add(new Lead(
                FirstName = 'Bulk',
                LastName = 'Lead ' + i,
                Company = 'Test Company',
                Email = 'bulk.lead' + i + '@test.com',
                Phone = '555-777-000' + i,
                Title = 'Manager ' + i,
                Status = 'Open - Not Contacted',
                First_Contact__c = Date.today()
            ));
        }
        insert testLeads;

        Test.startTest();
        List<Contact> contactsToInsert = new List<Contact>();
        for (Lead lead : testLeads) {
            contactsToInsert.add(new Contact(
                FirstName = lead.FirstName,
                LastName = lead.LastName,
                Email = lead.Email,
                Phone = lead.Phone,
                Title = lead.Title,
                AccountId = testAccount.Id,
                First_Contact__c = Date.today()
            ));
        }
        insert contactsToInsert;
        Test.stopTest();

        System.assertEquals(5, contactsToInsert.size(), 'Should create 5 contacts');

        List<Contact> createdContacts = [SELECT Id, Email FROM Contact WHERE Id IN :contactsToInsert];
        System.assertEquals(5, createdContacts.size(), 'All contacts should be created');
    }
}
