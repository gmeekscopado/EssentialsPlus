/**
 * @description Test class for ACME_LeadProvider
 * @author ACME Corporation
 * @date 2024
 */
@IsTest
private class ACME_LeadProviderTest {
    
    @TestSetup
    static void setupTestData() {
        List<Lead> testLeads = new List<Lead>();
        
        // Create hot leads
        for (Integer i = 0; i < 3; i++) {
            testLeads.add(new Lead(
                FirstName = 'Hot',
                LastName = 'Lead ' + i,
                Company = 'Hot Company ' + i,
                Email = 'hot.lead' + i + '@test.com',
                Phone = '555-123-000' + i,
                Rating = 'Hot',
                Status = 'Open - Not Contacted'
            ));
        }
        
        // Create qualified leads
        for (Integer i = 0; i < 2; i++) {
            testLeads.add(new Lead(
                FirstName = 'Qualified',
                LastName = 'Lead ' + i,
                Company = 'Qualified Company ' + i,
                Email = 'qualified.lead' + i + '@test.com',
                Phone = '555-456-000' + i,
                Rating = 'Warm',
                Status = 'Qualified',
                AnnualRevenue = 100000 + (i * 50000)
            ));
        }
        
        // Create converted lead
        testLeads.add(new Lead(
            FirstName = 'Converted',
            LastName = 'Lead',
            Company = 'Converted Company',
            Email = 'converted.lead@test.com',
            Phone = '555-789-0000',
            Rating = 'Hot',
            Status = 'Converted'
        ));
        
        insert testLeads;
    }
    
    @IsTest
    static void testGetHotLeads() {
        Test.startTest();
        List<Lead> hotLeads = ACME_LeadProvider.getHotLeads();
        Test.stopTest();
        
        System.assertNotEquals(null, hotLeads, 'Hot leads list should not be null');
        System.assert(hotLeads.size() > 0, 'Should return hot leads');
        
        for (Lead lead : hotLeads) {
            System.assertEquals('Hot', lead.Rating, 'All leads should have Hot rating');
            System.assertNotEquals('Converted', lead.Status, 'Should not include converted leads');
        }
    }
    
    @IsTest
    static void testGetLeadsForConversion() {
        Test.startTest();
        List<Lead> qualifiedLeads = ACME_LeadProvider.getLeadsForConversion();
        Test.stopTest();
        
        System.assertNotEquals(null, qualifiedLeads, 'Qualified leads list should not be null');
        
        for (Lead lead : qualifiedLeads) {
            System.assertEquals('Qualified', lead.Status, 'All leads should be qualified');
            System.assert(lead.Rating == 'Hot' || lead.Rating == 'Warm', 'Should be hot or warm leads');
        }
    }
    
    @IsTest
    static void testUpdateLeadStatus() {
        Lead testLead = [SELECT Id, Status, Rating FROM Lead WHERE Status = 'Open - Not Contacted' LIMIT 1];
        String newStatus = 'Working - Contacted';
        String newRating = 'Warm';
        
        Test.startTest();
        ACME_LeadProvider.updateLeadStatus(testLead.Id, newStatus, newRating);
        Test.stopTest();
        
        Lead updatedLead = [SELECT Id, Status, Rating FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(newStatus, updatedLead.Status, 'Status should be updated correctly');
        System.assertEquals(newRating, updatedLead.Rating, 'Rating should be updated correctly');
    }
    
    @IsTest
    static void testUpdateLeadStatusException() {
        Test.startTest();
        try {
            ACME_LeadProvider.updateLeadStatus(null, 'Working - Contacted', 'Warm');
            System.assert(false, 'Should have thrown an exception');
        } catch (ACME_LeadProvider.AcmeDataException e) {
            System.assert(true, 'Expected AcmeDataException was thrown');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBulkLeadOperations() {
        List<Lead> leads = [SELECT Id FROM Lead WHERE Status != 'Converted' LIMIT 5];
        
        Test.startTest();
        for (Lead lead : leads) {
            ACME_LeadProvider.updateLeadStatus(lead.Id, 'Working - Contacted', 'Warm');
        }
        Test.stopTest();
        
        List<Lead> updatedLeads = [SELECT Id, Status, Rating FROM Lead WHERE Id IN :leads];
        for (Lead lead : updatedLeads) {
            System.assertEquals('Working - Contacted', lead.Status, 'Bulk update should work');
            System.assertEquals('Warm', lead.Rating, 'Bulk rating update should work');
        }
    }
}