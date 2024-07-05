trigger OrderTrigger on Order__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {

        switch on Trigger.operationType {
            when AFTER_UPDATE{
               ICON_Todos_Helper.afterUpdateOrderXstore(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            }
            when else {
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
}