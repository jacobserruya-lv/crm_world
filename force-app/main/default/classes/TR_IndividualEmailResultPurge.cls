/***************************************************************************************************
* @File Name          : TR_IndividualEmailResultPurge.cls
* @Description        : This class was created for the C360 DELETE TechRecords
* @Author             : hamza.bouzid.ext@louisvuitton.com
* @Group              : VO2
* @Last Modified By   : hamza.bouzid.ext@louisvuitton.com
* @Last Modified On   : 06-10-2022  
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       06-10-2022         hamza.bouzid.ext@louisvuitton.com     Initial Version

To run the batch:
TR_BatchCampaignHistoryPurge bscl = new TR_BatchCampaignHistoryPurge();
Database.executeBatch(bscl, 500);
*****************************************************************************************************/
global class TR_IndividualEmailResultPurge  implements Database.Batchable<sObject>, Database.Stateful{
    String query;
    DateTime dt;
    Integer limitBatch;
    Transverse_Batchs_Setup__c setting;
    
    global TR_IndividualEmailResultPurge() {
        setting = Transverse_Batchs_Setup__c.getAll().get('Batch Indiv Email Result Purge Setup');
        dt = DateTime.now().addDays(-(integer.valueOf(setting.Created_Before_Days__c)));
        query = 'SELECT Id FROM et4ae5__IndividualEmailResult__c  WHERE CreatedDate < :dt';
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
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}