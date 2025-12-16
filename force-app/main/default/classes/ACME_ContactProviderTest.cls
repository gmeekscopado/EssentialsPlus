/**
 * @description Test class for ACME_ContactProvider, ensuring bulkification, security, and naming conventions.
 * @author ACME Corporation
 * @date 2025-12-15
 */
@IsTest
private class ACME_ContactProviderTest {

    @TestSetup
    static void setupTestData() {
        // Use TestDataFactory to create a consistent set of test data
        TestDataFactory.createTestAccounts(1);
        TestDataFactory.createTestContacts(5);
    }

    /**
     * @description Verifies that the findOrCreateContacts method can handle a large volume of new leads
     * without hitting governor limits.
     */
    @IsTest
    static void testBulkContactCreation() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        List<Lead> bulkLeads = TestDataFactory.createTestLeads(150, true);

        System.runAs(testUser) {
            Test.startTest();
            Map<Id, Id> leadContactMap = ACME_ContactProvider.findOrCreateContacts(bulkLeads, testAccount.Id);
            Test.stopTest();

            System.assertEquals(150, leadContactMap.size(), 'Should have processed all 150 leads.');
            Integer createdContacts = [SELECT COUNT() FROM Contact WHERE AccountId = :testAccount.Id AND Email LIKE 'test.lead%@acme.com'];
            System.assertEquals(150, createdContacts, 'Should have inserted 150 new contacts.');
        }
    }

    /**
     * @description Tests the scenario of processing a mix of leads that match existing contacts and new leads.
     */
    @IsTest
    static void testMixedNewAndExistingContacts() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        Contact existingContact = [SELECT Id, Email FROM Contact WHERE Email != null LIMIT 1];
        
        List<Lead> leadsToProcess = new List<Lead>();
        leadsToProcess.add(new Lead(LastName='ExistingMatch', Company='ACME', Email = existingContact.Email, OwnerId = testUser.Id));
        leadsToProcess.add(new Lead(LastName = 'Unique', Company='ACME', Email = 'new.unique.lead@acme.com', OwnerId = testUser.Id));
        insert leadsToProcess;

        System.runAs(testUser) {
            Test.startTest();
            Map<Id, Id> leadContactMap = ACME_ContactProvider.findOrCreateContacts(leadsToProcess, testAccount.Id);
            Test.stopTest();

            System.assertEquals(2, leadContactMap.size(), 'Should have processed both leads.');
            System.assertEquals(existingContact.Id, leadContactMap.get(leadsToProcess[0].Id), 'Should have found the existing contact.');
            System.assertNotEquals(null, leadContactMap.get(leadsToProcess[1].Id), 'Should have created a new contact.');
        }
    }

    /**
     * @description Verifies that a lead with a single-word name is handled correctly.
     */
    @IsTest
    static void testSingleWordNameParsing() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        Lead testLead = new Lead(FirstName='Cher', LastName='Sarkisian', Company='ACME', Email='cher@acme.com', OwnerId = testUser.Id);
        insert testLead;
        
        Lead leadToProcess = [SELECT Id, Name, Email, Phone, Title, LeadSource, OwnerId FROM Lead WHERE Id = :testLead.Id];
        leadToProcess.FirstName = null;
        leadToProcess.LastName = null;

        System.runAs(testUser) {
            Test.startTest();
            Map<Id, Id> leadContactMap = ACME_ContactProvider.findOrCreateContacts(new List<Lead>{leadToProcess}, testAccount.Id);
            Test.stopTest();

            Contact result = [SELECT FirstName, LastName FROM Contact WHERE Id = :leadContactMap.values()[0]];
            System.assert(leadContactMap.values()[0] != null, 'A new contact should have been created.');
            System.assertEquals('Cher', result.FirstName, 'First name should be parsed from the Name field.');
            System.assertEquals('Sarkisian', result.LastName, 'Last name should be parsed from the Name field.');
        }
    }

    /**
     * @description Tests that the getDecisionMakers method returns the correct contacts.
     */
    @IsTest
    static void testGetDecisionMakers() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            List<Contact> decisionMakers = ACME_ContactProvider.getDecisionMakers(testAccount.Id);
            Test.stopTest();

            System.assert(!decisionMakers.isEmpty(), 'Should return a list of decision makers.');
            for(Contact c : decisionMakers) {
                System.assert(c.Title.contains('Manager') || c.Title.contains('Director'), 'Returned contact should be a decision maker.');
            }
        }
    }

    /**
     * @description Verifies that the correct exception is thrown when a null Account ID is passed.
     */
    @IsTest
    static void testNullAccountIdException() {
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        List<Lead> leads = new List<Lead>{ new Lead(LastName = 'Test', Company='ACME', OwnerId = testUser.Id) };

        System.runAs(testUser) {
            Test.startTest();
            try {
                ACME_ContactProvider.findOrCreateContacts(leads, null);
                System.assert(false, 'An AcmeDataException should have been thrown for a null account ID.');
            } catch (ACME_ContactProvider.AcmeDataException e) {
                System.assert(e.getMessage().contains('Account ID cannot be null'), 'Exception message is not correct.');
            } 
            Test.stopTest();
        }
    }
}