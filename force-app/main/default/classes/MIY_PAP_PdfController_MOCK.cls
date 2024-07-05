@isTest
public with sharing class MIY_PAP_PdfController_MOCK implements HttpCalloutMock{
    private String statusCode;
    
    public MIY_PAP_PdfController_MOCK(String statusCode){
        this.statusCode = statusCode;
    }

    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        
        response.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        response.setHeader('instanceurl', Url.getOrgDomainUrl().toExternalForm());
        response.setBody('testBody');

        if(this.statusCode == '200'){
            response.setStatusCode(200);
        }
        else{
            response.setStatusCode(Integer.valueOf(this.statusCode));
        }
        
        return response; 
    }
}