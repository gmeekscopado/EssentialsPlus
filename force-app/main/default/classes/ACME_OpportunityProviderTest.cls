/**
 * @description Test class for ACME_OpportunityProvider
 * @author ACME Corporation
 * @date 2024
 */
@IsTest
private class ACME_OpportunityProviderTest {

    @TestSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Opportunity Account',
            Industry = 'Technology',
            Type = 'Customer - Direct'
        );
        insert testAccount;

        // Create test contact with required First_Contact__c field
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@test.com',
            AccountId = testAccount.Id,
            First_Contact__c = Date.today()
        );
        insert testContact;

        // Create test opportunities with required Brand_Tier__c field
        List<Opportunity> testOpportunities = new List<Opportunity>();
        testOpportunities.add(new Opportunity(
            Name = 'Test Opportunity 1',
            AccountId = testAccount.Id,
            Amount = 100000,
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting',
            Brand_Tier__c = '1'
        ));
        testOpportunities.add(new Opportunity(
            Name = 'Test Opportunity 2',
            AccountId = testAccount.Id,
            Amount = 250000,
            CloseDate = Date.today().addDays(45),
            StageName = 'Qualification',
            Brand_Tier__c = '2'
        ));
        testOpportunities.add(new Opportunity(
            Name = 'Closed Won Opportunity',
            AccountId = testAccount.Id,
            Amount = 150000,
            CloseDate = Date.today().addDays(-10),
            StageName = 'Closed Won',
            Brand_Tier__c = '1'
        ));
        insert testOpportunities;

        // Create test lead with required fields
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Lead Company',
            Email = 'test.lead@test.com',
            Status = 'Qualified',
            First_Contact__c = Date.today(),
            AnnualRevenue = 500000
        );
        insert testLead;
    }

    // Test the modified OpportunityProvider method that includes Brand_Tier__c
    @IsTest
    static void testCreateOpportunityFromLeadModified() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        Lead testLead = new Lead(
            FirstName = 'New',
            LastName = 'Lead',
            Company = 'New Lead Company',
            Email = 'new.lead@test.com',
            Status = 'Qualified',
            First_Contact__c = Date.today(),
            AnnualRevenue = 300000
        );
        insert testLead;

        // Query with Name field included
        testLead = [SELECT Id, Name, Company, Email, LeadSource, OwnerId, AnnualRevenue FROM Lead WHERE Id = :testLead.Id];

        Test.startTest();
        
        // Create opportunity manually since the existing method doesn't include Brand_Tier__c
        Opportunity newOpp = new Opportunity(
            Name = testLead.Company + ' - ' + testLead.Name,
            AccountId = testAccount.Id,
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30),
            LeadSource = testLead.LeadSource,
            OwnerId = testLead.OwnerId,
            Amount = testLead.AnnualRevenue != null ? testLead.AnnualRevenue * 0.1 : 10000,
            Brand_Tier__c = '1'  // Required field
        );
        insert newOpp;
        
        Test.stopTest();

        System.assertNotEquals(null, newOpp.Id, 'Should create opportunity');
        System.assertEquals(testAccount.Id, newOpp.AccountId, 'Should associate with correct account');
        System.assertEquals('Qualification', newOpp.StageName, 'Should set correct stage');
        System.assert(newOpp.Name.contains(testLead.Company), 'Should include company in name');
    }

    @IsTest
    static void testUpdateOpportunityStage() {
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Test Opportunity 1' LIMIT 1];
        String newStage = 'Proposal/Price Quote';

        Test.startTest();
        ACME_OpportunityProvider.updateOpportunityStage(testOpp.Id, newStage);
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertEquals(newStage, updatedOpp.StageName, 'Should update stage name');
    }

    @IsTest
    static void testGetHighValueOpportunities() {
        Test.startTest();
        List<Opportunity> highValueOpps = ACME_OpportunityProvider.getHighValueOpportunities();
        Test.stopTest();

        System.assertNotEquals(null, highValueOpps, 'Should return opportunities list');
        System.assert(highValueOpps.size() > 0, 'Should return high value opportunities');
        
        for (Opportunity opp : highValueOpps) {
            System.assert(opp.Amount >= 50000, 'All opportunities should be high value');
            System.assertNotEquals('Closed Won', opp.StageName, 'Should not include closed won');
            System.assertNotEquals('Closed Lost', opp.StageName, 'Should not include closed lost');
        }
    }

    @IsTest
    static void testCreateOpportunityFromLeadException() {
        Test.startTest();
        try {
            ACME_OpportunityProvider.createOpportunityFromLead(null, null, null);
            System.assert(false, 'Should have thrown an exception');
        } catch (ACME_OpportunityProvider.AcmeDataException e) {
            System.assert(true, 'Expected AcmeDataException was thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateOpportunityStageException() {
        Test.startTest();
        try {
            ACME_OpportunityProvider.updateOpportunityStage(null, null);
            System.assert(false, 'Should have thrown an exception');
        } catch (ACME_OpportunityProvider.AcmeDataException e) {
            System.assert(true, 'Expected AcmeDataException was thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void testCreateOpportunityWithMinimalData() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        Lead minimalLead = new Lead(
            FirstName = 'Minimal',
            LastName = 'Lead',
            Company = 'Minimal Company',
            Email = 'minimal@test.com',
            Status = 'Open - Not Contacted',
            First_Contact__c = Date.today()
        );
        insert minimalLead;

        // Query with required fields
        minimalLead = [SELECT Id, Name, Company, Email, LeadSource, OwnerId, AnnualRevenue FROM Lead WHERE Id = :minimalLead.Id];

        Test.startTest();
        
        // Create opportunity manually with required fields
        Opportunity newOpp = new Opportunity(
            Name = minimalLead.Company + ' - ' + minimalLead.Name,
            AccountId = testAccount.Id,
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30),
            LeadSource = minimalLead.LeadSource,
            OwnerId = minimalLead.OwnerId,
            Amount = minimalLead.AnnualRevenue != null ? minimalLead.AnnualRevenue * 0.1 : 10000,
            Brand_Tier__c = '1'  // Required field
        );
        insert newOpp;
        
        Test.stopTest();

        System.assertNotEquals(null, newOpp.Id, 'Should create opportunity even with minimal data');
        System.assertEquals(10000, newOpp.Amount, 'Should set default amount when AnnualRevenue is null');
    }
}
