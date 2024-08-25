/**
* @File Name          : TWIST_LoginServiceAPI_TEST
* @Description        : 
* @Author             : SFID Team
* @Group              : 
* @Last Modified By   : SFID Team
* @Last Modified On   : 21-12-2022
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       21-12-2022      Imad.alsidchikh.ext@louisvuitton.com     Initial Version
**/
@isTest
public class TWIST_LoginServiceAPI_TEST {
    
    @testSetup  
    static void initData(){
        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.AOB_Cert_Name__c = 'cert_name_test';
        settings.AOB_Client_Id__c = 'client_id_test';
        settings.Auth_Path__c = 'auth_path_test';
        settings.AOB_Site_URL__c= 'comm_url_test';
        settings.Password_Maxlength__c = 20;
        insert settings;
    }
    private static final String PRE_CREATED_CERTIFICATE_NAME = 'JWT';
    private static final String FAKE_TOKEN = 'TEIDUCLKHKJGVJNLKJKJBJHVJHBl';
    
    private class Mock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String userName;
            String password;
            HTTPResponse res = new HTTPResponse();
            System.assertEquals('POST', req.getMethod());
            System.assert(req.getBody().contains('login'), req.getBody());
            System.assert(req.getBody().contains('username'), req.getBody());
            System.assert(req.getBody().contains('password'), req.getBody());
            if(req.getBody().contains('test001-servicelogin@twist.fr') && req.getBody().contains('HDtfqawdv5435!')){ 
                res.setStatusCode(200);
                res.setBody(getXmlBody(FAKE_TOKEN)); 
            }else if(req.getBody().contains('1234')){  
                res.setStatusCode(400);
                res.setBody(getXmlBody('Bad_Request'));
            }else{
                res.setStatusCode(400);
                res.setBody('');  
            }
            return res;
        }
    }
    @isTest 
    static void testMethodPost(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/LoginService/';
        req.addHeader('Content-Type','application/json');  
        String body = '{"username":"test001-servicelogin@twist.fr","password":"HDtfqawdv5435!"}';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        // EMPTY BODY
        req.requestBody = Blob.valueOf('');
        Test.setMock(HttpCalloutMock.class, new Mock());
        TWIST_LoginServiceAPI.login();
        System.assertEquals(RestContext.response.statusCode,400);
        req.requestBody = Blob.valueOf(body);
        TWIST_LoginServiceAPI.login();
        Test.stopTest();
        System.assertEquals(RestContext.response.statusCode,200);
    }
    @isTest 
    static void testMethodPost2(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/LoginService/';
        req.addHeader('Content-Type','application/json');  
        String body = '{"username":"test001-servicelogin@twist.fr","password":"123"}';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        TWIST_LoginServiceAPI.login();
        Test.stopTest();
        System.assertEquals(RestContext.response.statusCode,400);  
    }
    @isTest 
    static void testMethodPost3(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/LoginService/';
        req.addHeader('Content-Type','application/json');  
        String body = '{"username":"","password":"1234"}';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = res;   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        TWIST_LoginServiceAPI.login();
        Test.stopTest();
        System.assertEquals(RestContext.response.statusCode,400);
        
    }
    private static String getXmlBody(String sessionId){
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
        loginXML += '<sessionId>'+ sessionId +'</sessionId>';          
        loginXML += '</urn:login>'; 
        loginXML += '</soapenv:Body>';  
        loginXML += '</soapenv:Envelope>';
        return loginXML;
    }
}