global with sharing class BL_ICON_Batch_Cache implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public String query;
	
	global BL_ICON_Batch_Cache() {
		query = 'select Id, RetailStoreId__c from Store__c  Where Status__c =\'Open\' AND LastOneDataKPIUpdate__c < TODAY';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('#### START - BL_ICON_Batch_Cache');
		System.debug('#### QUERY : ' + query);

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Store__c> storesToUpdate = new List<Store__c>();
        try{
            Datetime currentdate = System.now();
            for(Store__c s : (List<Store__c>) scope){
                
                try{
                    if(String.isnotBlank(s.RetailStoreId__c)){
                        s.tenKCount__c = getStoreFilterCount('is_10k', s.RetailStoreId__c);
                        s.potentialTenKCount__c = getStoreFilterCount('is_potential_10k', s.RetailStoreId__c);
                        s.tenKYTMCount__c = getStoreFilterCount('is_10k_this_year', s.RetailStoreId__c);
                        s.fiftyKCount__c = getStoreFilterCount('is_50k', s.RetailStoreId__c);
                        s.LastOneDataKPIUpdate__c = System.Today();
                        storesToUpdate.add(s);
                    }
                    
                    
                } catch(Exception e) {
                    System.debug('#### ' + e.getTypeName() + ' Exception:' + e.getMessage() + ' ' + e.getStackTraceString());
                }
            }
            if (storesToUpdate.size() > 0){
                Database.update(storesToUpdate, false);
            }
            while(System.now()< currentdate.addSeconds(5) ){}
        } catch(Exception e) {
            System.debug('#### ' + e.getTypeName() + ' Exception:' + e.getMessage() + ' ' + e.getStackTraceString());
        }
        
    }
    
    global void finish(Database.BatchableContext CD){}

    global Integer getStoreFilterCount(String filter, String storeCode){
        Map<String, Object> filter1 =  new map<String, object>{
            'left'=> 'default_store',
            'operator' => '=',
            'right' => storeCode
        };
            
        Map<String, Object> filter2 =  new map<String, object>{
            'left'=> filter,
            'operator' => '=',
            'right' => true
        };
            
        Map<String, Object> filters =  new map<String, object>{
            'filters'=> new list<Map<String, Object>>{filter1, filter2}
        };

        return BL_ICON_OneData_Helper.getCount(JSON.serialize(filters));
    }
	
}