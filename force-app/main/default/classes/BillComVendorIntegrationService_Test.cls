/**
 * @description Test class for BillComVendorIntegrationService
 * Provides comprehensive test coverage for vendor synchronization
 * @author Copado Demo
 * @date 2025-12-05
 */
@isTest
private class BillComVendorIntegrationService_Test {
    
    /**
     * @description Setup test data
     */
    @TestSetup
    static void setupTestData() {
        Vendor__c vendor = new Vendor__c(
            Name = 'Test Vendor Corp',
            Email__c = 'vendor@test.com',
            Payment_Terms__c = 'Net 30',
            Tax_ID__c = '12-3456789',
            Status__c = 'Active',
            Sync_Status__c = 'Pending'
        );
        insert vendor;
    }
    
    /**
     * @description Test successful vendor synchronization
     */
    @isTest
    static void testSyncVendor_Success() {
        // Setup
        Vendor__c vendor = [SELECT Id FROM Vendor__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new BillComVendorHttpMock());
        
        // Execute
        Test.startTest();
        Boolean result = BillComVendorIntegrationService.syncVendor(vendor.Id);
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result, 'Sync should succeed');
        
        Vendor__c updatedVendor = [SELECT Sync_Status__c, Last_Sync_Date__c 
                                    FROM Vendor__c WHERE Id = :vendor.Id];
        System.assertEquals('Synced', updatedVendor.Sync_Status__c, 
                           'Status should be Synced');
        System.assertNotEquals(null, updatedVendor.Last_Sync_Date__c, 
                              'Last sync date should be set');
    }
    
    /**
     * @description Test sync with null vendor ID
     */
    @isTest
    static void testSyncVendor_NullId() {
        // Execute
        Test.startTest();
        Boolean result = BillComVendorIntegrationService.syncVendor(null);
        Test.stopTest();
        
        // Verify
        System.assertEquals(false, result, 'Sync should fail with null ID');
    }
    
    /**
     * @description Test sync with API error response
     */
    @isTest
    static void testSyncVendor_ApiError() {
        // Setup
        Vendor__c vendor = [SELECT Id FROM Vendor__c LIMIT 1];
        BillComVendorHttpMock errorMock = new BillComVendorHttpMock(
            500, 'Internal Server Error', '{"error": "Server error"}'
        );
        Test.setMock(HttpCalloutMock.class, errorMock);
        
        // Execute
        Test.startTest();
        Boolean result = BillComVendorIntegrationService.syncVendor(vendor.Id);
        Test.stopTest();
        
        // Verify
        System.assertEquals(false, result, 'Sync should fail on API error');
        
        Vendor__c updatedVendor = [SELECT Sync_Status__c FROM Vendor__c 
                                    WHERE Id = :vendor.Id];
        System.assertEquals('Error', updatedVendor.Sync_Status__c, 
                           'Status should be Error');
    }
    
    /**
     * @description Test buildHttpRequest method
     */
    @isTest
    static void testBuildHttpRequest() {
        // Setup
        Vendor__c vendor = [SELECT Id, Name, Email__c, Payment_Terms__c, 
                            Tax_ID__c, Status__c, BillCom_ID__c 
                            FROM Vendor__c LIMIT 1];
        
        // Execute
        Test.startTest();
        HttpRequest req = BillComVendorIntegrationService.buildHttpRequest(vendor);
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, req, 'Request should not be null');
        System.assertEquals('POST', req.getMethod(), 'Method should be POST');
        System.assert(req.getEndpoint().contains('vendors'), 
                     'Endpoint should contain vendors');
    }
    
    /**
     * @description Test queryVendor with non-existent ID
     */
    @isTest
    static void testQueryVendor_NotFound() {
        // Setup - Create a fake ID that doesn't exist
        Id fakeId = Vendor__c.SObjectType.getDescribe().getKeyPrefix() + '0'.repeat(12);
        
        // Execute & Verify
        try {
            Test.startTest();
            BillComVendorIntegrationService.queryVendor(fakeId);
            Test.stopTest();
            System.assert(false, 'Should throw VendorNotFoundException');
        } catch (BillComVendorIntegrationService.VendorNotFoundException ex) {
            System.assert(true, 'Correct exception thrown');
        }
    }
    
    /**
     * @description Test queryVendor with valid ID
     */
    @isTest
    static void testQueryVendor_Found() {
        // Setup
        Vendor__c vendor = [SELECT Id FROM Vendor__c LIMIT 1];
        
        // Execute
        Test.startTest();
        Vendor__c result = BillComVendorIntegrationService.queryVendor(vendor.Id);
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, result, 'Vendor should be found');
        System.assertEquals(vendor.Id, result.Id, 'IDs should match');
    }
    
    /**
     * @description Test buildVendorPayload method
     */
    @isTest
    static void testBuildVendorPayload() {
        // Setup
        Vendor__c vendor = [SELECT Id, Name, Email__c, Payment_Terms__c, 
                            Tax_ID__c, Status__c FROM Vendor__c LIMIT 1];
        
        // Execute
        Test.startTest();
        String payload = BillComVendorIntegrationService.buildVendorPayload(vendor);
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, payload, 'Payload should not be null');
        System.assert(payload.contains('Test Vendor Corp'), 
                     'Payload should contain vendor name');
        System.assert(payload.contains('vendor@test.com'), 
                     'Payload should contain email');
    }
    
    /**
     * @description Test updateVendorSyncStatus method
     */
    @isTest
    static void testUpdateVendorSyncStatus() {
        // Setup
        Vendor__c vendor = [SELECT Id FROM Vendor__c LIMIT 1];
        
        // Execute
        Test.startTest();
        BillComVendorIntegrationService.updateVendorSyncStatus(
            vendor.Id, 'Synced', null
        );
        Test.stopTest();
        
        // Verify
        Vendor__c updated = [SELECT Sync_Status__c, Last_Sync_Date__c 
                             FROM Vendor__c WHERE Id = :vendor.Id];
        System.assertEquals('Synced', updated.Sync_Status__c, 
                           'Status should be updated');
        System.assertNotEquals(null, updated.Last_Sync_Date__c, 
                              'Sync date should be set');
    }
    
    /**
     * @description Test handleErrorResponse method
     */
    @isTest
    static void testHandleErrorResponse() {
        // Setup
        Vendor__c vendor = [SELECT Id FROM Vendor__c LIMIT 1];
        HttpResponse res = new HttpResponse();
        res.setStatusCode(404);
        res.setStatus('Not Found');
        
        // Execute
        Test.startTest();
        BillComVendorIntegrationService.handleErrorResponse(vendor.Id, res);
        Test.stopTest();
        
        // Verify
        Vendor__c updated = [SELECT Sync_Status__c FROM Vendor__c 
                             WHERE Id = :vendor.Id];
        System.assertEquals('Error', updated.Sync_Status__c, 
                           'Status should be Error after handling error response');
    }
    
    /**
     * @description Test HTTP mock respond method
     */
    @isTest
    static void testMockRespond() {
        // Setup
        BillComVendorHttpMock mock = new BillComVendorHttpMock();
        HttpRequest req = new HttpRequest();
        
        // Execute
        Test.startTest();
        HttpResponse res = mock.respond(req);
        Test.stopTest();
        
        // Verify
        System.assertEquals(200, res.getStatusCode(), 
                           'Mock should return 200');
        System.assert(res.getBody().contains('success'), 
                     'Body should contain success');
    }
}