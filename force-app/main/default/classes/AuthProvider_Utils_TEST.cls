@isTest
private class AuthProvider_Utils_TEST {
    
    @isTest static void test_method_one() {
        
        String jsonInput = '{"item": "test", "properties": {"prop1":"test1", "prop2":"test2"}, "kakao_account": {"prop3":"test3", "prop4":"test4"}}';
        AuthProvider_Utils.getTokenValue(jsonInput, 'test');

        String provider = 'kakao';
        String jwt_token = '{"tok1": "t1", "tok2": "t2"}';
        AuthProvider_Utils.getUserData(provider, jsonInput, jwt_token);   
    }  
}