@RestResource(urlMapping='/PushNotfication/*')
global with sharing class IM_WS_PushNotifications {
	@HttpPost
    global static void post() {
        RestRequest req = RestContext.request;
        String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        system.debug(req.requestBody.toString());
        system.debug(req.params);
        Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 200;
        string response;

        try{
            if(service == ''){
                response = JSON.serialize(createPushNotifications(body));
            }
            res.responseBody = Blob.valueOf(response);
            UtilsLogs.addLog('ICON','IM_WS_PushNotifications', JSON.serialize(req.params), '', response, '');
        }
        catch(Exception ex){
            string error = ex.getMessage() + '\n\n' + ex.getLineNumber();
            res.responseBody = Blob.valueOf(error);
            res.statusCode = 400;
            UtilsLogs.addLog('ICON', 'IM_WS_PushNotifications', JSON.serialize(req.params), '','', error);
        }
    }

    global static Push_Notification_Item__c createPushNotifications(Map<String,Object> body){
    	Push_Notification_Item__c push = new Push_Notification_Item__c(
    		Title__c = (String)body.get('Title__c'),
    		Type__c = (String)body.get('Type__c'),
    		ObjectId__c = (String)body.get('ObjectId__c'),
    		UsersIds__c = (String)body.get('UsersIds__c')
		);
    	insert push;
    	return push;
    }
}