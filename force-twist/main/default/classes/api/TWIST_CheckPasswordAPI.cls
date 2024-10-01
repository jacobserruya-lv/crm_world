@RestResource(urlMapping='/CheckPassword')
global with sharing class TWIST_CheckPasswordAPI {
    public final static String GENERIC_ERROR = 'GENERIC_ERROR';
    public final static String USERNAME = 'username';
    public final static String PASSWORD = 'password';

    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        Map<String,Object> responseMap = new Map<String,Object>();
        response.addHeader('Content-Type','application/json');

        List<String> requiredFields = new List<String>{USERNAME, PASSWORD};

        try {

            if(String.isBlank(request.requestBody.toString())){
                throw new CustomException(Label.EM_required_field_missing + ' : EMPTY BODY');
            }
           Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(request.requestBody.toString());

           String missingRequiredFields = getMissingRequiredFields(requiredFields, body);

            if(!String.isBlank(missingRequiredFields)){
                throw new CustomException(Label.EM_required_field_missing + ' : ' + missingRequiredFields);
            }

            String userName = String.ValueOf(body.get('username'));
            String password = String.ValueOf(body.get('password'));

            String userId = getUserId(username);

            if(userId == null){
                throw new CustomException(Label.EM_User_Not_Found);
            } 
            response.statusCode = 200;

            if (isMatchPasswordUsername(userName, password)) {
                responseMap = TWIST_Utils.buildSuccessResponseObject('match', True);
                TWIST_Settings__c setting = TWIST_Settings__c.getInstance();
                Decimal duration = setting.Password_checked_duration__c;
                List<TwistCacheManager__c> cache = [SELECT id, Value__c, TTL__c FROM TwistCacheManager__c WHERE Type__c = 'CHECKED_PASSWORD' and Key__c =:userName];
                if(!cache.isEmpty()){
                    cache[0].Last_password_date__c = Date.valueOf(cache[0].Value__c);
                    cache[0].Value__c = String.valueOf(DateTime.now());
                    cache[0].TTL__c = duration;
                    update cache;
                }
                else{
                    TwistCacheManager__c tcm = new TwistCacheManager__c (Key__c= userName, Last_password_date__c= Date.today(), Value__c= String.valueOf(DateTime.now()), TTL__c= duration, Type__c= 'CHECKED_PASSWORD');
                    insert tcm;
                }

            }
            else{
                responseMap = TWIST_Utils.buildSuccessResponseObject('match', False);
            }
        }
        catch (Exception e) {
            String errorMessage = e.getTypeName().contains('CustomException') ? e.getMessage() : GENERIC_ERROR;
            responseMap = TWIST_Utils.buildFailureResponseObject('message', errorMessage);
            response.statusCode = 400;
        }
        response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
    }

    @TestVisible
    private static Boolean isMatchPasswordUsername(String username, String password){

        TWIST_Settings__c setting = TWIST_Settings__c.getInstance();
        String loginXmlBody = getLoginXmlBody(userName, password);

        HttpRequest soapRequest = new HttpRequest();
        soapRequest.setEndpoint(setting.Host__c+'/services/Soap/c/'+setting.Version__c);
        soapRequest.setTimeout(60000); 
        soapRequest.setMethod('POST');
        soapRequest.setHeader('SOAPAction', 'login');
        soapRequest.setHeader('Accept','text/xml');
        soapRequest.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        soapRequest.setBody(loginXmlBody);       

        HttpResponse soapResponse = new Http().send(soapRequest);

        Integer statusCode = soapResponse.getStatusCode();
        if(statusCode == 200){
            return true;
        }
        return false;
    }

    @TestVisible
    private static String getLoginXmlBody(String userName, String password){
        String loginXML = '';
        loginXML = '<?xml version="1.0" encoding="utf-8"?>';  
        loginXML += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">';  
        loginXML += '<soapenv:Header>';  
        loginXML += '<urn:LoginScopeHeader>';  
        loginXML += '<urn:organizationId>'+ UserInfo.getOrganizationId() +'</urn:organizationId>';  
        loginXML += '</urn:LoginScopeHeader>';  
        loginXML += '</soapenv:Header>';  
        loginXML += '<soapenv:Body>'; 
        loginXML += '<urn:login>';
        loginXML += '<urn:username>'+ userName +'</urn:username>';
        loginXML += '<urn:password>'+ password +'</urn:password>';
        loginXML += '</urn:login>'; 
        loginXML += '</soapenv:Body>';  
        loginXML += '</soapenv:Envelope>';
        return loginXML;
    }

    @TestVisible
    private static String getUserId(String username){
        List<User> users = [SELECT id, UserName from user WHERE UserName =: userName];
        if(!users.isEmpty()){
            return users[0].Id;
        }  
        return null;
    }

    @TestVisible
    private static String getMissingRequiredFields(List<String> requiredFields, Map<String, Object> body){
        List<String> missingFields = new List<String>();

        for (String key : requiredFields){
            if(!body.containsKey(key) || String.isBlank(String.ValueOf(body.get(key)))){
                missingFields.add(key);
            }
        }

        if(!missingFields.isEmpty()){
            return String.join(missingFields, ' | ');
        }
          
        return null;
    }

    public class CustomException extends Exception {}

}
