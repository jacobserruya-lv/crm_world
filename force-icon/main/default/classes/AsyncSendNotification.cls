public class AsyncSendNotification implements Queueable {
    public List<BL_ICON_PushNotification_Config.PushNotification> pushNotificationItemList;
    
    public AsyncSendNotification(Object pushNotifications) {
        this.pushNotificationItemList = (List<BL_ICON_PushNotification_Config.PushNotification>) pushNotifications;
    }
    
    public void execute(QueueableContext context) {
       if(this.pushNotificationItemList.size() <= 10){   
       	sendNotifications(pushNotificationItemList);
       } else {
        splitAndSendNotification(pushNotificationItemList) ;
       }             
    }	

    public static void splitAndSendNotification(List<BL_ICON_PushNotification_Config.PushNotification> pushList){
        List<BL_ICON_PushNotification_Config.PushNotification> pushListTemp = new List<BL_ICON_PushNotification_Config.PushNotification>(pushList);
        List<BL_ICON_PushNotification_Config.PushNotification> pushListNew = new List<BL_ICON_PushNotification_Config.PushNotification>();
        Integer counter = 0 ;

        for(BL_ICON_PushNotification_Config.PushNotification push : pushListTemp){
            pushListNew.add(push);
            pushList.remove(pushList.indexOf(push));
            counter ++ ;
            if(counter == 10)  break ;
        }
        sendNotifications(pushListNew);
                
        if(!pushList.isEmpty() && !Test.isRunningTest()){
            AsyncSendNotification pushNotificationJob = new AsyncSendNotification(pushList);
            System.enqueueJob(pushNotificationJob);
        }  
    }

    public static void sendNotifications(List<BL_ICON_PushNotification_Config.PushNotification> pushList) {
        Set<String> userIds = new Set<String>();
        for(BL_ICON_PushNotification_Config.PushNotification push : pushList){
            userIds.addAll(push.userIds);

            Messaging.PushNotification msgPN = new Messaging.PushNotification();
            Map<String, Object> payload = push.userData;
            msgPN.setPayload(payload);
            try{
           	   msgPN.send('ICON_New_iOS', push.userIds);
            } catch(Exception e){
                system.debug(e.getMessage());
            }
        }

        Map<Id, User> chineseUsers = new Map<Id, User>([ 
            SELECT id, Lastname, FirstName, WWEmployeeNumber__c, MGMT_ZONE_SUB_LEVEL1__c, DefaultStore__c 
            FROM User 
            WHERE id IN: userIds AND MGMT_ZONE_SUB_LEVEL1__c = '1071' AND DefaultStore__c != NULL AND WWEmployeeNumber__c != NULL
        ]);  

        try{
            if(!chineseUsers.isEmpty()) {

                for(BL_ICON_PushNotification_Config.PushNotification push : pushList){
                    String notifType = (String) push.userData.get('Type');
                    List<User> chineseUsersPerNotif = new List<User>();
                    if(notifType != 'ClientList') continue;

                    for (string userId : push.userIds) {
                        if (chineseUsers.containsKey(userId)) {
                            chineseUsersPerNotif.add(chineseUsers.get(userId));
                        }
                    }
                    if(!chineseUsersPerNotif.isEmpty())
                        createWecomNotif(push, chineseUsersPerNotif);
                }
            }
        } catch(Exception e){
            system.debug(e.getMessage());
        }
    }

    public static void createWecomNotif(BL_ICON_PushNotification_Config.PushNotification pushitem,  List<User> users) {
       
        List<Map<String, String>> params = new List<Map<String, String>>();

        Map<String, Object> aps = (Map<String, Object>) pushitem.userData.get('aps');
        Map<String, Object> alert = (Map<String, Object>) aps.get('alert');
        String body = (String) alert.get('body');

        for (User user : users) {
            if(pushitem.userIds.contains(user.Id)) {
                params.add(new Map<String, String>{
                    'key'=> '早上好​',
                    'value'=> user.Lastname + ' ' + user.FirstName
                });
                params.add(new Map<String, String>{
                    'key'=> '通知内容​',    
                    'value'=> body
                });
                params.add(new Map<String, String>{
                    'key'=> '日期​',
                    'value'=> OnlineAppointments_Utils.getStoreLocalTime('Asia/Shanghai', System.today()).format('MM月dd日 下午','GMT') 
                });
                params.add(new Map<String, String>{
                    'key'=> '通知类型​',
                    'value'=> 'CD推送客户名单'
                });
    
                WechatWork_Notification_Center.sendNotification(
                    'ICON',
                    user.WWEmployeeNumber__c ,
                    'taro/pages/Notifications/Notifications',
                    '新客户名单',
                    '总部推送客户名单',
                    JSON.serialize(params));
            }
        }
    }
}