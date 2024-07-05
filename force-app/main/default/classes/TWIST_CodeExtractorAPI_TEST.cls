@isTest
public class TWIST_CodeExtractorAPI_TEST {
    @isTest
    static void testDoGetSucess() {
        // test data
        
        RestRequest mockRequest = new RestRequest();
        RestResponse mockResponse = new RestResponse();
        RestContext.request = mockRequest;
        RestContext.response = mockResponse;
        mockRequest.httpMethod = 'GET';
        mockRequest.requestURI = '/services/apexrest/code/extraction';
        mockRequest.addHeader('Content-Type','application/json');
        mockRequest.addParameter('code', 'code_value');
        mockRequest.addParameter('sfdc_community_url', 'community_url_value');
        mockRequest.addParameter('sfdc_community_id', 'community_id_value');
        mockRequest.addParameter('state', 'state_value');
         
        Test.startTest(); 
         
        TWIST_CodeExtractorAPI.CodeResponseWrapper result = new TWIST_CodeExtractorAPI.CodeResponseWrapper();
        result = TWIST_CodeExtractorAPI.doGet();
        Test.stopTest();
        
        //   results check
        System.assertEquals(200, mockResponse.statusCode); // statut code check
        System.assertEquals('code_value', result.code );
        System.assertEquals('community_url_value', result.sfdcCommunityUrl);
        System.assertEquals('community_id_value', result.sfdcCommunityId);
        System.assertEquals('state_value', result.state);
        System.assertEquals(true, result.success );
    }
    
    @isTest
    static void testDoGetMissingParams() {
        // test data
        
        RestRequest mockRequest = new RestRequest();
        RestResponse mockResponse = new RestResponse();
        RestContext.request = mockRequest;
        RestContext.response = mockResponse;
        mockRequest.httpMethod = 'GET';
        mockRequest.requestURI = '/services/apexrest/code/extraction';
        mockRequest.addHeader('Content-Type','application/json');
      
        Test.startTest(); 
        
        TWIST_CodeExtractorAPI.CodeResponseWrapper result = new TWIST_CodeExtractorAPI.CodeResponseWrapper();
        result = TWIST_CodeExtractorAPI.doGet();
        Test.stopTest();
        
        // results check
        System.assertEquals(400, mockResponse.statusCode); // status code check
        System.assertEquals('Missing parameters', result.errMsg );
        System.assertEquals(false, result.success );
       
    }
}