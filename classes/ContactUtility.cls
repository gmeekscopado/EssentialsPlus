/**
 * @description Utility class for Contact operations
 * @author BuildAgent
 * @date 2025-02-25
 */
public with sharing class ContactUtility {
    
    /**
     * @description Updates contact email domains for a list of contacts
     * @param contacts List of contacts to process
     * @return List<Contact> Updated list of contacts
     */
    public static List<Contact> updateEmailDomains(List<Contact> contacts) {
        List<Contact> updatedContacts = new List<Contact>();
        
        for(Contact cont : contacts) {
            if(String.isNotBlank(cont.Email)) {
                // Get domain from email
                String[] emailParts = cont.Email.split('@');
                if(emailParts.size() > 1) {
                    cont.Email_Domain__c = emailParts[1];
                    updatedContacts.add(cont);
                }
            }
        }
        
        return updatedContacts;
    }
}