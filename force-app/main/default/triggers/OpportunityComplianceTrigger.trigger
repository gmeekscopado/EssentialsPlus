trigger OpportunityComplianceTrigger on Opportunity (before update) {
    // Set of Opportunity IDs that are moving to 'Closed Won'
    Set<Id> oppsToCheck = new Set<Id>();
    for (Opportunity opp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
        if (opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won') {
            oppsToCheck.add(opp.Id);
        }
    }

    if (!oppsToCheck.isEmpty()) {
        // Map to hold Opportunity IDs and their set of attached document titles
        Map<Id, Set<String>> oppsWithDocs = new Map<Id, Set<String>>();
        for(Id oppId : oppsToCheck) {
            oppsWithDocs.put(oppId, new Set<String>());
        }

        // Single query to get all documents for the relevant opportunities
        for (ContentDocumentLink cdl : [SELECT ContentDocument.Title, LinkedEntityId
                                        FROM ContentDocumentLink
                                        WHERE LinkedEntityId IN :oppsToCheck]) {
            oppsWithDocs.get(cdl.LinkedEntityId).add(cdl.ContentDocument.Title);
        }

        // Set of required document titles
        Set<String> requiredDocTitles = new Set<String>{'Business Tax ID Form', 'Articles of Incorporation'};

        // Add errors to opportunities with missing documents
        for (Opportunity opp : Trigger.new) {
            if (oppsToCheck.contains(opp.Id)) {
                Set<String> attachedDocs = oppsWithDocs.get(opp.Id);
                Set<String> missingDocs = requiredDocTitles.clone();
                missingDocs.removeAll(attachedDocs);

                if (!missingDocs.isEmpty()) {
                    String missingDocsList = String.join(new List<String>(missingDocs), ', ');
                    opp.addError('Action required: The following compliance documents are missing: ' + missingDocsList);
                }
            }
        }
    }
}