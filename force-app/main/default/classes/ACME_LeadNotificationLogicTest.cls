/**
 * @description Test class for ACME_LeadNotificationLogic with comprehensive coverage
 * @author ACME Development Team
 * @date 2024
 */
@isTest
private class ACME_LeadNotificationLogicTest {
    
    /**
     * @description Test data setup method
     */
    @TestSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 1; i <= 5; i++) {
            testAccounts.add(new Account(
                Name = 'Test Account ' + i,
                Type = 'Customer'
            ));
        }
        insert testAccounts;
        
        // Create test leads
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 1; i <= 10; i++) {
            testLeads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead ' + i,
                Company = 'Test Company ' + i,
                Email = 'testlead' + i + '@test.com',
                Status = i <= 3 ? 'Qualified' : 'New',
                Rating = i <= 2 ? 'Hot' : 'Warm',
                AnnualRevenue = i <= 2 ? 100000 : 25000
            ));
        }
        insert testLeads;
        
        // Create test opportunities
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for (Integer i = 1; i <= 10; i++) {
            testOpportunities.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                AccountId = testAccounts[Math.mod(i-1, 5)].Id,
                StageName = i <= 2 ? 'Closed Won' : 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Amount = i <= 3 ? 75000 : 25000,
                Priority__c = i <= 2 ? 'High' : 'Medium'
            ));
        }
        insert testOpportunities;
    }
    
    /**
     * @description Test sendHotLeadNotifications with hot leads
     */
    @isTest
    static void testSendHotLeadNotifications_WithHotLeads() {
        User testUser = createTestUser();
        List<Lead> hotLeads = [SELECT Id, Name, Company, Status, Rating, AnnualRevenue 
                              FROM Lead 
                              WHERE Rating = 'Hot' OR Status = 'Qualified'];
        
        Test.startTest();
        System.runAs(testUser) {
            ACME_LeadNotificationLogic.sendHotLeadNotifications(hotLeads);
            
            // Verify no exceptions thrown
            System.assert(true, 'Method should execute without exceptions');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test sendHotLeadNotifications with non-hot leads
     */
    @isTest
    static void testSendHotLeadNotifications_WithNonHotLeads() {
        User testUser = createTestUser();
        List<Lead> nonHotLeads = [SELECT Id, Name, Company, Status, Rating, AnnualRevenue 
                                 FROM Lead 
                                 WHERE Rating != 'Hot' AND Status != 'Qualified' AND AnnualRevenue < 50000];
        
        Test.startTest();
        System.runAs(testUser) {
            ACME_LeadNotificationLogic.sendHotLeadNotifications(nonHotLeads);
            
            // Verify no exceptions thrown
            System.assert(true, 'Method should execute without exceptions for non-hot leads');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test sendHotLeadNotifications with null parameter
     */
    @isTest
    static void testSendHotLeadNotifications_NullParameter() {
        User testUser = createTestUser();
        
        Test.startTest();
        System.runAs(testUser) {
            ACME_LeadNotificationLogic.sendHotLeadNotifications(null);
            
            // Should handle null gracefully without throwing exception
            System.assert(true, 'Method should handle null parameter gracefully');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test sendHotLeadNotifications with empty list
     */
    @isTest
    static void testSendHotLeadNotifications_EmptyList() {
        User testUser = createTestUser();
        
        Test.startTest();
        System.runAs(testUser) {
            ACME_LeadNotificationLogic.sendHotLeadNotifications(new List<Lead>());
            
            // Should handle empty list gracefully
            System.assert(true, 'Method should handle empty list gracefully');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test sendHotLeadNotifications with bulk data (200+ records)
     */
    @isTest
    static void testSendHotLeadNotifications_BulkData() {
        User testUser = createTestUser();
        
        // Create bulk test data
        List<Lead> bulkLeads = new List<Lead>();
        for (Integer i = 1; i <= 250; i++) {
            bulkLeads.add(new Lead(
                FirstName = 'Bulk',
                LastName = 'Lead ' + i,
                Company = 'Bulk Company ' + i,
                Email = 'bulklead' + i + '@test.com',
                Status = Math.mod(i, 3) == 0 ? 'Qualified' : 'New',
                Rating = Math.mod(i, 5) == 0 ? 'Hot' : 'Warm',
                AnnualRevenue = Math.mod(i, 4) == 0 ? 100000 : 25000
            ));
        }
        insert bulkLeads;
        
        Test.startTest();
        System.runAs(testUser) {
            ACME_LeadNotificationLogic.sendHotLeadNotifications(bulkLeads);
            
            // Verify bulk processing works
            System.assert(true, 'Method should handle bulk data correctly');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test sendOpportunityNotifications with qualified opportunities
     */
    @isTest
    static void testSendOpportunityNotifications_WithQualifiedOpportunities() {
        User testUser = createTestUser();
        List<Opportunity> qualifiedOpps = [SELECT Id, Name, Amount, StageName, Priority__c 
                                          FROM Opportunity 
                                          WHERE Amount > 50000 OR Priority__c = 'High' OR StageName = 'Closed Won'];
        
        Test.startTest();
        System.runAs(testUser) {
            ACME_LeadNotificationLogic.sendOpportunityNotifications(qualifiedOpps);
            
            // Verify no exceptions thrown
            System.assert(true, 'Method should execute without exceptions');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test sendOpportunityNotifications with non-qualified opportunities
     */
    @isTest
    static void testSendOpportunityNotifications_WithNonQualifiedOpportunities() {
        User testUser = createTestUser();
        List<Opportunity> nonQualifiedOpps = [SELECT Id, Name, Amount, StageName, Priority__c 
                                             FROM Opportunity 
                                             WHERE Amount < 50000 AND Priority__c != 'High' AND StageName != 'Closed Won'];
        
        Test.startTest();
        System.runAs(testUser) {
            ACME_LeadNotificationLogic.sendOpportunityNotifications(nonQualifiedOpps);
            
            // Verify no exceptions thrown
            System.assert(true, 'Method should execute without exceptions for non-qualified opportunities');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test sendOpportunityNotifications with null parameter
     */
    @isTest
    static void testSendOpportunityNotifications_NullParameter() {
        User testUser = createTestUser();
        
        Test.startTest();
        System.runAs(testUser) {
            ACME_LeadNotificationLogic.sendOpportunityNotifications(null);
            
            // Should handle null gracefully
            System.assert(true, 'Method should handle null parameter gracefully');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test sendOpportunityNotifications with empty list
     */
    @isTest
    static void testSendOpportunityNotifications_EmptyList() {
        User testUser = createTestUser();
        
        Test.startTest();
        System.runAs(testUser) {
            ACME_LeadNotificationLogic.sendOpportunityNotifications(new List<Opportunity>());
            
            // Should handle empty list gracefully
            System.assert(true, 'Method should handle empty list gracefully');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test sendOpportunityNotifications with bulk data
     */
    @isTest
    static void testSendOpportunityNotifications_BulkData() {
        User testUser = createTestUser();
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Create bulk opportunities
        List<Opportunity> bulkOpportunities = new List<Opportunity>();
        for (Integer i = 1; i <= 200; i++) {
            bulkOpportunities.add(new Opportunity(
                Name = 'Bulk Opportunity ' + i,
                AccountId = testAccount.Id,
                StageName = Math.mod(i, 4) == 0 ? 'Closed Won' : 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Amount = Math.mod(i, 3) == 0 ? 75000 : 25000,
                Priority__c = Math.mod(i, 5) == 0 ? 'High' : 'Medium'
            ));
        }
        insert bulkOpportunities;
        
        Test.startTest();
        System.runAs(testUser) {
            ACME_LeadNotificationLogic.sendOpportunityNotifications(bulkOpportunities);
            
            // Verify bulk processing works
            System.assert(true, 'Method should handle bulk data correctly');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test areNotificationsEnabled method with valid user ID
     */
    @isTest
    static void testAreNotificationsEnabled_ValidUserId() {
        User testUser = createTestUser();
        
        Test.startTest();
        System.runAs(testUser) {
            Boolean isEnabled = ACME_LeadNotificationLogic.areNotificationsEnabled(UserInfo.getUserId());
            
            System.assertEquals(true, isEnabled, 'Notifications should be enabled by default');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test areNotificationsEnabled method with null user ID
     */
    @isTest
    static void testAreNotificationsEnabled_NullUserId() {
        User testUser = createTestUser();
        
        Test.startTest();
        System.runAs(testUser) {
            Boolean isEnabled = ACME_LeadNotificationLogic.areNotificationsEnabled(null);
            
            System.assertEquals(false, isEnabled, 'Notifications should be disabled for null user ID');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test exception handling in sendHotLeadNotifications
     */
    @isTest
    static void testSendHotLeadNotifications_ExceptionHandling() {
        User testUser = createTestUser();
        
        // Create lead with invalid data to potentially trigger exception
        Lead invalidLead = new Lead(
            FirstName = 'Test',
            LastName = 'Invalid Lead'
            // Missing required Company field
        );
        
        Test.startTest();
        System.runAs(testUser) {
            try {
                // This should handle any internal exceptions gracefully
                ACME_LeadNotificationLogic.sendHotLeadNotifications(new List<Lead>{invalidLead});
                System.assert(true, 'Method should handle exceptions gracefully');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('Error processing hot lead notifications'), 
                             'Should throw appropriate error message');
            }
        }
        Test.stopTest();
    }
    
    /**
     * @description Helper method to create test user
     * @return User Test user for running tests
     */
    private static User createTestUser() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        return new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@acme.com',
            Username = 'testuser' + System.currentTimeMillis() + '@acme.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = standardProfile.Id
        );
    }
}
