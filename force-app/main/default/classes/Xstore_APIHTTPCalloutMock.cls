@isTest
global class Xstore_APIHTTPCalloutMock implements HttpCalloutMock { //MIY-2092
  // Implement this interface method
  global HTTPResponse respond(HTTPRequest req) {
   
    // Create a fake response
    HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{"message": "Deposit Amount from Xstore Sucessful updated on Salesforce"}');
      response.setStatusCode(200);
    return response;
  }
}