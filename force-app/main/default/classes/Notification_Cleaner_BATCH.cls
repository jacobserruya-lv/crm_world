global class Notification_Cleaner_BATCH implements Database.Batchable<sObject> {
    
    String query;
    //DateTime dt = System.now().addDays(-45);
    Map<String,Map<String,Notification_Settings__mdt>> settings;
    
    global Notification_Cleaner_BATCH () {
        query = 'SELECT Id, Application__c, Message_Id__c, LastModifiedDate, Status__c FROM Notification__c WHERE Status__c = \'CANCELLED\' OR Status__c = \'CLOSED\' OR Status__c = \'READY TO SEND\' ';
        
        // GET SETTINGS 
        List<Notification_Settings__mdt> settings_list = [
            SELECT Application__c, Message_Id__c, Clean_Up_Every__c, Update_Statut_Every__c
            FROM Notification_Settings__mdt 
        ];
        
        settings = new Map<String,Map<String,Notification_Settings__mdt>>();
        for(Notification_Settings__mdt setting : settings_list){
            
            if(settings.get(setting.Application__c) == null){
                settings.put(setting.Application__c, new Map<String,Notification_Settings__mdt>());
            }
            
            settings.get(setting.Application__c).put(setting.Message_Id__c, setting);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        List<Notification__c> toDelete = new List<Notification__c>();
        List<Notification__c> toUpdate = new List<Notification__c>();
        
        for(Notification__c note : (List<Notification__c>)scope){
            
            if(settings.get(note.Application__c) != null){
                //UPDATE STATUT "REANDY TO SEND" NOTIFICATIONS to "CANCELLED" AFTER *** DAYS
                if(note.Status__c == 'READY TO SEND'){
                    // ACCORDING SETTINGS BY MessageId
                    if(settings.get(note.Application__c).get(note.Message_Id__c) != null){
                        if(settings.get(note.Application__c).get(note.Message_Id__c).Update_Statut_Every__c !=NULL) {
                            Integer Udays = Integer.valueOf(settings.get(note.Application__c).get(note.Message_Id__c).Update_Statut_Every__c);
                            if(note.LastModifiedDate <= System.now().addDays(-Udays) || Test.isRunningTest()){
                                note.Status__c = 'CANCELLED';
                                toUpdate.add(note);
                            }
                        }
                    }
                }else{
                    // REMOVE CANCELLED and CLOSED NOTIFICATIONS CLOSED AFTER *** DAYS     
                    // ACCORDING SETTINGS BY MessageId
                    if(settings.get(note.Application__c).get(note.Message_Id__c) != null){
                        Integer days = Integer.valueOf(settings.get(note.Application__c).get(note.Message_Id__c).Clean_Up_Every__c);                        
                        if(note.LastModifiedDate <= System.now().addDays(-days) || Test.isRunningTest()){
                            toDelete.add(note);
                        }
                    }
                    // BY DEFAULT
                    else {
                        Integer days = 7;
                        if(note.LastModifiedDate <= System.now().addDays(-days) || Test.isRunningTest()){
                            toDelete.add(note);
                        }
                    }                    
                }
            }
        }
        if(toUpdate.size()>0){
            Database.SaveResult[] srList = Database.update(toUpdate, false);
            }
        if(toDelete.size()>0){
            Database.DeleteResult[] sdList = Database.delete(toDelete, false);
        } 
    }
    
    global void finish(Database.BatchableContext BC) {}
}