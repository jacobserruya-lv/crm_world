global without sharing class Notification_Sender {

    public static List<Notification_Settings__mdt> getSettings(String application, Integer scenario, String channel){

       return Database.query(
              ' SELECT Application__c, Channel__c, Message_Id__c '
            + ' FROM Notification_Settings__mdt '
            + ' WHERE Application__c = \'' + application + '\''
            + ' AND Scenario__c = ' + scenario
            + (String.isEmpty(channel) ? '' : ' AND Channel__c = \'' + channel + '\'')
            + ' AND Is_Active__c = ' + true
        );
    }

    public static List<SObject> getClients(Set<Id> client_ids){

       return Database.query(
              ' SELECT Id, HomeAddressCountryCode__pc, Can_Be_Contacted_By_Email__pc, PersonEmail, PersonMobilePhone '
            + ' FROM Account '
            + ' WHERE Id IN: client_ids '
        );
    }

    public static Map<Id,Account> getClientsMap(Set<Id> client_ids){

        return new Map<Id,Account>(
            [   SELECT Id, HomeAddressCountryCode__pc, Can_Be_Contacted_By_Email__pc, PersonEmail, PersonMobilePhone 
                FROM Account 
                WHERE Id IN: client_ids 
            ]
        );
    }

    public static void sendNotifications(List<Map<String, Object>> requirements){

        Set<Id> clientIds = new Set<Id>();
        List<SObject> notifications = new List<SObject>();
        List<Sobject> notifM = new List<Sobject>();
        List<Sobject> notifP = new List<Sobject>();

        try{
            for(Map<String, Object> requirement : requirements){
                clientIds.addall((Set<Id>) requirement.get('clientIds'));
            }
            Map<Id,Account> clientMap = getClientsMap(clientIds);

            for(Map<String, Object> requirement : requirements){

                List<SObject> clients = new List<SObject>();
                Map<String,Map<String,Object>> params = (Map<String,Map<String,Object>>) requirement.get('params');
                Notification_Settings__mdt setting = (Notification_Settings__mdt)  requirement.get('setting');

                for(Id clientId : (Set<Id>)  requirement.get('clientIds')){
                    clients.add(clientMap.get(clientid));
                }

                createNotifications(setting, clients, params, notifM, notifP);       
            }
         
            notifications.addAll(notifM);
            notifications.addAll(notifP);

            // INSERT NOTIFICATIONS
            System.debug('Insert Notifications: ' + notifications);
            Database.SaveResult[] results = Database.insert(notifications, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    new Logs( new Map<String,Object> {
                        'level' => 'ERROR', 
                        'apexClass' => 'Notification_Sender', 
                        'category' => 'Database',
                        'message' => String.valueOf(results[i].getErrors()[0].getStatusCode())
                    });

                    system.debug('ERROR LOGS' + results[i].getErrors());
                }
            }
        }
        catch(Exception ex){
            new Logs( new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'Notification_Sender', 
                'category' => 'APEX CODE',
                'exception_case' => ex
            });
        }
    }

    
    //create notification. for each client id one notification
    public static void send(Map<String,Object> requirements, Set<Id> client_ids, Map<String,Map<String,Object>> params){

        String application = (String)requirements.get('application');
        Integer scenario = (Integer)requirements.get('scenario');
        String channel = (String)requirements.get('channel');

        try{
            List<SObject> clients = getClients(client_ids);
            List<Notification_Settings__mdt> settings = getSettings(application, scenario, channel);

            List<SObject> notifications = new List<SObject>();
            List<Sobject> notifM = new List<Sobject>();
            List<Sobject> notifP = new List<Sobject>();
            for(Notification_Settings__mdt setting : settings){
                createNotifications(setting, clients, params, notifM, notifP);
            }
            notifications.addAll(notifM);
            notifications.addAll(notifP);

            // INSERT NOTIFICATIONS
            System.debug('Insert Notifications: ' + notifications);
            Database.SaveResult[] results = Database.insert(notifications, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    new Logs( new Map<String,Object> {
                        'level' => 'ERROR', 
                        'apexClass' => 'Notification_Sender', 
                        'category' => 'Database',
                        'message' => String.valueOf(results[i].getErrors()[0].getStatusCode())
                    });
                }
            }
        }
        catch(Exception ex){
            new Logs( new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'Notification_Sender', 
                'category' => 'APEX CODE',
                'exception_case' => ex
            });
        }
    }
    //create notifications. This funtion is able to create more than one notification per client according the "params" map (params = ClientID =>List of Map, each map represent the parameters for notification creation)
    public static void send2(Map<String,Object> requirements, Set<Id> client_ids, Map<String,List<Map<String,Object>>> params){

        String application = (String)requirements.get('application');
        Integer scenario = (Integer)requirements.get('scenario');
        String channel = (String)requirements.get('channel');

        try{
            List<SObject> clients = getClients(client_ids);
            List<Notification_Settings__mdt> settings = getSettings(application, scenario, channel);

            List<SObject> notifications = new List<SObject>();
            List<Sobject> notifM = new List<Sobject>();
            List<Sobject> notifP = new List<Sobject>();
            for(Notification_Settings__mdt setting : settings){
                createNotifications2(setting, clients, params, notifM, notifP);
            }
            notifications.addAll(notifM);
            notifications.addAll(notifP);

            // INSERT NOTIFICATIONS
            Database.SaveResult[] results = Database.insert(notifications, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    System.debug(results[i].getErrors()[0]);
                    new Logs( new Map<String,Object> {
                        'level' => 'ERROR', 
                        'apexClass' => 'Notification_Sender', 
                        'category' => 'Database',
                        'message' => String.valueOf(results[i].getErrors()[0].getStatusCode())
                    });
                }
            }
        }
        catch(Exception ex){
            new Logs( new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'Notification_Sender', 
                'category' => 'APEX CODE',
                'exception_case' => ex
            });
        }
    }
    public static Boolean isContactable(Account client, String channel){
        switch on channel {
            when 'EMAIL MARKETING CLOUD'{
                return !String.isEmpty(client.PersonEmail);
            }
            when 'REAL TIME'{
                return !String.isEmpty(client.PersonEmail);
            }
            when 'SMS MARKETING CLOUD'{
                return !String.isEmpty(client.PersonMobilePhone);
            }
            when else {
                return true;
            }
        }
    }

    public static Void createNotifications(Notification_Settings__mdt setting, List<SObject> clients, Map<String,Map<String,Object>> params, List<SObject> notificationsM, List<SObject> notificationsP){

        for(SObject client : clients){

            String external_id = getUUID();
            String client_id = (String)client.get('Id');

            if(isContactable((Account)client, setting.Channel__c)){
                // NOTIFICATION 
                Notification__c notification = new Notification__c(
                    Channel__c = setting.Channel__c,
                    Application__c = setting.Application__c,
                    Message_Id__c = setting.Message_Id__c,
                    Client__c = client_id,
                    Country__c = (String)client.get('HomeAddressCountryCode__pc'),
                    Language__c = (String)client.get('HomeAddressCountryCode__pc'),
                    External_Id__c = external_id
                );

                // WHAT ID
                if(params.get(client_id) != null && params.get(client_id).get('what_id') != null) {
                    notification.WhatId__c = (String)params.get(client_id).get('what_id');
                }

                // WHAT ID
                if(params.get(client_id) != null && params.get(client_id).get('is_real_time') != null) {
                    notification.Real_Time__c = (Boolean)params.get(client_id).get('is_real_time');
                }

                // Relay Datetime 
                if(params.get(client_id) != null && params.get(client_id).get('relay_datetime') != null) {
                    notification.Relay_Datetime__c = (DateTime)params.get(client_id).get('relay_datetime');
                }

                // REAL TIME 
                if(notification.Real_Time__c) {
                    notification.Status__c = 'READY TO SEND';
                    willSendRealTime(JSON.serialize(notification), JSON.serialize(params.get(client_id)));
                } else {
                    notificationsM.add(notification);
        
                  //DISTANT CARE SERVICE
                  if(setting.Application__c == 'DISTANT CARE SERVICE')
                      notification.status__c = 'READY TO SEND';
                    
                    // NOTIFICATION PARAMETERS
                    if(params.get(client_id) != null){
                        notificationsP.addAll(setNotificationParameters(params.get(client_id), setting.channel__c, external_id));
                    }
                }

                // MESSAGE ID - Exclusive Sales
                if(params.get(client_id) != null && params.get(client_id).get('message_id') != null) {
                    notification.Message_Id__c = (String)params.get(client_id).get('message_id');
                }
                
                //Added By Ouramdane-A
                //Status - Exclusive Repair (Store Care Service)
                if(setting.Message_Id__c == 'VCSE1') {
                    notification.status__c = 'READY TO SEND';
                }
            }
        }
    }
          
    public static Void createNotifications2(Notification_Settings__mdt setting, List<SObject> clients, Map<String,List<Map<String,Object>>> params, List<SObject> notificationsM, List<SObject> notificationsP){

        for(SObject client : clients){
            String client_id = (String)client.get('Id');
            for(Map<String,Object> acc_params:params.get(client_id))
            {
                String external_id = getUUID();

                if(isContactable((Account)client, setting.Channel__c)){
                    // NOTIFICATION 
                    Notification__c notification = new Notification__c(
                        Channel__c = setting.Channel__c,
                        Application__c = setting.Application__c,
                        Message_Id__c = setting.Message_Id__c,
                        Client__c = client_id,
                        Country__c = (String)client.get('HomeAddressCountryCode__pc'),
                        Language__c = (String)client.get('HomeAddressCountryCode__pc'),
                        External_Id__c = external_id
                    );

                    // WHAT ID
                    if(params.get(client_id) != null && acc_params.get('what_id') != null) {
                        notification.WhatId__c = (String)acc_params.get('what_id');
                    }

                    // WHAT ID
                    if(params.get(client_id) != null && acc_params.get('is_real_time') != null) {
                        notification.Real_Time__c = (Boolean)acc_params.get('is_real_time');
                    }

                    // Relay Datetime 
                    if(params.get(client_id) != null && acc_params.get('relay_datetime') != null) {
                        notification.Relay_Datetime__c = (DateTime)acc_params.get('relay_datetime');
                    }

                    // REAL TIME 
                    if(notification.Real_Time__c) {
                        notification.Status__c = 'READY TO SEND';
                        willSendRealTime(JSON.serialize(notification), JSON.serialize(acc_params));
                    } else {
                        notificationsM.add(notification);
          
                    //DISTANT CARE SERVICE
                    if(setting.Application__c == 'DISTANT CARE SERVICE')
                        notification.status__c = 'READY TO SEND';
                        
                        // NOTIFICATION PARAMETERS
                        if(params.get(client_id) != null){
                            notificationsP.addAll(setNotificationParameters(acc_params, setting.channel__c, external_id));
                        }
                    }

                    // MESSAGE ID - Exclusive Sales
                    if(params.get(client_id) != null && acc_params.get('message_id') != null) {
                        notification.Message_Id__c = (String)acc_params.get('message_id');
                    }
                }
            }
        }
    }
    public static List<Notification_Parameter__c> setNotificationParameters(Map<String, Object> params, string channel, string external_id) {
        List<Notification_Parameter__c> notification_parameters = new List<Notification_Parameter__c>();
        for(String field : params.keySet()){
                            
            if(field != 'application'){
                Notification_Parameter__c notification_parameter = new Notification_Parameter__c(
                    Notification__r = new Notification__c(External_Id__c = external_id),
                    Field__c = field,
                   // LongValue__c = getType(params.get(field)) == 'Object' ? JSON.serialize(params.get(field)) : String.valueOf(params.get(field)),
                    Type__c = getType(params.get(field))
                );
                //--second field LongValue2__c for shipping label too long --- Keman WU
                if(params.get(field) != null){
                if(String.valueOf(params.get(field)).length() <131072)
                    notification_parameter.LongValue__c = getType(params.get(field)) == 'Object' ? JSON.serialize(params.get(field)) : String.valueOf(params.get(field));
                else{
                    notification_parameter.LongValue__c = String.valueOf(params.get(field)).substring(0, 131072);
                    notification_parameter.LongValue2__c = String.valueOf(params.get(field)).substring(131072);
                        }
                    }
                notification_parameters.add(notification_parameter);

                if(params.get('application')!='DISTANT CARE SERVICE' && params.get('application')!='EXCLUSIVE EXPERIENCE' && ((channel.toLowerCase().contains('sms') || channel.toLowerCase().contains('email')) && field.toLowerCase().contains('url'))){
                    if(!System.isBatch() && !System.isFuture())
                        willShortUrl(JSON.serialize(notification_parameter), external_id);
                }
            }
        }

        return notification_parameters;
    }


    public static string getType(Object o) {
        if(o==null) return '';              // we can't say much about null with our current techniques
        if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+''; 
        if(o instanceof Boolean)            return 'BOOLEAN';
        if(o instanceof Id)                 return 'TEXT';
        if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof String)             return 'TEXT';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Decimal';  // we can't distinguish between decimal and double
        if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
        if(o instanceof List<object>)       return 'List';
        return 'Object';                    // actually we can't detect maps and sets and maps
    }

    public static String getUUID(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }

    @future(callout=true)
    global static void willShortUrl(String jsonData, String externalId) {
        try{
            Notification_Parameter__c param = (Notification_Parameter__c)JSON.deserialize(jsonData, Notification_Parameter__c.Class);

            String shortUrl = Akamai_API.getShortUrl(param.LongValue__c, 'IDENTITY');

            Notification_Parameter__c newParam = new Notification_Parameter__c(
                Notification__r = new Notification__c(External_Id__c = externalId),
                Field__c = param.Field__c + '_short',
                LongValue__c = shortUrl,
                Type__c = param.Type__c
            );

            insert newParam;
        }
        catch(Exception ex) {
            new Logs( new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'Notification_Sender', 
                'category' => 'APEX CODE',
                'exception_case' => ex
            });
        }
    }

     @future(callout=true)
     global static void willSendRealTime(String jsonData, String jsonParams) {
         String logDetails;
         try{
             Notification__c notification = (Notification__c)JSON.deserialize(jsonData, Notification__c.Class);
             Map<String,Object> params = (Map<String,Object>)JSON.deserializeUntyped(jsonParams);
             logDetails = 'NOTIFICATION: ' + notification + '\n' + 'CLIENT ID: ' + params;
             if(notification.application__c == 'WECHAT ONLINE APPOINTMENT') {
                 HTTP_Utils response = Wechat_MP_Notification_Center.sendNotification(notification, params);
                 if(response.statusCode() == 200) {
                     notification.Status__c ='CLOSED';
                     update notification;
                 }
             }
             MarketingCloud_API.sendNotification(notification, params);
         }
         catch(Exception ex) {
            
             new Logs( new Map<String,Object> {
                 'level' => 'ERROR', 
                 'apexClass' => 'Notification_Sender', 
                 'category' => 'APEX CODE',
                 'exception_case' => ex,
                 'details' => logDetails
             });
         }
     }

    public class CustomException extends Exception {}
}