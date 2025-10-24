/**
 * @description Provider class for Lead data access operations
 * @author ACME Corporation
 * @date 2024
 */
public with sharing class ACME_LeadProvider {
    
    /**
     * @description Gets hot leads based on score and rating
     * @return List of hot leads
     */
    public static List<Lead> getHotLeads() {
        try {
            // Query with CRUD/FLS check
            List<Lead> leads = [
                SELECT Id, Name, Company, Email, Phone, Status, Rating, LeadSource,
                       Owner.Name, Owner.Email
                FROM Lead 
                WHERE Rating = 'Hot'
                AND Status != 'Converted'
                ORDER BY CreatedDate DESC
                LIMIT 100
            ];
            
            // Strip inaccessible fields
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.READABLE,
                leads
            );
            
            return securityDecision.getRecords();
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving hot leads: ' + e.getMessage());
            throw new AcmeDataException('Failed to retrieve hot leads: ' + e.getMessage());
        }
    }
    
    /**
     * @description Converts lead to account, contact, and opportunity
     * @param leadId Lead ID to convert
     * @param accountId Optional existing account ID
     * @param contactId Optional existing contact ID
     * @return Opportunity ID from conversion
     */
    public static Id convertLead(Id leadId, Id accountId, Id contactId) {
        try {
            // Check if user can update leads (required for conversion)
            if (!Schema.sObjectType.Lead.isUpdateable()) {
                throw new AcmeDataException('Insufficient permissions to convert Lead');
            }
            
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            
            if (accountId != null) {
                lc.setAccountId(accountId);
            }
            
            if (contactId != null) {
                lc.setContactId(contactId);
            }
            
            lc.setDoNotCreateOpportunity(false);
            lc.setConvertedStatus('Qualified');
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            
            if (!lcr.isSuccess()) {
                String errorMsg = 'Lead conversion failed: ';
                for (Database.Error err : lcr.getErrors()) {
                    errorMsg += err.getMessage() + '; ';
                }
                throw new AcmeDataException(errorMsg);
            }
            
            return lcr.getOpportunityId();
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error converting lead: ' + e.getMessage());
            throw new AcmeDataException('Failed to convert lead: ' + e.getMessage());
        }
    }
    
    /**
     * @description Updates lead status
     * @param leadId Lead ID to update
     * @param newStatus New status value
     */
    public static void updateLeadStatus(Id leadId, String newStatus) {
        try {
            // Check update permission
            if (!Schema.sObjectType.Lead.isUpdateable()) {
                throw new AcmeDataException('Insufficient permissions to update Lead');
            }
            
            Lead leadToUpdate = new Lead(
                Id = leadId,
                Status = newStatus
            );
            
            // Strip inaccessible fields before update
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.UPDATABLE,
                new List<Lead>{ leadToUpdate }
            );
            
            update securityDecision.getRecords();
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error updating lead status: ' + e.getMessage());
            throw new AcmeDataException('Failed to update lead status: ' + e.getMessage());
        }
    }
    
    /**
     * @description Custom exception for data access errors
     */
    public class AcmeDataException extends Exception {}
}