@isTest
public with sharing class TWIST_UrlRewriter_TEST {

    @TestSetup
    static void setup() {
        Identity_TestFactory.createSettings();

        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Language_Country_Values__c = 'eng-us/por-br/eng-ca/jpn-jp';
        settings.Password_Maxlength__c = 20;
        insert settings;
    }

    @isTest
    static void test_mapRequestUrl_whenUrlDoesNotMatchLvUrlPattern() {
        // Given
        PageReference friendlyUrl = new Pagereference('/whatever');
        // When
        PageReference mappedUrl = new TWIST_UrlRewriter().mapRequestUrl(friendlyUrl);
        // Then
        System.assertEquals(friendlyUrl.getUrl(), mappedUrl.getUrl(), 'ERROR');
    }

    @isTest
    static void test_mapRequestUrl_whenUrlMatchesLvUrlPatternAndPageKeyIsEmpty() {
        // Given
        String langCountry = 'fra-fr';
        String origin = 'mylv';
        String pageKey = '';
        PageReference friendlyUrl = new Pagereference(String.format('/{0}/{1}/{2}', new List<String> { langCountry, origin, pageKey }));
        
        Pagereference expectedMappedUrl = new PageReference(TWIST_PageUrl_CONST.EXCEPTION_URL);
        Map<String,String> parameters = expectedMappedUrl.getParameters();
        parameters.put(TWIST_QueryParamKey_CONST.ORIGIN, origin);
        parameters.put(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY, langCountry);
        parameters.put(TWIST_QueryParamKey_CONST.ERROR_404, String.valueOf(true));
        parameters.put(TWIST_QueryParamKey_CONST.FRIENDLY_URL, friendlyUrl.getUrl());
        parameters.put(TWIST_QueryParamKey_CONST.CLIENT_ID, '');
        parameters.put(TWIST_QueryParamKey_CONST.ORIGIN, origin);
        parameters.put(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY, langCountry);
        parameters.put(TWIST_QueryParamKey_CONST.ERROR_404, String.valueOf(true));
        parameters.put(TWIST_QueryParamKey_CONST.FRIENDLY_URL, friendlyUrl.getUrl());
        parameters.put(TWIST_QueryParamKey_CONST.CLIENT_ID, '');

        // When
        PageReference mappedUrl = new TWIST_UrlRewriter().mapRequestUrl(friendlyUrl);

        // Then
        System.assertEquals(expectedMappedUrl.getUrl(), mappedUrl.getUrl(), 'ERROR');
    }

    @isTest
    static void test_mapRequestUrl_whenUrlMatchesLvUrlPatternAndPageKeyIsOfTypeRegistrationAndModeIsOfTypeRegistration() {
        // Given
        // IDENTITY_Settings__c identitySettings = IDENTITY_Settings__c.getInstance();
        String langCountry = 'fra-fr';
        String origin = 'mylv';
        String pageKey = 'registration';
        PageReference friendlyUrl = new Pagereference(String.format('/{0}/{1}/{2}', new List<String> { langCountry, origin, pageKey }));
        
        Pagereference expectedMappedUrl = new PageReference(TWIST_PageUrl_CONST.REGISTRATION_URL);
        Map<String,String> parameters = expectedMappedUrl.getParameters();
        parameters.put(TWIST_QueryParamKey_CONST.ORIGIN, origin);
        parameters.put(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY, langCountry);
        parameters.put(TWIST_QueryParamKey_CONST.FRIENDLY_URL, friendlyUrl.getUrl());
        parameters.put(TWIST_QueryParamKey_CONST.CLIENT_ID, '');

        // When
        PageReference mappedUrl = new TWIST_UrlRewriter().mapRequestUrl(friendlyUrl);
        
        // Then
        System.assertEquals(expectedMappedUrl.getUrl(), mappedUrl.getUrl(), 'ERROR');
    }
    
    @isTest
    static void test_mapRequestUrl_whenUrlMatchesLvUrlPatternAndPageKeyIsOfTypeRegistrationAndModeIsOfTypeActivation() {
        // Given
        Account account = Identity_TestFactory.createAccount('firstName', 'lastname', 'email@mail.com', '13922021206', '+33', true);
        String encryptedAccountId = IDENTITY_Utils.getEncryptedId(account.Id);

        String langCountry = 'fra-fr';
        String origin = 'mylv';
        String pageKey = 'registration';
        String url = String.format(
            '/{0}/{1}/{2}?cid={3}',
            new List<String> {
                langCountry,
                origin,
                pageKey,
                encryptedAccountId
        });
        PageReference friendlyUrl = new Pagereference(url);
        
        Pagereference expectedMappedUrl = new PageReference(TWIST_PageUrl_CONST.REGISTRATION_URL);
        Map<String,String> parameters = expectedMappedUrl.getParameters();
        parameters.put(TWIST_QueryParamKey_CONST.CLIENT_ID, '');
        //parameters.put(TWIST_QueryParamKey_CONST.TRUST_ORIGIN, 'false');
        parameters.put(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY, langCountry);
        parameters.put(TWIST_QueryParamKey_CONST.ORIGIN, origin);
        parameters.put('cid', friendlyUrl.getParameters().get('cid'));
        parameters.put(TWIST_QueryParamKey_CONST.FRIENDLY_URL, friendlyUrl.getUrl());
        
        //  When
        PageReference mappedUrl = new TWIST_UrlRewriter().mapRequestUrl(friendlyUrl);
        
        // Then
        System.assertEquals(expectedMappedUrl.getUrl(), mappedUrl.getUrl(), 'ERROR');
       
    }
    
    @isTest
    static void test_mapRequestUrl_whenUrlMatchesLvUrlPatternAndPageKeyIsOfTypeSocialLogin() {
        // Given
        String langCountry = 'jpn-jp';
        String origin = 'mylv';
        String pageKey = 'line';
        PageReference friendlyUrl = new Pagereference(String.format('/{0}/{1}/{2}', new List<String> { langCountry, origin, pageKey }));
        
        Pagereference expectedMappedUrl = new PageReference(TWIST_PageUrl_CONST.SOCIAL_LOGIN_URL);
        Map<String,String> parameters = expectedMappedUrl.getParameters();
        parameters.put(TWIST_QueryParamKey_CONST.SOCIAL_MEDIA, pageKey);
        parameters.put(TWIST_QueryParamKey_CONST.ORIGIN, origin);
        parameters.put(TWIST_QueryParamKey_CONST.LANG_COUNTRY, langCountry);
        parameters.put(TWIST_QueryParamKey_CONST.PAGE, TWIST_QueryParamValue_CONST.PAGE_SOCIAL_LOGIN);
        parameters.put(TWIST_QueryParamKey_CONST.FRIENDLY_URL, friendlyUrl.getUrl());
        parameters.put(TWIST_QueryParamKey_CONST.CLIENT_ID, '');

        // When
        PageReference mappedUrl = new TWIST_UrlRewriter().mapRequestUrl(friendlyUrl);
        
        // Then
        System.assertEquals(expectedMappedUrl.getUrl(), mappedUrl.getUrl(), 'ERROR');
    }

    @isTest
    static void test_mapRequestUrl_whenUrlMatchesLvUrlPatternAndPageKeyIsOfTypeLogin() {
        // Given
        String langCountry = 'fra-fr';
        String origin = 'mylv';
        String pageKey = 'login';
        PageReference friendlyUrl = new Pagereference(String.format('/{0}/{1}/{2}', new List<String> { langCountry, origin, pageKey }));
        
        Pagereference expectedMappedUrl = new PageReference(TWIST_PageUrl_CONST.LOGIN_URL);
        Map<String,String> parameters = expectedMappedUrl.getParameters();
        parameters.put(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY, langCountry);
        parameters.put(TWIST_QueryParamKey_CONST.ORIGIN, origin);
        parameters.put(TWIST_QueryParamKey_CONST.FRIENDLY_URL, friendlyUrl.getUrl());
        parameters.put(TWIST_QueryParamKey_CONST.CLIENT_ID, '');

        // When
        PageReference mappedUrl = new TWIST_UrlRewriter().mapRequestUrl(friendlyUrl);
        
        // Then
        System.assertEquals(expectedMappedUrl.getUrl(), mappedUrl.getUrl(), 'ERROR');
    }

    @isTest
    static void test_mapRequestUrl_whenUrlMatchesLvUrlPatternAndPageKeyIsNothingInParticular() {
        // Given
        String langCountry = 'fra-fr';
        String origin = 'mylv';
        String pageKey = 'nothing-in-particular';
        PageReference friendlyUrl = new Pagereference(String.format('/{0}/{1}/{2}', new List<String> { langCountry, origin, pageKey }));
        
        Pagereference expectedMappedUrl = new PageReference(TWIST_PageUrl_CONST.EXCEPTION_URL);
        Map<String,String> parameters = expectedMappedUrl.getParameters();
        parameters.put(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY, langCountry);
        parameters.put(TWIST_QueryParamKey_CONST.ORIGIN, origin);
        parameters.put(TWIST_QueryParamKey_CONST.ERROR_404, String.valueOf(true));
        parameters.put(TWIST_QueryParamKey_CONST.FRIENDLY_URL, friendlyUrl.getUrl());
        parameters.put(TWIST_QueryParamKey_CONST.CLIENT_ID, '');

        // When
        PageReference mappedUrl = new TWIST_UrlRewriter().mapRequestUrl(friendlyUrl);
        
        // Then
        System.assertEquals(expectedMappedUrl.getUrl(), mappedUrl.getUrl(), 'ERROR');
    }

    @isTest
    static void test_mapRequestUrl_whenUrlMatchesLvUrlPatternAndPageKeyIsOfTypeLoginAndLangCountryInUnknown() {
        // Given
        IDENTITY_Settings__c identitySettings = IDENTITY_Settings__c.getInstance();
        String langCountry = 'xxx-xx';
        String origin = 'mylv';
        String pageKey = 'login';
        PageReference friendlyUrl = new Pagereference(String.format('/{0}/{1}/{2}', new List<String> { langCountry, origin, pageKey }));
        
        Pagereference expectedMappedUrl = new PageReference(TWIST_PageUrl_CONST.LOGIN_URL);
        Map<String,String> parameters = expectedMappedUrl.getParameters();
        parameters.put(TWIST_QueryParamKey_CONST.ORIGIN, origin);
        parameters.put(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY, langCountry);
        parameters.put(TWIST_QueryParamKey_CONST.FRIENDLY_URL, friendlyUrl.getUrl());
        parameters.put(TWIST_QueryParamKey_CONST.CLIENT_ID, '');

        // When
        PageReference mappedUrl = new TWIST_UrlRewriter().mapRequestUrl(friendlyUrl);
        
        // Then
        System.assertEquals(expectedMappedUrl.getUrl(), mappedUrl.getUrl(), 'ERROR');
    }

	@isTest
    static void test_generateUrlFor() {
        TWIST_UrlRewriter rewriter = new TWIST_UrlRewriter();
		Test.StartTest();
        rewriter.generateUrlFor(new List<PageReference>());
		Test.StopTest();
	}

    @isTest
    static void test_mapRequestUrl_whenUrlMatchesLvUrlPatternAndlangCountryIsWrong() {
        // Given
        String langCountry = 'fra-frf';
        String origin = 'mylv';
        String pageKey = '';
        PageReference friendlyUrl = new Pagereference(String.format('/{0}/{1}/{2}', new List<String> { langCountry, origin, pageKey }));
        
        Pagereference expectedMappedUrl = new PageReference(TWIST_PageUrl_CONST.EXCEPTION_URL);
        Map<String,String> parameters = expectedMappedUrl.getParameters();
        parameters.put(TWIST_QueryParamKey_CONST.ORIGIN, origin);
        parameters.put(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY, langCountry);
        parameters.put(TWIST_QueryParamKey_CONST.ERROR_404, String.valueOf(true));
        parameters.put(TWIST_QueryParamKey_CONST.FRIENDLY_URL, friendlyUrl.getUrl());
        parameters.put(TWIST_QueryParamKey_CONST.CLIENT_ID, '');

        // When
        PageReference mappedUrl = new TWIST_UrlRewriter().mapRequestUrl(friendlyUrl);

        // Then
        System.assertEquals(expectedMappedUrl.getUrl().contains('page=error404'), mappedUrl.getUrl().contains('page=error404') , 'ERROR');
    }
    
}