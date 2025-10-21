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
            Name = 'Test Account',
            Industry = 'Technology',
            AnnualRevenue = 1000000
        );
        insert testAccount;
        
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@test.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Create test lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'test.lead@test.com',
            Phone = '555-123-0000',
            Status = 'Open - Not Contacted',
            AnnualRevenue = 500000
        );
        insert testLead;
        
        // Create test opportunities
        List<Opportunity> testOpps = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            testOpps.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                AccountId = testAccount.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Amount = 60000 + (i * 10000)
            ));
        }
        insert testOpps;
    }
    
    @IsTest
    static void testCreateOpportunityFromLead() {
        Lead testLead = [SELECT Id, Company, Name, LeadSource, OwnerId, AnnualRevenue FROM Lead LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        Id oppId = ACME_OpportunityProvider.createOpportunityFromLead(testLead, testAccount.Id, testContact.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, oppId, 'Opportunity should be created');
        
        Opportunity createdOpp = [SELECT Id, Name, AccountId, StageName, Amount FROM Opportunity WHERE Id = :oppId];
        System.assertEquals(testAccount.Id, createdOpp.AccountId, 'Account should be set correctly');
        System.assertEquals('Qualification', createdOpp.StageName, 'Stage should be set to Qualification');
        System.assert(createdOpp.Amount > 0, 'Amount should be greater than 0');
    }
    
    @IsTest
    static void testGetHighValueOpportunities() {
        Test.startTest();
        List<Opportunity> highValueOpps = ACME_OpportunityProvider.getHighValueOpportunities();
        Test.stopTest();
        
        System.assertNotEquals(null, highValueOpps, 'Should return opportunities list');
        for (Opportunity opp : highValueOpps) {
            System.assert(opp.Amount > 50000, 'All opportunities should be high value');
        }
    }
    
    @IsTest
    static void testUpdateOpportunityStage() {
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        String newStage = 'Proposal/Price Quote';
        
        Test.startTest();
        ACME_OpportunityProvider.updateOpportunityStage(testOpp.Id, newStage);
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertEquals(newStage, updatedOpp.StageName, 'Stage should be updated correctly');
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
}