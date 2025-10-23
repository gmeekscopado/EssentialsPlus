/**
 * @description Business logic for lead notifications and alerts
 * @author ACME Corporation
 * @date 2024
 */
public with sharing class ACME_LeadNotificationLogic {
    
    /**
     * @description Sends hot lead notifications to sales reps and managers
     * @param hotLeads List of hot leads to process
     */
    public static void sendHotLeadNotifications(List<Lead> hotLeads) {
        try {
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            
            for (Lead hotLead : hotLeads) {
                // Notify lead owner
                String ownerMessage = String.format(
                    'Hot lead alert: {0} from {1} requires immediate attention. Lead Rating: {2}',
                    new List<String>{hotLead.Name, hotLead.Company, hotLead.Rating}
                );
                
                if (hotLead.Owner != null && hotLead.Owner.Email != null) {
                    Messaging.SingleEmailMessage ownerEmail = createEmailMessage(
                        hotLead.Owner.Email,
                        'Hot Lead Alert: ' + hotLead.Name,
                        ownerMessage
                    );
                    emailsToSend.add(ownerEmail);
                }
                
                // Notify sales managers
                List<User> managers = ACME_UserProvider.getSalesManagers();
                for (User manager : managers) {
                    if (manager.Email != null) {
                        Messaging.SingleEmailMessage managerEmail = createEmailMessage(
                            manager.Email,
                            'Hot Lead Alert for Review: ' + hotLead.Name,
                            ownerMessage + '\n\nAssigned to: ' + (hotLead.Owner != null ? hotLead.Owner.Name : 'Unknown')
                        );
                        emailsToSend.add(managerEmail);
                    }
                }
            }
            
            if (!emailsToSend.isEmpty()) {
                Messaging.sendEmail(emailsToSend);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error sending hot lead notifications: ' + e.getMessage());
            throw new AcmeBusinessException('Failed to send notifications: ' + e.getMessage());
        }
    }
    
    /**
     * @description Sends new opportunity notifications with financial details
     * @param opportunities List of new opportunities
     */
    public static void sendOpportunityNotifications(List<Opportunity> opportunities) {
        try {
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            
            for (Opportunity opp : opportunities) {
                String notificationMessage = String.format(
                    'New opportunity created: {0} with potential value of {1}. Lead Source: {2}',
                    new List<String>{
                        opp.Name, 
                        String.valueOf(opp.Amount), 
                        opp.LeadSource != null ? opp.LeadSource : 'Unknown'
                    }
                );
                
                // Notify opportunity owner
                User oppOwner = ACME_UserProvider.getUserWithRole(opp.OwnerId);
                if (oppOwner != null && oppOwner.Email != null) {
                    Messaging.SingleEmailMessage ownerEmail = createEmailMessage(
                        oppOwner.Email,
                        'New Opportunity Created: ' + opp.Name,
                        notificationMessage
                    );
                    emailsToSend.add(ownerEmail);
                    
                    // Notify manager if available
                    if (oppOwner.ManagerId != null && oppOwner.Manager != null && oppOwner.Manager.Email != null) {
                        Messaging.SingleEmailMessage managerEmail = createEmailMessage(
                            oppOwner.Manager.Email,
                            'New Opportunity - Team Update: ' + opp.Name,
                            notificationMessage + '\n\nOwner: ' + oppOwner.Name
                        );
                        emailsToSend.add(managerEmail);
                    }
                }
            }
            
            if (!emailsToSend.isEmpty()) {
                Messaging.sendEmail(emailsToSend);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error sending opportunity notifications: ' + e.getMessage());
            throw new AcmeBusinessException('Failed to send opportunity notifications: ' + e.getMessage());
        }
    }
    
    /**
     * @description Creates standardized email message
     * @param toEmail Recipient email address
     * @param subject Email subject
     * @param body Email body
     * @return Configured email message
     */
    private static Messaging.SingleEmailMessage createEmailMessage(String toEmail, String subject, String body) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{toEmail});
        email.setSubject(subject);
        email.setPlainTextBody(body);
        email.setSaveAsActivity(false);
        return email;
    }
    
    /**
     * Custom exception for business logic errors
     */
    public class AcmeBusinessException extends Exception {}
}