/**
 * @description Service class for integrating Vendor records with Bill.com API
 * Handles vendor synchronization, API communication, and error logging
 * @author Copado Demo
 * @date 2025-12-05
 */
public with sharing class BillComVendorIntegrationService {
    
    private static final String BILLCOM_ENDPOINT = 'callout:BillCom_API/vendors';
    private static final Integer TIMEOUT_MS = 120000;
    
    /**
     * @description Synchronizes a Vendor record with Bill.com
     * @param vendorId The ID of the Vendor record to sync
     * @return Boolean indicating success or failure
     */
    public static Boolean syncVendor(Id vendorId) {
        // Defensive coding: validate input
        if (vendorId == null) {
            System.debug('ERROR: Vendor ID cannot be null');
            return false;
        }
        
        try {
            // Query vendor record
            Vendor__c vendor = queryVendor(vendorId);
            
            // Build and send HTTP request
            HttpRequest req = buildHttpRequest(vendor);
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Handle response
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                updateVendorSyncStatus(vendorId, 'Synced', null);
                System.debug('SUCCESS: Vendor synced successfully: ' + vendorId);
                return true;
            } else {
                handleErrorResponse(vendorId, res);
                return false;
            }
            
        } catch (Exception ex) {
            // Exception handling per ACME standards
            String errorMsg = 'Exception during vendor sync: ' + ex.getMessage();
            System.debug('ERROR: ' + errorMsg);
            updateVendorSyncStatus(vendorId, 'Error', errorMsg);
            return false;
        }
    }
    
    /**
     * @description Queries Vendor record with required fields
     * @param vendorId The ID of the Vendor to query
     * @return Vendor__c record
     */
    @TestVisible
    private static Vendor__c queryVendor(Id vendorId) {
        List<Vendor__c> vendors = [
            SELECT Id, Name, Email__c, Payment_Terms__c, Tax_ID__c, 
                   Status__c, BillCom_ID__c
            FROM Vendor__c
            WHERE Id = :vendorId
            LIMIT 1
        ];
        
        if (vendors.isEmpty()) {
            throw new VendorNotFoundException('Vendor not found: ' + vendorId);
        }
        
        return vendors[0];
    }
    
    /**
     * @description Builds HTTP request for Bill.com API
     * @param vendor The Vendor record to sync
     * @return Configured HttpRequest
     */
    @TestVisible
    private static HttpRequest buildHttpRequest(Vendor__c vendor) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BILLCOM_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(TIMEOUT_MS);
        req.setBody(buildVendorPayload(vendor));
        return req;
    }
    
    /**
     * @description Builds JSON payload for vendor sync
     * @param vendor The Vendor record
     * @return JSON string payload
     */
    @TestVisible
    private static String buildVendorPayload(Vendor__c vendor) {
        Map<String, Object> payload = new Map<String, Object>{
            'name' => vendor.Name,
            'email' => vendor.Email__c,
            'paymentTerms' => vendor.Payment_Terms__c,
            'taxId' => vendor.Tax_ID__c,
            'status' => vendor.Status__c,
            'salesforceId' => vendor.Id
        };
        return JSON.serialize(payload);
    }
    
    /**
     * @description Updates vendor sync status
     * @param vendorId The Vendor ID to update
     * @param status The sync status value
     * @param errorMessage Optional error message
     */
    @TestVisible
    private static void updateVendorSyncStatus(Id vendorId, String status, String errorMessage) {
        try {
            Vendor__c vendor = new Vendor__c(
                Id = vendorId,
                Sync_Status__c = status,
                Last_Sync_Date__c = System.now()
            );
            update vendor;
        } catch (DmlException ex) {
            System.debug('ERROR: Failed to update vendor status: ' + ex.getMessage());
        }
    }
    
    /**
     * @description Handles error responses from Bill.com API
     * @param vendorId The Vendor ID
     * @param res The HTTP response
     */
    @TestVisible
    private static void handleErrorResponse(Id vendorId, HttpResponse res) {
        String errorMsg = 'API Error: ' + res.getStatusCode() + ' - ' + res.getStatus();
        System.debug('ERROR: ' + errorMsg);
        updateVendorSyncStatus(vendorId, 'Error', errorMsg);
    }
    
    /**
     * @description Custom exception for vendor not found scenarios
     */
    public class VendorNotFoundException extends Exception {}
}