trigger OrderShippingTrigger on OrderShipping__c (before insert, before update, after insert, after update, after delete, after undelete) {
    icx_OrderShippingTriggerHandler icx_handler = new icx_OrderShippingTriggerHandler(Trigger.isExecuting, Trigger.size);
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            icx_handler.beforeInsert(Trigger.new, Trigger.newMap);
        }
        when BEFORE_UPDATE {
            icx_handler.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
        // when BEFORE_DELETE {
        //     // handler.beforeDelete(Trigger.old, Trigger.oldMap);
        // }
        when AFTER_INSERT {
            icx_handler.afterInsert(Trigger.new, Trigger.newMap);
        }
        when AFTER_UPDATE {
            system.debug('after update');
            icx_handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
        when AFTER_DELETE {
            icx_handler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            icx_handler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }
}