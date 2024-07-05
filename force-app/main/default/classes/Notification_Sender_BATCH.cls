global class Notification_Sender_BATCH implements Database.Batchable<sObject> {
    
    String query;
    Map<String,Map<String,Notification_Settings__mdt>> settings;
    
    global Notification_Sender_BATCH () {
        query = 'SELECT Id, Application__c, Message_Id__c, CreatedDate, Status__c, Relay_Datetime__c FROM Notification__c WHERE Status__c = \'CREATED\' AND Real_Time__c != true ';

        // GET SETTINGS 
        List<Notification_Settings__mdt> settings_list = [
            SELECT Application__c, Message_Id__c, Delay_Time__c
            FROM Notification_Settings__mdt 
        ];

        settings = new Map<String,Map<String,Notification_Settings__mdt>>();
        for(Notification_Settings__mdt setting : settings_list){

            if(settings.get(setting.Application__c) == null){
                settings.put(setting.Application__c, new Map<String,Notification_Settings__mdt>());
            }

            settings.get(setting.Application__c).put(setting.Message_Id__c, setting);
        }

        System.debug('SETTINGS: ' + settings);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        List<Notification__c> toUpdate = new List<Notification__c>();

        for(Notification__c note : (List<Notification__c>)scope){

            // UPDATE NOTIFICATIONS STATUS AFTER *** HOURS
            if(settings.get(note.Application__c) != null){

                if(settings.get(note.Application__c).get(note.Message_Id__c) != null){

                    // ACCORDING TO NOTIFICATIONS By RealTime
                    if(note.Relay_Datetime__c != null){
                        if(note.Relay_Datetime__c <= System.now()){
                            note.Status__c = 'READY TO SEND';
                            toUpdate.add(note);
                        }
                    }
                    // ACCORDING TO SETTINGS BY MessageId
                    else{
                        Integer hours = Integer.valueOf(settings.get(note.Application__c).get(note.Message_Id__c).Delay_Time__c);
                        if(note.CreatedDate <= System.now().addHours(-hours)){
                            note.Status__c = 'READY TO SEND';
                            toUpdate.add(note);
                        }
                    }
                }
            }
        }

        update toUpdate;
    }
    
    global void finish(Database.BatchableContext BC) {}
}