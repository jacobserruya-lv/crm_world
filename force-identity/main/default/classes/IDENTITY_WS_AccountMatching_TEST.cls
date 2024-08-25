@isTest
private class IDENTITY_WS_AccountMatching_TEST {
    
    @isTest static void test_ws() {
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/identity/v1/accountMatching';
        req.addHeader('Content-Type','application/json');
                
        RestContext.request = req;
        RestContext.response = res;

        String code;
        Account acc;
        
        Test.startTest();

            // EMPTY BODY
            req.requestBody = Blob.valueOf('');
            IDENTITY_WS_AccountMatching.match();

            // GENERATE DML EXCEPTION FOR TEST COVERAGE
            acc = IDENTITY_TestFactory.createAccount('DmlException', null, null, null, '33', false);
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_AccountMatching.match();

            // MISSING REQUIRED FIELDS
            acc = IDENTITY_TestFactory.createAccount('firstName', null, null, null, '33', false);
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_AccountMatching.match();

            // MISSING REQUIRED FIELDS - phone fields
            code = String.valueOf(Math.round(Math.random() * 100000));
            acc = IDENTITY_TestFactory.createAccount('firstName', 'lastName', code + 'test@test.com', code + '2615', '33', false);
            acc.LocalMobilePhone__pc = '';
            acc.MobilePhoneCountryCallingCode__pc = '';
            acc.MobilePhoneCountryCode__pc = '';
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_AccountMatching.match();

            // MISSING REQUIRED FIELDS - mobile phone field + other phone fields provided
            code = String.valueOf(Math.round(Math.random() * 100000));
            acc = IDENTITY_TestFactory.createAccount('firstName', 'lastName', code + 'test@test.com', '', '33', false);
            acc.LocalMobilePhone__pc = code + '2615';
            acc.MobilePhoneCountryCallingCode__pc = '33';
            acc.MobilePhoneCountryCode__pc = 'FRA';
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_AccountMatching.match();

            // INVALID REQUIRED FIELD - Home country code has to be ISO3
            code = String.valueOf(Math.round(Math.random() * 100000));
            acc = IDENTITY_TestFactory.createAccount('firstName', 'lastName', code + 'test@test.com', code + '2615', '33', false);
            acc.HomeAddressCountryCode__pc = 'AA';
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_AccountMatching.match();

            // INVALID REQUIRED FIELD - Mobile country code has to be ISO2
            code = String.valueOf(Math.round(Math.random() * 100000));
            acc = IDENTITY_TestFactory.createAccount('firstName', 'lastName', code + 'test@test.com', code + '2615', '33', false);
            acc.MobilePhoneCountryCode__pc = 'AAA';
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_AccountMatching.match();

            // BY EMAIL AND MOBILE
            code = String.valueOf(Math.round(Math.random() * 100000));
            acc = IDENTITY_TestFactory.createAccount('firstName', 'lastName', code + 'test@test.com', code + '2615', '33', false);
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_AccountMatching.match();

            // BY EMAIL
            code = String.valueOf(Math.round(Math.random() * 100000));
            acc = IDENTITY_TestFactory.createAccount(null, null, code + 'test@test.com', null, '33', false);
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_AccountMatching.match();

            // BY MOBILE
            code = String.valueOf(Math.round(Math.random() * 100000));
            acc = IDENTITY_TestFactory.createAccount(null, null, null, code + '2615', '33', false);
            req.requestBody = Blob.valueOf(JSON.serialize(acc));
            IDENTITY_WS_AccountMatching.match();

        Test.stopTest();
	}
}