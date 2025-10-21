/**
 * @description Test class for ACME_LeadNotificationLogic
 * @author ACME Corporation
 * @date 2024
 */
@IsTest
private class ACME_LeadNotificationLogicTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test users
        Profile salesProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testOwner = new User(
            FirstName = 'Test',
            LastName = 'Owner',
            Email = 'test.owner@acme.com',
            Username = 'test.owner@acme.test.com',
            Alias = 'town',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = salesProfile.Id
        );
        insert testOwner;
        
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Industry = 'Technology'
        );
        insert testAccount;
        
        // Create test leads
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 3; i++) {
            testLeads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead ' + i,
                Company = 'Test Company ' + i,
                Email = 'test.lead' + i + '@test.com',
                Phone = '555-123-000' + i,
                Rating = 'Hot',
                Status = 'Open - Not Contacted',
                OwnerId = testOwner.Id
            ));
        }
        insert testLeads;
        
        // Create test opportunities
        List<Opportunity> testOpps = new List<Opportunity>();
        for (Integer i = 0; i < 2; i++) {
            testOpps.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                AccountId = testAccount.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Amount = 50000 + (i * 10000),
                OwnerId = testOwner.Id
            ));
        }
        insert testOpps;
    }
    
    @IsTest
    static void testSendHotLeadNotifications() {
        List<Lead> hotLeads = [SELECT Id, Name, Company, Rating, Owner.Name, Owner.Email FROM Lead WHERE Rating = 'Hot'];
        
        Test.startTest();
        Integer emailInvocations = Limits.getEmailInvocations();
        ACME_LeadNotificationLogic.sendHotLeadNotifications(hotLeads);
        Test.stopTest();
        
        System.assert(Limits.getEmailInvocations() > emailInvocations, 'Emails should have been sent');
    }
    
    @IsTest
    static void testSendOpportunityNotifications() {
        List<Opportunity> opportunities = [SELECT Id, Name, Amount, LeadSource, OwnerId FROM Opportunity];
        
        Test.startTest();
        Integer emailInvocations = Limits.getEmailInvocations();
        ACME_LeadNotificationLogic.sendOpportunityNotifications(opportunities);
        Test.stopTest();
        
        System.assert(Limits.getEmailInvocations() > emailInvocations, 'Emails should have been sent');
    }
    
    @IsTest
    static void testSendHotLeadNotificationsEmpty() {
        List<Lead> emptyLeads = new List<Lead>();
        
        Test.startTest();
        try {
            ACME_LeadNotificationLogic.sendHotLeadNotifications(emptyLeads);
            System.assert(true, 'Should handle empty list gracefully');
        } catch (Exception e) {
            System.assert(false, 'Should not throw exception for empty list');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSendOpportunityNotificationsEmpty() {
        List<Opportunity> emptyOpps = new List<Opportunity>();
        
        Test.startTest();
        try {
            ACME_LeadNotificationLogic.sendOpportunityNotifications(emptyOpps);
            System.assert(true, 'Should handle empty list gracefully');
        } catch (Exception e) {
            System.assert(false, 'Should not throw exception for empty list');
        }
        Test.stopTest();
    }
}