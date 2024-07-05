/***************************************************************************************************
* @File Name          : TR_PurgeDeletedRecordLog.cls
* @Description        : This class was created for the purge of record logs 
* @Author             : frank.peyo.basso.ext@louisvuitton.com
* @Group              : VO2
* @Last Modified By   : frank.peyo.basso.ext@louisvuitton.com
* @Last Modified On   : 02-11-2022  
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       02-11-2022         frank.peyo.basso.ext@louisvuitton.com     Initial Version

To run the batch:
TR_BatchCampaignHistoryPurge bscl = new TR_BatchCampaignHistoryPurge();
Database.executeBatch(bscl, 500);
*****************************************************************************************************/
global  class TR_PurgeDeletedRecordLog implements Database.Batchable<sObject>, Database.Stateful {
 String query;
    DateTime dt;
    Integer limitBatch;
    Transverse_Batchs_Setup__c setting;
    
    global TR_PurgeDeletedRecordLog() {
        setting = Transverse_Batchs_Setup__c.getAll().get('Batch Deleted record logs');
        dt = DateTime.now().addDays(-(integer.valueOf(setting.Created_Before_Days__c)));
        query = 'SELECT Id FROM Deleted_record_log__c  WHERE CreatedDate < :dt';
        limitBatch = integer.valueOf(setting.Limit__c);
        if(limitBatch != null){
            query = query + ' Limit :limitBatch';
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(scope.size() > 0){
            System.debug(scope.Size());
            delete scope;
            Database.emptyRecycleBin(scope);
            
            setting.job_id__c = BC.getJobId();
            update setting;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}