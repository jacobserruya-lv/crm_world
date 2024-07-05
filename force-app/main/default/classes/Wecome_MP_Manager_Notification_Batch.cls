public with sharing class Wecome_MP_Manager_Notification_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    static string reassignedClientList = [SELECT id from BL_ClientList__mdt WHERE developerName = 'Reassigned' limit 1].id;
    List<String> errorOnNotif = new List<String>();
    String query;

    public Wecome_MP_Manager_Notification_Batch() {

        Map<String,Profile> SAprofiles = new Map<String, Profile> ([SELECT id FROM profile WHERE name in ('ICON_SA', 'ICON_SA Manager', 'ICON_SAManager_EVERYWHERE','System Administrator')]);
        Set<String> SAprofilesIds = SAprofiles.keySet();
        query = 'SELECT id, WWEmployeeNumber__c, Lastname, FirstName, DefaultStore__c, TECH_IsManager__c from User WHERE TECH_IsManager__c = TRUE AND MGMT_ZONE_SUB_LEVEL1__c = \'1071\' AND DefaultStore__c <> NULL  AND IsActive = true AND WWEmployeeNumber__c <> null AND ProfileId IN (' + listToString(SAprofilesIds) +') ';
        query += 'ORDER BY DefaultStore__c';

    }
    public Wecome_MP_Manager_Notification_Batch(String queryCondition) {
        
        query = 'SELECT id, WWEmployeeNumber__c, Lastname, FirstName, DefaultStore__c, TECH_IsManager__c from User WHERE '+queryCondition;

    }

    public Database.QueryLocator start(Database.BatchableContext BC){

        return Database.getQueryLocator(query);

    }
  
    public void execute(Database.BatchableContext BC, List<sObject> users){

        try{
            List<String> storeList = getAttachedStoreList(users);
            system.debug('storeList:'+storeList);
            Map<String, Integer> StoreCode_ClientCounter = getNumberOfClientsByStore(storeList);
            for(SObject u :users){
                User user = (User)u;
                if(StoreCode_ClientCounter.get(user.DefaultStore__c) != null && StoreCode_ClientCounter.get(user.DefaultStore__c) > 0){
                    List<Map<String, String>> params = getNotificationParams(user.Lastname + ' ' + user.FirstName, '您的店铺有'+String.valueOf(StoreCode_ClientCounter.get(user.DefaultStore__c)) +'位客人需重新指派', 'Clienteling机遇任务' );

                    //NOT TO FORGET CHANGE ICON_PRP TO ICON for PROD deploy
               
                    HTTP_Utils response = sendNotification(
                                                        'ICON',
                                                        user.WWEmployeeNumber__c ,
                                                        'pages/clients/client-lists/clients-list/clients-list?id='+reassignedClientList+'&tab=1&source=notification_icon',
                                                        '重新指派通知',
                                                        '通知提醒',
                                                        JSON.serialize(params));  

                    if(response.response.getStatusCode() != 201){//status code: created
                        errorOnNotif.add(user.WWEmployeeNumber__c);
                    }
                }
            }

        }
        catch(Exception ex){
            new Logs.ERROR('Wecome_MP_Assistant_Notification_Batch','Callout',ex);
		}
    }

    public void finish(Database.BatchableContext BC){
        if(!errorOnNotif.isEmpty()){
            new Logs.ERROR('Wecome_MP_Assistant_Notification_Batch','Callout','The following users have Notifications but ERROR sending notification'+ errorOnNotif);
        }
    }

    //HELP FUNCTIONS
    public static String listToString (Set<String> stringSet){
        List<String> stringList = new List<String>();
        stringList.addAll(stringSet);
        return '\''+ String.join(stringList, '\',\'') + '\'';
    }

    private static List<String> getAttachedStoreList (List<Sobject> users){
        List<String> storeList = new List<String>();
        for(Sobject user : users){
            if(!storeList.contains((String)user.get('DefaultStore__c')))
                storeList.add((String)user.get('DefaultStore__c'));
        }
        return storeList;
    }

    private static Map<String, Integer> getNumberOfClientsByStore(List<String> storeList){
        Map <String, Integer> clientCounterByStore = new Map<String, Integer>();
        for(AggregateResult acc : [SELECT AttachedStore__pc, COUNT(Id)counter FROM Account WHERE IsProspect__pc = FALSE AND AttachedStore__pc IN: storeList AND Owner.IsTechnicalUser__c = TRUE GROUP BY AttachedStore__pc]){
            clientCounterByStore.put((String)acc.get('AttachedStore__pc') , (Integer)acc.get('counter'));
        }
        return clientCounterByStore;
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