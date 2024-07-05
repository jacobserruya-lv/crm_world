public with sharing class icx_OrderShippingTriggerHandler {
    private boolean triggerIsExecuting;
    private integer triggerSize;

    public icx_OrderShippingTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
    }

    public void beforeInsert(List<OrderShipping__c> newList, Map<id, OrderShipping__c> newMap) {
        updateIconicsStatus(newList, null);
    }

    public void beforeUpdate(List<OrderShipping__c> newList, Map<id, OrderShipping__c> newMap,List<OrderShipping__c> oldList, Map<id, OrderShipping__c> oldMap) {
        updateIconicsStatus(newList, oldMap);
    }

    public void afterInsert(List<OrderShipping__c> newList, Map<id, OrderShipping__c> newMap) {
        updateOrderStatus(newList, newMap, null, null);
    }

    public void afterUpdate(List<OrderShipping__c> newList, Map<id, OrderShipping__c> newMap,List<OrderShipping__c> oldList, Map<id, OrderShipping__c> oldMap) {
        updateOrderStatus(newList, newMap, oldList, oldMap);
    }

    public void afterDelete(List<OrderShipping__c> oldList, Map<id, OrderShipping__c> oldMap) {
        updateOrderStatus(null, null, oldList, oldMap);
    }

    public void afterUndelete(List<OrderShipping__c> newList, Map<id, OrderShipping__c> newMap) {
        updateOrderStatus(newList, newMap, null, null);
    }

    // 
    public void updateIconicsStatus(List<OrderShipping__c> newList, Map<id, OrderShipping__c> oldMap) {
        for(OrderShipping__c orderShipping: newList) {
            // IF criterias updated
            ICX_OrderShippingStatusService.setIconicsOrderShippingStatus(orderShipping);
        }
    }

    public void updateOrderStatus(List<OrderShipping__c> newList, Map<id, OrderShipping__c> newMap,List<OrderShipping__c> oldList, Map<id, OrderShipping__c> oldMap) {
        // 
        Set<Id> orderToUpd = new Set<Id>();

        // In case of "After Insert/Update/Undelete
        If (newList != null) {
            for(OrderShipping__c orderShipping: newList) {
                if ( newList == null || oldList == null || orderShipping.statusIconics__c != oldMap?.get(orderShipping.Id).statusIconics__c || orderShipping.status__c != oldMap?.get(orderShipping.Id).status__c) {
                    orderToUpd.add(orderShipping.order__c);
                }
            }
        }
        // In case of "After Delete"
        else if (oldList != null) {
            for(OrderShipping__c orderShipping: oldList) {
                orderToUpd.add(orderShipping.order__c);
            }
        }


        if (orderToUpd.size() > 0) {
            ICX_OrderHelper.updateOrderStatusIconics(new List<Id>(orderToUpd));
        }

    }
}