@isTest
private class CaseAssignmentTests {

    @testSetup
    static void setup() {
        // Create a queue for testing
        Group queue = new Group(Name = 'Federal Support Queue', Type = 'Queue');
        insert queue;

        // Associate the queue with the Case object
        insert new QueueSobject(
            QueueId = queue.Id,
            SobjectType = 'Case'
        );

        // Create a test account that is a federal government account
        Account federalAccount = new Account(Name = 'Test Federal Account', Account_Type__c = 'Federal Government');
        insert federalAccount;

        // Create a test account that is not a federal government account
        Account nonFederalAccount = new Account(Name = 'Test Non-Federal Account', Account_Type__c = 'Commercial');
        insert nonFederalAccount;
    }

    @isTest
    static void testFederalCaseAssignment() {
        // Get the test accounts
        Account federalAccount = [SELECT Id FROM Account WHERE Name = 'Test Federal Account'];
        Group federalQueue = [SELECT Id FROM Group WHERE Name = 'Federal Support Queue'];

        // Create a new case for the federal account
        Case newCase = new Case(
            AccountId = federalAccount.Id,
            Subject = 'Test Case for Federal Account',
            Status = 'New',
            Origin = 'Phone'
        );

        Test.startTest();
        insert newCase;
        Test.stopTest();

        // Verify that the case was assigned to the Federal Support Queue
        Case resultCase = [SELECT OwnerId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(federalQueue.Id, resultCase.OwnerId, 'Case should be assigned to the Federal Support Queue.');
    }

    @isTest
    static void testNonFederalCaseAssignment() {
        // Get the test account
        Account nonFederalAccount = [SELECT Id, OwnerId FROM Account WHERE Name = 'Test Non-Federal Account'];

        // Create a new case for the non-federal account
        Case newCase = new Case(
            AccountId = nonFederalAccount.Id,
            Subject = 'Test Case for Non-Federal Account',
            Status = 'New',
            Origin = 'Phone'
        );

        Test.startTest();
        insert newCase;
        Test.stopTest();

        // Verify that the case owner remains the account owner
        Case resultCase = [SELECT OwnerId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(nonFederalAccount.OwnerId, resultCase.OwnerId, 'Case owner should not be changed.');
    }

    @isTest
    static void testBulkCaseAssignment() {
        // Get the test accounts and queue
        Account federalAccount = [SELECT Id FROM Account WHERE Name = 'Test Federal Account'];
        Account nonFederalAccount = [SELECT Id, OwnerId FROM Account WHERE Name = 'Test Non-Federal Account'];
        Group federalQueue = [SELECT Id FROM Group WHERE Name = 'Federal Support Queue'];

        // Create a list of cases to insert
        List<Case> casesToInsert = new List<Case>();
        for (Integer i = 0; i < 100; i++) {
            casesToInsert.add(new Case(
                AccountId = federalAccount.Id,
                Subject = 'Bulk Federal Case ' + i,
                Status = 'New',
                Origin = 'Web'
            ));
            casesToInsert.add(new Case(
                AccountId = nonFederalAccount.Id,
                Subject = 'Bulk Non-Federal Case ' + i,
                Status = 'New',
                Origin = 'Email'
            ));
        }

        Test.startTest();
        insert casesToInsert;
        Test.stopTest();

        // Verify the assignments
        Integer federalCasesAssigned = [SELECT COUNT() FROM Case WHERE AccountId = :federalAccount.Id AND OwnerId = :federalQueue.Id];
        Integer nonFederalCasesUnchanged = [SELECT COUNT() FROM Case WHERE AccountId = :nonFederalAccount.Id AND OwnerId = :nonFederalAccount.OwnerId];

        System.assertEquals(100, federalCasesAssigned, 'All federal cases should be assigned to the queue.');
        System.assertEquals(100, nonFederalCasesUnchanged, 'Non-federal case owners should not be changed.');
    }
}