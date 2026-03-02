/**
 * @description Provider class for Contact data access operations, refactored for bulk processing and security.
 * @author ACME Corporation
 * @date 2025-12-15
 */
public with sharing class ACME_ContactProvider {

    /**
     * @description Finds existing contacts or prepares new ones for creation in a bulk-safe manner.
     * @param leads A list of Lead records to process.
     * @param accountId The ID of the Account to associate the contacts with.
     * @return A map of original Lead IDs to their corresponding found or created Contact IDs.
     */
    public static Map<Id, Id> findOrCreateContacts(List<Lead> leads, Id accountId) {
        if (leads == null || leads.isEmpty()) {
            return new Map<Id, Id>();
        }
        if (accountId == null) {
            throw new AcmeDataException('Account ID cannot be null.');
        }

        // Security Check: Verify FLS read access on key Lead fields
        ACME_Security.verifyFieldReadAccess(Lead.SObjectType, new Set<String>{'Id', 'Email', 'Name', 'FirstName', 'LastName', 'Phone', 'Title', 'LeadSource', 'OwnerId'});

        Map<String, Lead> emailToLeadMap = getEmailToLeadMap(leads);
        Map<String, Id> emailToExistingContactIdMap = findExistingContactsByEmail(emailToLeadMap.keySet(), accountId);

        List<Contact> contactsToCreate = new List<Contact>();
        Map<Id, Id> leadToContactIdMap = new Map<Id, Id>();

        for (Lead currentLead : leads) {
            if (String.isNotBlank(currentLead.Email) && emailToExistingContactIdMap.containsKey(currentLead.Email)) {
                leadToContactIdMap.put(currentLead.Id, emailToExistingContactIdMap.get(currentLead.Email));
            } else if (String.isNotBlank(currentLead.Email)) {
                contactsToCreate.add(createContactFromLead(currentLead, accountId));
            }
        }

        insertNewContacts(contactsToCreate, leadToContactIdMap, emailToLeadMap);

        return leadToContactIdMap;
    }

    /**
     * @description Retrieves a list of decision-making contacts from a given account.
     * @param accountId The ID of the Account to search within.
     * @return A list of contacts who are potential decision-makers.
     */
    public static List<Contact> getDecisionMakers(Id accountId) {
        if (accountId == null) {
            throw new AcmeDataException('Account ID cannot be null when retrieving decision makers.');
        }
        
        // Security Check: Verify FLS read access on Contact fields
        ACME_Security.verifyFieldReadAccess(Contact.SObjectType, new Set<String>{'Id', 'Name', 'Email', 'Phone', 'Title', 'Department'});

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
            throw new AcmeDataException('Failed to retrieve decision makers: ' + e.getMessage());
        }
    }

    // --- Helper Methods ---

    /**
     * @description Creates a map of email addresses to Lead records.
     */
    private static Map<String, Lead> getEmailToLeadMap(List<Lead> leads) {
        Map<String, Lead> emailToLeadMap = new Map<String, Lead>();
        for (Lead l : leads) {
            if (String.isNotBlank(l.Email)) {
                emailToLeadMap.put(l.Email, l);
            }
        }
        return emailToLeadMap;
    }

    /**
     * @description Queries for existing contacts based on a set of email addresses and an account ID.
     */
    private static Map<String, Id> findExistingContactsByEmail(Set<String> emails, Id accountId) {
        Map<String, Id> emailToContactIdMap = new Map<String, Id>();
        if (emails.isEmpty()) {
            return emailToContactIdMap;
        }

        for (Contact c : [SELECT Id, Email FROM Contact WHERE Email IN :emails AND AccountId = :accountId]) {
            emailToContactIdMap.put(c.Email, c.Id);
        }
        return emailToContactIdMap;
    }

    /**
     * @description Constructs a new Contact object from a Lead record.
     */
    private static Contact createContactFromLead(Lead leadData, Id accountId) {
        String firstName = leadData.FirstName;
        String lastName = leadData.LastName;

        // Handle cases where name is in a single field
        if (String.isBlank(lastName) && String.isNotBlank(leadData.Name)) {
            if (leadData.Name.contains(' ')) {
                firstName = leadData.Name.substringBefore(' ');
                lastName = leadData.Name.substringAfter(' ');
            } else {
                lastName = leadData.Name;
                firstName = null;
            }
        }
        
        return new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = leadData.Email,
            Phone = leadData.Phone,
            Title = leadData.Title,
            AccountId = accountId,
            LeadSource = leadData.LeadSource,
            OwnerId = leadData.OwnerId
        );
    }

    /**
     * @description Inserts new contacts and maps their new IDs back to the original Lead IDs.
     */
    private static void insertNewContacts(List<Contact> contactsToCreate, Map<Id, Id> leadToContactIdMap, Map<String, Lead> emailToLeadMap) {
        if (contactsToCreate.isEmpty()) {
            return;
        }

        // Security Check: Verify FLS create access
        ACME_Security.verifyObjectCreateAccess(Contact.SObjectType);

        try {
            insert contactsToCreate;
            // Map the newly created contact IDs back to the original lead IDs
            for (Contact newContact : contactsToCreate) {
                if (emailToLeadMap.containsKey(newContact.Email)) {
                    leadToContactIdMap.put(emailToLeadMap.get(newContact.Email).Id, newContact.Id);
                }
            }
        } catch (Exception e) {
            throw new AcmeDataException('Failed to create contacts: ' + e.getMessage());
        }
    }

    /**
     * @description Custom exception for data access errors within this class.
     */
    public class AcmeDataException extends Exception {
        // Intentionally left empty as it serves as a custom exception type
    }
}