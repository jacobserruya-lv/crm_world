/**
    @Author : 	ouramdane.aouci
    Desc 	:   Client 360 - SF - Data Catch up in SF of clients whose DreamId is missing  (for a given period)
    			For clients without country code, retrieve the store code if exist.
    			Fill in the TECH_IntegrationManager__c Object for each Account to start the sending process to C360
    V 1.0 	:   26/09/2023
*/
global class TR_BatchC360DataCatchUp implements Database.Batchable<sObject>, Database.Stateful {
    
    private String myQuery;
    private final Transverse_Batchs_Setup__c setting;
    global DateTime createdAfter;
    private Integer clientCatchUpLimit = 0;
    private String clauseWhere;
    
    global TR_BatchC360DataCatchUp(){
        setting = Transverse_Batchs_Setup__c.getInstance('Batch_C360_Data_Catch_Up');
        //Dynamic data
        createdAfter = setting.Created_After__c;
        clientCatchUpLimit =  integer.valueOf(setting.Limit__c);
        clauseWhere =  setting.Where_Clause__c;

        myQuery = 'SELECT Id, CreatedDate FROM Account WHERE ' + clauseWhere + 
            ' AND CreatedDate > :createdAfter ORDER BY createdDate ASC LIMIT :clientCatchUpLimit';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(myQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){
        try{
            //Preparing the TECH_IntegrationManager__c list to insert
            List<TECH_IntegrationManager__c> techIntegMngrList = new List<TECH_IntegrationManager__c>();
            
            //Process each Account line (current Batch of records)
            for(Account acc : scope){
                //Prepare the TECH_IntegrationManager__c Object
                TECH_IntegrationManager__c techIntegMngr = new TECH_IntegrationManager__c();

                techIntegMngr.Object_Name__c = 'ACCOUNT';
                techIntegMngr.AccountId__c = acc.Id;
                techIntegMngr.Trigger_Event__c = 'CREATE';
                techIntegMngr.Error__c = true;
                techIntegMngr.Operation__c = 'CREATE';
                techIntegMngr.Object_Id__c = acc.Id;
                techIntegMngr.StartTime__c = System.now();
                
                //Add it to this list
                techIntegMngrList.add(techIntegMngr);
                
                //Get the last treated Account Created Date
                //To update the start Date (CreatedDate) for the next process
                if(acc.CreatedDate > createdAfter){
                    createdAfter = acc.CreatedDate;
                }
            }
            
            if(techIntegMngrList.size() > 0){
                //INSERT techIntegMngrList;
                Database.insert(techIntegMngrList, false); //Default param = true (allorNone)
            }
            
		} Catch(Exception e){
            System.debug('Err: ' + e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext bc){
        //Update the setting instance <Batch_C360_Data_Catch_Up>
        setting.Created_After__c = createdAfter;
        UPDATE setting;
    }
    
}