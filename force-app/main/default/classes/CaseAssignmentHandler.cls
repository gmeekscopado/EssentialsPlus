public with sharing class CaseAssignmentHandler {
    public static void handleBeforeInsert(List<Case> newCases) {
        // Use a map to store account IDs and their corresponding cases
        Map<Id, List<Case>> accountIdToCasesMap = new Map<Id, List<Case>>();

        for (Case c : newCases) {
            if (c.AccountId != null) {
                if (!accountIdToCasesMap.containsKey(c.AccountId)) {
                    accountIdToCasesMap.put(c.AccountId, new List<Case>());
                }
                accountIdToCasesMap.get(c.AccountId).add(c);
            }
        }

        if (accountIdToCasesMap.isEmpty()) {
            return;
        }

        // Get the Federal Support Queue
        Group federalSupportQueue;
        try {
            federalSupportQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Federal Support Queue' LIMIT 1];
        } catch (QueryException e) {
            System.debug('The "Federal Support Queue" was not found. Please ensure it exists.');
            return;
        }

        // Query for accounts with the 'Federal Government' type
        List<Account> federalAccounts = [SELECT Id FROM Account WHERE Id IN :accountIdToCasesMap.keySet() AND Account_Type__c = 'Federal Government'];

        // Assign cases from federal accounts to the queue
        for (Account acc : federalAccounts) {
            if (accountIdToCasesMap.containsKey(acc.Id)) {
                for (Case caseToUpdate : accountIdToCasesMap.get(acc.Id)) {
                    caseToUpdate.OwnerId = federalSupportQueue.Id;
                }
            }
        }
    }
}