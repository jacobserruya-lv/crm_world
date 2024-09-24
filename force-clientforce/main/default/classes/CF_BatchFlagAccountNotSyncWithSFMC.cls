/**
	@Author :	ouramdane.aouci
    Desc    : 	Flag Accounts Not Synced with SFMC in new field "Exclude SFMC".
				Pre-filter client records based on specific criteria, .. (CF-370)
				This ensures that only relevant client records are shared for SFMC broadcast email campaigns, instead of the whole database.
    V 1.0   : 	10/04/2024
	V 2.0   : 	22/08/2024 : Set a flag (Exclude_SFMC__c=true) according to certain criteria (CF-1494)
*/
global class CF_BatchFlagAccountNotSyncWithSFMC implements Database.Batchable<sObject>, Database.Stateful {
    
    private final String myQuery;
    private final Transverse_Batchs_Setup__c setting;
    global DateTime createdAfter;
    private Integer lotLimit = 0;
    
    global CF_BatchFlagAccountNotSyncWithSFMC(){
        setting = Transverse_Batchs_Setup__c.getInstance('Batch_C360_Data_Catch_Up');
        //Dynamic data
        createdAfter = setting.Created_After__c;
        lotLimit =  integer.valueOf(setting.Limit__c);
        
        myQuery = 'SELECT Id, ParallelMarket_Status__pc, Anonymization_date__c, Exclude_SFMC__c, createdDate, ' +
            	'(SELECT Id FROM Social_Media_Identifiers__r WHERE Opt_In__c = true LIMIT 1) ' +
				'FROM Account ' +
            	'WHERE ((ParallelMarket_Status__pc IN (\'Blue\', \'Red\') OR Anonymization_date__c != null ' +
            	'OR (Can_Be_Contacted_By_Email__pc = false AND Can_Be_Contacted_By_SMS__pc = false ' +
            	'AND Can_Be_Contacted_By_Phone__pc = false AND Can_Be_Contacted_By_Mail__pc = false ' +
            	'AND Can_Be_Contacted_By_LVApp__c = false)) ' +
            	'AND (CreatedDate > :createdAfter AND Exclude_SFMC__c = false)) ORDER BY createdDate ASC LIMIT :lotLimit';
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('=> START - CF_BatchFlagAccountNotSyncWithSFMC ..');
        system.debug('=> myQuery: ' + myQuery);
        return Database.getQueryLocator(myQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){
        system.debug('Scope: ' + scope.size());
        
        try{
            Map<Id, Account> accountMap = new Map<Id, Account>(scope);
            
            for(Account acc : scope){
                //Check the client contactability through SMI
                if(acc.ParallelMarket_Status__pc != 'Blue' && acc.ParallelMarket_Status__pc != 'Red' && acc.Anonymization_date__c == null){

                    if(acc.Social_Media_Identifiers__r.size() > 0){
                        //Client contactable by at least one SMI, therefore, he will not be excluded
                        accountMap.remove(acc.Id);
                	}
                }
                
                if(acc.CreatedDate > createdAfter){
                	createdAfter = acc.CreatedDate;
                }
            }

            //Which Account will be flagged
			if(accountMap.size() > 0){
                System.debug('--------------------- Put a Flag ---------------------');
                System.debug('AccMap Size : ' + accountMap.size());
                List<Account> accountList = accountMap.values();
                for(Account acct : accountList){
					acct.Exclude_SFMC__c = true;   //Account will be excluded
				}
            
				Database.update(accountList, false); //Default param = true (allorNone)
			}
           
        } catch(Exception e) {
            System.debug('Flag Acc=> ' + e.getTypeName()+' Exception: '+ e.getMessage() +' '+ e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext bc){
        //Update the setting instance <Batch_C360_Data_Catch_Up>
        setting.Created_After__c = createdAfter;
        UPDATE setting;
    }
}