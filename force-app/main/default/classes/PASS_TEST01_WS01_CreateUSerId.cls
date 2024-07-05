@isTest
private class PASS_TEST01_WS01_CreateUSerId {
    
    @isTest static void missingRequiredFields() {

        setup();
        Test.startTest();
            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');

            Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', null, null, null, null, 'France', 'Password2!!AA@');
            request.requestBody = Blob.valueof(JSON.serialize(body));
            
            RestContext.request = request;
            System.RestContext.response = new RestResponse();
            
            IDENTITY_Utils.ResponseHandler response=PASS_WS01_CreateUSerId.createUserIdentity();
        	system.assertEquals(response.message,'REQUIRED_FIELD_MISSING');
        	system.assertEquals('error',response.status);
        Test.stopTest();
    }

    @isTest static void passwordTooShort() {

        setup();
        Test.startTest();
            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');

            Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', 'test@test.com', null, null, null, 'France', 'pa');
            request.requestBody = Blob.valueof(JSON.serialize(body));
            
            RestContext.request = request;
            System.RestContext.response = new RestResponse();
            
            IDENTITY_Utils.ResponseHandler response=PASS_WS01_CreateUSerId.createUserIdentity();
        	system.assertEquals(response.message,'INVALID_NEW_PASSWORD_TOO_SHORT_OR_NOT_CONTAINS_NUMBER_OR_UPPERCASE');
        	system.assertEquals('error',response.status); 
        Test.stopTest();
    }

    @isTest static void passwordTooEasy() {

        setup();
        Test.startTest();
            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');

            Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', 'test', null, null, null, 'France', '123456');
            request.requestBody = Blob.valueof(JSON.serialize(body));
            
            RestContext.request = request;
            System.RestContext.response = new RestResponse();
            
            IDENTITY_Utils.ResponseHandler response=PASS_WS01_CreateUSerId.createUserIdentity();
        	system.assertEquals(response.message,'INVALID_NEW_PASSWORD_TOO_SHORT_OR_NOT_CONTAINS_NUMBER_OR_UPPERCASE');
        	system.assertEquals('error',response.status); 
        Test.stopTest();
    }

    @isTest static void invalidEmail() {

        setup();
        Test.startTest();
            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');

            Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', 'test', null, null, null, 'France', 'pa');
            request.requestBody = Blob.valueof(JSON.serialize(body));
            
            RestContext.request = request;
            System.RestContext.response = new RestResponse();
            
            IDENTITY_Utils.ResponseHandler response=PASS_WS01_CreateUSerId.createUserIdentity();
        	system.assertEquals(response.message,'INVALID_NEW_PASSWORD_TOO_SHORT_OR_NOT_CONTAINS_NUMBER_OR_UPPERCASE');
        	system.assertEquals('error',response.status); 
        Test.stopTest();
    }

    @isTest static void createAccountWithEmail() {

        setup();
        Test.startTest();
            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');

            String email = 'xxx'+IDENTITY_Utils.getRandomClientId()+'@xxx.com';

            Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', email, null, null, null, 'France', 'Password2!!AA@');
            request.requestBody = Blob.valueof(JSON.serialize(body));
            
            RestContext.request = request;
            System.RestContext.response = new RestResponse();
            
            IDENTITY_Utils.ResponseHandler response=PASS_WS01_CreateUSerId.createUserIdentity();
            System.debug('createAccountWithEmail');
            System.debug(response);
        	system.assertEquals(response.message,'Success : User Created');
        	system.assertEquals('success',response.status); 
        	
        Test.stopTest();
    }

    @isTest static void createAccountWithPhone() {

        setup();
        Test.startTest();
            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');

            Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', null, '0614378505', 'FR', '+33614378505', 'France', 'Password2!!AA@');
            request.requestBody = Blob.valueof(JSON.serialize(body));
            
            RestContext.request = request;
            System.RestContext.response = new RestResponse();
            
            IDENTITY_Utils.ResponseHandler response=PASS_WS01_CreateUSerId.createUserIdentity();
        	system.assertEquals(response.message,'Success : User Created');
        	system.assertEquals('success',response.status); 
        	String username=(String)response.data.get('Username'); 
            system.assertEquals('+33614378505@louisvuitton.com',username);
        Test.stopTest();
    }

    @isTest static void duplicateUsername() {

        setup();
        Test.startTest();
            
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            system.runAs(thisUser){        
                // First client
                RestRequest request = new RestRequest();
                request.httpMethod = 'POST';
                request.addHeader('Content-Type', 'application/json');

                String email = 'xxx'+IDENTITY_Utils.getRandomClientId()+'@xxx.com';

                Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', email, '0987654321', 'FR', '+33987654321', 'France', 'Password2!!AA@');
                request.requestBody = Blob.valueof(JSON.serialize(body));
                
                RestContext.request = request;
                System.RestContext.response = new RestResponse();
                
                IDENTITY_Utils.ResponseHandler response1=PASS_WS01_CreateUSerId.createUserIdentity();
                System.debug('Client 1');
                System.debug(response1);
                system.assertEquals(response1.message,'Success : User Created');
                system.assertEquals('success',response1.status); 
                String username=(String)response1.data.get('Username'); 
                system.assertEquals(email,username);

            
                // Second client
                request = new RestRequest();
                request.httpMethod = 'POST';
                request.addHeader('Content-Type', 'application/json');

                body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', email, '0987654321', 'FR', '+33987654321', 'France', 'Password2!!AA@');
                request.requestBody = Blob.valueof(JSON.serialize(body));
                
                RestContext.request = request;
                System.RestContext.response = new RestResponse();
                
                IDENTITY_Utils.ResponseHandler response=PASS_WS01_CreateUSerId.createUserIdentity();
                System.debug('Client 2');
                System.debug(response);
                system.assertEquals(response.message,'UNKNOWN_EXCEPTION: invalid repeated password');
                system.assertEquals('error',response.status); 
                system.assertEquals(null,response.data);
            }
        
        Test.stopTest();
    }

    public static void setup() {
        Identity_TestFactory.createSettings();
    }

    public static Map<String,Object> getBody(String title, String firstName, String lastName, String firstName2, String lastName2, String email, String localMobilePhone, String countryCode,
        String internationalMobilePhone, String country, String password) {
        Map<String, Object> body = new Map<String, Object>();
        body.put('title', title);
        body.put('firstName', firstName);
        body.put('lastName', lastName);
        body.put('firstName2', firstName2);
        body.put('lastName2', lastName2);
        body.put('email', email);
        body.put('country', country);
        body.put('localMobilePhone', localMobilePhone);
        body.put('countryCode', countryCode);
        body.put('internationalMobilePhone', internationalMobilePhone);
        body.put('password', password);
        return body; 
    }
}