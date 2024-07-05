@isTest
global class WS_RMS_Document_Mock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assert(req.getEndpoint().contains('EAI_CustomerDocumentsAPI/1.0/LVCustomerDocumentsAPI/v1/webServices/resources/CustomerDocuments'));
        //System.assertEquals('POST', req.getMethod());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"LVResponse": {"data": {"Documents":[{"transactionID":"Transaction1","binaryDoc":["Blob1"]},{"transactionID":"Transaction2","binaryDoc":["Blob2"]}]}}}');
        res.setStatusCode(200);
        return res;
    }
}