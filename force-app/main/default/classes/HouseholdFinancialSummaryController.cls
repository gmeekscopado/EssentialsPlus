public without sharing class HouseholdFinancialSummaryController {
    @AuraEnabled(cacheable=true)
    public static HouseholdSummary getHouseholdSummary(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('Account ID cannot be null.');
        }

        List<Contact> relatedContacts = [
            SELECT Id, Name
            FROM Contact
            WHERE AccountId = :accountId
            ORDER BY Name
        ];

        Set<Id> contactIds = new Map<Id, Contact>(relatedContacts).keySet();
        Decimal totalAUM = 0;

        if (!contactIds.isEmpty()) {
            AggregateResult[] results = [
                SELECT SUM(Balance__c) total
                FROM Financial_Account__c
                WHERE Contact__c IN :contactIds
            ];

            if (results != null && !results.isEmpty() && results[0].get('total') != null) {
                totalAUM = (Decimal)results[0].get('total');
            }
        }

        HouseholdSummary summary = new HouseholdSummary();
        summary.contacts = relatedContacts;
        summary.totalAUM = totalAUM;

        return summary;
    }

    public class HouseholdSummary {
        @AuraEnabled
        public List<Contact> contacts { get; set; }
        @AuraEnabled
        public Decimal totalAUM { get; set; }
    }
}