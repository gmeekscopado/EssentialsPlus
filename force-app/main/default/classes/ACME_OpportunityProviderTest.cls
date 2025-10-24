/**
 * @description Comprehensive test class for ACME_OpportunityProvider
 * @author ACME Corporation
 * @date 2024
 */
@IsTest
private class ACME_OpportunityProviderTest {
    
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
        
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@test.com',
            Phone = '555-1234',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Create test lead with AnnualRevenue
        Lead leadWithRevenue = new Lead(
            FirstName = 'Revenue',
            LastName = 'Lead',
            Company = 'Revenue Company',
            Email = 'revenue.lead@test.com',
            Phone = '555-1111',
            Status = 'Open - Not Contacted',
            LeadSource = 'Web',
            AnnualRevenue = 100000
        );
        insert leadWithRevenue;
        
        // Create test lead without AnnualRevenue
        Lead leadWithoutRevenue = new Lead(
            FirstName = 'No Revenue',
            LastName = 'Lead',
            Company = 'No Revenue Company',
            Email = 'norevenue.lead@test.com',
            Phone = '555-2222',
            Status = 'Open - Not Contacted',
            LeadSource = 'Referral'
        );
        insert leadWithoutRevenue;
        
        // Create high-value opportunities
        List<Opportunity> highValueOpps = new List<Opportunity>();
        
        highValueOpps.add(new Opportunity(
            Name = 'High Value Opp 1',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 75000,
            LeadSource = 'Web'
        ));
        
        highValueOpps.add(new Opportunity(
            Name = 'High Value Opp 2',
            AccountId = testAccount.Id,
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(15),
            Amount = 100000,
            LeadSource = 'Partner'
        ));
        
        highValueOpps.add(new Opportunity(
            Name = 'High Value Opp 3',
            AccountId = testAccount.Id,
            StageName = 'Proposal/Price Quote',
            CloseDate = Date.today().addDays(45),
            Amount = 150000,
            LeadSource = 'Referral'
        ));
        
        insert highValueOpps;
        
        // Create low-value opportunity (should not be returned)
        Opportunity lowValueOpp = new Opportunity(
            Name = 'Low Value Opp',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 25000,
            LeadSource = 'Web'
        );
        insert lowValueOpp;
        
        // Create closed opportunities (should not be returned)
        List<Opportunity> closedOpps = new List<Opportunity>();
        
        closedOpps.add(new Opportunity(
            Name = 'Closed Won Opp',
            AccountId = testAccount.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(-30),
            Amount = 80000,
            LeadSource = 'Web'
        ));
        
        closedOpps.add(new Opportunity(
            Name = 'Closed Lost Opp',
            AccountId = testAccount.Id,
            StageName = 'Closed Lost',
            CloseDate = Date.today().addDays(-15),
            Amount = 60000,
            LeadSource = 'Partner'
        ));
        
        insert closedOpps;
    }
    
    /**
     * @description Test creating opportunity from lead with AnnualRevenue
     */
    @IsTest
    static void testCreateOpportunityFromLead_WithRevenue() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        Lead testLead = [SELECT Id, Company, FirstName, LastName, LeadSource, OwnerId, AnnualRevenue 
                         FROM Lead 
                         WHERE Email = 'revenue.lead@test.com' 
                         LIMIT 1];
        
        // Act
        Test.startTest();
        Id oppId = ACME_OpportunityProvider.createOpportunityFromLead(testLead, testAccount.Id, testContact.Id);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, oppId, 'Opportunity ID should not be null');
        
        Opportunity createdOpp = [SELECT Id, Name, AccountId, StageName, CloseDate, LeadSource, OwnerId, Amount 
                                  FROM Opportunity 
                                  WHERE Id = :oppId];
        
        System.assertEquals('Revenue Company - Revenue Lead', createdOpp.Name, 'Name should match expected format');
        System.assertEquals(testAccount.Id, createdOpp.AccountId, 'AccountId should match');
        System.assertEquals('Qualification', createdOpp.StageName, 'StageName should be Qualification');
        System.assertEquals(Date.today().addDays(30), createdOpp.CloseDate, 'CloseDate should be 30 days from today');
        System.assertEquals('Web', createdOpp.LeadSource, 'LeadSource should match');
        System.assertEquals(testLead.OwnerId, createdOpp.OwnerId, 'OwnerId should match');
        System.assertEquals(10000, createdOpp.Amount, 'Amount should be 10% of AnnualRevenue');
    }
    
    /**
     * @description Test creating opportunity from lead without AnnualRevenue
     */
    @IsTest
    static void testCreateOpportunityFromLead_WithoutRevenue() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        Lead testLead = [SELECT Id, Company, FirstName, LastName, LeadSource, OwnerId, AnnualRevenue 
                         FROM Lead 
                         WHERE Email = 'norevenue.lead@test.com' 
                         LIMIT 1];
        
        // Act
        Test.startTest();
        Id oppId = ACME_OpportunityProvider.createOpportunityFromLead(testLead, testAccount.Id, testContact.Id);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, oppId, 'Opportunity ID should not be null');
        
        Opportunity createdOpp = [SELECT Id, Name, Amount 
                                  FROM Opportunity 
                                  WHERE Id = :oppId];
        
        System.assertEquals('No Revenue Company - No Revenue Lead', createdOpp.Name, 'Name should match expected format');
        System.assertEquals(10000, createdOpp.Amount, 'Amount should default to 10000 when AnnualRevenue is null');
    }
    
    /**
     * @description Test exception handling with null lead data
     */
    @IsTest
    static void testCreateOpportunityFromLead_NullLeadException() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        // Act & Assert
        Test.startTest();
        try {
            ACME_OpportunityProvider.createOpportunityFromLead(null, testAccount.Id, testContact.Id);
            System.assert(false, 'Should throw AcmeDataException');
        } catch (ACME_OpportunityProvider.AcmeDataException e) {
            System.assert(e.getMessage().contains('Failed to create opportunity'), 'Exception message should be correct');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test exception handling with null accountId
     */
    @IsTest
    static void testCreateOpportunityFromLead_NullAccountException() {
        // Arrange
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        Lead testLead = [SELECT Id, Company, FirstName, LastName, LeadSource, OwnerId, AnnualRevenue 
                         FROM Lead 
                         LIMIT 1];
        
        // Act & Assert
        Test.startTest();
        try {
            ACME_OpportunityProvider.createOpportunityFromLead(testLead, null, testContact.Id);
            System.assert(false, 'Should throw AcmeDataException');
        } catch (ACME_OpportunityProvider.AcmeDataException e) {
            System.assert(e.getMessage().contains('Failed to create opportunity'), 'Exception message should be correct');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test retrieving high-value opportunities
     */
    @IsTest
    static void testGetHighValueOpportunities_Success() {
        // Act
        Test.startTest();
        List<Opportunity> highValueOpps = ACME_OpportunityProvider.getHighValueOpportunities();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, highValueOpps, 'Should return list of opportunities');
        System.assertEquals(3, highValueOpps.size(), 'Should return 3 high-value opportunities');
        
        // Verify all returned opportunities meet criteria
        for (Opportunity opp : highValueOpps) {
            System.assert(opp.Amount > 50000, 'All opportunities should have Amount > 50000');
            System.assertNotEquals('Closed Won', opp.StageName, 'Should not include Closed Won opportunities');
            System.assertNotEquals('Closed Lost', opp.StageName, 'Should not include Closed Lost opportunities');
        }
        
        // Verify ordering (descending by Amount)
        System.assert(highValueOpps[0].Amount >= highValueOpps[1].Amount, 'Should be ordered by Amount DESC');
        System.assert(highValueOpps[1].Amount >= highValueOpps[2].Amount, 'Should be ordered by Amount DESC');
    }
    
    /**
     * @description Test retrieving high-value opportunities returns correct fields
     */
    @IsTest
    static void testGetHighValueOpportunities_VerifyFields() {
        // Act
        Test.startTest();
        List<Opportunity> highValueOpps = ACME_OpportunityProvider.getHighValueOpportunities();
        Test.stopTest();
        
        // Assert - Verify all required fields are populated
        for (Opportunity opp : highValueOpps) {
            System.assertNotEquals(null, opp.Id, 'Id should be populated');
            System.assertNotEquals(null, opp.Name, 'Name should be populated');
            System.assertNotEquals(null, opp.Amount, 'Amount should be populated');
            System.assertNotEquals(null, opp.StageName, 'StageName should be populated');
            System.assertNotEquals(null, opp.CloseDate, 'CloseDate should be populated');
            System.assertNotEquals(null, opp.Account.Name, 'Account.Name should be populated');
            // Owner.Name and Owner.Email may be null for some users
        }
    }
    
    /**
     * @description Test getHighValueOpportunities when no opportunities exist
     */
    @IsTest
    static void testGetHighValueOpportunities_NoResults() {
        // Arrange - Delete all high-value opportunities
        delete [SELECT Id FROM Opportunity WHERE Amount > 50000];
        
        // Act
        Test.startTest();
        List<Opportunity> highValueOpps = ACME_OpportunityProvider.getHighValueOpportunities();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, highValueOpps, 'Should return empty list, not null');
        System.assertEquals(0, highValueOpps.size(), 'Should return no opportunities');
    }
    
    /**
     * @description Test updating opportunity stage
     */
    @IsTest
    static void testUpdateOpportunityStage_Success() {
        // Arrange
        Opportunity testOpp = [SELECT Id, StageName 
                               FROM Opportunity 
                               WHERE Name = 'High Value Opp 1' 
                               LIMIT 1];
        
        String originalStage = testOpp.StageName;
        String newStage = 'Negotiation/Review';
        
        // Act
        Test.startTest();
        ACME_OpportunityProvider.updateOpportunityStage(testOpp.Id, newStage);
        Test.stopTest();
        
        // Assert
        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertNotEquals(originalStage, updatedOpp.StageName, 'Stage should be updated');
        System.assertEquals(newStage, updatedOpp.StageName, 'Stage should match new value');
    }
    
    /**
     * @description Test updating opportunity stage with various stages
     */
    @IsTest
    static void testUpdateOpportunityStage_MultipleStages() {
        // Arrange
        List<Opportunity> testOpps = [SELECT Id, StageName 
                                      FROM Opportunity 
                                      WHERE Amount > 50000 
                                      ORDER BY Name 
                                      LIMIT 3];
        
        List<String> newStages = new List<String>{'Qualification', 'Proposal/Price Quote', 'Closed Won'};
        
        // Act
        Test.startTest();
        for (Integer i = 0; i < testOpps.size(); i++) {
            ACME_OpportunityProvider.updateOpportunityStage(testOpps[i].Id, newStages[i]);
        }
        Test.stopTest();
        
        // Assert
        List<Opportunity> updatedOpps = [SELECT Id, StageName 
                                         FROM Opportunity 
                                         WHERE Id IN :testOpps 
                                         ORDER BY Name];
        
        for (Integer i = 0; i < updatedOpps.size(); i++) {
            System.assertEquals(newStages[i], updatedOpps[i].StageName, 'Stage should be updated to ' + newStages[i]);
        }
    }
    
    /**
     * @description Test exception handling with null opportunity ID
     */
    @IsTest
    static void testUpdateOpportunityStage_NullIdException() {
        // Act & Assert
        Test.startTest();
        try {
            ACME_OpportunityProvider.updateOpportunityStage(null, 'Qualification');
            System.assert(false, 'Should throw AcmeDataException');
        } catch (ACME_OpportunityProvider.AcmeDataException e) {
            System.assert(e.getMessage().contains('Failed to update opportunity stage'), 'Exception message should be correct');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test exception handling with invalid stage name
     */
    @IsTest
    static void testUpdateOpportunityStage_InvalidStageException() {
        // Arrange
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Act & Assert
        Test.startTest();
        try {
            ACME_OpportunityProvider.updateOpportunityStage(testOpp.Id, 'Invalid Stage Name');
            System.assert(false, 'Should throw AcmeDataException for invalid stage');
        } catch (ACME_OpportunityProvider.AcmeDataException e) {
            System.assert(e.getMessage().contains('Failed to update opportunity stage'), 'Exception message should be correct');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test bulk opportunity creation (governor limits)
     */
    @IsTest
    static void testCreateOpportunityFromLead_BulkProcessing() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        List<Lead> bulkLeads = new List<Lead>();
        for (Integer i = 0; i < 100; i++) {
            bulkLeads.add(new Lead(
                FirstName = 'Bulk',
                LastName = 'Lead' + i,
                Company = 'Bulk Company ' + i,
                Email = 'bulk' + i + '@test.com',
                Phone = '555-' + Math.mod(i, 10000),
                Status = 'Open - Not Contacted',
                LeadSource = 'Web',
                AnnualRevenue = 50000 + (i * 1000)
            ));
        }
        insert bulkLeads;
        
        // Act
        Test.startTest();
        List<Id> oppIds = new List<Id>();
        for (Lead lead : bulkLeads) {
            Id oppId = ACME_OpportunityProvider.createOpportunityFromLead(lead, testAccount.Id, testContact.Id);
            oppIds.add(oppId);
        }
        Test.stopTest();
        
        // Assert
        System.assertEquals(100, oppIds.size(), 'Should create 100 opportunities');
        
        List<Opportunity> createdOpps = [SELECT Id FROM Opportunity WHERE Id IN :oppIds];
        System.assertEquals(100, createdOpps.size(), 'All opportunities should be inserted successfully');
    }
    
    /**
     * @description Test getHighValueOpportunities with exactly 20 results (limit test)
     */
    @IsTest
    static void testGetHighValueOpportunities_LimitTest() {
        // Arrange - Create 25 high-value opportunities
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        List<Opportunity> manyOpps = new List<Opportunity>();
        
        for (Integer i = 0; i < 25; i++) {
            manyOpps.add(new Opportunity(
                Name = 'Many Opps ' + i,
                AccountId = testAccount.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30 + i),
                Amount = 60000 + (i * 1000),
                LeadSource = 'Web'
            ));
        }
        insert manyOpps;
        
        // Act
        Test.startTest();
        List<Opportunity> highValueOpps = ACME_OpportunityProvider.getHighValueOpportunities();
        Test.stopTest();
        
        // Assert
        System.assert(highValueOpps.size() <= 20, 'Should respect LIMIT 20 in query');
    }
    
    /**
     * @description Test opportunity name formatting with edge cases
     */
    @IsTest
    static void testCreateOpportunityFromLead_NameFormatting() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        Lead testLead = new Lead(
            FirstName = 'Complex-Name',
            LastName = 'Test\'s',
            Company = 'Company & Associates',
            Email = 'complex@test.com',
            Phone = '555-9999',
            Status = 'Open - Not Contacted'
        );
        insert testLead;
        
        // Act
        Test.startTest();
        Id oppId = ACME_OpportunityProvider.createOpportunityFromLead(testLead, testAccount.Id, testContact.Id);
        Test.stopTest();
        
        // Assert
        Opportunity createdOpp = [SELECT Id, Name FROM Opportunity WHERE Id = :oppId];
        System.assert(createdOpp.Name.contains('Company & Associates'), 'Name should include company name with special characters');
    }
    
    /**
     * @description Test that LeadSource is properly carried over to Opportunity
     */
    @IsTest
    static void testCreateOpportunityFromLead_LeadSourceMapping() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        List<String> leadSources = new List<String>{'Web', 'Phone Inquiry', 'Partner Referral', 'Purchased List'};
        List<Id> oppIds = new List<Id>();
        
        // Act
        Test.startTest();
        for (String source : leadSources) {
            Lead testLead = new Lead(
                FirstName = 'Source',
                LastName = 'Test',
                Company = source + ' Company',
                Email = source.deleteWhitespace().toLowerCase() + '@test.com',
                Status = 'Open - Not Contacted',
                LeadSource = source
            );
            insert testLead;
            
            Id oppId = ACME_OpportunityProvider.createOpportunityFromLead(testLead, testAccount.Id, testContact.Id);
            oppIds.add(oppId);
        }
        Test.stopTest();
        
        // Assert
        List<Opportunity> createdOpps = [SELECT Id, LeadSource FROM Opportunity WHERE Id IN :oppIds ORDER BY LeadSource];
        
        for (Integer i = 0; i < createdOpps.size(); i++) {
            System.assertNotEquals(null, createdOpps[i].LeadSource, 'LeadSource should be populated');
        }
    }
}