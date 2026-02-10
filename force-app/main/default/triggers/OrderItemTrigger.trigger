trigger OrderItemTrigger on OrderItem (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            OrderItemTriggerHandler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isDelete) {
            OrderItemTriggerHandler.handleAfterDelete(Trigger.old);
        }
    }
}