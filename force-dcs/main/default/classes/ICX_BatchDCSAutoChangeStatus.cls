/**
* @author Keman WU
* @date Creation 20/09/2022
* @Batch Apex
* @description auto change status for distant care service
*/

    global class ICX_BatchDCSAutoChangeStatus implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
        public Set<ID> setIDCareToChangeInMyRepair = new Set<ID> ();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
            return Database.getQueryLocator(
            'select id,TransactionId__c,ICONiCS_Status_Detail__c,Payment_Review_Reason__c,IsAutoCancelled__c,Cancellation_Reason__c from CareService__c '+
            'where RecordType.DeveloperName =   \'DistantCareService\' AND '+        
            '((ICONiCS_Status_Detail__c =\'Preliminary Quote Pending Validation\' AND Quotation_expiration_date__c < TODAY ) OR '+
            '(ICONiCS_Status_Detail__c =\'Preliminary Quote Validated\' AND Shipping_label_expiration_date__c  < TODAY ) OR ' +
            '(ICONiCS_Status_Detail__c =\'Confirm Address\' AND Confirm_Address_Expiration_Date__c < TODAY ) OR '+
            '(ICONiCS_Status_Detail__c =\'Waiting for Payment\' AND Current_Status_Age__c > 90 ) OR '+
            '(ICONiCS_Status_Detail__c =\'Payment Initiated\' AND PBL_Expiration_Date__c  < TODAY ))' );
    }
    
    global void execute(Database.BatchableContext bc, List<CareService__c> scope){
        List<CareService__c> lstCareToUpdate = new  List<CareService__c> ();
        
        for(CareService__c c : scope){
            //if confirmation Adresse expired, pass to Payment Received
            if(c.ICONiCS_Status_Detail__c =='Confirm Address'){
                c.ICONiCS_Status_Detail__c = 'Payment Received'; 
                c.MYLV_Care_Status__c = 'shipping_in_preparation'; 
                //c.MyRepairStatus__c = 'receivedAndAcceptedInStore';  
                c.Last_ICONiCS_Status_Changed_Date__c = system.today(); 
                c.Last_MYLV_Care_Status_Changed_Date__c = system.today(); 
                //c.Last_MyRepair_Status_Changed_Date__c = system.today();           
                     
            //if PBL expired, pass to Payment Review   
            }else if(c.ICONiCS_Status_Detail__c =='Payment Initiated'){
                c.ICONiCS_Status_Detail__c = 'Payment Review';
                c.MYLV_Care_Status__c = 'payment_contact'; 
                c.Payment_Review_Reason__c = 'Expired PBL';
                c.Last_ICONiCS_Status_Changed_Date__c = system.today(); 
                c.Last_MYLV_Care_Status_Changed_Date__c = system.today();

            //if PBL never initiated, pass to Payment Review        
            }else if(c.ICONiCS_Status_Detail__c =='Waiting for Payment'){
                c.ICONiCS_Status_Detail__c = 'Payment Review';
                c.MYLV_Care_Status__c = 'payment_contact'; 
                c.Payment_Review_Reason__c = 'Payment Never Initiated';
                c.Last_ICONiCS_Status_Changed_Date__c = system.today(); 
                c.Last_MYLV_Care_Status_Changed_Date__c = system.today();       
            }else{

            //auto cancel
            if(c.ICONiCS_Status_Detail__c =='Preliminary Quote Pending Validation')
                c.Cancellation_Reason__c = 'Preliminary Assessment expired';        
            if(c.ICONiCS_Status_Detail__c =='Preliminary Quote Validated')
                c.Cancellation_Reason__c = 'Product never shipped';
        
                c.ICONiCS_Status_Detail__c = 'Cancelled';
                c.IsAutoCancelled__c = true;             
            if(c.TransactionId__c !=null)
            setIDCareToChangeInMyRepair.add(c.Id);
            }
            lstCareToUpdate.add(c);
            
    
        system.debug(lstCareToUpdate);
        system.debug('setIDCareToChangeInMyRepair ' +setIDCareToChangeInMyRepair.size());
        try{                      
            update lstCareToUpdate;
            
        }catch (DmlException e){
        System.debug('#### Auto Change Status Careservice '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
        }
    }
    
    public void finish(Database.BatchableContext bc){    
        system.debug('final setIDCareToChangeInMyRepair'+setIDCareToChangeInMyRepair.size());
        if(setIDCareToChangeInMyRepair.size()>0 && !Test.isRunningTest())
        Database.executeBatch(new ICX_BatchChangeMyRepairOrder(setIDCareToChangeInMyRepair),1);
    }
    
    
    }