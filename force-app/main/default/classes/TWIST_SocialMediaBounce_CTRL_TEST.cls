@isTest
public with sharing class TWIST_SocialMediaBounce_CTRL_TEST {

    private static final Map<String,String> baseParams = new Map<String,String> {
        TWIST_QueryParamKey_CONST.ORIGIN => 'mylv',
        TWIST_QueryParamKey_CONST.LANG_COUNTRY => 'jpn-jp',
        TWIST_QueryParamKey_CONST.CODE_CHALLENGE => 'dummy-code-challenge',
        TWIST_QueryParamKey_CONST.CLIENT_ID => 'dummy-client-id',
        TWIST_QueryParamKey_CONST.REDIRECT_URI => 'https://dummy.com',
        TWIST_QueryParamKey_CONST.STATE => 'dummy-state'
    };

    @isTest
    public static void dummyTest_whenBouncingFromSalesforceToSocialMedia_to_be_rewritten() {
        PageReference page = Page.TWIST_SocialMediaBounce;
        page.getParameters().putAll(baseParams);
        page.getParameters().put(TWIST_QueryParamKey_CONST.SOCIAL_MEDIA, 'line');
        Test.setCurrentPage(page);
        TWIST_SocialMediaBounce_CTRL ctrl = new TWIST_SocialMediaBounce_CTRL();
    }

    @isTest
    public static void dummyTest_WhenBouncingFromSocialMediaTo_Salesforce_to_be_rewritten() {
        PageReference page = Page.TWIST_SocialMediaBounce;
        page.getParameters().putAll(baseParams);
        page.getParameters().put(TWIST_QueryParamKey_CONST.ACCESS_TOKEN_SNAKE_CASE, 'dummy-token');
        page.getParameters().put(TWIST_QueryParamKey_CONST.REDIRECT_URL, 'https://dummy.com');
        Test.setCurrentPage(page);
        TWIST_SocialMediaBounce_CTRL ctrl = new TWIST_SocialMediaBounce_CTRL();
    }

    @isTest
    public static void dummyTest_whenSocialRegistration_to_be_rewritten() {
        // List<AuthProvider> providers = [SELECT Id FROM AuthProvider WHERE DeveloperName = 'LineLV' LIMIT 1];
        PageReference page = Page.TWIST_SocialMediaBounce;
        page.getParameters().putAll(baseParams);
        page.getParameters().put(TWIST_QueryParamKey_CONST.ERROR_CODE, 'dummy-token');
        page.getParameters().put(TWIST_QueryParamKey_CONST.ERROR_DESCRIPTION, EncodingUtil.base64Encode(Blob.valueOf('dummy-error')));
        // page.getParameters().put(TWIST_QueryParamKey_CONST.PROVIDER_ID, String.valueOf(providers.get(0).Id).substring(0,15));
        page.getParameters().put(TWIST_QueryParamKey_CONST.PROVIDER_ID, 'fafa');
        Test.setCurrentPage(page);
        TWIST_SocialMediaBounce_CTRL ctrl = new TWIST_SocialMediaBounce_CTRL();
    }

    @isTest
    public static void dummyTest_whenSocialRegistration_withInvalidBase64ErrorDescription_to_be_rewritten() {
        // List<AuthProvider> providers = [SELECT Id FROM AuthProvider WHERE DeveloperName = 'LineLV' LIMIT 1];
        PageReference page = Page.TWIST_SocialMediaBounce;
        page.getParameters().putAll(baseParams);
        page.getParameters().put(TWIST_QueryParamKey_CONST.ERROR_CODE, 'dummy-token');
        page.getParameters().put(TWIST_QueryParamKey_CONST.ERROR_DESCRIPTION, 'dummy-error-base64-invalid');
        // page.getParameters().put(TWIST_QueryParamKey_CONST.PROVIDER_ID, String.valueOf(providers.get(0).Id).substring(0,15));
        page.getParameters().put(TWIST_QueryParamKey_CONST.PROVIDER_ID, 'fafa');
        Test.setCurrentPage(page);
        TWIST_SocialMediaBounce_CTRL ctrl = new TWIST_SocialMediaBounce_CTRL();
    }

    @isTest
    public static void dummyTest_whenError_to_be_rewritten() {
        PageReference page = Page.TWIST_SocialMediaBounce;
        page.getParameters().putAll(new Map<String,String> {
            TWIST_QueryParamKey_CONST.ORIGIN => 'mylv',
            TWIST_QueryParamKey_CONST.LANG_COUNTRY => 'jpn-jp'
        });
        Test.setCurrentPage(page);
        TWIST_SocialMediaBounce_CTRL ctrl = new TWIST_SocialMediaBounce_CTRL();
    }
    
    
    @isTest
    public static void dummyTest_handleErrorWhenProcessingSocialRegistration() {
        // List<AuthProvider> aList = [SELECT Id FROM AuthProvider WHERE DeveloperName = 'LineLV' LIMIT 1];
        // String lineProviderId = (String) aList.get(0).Id;
        String lineProviderId = 'fafa';
        PageReference page = Page.TWIST_SocialMediaBounce;
        page.getParameters().putAll(baseParams);
        page.getParameters().putAll(new Map<String,String> {
            TWIST_QueryParamKey_CONST.PROVIDER_ID => lineProviderId,
            TWIST_QueryParamKey_CONST.ERROR_CODE => 'error'
        });
        Test.setCurrentPage(page);
        TWIST_SocialMediaBounce_CTRL ctrl = new TWIST_SocialMediaBounce_CTRL();
        ctrl.handleErrorWhenProcessingSocialRegistration(new Map<String,String> { TWIST_QueryParamKey_CONST.SOCIAL_ID => 'dummy-social-id' });
    }
    
}