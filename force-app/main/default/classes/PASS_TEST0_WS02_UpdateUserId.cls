@isTest
private class PASS_TEST0_WS02_UpdateUserId {
    
    @isTest static void updateUserIdentityById() {

        Test.startTest();

            setup();
            User u = [SELECT Id FROM User WHERE Username =: 'test456321@test.com' LIMIT 1];

            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');

            Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', null, '0614378505', 'FR', '+33614378505', 'France', null, null);
            request.requestBody = Blob.valueof(JSON.serialize(body));
            
            RestContext.request = request;
            System.RestContext.response = new RestResponse();

            System.RunAs(u){
                IDENTITY_Utils.ResponseHandler response=PASS_WS02_UpdateUserId.UpdateUserIdentity();
                system.assertEquals(response.message,'Success : User and Account Updated');
                system.assertEquals(response.Status,'success');
                String username=(String)response.data.get('Username'); 
            	system.assertEquals(null,username);
            }
        	
            
        Test.stopTest();
       
    }

    @isTest static void updateUserIdentityByIdWithCollectible() {

        Test.startTest();

            setup();
            User u = [SELECT Id,accountId FROM User WHERE Username =: 'test456321@test.com' LIMIT 1];

            Collectible_Wallet__c c1 =  new Collectible_Wallet__c(Wallet_Id__c = '1234', Client__c = u.accountId);
            Collectible_Wallet__c c2 =  new Collectible_Wallet__c(Wallet_Id__c = '12344', Client__c = u.accountId);
            insert new List<Collectible_Wallet__c>{ c1, c2 };

            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');

            Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', null, '0614378505', 'FR', '+33614378505', 'France', null, null);

            body.put('wallets', new List<Object>{ 
                                        new Map<String,String>{'new' => '123'},
                                        new Map<String,String>{'old' => '1234'},
                                        new Map<String,String>{'old' => '12344', 'new' =>'111'}
                                    });

            request.requestBody = Blob.valueof(JSON.serialize(body));

            RestContext.request = request;
            System.RestContext.response = new RestResponse();

            System.RunAs(u){
                IDENTITY_Utils.ResponseHandler response=PASS_WS02_UpdateUserId.UpdateUserIdentity();
                system.assertEquals(response.message,'Success : User and Account Updated');
                system.assertEquals(response.Status,'success');
                String username=(String)response.data.get('Username'); 
            	system.assertEquals(null,username);
            }
        	
            
        Test.stopTest();
        
    }

    @isTest static void duplicateUsername() {

        Test.startTest();

            setup();
            User u = [SELECT Id FROM User WHERE Username =: 'test456321@test.com' LIMIT 1];

            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');

            Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', 'test2@test.com', '0614378505', 'FR', '+33614378505', 'France', null, null);
            request.requestBody = Blob.valueof(JSON.serialize(body));
            
            RestContext.request = request;
            System.RestContext.response = new RestResponse();

            System.RunAs(u){
                IDENTITY_Utils.ResponseHandler response=PASS_WS02_UpdateUserId.UpdateUserIdentity();
                system.assertEquals(response.message,'DUPLICATE_USERNAME');
                system.assertEquals(response.Status,'error'); 
            	system.assertEquals(null,response.Data);
            }
            
        Test.stopTest();
        
    }

    @isTest static void invalidEmail() {

        Test.startTest();

            setup();
            User u = [SELECT Id FROM User WHERE Username =: 'test456321@test.com' LIMIT 1];

            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');

            Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', 'test2', '0614378505', 'FR', '+33614378505', 'France', null, null);
            request.requestBody = Blob.valueof(JSON.serialize(body));
            
            RestContext.request = request;
            System.RestContext.response = new RestResponse();

            System.RunAs(u){
                IDENTITY_Utils.ResponseHandler response=PASS_WS02_UpdateUserId.UpdateUserIdentity();
                system.assertEquals(response.message,'Update failed. First exception on row 0 with id ' +u.Id+'; first error: INVALID_EMAIL_ADDRESS, E-mail: adresse e-mail non valable : test2: [Email]');
                system.assertEquals(response.Status,'error'); 
            	system.assertEquals(null,response.Data);
            }
            
        Test.stopTest();
        
    }

    @isTest static void missingRequiredFields() {

        Test.startTest();
            setup();
            User u = [SELECT Id FROM User WHERE Username =: 'test456321@test.com' LIMIT 1];

            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');

            Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', null, null, null, null, 'France', null, null);
            request.requestBody = Blob.valueof(JSON.serialize(body));
            
            RestContext.request = request;
            System.RestContext.response = new RestResponse();
            
           System.RunAs(u){
                IDENTITY_Utils.ResponseHandler response=PASS_WS02_UpdateUserId.UpdateUserIdentity();
                system.assertEquals(response.message,'Success : User and Account Updated');
                system.assertEquals(response.Status,'success'); 
               
                String username=(String)response.data.get('Username'); 
            	system.assertEquals(null,username);

            }

        Test.stopTest();
    }

    @isTest static void updateUserIdentityLoggedin() {

        Test.startTest();

            setup();
            User u = [SELECT Id FROM User WHERE Username =: 'test456321@test.com' LIMIT 1];

            RestRequest request = new RestRequest();
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');

            Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', 'test2@test.com', '0614378505', 'FR', '+33614378505', 'France', null, null);
            request.requestBody = Blob.valueof(JSON.serialize(body));
            
            RestContext.request = request;
            System.RestContext.response = new RestResponse();
            
            System.RunAs(u){
                IDENTITY_Utils.ResponseHandler response=PASS_WS04_UpdateUserId2.UpdateUserIdentity();
                
                system.assertEquals(response.message,'DUPLICATE_USERNAME');
                system.assertEquals(response.Status,'error');  
            	system.assertEquals(response.Data,null); 
            }
        Test.stopTest();
    }

    public static void setup() {
        Identity_TestFactory.createSettings();

        // First Client
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');

        Map<String, Object> body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', 'test456321@test.com', null, null, null, 'France', 'Password2!!AA@', null);
        request.requestBody = Blob.valueof(JSON.serialize(body));
        
        RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        PASS_WS01_CreateUSerId.createUserIdentity();


        // Second Client
        request = new RestRequest();
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');

        body = getBody('Mr', 'firstName', 'lastName', 'firstName2', 'lastName2', 'test2@test.com', null, null, null, 'France', 'Password2!!AA@', null);
        request.requestBody = Blob.valueof(JSON.serialize(body));
        
        RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        PASS_WS01_CreateUSerId.createUserIdentity();
    }

    public static Map<String,Object> getBody(String title, String firstName, String lastName, String firstName2, String lastName2, String email, String localMobilePhone, String countryCode,
        String internationalMobilePhone, String country, String password, String userId) {
        Map<String, Object> body = new Map<String, Object>();
        body.put('title', title);
        body.put('firstName', firstName);
        body.put('lastName', lastName);
        body.put('firstName2', firstName2);
        body.put('lastName2', lastName2);
        body.put('email', email);
        body.put('country', country);
        body.put('localMobilePhone', localMobilePhone);
        body.put('countryCodeMobilePhone', countryCode);
        body.put('callingCodeMobilePhone', '33');
        body.put('internationalMobilePhone', internationalMobilePhone);
        body.put('password', password);
        body.put('userId', userId);

        return body; 
    }
}