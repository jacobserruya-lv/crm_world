/**
* @author Keman WU
* @date Creation 14/12/2021
* @Batch Apex
* @description cancel duplicate distant care service
*/
global class ICX_BatchDuplicateCareService implements Database.Batchable<sObject>,Database.Stateful{
   
global Database.QueryLocator start(Database.BatchableContext bc) {
    
        return Database.getQueryLocator(
        'select id,Description__c,Client__c,CreatedDate,StoreRetailCode__c from CareService__c '+
        'where RecordType.DeveloperName =   \'DistantCareService\' AND '+
        'ICONiCS_Status_Detail__c =\'New Request\' AND '+
        'Origin__c =\'LV App-Form\' order by createdDate desc ');
}

global void execute(Database.BatchableContext bc, List<CareService__c> scope){
    List<CareService__c> lstCareToCancel = new  List<CareService__c> ();
    Set<String> setClient = new Set<String> ();
    Set<String> setCreatedDate = new Set<String> ();
    Set<String> setStoreCode = new Set<String> ();
    Set<String> setDescription = new Set<String> ();  
   
    
    for(CareService__c c : scope){   
     
      Boolean sameClient = false;
      Boolean sameDate = false;
      Boolean sameStore = false;
      Boolean sameDescription = false;
            if(!setClient.contains(c.client__c)) 
                setClient.add(c.client__c);
            else
                sameClient = true;

            if(!setCreatedDate.contains(c.createdDate.format('yyyy-MM-dd')))
                setCreatedDate.add(c.createdDate.format('yyyy-MM-dd'));
            else 
                sameDate = true;

            if(!setStoreCode.contains(c.StoreRetailCode__c))
                setStoreCode.add(c.StoreRetailCode__c);
            else 
                sameStore = true;

            if(!setDescription.contains(c.Description__c))
                setDescription.add(c.Description__c); 
            else  
                sameDescription = true;

      
            if(sameClient && sameDate && sameStore && sameDescription){
                c.ICONiCS_Status_Detail__c = 'Cancelled';
                c.Cancellation_Reason__c = 'Cancelled automatically by system';  
                c.IsAutoCancelled__c = true; 
                lstCareToCancel.add(c);
            }
           
               

    }
    system.debug('lstCareToCancel: ' +lstCareToCancel);
  
   try{                      
       update lstCareToCancel;
      
   }catch (DmlException e){
    System.debug('#### Auto Cancellation Careservice '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
   }
}
public void finish(Database.BatchableContext bc){    
    
}


}