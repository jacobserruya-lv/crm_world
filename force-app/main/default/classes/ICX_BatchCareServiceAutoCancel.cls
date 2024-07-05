/**
* @author Keman WU
* @date Creation 09/12/2021
* @Batch Apex
* @description auto cancellation for distant care service
*/
global class ICX_BatchCareServiceAutoCancel implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    public Set<ID> setIDCareToCancelInMyRepair = new Set<ID> ();
global Database.QueryLocator start(Database.BatchableContext bc) {
    
        return Database.getQueryLocator(
        'select id,TransactionId__c,ICONiCS_Status_Detail__c,IsAutoCancelled__c from CareService__c '+
        'where RecordType.DeveloperName =   \'DistantCareService\' AND '+        
        'ICONiCS_Status_Detail__c =\'Preliminary Quote Pending Validation\'  AND '+
        'Current_Status_Age__c > 29' );
}

global void execute(Database.BatchableContext bc, List<CareService__c> scope){
    List<CareService__c> lstCareToUpdate = new  List<CareService__c> ();
  
    for(CareService__c c : scope){
        c.ICONiCS_Status_Detail__c = 'Cancelled';
        c.IsAutoCancelled__c = true;
        lstCareToUpdate.add(c);
        if(c.TransactionId__c !=null)
        setIDCareToCancelInMyRepair.add(c.Id);
    
    }
    system.debug(lstCareToUpdate);
    system.debug('setIDCareToCancelInMyRepair ' +setIDCareToCancelInMyRepair.size());
   try{                      
       update lstCareToUpdate;
      
   }catch (DmlException e){
    System.debug('#### Auto Cancellation Careservice '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
   }
}
public void finish(Database.BatchableContext bc){    
    system.debug('final setIDCareToCancelInMyRepair'+setIDCareToCancelInMyRepair.size());
    if(setIDCareToCancelInMyRepair.size()>0 && !Test.isRunningTest())
    Database.executeBatch(new ICX_BatchCancelMyRepairOrder(setIDCareToCancelInMyRepair),1);
}


}