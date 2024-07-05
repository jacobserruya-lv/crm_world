@isTest
public with sharing class TWIST_Account_Confirmation_TEST {
    
    @testSetup
    static void initData(){

        TWIST_Registration_Form_Settings__c  registrationSetting = new TWIST_Registration_Form_Settings__c();
        registrationSetting.Code_Validity_Time__c = 10;
        insert registrationSetting;
        
        Identity_TestFactory.createSettings();

        Registration_Code_Verification_Request__c code = createCodeRequest('12345', 'test@test.test');
        insert code;

        Store__c store = new Store__c();
        store.RetailStoreId__c = 'A06';
        insert store;

        Language2__c lang2 = new Language2__c();
        lang2.Iso2Code__c = 'US';
        lang2.Iso3Code__c = 'US';
        insert lang2;

        Country__c country = new Country__c();
        country.tech_duplicate__c = 'Austria';
        insert country;

        CountryLanguage__c countryLanguage = new CountryLanguage__c();
        countryLanguage.defaultStore__c = store.Id;
        countryLanguage.Dispatch_Country__c = 'US';
        countryLanguage.ATG_Locale__c = 'eng-e1';
        countryLanguage.Country__c = country.Id;
        countryLanguage.Language__c = lang2.Id;
        insert countryLanguage;
    }

    
    @isTest
    static void test_createMyLvUserAndRedirect_registrationMode() {
        // Given
        Map<String,Object> queryParams = new Map<String,Object> {
            TWIST_QueryParamKey_CONST.STATE => 'dummy-state',
            TWIST_QueryParamKey_CONST.CODE_CHALLENGE => 'dummy-code-challenge',
            TWIST_QueryParamKey_CONST.CLIENT_ID => 'dummy-client-id',
            TWIST_QueryParamKey_CONST.REDIRECT_URI => 'https://dummy-redirect.uri'
        };

        Map<String,Object> formData = new Map<String,Object> {
            'firstname' => 'Test',
            'country' => 'USA',
            'lastname' => 'Test',
            'title' => 'Test',
            'email' => 'test@gmail.com',
            'emailconfirmation' => 'test@gmail.com',
            'password' => 'Pass@!123456'
        };
        Map<String,Object> result = TWIST_Account_Confirmation.createMyLvUserAndRedirect('12345', 'test@test.test', formData, queryParams, new Map<String,String>{});
        system.debug('result : '+result);
        Test.setMock(HttpCalloutMock.class, new GetMockData());

        // When
        Test.startTest();
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('CUSTOM_LABEL', 'en')) ;
        Test.stopTest();

        // Then
        System.assertEquals(result, expected);
    }

    @isTest
    static void test_createMyLvUserAndRedirect_invalidCode() {

        Map<String,Object> result = TWIST_Account_Confirmation.createMyLvUserAndRedirect('', 'test@test.test', new Map<String,Object> {}, new Map<String,Object> {}, new Map<String,String>{});
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Account_Creation_Form_AccountCreationProcessError', 'en')) ;

        System.assertEquals(result, expected);
    }
    
    @isTest
    static void test_isUserIdentity() {
        User user = Identity_TestFactory.createUser('TEST','TEST','identityUserTest@test.test','0500000000','972');

        boolean result = TWIST_Account_Confirmation.isUserIdentity('identityUserTest@test.test');
        boolean resultEmpty = TWIST_Account_Confirmation.isUserIdentity('');

        System.assertEquals(result, true);
        System.assertEquals(resultEmpty, false);
    }

    @isTest
    static void test_userCreation() {
        Account account1 = Identity_TestFactory.createAccount('test1', 'test1', 'test-FULL_ACTIVATION@test.com', '133456789', '972', true);
        Account account2 = Identity_TestFactory.createAccount('test2', 'test2', 'test-PARTIAL_ACTIVATION@test.com', '133456788', '972', true);

        account2 = TWIST_RegistrationUtils.getClientById(account2.id);

        Id resultFullActivation = TWIST_Account_Confirmation.userCreation(account1, 'Pass86324@!', new Map<String,Object> {}, TWIST_RegistrationUtils.Mode.FULL_ACTIVATION);
        Id resultPartialActivation = TWIST_Account_Confirmation.userCreation(account2, 'Pass86324@!', new Map<String,Object> {}, TWIST_RegistrationUtils.Mode.PARTIAL_ACTIVATION);
        
        try {
            Id resultException = TWIST_Account_Confirmation.userCreation(account2, 'Pass86324@!', new Map<String,Object> {}, TWIST_RegistrationUtils.Mode.LOGIN);
        } catch(Exception e) {
            Exception ex = new AuraHandledException('error');
            System.assertEquals(e.getMessage(), ex.getMessage());
        }

        System.assertEquals(resultFullActivation == null, false);
        System.assertEquals(resultPartialActivation == null, false);
    }


    //Only for code coverage
    @isTest
    static void test_createUser() {

        Account account = Identity_TestFactory.createAccount('test3', 'test3', 'test-createuser@test.com', '133456189', '972', true);
        account.AttachedStoreCode__pc = 'A06';
        update account;

        Map<String,Object> queryParams = new Map<String,Object> {
            'dispatchCountry' => 'US',
            'langCountry' => 'eng-e1'
        };

        TWIST_Account_Confirmation.sendClientRMS(account, queryParams);
        TWIST_Account_Confirmation.sendClientRMS(null, queryParams); //Exception
    }

    @isTest
    static void test_socialMediaCreationAndLogin() {

        User user = Identity_TestFactory.createUser('TEST','TEST','identityUserTest@test.test','0500000000','972');

        Map<String,String> socialParams = new Map<String,String> {
            'social_id' => 'Uf2537919f7f580be5280cd749ce7b86e',
            'social_media_type' => 'Line'
        };

        Map<String,Object> queryParams = new Map<String,Object> {
            'dispatchCountry' => 'US',
            'langCountry' => 'eng-e1'
        };

        TWIST_Account_Confirmation.socialMediaCreationAndLogin('identityUserTest@test.test','test1234', socialParams, queryParams);
    }
    //--------------- PRIVATE METHODS ---------------//
    private static Registration_Code_Verification_Request__c createCodeRequest(String code, String recordId) {
        Registration_Code_Verification_Request__c request = new Registration_Code_Verification_Request__c();
        request.code__c = code;
        request.Record_Id__c = recordId;
        request.State__c = '1';
        return request;
    }

    public class GetMockData implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('OK');
            response.setBody(' "IDENTITY_Activation_Confirm_Button" : "IDENTITY_Activation_Confirm_Button" , "CUSTOM_LABEL" : "CUSTOM_LABEL",');

            return response;
        }
    }
}