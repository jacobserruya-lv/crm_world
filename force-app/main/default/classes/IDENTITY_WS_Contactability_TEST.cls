@isTest
private class IDENTITY_WS_Contactability_TEST {
	
	@isTest static void test_method_one() {
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/contactability';
        req.addHeader('Content-Type','application/json');
                
        RestContext.request = req;
        RestContext.response = res;

        Account acc;
        
        Test.startTest();
            // EMPTY BODY
            req.requestBody = Blob.valueOf('');
            IDENTITY_WS_Contactability.create();

            // MISSING REQUIRED FIELDS
            acc = IDENTITY_TestFactory.createAccount('firstName', null, null, null, '33', false);
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_Contactability.create();

            // BY DREAM ID
            acc = IDENTITY_TestFactory.createAccount('firstName', 'lastName', 'email@tyest.com', '0621052615', '33', false);
            acc.DreamID__c = '123654';
            insert acc;
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_Contactability.create();

            // BY SF ID
            acc = IDENTITY_TestFactory.createAccount('firstName', 'lastName', 'email@tyest.com', '0621052615', '33', true);
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_Contactability.create();

            // BY IDENTIFIER FIELDS
            acc = IDENTITY_TestFactory.createAccount('firstName', 'lastName', 'email2@tyest.com', '0621052615', '33', false);
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_Contactability.create();

            // BY EMAIL
            acc = IDENTITY_TestFactory.createAccount(null, null, 'email2@tyest.com', null, '33', false);
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_Contactability.create();

            // BY PHONE
            acc = IDENTITY_TestFactory.createAccount(null, null, null, '0621052615', '33', false);
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_Contactability.create();
        Test.stopTest();
	}
}