/**
    Description: Batch used in the developper console in order to create Bachlog oBject
    Created for: SOW: IC007 ICON project
    Create date: 03/06/2014

    Update History
    --------------
    Create date: Juin 2014  HCH
    
    
    Issues / TODOs
    --------------
*/

   global class IC_BatchClientCleanUp implements Database.Batchable<sObject>{
      
    public String query;
//    Integer isProspectOrAndClient = Integer.valueOf((Decimal)ICONSettings__c.getOrgDefaults().get('ProspectClientPurge__c'));
    Integer accountPurgeLimit = Integer.valueOf((Decimal)ICONSettings__c.getOrgDefaults().get('accountPurgeLimit__c'));
    date DateLimitOfLastTran = Date.today().addMonths(-accountPurgeLimit);
    global IC_BatchClientCleanUp(){
        query = 'SELECT Id,DREAMID__c, Has_Private_Data__c, IsProspect__pc FROM Account Where LastTrans__pc < :DateLimitOfLastTran AND  Date_Identity__pc=null';  
       
       /* 
        if(isProspectOrAndClient == 0)
          query += ' AND IsProspect__pc = true';
        else if (isProspectOrAndClient == 1)
          query += ' AND IsProspect__pc = false';  */
        
     }
        
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - BatchLogInsert');
        System.debug('#### query : '+query);
        return Database.getQueryLocator(query);   
    } 
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
        
        Integer isProspectOrAndClient = Integer.valueOf((Decimal)ICONSettings__c.getOrgDefaults().get('ProspectClientPurge__c'));
        
        List<CleanUpLog__c> BatchLogTocreate = new List<CleanUpLog__c>();
        List<Account> lstAccTemp = new List<Account>();
        List<Account> lstAccFinal = new List<Account>();
        
        try{
            for(sObject o:scope){ 
                Account acc = (Account)o;
                lstAccTemp.add(acc); 
            }  
            
            if (isProspectOrAndClient == 0) {
                if (lstAccTemp != null && lstAccTemp.size() > 0) {
                    for (Account act : lstAccTemp) {
                        if(act.IsProspect__pc){
                            lstAccFinal.add(act); 
                        }
                    }
                    
                }  
                
            } else if (isProspectOrAndClient == 1) {
                if (lstAccTemp != null && lstAccTemp.size() > 0) {
                    for (Account act : lstAccTemp) {
                        if(!act.IsProspect__pc){
                            lstAccFinal.add(act); 
                        }
                    }                   
                }  
            }
            
            lstAccTemp.clear();
            lstAccTemp.addAll(lstAccFinal);
            lstAccFinal.clear();

             
            if (lstAccTemp != null && lstAccTemp.size() > 0) {
                for (Account act : lstAccTemp) {
                    if(!act.Has_Private_Data__c){
                        lstAccFinal.add(act); 
                    }
                }
                
            } 
            
            // Deuxieme partie Where
            List<Program__c> lstIdProg = new List<Program__c>();
            lstIdProg = [Select AccountId__c From Program__c]; 
            Set<ID> buffAccountID = new Set<ID>();
            
            for (Program__c prg : lstIdProg) {
                buffAccountID.add(prg.AccountId__c);
            }
                
            for (Account acc : lstAccFinal) {
                if(!buffAccountID.contains(acc.ID)) {
                    CleanUpLog__c BL = new CleanUpLog__c(IdSFDCAccount__c = acc.Id, DreamIdClient__c = acc.DREAMID__c);
                    BatchLogTocreate.add(BL);  
                }
            }
            
            insert BatchLogTocreate; 
       
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }       
    }
    
    global void finish(Database.BatchableContext CD){}
    
}