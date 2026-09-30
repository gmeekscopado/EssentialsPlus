/**
 * @description Handler class for Payment__c trigger logic.
 *              Detects Status__c changes and sends email notifications
 *              to the parent Invoice owner for Completed, Failed, and
 *              Cancelled statuses.
 *              Bulkified; Payment__c is a master-detail child of Invoice__c
 *              so ownership is resolved by passing ownerEmail/ownerName into
 *              the email builder to keep the helper fully unit-testable.
 * @author      Flywire Development Team
 * @date        2026-09-29
 */
public with sharing class PaymentTriggerHandler {

    /** Statuses that warrant an outbound notification. */
    @TestVisible
    private static final Set<String> NOTIFY_STATUSES = new Set<String>{
        'Completed', 'Failed', 'Cancelled'
    };

    /**
     * @description Entry point called from the after-update trigger context.
     * @param newList  Trigger.new - updated Payment records.
     * @param oldMap   Trigger.oldMap - pre-update Payment records keyed by Id.
     */
    public static void handleAfterUpdate(
        List<Payment__c> newList,
        Map<Id, Payment__c> oldMap
    ) {
        Set<Id> changedIds = new Set<Id>();
        for (Payment__c pmt : newList) {
            Payment__c oldPmt = oldMap.get(pmt.Id);
            if (pmt.Status__c != oldPmt.Status__c && NOTIFY_STATUSES.contains(pmt.Status__c)) {
                changedIds.add(pmt.Id);
            }
        }

        if (changedIds.isEmpty()) {
            return;
        }

        // Re-query with Invoice owner details for email composition
        List<Payment__c> paymentsToNotify = [
            SELECT Id, Name, Status__c, Payment_Amount__c, Payment_Date__c,
                   Payment_Method__c,
                   Invoice__r.Owner.Email, Invoice__r.Owner.Name
            FROM Payment__c
            WHERE Id IN :changedIds
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Payment__c pmt : paymentsToNotify) {
            String ownerEmail = pmt.Invoice__r.Owner.Email;
            String ownerName  = pmt.Invoice__r.Owner.Name;
            if (!String.isBlank(ownerEmail)) {
                emails.add(buildEmail(pmt, ownerEmail, ownerName));
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails, false);
        }
    }

    /**
     * @description Constructs a single email notification for a Payment status change.
     *              Exposed as @TestVisible so unit tests can call it directly
     *              without needing a live relationship traversal.
     * @param pmt        The updated Payment record.
     * @param ownerEmail Recipient email address.
     * @param ownerName  Recipient display name.
     * @return           A configured SingleEmailMessage instance.
     */
    @TestVisible
    static Messaging.SingleEmailMessage buildEmail(
        Payment__c pmt,
        String ownerEmail,
        String ownerName
    ) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ ownerEmail });
        mail.setSubject('Payment Status Update: ' + pmt.Name + ' is now ' + pmt.Status__c);
        mail.setPlainTextBody(buildEmailBody(pmt, ownerName));
        mail.setSaveAsActivity(false);
        return mail;
    }

    /**
     * @description Composes the plain-text email body for a status change notification.
     * @param pmt       The updated Payment record.
     * @param ownerName The name of the Invoice owner.
     * @return          Formatted plain-text email body.
     */
    @TestVisible
    static String buildEmailBody(Payment__c pmt, String ownerName) {
        return 'Hi ' + ownerName + ',\n\n'
            + 'The following payment record has been updated:\n\n'
            + 'Payment Number : ' + pmt.Name + '\n'
            + 'Payment Amount : ' + pmt.Payment_Amount__c + '\n'
            + 'Payment Date   : ' + pmt.Payment_Date__c + '\n'
            + 'Payment Method : ' + pmt.Payment_Method__c + '\n'
            + 'New Status     : ' + pmt.Status__c + '\n\n'
            + 'Please log in to Salesforce to review and take any required action.\n\n'
            + 'This is an automated notification. Please do not reply to this email.';
    }
}