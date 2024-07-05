@isTest
private class ICX_SurveyForm_TEST {
    

    @isTest 
    static void getSurveyFormResultTEST() {

        
        Account accts = ICX_TestFactory.createAccount();
        insert accts;
        ID accountId = accts.Id;
        
        VO_Survey__c mainSurvey = ICX_TestFactory.createSurvey(accountId);
        mainSurvey.FeedbackID__c = '4de5413c-6103-478f-97c7-d6283339b37f';
        insert mainSurvey;
        
        System.debug('getSurveyFormResultTEST mainSurvey.FeedbackID__c: '+mainSurvey.FeedbackID__c);

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();

        Test.startTest();

        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock().setBody('{"data": {"attributes": {"segments": {"communication_channel": "EMAIL"},"resolved": true}}}'));
           
        Object result = ICX_SurveyForm.getSurveyFormResult(mainSurvey.id);
        system.debug('getSurveyFormResultTEST result : ' +result);
        System.assertNotEquals(null, result, 'response not null');
        
        Test.stopTest();

    }


    @isTest 
    static void getSurveyFormResultERRORTEST() {

        Account accts = ICX_TestFactory.createAccount();
        insert accts;
        ID accountId = accts.Id;

        VO_Survey__c mainSurvey = ICX_TestFactory.createSurvey(accountId);
        mainSurvey.FeedbackID__c = '4de5413c-6103-478f-97c7-d6283339b37f';
        insert mainSurvey;

        Test.startTest();
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock().setBody('Ressource not found'));

        Object error = ICX_SurveyForm.getSurveyFormResult(mainSurvey.id);
        System.debug('getSurveyFormResultTEST error: '+error);


        System.assertNotEquals(null, error, 'response not null');
        
        Test.stopTest();

    }

    @isTest
    static void getTransactionProductTEST() {
        Account accts = ICX_TestFactory.createAccount();
        accts.DREAMID__c = '14712';
        insert accts;
        ID accountId = accts.Id;

        PPR_PurchProduct__c newPurchase = ICX_TestFactory.createPurchases(accountId);
        newPurchase.TransactionRMSId__c = '123';
        newPurchase.DREAMIdClient__c = '14712';
        insert newPurchase;
      
        VO_Survey__c mainSurvey = ICX_TestFactory.createSurvey(accountId);
        mainSurvey.ClientDreamID__c = accountId;
        insert mainSurvey;
        String transactionId = mainSurvey.IDTransaction__c;
        String dreamIdClient = mainSurvey.DreamIDText__c;        

        Test.startTest();

        Object transactionMapped = ICX_SurveyForm.getTransactionProduct(transactionId, dreamIdClient);
        System.debug('getTransactionProductTEST transactionMapped: ' + transactionMapped);
        System.assertNotEquals(null, transactionMapped, 'response not null');
      
        Test.stopTest();
        
    }


    @isTest
    static void getTransactionProductERRORTEST() {
        Account accts = ICX_TestFactory.createAccount();
        accts.DREAMID__c = '14712';
        insert accts;
        ID accountId = accts.Id;
      
        VO_Survey__c mainSurvey = ICX_TestFactory.createSurvey(accountId);
        mainSurvey.ClientDreamID__c = accountId;
        insert mainSurvey;
        String transactionId = mainSurvey.IDTransaction__c;
        String dreamIdClient = mainSurvey.DreamIDText__c;        

        Test.startTest();

        Object error = ICX_SurveyForm.getTransactionProduct(transactionId, dreamIdClient);
        System.debug('getTransactionProductTEST transactionMapped ERROR: ' + error);      
        System.assertNotEquals(null, error, 'System.ListException: List index out of bounds: 0');

        Test.stopTest();
        
    }
    
    @isTest

    static void getVoiceLanguageUserTEST() {
		User testUser = TEST_Utils.createUser('test user');
		Country__c country = ICX_TestFactory.createCountry('US', 'USA', 'USA');
        insert country;

        Language2__c language = ICX_TestFactory.createLanguage('US', 'USA');
        insert language;

        CountryLanguage__c countryLanguage = ICX_TestFactory.createCountryLanguage(country.id, language.id);
        insert countryLanguage;


        Test.startTest();
		System.runAs(testUser) {
            String voiceLanguage = ICX_SurveyForm.getVoiceLanguageUser();
            system.debug('getVoiceLanguageUserTEST voiceLanguage : ' + voiceLanguage);
            System.assertEquals(voiceLanguage, 'it');
        }
		Test.stopTest();

    }

}