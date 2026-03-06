@isTest
private class CaseTriggerTest {

    @TestSetup
    static void makeData(){
        Group queue = new Group(Name = 'Federal Support Queue', Type = 'Queue');
        insert queue;

        // Associate the queue with the Case object
        QueueSobject queueSobject = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert queueSobject;

        Account federalAccount = new Account(Name='Test Federal Account', Type='Government');
        insert federalAccount;

        Account commercialAccount = new Account(Name='Test Commercial Account', Type='Other');
        insert commercialAccount;
    }

    @isTest
    static void testFederalCaseAssignment() {
        Group federalQueue = [SELECT Id FROM Group WHERE Name = 'Federal Support Queue' LIMIT 1];
        Account federalAccount = [SELECT Id FROM Account WHERE Name = 'Test Federal Account' LIMIT 1];

        Test.startTest();
        Case newCase = new Case(Subject = 'Test Case', AccountId = federalAccount.Id);
        insert newCase;
        Test.stopTest();

        Case resultCase = [SELECT OwnerId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(federalQueue.Id, resultCase.OwnerId, 'Case should be assigned to the Federal Support Queue.');
    }

    @isTest
    static void testCommercialCaseAssignment() {
        Account commercialAccount = [SELECT Id FROM Account WHERE Name = 'Test Commercial Account' LIMIT 1];
        Id initialOwnerId = UserInfo.getUserId();

        Test.startTest();
        Case newCase = new Case(Subject = 'Test Case', AccountId = commercialAccount.Id);
        insert newCase;
        Test.stopTest();

        Case resultCase = [SELECT OwnerId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(initialOwnerId, resultCase.OwnerId, 'Case should not be reassigned.');
    }
    
    @isTest
    static void testBulkCaseAssignment() {
        Group federalQueue = [SELECT Id FROM Group WHERE Name = 'Federal Support Queue' LIMIT 1];
        Account federalAccount = [SELECT Id FROM Account WHERE Name = 'Test Federal Account' LIMIT 1];
        Account commercialAccount = [SELECT Id FROM Account WHERE Name = 'Test Commercial Account' LIMIT 1];
        Id initialOwnerId = UserInfo.getUserId();

        List<Case> casesToInsert = new List<Case>();
        casesToInsert.add(new Case(Subject = 'Federal Case 1', AccountId = federalAccount.Id));
        casesToInsert.add(new Case(Subject = 'Commercial Case 1', AccountId = commercialAccount.Id));
        casesToInsert.add(new Case(Subject = 'Federal Case 2', AccountId = federalAccount.Id));

        Test.startTest();
        insert casesToInsert;
        Test.stopTest();

        List<Case> results = [SELECT Id, OwnerId, Subject FROM Case WHERE Id IN :casesToInsert];
        for(Case c : results){
            if(c.Subject.startsWith('Federal')){
                System.assertEquals(federalQueue.Id, c.OwnerId, 'Federal cases should be assigned to the queue.');
            } else {
                System.assertEquals(initialOwnerId, c.OwnerId, 'Commercial cases should not be reassigned.');
            }
        }
    }
}