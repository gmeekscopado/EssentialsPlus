/**
 * @description Provider class for Lead data access operations
 * @author ACME Corporation
 * @date 2024
 */
public with sharing class ACME_LeadProvider {
    
    /**
     * @description Retrieves hot leads that need immediate attention
     * @return List of hot leads
     */
    public static List<Lead> getHotLeads() {
        try {
            return [
                SELECT Id, Name, Company, Email, Phone, LeadSource, Rating, Status,
                       OwnerId, Owner.Name, Owner.Email, CreatedDate
                FROM Lead 
                WHERE Rating = 'Hot' 
                AND Status != 'Converted'
                AND Status != 'Unqualified'
                ORDER BY CreatedDate DESC
                LIMIT 100
            ];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving hot leads: ' + e.getMessage());
            throw new AcmeDataException('Failed to retrieve hot leads: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets leads ready for conversion to opportunities
     * @return List of qualified leads
     */
    public static List<Lead> getLeadsForConversion() {
        try {
            return [
                SELECT Id, Name, Company, Email, Phone, Title, Industry,
                       LeadSource, Rating, Status, AnnualRevenue,
                       OwnerId, Owner.Name, Owner.Email
                FROM Lead 
                WHERE Status = 'Qualified'
                AND Rating IN ('Hot', 'Warm')
                ORDER BY Rating DESC, CreatedDate ASC
                LIMIT 50
            ];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving leads for conversion: ' + e.getMessage());
            throw new AcmeDataException('Failed to retrieve leads for conversion: ' + e.getMessage());
        }
    }
    
    /**
     * @description Updates lead status and rating
     * @param leadId The lead to update
     * @param newStatus New status value
     * @param newRating New rating value
     */
    public static void updateLeadStatus(Id leadId, String newStatus, String newRating) {
        try {
            Lead leadToUpdate = new Lead(
                Id = leadId,
                Status = newStatus,
                Rating = newRating
            );
            update leadToUpdate;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error updating lead status: ' + e.getMessage());
            throw new AcmeDataException('Failed to update lead status: ' + e.getMessage());
        }
    }
    
    /**
     * Custom exception for data access errors
     */
    public class AcmeDataException extends Exception {}
}