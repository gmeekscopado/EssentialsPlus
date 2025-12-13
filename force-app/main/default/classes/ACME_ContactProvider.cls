/**
 * @description Provider class for Contact data access operations
 * @author ACME Corporation
 * @date 2024
 */
public with sharing class ACME_ContactProvider {

    /**
     * @description Finds or creates contacts in bulk for lead conversion
     * @param leads Lead information for contact creation
     * @param accountId Associated account ID
     * @return Map of Lead IDs to corresponding Contact IDs
     */
    public static Map<Id, Id> findOrCreateContacts(List<Lead> leads, Id accountId) {
        Map<Id, Id> leadToContactIdMap = new Map<Id, Id>();
        if (leads == null || leads.isEmpty() || accountId == null) {
            return leadToContactIdMap;
        }

        Set<String> leadEmails = new Set<String>();
        for (Lead l : leads) {
            if (String.isNotBlank(l.Email)) {
                leadEmails.add(l.Email);
            }
        }

        // Find existing contacts associated with the account
        Map<String, Id> emailToContactIdMap = new Map<String, Id>();
        if (!leadEmails.isEmpty()) {
            for (Contact c : [
                SELECT Id, Email
                FROM Contact
                WHERE Email IN :leadEmails AND AccountId = :accountId
            ]) {
                emailToContactIdMap.put(c.Email, c.Id);
            }
        }

        List<Contact> newContactsToCreate = new List<Contact>();
        Map<String, Id> emailToLeadIdMap = new Map<String, Id>();

        for (Lead leadData : leads) {
            if (String.isNotBlank(leadData.Email)) {
                if (emailToContactIdMap.containsKey(leadData.Email)) {
                    leadToContactIdMap.put(leadData.Id, emailToContactIdMap.get(leadData.Email));
                } else {
                    // Prepare new contact for creation
                    String firstName = leadData.FirstName;
                    String lastName = leadData.LastName;

                    if (String.isBlank(lastName) && String.isNotBlank(leadData.Name)) {
                        if (leadData.Name.contains(' ')) {
                            firstName = leadData.Name.substringBefore(' ');
                            lastName = leadData.Name.substringAfter(' ');
                        } else {
                            lastName = leadData.Name;
                        }
                    }

                    Contact newContact = new Contact(
                        FirstName = firstName,
                        LastName = lastName,
                        Email = leadData.Email,
                        Phone = leadData.Phone,
                        Title = leadData.Title,
                        AccountId = accountId,
                        LeadSource = leadData.LeadSource,
                        OwnerId = leadData.OwnerId
                    );
                    newContactsToCreate.add(newContact);
                    emailToLeadIdMap.put(leadData.Email, leadData.Id);
                }
            }
        }

        try {
            if (!newContactsToCreate.isEmpty()) {
                insert newContactsToCreate;
                // Map the newly created contact IDs back to the original lead IDs
                for (Contact newContact : newContactsToCreate) {
                    if (emailToLeadIdMap.containsKey(newContact.Email)) {
                        Id leadId = emailToLeadIdMap.get(newContact.Email);
                        if (leadId != null) {
                           leadToContactIdMap.put(leadId, newContact.Id);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error creating contacts: ' + e.getMessage());
            throw new AcmeDataException('Failed to create contacts: ' + e.getMessage());
        }

        return leadToContactIdMap;
    }

    /**
     * @description Gets decision makers for opportunity engagement
     * @param accountId Account to find decision makers for
     * @return List of decision maker contacts
     */
    public static List<Contact> getDecisionMakers(Id accountId) {
        if (accountId == null) {
            throw new AcmeDataException('Failed to retrieve decision makers: Account ID cannot be null.');
        }
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