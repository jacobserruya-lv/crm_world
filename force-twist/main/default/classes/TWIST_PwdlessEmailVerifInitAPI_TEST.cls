@isTest
public class TWIST_PwdlessEmailVerifInitAPI_TEST {
    
    @testSetup static void setup() {
         Identity_TestFactory.createSettings();
        
        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Name = 'test';
        settings.Reset_Password_Max_Requests__c = 3;
        settings.Password_Maxlength__c = 20;
        settings.Email_Token_Size__c = 32;
        settings.Email_Token_Chars__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        insert settings;
        
        User u = Identity_TestFactory.createUser('TEST','TEST','test_2023_d_31@test.com','','');
    }
    
    @isTest
    static void testDoPost() {
       
   		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest//PwdlessEmailVerification/Init';
        req.addHeader('Content-Type','application/json');
        RestContext.request = req;
        RestContext.response = res;
        
        
        EmailTemplate et = [SELECT Id, DeveloperName From EmailTemplate LIMIT 1];
        User userTest = [SELECT Id, Email, userName FROM User LIMIT 1];
        
        Test.startTest();
       
            // ALL FIELDS
            Map<String, Object> bodyMap = new Map<String, Object>{
                'username' => userTest.userName,
                'emailtemplate' => et.DeveloperName,
                'redirecturi' => 'https://google.com',
                'locale' => 'eng-us'
            };
            req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
            TWIST_PwdlessEmailVerifInitAPI.doPost();
            System.assertEquals(200, res.statusCode, 'The response request is not 200');

            //EMPTY BODY
            Map<String, Object> bodyMapEmpty = new Map<String, Object>{};
            req.requestBody = Blob.valueOf(JSON.serialize(bodyMapEmpty));
            TWIST_PwdlessEmailVerifInitAPI.doPost();
            System.assertEquals(400, res.statusCode, 'The response request is not 400');
            
            //MISSING FIELDS
            Map<String, Object> bodyMap2 = new Map<String, Object>{
                'username' => userTest.userName,
                'emailtemplate' => '',
                'redirecturi' => 'https://google.com',
                'locale' => 'eng-us'
            };
            req.requestBody = Blob.valueOf(JSON.serialize(bodyMap2));
            TWIST_PwdlessEmailVerifInitAPI.doPost();
            System.assertEquals(400, res.statusCode, 'The response request is not 400');

            //WRONG USERNEME
            Map<String, Object> bodyMap3 = new Map<String, Object>{
                'username' => 'notexisting',
                'emailtemplate' => et.DeveloperName,
                'redirecturi' => 'https://google.com',
                'locale' => 'eng-us'
            };
            req.requestBody = Blob.valueOf(JSON.serialize(bodyMap3));
            TWIST_PwdlessEmailVerifInitAPI.doPost();
            System.assertEquals(400, res.statusCode, 'The response request is not 400');
        
        	//WRONG TEMPLATE
            Map<String, Object> bodyMap4 = new Map<String, Object>{
                'username' => userTest.userName,
                'emailtemplate' => 'notexisting',
                'redirecturi' => 'https://google.com',
                'locale' => 'eng-us'
            };
            req.requestBody = Blob.valueOf(JSON.serialize(bodyMap4));
            TWIST_PwdlessEmailVerifInitAPI.doPost();
            System.assertEquals(400, res.statusCode, 'The response request is not 400');
        
        
      	Test.stopTest();
    }
}