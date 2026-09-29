/**
 * @description Trigger on Payment__c to handle status change notifications.
 *              All logic is delegated to PaymentTriggerHandler to keep the
 *              trigger lean and testable.
 * @author      Flywire Development Team
 * @date        2026-09-29
 */
trigger PaymentTrigger on Payment__c (after update) {
    PaymentTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
}