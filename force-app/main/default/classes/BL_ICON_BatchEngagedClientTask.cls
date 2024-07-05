global with sharing class BL_ICON_BatchEngagedClientTask implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public String query;
    public static final Id TaskTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('To_Do_Assistant').getRecordTypeId();   
    
    global BL_ICON_BatchEngagedClientTask() {
        query = 'SELECT id, PersonContactId, CA_Engaged__c, CA_Engaged__r.DefaultStore__c, End_Engagement_date__c FROM Account WHERE End_Engagement_date__c = NEXT_N_DAYS:61';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        Map<String, Task> tasksFound = new Map<String, Task>();
        
        String typeIdTemp = String.valueOf(TaskTypeId);
        
        List<Task> exsistTasks = [SELECT Id, WhatId, WhoId, ActivityDate, To_do_type__c FROM Task WHERE To_do_type__c = 'Engaged' AND ActivityDate >= TODAY AND ActivityDate <= NEXT_N_DAYS:60 AND recordTypeId =: TaskTypeId];
        List<String> usersIds = new List<String>();
        Map<String, Boolean> isIdInPilot = new Map<String, Boolean>();
        
        List<Pilot_Setting__mdt> pilotSettings = [
                SELECT Application__c, Mode__c, Stores__c, Countries__c, Zones__c, Excluded_Countries__c, Excluded_Stores__c,
                ProfileIds__c, Excluded_ProfileIds__c, High_Priority_Excluded_ProfileIds__c, High_Priority_ProfileIds__c
                FROM Pilot_Setting__mdt 
                WHERE Application__c = 'ICON' LIMIT 1
            ];

        for(sObject s : scope) {
            Account acc = (Account) s;
            usersIds.add(acc.CA_Engaged__c);
        }

        List<User> users = [SELECT DefaultStore__c, MANAGEMENT_ZONE_LEVEL__c, country__c, ProfileId FROM User WHERE Id IN :usersIds];
        for(User u : users) {
            isIdInPilot.put(u.id, isCaInPilot(u, pilotSettings));
        }
        for(Task task : exsistTasks){
            tasksFound.put(task.WhatId, task);
        }
        
        try {
            List<Task> lstTask = new List<Task>();
            for(sObject s : scope){
                Account acc = (Account) s;
                if(!tasksFound.containsKey(acc.id) && isIdInPilot.get(acc.CA_Engaged__c)){
                   lstTask.add(createToDoTaskEngaged(acc));
                }
            }            
            database.insert(lstTask,true);
            for(Task t : lstTask){
            }
        }
        catch(Exception e) {
            System.debug(e);
        }
    }
    
    public static Task createToDoTaskEngaged(Account account){
        return new Task(
            To_do_type__c = 'Engaged',
            SourceType__c = 'ICON',
            Status = 'New',
            Subject = setSubject(account.CA_Engaged__c),
            WhatId =  account.Id,
            WhoId = account.PersonContactId,
            Store_Location__r = account.CA_Engaged__r.DefaultStore__c != null ? new Store__c(RetailStoreId__c = account.CA_Engaged__r.DefaultStore__c) : null,
            Assignment__c = 'CA',
            OwnerId = account.CA_Engaged__c,        
            RecordTypeId = TaskTypeId,
            ActivityDate = account.End_Engagement_date__c,
            Todo_Code__c = 'TD_CL_END_ENG_60days'
         );
    }
    
        public static String setSubject(String userId){
        String subject = '';
        Map<String, String> languageMap = new Map<String, String>();
        List<Translation__c> translation = [SELECT Id, value__c, language__c FROM Translation__c where key__c = 'iconAssistant-engaged-task-subject'];
        String language = [SELECT Id, LanguageLocaleKey FROM User where Id =: userId]?.LanguageLocaleKey;
        for(Translation__c t : translation){
            languageMap.put(t.Language__c, t.Value__c);
        }
        if(String.IsNotEmpty(languageMap.get(language))){
            subject = languageMap.get(language);
        }
        else {
            subject = languageMap.get('en_US');
        }
              
        return subject;
    }
    
    public static Boolean isCaInPilot(User u, List<Pilot_Setting__mdt> pilotSettings)  {
        try {
            System.debug('RRRRRRRRRRRRRRRRR: ' + u );
            if(pilotSettings.size() > 0) {
                Pilot_Setting__mdt pilotSetting = pilotSettings[0];
                if(pilotSetting.Mode__c.equalsIgnoreCase('WW_Deployed')) {
                    return true;
                } else if(pilotSetting.Mode__c.equalsIgnoreCase('Unavailable')){
                    return false;
                } else if (pilotSetting.Mode__c.equalsIgnoreCase('Pilot')){
                    return isPriorityProfileId(u, pilotSetting.High_Priority_ProfileIds__c) 
                        ||
                    !isPriorityExcludedProfileId(u, pilotSetting.High_Priority_Excluded_ProfileIds__c) 
                        && isProfileId(u, pilotSetting.ProfileIds__c, pilotSetting.Excluded_ProfileIds__c) && 
                         (isZone(u,  pilotSetting.Zones__c, pilotSetting.Excluded_Stores__c, pilotSetting.Excluded_Countries__c )||
                        isCountry(u, pilotSetting.Countries__c, pilotSetting.Excluded_Stores__c) || isStore(u, pilotSetting.Stores__c) );
                  
                      
                }
                return true;
            }
            return true;
        } catch (Exception e ) {
            return false;
        }
        
    }
     private static Boolean isPriorityProfileId(User u, String profileIds) {
        if(String.isBlank(profileIds)) {
            return false;
        } 
        return profileIds.contains(u.ProfileId) ;
    }
    
    private static Boolean isPriorityExcludedProfileId(User u, String excludedProfileIds) {
        if(String.isBlank(excludedProfileIds)) {
            return false;
        } 
        return excludedProfileIds.contains(u.ProfileId) ;
    }
    
    private static Boolean isProfileId(User u, String profileIds, String excludedProfileIds) {
        if(String.isBlank(profileIds)) {
            return (String.isBlank(excludedProfileIds) || !excludedProfileIds.contains(u.ProfileId));
        } 
        return profileIds.contains(u.ProfileId)  && (String.isBlank(excludedProfileIds) || !excludedProfileIds.contains(u.ProfileId));
    }
    
    private static Boolean isStore(User u, String stores) {
        if(String.isBlank(stores) || String.isBlank(u.DefaultStore__c)) {
            return false;
        }
        return stores.containsIgnoreCase(u.DefaultStore__c);
    }
    
    private static Boolean isCountry(User u, String countries, String excludedStores) {
        if(String.isBlank(countries) || String.isBlank(u.country__c)) {
            return false;
        }
        return countries.containsIgnoreCase(u.country__c) && ( String.isBlank(excludedStores) || !excludedStores.containsIgnoreCase(u.DefaultStore__c));
    }
    
    private static Boolean isZone(User u, String zones, String excludedStores, String excludedCountries) {
        if(String.isBlank(zones) || String.isBlank(u.MANAGEMENT_ZONE_LEVEL__c)) {
            return false;
        }
        system.debug('iszone ' + (zones.containsIgnoreCase(u.MANAGEMENT_ZONE_LEVEL__c) &&
        ( String.isBlank(excludedStores) || !excludedStores.containsIgnoreCase(u.DefaultStore__c)) && 
        ( String.isBlank(excludedCountries) || !excludedCountries.containsIgnoreCase(u.country__c))));
        return zones.containsIgnoreCase(u.MANAGEMENT_ZONE_LEVEL__c) &&
        ( String.isBlank(excludedStores) || !excludedStores.containsIgnoreCase(u.DefaultStore__c)) && 
        ( String.isBlank(excludedCountries) || !excludedCountries.containsIgnoreCase(u.country__c));
    }
    
    global void finish(Database.BatchableContext CD){}
}