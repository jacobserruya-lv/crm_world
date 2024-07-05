public with sharing class MarketingCloud_API {
    
    public static Map<String,Object> sendNotification(Notification__c notification, Map<String,Object> params){

        Map<String,Object> session = getSessionId();

        Account client = [SELECT Id, PersonEmail, PersonContactId
            FROM Account
            WHERE Id = :notification.Client__c];

        Map<String,Object> body = new Map<String,Object>{
            'ContactKey' => client.PersonContactId,
            'EventDefinitionKey' => SETTINGS.get(EVENT_KEY),
            'Data' => new Map<String,Object>{}
        };

        // Settings
        ((Map<String,Object>)body.get('Data')).put('Message_Id', (Object)notification.Message_Id__c);
        ((Map<String,Object>)body.get('Data')).put('email', client.PersonEmail);
        ((Map<String,Object>)body.get('Data')).put('account_id', client.Id);
        ((Map<String,Object>)body.get('Data')).put('contact_id', client.PersonContactId);

        // Parameters
        for(String key : params.keySet()){
            ((Map<String,Object>)body.get('Data')).put(key, (Object)params.get(key));
        }
        system.debug(body);
        HTTP_Utils response = new HTTP_Utils()
            .post(getDomain(null) + SETTINGS.get(EVENT))
            .header('Authorization', 'Bearer ' + session.get('access_token'))
            .header('Content-Type', 'application/json')
            .body(JSON.serialize(body))
            .call();

            System.debug('REQUEST BODY: ' + JSON.serialize(body));

        System.debug('RESPONSE CODE: ' + response.statusCode());
        System.debug('RESPONSE BODY: ' + response.responseBody());

        // INSERT IN DB
        insert notification;
        insert Notification_Sender.setNotificationParameters(params, notification.channel__c, notification.external_Id__c);

        Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody());

        if(response.statusCode() == 201 || response.statusCode() == 200) {
            notification.Status__c = 'CLOSED';
            upsert notification;
        }
        else{
            new Logs( new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'MarketingCloud_API', 
                'category' => 'CALLOUT',
                'http' => response,
                'message' => data.get('message'),
                'type' => String.valueOf((Decimal)data.get('errorcode'))
            });
        }


        return data;
    }

    /*
    *** DESCRIPTION GET Session number and its confirmation, need to call other API
    *** RETURN      Map of session parameters
    */
    public static Map<String,Object> getSessionId(){

        Map<String,Object> body = new Map<String,Object>{
            'grant_type' => 'client_credentials',
            'client_id' => SETTINGS.get(USERNAME),
            'client_secret' => SETTINGS.get(PASSWORD),
            'scope' => SETTINGS.get(SCOPE)
        };
    
        HTTP_Utils response = new HTTP_Utils()
            .post(getDomain(SETTINGS.get(TOKEN)))
            .header('Content-Type', 'application/json')
            .body(JSON.serialize(body))
            .call();

        System.debug('RESPONSE BODY: ' + response.responseBody());

        if(response.statusCode() == 200){
            return (Map<String,Object>)JSON.deserializeUntyped(response.responseBody());
        }
        
        throw new CustomException(response.responseBody());
    }

    /*
    *** DESCRIPTION GET Endpoint: URL
    *** RETURN      String endpoint 
    */
    public static String getDomain(String url){

        if(String.isEmpty(url)){
            url = SETTINGS.get(ENDPOINT);
        }

        url = url.replace('{org}', SETTINGS.get(ORG));

        return url;
    }

    public static Map<String,String> SETTINGS;
    public final static String ENDPOINT;
    public final static String USERNAME;
    public final static String PASSWORD;
    public final static String EVENT;
    public final static String TOKEN;
    public final static String ORG;
    public final static String EVENT_KEY;
    public final static String SCOPE;

    static {
        SETTINGS = ThirdParty_Utils.getSettings('Marketing_Cloud');

        ENDPOINT = 'endpoint';
        USERNAME = 'username';
        PASSWORD = 'password';
        TOKEN = 'token';
        EVENT = 'event';
        EVENT_KEY = 'eventDefinitionKey';
        ORG = 'org';
        SCOPE = 'scope';
    }

    public class CustomException extends Exception {}
}