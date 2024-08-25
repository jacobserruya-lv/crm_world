public with sharing class BL_ICON_Notification_Helper {
   

    public static Object getAllNotification(BL_UserInfo me, Integer page, Integer limitValue){

        return new BL_WS_Response (new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_NOTIFICATION)
                .condition('UserId__c = \'' + me.basicInfos.Id + '\''+'AND Push_Notification_Item__r.Is_Silent_Push__c=false AND IsNotificationDeleted__c = false AND (IsRead__c = False OR (IsRead__c =true and LastModifiedDate = LAST_N_DAYS:2))')
                .orderBy('CreatedDate DESC')
                .pagination(page, limitValue)
                .executeQuery()
                .getMappedObjects());

    }
    public static Object UpdateAllNotifications(BL_UserInfo me) {
        
        List<Map<String, Object>> notifs = new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_NOTIFICATION)
                .condition('UserId__c = \'' + me.basicInfos.Id + '\''+'AND Push_Notification_Item__r.Is_Silent_Push__c=false AND IsNotificationDeleted__c = false AND IsRead__c = False ')
                .executeQuery()
                .getMappedObjects();
        
        for(Map<String, Object> notif : notifs ) {
            if (notif.containsKey('isRead')){
                notif.put('isRead',true);
            }
        }
        
        return  UpdateNotificationAsRead(notifs) ;
    }
    
    public static Object UpdateNotificationAsRead(List<Object> records){
        try{
            

            Schema.sObjectField field = Push_Notification_Recipient__c.ExKey__c ;

            new BL_EasyQuery()
                    .useCase(BL_ICON_Constants.USE_CASE_NOTIFICATION)
                    .upsertWrappersWithChilds(records, field, null);
			

            return new Map<String, Object>{ 'status' =>'OK' };
            
        } catch(Exception ex){
            return new Map<String,Object> {'status' =>'error ' + ex};
        }

    }




}