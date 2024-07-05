/**
* @description       : 
* @author            : peyo basso
* @group             : 
* @last modified on  : 05-09-2022
* @last modified by  : PEYO BASSO
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   05-09-2022   peyo basso                           Initial Version 
* 1.1   20-09-2022   Imad ALSID                           add custom setting   

To run the batch:
TR_CleanParallelMarket_Batch bscl = new TR_CleanParallelMarket_Batch();
Database.executeBatch(bscl, 500);
**/
global class TR_CleanParallelMarket_Batch implements Database.Batchable<sObject>{
    String query;
    DateTime dt;
    Integer limitBatch;
    Transverse_Batchs_Setup__c setting;
    global TR_CleanParallelMarket_Batch(){
        setting = Transverse_Batchs_Setup__c.getAll().get('Batch Parallel Market Setup');
        dt = DateTime.now().addMonths(-(integer.valueOf(setting.Created_Before_Months__c)));
        limitBatch = integer.valueOf(setting.Limit__c);
        query ='SELECT ID,ParallelMarket_StatusDate__pc,ParallelMarket_Status__pc FROM Account  WHERE ParallelMarket_StatusDate__pc <=: dt and ParallelMarket_Status__pc !=\'\'';
        if(limitBatch != null){
            query = query + ' Limit :limitBatch';
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);	
    }
    
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        List<Account> lstClients = new List<Account>(); 
        System.debug('scope size******'+scope.size());
        if(scope.size()>0){
            for(Account client :scope){
                if( client.ParallelMarket_StatusDate__pc !=null && client.ParallelMarket_StatusDate__pc <= dt){
                    System.debug('ParallelMarket_StatusDate '+ client.ParallelMarket_StatusDate__pc);
                    if(client.ParallelMarket_StatusDate__pc!=null){
                        client.ParallelMarket_StatusDate__pc=Null;
                    }
                    if(client.ParallelMarket_Status__pc!=null){
                        client.ParallelMarket_Status__pc=null;
                    }
                    lstClients.Add(client);
                }
            }
            System.debug('ParallelMarket_StatusDate '+ lstClients.Size());
            if(lstClients.size()>0){
                Database.SaveResult[] srList = Database.update(lstClients, false);
                system.debug(srList);
            } 
        }
    }
    global void finish(Database.BatchableContext BC){ 
        
    }
    
}