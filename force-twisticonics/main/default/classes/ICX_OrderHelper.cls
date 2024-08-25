public with sharing class ICX_OrderHelper {
    /**
     * Determine if wether or not the method can be executed as a @future method
     */
    public static void updateOrderStatusIconics(List<Id> ordersId) {
        if (System.isFuture() || System.isBatch()) {
            system.debug('JGU-ICX_OrderHelper.updateOrderStatusIconics => synchronous');
            updateOrderStatusIconicsSynchronous(ordersId);
        }
        else {
            system.debug('JGU-ICX_OrderHelper.updateOrderStatusIconics => @future');
            updateOrderStatusIconicsFuture(ordersId);
        }
    }
    
    @future
    private static void updateOrderStatusIconicsFuture(List<Id> ordersId) {
        updateOrderStatusIconicsSynchronous(ordersId);
    }
    
    /*
    ** Calculate the Order Iconics Status according to the Orders Shippings Iconics Status
    **
    */
    private static void updateOrderStatusIconicsSynchronous(List<Id> ordersId) {
        Integer nbCancel = 0;
        Integer nbFulfilled = 0;
        Integer nbPending = 0;
        Integer nbPendingPayment = 0;
        Integer nbOthers = 0;
        String newOrderStatusIconics;
        Map<Order__c, List<OrderShipping__c>> orderShippingsByOrder = new Map<Order__c, List<OrderShipping__c>>();
        Map<Id, Order__c> orderById = new Map<Id, Order__c>();
        Order__c key;
        List<Order__c> ordersToUpdate = new List<Order__c>();
        
        // Retrieve OrderShipping__c.statusIconics__c
        List<OrderShipping__c> orderShippings = [Select Id, status__c, Order__c, Order__r.Id, Order__r.StatusIconics__c From OrderShipping__c Where Order__c = :ordersId ];
        
        // Create a Map<Id, Order__c>
        // Create a Map<Order__c, List<OrderShipping__c>>
        for(OrderShipping__c orderShipping: orderShippings) {

            if (!orderById.containsKey(orderShipping.order__r.Id)) {
                key =  new Order__c(
                    Id = orderShipping.Order__r.Id,
                    StatusIconics__c = orderShipping.Order__r.StatusIconics__c);

                orderById.put(orderShipping.order__r.Id, key);
            }
            else {
                key = orderById.get(orderShipping.order__r.Id);
            }

            if (!orderShippingsByOrder.containsKey(key)) {
                orderShippingsByOrder.put(key, new List<OrderShipping__c>());
            }
            orderShippingsByOrder.get(key).add(orderShipping);
        }

        // For Each Order
        for (Order__c orderKey: orderShippingsByOrder.keySet()) {
            nbCancel = 0;
            nbFulfilled = 0;
            nbPending = 0;
            nbPendingPayment = 0;
            nbOthers = 0;
            // For each Order Shipping
            for(OrderShipping__c orderShipping: orderShippingsByOrder.get(orderKey)) {
                if(orderShipping.status__c == 'fulfilled') {
                    nbFulfilled++;
                }
                else if(orderShipping.status__c == 'cancelled') {
                    nbCancel++;
                }                
                else if(orderShipping.status__c == 'pending') {
                    nbPending++;
                }
                else if(orderShipping.status__c == 'pending_payment') {
                    nbPendingPayment++;
                }
                else {
                    nbOthers++;
                }
            }
            // What is the Order Iconics Status ?
            if (nbCancel > 0 && nbFulfilled == 0 && nbOthers == 0 && nbPending == 0 && nbPendingPayment == 0) {
                newOrderStatusIconics = 'Cancelled';
            }
            else if (nbCancel >= 0 && nbFulfilled > 0 && nbOthers == 0 && nbPending == 0 && nbPendingPayment == 0) {
                newOrderStatusIconics = 'Finalized';
            }
            else if (nbPending > 0 || nbPendingPayment > 0) {
                newOrderStatusIconics = 'Pending action';
            }            
            else if (nbOthers > 0) {
                newOrderStatusIconics = 'In Progress';
            }
            
            // If the Iconics Status changes.
            if (newOrderStatusIconics != orderKey.statusIconics__c) {
                orderKey.statusIconics__c = newOrderStatusIconics;
                ordersToUpdate.add(orderKey);
            }
        }

        if (ordersToUpdate.size() > 0) {
            update ordersToUpdate;
        }

    }
}