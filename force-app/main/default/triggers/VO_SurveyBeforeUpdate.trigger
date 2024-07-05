trigger VO_SurveyBeforeUpdate on VO_Survey__c (before update) {

      //add udpate TechStore_delivery__c
     VO_Survey.UpdateTechStoreDelivery(Trigger.new);
    VO_Survey.updateOwnerName(Trigger.new);
    
}