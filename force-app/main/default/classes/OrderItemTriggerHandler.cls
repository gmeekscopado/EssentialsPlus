public class OrderItemTriggerHandler {
    public static void handleAfterInsert(List<OrderItem> newItems) {
        updateContainsEvoVivaProduct(newItems);
    }

    public static void handleAfterDelete(List<OrderItem> oldItems) {
        updateContainsEvoVivaProduct(oldItems);
    }

    private static void updateContainsEvoVivaProduct(List<OrderItem> items) {
        Set<Id> orderIds = new Set<Id>();
        for (OrderItem item : items) {
            orderIds.add(item.OrderId);
        }

        if (orderIds.isEmpty()) {
            return;
        }

        Map<Id, Order> ordersToUpdate = new Map<Id, Order>();
        for(Id orderId : orderIds){
            ordersToUpdate.put(orderId, new Order(Id = orderId, Contains_EVO_Viva_Product__c = false));
        }

        List<OrderItem> evoVivaItems = [
            SELECT OrderId
            FROM OrderItem
            WHERE OrderId IN :orderIds
            AND PricebookEntry.Product2.Name = 'EVO Viva'
        ];

        for (OrderItem item : evoVivaItems) {
            ordersToUpdate.get(item.OrderId).Contains_EVO_Viva_Product__c = true;
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate.values();
        }
    }
}