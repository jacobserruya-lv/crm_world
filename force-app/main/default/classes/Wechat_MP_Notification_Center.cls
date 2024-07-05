public with sharing class Wechat_MP_Notification_Center {

    public static String state;

    public static HTTP_Utils sendNotification(Notification__c notification, Map<String, Object> params) {
        if(notification.application__c == 'WECHAT DIAMOND APPOINTMENT') {
            
                return sendNotification('DIAMOND', notification.message_id__c, (String) params.get('wechat_openId'), 'package-mall/pages/appointment-list/appointment-list', params);
            }
            else if(notification.application__c == 'WECHAT ONLINE APPOINTMENT') {
                return sendNotification('SCRM', notification.message_id__c, (String) params.get('wechat_openId'), 'package-olbooking/pages/my-appointments-list/my-appointments-list', params);
            }
        
        return null;
    }
    
    public static HTTP_Utils sendNotification(String appid, String templateId, String openid,String page, Map<String, Object> params){
        
        Map<String, Object> body = new Map<String, Object> {
            'touser'=> openid,
            'template_id' => templateId,
            'page' => page,
            //'miniprogram_state' => miniprogram_state,
            'lang' => 'zh_CN',
            'data' =>  params
        };
        state = String.isBlank(state) ? ([SELECT isSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId()][0].isSandbox ? (URL.getSalesforceBaseUrl().toExternalForm().contains('pprod') ? 'trial' : 'developer') : null) : state;
        if(state != null){
            body.put('miniprogram_state', state);
        }
        system.debug(JSON.serialize(body));
        HTTP_Utils response = new HTTP_Utils()
                    .post('callout:LV_OSA_WECHAT/wechat/messaging/mp?app_id='+appid)
                    .header('Content-Type', 'application/json;charset=UTF-8')
                    .body(JSON.serialize(body))
                    .call();

                    system.debug(response);

                    return response;
    }

}