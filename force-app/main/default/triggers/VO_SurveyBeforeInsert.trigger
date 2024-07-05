/*
Trigger Survey before insert
Created by BW
Creation date : 01/10/2015
*/

trigger VO_SurveyBeforeInsert on VO_Survey__c (before insert) {

    // Update the account Id and the store Id depending on the Dream Id and the RMS store code
    VO_Survey.UpdateClientAndStoreId(Trigger.new);  
    
    // Evaluating the Assigned To value
    VO_Survey.UpdateAssignedTo(Trigger.new);
    
    //add udpate TechStore_delivery__c
    VO_Survey.UpdateTechStoreDelivery(Trigger.new);
    
    VO_Survey.updateOwnerName(Trigger.new);
    
    VO_Survey.updateGlobalScore(Trigger.new);
}