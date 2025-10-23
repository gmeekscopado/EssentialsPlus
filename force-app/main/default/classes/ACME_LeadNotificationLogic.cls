/**
 * @description Business logic for lead and opportunity notifications
 * @author ACME Corporation
 * @date 2024
 */
public with sharing class ACME_LeadNotificationLogic {

    /**
     * @description Sends notifications for hot leads (REFACTORED - Reduced Complexity)
     * @param leads List of hot leads to process
     */
    public static void sendHotLeadNotifications(List<Lead> leads) {
        try {
            if (leads == null || leads.isEmpty()) {
                return;
            }

            for (Lead lead : leads) {
                processHotLeadNotification(lead);
            }

        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Error sending hot lead notifications: ' + ex.getMessage());
            throw new AcmeNotificationException('Failed to send hot lead notifications: ' + ex.getMessage());
        }
    }

    /**
     * @description Processes notification for a single hot lead
     * @param lead Hot lead to process
     */
    private static void processHotLeadNotification(Lead lead) {
        // Skip if rating is not Hot
        if (lead.Rating != 'Hot') {
            return;
        }

        // Build notification message
        String message = buildHotLeadMessage(lead);

        // Send to owner
        if (shouldNotifyOwner(lead)) {
            sendNotificationToUser(lead.Owner.Email, 'Hot Lead Alert', message);
        }
    }

    /**
     * @description Builds message content for hot lead notification
     * @param lead Lead record
     * @return Formatted notification message
     */
    private static String buildHotLeadMessage(Lead lead) {
        return 'New Hot Lead: ' + lead.Name + '\n' +
               'Company: ' + lead.Company + '\n' +
               'Email: ' + lead.Email + '\n' +
               'Phone: ' + lead.Phone + '\n' +
               'Source: ' + lead.LeadSource;
    }

    /**
     * @description Determines if owner should be notified
     * @param lead Lead record
     * @return True if owner should receive notification
     */
    private static Boolean shouldNotifyOwner(Lead lead) {
        return lead.Owner != null &&
               String.isNotBlank(lead.Owner.Email);
    }

    /**
     * @description Sends notifications for new opportunities (REFACTORED - Reduced Complexity)
     * @param opportunities List of opportunities to process
     */
    public static void sendOpportunityNotifications(List<Opportunity> opportunities) {
        try {
            if (opportunities == null || opportunities.isEmpty()) {
                return;
            }

            // Get manager info for owners who need it
            Set<Id> ownerIds = new Set<Id>();
            for (Opportunity opp : opportunities) {
                if (isQualifyingStage(opp.StageName) && opp.Owner != null) {
                    ownerIds.add(opp.OwnerId);
                }
            }

            // Query managers for these owners
            Map<Id, User> ownersWithManagers = new Map<Id, User>([
                SELECT Id, Email, Manager.Email
                FROM User
                WHERE Id IN :ownerIds
            ]);

            for (Opportunity opp : opportunities) {
                processOpportunityNotification(opp, ownersWithManagers);
            }

        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Error sending opportunity notifications: ' + ex.getMessage());
            throw new AcmeNotificationException('Failed to send opportunity notifications: ' + ex.getMessage());
        }
    }

    /**
     * @description Processes notification for a single opportunity
     * @param opp Opportunity to process
     * @param ownersWithManagers Map of owners with manager information
     */
    private static void processOpportunityNotification(Opportunity opp, Map<Id, User> ownersWithManagers) {
        // Skip if not in qualifying stages
        if (!isQualifyingStage(opp.StageName)) {
            return;
        }

        // Build notification message
        String message = buildOpportunityMessage(opp);

        // Send to owner
        if (shouldNotifyOwnerOpp(opp)) {
            sendNotificationToUser(opp.Owner.Email, 'New Opportunity Created', message);
        }

        // Send to manager if applicable
        User ownerWithManager = ownersWithManagers.get(opp.OwnerId);
        if (ownerWithManager != null && ownerWithManager.Manager != null && 
            String.isNotBlank(ownerWithManager.Manager.Email)) {
            sendNotificationToUser(ownerWithManager.Manager.Email, 'New Opportunity - Team Member', message);
        }
    }

    /**
     * @description Checks if opportunity stage qualifies for notification
     * @param stageName Stage name to check
     * @return True if stage qualifies
     */
    private static Boolean isQualifyingStage(String stageName) {
        Set<String> qualifyingStages = new Set<String>{
            'Qualification',
            'Needs Analysis',
            'Proposal/Price Quote'
        };
        return qualifyingStages.contains(stageName);
    }

    /**
     * @description Builds message content for opportunity notification
     * @param opp Opportunity record
     * @return Formatted notification message
     */
    private static String buildOpportunityMessage(Opportunity opp) {
        return 'New Opportunity: ' + opp.Name + '\n' +
               'Account: ' + opp.Account.Name + '\n' +
               'Amount: $' + String.valueOf(opp.Amount) + '\n' +
               'Stage: ' + opp.StageName + '\n' +
               'Close Date: ' + String.valueOf(opp.CloseDate) + '\n' +
               'Source: ' + opp.LeadSource;
    }

    /**
     * @description Determines if opportunity owner should be notified
     * @param opp Opportunity record
     * @return True if owner should receive notification
     */
    private static Boolean shouldNotifyOwnerOpp(Opportunity opp) {
        return opp.Owner != null &&
               String.isNotBlank(opp.Owner.Email);
    }

    /**
     * @description Sends notification to specified user
     * @param recipientEmail Email address of recipient
     * @param subject Email subject line
     * @param body Email body content
     */
    private static void sendNotificationToUser(String recipientEmail, String subject, String body) {
        // Implementation would use Messaging.SingleEmailMessage or custom notification
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{ recipientEmail });
        mail.setSubject(subject);
        mail.setPlainTextBody(body);

        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        }
    }

    /**
     * @description Custom exception for notification errors
     */
    public class AcmeNotificationException extends Exception {}
}