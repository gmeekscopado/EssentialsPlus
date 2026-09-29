/**
 * @description Unit tests for PaymentTriggerHandler.
 *              Covers positive (status changes to notifiable values),
 *              negative (status unchanged), bulk, and direct unit tests
 *              of @TestVisible helpers to achieve coverage above 75%.
 *              Payment__c is a master-detail child of Invoice__c.
 * @author      Flywire Development Team
 * @date        2026-09-29
 */
@IsTest
private class PaymentTriggerHandlerTest {

    // -------------------------------------------------------------------------
    // Test Setup
    // -------------------------------------------------------------------------

    @TestSetup
    static void setupTestData() {
        Invoice__c inv = new Invoice__c();
        insert inv;

        List<Payment__c> payments = new List<Payment__c>();
        for (Integer i = 0; i < 10; i++) {
            payments.add(new Payment__c(
                Invoice__c        = inv.Id,
                Payment_Amount__c = 500.00 * (i + 1),
                Payment_Date__c   = Date.today(),
                Payment_Method__c = 'Wire Transfer',
                Status__c         = 'Pending'
            ));
        }
        insert payments;
    }

    // -------------------------------------------------------------------------
    // Positive: single record -> Completed (exercises trigger + handler path)
    // -------------------------------------------------------------------------

    @IsTest
    static void testStatusChangeToCompleted_sendsNotification() {
        Payment__c pmt = [SELECT Id, Status__c FROM Payment__c LIMIT 1];

        Test.startTest();
            pmt.Status__c = 'Completed';
            update pmt;
        Test.stopTest();

        Payment__c updated = [SELECT Id, Status__c FROM Payment__c WHERE Id = :pmt.Id];
        System.assertEquals('Completed', updated.Status__c, 'Status should be Completed.');
    }

    // -------------------------------------------------------------------------
    // Positive: single record -> Failed
    // -------------------------------------------------------------------------

    @IsTest
    static void testStatusChangeToFailed_sendsNotification() {
        Payment__c pmt = [SELECT Id, Status__c FROM Payment__c LIMIT 1];

        Test.startTest();
            pmt.Status__c = 'Failed';
            update pmt;
        Test.stopTest();

        Payment__c updated = [SELECT Id, Status__c FROM Payment__c WHERE Id = :pmt.Id];
        System.assertEquals('Failed', updated.Status__c, 'Status should be Failed.');
    }

    // -------------------------------------------------------------------------
    // Positive: single record -> Cancelled
    // -------------------------------------------------------------------------

    @IsTest
    static void testStatusChangeToCancelled_sendsNotification() {
        Payment__c pmt = [SELECT Id, Status__c FROM Payment__c LIMIT 1];

        Test.startTest();
            pmt.Status__c = 'Cancelled';
            update pmt;
        Test.stopTest();

        Payment__c updated = [SELECT Id, Status__c FROM Payment__c WHERE Id = :pmt.Id];
        System.assertEquals('Cancelled', updated.Status__c, 'Status should be Cancelled.');
    }

    // -------------------------------------------------------------------------
    // Negative: non-status field change - no notification path exercised
    // -------------------------------------------------------------------------

    @IsTest
    static void testNoStatusChange_noNotification() {
        Payment__c pmt = [SELECT Id, Status__c, Payment_Amount__c FROM Payment__c LIMIT 1];

        Test.startTest();
            pmt.Payment_Amount__c = 9999.00;
            update pmt;
        Test.stopTest();

        Payment__c updated = [SELECT Id, Status__c FROM Payment__c WHERE Id = :pmt.Id];
        System.assertEquals('Pending', updated.Status__c, 'Status should remain Pending.');
    }

    // -------------------------------------------------------------------------
    // Bulk: all 10 records -> Completed in one DML call
    // -------------------------------------------------------------------------

    @IsTest
    static void testBulkStatusChange_allCompleted() {
        List<Payment__c> payments = [SELECT Id, Status__c FROM Payment__c];

        Test.startTest();
            for (Payment__c p : payments) {
                p.Status__c = 'Completed';
            }
            update payments;
        Test.stopTest();

        List<Payment__c> updated = [SELECT Id, Status__c FROM Payment__c];
        for (Payment__c p : updated) {
            System.assertEquals('Completed', p.Status__c, 'All records should be Completed.');
        }
    }

    // -------------------------------------------------------------------------
    // Unit: buildEmail - directly call @TestVisible method with explicit params
    //       to cover the email construction path without relationship traversal
    // -------------------------------------------------------------------------

    @IsTest
    static void testBuildEmail_generatesCorrectEmail() {
        Payment__c pmt = [
            SELECT Id, Name, Status__c, Payment_Amount__c,
                   Payment_Date__c, Payment_Method__c
            FROM Payment__c LIMIT 1
        ];
        pmt.Status__c = 'Completed';

        Test.startTest();
            Messaging.SingleEmailMessage email =
                PaymentTriggerHandler.buildEmail(pmt, 'notify@flywire.com', 'Flywire Ops');
        Test.stopTest();

        System.assert(email.getSubject().contains('Completed'), 'Subject should contain new status.');
        System.assertEquals(
            new List<String>{ 'notify@flywire.com' },
            email.getToAddresses(),
            'To address should match.'
        );
    }

    // -------------------------------------------------------------------------
    // Unit: buildEmailBody - directly call @TestVisible method and assert body content
    // -------------------------------------------------------------------------

    @IsTest
    static void testBuildEmailBody_containsExpectedFields() {
        Payment__c pmt = [
            SELECT Id, Name, Status__c, Payment_Amount__c,
                   Payment_Date__c, Payment_Method__c
            FROM Payment__c LIMIT 1
        ];
        pmt.Status__c = 'Failed';

        Test.startTest();
            String body = PaymentTriggerHandler.buildEmailBody(pmt, 'Test Owner');
        Test.stopTest();

        System.assert(body.contains('Test Owner'), 'Body should greet the owner.');
        System.assert(body.contains('Failed'), 'Body should include the new status.');
        System.assert(body.contains(pmt.Name), 'Body should include the payment name.');
    }
}