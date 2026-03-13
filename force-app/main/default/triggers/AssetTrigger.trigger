trigger AssetTrigger on Asset (before update) {
    for (Asset newAsset : Trigger.new) {
        Asset oldAsset = Trigger.oldMap.get(newAsset.Id);

        // SC-02: Block direct change to "Obsolete"
        if (newAsset.Status == 'Obsolete' && oldAsset.Status != 'Obsolete') {
            newAsset.addError('Directly setting status to Obsolete is not allowed. Please change the status to \'Pending Decommission\' to initiate the approval process.');
        }

        // SC-01: Request Decommission
        if (newAsset.Status == 'Pending Decommission' && oldAsset.Status != 'Pending Decommission') {
            Action_Audit__c audit = new Action_Audit__c(
                Asset__c = newAsset.Id,
                Initiated_By__c = UserInfo.getUserId(),
                Status__c = 'Pending'
            );
            insert audit;
        }
    }
}