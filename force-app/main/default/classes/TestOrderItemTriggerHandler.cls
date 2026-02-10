@isTest
public class TestOrderItemTriggerHandler {

    @testSetup
    static void makeData(){
        Account surgeonAccount = new Account(Name='Test Surgeon Account');
        insert surgeonAccount;

        Contact certifiedSurgeon = new Contact(
            LastName = 'Certified',
            AccountId = surgeonAccount.Id,
            EVO_Viva_Certification_Status__c = 'Certified'
        );
        Contact nonCertifiedSurgeon = new Contact(
            LastName = 'NonCertified',
            AccountId = surgeonAccount.Id,
            EVO_Viva_Certification_Status__c = 'Not Certified'
        );
        insert new List<Contact>{certifiedSurgeon, nonCertifiedSurgeon};

        Product2 evoProduct = new Product2(Name = 'EVO Viva', IsActive = true);
        Product2 otherProduct = new Product2(Name = 'Other Lens', IsActive = true);
        insert new List<Product2>{evoProduct, otherProduct};

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry evoPbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = evoProduct.Id,
            UnitPrice = 1000,
            IsActive = true
        );
        PricebookEntry otherPbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = otherProduct.Id,
            UnitPrice = 500,
            IsActive = true
        );
        insert new List<PricebookEntry>{evoPbe, otherPbe};

        Account customerAccount = new Account(Name='Test Customer Account');
        insert customerAccount;

        Order certifiedOrder = new Order(
            AccountId = customerAccount.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = pricebookId,
            Surgeon__c = certifiedSurgeon.Id
        );
        Order nonCertifiedOrder = new Order(
            AccountId = customerAccount.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = pricebookId,
            Surgeon__c = nonCertifiedSurgeon.Id
        );
        insert new List<Order>{certifiedOrder, nonCertifiedOrder};
    }

    @isTest
    static void testAddEvoVivaProduct_Certified() {
        Order certifiedOrder = [SELECT Id FROM Order WHERE Surgeon__r.LastName = 'Certified' LIMIT 1];
        PricebookEntry evoPbe = [SELECT Id FROM PricebookEntry WHERE Product2.Name = 'EVO Viva' LIMIT 1];

        Test.startTest();
        OrderItem oi = new OrderItem(OrderId = certifiedOrder.Id, PricebookEntryId = evoPbe.Id, Quantity = 1, UnitPrice = 1000);
        insert oi;
        Test.stopTest();

        Order resultOrder = [SELECT Contains_EVO_Viva_Product__c FROM Order WHERE Id = :certifiedOrder.Id];
        System.assertEquals(true, resultOrder.Contains_EVO_Viva_Product__c, 'Flag should be true after adding EVO Viva product');
    }

    @isTest
    static void testValidationFailure_NonCertified() {
        Order nonCertifiedOrder = [SELECT Id FROM Order WHERE Surgeon__r.LastName = 'NonCertified' LIMIT 1];
        PricebookEntry evoPbe = [SELECT Id FROM PricebookEntry WHERE Product2.Name = 'EVO Viva' LIMIT 1];

        Test.startTest();
        try {
            OrderItem oi = new OrderItem(OrderId = nonCertifiedOrder.Id, PricebookEntryId = evoPbe.Id, Quantity = 1, UnitPrice = 1000);
            insert oi;
            System.assert(false, 'DML should have failed for non-certified surgeon.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('The selected surgeon is not certified for the EVO Viva lens'), 'Error message should contain the validation error. Got: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAddThenRemoveEvoVivaProduct() {
        Order certifiedOrder = [SELECT Id FROM Order WHERE Surgeon__r.LastName = 'Certified' LIMIT 1];
        PricebookEntry evoPbe = [SELECT Id FROM PricebookEntry WHERE Product2.Name = 'EVO Viva' LIMIT 1];
        OrderItem oi = new OrderItem(OrderId = certifiedOrder.Id, PricebookEntryId = evoPbe.Id, Quantity = 1, UnitPrice = 1000);
        insert oi;

        Order resultOrder = [SELECT Contains_EVO_Viva_Product__c FROM Order WHERE Id = :certifiedOrder.Id];
        System.assertEquals(true, resultOrder.Contains_EVO_Viva_Product__c, 'Flag should be true before deletion');

        Test.startTest();
        delete oi;
        Test.stopTest();

        resultOrder = [SELECT Contains_EVO_Viva_Product__c FROM Order WHERE Id = :certifiedOrder.Id];
        System.assertEquals(false, resultOrder.Contains_EVO_Viva_Product__c, 'Flag should be false after removing EVO Viva product');
    }

    @isTest
    static void testAddNonEvoProduct() {
        Order nonCertifiedOrder = [SELECT Id, Contains_EVO_Viva_Product__c FROM Order WHERE Surgeon__r.LastName = 'NonCertified' LIMIT 1];
        PricebookEntry otherPbe = [SELECT Id FROM PricebookEntry WHERE Product2.Name = 'Other Lens' LIMIT 1];

        Test.startTest();
        OrderItem oi = new OrderItem(OrderId = nonCertifiedOrder.Id, PricebookEntryId = otherPbe.Id, Quantity = 1, UnitPrice = 500);
        insert oi;
        Test.stopTest();

        Order resultOrder = [SELECT Contains_EVO_Viva_Product__c FROM Order WHERE Id = :nonCertifiedOrder.Id];
        System.assertEquals(false, resultOrder.Contains_EVO_Viva_Product__c, 'Flag should remain false after adding a non-EVO product');
    }
}