@isTest
public class HttpResponseMock_TEST {

    @isTest
    static void testHttpResponseMock() {
        HttpResponseMock mock = new HttpResponseMock();
        
        // Set headers and other attributes
        mock.addHeader('Custom-Header', 'TestHeaderValue')
            .setStatusCode(404)
            .setStatus('Not Found')
            .setBody('This is a test response body');
        
        HttpResponse response = mock.getResponse();
        
        System.assertEquals('TestHeaderValue', response.getHeader('Custom-Header'));
        System.assertEquals(404, response.getStatusCode());
        System.assertEquals('Not Found', response.getStatus());
        System.assertEquals('This is a test response body', response.getBody());
    }

    @isTest
    static void testHttpResponseMockWithParameters() {
        Map<String, String> headers = new Map<String, String>{
            'Header1' => 'Value1',
            'Header2' => 'Value2'
        };
        Integer statusCode = 500;
        String status = 'Internal Server Error';
        String body = 'Custom error message';

        HttpResponseMock mock = new HttpResponseMock(headers, statusCode, status, body);
        
        HttpResponse response = mock.getResponse();
        
        System.assertEquals('Value1', response.getHeader('Header1'));
        System.assertEquals('Value2', response.getHeader('Header2'));
        System.assertEquals(500, response.getStatusCode());
        System.assertEquals('Internal Server Error', response.getStatus());
        System.assertEquals('Custom error message', response.getBody());
    }

    @isTest
    static void testSetBodyWithMap() {
        Map<String, Object> expectedBodyMap = new Map<String, Object>{
            'key1' => 'value1',
            'key2' => 42,
            'key3' => true
        };
    
        HttpResponseMock mock = new HttpResponseMock();
        mock.setBody(expectedBodyMap);
    
        HttpResponse response = mock.getResponse();
    
        String expectedBodyJson = JSON.serialize(expectedBodyMap);
        String actualBodyJson = response.getBody();
    
        // Deserialize both JSON strings into maps for comparison
        Map<String, Object> expectedMap = (Map<String, Object>)JSON.deserializeUntyped(expectedBodyJson);
        Map<String, Object> actualMap = (Map<String, Object>)JSON.deserializeUntyped(actualBodyJson);
    
        System.assertEquals(expectedMap, actualMap);
    }
}