public with sharing class Wecome_MP_Assistant_Notification_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{

    public static final Id TaskTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('To_Do_Assistant').getRecordTypeId();
    List<String> errorOnClientTaskNotif = new List<String>();
    List<String> errorOnServiceTaskNotif = new List<String>();
    List<String> errorOnNotif = new List<String>();
    String query;

    public Wecome_MP_Assistant_Notification_Batch() { 
        Map<String,Profile> SAprofiles = new Map<String, Profile> ([SELECT id FROM profile WHERE name in ('ICON_SA', 'ICON_SA Manager', 'ICON_SAManager_EVERYWHERE','System Administrator')]);
        Set<String> SAprofilesIds = SAprofiles.keySet();
        query = 'SELECT id, WWEmployeeNumber__c, Lastname, FirstName, DefaultStore__c, TECH_IsManager__c from User WHERE MGMT_ZONE_SUB_LEVEL1__c = \'1071\' AND DefaultStore__c <> NULL  AND IsActive = true AND WWEmployeeNumber__c <> null AND ProfileId IN (' + listToString(SAprofilesIds) +')';
    }

    public Wecome_MP_Assistant_Notification_Batch(String queryCondition)  { 
        query = 'SELECT id, WWEmployeeNumber__c, Lastname, FirstName, DefaultStore__c, TECH_IsManager__c from User WHERE '+queryCondition;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){

        return Database.getQueryLocator(query);

    }
  
    public void execute(Database.BatchableContext BC, List<sObject> users){

        try{
            Map<String, sObject> userMap = new Map<String, sObject>(users);
            Set<String> userIds = userMap.keySet();

            Set<String> defaultStoreList = new Set<String>();
            for (sObject user : users){
                if((Boolean)user.get('TECH_IsManager__c'))
                    defaultStoreList.add((String)user.get('DefaultStore__c'));
            }

            String taskCondition = 'Status =  \'New\' AND IsBadged__c = false  AND  recordTypeId = \''+ TaskTypeId + '\' AND ( ownerId IN (' + listToString(userIds) +') OR (Assignment__c = \'Manager\'  AND Store_Location__r.RetailStoreId__c IN (' + listToString(defaultStoreList) + ')))';
            List<Map<String, Object>> taskList = getAllObjects (BL_ICON_Constants.USE_CASE_TODO_ASSISTANT, taskCondition);
            
            Map<Id, List<Map<String,Object>>> ca_clientTasks_Map = new Map<Id, List<Map<String,Object>>>();
            Map<Id, List<Map<String,Object>>> ca_serviceTasks_Map = new Map<Id, List<Map<String,Object>>>();
            Map<String, List<Map<String,Object>>> store_clientTasks_Map = new Map<String, List<Map<String,Object>>>();
            Map<String, List<Map<String,Object>>> store_serviceTasks_Map = new Map<String, List<Map<String,Object>>>();

            for(Map<String, Object> obj : taskList){
                String ownerId = (String)obj.get('caId');
                String defaultStore = (String)obj.get('storeCode');
                
                if(obj.get('Assignment__c') == 'Manager'){
                    if(obj.get('to_do_type') == 'Client'){
                        if(!store_clientTasks_Map.containsKey(defaultStore)){
                            store_clientTasks_Map.put(defaultStore, new List<Map<String,Object>>()); 
                        }
                        store_clientTasks_Map.get(defaultStore).add(obj);
                    }
                    else{//service tasks
                        if(!store_serviceTasks_Map.containsKey(defaultStore)){
                            store_serviceTasks_Map.put(defaultStore, new List<Map<String,Object>>()); 
                        }
                        store_serviceTasks_Map.get(defaultStore).add(obj);
                    }    
                }
                else{
                    if(obj.get('to_do_type') == 'Client'){
                        if(!ca_clientTasks_Map.containsKey(ownerId)){
                            ca_clientTasks_Map.put(ownerId, new List<Map<String,Object>>()); 
                        }
                        ca_clientTasks_Map.get(ownerId).add(obj);
                    }
                    else{//service tasks
                        if(!ca_serviceTasks_Map.containsKey(ownerId)){
                            ca_serviceTasks_Map.put(ownerId, new List<Map<String,Object>>()); 
                        }
                        ca_serviceTasks_Map.get(ownerId).add(obj);
                    }    
                } 
            }
            
            for (sObject u : users){
                User user = (User)u;
                if(user.TECH_IsManager__c)
                {
                    if(ca_clientTasks_Map.get(user.id) != null && store_clientTasks_Map.get(user.DefaultStore__c) != null)
                        ca_clientTasks_Map.get(user.id).addAll(store_clientTasks_Map.get(user.DefaultStore__c));
                    if(ca_serviceTasks_Map.get(user.id) != null && store_serviceTasks_Map.get(user.DefaultStore__c) != null)
                        ca_serviceTasks_Map.get(user.id).addAll(store_serviceTasks_Map.get(user.DefaultStore__c));
                }
            }

            String notificationCondition = 'UserId__c  IN (' + listToString(userIds) +') AND Push_Notification_Item__r.Is_Silent_Push__c=false AND (IsRead__c = False OR (IsRead__c = true and LastModifiedDate = LAST_N_DAYS:2))';
            List<Map<String, Object>> notificationList = getAllObjects (BL_ICON_Constants.USE_CASE_NOTIFICATION, notificationCondition);
            Map<Id, List<Map<String,Object>>> ca_notifList_Map = listByCAMap(notificationList, 'userId');

            // Client Tasks Wecome notification sender
            for(String ca :ca_clientTasks_Map.keySet()){
                if(ca_clientTasks_Map.get(ca).size() > 0){
                    User caUser = (user)userMap.get(ca);
                    List<Map<String, String>> params = getNotificationParams(caUser.Lastname + ' ' + caUser.FirstName, '您今天有'+ca_clientTasks_Map.get(ca).size() +'个客户发展任务', 'Clienteling机遇任务' );

                    //NOT TO FORGET CHANGE ICON_PRP TO ICON for PROD deploy
                    HTTP_Utils response = sendNotification(
                                                        'ICON',
                                                        caUser.WWEmployeeNumber__c ,
                                                        'taro/pages/IconAssistantPage/IconAssistantPage?feature=Client',
                                                        '小助手通知',
                                                        '客户发展机会',
                                                        JSON.serialize(params));  

                    if(response.response.getStatusCode() != 201){//status code: created
                        errorOnClientTaskNotif.add(caUser.WWEmployeeNumber__c);
                    }
                }      
            }

            // Service Tasks Wecome notification sender
            for(String ca :ca_serviceTasks_Map.keySet()){
                if(ca_serviceTasks_Map.get(ca).size() > 0){
                    User caUser = (user)userMap.get(ca);
                    List<Map<String, String>> params = getNotificationParams(caUser.Lastname + ' ' + caUser.FirstName, '您今天有'+ca_serviceTasks_Map.get(ca).size() +'个服务跟进任务', '服务任务');
                    
                    //NOT TO FORGET CHANGE ICON_PRP TO ICON for PROD deploy
                    HTTP_Utils response = sendNotification(
                                                        'ICON',
                                                        caUser.WWEmployeeNumber__c ,
                                                        'taro/pages/IconAssistantPage/IconAssistantPage?feature=Service',
                                                        '小助手通知',
                                                        '服务跟进',
                                                        JSON.serialize(params));  
                    if(response.response.getStatusCode() != 201){//status code: created
                        errorOnServiceTaskNotif.add(caUser.WWEmployeeNumber__c);
                    }
                }      
            }

            // Notification wecome notification sender
            for(String ca :ca_notifList_Map.keySet()){
                if(ca_notifList_Map.get(ca).size() > 0){
                    User caUser = (user)userMap.get(ca);
                    List<Map<String, String>> params = getNotificationParams(caUser.Lastname + ' ' + caUser.FirstName,'您今天有'+ca_notifList_Map.get(ca).size() +'个消息提醒', '新信息​');
                    
                    //NOT TO FORGET CHANGE ICON_PRP TO ICON for PROD deploy
                    HTTP_Utils response = sendNotification(
                                                        'ICON',
                                                        caUser.WWEmployeeNumber__c ,
                                                        'taro/pages/Notifications/Notifications',
                                                        '新信息通知',
                                                        '通知提醒',
                                                        JSON.serialize(params));

                    if(response.response.getStatusCode() != 201){//status code: created
                        errorOnNotif.add(caUser.WWEmployeeNumber__c);
                    }

                }
            }
        }
        catch(Exception ex){
            new Logs.ERROR('Wecome_MP_Assistant_Notification_Batch','Callout',ex);
		}
    }

    //HELP FUNCTIONS    
    public void finish(Database.BatchableContext BC){
        if(!errorOnClientTaskNotif.isEmpty())
            new Logs.ERROR('Wecome_MP_Assistant_Notification_Batch','Callout','The following users have Clienting Tasks but ERROR sending notification'+ errorOnClientTaskNotif);
        if(!errorOnServiceTaskNotif.isEmpty())
            new Logs.ERROR('Wecome_MP_Assistant_Notification_Batch','Callout','The following users have Services Tasks but ERROR sending notification'+ errorOnServiceTaskNotif);
        if(!errorOnNotif.isEmpty()){
            new Logs.ERROR('Wecome_MP_Assistant_Notification_Batch','Callout','The following users have Notifications but ERROR sending notification'+ errorOnNotif);
        }
    }

    public static String listToString (Set<String> stringSet){
        List<String> stringList = new List<String>();
        stringList.addAll(stringSet);
        return '\''+ String.join(stringList, '\',\'') + '\'';
    }

    public static List<Map<String, Object>> getAllObjects(String useCase, String condition){

        return new BL_EasyQuery()
                .useCase(useCase)
                .condition(condition)
                .orderBy('LastModifiedDate DESC')
                .executeQuery()
                .getMappedObjects();
    }

    public static Map<Id, List<Map<String,Object>>> listByCAMap (List<Map<String, Object>> objList, String userLabel){

        Map<Id, List<Map<String,Object>>> ca_objList_Map = new Map<Id, List<Map<String,Object>>>();
        for(Map<String, Object> obj : objList){
            String ownerId = (String)obj.get(userLabel);
            if(!ca_objList_Map.containsKey(ownerId)){
                ca_objList_Map.put(ownerId, new List<Map<String,Object>>()); 
            }
            ca_objList_Map.get(ownerId).add(obj);
        }
        return ca_objList_Map;
    }

    public static HTTP_Utils sendNotification(String appid, String userids,String page, String title, String description, String paramsJson){
        
        Object params = (Object) JSON.deserializeUntyped(paramsJson) ;
        Map<String, Object> body = new Map<String, Object> {
            'touser'=> userids,
            'msgtype' => 'miniprogram_notice',
            'miniprogram_notice' => new Map<String, Object> {
                'appid'=> appid,
                'page'=> page,
                'title'=> title,
                'description'=> description,
                'emphasis_first_item'=> true,
                'content_item'=> params
            }
        };
        String bodyJson  = JSON.serialize(body);
        HTTP_Utils response = new HTTP_Utils()
                    .post('callout:LV_ICON_WECOM/wcw/messaging/mp?app_id='+appid)
                    .header('Content-Type', 'application/json;charset=UTF-8')
                    .body(bodyJson)
                    .call();
        
        return response;
    }

    public static List<Map<String,String>> getNotificationParams(String fullName, String bodyMsg, String notificationType){
        List<Map<String, String>> params = new List<Map<String, String>>();
        params.add(new Map<String, String>{
            'key'=> '早上好​',
            'value'=> fullName
        });
        params.add(new Map<String, String>{
            'key'=> '通知内容​',
            'value'=> bodyMsg
        });
        params.add(new Map<String, String>{
            'key'=> '日期​',
            'value'=> OnlineAppointments_Utils.getStoreLocalTime('Asia/Shanghai', System.today()).format('MM月dd日','GMT') 
        });
        params.add(new Map<String, String>{
            'key'=> '通知类型​',
            'value'=> notificationType
        });
        return params;

    }
}