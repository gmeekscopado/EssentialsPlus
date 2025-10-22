/**
 * @description Provider class for Contact data access operations
 * @author ACME Corporation
 * @date 2024
 */
public with sharing class ACME_ContactProvider {
    
    /**
     * @description Finds or creates contact for lead conversion
     * @param leadData Lead information for contact creation
     * @param accountId Associated account ID
     * @return Contact ID
     */
    public static Id findOrCreateContact(Lead leadData, Id accountId) {
        try {
            // Try to find existing contact
            List<Contact> existingContacts = [
                SELECT Id, Name, Email
                FROM Contact 
                WHERE Email = :leadData.Email 
                AND AccountId = :accountId
                LIMIT 1
            ];
            
            if (!existingContacts.isEmpty()) {
                return existingContacts[0].Id;
            }
            
            // Create new contact if not found
            Contact newContact = new Contact(
                FirstName = leadData.Name.substringBefore(' '),
                LastName = leadData.Name.substringAfter(' '),
                Email = leadData.Email,
                Phone = leadData.Phone,
                Title = leadData.Title,
                AccountId = accountId,
                LeadSource = leadData.LeadSource,
                OwnerId = leadData.OwnerId
            );
            
            insert newContact;
            return newContact.Id;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error finding/creating contact: ' + e.getMessage());
            throw new AcmeDataException('Failed to find or create contact: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets decision makers for opportunity engagement
     * @param accountId Account to find decision makers for
     * @return List of decision maker contacts
     */
    public static List<Contact> getDecisionMakers(Id accountId) {
        try {
            return [
                SELECT Id, Name, Email, Phone, Title, Department
                FROM Contact 
                WHERE AccountId = :accountId
                AND (Title LIKE '%Director%' OR Title LIKE '%Manager%' OR Title LIKE '%VP%' OR Title LIKE '%President%')
                ORDER BY Title, Name
                LIMIT 10
            ];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving decision makers: ' + e.getMessage());
            throw new AcmeDataException('Failed to retrieve decision makers: ' + e.getMessage());
        }
    }
    
    /**
     * Custom exception for data access errors
     */
    public class AcmeDataException extends Exception {}
}