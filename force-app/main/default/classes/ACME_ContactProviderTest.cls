/**
 * @description Comprehensive test class for ACME_ContactProvider
 * @author ACME Corporation
 * @date 2024
 */
@IsTest
private class ACME_ContactProviderTest {
    
    /**
     * @description Test data setup method
     */
    @TestSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Industry = 'Technology',
            AnnualRevenue = 1000000
        );
        insert testAccount;
        
        // Create existing contact for find scenario
        Contact existingContact = new Contact(
            FirstName = 'Existing',
            LastName = 'Contact',
            Email = 'existing.contact@test.com',
            Phone = '555-1234',
            AccountId = testAccount.Id,
            Title = 'VP Sales'
        );
        insert existingContact;
        
        // Create decision maker contacts with various titles
        List<Contact> decisionMakers = new List<Contact>();
        
        decisionMakers.add(new Contact(
            FirstName = 'John',
            LastName = 'Director',
            Email = 'john.director@test.com',
            Phone = '555-0001',
            AccountId = testAccount.Id,
            Title = 'Director of Sales',
            Department = 'Sales'
        ));
        
        decisionMakers.add(new Contact(
            FirstName = 'Jane',
            LastName = 'Manager',
            Email = 'jane.manager@test.com',
            Phone = '555-0002',
            AccountId = testAccount.Id,
            Title = 'Sales Manager',
            Department = 'Sales'
        ));
        
        decisionMakers.add(new Contact(
            FirstName = 'Bob',
            LastName = 'VeeP',
            Email = 'bob.vp@test.com',
            Phone = '555-0003',
            AccountId = testAccount.Id,
            Title = 'VP of Marketing',
            Department = 'Marketing'
        ));
        
        decisionMakers.add(new Contact(
            FirstName = 'Alice',
            LastName = 'President',
            Email = 'alice.president@test.com',
            Phone = '555-0004',
            AccountId = testAccount.Id,
            Title = 'President',
            Department = 'Executive'
        ));
        
        decisionMakers.add(new Contact(
            FirstName = 'Regular',
            LastName = 'Employee',
            Email = 'regular.employee@test.com',
            Phone = '555-0005',
            AccountId = testAccount.Id,
            Title = 'Sales Representative',
            Department = 'Sales'
        ));
        
        insert decisionMakers;
        
        // Create test lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'test.lead@test.com',
            Phone = '555-9999',
            Title = 'Manager',
            Status = 'Open - Not Contacted',
            LeadSource = 'Web'
        );
        insert testLead;
    }
    
    /**
     * @description Test finding existing contact by email and accountId
     */
    @IsTest
    static void testFindOrCreateContact_FindExisting() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact existingContact = [SELECT Id, Email FROM Contact WHERE Email = 'existing.contact@test.com' LIMIT 1];
        
        Lead testLead = new Lead(
            FirstName = 'Existing',
            LastName = 'Contact',
            Company = 'Test Company',
            Email = 'existing.contact@test.com',
            Phone = '555-1234',
            Title = 'VP Sales',
            Status = 'Open - Not Contacted'
        );
        
        // Act
        Test.startTest();
        Id contactId = ACME_ContactProvider.findOrCreateContact(testLead, testAccount.Id);
        Test.stopTest();
        
        // Assert
        System.assertEquals(existingContact.Id, contactId, 'Should return existing contact ID');
        
        // Verify no new contact was created
        Integer contactCount = [SELECT COUNT() FROM Contact WHERE Email = 'existing.contact@test.com'];
        System.assertEquals(1, contactCount, 'Should not create duplicate contact');
    }
    
    /**
     * @description Test creating new contact when none exists
     */
    @IsTest
    static void testFindOrCreateContact_CreateNew() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Lead testLead = new Lead(
            FirstName = 'New',
            LastName = 'Contact',
            Company = 'New Company',
            Email = 'new.contact@test.com',
            Phone = '555-7777',
            Title = 'Director',
            Status = 'Open - Not Contacted',
            LeadSource = 'Referral'
        );
        insert testLead;
        
        // Act
        Test.startTest();
        Id contactId = ACME_ContactProvider.findOrCreateContact(testLead, testAccount.Id);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, contactId, 'Should return new contact ID');
        
        Contact createdContact = [SELECT Id, FirstName, LastName, Email, Phone, Title, AccountId, LeadSource, OwnerId 
                                  FROM Contact 
                                  WHERE Id = :contactId];
        
        System.assertEquals('New', createdContact.FirstName, 'FirstName should be parsed correctly');
        System.assertEquals('Contact', createdContact.LastName, 'LastName should be parsed correctly');
        System.assertEquals('new.contact@test.com', createdContact.Email, 'Email should match');
        System.assertEquals('555-7777', createdContact.Phone, 'Phone should match');
        System.assertEquals('Director', createdContact.Title, 'Title should match');
        System.assertEquals(testAccount.Id, createdContact.AccountId, 'AccountId should match');
        System.assertEquals('Referral', createdContact.LeadSource, 'LeadSource should match');
        System.assertEquals(testLead.OwnerId, createdContact.OwnerId, 'OwnerId should match');
    }
    
    /**
     * @description Test creating contact with single name (edge case)
     */
    @IsTest
    static void testFindOrCreateContact_SingleName() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Lead testLead = new Lead(
            FirstName = 'Madonna',
            LastName = 'Madonna',
            Company = 'Single Name Company',
            Email = 'madonna@test.com',
            Phone = '555-8888',
            Status = 'Open - Not Contacted'
        );
        insert testLead;
        
        // Act
        Test.startTest();
        Id contactId = ACME_ContactProvider.findOrCreateContact(testLead, testAccount.Id);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, contactId, 'Should create contact even with single name');
        
        Contact createdContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :contactId];
        System.assertNotEquals(null, createdContact.LastName, 'LastName should not be null');
    }
    
    /**
     * @description Test exception handling with null lead data
     */
    @IsTest
    static void testFindOrCreateContact_NullLeadException() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Act & Assert
        Test.startTest();
        try {
            ACME_ContactProvider.findOrCreateContact(null, testAccount.Id);
            System.assert(false, 'Should throw AcmeDataException');
        } catch (ACME_ContactProvider.AcmeDataException e) {
            System.assert(e.getMessage().contains('Failed to find or create contact'), 'Exception message should be correct');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test exception handling with null accountId
     */
    @IsTest
    static void testFindOrCreateContact_NullAccountException() {
        // Arrange
        Lead testLead = [SELECT Id, FirstName, LastName, Company, Email, Phone, Title, Status FROM Lead LIMIT 1];
        
        // Act & Assert
        Test.startTest();
        try {
            ACME_ContactProvider.findOrCreateContact(testLead, null);
            System.assert(false, 'Should throw AcmeDataException');
        } catch (ACME_ContactProvider.AcmeDataException e) {
            System.assert(e.getMessage().contains('Failed to find or create contact'), 'Exception message should be correct');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test retrieving decision makers with various titles
     */
    @IsTest
    static void testGetDecisionMakers_Success() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Act
        Test.startTest();
        List<Contact> decisionMakers = ACME_ContactProvider.getDecisionMakers(testAccount.Id);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, decisionMakers, 'Should return list of decision makers');
        System.assertEquals(4, decisionMakers.size(), 'Should return 4 decision makers (Director, Manager, VP, President)');
        
        // Verify all returned contacts have decision maker titles
        for (Contact contact : decisionMakers) {
            Boolean hasDecisionMakerTitle = 
                contact.Title.contains('Director') ||
                contact.Title.contains('Manager') ||
                contact.Title.contains('VP') ||
                contact.Title.contains('President');
            
            System.assert(hasDecisionMakerTitle, 'Contact should have decision maker title: ' + contact.Title);
        }
    }
    
    /**
     * @description Test retrieving decision makers when none exist
     */
    @IsTest
    static void testGetDecisionMakers_NoResults() {
        // Arrange - Create new account with no contacts
        Account emptyAccount = new Account(
            Name = 'Empty Account',
            Industry = 'Finance'
        );
        insert emptyAccount;
        
        // Act
        Test.startTest();
        List<Contact> decisionMakers = ACME_ContactProvider.getDecisionMakers(emptyAccount.Id);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, decisionMakers, 'Should return empty list, not null');
        System.assertEquals(0, decisionMakers.size(), 'Should return no decision makers for empty account');
    }
    
    /**
     * @description Test exception handling with null accountId in getDecisionMakers
     */
    @IsTest
    static void testGetDecisionMakers_NullAccountException() {
        // Act & Assert
        Test.startTest();
        try {
            ACME_ContactProvider.getDecisionMakers(null);
            System.assert(false, 'Should throw AcmeDataException');
        } catch (ACME_ContactProvider.AcmeDataException e) {
            System.assert(e.getMessage().contains('Failed to retrieve decision makers'), 'Exception message should be correct');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test bulk contact creation (governor limits)
     */
    @IsTest
    static void testFindOrCreateContact_BulkProcessing() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        List<Lead> bulkLeads = new List<Lead>();
        for (Integer i = 0; i < 100; i++) {
            bulkLeads.add(new Lead(
                FirstName = 'Bulk',
                LastName = 'Lead' + i,
                Company = 'Bulk Company ' + i,
                Email = 'bulk' + i + '@test.com',
                Phone = '555-' + Math.mod(i, 10000),
                Status = 'Open - Not Contacted',
                LeadSource = 'Web'
            ));
        }
        insert bulkLeads;
        
        // Act
        Test.startTest();
        List<Id> contactIds = new List<Id>();
        for (Lead lead : bulkLeads) {
            Id contactId = ACME_ContactProvider.findOrCreateContact(lead, testAccount.Id);
            contactIds.add(contactId);
        }
        Test.stopTest();
        
        // Assert
        System.assertEquals(100, contactIds.size(), 'Should create 100 contacts');
        
        List<Contact> createdContacts = [SELECT Id FROM Contact WHERE Id IN :contactIds];
        System.assertEquals(100, createdContacts.size(), 'All contacts should be inserted successfully');
    }
    
    /**
     * @description Test name parsing with multiple spaces
     */
    @IsTest
    static void testFindOrCreateContact_NameParsingWithSpaces() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Smith Jr.',
            Company = 'Complex Name Company',
            Email = 'john.smith.jr@test.com',
            Phone = '555-3333',
            Status = 'Open - Not Contacted'
        );
        insert testLead;
        
        // Act
        Test.startTest();
        Id contactId = ACME_ContactProvider.findOrCreateContact(testLead, testAccount.Id);
        Test.stopTest();
        
        // Assert
        Contact createdContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :contactId];
        System.assertNotEquals(null, createdContact.FirstName, 'FirstName should be parsed');
        System.assertNotEquals(null, createdContact.LastName, 'LastName should be parsed');
    }
    
    /**
     * @description Test getDecisionMakers with multiple accounts
     */
    @IsTest
    static void testGetDecisionMakers_MultipleAccounts() {
        // Arrange - Create second account with decision makers
        Account secondAccount = new Account(
            Name = 'Second Account',
            Industry = 'Healthcare'
        );
        insert secondAccount;
        
        Contact decisionMaker = new Contact(
            FirstName = 'Sarah',
            LastName = 'Director',
            Email = 'sarah.director@test.com',
            Phone = '555-2222',
            AccountId = secondAccount.Id,
            Title = 'Director of Operations',
            Department = 'Operations'
        );
        insert decisionMaker;
        
        // Act
        Test.startTest();
        List<Contact> decisionMakers = ACME_ContactProvider.getDecisionMakers(secondAccount.Id);
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, decisionMakers.size(), 'Should return decision makers only for specified account');
        System.assertEquals('Sarah', decisionMakers[0].FirstName, 'Should return correct decision maker');
    }
    
    /**
     * @description Test contact fields are properly populated
     */
    @IsTest
    static void testFindOrCreateContact_AllFieldsPopulated() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Lead testLead = new Lead(
            FirstName = 'Complete',
            LastName = 'Fields',
            Company = 'Complete Company',
            Email = 'complete.fields@test.com',
            Phone = '555-4444',
            Title = 'Chief Technology Officer',
            Status = 'Open - Not Contacted',
            LeadSource = 'Partner'
        );
        insert testLead;
        
        // Act
        Test.startTest();
        Id contactId = ACME_ContactProvider.findOrCreateContact(testLead, testAccount.Id);
        Test.stopTest();
        
        // Assert
        Contact createdContact = [SELECT Id, Email, Phone, Title, LeadSource 
                                  FROM Contact 
                                  WHERE Id = :contactId];
        
        System.assertEquals('complete.fields@test.com', createdContact.Email, 'Email should be populated');
        System.assertEquals('555-4444', createdContact.Phone, 'Phone should be populated');
        System.assertEquals('Chief Technology Officer', createdContact.Title, 'Title should be populated');
        System.assertEquals('Partner', createdContact.LeadSource, 'LeadSource should be populated');
    }
}