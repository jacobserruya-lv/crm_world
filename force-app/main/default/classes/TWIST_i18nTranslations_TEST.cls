@isTest
public with sharing class TWIST_i18nTranslations_TEST {

    @testSetup
    static void initData(){
        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Name = 'test';
        settings.Allow_Plus_Symbol_In_Email__c = true;
        settings.Reset_Password_Max_Requests__c = 2;
        settings.Community_URL__c = URL.getSalesforceBaseUrl().toExternalForm();
        settings.Password_Maxlength__c = 20;
        settings.Env_In_Reset_Password_Url__c = 'i1f';
        insert settings;
    }
    
    @isTest
    static void test_translateLabelsListWhenLanguageIsNullShouldReturnEmptyMap() {
        // Given
        String customLabel = 'IDENTITY_Activation_Confirm_Button';
        String langCountry = 'fra-fr';
        // When
        String translation = TWIST_i18nTranslations.translateSingleLabel(customLabel, langCountry);

        // Then
        System.assertEquals('CUSTOM_LABEL', translation, 'ERROR');
    }

    @isTest
    static void test_translateLabelsListWhenCustomLabelsIsEmptyShouldReturnEmptyMap() {
        // Given
        List<String> customLabels = new List<String>();
        String langCountry = 'fra-fr';
        // When
        Map<String,Object> translation = TWIST_i18nTranslations.translateLabelsList(customLabels, langCountry);
        // Then
        System.assert(translation.isEmpty(), 'ERROR');
    }

    @isTest
    static void test_translateLabelsListNominalCase() {
        // Given
        List<String> customLabels = new List<String> { 'IDENTITY_Activation_Cancel_Button', 'IDENTITY_Activation_Confirm_Button', 'IDENTITY_LOGIN_Section_Title' };
        String langCountry = 'fra-fr';
        // When
        Map<String,Object> translation = TWIST_i18nTranslations.translateLabelsList(customLabels, langCountry);
        // Then
        System.assertEquals(customLabels, new List<String>(translation.keySet()), 'ERROR');
    }

    @isTest
    static void test_translateLabelsListWhenExceptionThrows() {
        // Given
        TWIST_i18nTranslations.forceThrowException = true;
        List<String> customLabels = new List<String> { 'IDENTITY_Activation_Cancel_Button', 'IDENTITY_Activation_Confirm_Button', 'IDENTITY_LOGIN_Section_Title' };
        String langCountry = 'fra-fr';
        // When
        Map<String,Object> translation = TWIST_i18nTranslations.translateLabelsList(customLabels, langCountry);
        // Then
        System.assertEquals(customLabels, new List<String>(translation.keySet()), 'ERROR');
    }

    @isTest
    static void test_translatePicklistNominalCase() {
        // Given
        String picklist = 'Countries';
        String language = 'fr';
        // When
        Map<String,Object> translation = TWIST_i18nTranslations.translatePicklist(picklist, language);
        // Then
        System.assertNotEquals(null, translation,'ERROR');
    }

    @isTest
    static void test_translatePicklistWhenExceptionThrows() {
        // Given
        TWIST_i18nTranslations.forceThrowException = true;
        String picklist = 'Countries';
        String language = 'fr';
        // When
        Map<String,Object> translation = TWIST_i18nTranslations.translatePicklist(picklist, language);
        // Then
        System.assertNotEquals(null, translation,'ERROR');
    }

    @isTest
    static void test_translateLabelsCallout() {
        List<String> customLabels = new List<String> { 'IDENTITY_Activation_Cancel_Button', 'IDENTITY_Activation_Confirm_Button', 'IDENTITY_LOGIN_Section_Title' };
        String language = 'fr';

        Test.setMock(HttpCalloutMock.class, new GetMockData());
        Test.startTest();

        // Given
        Map<String,Object> translation = TWIST_i18nTranslations.vfpContentToMap(
            'TWIST_i18nCustomLabels',
            new Map<String,Object> {
                'customLabels' => String.join(customLabels, ','),
                'language' => language
            }
        );
        Test.stopTest();

        // Then
       System.assertNotEquals(translation, null,'ERROR');
    }

    @isTest
    public static void test_translateLabelsListKnowingThatSomeDontExist() {
        // Given
        List<String> customLabels = new List<String> { 'IDENTITY_Activation_Cancel_Button', 'IDENTITY_Activation_Confirm_Button', 'IDENTITY_LOGIN_Section_Title' };
        String langCountry = 'fra-fr';
        // When
        Map<String,Object> translation = TWIST_i18nTranslations.translateLabelsListKnowingThatSomeDontExist(customLabels, langCountry);
        // Then
        System.assertEquals(customLabels, new List<String>(translation.keySet()), 'ERROR');
    }

    @isTest
    public static void test_translateLabelsListKnowingThatSomeDontExistWhenExceptionThrows() {
        // Given
        TWIST_i18nTranslations.forceThrowException = true;
        List<String> customLabels = new List<String> { 'IDENTITY_Activation_Cancel_Button', 'IDENTITY_Activation_Confirm_Button', 'IDENTITY_LOGIN_Section_Title' };
        String langCountry = 'fra-fr';
        // When
        Map<String,Object> translation = TWIST_i18nTranslations.translateLabelsListKnowingThatSomeDontExist(customLabels, langCountry);
        // Then
        System.assertEquals(customLabels, new List<String>(translation.keySet()), 'ERROR');
    }

    private class GetMockData implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('OK');
            response.setBody(' "IDENTITY_Activation_Confirm_Button" : "IDENTITY_Activation_Confirm_Button" ,');
            return response;
        }
    }

}