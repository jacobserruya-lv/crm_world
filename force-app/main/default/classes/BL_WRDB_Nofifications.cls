@RestResource(urlMapping='/wrdb-notifications/*')
global without sharing class BL_WRDB_Nofifications {
  
        /*=================================================================================================================*/
        //HTTP Request POST called 

        @HttpPost
        global static void post() {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            try{
                
                String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
                res.addHeader('Content-Type','application/json');
                res.statusCode = 200;
                string response;
                Push_Notification_Item__c p = new Push_Notification_Item__c();
                Map<String, String> body = new  Map<String, String>();
                Map<String, String> results = new Map<String, String>();
                if (req.requestBody != null) {
                    body = (Map<String,String>) JSON.deserialize(req.requestBody.toString(), Map<String,String>.class);
                    p = buildNotification(body.get('sharingId'), body.get('ownerId'), body.get('clientId') ,body.get('wardrobingName'));
                
                    results = new Map<String, String>{'clientName' => body.get('clientId') , 'objectId'=> body.get('sharingId')};
                    insert BL_ICON_PushNotification_Config.createPushItemRecipient(body.get('ownerId'),p.id ,JSON.serialize(results));
                }
                res.responseBody = Blob.valueOf(JSON.serialize(p));
            }
            catch(Exception ex){
                res.responseBody =  Blob.valueOf(JSON.serialize('error'));
                res.statusCode = 400;
            }
        }

        public static Push_Notification_Item__c buildNotification(String sharingId ,String userId , String clientId , String wardrobingName) {

            String lang = [SELECT id ,LanguageLocaleKey FROM User where Id =: userId LIMIT 1 ]?.LanguageLocaleKey ;
            String clientName = [SELECT id ,name FROM Account where Id =: clientId LIMIT 1 ]?.name ;
            String  placeholder = IM_SendPushNotifications.getNotificationTemplate(lang, 'WardrobingLike__c');
            List<String> fillers = new String[]{  wardrobingName,clientName} ;

            Push_Notification_Item__c pushObj = new Push_Notification_Item__c();
            pushObj.Body__c = String.format(placeholder, fillers);
            pushObj.Title__c = '';
            pushObj.Type__c = 'Wardrobing';
            pushObj.ObjectId__c = sharingId;
            pushObj.UsersIds__c = userId ;
            pushObj.UserRecipient__c = (Id) userId;

            insert pushObj; 
            return pushObj;

        }




    
    
    }