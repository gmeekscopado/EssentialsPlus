@IsTest
private class ACME_ContactProviderTest {

    @TestSetup
    static void setupTestData() {
        // Create common test account using the factory
        Account testAccount = TestDataFactory.createAccounts(1, true)[0];

        // Create an existing contact for find-or-create scenarios
        Contact existingContact = TestDataFactory.createContacts(1, testAccount.Id, false)[0];
        existingContact.FirstName = 'Existing';
        existingContact.LastName = 'Contact';
        existingContact.Email = 'existing.contact@test.com';
        existingContact.Title = 'VP Sales';
        insert existingContact;

        // Create various decision maker contacts
        List<Contact> decisionMakers = new List<Contact>();
        decisionMakers.add(new Contact(FirstName='John', LastName='Director', Email='jd@test.com', AccountId=testAccount.Id, Title='Director of Sales'));
        decisionMakers.add(new Contact(FirstName='Jane', LastName='Manager', Email='jm@test.com', AccountId=testAccount.Id, Title='Sales Manager'));
        decisionMakers.add(new Contact(FirstName='Bob', LastName='VeeP', Email='bv@test.com', AccountId=testAccount.Id, Title='VP of Marketing'));
        decisionMakers.add(new Contact(FirstName='Alice', LastName='President', Email='ap@test.com', AccountId=testAccount.Id, Title='President'));
        decisionMakers.add(new Contact(FirstName='Regular', LastName='Employee', Email='re@test.com', AccountId=testAccount.Id, Title='Sales Representative'));
        insert decisionMakers;
    }

    @IsTest
    static void testFindOrCreate_FindExisting() {
        // Arrange
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact existingContact = [SELECT Id, Email FROM Contact WHERE Email = 'existing.contact@test.com' LIMIT 1];
        List<Lead> leads = TestDataFactory.createLeads(1, true);
        leads[0].Email = existingContact.Email;

        // Act
        Test.startTest();
        Map<Id, Id> leadContactMap = ACME_ContactProvider.findOrCreateContacts(leads, acc.Id);
        Test.stopTest();

        // Assert
        System.assertEquals(1, leadContactMap.size());
        System.assertEquals(existingContact.Id, leadContactMap.get(leads[0].Id));
    }

    @IsTest
    static void testFindOrCreate_CreateNew() {
        // Arrange
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Lead> leads = TestDataFactory.createLeads(1, true);
        leads[0].Email = 'new.contact@test.com';
        Integer contactsBefore = [SELECT COUNT() FROM Contact];

        // Act
        Test.startTest();
        Map<Id, Id> leadContactMap = ACME_ContactProvider.findOrCreateContacts(leads, acc.Id);
        Test.stopTest();

        // Assert
        Integer contactsAfter = [SELECT COUNT() FROM Contact];
        System.assertEquals(1, contactsAfter - contactsBefore, 'A new contact should have been created');
        System.assertNotEquals(null, leadContactMap.get(leads[0].Id), 'Should return the new contact ID');
    }

    @IsTest
    static void testFindOrCreate_NameParsing() {
        // Arrange
        Account acc = [SELECT Id FROM Account LIMIT 1];
        User testUser = TestDataFactory.getTestUser();
        // Simulate a Lead object that could not be created directly in Apex
        String leadJson = '{"attributes":{"type":"Lead"},"Name":"Name Parser","Email":"nameparsing@test.com", "OwnerId":"' + testUser.Id + '"}';
        Lead leadStub = (Lead)JSON.deserialize(leadJson, Lead.class);
        List<Lead> leads = new List<Lead>{leadStub};

        // Act
        Test.startTest();
        ACME_ContactProvider.findOrCreateContacts(leads, acc.Id);
        Test.stopTest();

        // Assert
        Contact result = [SELECT FirstName, LastName FROM Contact WHERE Email = 'nameparsing@test.com'];
        System.assertEquals('Name', result.FirstName);
        System.assertEquals('Parser', result.LastName);
    }

    @IsTest
    static void testFindOrCreate_BulkMixAndLimits() {
        // Arrange
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact existingContact = [SELECT Id, Email FROM Contact WHERE Email = 'existing.contact@test.com' LIMIT 1];
        List<Lead> leads = TestDataFactory.createLeads(199, false);
        for(Integer i = 0; i < leads.size(); i++) {
            leads[i].Email = 'bulk' + i + '@test.com';
        }
        Lead existingLead = TestDataFactory.createLeads(1, false)[0];
        existingLead.Email = existingContact.Email;
        leads.add(existingLead);
        insert leads;

        // Act
        Test.startTest();
        Map<Id, Id> leadContactMap = ACME_ContactProvider.findOrCreateContacts(leads, acc.Id);
        Test.stopTest();

        // Assert
        System.assertEquals(200, leadContactMap.size(), 'Should process 200 leads');
        System.assertEquals(existingContact.Id, leadContactMap.get(existingLead.Id), 'Should find the existing contact');
        System.assertNotEquals(null, leadContactMap.get(leads[0].Id), 'Should have created a new contact');
    }

    @IsTest
    static void testGetDecisionMakers_Success() {
        // Arrange
        Account acc = [SELECT Id FROM Account LIMIT 1];

        // Act
        Test.startTest();
        List<Contact> decisionMakers = ACME_ContactProvider.getDecisionMakers(acc.Id);
        Test.stopTest();

        // Assert
        System.assertEquals(5, decisionMakers.size(), 'Should return 5 decision makers');
    }

    @IsTest
    static void testExceptions() {
        // Arrange: Setup for DML Exception
        List<Lead> leads = TestDataFactory.createLeads(1, false);
        leads[0].Email = 'exception@test.com';
        insert leads;
        Id invalidAccountId = '001000000000000AAA'; // Invalid ID

        // Act & Assert for multiple exception scenarios
        Test.startTest();
        // 1. DML Exception
        try {
            ACME_ContactProvider.findOrCreateContacts(leads, invalidAccountId);
            System.assert(false, 'Expected a DML exception to be wrapped in AcmeDataException.');
        } catch (ACME_ContactProvider.AcmeDataException e) {
            System.assert(e.getMessage().contains('Failed to create contacts'), 'Incorrect exception message for DML failure.');
        }

        // 2. Null Account ID for getDecisionMakers
        try {
            ACME_ContactProvider.getDecisionMakers(null);
            System.assert(false, 'Expected an AcmeDataException for null account ID.');
        } catch (ACME_ContactProvider.AcmeDataException e) {
            System.assert(e.getMessage().contains('Account ID cannot be null'), 'Incorrect exception message for null account.');
        }
        Test.stopTest();
    }

    @IsTest
    static void testEdgeCases_EmptyAndNull() {
        // Arrange
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Lead> leads = TestDataFactory.createLeads(1, true);

        // Act
        Test.startTest();
        Map<Id, Id> resultEmptyList = ACME_ContactProvider.findOrCreateContacts(new List<Lead>(), acc.Id);
        Map<Id, Id> resultNullList = ACME_ContactProvider.findOrCreateContacts(null, acc.Id);
        Map<Id, Id> resultNullAccount = ACME_ContactProvider.findOrCreateContacts(leads, null);
        Test.stopTest();

        // Assert
        System.assert(resultEmptyList.isEmpty(), 'Should return an empty map for an empty list of leads');
        System.assert(resultNullList.isEmpty(), 'Should return an empty map for a null list of leads');
        System.assert(resultNullAccount.isEmpty(), 'Should return an empty map for a null account ID');
    }
}