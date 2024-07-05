global class Notifcation_BATCH_Wechat_Sender implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    String query;
    Map<String,Map<String,Notification_Settings__mdt>> settings;
    
    global Notifcation_BATCH_Wechat_Sender () {
        query = 'SELECT Id, Application__c, Message_Id__c, CreatedDate, Status__c, Relay_Datetime__c, (Select Field__c, LongValue__c, Type__c From Notification_Parameters__r) FROM Notification__c WHERE Status__c = \'READY TO SEND\' AND Real_Time__c != true AND Application__c = \'WECHAT ONLINE APPOINTMENT\' ';

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
            if(settings.get(note.Application__c) != null ){

                if(settings.get(note.Application__c).get(note.Message_Id__c) != null){
                    Map<String, Object> params = new Map<String, Object>();
                    for(Notification_Parameter__c param : note.Notification_Parameters__r) {
                        try{
                            params.put(param.Field__c, (param.Type__c == 'Object' ? (Object)((Map<String,Object>)JSON.deserializeUntyped(param.LongValue__c)) : (Object)param.LongValue__c));
                        } catch(Exception e){
                            system.debug(e.getMessage());
                        }
                        
                    }
                    
                    if(note.Relay_Datetime__c.addMinutes(24*60) > system.now()) {
                        try{
                            HTTP_Utils response = Wechat_MP_Notification_Center.sendNotification(note, params);
                            if(response.statusCode() >= 400) {
                                note.Status__c ='FAILED';
                            } else {
                                note.Status__c ='CLOSED';
                            }
                        } catch(Exception e){
                            system.debug(e.getMessage());
                            note.Status__c ='FAILED';
                        }
                    } else {
                        note.Status__c ='NOT SENT';
                    }
                    toUpdate.add(note);
                }
            }
        }

        update toUpdate;
    }
    
    global void finish(Database.BatchableContext BC) {}
}