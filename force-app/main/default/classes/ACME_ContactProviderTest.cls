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
        
        // Create existing contact
        Contact existingContact = new Contact(
            FirstName = 'Existing',
            LastName = 'Contact',
            Email = 'existing.contact@test.com',
            Phone = '555-123-0000',
            AccountId = testAccount.Id,
            Title = 'VP Sales'
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
                Department = 'Leadership'
            ));
        }
        insert decisionMakers;
        
        // Create test lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'test.lead@test.com',
            Phone = '555-789-0000',
            Title = 'Manager',
            Status = 'Open - Not Contacted'
        );
        insert testLead;
    }
    
    @IsTest
    static void testFindExistingContact() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        // Create lead with SEPARATE fields instead of trying to set Lead.Name
        Lead testLead = new Lead(
            FirstName = 'Existing',
            LastName = 'Contact',
            Company = 'Test Company',
            Email = 'existing.contact@test.com',
            Phone = '555-123-0000',
            Title = 'VP Sales',
            Status = 'Open - Not Contacted'
        );
        
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
        Lead testLead = [SELECT Id, FirstName, LastName, Email, Phone, Title, Company, Status FROM Lead LIMIT 1];
        
        Test.startTest();
        Id contactId = ACME_ContactProvider.findOrCreateContact(testLead, testAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, contactId, 'Should return new contact ID');
        
        Contact newContact = [SELECT Id, Email, AccountId, Title FROM Contact WHERE Id = :contactId];
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
            FirstName = 'John',
            LastName = 'Smith',
            Company = 'Test Company',
            Email = 'john.smith@test.com',
            Phone = '555-999-0000',
            Title = 'Sales Director',
            Status = 'Open - Not Contacted'
        );
        
        Test.startTest();
        Id contactId = ACME_ContactProvider.findOrCreateContact(testLead, testAccount.Id);
        Test.stopTest();
        
        Contact newContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :contactId];
        System.assertEquals('John', newContact.FirstName, 'Should parse first name correctly');
        System.assertEquals('Smith', newContact.LastName, 'Should parse last name correctly');
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
                Phone = '555-888-000' + i,
                Title = 'Manager ' + i,
                Status = 'Open - Not Contacted'
            ));
        }
        
        Test.startTest();
        List<Id> contactIds = new List<Id>();
        for (Lead lead : testLeads) {
            Id contactId = ACME_ContactProvider.findOrCreateContact(lead, testAccount.Id);
            contactIds.add(contactId);
        }
        Test.stopTest();
        
        System.assertEquals(5, contactIds.size(), 'Should create 5 contacts');
        
        List<Contact> createdContacts = [SELECT Id, Email FROM Contact WHERE Id IN :contactIds];
        System.assertEquals(5, createdContacts.size(), 'All contacts should be created');
    }
}