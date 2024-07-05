/**
    @Author : ouramdane.aouci
    V 1.0 :   08/06/2023
*/
trigger Diduenjoy_FeedbackTrigger on due__Diduenjoy_Feedback__c (after update) {
    
    if(Trigger.isUpdate && Trigger.isAfter){
        Diduenjoy_FeedbackTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}