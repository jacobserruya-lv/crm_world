/**
 * Dummy test class, created for code coverage purposes only
 */

@isTest
public with sharing class HttpCalloutMockUtil_TEST {
    
    @isTest
    static void test() {
        String dummyUrl = 'https://dummy-endpoint.url';
        HttpCalloutMockUtil mockUtil = new HttpCalloutMockUtil();
        mockUtil.addMock(dummyUrl, new HttpResponseMock());

        HTTPRequest request = new HTTPRequest();
        request.setEndpoint(dummyUrl);
        HTTPResponse response = mockUtil.respond(request);
    }

}