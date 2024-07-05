/***************************************************************************************************
* @File Name          : TR_PurgeEmailMessage.cls
* @Description        : This class was created for the purge of EMAIL MESSAGES 
* @Author             : frank.peyo.basso.ext@louisvuitton.com
* @Group              : VO2
* @Last Modified By   : frank.peyo.basso.ext@louisvuitton.com
* @Last Modified On   : 11-01-2023  
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       02-11-2022         frank.peyo.basso.ext@louisvuitton.com     Initial Version

To run the batch:
TR_PurgeEmailMessage bscl = new TR_PurgeEmailMessage();
Database.executeBatch(bscl, 500); */
global   class TR_PurgeEmailMessage implements Database.Batchable<sObject>, Database.Stateful {
     String query;
    String Idcomptemail;
 global TR_PurgeEmailMessage() {
      Idcomptemail='005i0000008NEdWAAW';
     
        query = 'select id from EmailMessage where RelatedToId = null and createddate < LAST_MONTH   and CreatedById =:Idcomptemail';
      
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(scope.size() > 0){
            System.debug(scope.Size());
            delete scope;
            Database.emptyRecycleBin(scope);
            
          
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}