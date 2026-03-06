public with sharing class CaseTriggerHandler {
    public static void handleBeforeInsert(List<Case> newCases) {
        List<Group> federalQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Federal Support Queue' LIMIT 1];
        
        if(federalQueue.isEmpty()){
            System.debug(Logginglevel.ERROR, 'The "Federal Support Queue" was not found. Please create it.');
            return;
        }

        Set<Id> accountIds = new Set<Id>();
        for (Case c : newCases) {
            if (c.AccountId != null) {
                accountIds.add(c.AccountId);
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }

        Map<Id, Account> federalAccounts = new Map<Id, Account>([
            SELECT Id FROM Account WHERE Id IN :accountIds AND Type = 'Government'
        ]);

        for (Case c : newCases) {
            if (c.AccountId != null && federalAccounts.containsKey(c.AccountId)) {
                c.OwnerId = federalQueue[0].Id;
            }
        }
    }
}