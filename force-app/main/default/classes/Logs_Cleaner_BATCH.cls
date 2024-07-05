global class Logs_Cleaner_BATCH implements Database.Batchable<sObject> {
    Integer batchLimit = 10000;
    String query;
    DateTime dt = System.now().addDays(-35);
    Map<String,Map<String,LogsSetting__mdt>> settings;
    Integer minimumCleanUpDays;
    
    global Logs_Cleaner_BATCH() {
        //query = 'SELECT Id, Apex_Class__c, Level__c, CreatedDate FROM Logs__c WHERE CreatedDate >: dt';

        // GET SETTINGS 
        List<LogsSetting__mdt> settings_list = [
            SELECT Apex_Class__c, Mode__c, Level__c, Clean_Up_Every__c, Batch_Limit__c
            FROM LogsSetting__mdt 
            WHERE IsActive__c = true
        ];

        settings = new Map<String,Map<String,LogsSetting__mdt>>();
        for(LogsSetting__mdt setting : settings_list){
            
            
             if (setting.Batch_Limit__c != null) {
                batchLimit = setting.Batch_Limit__c.intValue();
                
            }
            if(settings.get(setting.Apex_Class__c) == null){
                settings.put(setting.Apex_Class__c, new Map<String,LogsSetting__mdt>());
            }

            if(String.isEmpty(setting.Level__c) || setting.Level__c == 'ALL'){
                settings.get(setting.Apex_Class__c).put('ALL', setting);
            }
            else {
                settings.get(setting.Apex_Class__c).put(setting.Level__c, setting);
            }
        }
        
        query = 'SELECT Id, Apex_Class__c, Level__c, CreatedDate FROM Logs__c WHERE CreatedDate >: dt LIMIT ' + batchLimit;
        System.debug ('query' + query);
        Global_Settings__mdt minimumCleanUp = Global_Settings__mdt.getInstance('Logs_Cleaner_Minimum_Clean_Up_Days');
        minimumCleanUpDays = minimumCleanUp != null ? Integer.valueOf(minimumCleanUp.Value__c) * -1 : -7;

    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        List<Logs__c> toDelete = new List<Logs__c>();

        for(Logs__c log : (List<Logs__c>)scope){

            // REMOVE LOG WITHOUT APEX CLASS AFTER X DAYS
            if(String.isEmpty(log.Apex_Class__c) && log.CreatedDate <= System.now().addDays(minimumCleanUpDays)){
                toDelete.add(log);
            }
            else if(!String.isEmpty(log.Apex_Class__c)){

                // REMOVE LOG WITHOUT SETTINGS AFTER X DAYS
                if(settings.get(log.Apex_Class__c) == null && log.CreatedDate <= System.now().addDays(minimumCleanUpDays)){
                    toDelete.add(log);
                }
                else if(settings.get(log.Apex_Class__c) != null){

                    // ACCORDING  SETTINGS BY LEVEL
                    if(settings.get(log.Apex_Class__c).get(log.Level__c) != null){
                        Integer days = Integer.valueOf(settings.get(log.Apex_Class__c).get(log.Level__c).Clean_Up_Every__c);

                        if(log.CreatedDate <= System.now().addDays(-days)){
                            toDelete.add(log);
                        }
                    }
                    // ACCORDING SETTINGS BY APEX CLASS
                    else if(settings.get(log.Apex_Class__c).get('ALL') != null){
                        Integer days = Integer.valueOf(settings.get(log.Apex_Class__c).get('ALL').Clean_Up_Every__c);

                        if(log.CreatedDate <= System.now().addDays(-days)){
                            toDelete.add(log);
                        }
                    }
                    // REMOVE LOG WITHOUT SETTINGS AFTER X DAYS
                    else if(log.CreatedDate <= System.now().addDays(minimumCleanUpDays)){
                        toDelete.add(log);
                    }
                }
            }
        }

        delete toDelete;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}