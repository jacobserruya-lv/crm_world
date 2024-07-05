/***************************************************************************************************
* @File Name          : TR_BatchIntegrationManagerDeletion.cls
* @Description        : This class was created for the C360 DELETE TechRecords
* @Author             : Imad.alsidchikh@vo2-consultant.com
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 01-11-2022  
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       01-11-2022         Imad.alsidchikh@vo2-group.com     Initial Version

To run the batch:
TR_BatchIntegrationManagerDeletion bscl = new TR_BatchIntegrationManagerDeletion();
Database.executeBatch(bscl, 500);
*****************************************************************************************************/
global class TR_BatchIntegrationManagerDeletion  implements Database.Batchable<sObject>, Database.Stateful{
    String query;
    DateTime dt;
    global TR_BatchIntegrationManagerDeletion() {
        TR_Integration_Manager_Setting__c setting = TR_Integration_Manager_Setting__c.getAll().get('Batch_Deletion_Setup');
        dt = DateTime.now().addDays(-(integer.valueOf(setting.Created_Before_Days__c)));
        query = 'SELECT Id FROM TECH_IntegrationManager__c WHERE CreatedDate < :dt';
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