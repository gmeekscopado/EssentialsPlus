/**
 * @description Provider class for Opportunity data access operations
 * @author ACME Corporation
 * @date 2024
 */
public with sharing class ACME_OpportunityProvider {
    
    /**
     * @description Creates opportunity from lead conversion
     * @param leadData Lead information for conversion
     * @param accountId Associated account ID
     * @param contactId Associated contact ID
     * @return Created opportunity ID
     */
    public static Id createOpportunityFromLead(Lead leadData, Id accountId, Id contactId) {
        try {
            Opportunity newOpp = new Opportunity(
                Name = leadData.Company + ' - ' + leadData.Name,
                AccountId = accountId,
                StageName = 'Qualification',
                CloseDate = Date.today().addDays(30),
                LeadSource = leadData.LeadSource,
                OwnerId = leadData.OwnerId,
                Amount = leadData.AnnualRevenue != null ? leadData.AnnualRevenue * 0.1 : 10000
            );
            
            insert newOpp;
            return newOpp.Id;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error creating opportunity: ' + e.getMessage());
            throw new AcmeDataException('Failed to create opportunity: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets high-value opportunities for notifications
     * @return List of high-value opportunities
     */
    public static List<Opportunity> getHighValueOpportunities() {
        try {
            return [
                SELECT Id, Name, Amount, StageName, CloseDate, Account.Name,
                       Owner.Name, Owner.Email, LeadSource
                FROM Opportunity 
                WHERE Amount > 50000
                AND StageName NOT IN ('Closed Won', 'Closed Lost')
                ORDER BY Amount DESC, CloseDate ASC
                LIMIT 20
            ];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving high-value opportunities: ' + e.getMessage());
            throw new AcmeDataException('Failed to retrieve opportunities: ' + e.getMessage());
        }
    }
    
    /**
     * @description Updates opportunity stage
     * @param oppId Opportunity ID to update
     * @param newStage New stage name
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        try {
            Opportunity oppToUpdate = new Opportunity(
                Id = oppId,
                StageName = newStage
            );
            update oppToUpdate;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error updating opportunity stage: ' + e.getMessage());
            throw new AcmeDataException('Failed to update opportunity stage: ' + e.getMessage());
        }
    }
    
    /**
     * Custom exception for data access errors
     */
    public class AcmeDataException extends Exception {}
}