/**
* @File Name          : TWIST_LoginServiceAPI
* @Description        : 
* @Author             : SFID Team
* @Group              : 
* @Last Modified By   : SFID Team
* @Last Modified On   : 21-12-2022
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       21-12-2022      Imad.alsidchikh.ext@louisvuitton.com     Initial Version
**/
@RestResource(urlMapping='/LoginService/*')
global with sharing class TWIST_LoginServiceAPI {
    
    @HttpPost
    global static LoginResponse login() {
        
        RestResponse resLs = RestContext.response;
        resLs.addHeader('Content-Type', 'application/json');
        resLs.statusCode = 200;
        LoginResponse objResponse = new LoginResponse();
        objResponse.statusMessage = 'Starting';
        
        RestRequest req = RestContext.request;
        if(String.isNotBlank(req.requestBody.toString())){
            Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
            String userName = String.ValueOf(body.get('username'));
            String pass = String.ValueOf(body.get('password'));
            String password = pass.replace('&', '&amp;')
                                       .replace('<', '&lt;')
                                       .replace('>', '&gt;');
            String loginXmlBody = '';
            try{
                //Send Soap Login to check password
                TWIST_Settings__c setting = TWIST_Settings__c.getInstance();
                loginXmlBody = getLoginXmlBody(userName, password);
                HttpRequest request = new HttpRequest();
                request.setEndpoint(setting.Host__c+'/services/Soap/c/'+setting.Version__c);
                request.setTimeout(60000); 
                request.setMethod('POST');
                request.setHeader('SOAPAction', 'login');
                request.setHeader('Accept','text/xml');
                request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
                request.setBody(loginXmlBody);       
                HttpResponse response = new Http().send(request);
                String responseBody = response.getBody();
                String sessionId = getValueFromXMLString(responseBody, 'sessionId');
                objResponse.statusMessage = response.getStatus();
                objResponse.statusCode = response.getStatusCode();
                objResponse.accessToken = sessionId;
                if(string.isNotBlank(sessionId)){
                    objResponse.accessToken = getJWTAccessToken(username,setting);
                    if(string.isNotBlank(objResponse.accessToken) && objResponse.accessToken.startswith(String.valueOf(UserInfo.getOrganizationId()).substring(0, 15))){
                        objResponse.isSuccess = true; 
                        objResponse.userId = TWIST_Utils.getUserByEmail(username).get('Id');
                        objResponse.siteUrl = setting.AOB_Site_URL__c;                        
                    }else{
                        objResponse.isSuccess = false;
                        objResponse.statusMessage = objResponse.accessToken;
                        objResponse.accessToken = '';
                        objResponse.userId = '';
                        objResponse.siteUrl= '';
                        objResponse.statusCode = 400;
                        resLs.statusCode= objResponse.statusCode;
                    }
                }else{
                    objResponse.isSuccess = false;
                    objResponse.statusMessage = 'Invalid credentials';
                    objResponse.userId = '';
                    objResponse.siteUrl= '';
                    resLs.statusCode= objResponse.statusCode;
                }
            }catch(System.Exception ex){
                objResponse.isSuccess = false;
                objResponse.statusMessage = ex.getStackTraceString()+ loginXmlBody;
                //Create Log 
                new Logs(new Map<String,Object> {
                    'level' => 'ERROR',
                    'apexClass' => 'TWIST_LoginServiceAPI',
                    'category' => 'API',
                    'message' => ex.getMessage()
                });
            }
        }else{
            resLs.statusCode=400; 
        }
        return objResponse;
    }
    
    /*
* Get XML tag value from XML string
* @param xmlString : String XML
* @param keyField : XML key tag
* @return String : return XML tag key value
*/
    public static string getValueFromXMLString(string xmlString, string keyField){
        String xmlKeyValue = '';
        if(xmlString.contains('<' + keyField + '>')){
            xmlKeyValue = xmlString.substring(xmlString.indexOf('<' + keyField + '>')+keyField.length() + 2, xmlString.indexOf('</' + keyField + '>'));
        }
        return xmlKeyValue;
    }
    private static String getJWTAccessToken(String username,TWIST_Settings__c setting) {
        try {
            return SFID_Utils.getJWTAccessToken(username, setting.AOB_Client_Id__c, setting.AOB_Site_URL__c, setting.AOB_Cert_Name__c, setting.Auth_Path__c);
        }
        catch (Exception ex) {
            new Logs(new Map<String,Object> {
                'level' => 'ERROR',
                'apexClass' => 'TWIST_LoginServiceAPI',
                'category' => 'API',
                'message' => ex.getMessage()
            });
            return ex.getMessage();
        }
    }
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
    global class LoginResponse {
        public Boolean  isSuccess {get; set;}
        public String   statusMessage {get; set;}
        public Integer  statusCode {get; set;}
        public String   userId{get; set;}
        public String   siteUrl{get; set;}
        public String   accessToken {get; set;}
    }
    
}