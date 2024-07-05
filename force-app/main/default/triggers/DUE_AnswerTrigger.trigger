trigger DUE_AnswerTrigger on due__Diduenjoy_Answer__c (after insert, after update) {
	switch on Trigger.operationType {
        when AFTER_INSERT {
            DUE_AnswerTriggerHandler.afterInsert(Trigger.new);
        }
        when AFTER_UPDATE {
            
            DUE_AnswerTriggerHandler.afterUpdate(Trigger.new ,Trigger.oldMap);
        }
        when else {
            //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
        }
    }
}