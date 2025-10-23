/**
 * @description Provider class for Lead-related operations with CRUD validation
 * @author ACME Development Team
 * @date 2024
 */
public with sharing class ACME_LeadProvider {
    
    /**
     * @description Retrieves all leads from the database with CRUD validation
     * @return List<Lead> List of all leads the user has access to
     * @throws AuraHandledException when user lacks read access to Lead object
     */
    public static List<Lead> getAllLeads() {
        try {
            // CRUD validation before SOQL operation
            if (!Schema.sObjectType.Lead.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to read Lead records');
            }
            
            return [SELECT Id, Name, FirstName, LastName, Company, Email, Phone, Status, Rating, 
                          AnnualRevenue, LeadSource, Industry, CreatedDate 
                   FROM Lead 
                   ORDER BY CreatedDate DESC];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving leads: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves leads by their IDs with CRUD validation
     * @param leadIds Set of Lead IDs to retrieve
     * @return List<Lead> List of leads matching the provided IDs
     * @throws AuraHandledException when user lacks read access or invalid parameters
     */
    public static List<Lead> getLeadsByIds(Set<Id> leadIds) {
        try {
            if (leadIds == null || leadIds.isEmpty()) {
                throw new AuraHandledException('Lead IDs cannot be null or empty');
            }
            
            // CRUD validation before SOQL operation
            if (!Schema.sObjectType.Lead.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to read Lead records');
            }
            
            return [SELECT Id, Name, FirstName, LastName, Company, Email, Phone, Status, Rating,
                          AnnualRevenue, LeadSource, Industry, Address, CreatedDate
                   FROM Lead 
                   WHERE Id IN :leadIds
                   ORDER BY Name];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving leads by IDs: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves hot leads based on rating and status
     * @return List<Lead> List of hot leads
     * @throws AuraHandledException when user lacks read access
     */
    public static List<Lead> getHotLeads() {
        try {
            // CRUD validation before SOQL operation
            if (!Schema.sObjectType.Lead.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to read Lead records');
            }
            
            return [SELECT Id, Name, FirstName, LastName, Company, Email, Phone, Status, Rating,
                          AnnualRevenue, LeadSource, CreatedDate
                   FROM Lead 
                   WHERE Rating = 'Hot' OR Status = 'Qualified'
                   ORDER BY CreatedDate DESC];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving hot leads: ' + e.getMessage());
        }
    }
    
    /**
     * @description Creates new lead records with CRUD validation
     * @param leads List of Lead records to create
     * @return List<Lead> List of created leads with IDs
     * @throws AuraHandledException when user lacks create access or DML fails
     */
    public static List<Lead> createLeads(List<Lead> leads) {
        try {
            if (leads == null || leads.isEmpty()) {
                throw new AuraHandledException('Leads list cannot be null or empty');
            }
            
            // CRUD validation before DML operation
            if (!Schema.sObjectType.Lead.isCreateable()) {
                throw new AuraHandledException('Insufficient permissions to create Lead records');
            }
            
            insert leads;
            return leads;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating leads: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error creating leads: ' + e.getMessage());
        }
    }
    
    /**
     * @description Updates existing lead records with CRUD validation
     * @param leads List of Lead records to update
     * @return List<Lead> List of updated leads
     * @throws AuraHandledException when user lacks update access or DML fails
     */
    public static List<Lead> updateLeads(List<Lead> leads) {
        try {
            if (leads == null || leads.isEmpty()) {
                throw new AuraHandledException('Leads list cannot be null or empty');
            }
            
            // CRUD validation before DML operation
            if (!Schema.sObjectType.Lead.isUpdateable()) {
                throw new AuraHandledException('Insufficient permissions to update Lead records');
            }
            
            update leads;
            return leads;
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating leads: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error updating leads: ' + e.getMessage());
        }
    }
    
    /**
     * @description Converts leads to opportunities with CRUD validation
     * @param leadIds Set of Lead IDs to convert
     * @return List<Database.LeadConvertResult> Results of the conversion process
     * @throws AuraHandledException when user lacks convert access or conversion fails
     */
    public static List<Database.LeadConvertResult> convertLeads(Set<Id> leadIds) {
        try {
            if (leadIds == null || leadIds.isEmpty()) {
                throw new AuraHandledException('Lead IDs cannot be null or empty');
            }
            
            // CRUD validation - check if user can update leads and create accounts/contacts/opportunities
            if (!Schema.sObjectType.Lead.isUpdateable() || 
                !Schema.sObjectType.Account.isCreateable() ||
                !Schema.sObjectType.Contact.isCreateable() ||
                !Schema.sObjectType.Opportunity.isCreateable()) {
                throw new AuraHandledException('Insufficient permissions to convert Lead records');
            }
            
            List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
            
            for (Id leadId : leadIds) {
                Database.LeadConvert leadConvert = new Database.LeadConvert();
                leadConvert.setLeadId(leadId);
                leadConvert.setConvertedStatus(getConvertedStatus());
                leadConverts.add(leadConvert);
            }
            
            List<Database.LeadConvertResult> results = Database.convertLead(leadConverts);
            return results;
        } catch (Exception e) {
            throw new AuraHandledException('Error converting leads: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets the appropriate converted status for lead conversion
     * @return String The converted status value
     */
    private static String getConvertedStatus() {
        LeadStatus convertStatus = [SELECT MasterLabel 
                                   FROM LeadStatus 
                                   WHERE IsConverted = true 
                                   LIMIT 1];
        return convertStatus.MasterLabel;
    }
    
    /**
     * @description Deletes lead records with CRUD validation
     * @param leadIds Set of Lead IDs to delete
     * @throws AuraHandledException when user lacks delete access or DML fails
     */
    public static void deleteLeads(Set<Id> leadIds) {
        try {
            if (leadIds == null || leadIds.isEmpty()) {
                throw new AuraHandledException('Lead IDs cannot be null or empty');
            }
            
            // CRUD validation before DML operation
            if (!Schema.sObjectType.Lead.isDeletable()) {
                throw new AuraHandledException('Insufficient permissions to delete Lead records');
            }
            
            List<Lead> leadsToDelete = [SELECT Id FROM Lead WHERE Id IN :leadIds];
            delete leadsToDelete;
        } catch (DmlException e) {
            throw new AuraHandledException('Error deleting leads: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error deleting leads: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves leads by company name with CRUD validation
     * @param companyName Name of the company to search for
     * @return List<Lead> List of leads from the specified company
     * @throws AuraHandledException when user lacks read access or invalid parameters
     */
    public static List<Lead> getLeadsByCompany(String companyName) {
        try {
            if (String.isBlank(companyName)) {
                throw new AuraHandledException('Company name cannot be null or empty');
            }
            
            // CRUD validation before SOQL operation
            if (!Schema.sObjectType.Lead.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to read Lead records');
            }
            
            String searchPattern = '%' + String.escapeSingleQuotes(companyName) + '%';
            
            return [SELECT Id, Name, FirstName, LastName, Company, Email, Phone, Status, Rating,
                          AnnualRevenue, LeadSource, CreatedDate
                   FROM Lead 
                   WHERE Company LIKE :searchPattern
                   ORDER BY CreatedDate DESC
                   LIMIT 100];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving leads by company: ' + e.getMessage());
        }
    }
}
