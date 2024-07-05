global  class BatchStoreTimeZone implements Database.Batchable<sObject>,Database.AllowsCallouts {

       
    public String query;
    private final String GOOGLE_API_KEY {
        get {
            List<IconSetting__mdt> iconsettings = [Select Text__c From IconSetting__mdt Where QualifiedApiName ='TimeZone_Google_API_KEY'];
                if(iconsettings.size() > 0){
                    return  iconsettings[0].Text__c;
                }
                return null;
            }
        set;
    }
    
    global BatchStoreTimeZone(){
        query = ' Select Id, Time_Zone_Id__c, StoreLocation__Latitude__s, StoreLocation__Longitude__s, RetailStoreId__c '+
        '  From Store__c where Time_Zone_Id__c = null AND StoreLocation__Latitude__s != null  ';
    }
        
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - BatchStoreTimeZone');
        System.debug('#### query : ' + query);
        return Database.getQueryLocator(query);   
    } 
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
        try{
            
            if(scope.size() > 0){
                this.setTimeZone((List<Store__c>) scope);
            }
            
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }       
    }
    
    global void finish(Database.BatchableContext CD){
    //     Datetime sysTime = System.now();

    //    // this would increase the time to 1 hour after current time
    //     sysTime = sysTime.addHours(1);

    //     String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
	// 	String strJobName = 'AppointmentTransactionSyncJOB-' + sysTime.getTime();
		// System.schedule(strJobName, chron_exp, new IM_SchedulerCareServiceStatusFlow());
    }

    private void setTimeZone(List<Store__c> stores){
        system.debug(stores.size());
        Map<String, String> mapStoreCodeTimeZone = new Map<String, String>();
        for(Store__c s : stores){
            // Instantiate a new http object
            Http h = new Http();

            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            String url = 'https://maps.googleapis.com/maps/api/timezone/json?location=' +
                s.StoreLocation__Latitude__s + ',' +s.StoreLocation__Longitude__s +
                '&timestamp='+ DateTime.now().getTime()/1000 +'&key=' + this.GOOGLE_API_KEY ;
            req.setEndpoint(url);
            req.setMethod('GET');

            // Send the request, and return a response
            HttpResponse res = h.send(req);
            system.debug(res.getBody()) ;
            Map<String, Object> m =(Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            s.Time_Zone_Id__c = (String) m.get('timeZoneId');
            if(String.isNotEmpty(s.Time_Zone_Id__c))
                mapStoreCodeTimeZone.put(s.RetailStoreId__c, s.Time_Zone_Id__c);
        }

        Database.update(stores, false);

        // List<User> users = [Select Id, TimeZoneSidKey, DefaultStore__c From User Where DefaultStore__c IN :mapStoreCodeTimeZone.keySet() AND Is_Identity_User__c = false AND isActive = true];
        // for( User u : users){
        //     u.TimeZoneSidKey = mapStoreCodeTimeZone.get(u.DefaultStore__c);
        // }

        // Database.update(users, false);
    }
}