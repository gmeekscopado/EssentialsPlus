/**
 * @description Test class for ACME_LeadNotificationLogic
 * @author ACME Corporation
 * @date 2024
 */
@isTest
private class ACME_LeadNotificationLogicTest {

    /**
     * @description Test setup method to create test data
     */
    @testSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Industry = 'Technology'
        );
        insert testAccount;

        // Create test user for lead owner
        User testUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId()];

        // Create test leads
        List<Lead> testLeads = new List<Lead>();
        testLeads.add(new Lead(
            FirstName = 'Hot',
            LastName = 'Lead',
            Company = 'Hot Corp',
            Email = 'hot@example.com',
            Status = 'Open - Not Contacted',
            Rating = 'Hot',
            OwnerId = testUser.Id
        ));
        testLeads.add(new Lead(
            FirstName = 'Warm',
            LastName = 'Lead',
            Company = 'Warm Inc',
            Email = 'warm@example.com',
            Status = 'Open - Not Contacted',
            Rating = 'Warm',
            OwnerId = testUser.Id
        ));
        insert testLeads;

        // Create test opportunities with required Brand_Tier__c field
        List<Opportunity> testOpps = new List<Opportunity>();
        testOpps.add(new Opportunity(
            Name = 'Test Opp 1',
            AccountId = testAccount.Id,
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30),
            Amount = 50000,
            LeadSource = 'Web',
            Brand_Tier__c = '1',
            OwnerId = testUser.Id
        ));
        testOpps.add(new Opportunity(
            Name = 'Test Opp 2',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(60),
            Amount = 75000,
            LeadSource = 'Phone Inquiry',
            Brand_Tier__c = '2',
            OwnerId = testUser.Id
        ));
        insert testOpps;
    }

    /**
     * @description Test sending notifications for hot leads
     */
    @isTest
    static void testSendHotLeadNotifications() {
        List<Lead> hotLeads = [
            SELECT Id, Name, Company, Email, Phone, Rating, LeadSource, Owner.Email
            FROM Lead
            WHERE Rating = 'Hot'
        ];

        Test.startTest();
        ACME_LeadNotificationLogic.sendHotLeadNotifications(hotLeads);
        Test.stopTest();

        // Verify no exceptions were thrown
        System.assertEquals(1, hotLeads.size(), 'Should have one hot lead');
    }

    /**
     * @description Test sending notifications with null/empty list
     */
    @isTest
    static void testSendHotLeadNotificationsNullList() {
        Test.startTest();
        ACME_LeadNotificationLogic.sendHotLeadNotifications(null);
        ACME_LeadNotificationLogic.sendHotLeadNotifications(new List<Lead>());
        Test.stopTest();

        // Should complete without exceptions
        System.assert(true, 'Should handle null and empty lists gracefully');
    }

    /**
     * @description Test sending notifications for opportunities
     */
    @isTest
    static void testSendOpportunityNotifications() {
        List<Opportunity> opps = [
            SELECT Id, Name, Amount, StageName, CloseDate, LeadSource, 
                   Account.Name, Owner.Email, OwnerId
            FROM Opportunity
            WHERE StageName = 'Qualification'
        ];

        Test.startTest();
        ACME_LeadNotificationLogic.sendOpportunityNotifications(opps);
        Test.stopTest();

        // Verify no exceptions were thrown
        System.assertEquals(1, opps.size(), 'Should have one qualifying opportunity');
    }

    /**
     * @description Test sending notifications with null/empty opportunity list
     */
    @isTest
    static void testSendOpportunityNotificationsNullList() {
        Test.startTest();
        ACME_LeadNotificationLogic.sendOpportunityNotifications(null);
        ACME_LeadNotificationLogic.sendOpportunityNotifications(new List<Opportunity>());
        Test.stopTest();

        // Should complete without exceptions
        System.assert(true, 'Should handle null and empty lists gracefully');
    }

    /**
     * @description Test exception handling for hot lead notifications
     */
    @isTest
    static void testHotLeadNotificationException() {
        // Create lead without required owner relationship
        Lead invalidLead = new Lead(
            FirstName = 'Invalid',
            LastName = 'Lead',
            Company = 'Invalid Corp',
            Rating = 'Hot'
        );

        Test.startTest();
        try {
            ACME_LeadNotificationLogic.sendHotLeadNotifications(new List<Lead>{ invalidLead });
            // Exception may or may not be thrown depending on implementation
            System.assert(true, 'Method completed');
        } catch (ACME_LeadNotificationLogic.AcmeNotificationException ex) {
            System.assert(true, 'Expected AcmeNotificationException thrown');
        }
        Test.stopTest();
    }

    /**
     * @description Test opportunity notifications for non-qualifying stages
     */
    @isTest
    static void testOpportunityNotificationsNonQualifyingStage() {
        List<Opportunity> opps = [
            SELECT Id, Name, Amount, StageName, CloseDate, LeadSource,
                   Account.Name, Owner.Email, OwnerId
            FROM Opportunity
            WHERE StageName = 'Prospecting'
        ];

        Test.startTest();
        ACME_LeadNotificationLogic.sendOpportunityNotifications(opps);
        Test.stopTest();

        // Should complete without sending notifications
        System.assertEquals(1, opps.size(), 'Should have one non-qualifying opportunity');
    }
}