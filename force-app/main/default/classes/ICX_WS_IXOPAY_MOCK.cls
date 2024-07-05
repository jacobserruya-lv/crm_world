/*	 * @author Keman WU
* @date creation 28/07/2023
* @description Mock class for ICX_WS_IXOPAY
*/
@isTest
global class ICX_WS_IXOPAY_MOCK implements HttpCalloutMock {
    global HTTPResponse respond(HttpRequest req) {
     
        // Create a fake response
        HttpResponse res = new HttpResponse();
       
        res.setHeader('Content-Type', 'application/json');     
        res.setBody('{'+
		'    "success": true,'+
		'    "uuid": "ee46d2e01d9032474f89",'+
		'    "purchaseId": "20230728-ee46d2e01d9032474f89",'+
		'    "returnType": "REDIRECT",'+
		'    "redirectUrl": "https://louisvuitton.ixopaysandbox.com/redirect/ee46d2e01d9032474f89/YzdmMjliN2Q3ZTk5ZDQzZjYzODI2NWU2ZTE2ODExOTNjM2U3NmY3NTdlYmQ5ODg1M2NkMjkyMGE3OWI2NGE4NjdmYzQ5M2IxNmM3MGMzN2RkMmU3NzVhMmY4NzEzMTExMTZkN2MxZjU3OTQ0NWRiZjdkYzdkZjFlMDhlYzI3ODA="'+
		'}');

        res.setStatusCode(200);
        return res;
    }

}