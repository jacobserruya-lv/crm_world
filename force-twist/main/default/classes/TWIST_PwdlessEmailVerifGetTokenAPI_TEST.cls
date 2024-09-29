@isTest
private class TWIST_PwdlessEmailVerifGetTokenAPI_TEST {
    
    public final static String PWDLESS_EMAIL_VERIFICATION = 'PasswordlessEmailVerification';
    public final static String EMAIL = 'email';
    public final static String IDENTIFIER_ISSUED = 'IDENTIFIER_ISSUED';
    public final static String IDENTIFIER_USED = 'IDENTIFIER_USED';
         
    @isTest static void test() {
        
        Headless_Identity_Flow_Instance__c pwdlessEmailVerifRequest = new Headless_Identity_Flow_Instance__c (
            Flow_Type__c = PWDLESS_EMAIL_VERIFICATION,
            Username__c = 'userName@test.com', 
            Verification_Method__c = EMAIL,
            Status__c = IDENTIFIER_ISSUED,
        	Identifier__c = 'existing-identifier'
        
        );
        insert pwdlessEmailVerifRequest;
        Identity_TestFactory.createSettings();
        User user = Identity_TestFactory.createUser('TEST','TEST','userName@test.com','0500000000','972');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/PwdlessEmailVerification/GetAccessToken';
        req.addHeader('Content-Type','application/json');
        RestContext.request = req;
        RestContext.response = res;
        
        
        Test.startTest();
        
        Map<String, Object> bodyMap = new Map<String, Object>();
        
        //EMPTY BODY
        bodyMap = new Map<String, Object>{};
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        TWIST_PwdlessEmailVerifGetTokenAPI.doPost();
        System.assertEquals(400, res.statusCode, 'Statuscode should be 400');
        
        // GENERIC ERROR - MISSING SETTINGS
        bodyMap = new Map<String, Object>{'code' => 'existing-identifier'};
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        TWIST_PwdlessEmailVerifGetTokenAPI.doPost();
        System.assertEquals(400, res.statusCode, 'Statuscode should be 400');
        
        //CREATE SETTINGS
        TWIST_Settings__c settings = new TWIST_Settings__c(	Name = 'test',
                                                           Pwdless_Email_Verif_Identifier_Validity__c = 15,
                                                           Password_Maxlength__c = 20,
                                                           Email_Token_Size__c = 32,
                                                           Email_Token_Chars__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz');
        insert settings;
        
        // IDENTIFIER_STATUS_VALID
        bodyMap = new Map<String, Object>{'code' => 'existing-identifier'};
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        TWIST_PwdlessEmailVerifGetTokenAPI.doPost();
        System.assertEquals(200, res.statusCode, 'Statuscode should be 200');
        
        // IDENTIFIER_STATUS_UNKNOWN
        bodyMap = new Map<String, Object>{'code' => 'non-existing-identifier'};
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        TWIST_PwdlessEmailVerifGetTokenAPI.doPost();
        System.assertEquals(400, res.statusCode, 'Statuscode should be 400');
        
        // IDENTIFIER_STATUS_USED
        pwdlessEmailVerifRequest.Status__c = IDENTIFIER_USED;
        update pwdlessEmailVerifRequest;
        bodyMap = new Map<String, Object>{'code' => 'existing-identifier'};
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        TWIST_PwdlessEmailVerifGetTokenAPI.doPost();
        System.assertEquals(400, res.statusCode, 'Statuscode should be 400');
        
        // LOGIN ERROR
        pwdlessEmailVerifRequest.Username__c = '';
        update pwdlessEmailVerifRequest;
        bodyMap = new Map<String, Object>{'code' => 'existing-identifier'};
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        TWIST_PwdlessEmailVerifGetTokenAPI.doPost();
        System.assertEquals(400, res.statusCode, 'Statuscode should be 400');


        Test.stopTest();
    }
    
}