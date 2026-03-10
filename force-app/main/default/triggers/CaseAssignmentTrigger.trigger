trigger CaseAssignmentTrigger on Case (before insert) {
    CaseAssignmentHandler.handleBeforeInsert(Trigger.new);
}