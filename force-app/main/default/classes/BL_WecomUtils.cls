public class BL_WecomUtils {
    @future(callout = true)
    public static void sendNotif(Map<String,String> notifDetails, Map<String,String> paramMap){
        List<Map<String, String>> params = new List<Map<String, String>>();
        params.add(new Map<String, String>{
            'key' => notifDetails.get('mainMessageKey'),
            'value' => notifDetails.get('mainMessage')
        });
        if(paramMap != null && !paramMap.isEmpty()){
            params.add(paramMap);
        }
       
        Wecome_MP_Assistant_Notification_Batch.sendNotification(
                                            WECOM_ICON_APPID__c.getOrgDefaults().AppId__c,
                                            notifDetails.get('lvMid'),
                                            notifDetails.get('path'),
                                            notifDetails.get('title'),
                                            notifDetails.get('description'),
                                            JSON.serialize(params));  
    }

}