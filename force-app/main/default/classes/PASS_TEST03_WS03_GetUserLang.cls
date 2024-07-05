@isTest
private class PASS_TEST03_WS03_GetUserLang {
    
    @isTest 
    static void getUserLangAsset() {

        setup();

        // Insert client
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');

        Map<String, Object> body = getBody('Mr', 'Bernard', 'Dupont', null, null, 'Bernard@Dupont.test', '0614378505', 'FR', '+33614378505', 'France', 'Password2');
        request.requestBody = Blob.valueof(JSON.serialize(body));
        
        RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        PASS_WS01_CreateUSerId.createUserIdentity();

        List<User> users = [
            SELECT Id, ContactId
            FROM User 
            WHERE Email = 'Bernard@Dupont.test'
        ];

        String assId = '';

        if(!users.isEmpty()) {
            List<Account> accs = [
                SELECT Id
                FROM Account 
                WHERE PersonContactId =: users[0].ContactId
            ];

            if(!accs.isEmpty()) {
                Asset ass = new Asset(
                    Name = 'test',
                    AccountId = accs[0].Id
                );
                insert ass;

                assId = ass.Id;
            }
        }

        test.startTest();

            request = new RestRequest();
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            
            RestContext.request = request;
            System.RestContext.response = new RestResponse();
            
            PASS_WS03_GetUserLang.GetUserLangAsset(assId);
            PASS_WS03_GetUserLang.GetUserLangAsset('02i21000005IrgQ');

        test.stopTest();
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