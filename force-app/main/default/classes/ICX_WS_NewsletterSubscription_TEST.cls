@isTest
public class ICX_WS_NewsletterSubscription_TEST {
    

    @TestSetup
    static void createTestData() {
        // Create a test account
        List<Account> accountList = new List<Account>();
        Account testAccount = new Account();
            testAccount.FirstName = 'CoolRobert';
            testAccount.LastName = 'Shon';
            testAccount.PersonEmail = 'robertshon@lv.com';
            testAccount.Can_Be_Contacted_By_Email__pc = false;
            testAccount.PrimaryCountry__pc = 'USA';
            testAccount.NationalityCountryCode__pc = 'USA';
            testAccount.Nationality__pc ='American';
            testAccount.PreferredLanguage__pc = 'ENG';
        
            accountList.add(testAccount);
            
            Account testAccount2 = new Account();
            testAccount2.FirstName = '';
            testAccount2.LastName = 'Gold';
            testAccount2.PersonEmail = 'johngold@lv.com';
            testAccount2.Can_Be_Contacted_By_Email__pc = false;
            testAccount2.Firstname2__pc = 'John';
            testAccount2.Lastname2__pc = 'Gold';
            testAccount2.PrimaryCountry__pc = 'JPN';
            testAccount2.NationalityCountryCode__pc = 'JPN';
            testAccount2.Nationality__pc ='Japanese';
            testAccount2.PreferredLanguage__pc = 'JPN';
            testAccount2.HomeAddressCountryCode__pc='JPN';
            accountList.add(testAccount2);

            Account testAccount3 = new Account();
            testAccount3.FirstName = 'Geneva';
            testAccount3.LastName = 'Grey';
            testAccount3.PersonEmail = 'geneva@lv.com';
            testAccount3.Can_Be_Contacted_By_Email__pc = true;
            testAccount3.Newsletter__c=true;
            testAccount3.PersonHasOptedOutOfEmail = false;
            testAccount3.Firstname2__pc = '';
            testAccount3.Lastname2__pc = '';
            testAccount3.PrimaryCountry__pc = 'KOR';
            testAccount3.NationalityCountryCode__pc = 'KOR';
            testAccount3.Nationality__pc ='Korean';
            testAccount3.PreferredLanguage__pc = 'KOR';
            accountList.add(testAccount3);

        insert accountList;
    }

    //This method test the scenario when the class method update NewsLetter status on existing client 
    @isTest
    static void testSubscribeToNewsletter() {
       
        // Set up the request body for the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription_Helper.requestBodySubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodySubscription();
        reqBody.clientEmail = 'robertshon@lv.com';
        reqBody.firstName = 'CoolRobert';
        reqBody.lastName = 'Shon';
        reqBody.firstName2 = '';
        reqBody.lastName2 = '';
        reqBody.title = '03';
        reqBody.countryCode = 'USA';
        reqBody.nationalityCode = 'USA';
        reqBody.clientPhone='';

        reqBody.local = 'eng-us' ;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/newsletter/subscribe'; // request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqBody));
        // req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;


        //////////////////////////
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('marketingCloudEventResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        //////////////////////////


        // Call the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription.subscribeToNewsletter();

        Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'robertshon@lv.com'];
        System.assertEquals(true, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to true');
        Test.stopTest();

    }

    //This method test the scenario when the class method update NewsLetter status on existing client with firstname2 and lastname2
    @isTest
    static void testSubscribeToNewsletterName2() {
       
        // Set up the request body for the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription_Helper.requestBodySubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodySubscription();
        reqBody.clientEmail = 'johngold@lv.com';
        reqBody.firstName = '';
        reqBody.lastName = '';
        reqBody.firstName2 = 'John';
        reqBody.lastName2 = 'Gold';
        reqBody.title = '03';
        reqBody.countryCode = 'USA';
        reqBody.nationalityCode = 'USA';
        reqBody.clientPhone='';
        reqBody.local = 'eng-us' ;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/newsletter/subscribe'; // request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqBody));
        // req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;


        //////////////////////////
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('marketingCloudEventResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        //////////////////////////


        // Call the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription.subscribeToNewsletter();

        Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'johngold@lv.com'];
        System.assertEquals(true, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to true');
        Test.stopTest();

    }

    // This method test the scenario when the client does not exists , 
    // And the method create a new client and update his Newsletter status
    @isTest
    static void testSubscribeToNewsletterNewClient() {
        
        // Set up the request body for the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription_Helper.requestBodySubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodySubscription();
        reqBody.clientEmail = 'test@example.com';
        reqBody.firstName = 'Robert';
        reqBody.lastName = 'ShonBox';
        reqBody.firstName2 = '';
        reqBody.lastName2 = '';
        reqBody.title = '03';
        reqBody.countryCode = 'ISR';
        reqBody.nationalityCode = 'ISR';
        reqBody.clientPhone='00586662037';
        reqBody.local = 'eng-us';
        
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/newsletter/subscribe'; // request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqBody));
        RestContext.request = req;
        RestContext.response = res;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('marketingCloudEventResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        
        
        // Call the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription.subscribeToNewsletter();

        Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'test@example.com'];
        System.assertEquals(true, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to true');
        
        Test.stopTest();

    }

      //This method test the scenario when the class method update NewsLetter status when no match
    @isTest
    static void testSubscribeToNewsletterNoMatch() {
       
        // Set up the request body for the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription_Helper.requestBodySubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodySubscription();
        reqBody.clientEmail = 'robertshon@lv.com';
        reqBody.firstName = 'CoolRobert1';
        reqBody.lastName = 'Shon';
        reqBody.firstName2 = '';
        reqBody.lastName2 = '';
        reqBody.title = '03';
        reqBody.countryCode = 'USA';
        reqBody.nationalityCode = 'USA';
        reqBody.clientPhone='';

        reqBody.local = 'eng-us' ;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/newsletter/subscribe'; // request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqBody));
        RestContext.request = req;
        RestContext.response = res;




        // Call the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription.subscribeToNewsletter();

        Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'robertshon@lv.com'];
        System.assertEquals(false, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to false');
        Test.stopTest();

    }

    
     //This method test the scenario when the we have field clientEmail missing in the callout
     @isTest
     static void testSubscribeToNewsletterMissingField1() {
        
         // Set up the request body for the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription_Helper.requestBodySubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodySubscription();
         reqBody.clientEmail = '';
         reqBody.firstName = 'CoolRobert';
         reqBody.lastName = 'Shon';
         reqBody.firstName2 = '';
         reqBody.lastName2 = '';
         reqBody.title = '03';
         reqBody.countryCode = 'USA';
         reqBody.nationalityCode = 'USA';
         reqBody.clientPhone='';
 
         reqBody.local = 'eng-us' ;
 
         Test.startTest();
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
 
         req.requestURI = '/services/apexrest/newsletter/subscribe'; // request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(JSON.serialize(reqBody));
         RestContext.request = req;
         RestContext.response = res;

 
 
         // Call the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription.subscribeToNewsletter();
 
         Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'robertshon@lv.com'];
         System.assertEquals(false, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to false');
         Test.stopTest();
 
     }
    
    
  //This method test the scenario when the we have field first name missing in the callout
     @isTest
     static void testSubscribeToNewsletterMissingField2() {
        
         // Set up the request body for the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription_Helper.requestBodySubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodySubscription();
         reqBody.clientEmail = 'robertshon@lv.com';
         reqBody.firstName = '';
         reqBody.lastName = 'Shon';
         reqBody.firstName2 = '';
         reqBody.lastName2 = '';
         reqBody.title = '03';
         reqBody.countryCode = 'USA';
         reqBody.nationalityCode = 'USA';
         reqBody.clientPhone='';
 
         reqBody.local = 'eng-us' ;
 
         Test.startTest();
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
 
         req.requestURI = '/services/apexrest/newsletter/subscribe'; // request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(JSON.serialize(reqBody));
         RestContext.request = req;
         RestContext.response = res;
 

 
 
         // Call the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription.subscribeToNewsletter();
 
         Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'robertshon@lv.com'];
         System.assertEquals(false, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to false');
         Test.stopTest();
 
     }
 
     //This method test the scenario when the we have field title missing in the callout
     @isTest
     static void testSubscribeToNewsletterMissingField3() {
        
         // Set up the request body for the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription_Helper.requestBodySubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodySubscription();
         reqBody.clientEmail = 'robertshon@lv.com';
         reqBody.firstName = 'CoolRobert';
         reqBody.lastName = 'Shon';
         reqBody.firstName2 = '';
         reqBody.lastName2 = '';
         reqBody.title = '';
         reqBody.countryCode = 'USA';
         reqBody.nationalityCode = 'USA';
         reqBody.clientPhone='';
 
         reqBody.local = 'eng-us' ;
 
         Test.startTest();
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
 
         req.requestURI = '/services/apexrest/newsletter/subscribe'; // request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(JSON.serialize(reqBody));
         RestContext.request = req;
         RestContext.response = res;
 
 
 
         // Call the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription.subscribeToNewsletter();
 
         Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'robertshon@lv.com'];
         System.assertEquals(false, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to false');
         Test.stopTest();
 
     }
   
    //This method test the scenario when the we have field countryCode missing in the callout
     @isTest
     static void testSubscribeToNewsletterMissingField4() {
        
         // Set up the request body for the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription_Helper.requestBodySubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodySubscription();
         reqBody.clientEmail = 'robertshon@lv.com';
         reqBody.firstName = 'CoolRobert';
         reqBody.lastName = 'Shon';
         reqBody.firstName2 = '';
         reqBody.lastName2 = '';
         reqBody.title = '03';
         reqBody.countryCode = '';
         reqBody.nationalityCode = 'USA';
         reqBody.clientPhone='';
         reqBody.local = 'eng-us' ;
 
         Test.startTest();
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
 
         req.requestURI = '/services/apexrest/newsletter/subscribe'; // request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(JSON.serialize(reqBody));
         RestContext.request = req;
         RestContext.response = res;
 

 
 
         // Call the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription.subscribeToNewsletter();
 
         Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'robertshon@lv.com'];
         System.assertEquals(false, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to false');
         Test.stopTest();
 
     }
   
    //This method test the scenario when the we have field nationalityCode missing in the callout
     @isTest
     static void testSubscribeToNewsletterMissingField5() {
        
         // Set up the request body for the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription_Helper.requestBodySubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodySubscription();
         reqBody.clientEmail = 'robertshon@lv.com';
         reqBody.firstName = 'CoolRobert';
         reqBody.lastName = 'Shon';
         reqBody.firstName2 = '';
         reqBody.lastName2 = '';
         reqBody.title = '03';
         reqBody.countryCode = 'USA';
         reqBody.nationalityCode = '';
         reqBody.clientPhone='';
         reqBody.local = 'eng-us' ;
 
         Test.startTest();
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
 
         req.requestURI = '/services/apexrest/newsletter/subscribe'; // request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(JSON.serialize(reqBody));
         RestContext.request = req;
         RestContext.response = res;

 
 
         // Call the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription.subscribeToNewsletter();
 
         Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'robertshon@lv.com'];
         System.assertEquals(false, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to false');
         Test.stopTest();
 
     }
   
      //This method test the scenario when the we have field local missing in the callout
     @isTest
     static void testSubscribeToNewsletterMissingField6() {
        
         // Set up the request body for the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription_Helper.requestBodySubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodySubscription();
         reqBody.clientEmail = 'robertshon@lv.com';
         reqBody.firstName = 'CoolRobert';
         reqBody.lastName = 'Shon';
         reqBody.firstName2 = '';
         reqBody.lastName2 = '';
         reqBody.title = '03';
         reqBody.countryCode = 'USA';
         reqBody.nationalityCode = 'USA';
         reqBody.clientPhone='';
         reqBody.local = '' ;
 
         Test.startTest();
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
 
         req.requestURI = '/services/apexrest/newsletter/subscribe'; // request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(JSON.serialize(reqBody));
         RestContext.request = req;
         RestContext.response = res;
 
 
 
         // Call the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription.subscribeToNewsletter();
 
         Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'robertshon@lv.com'];
         System.assertEquals(false, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to false');
         Test.stopTest();
 
     }
   
    
     //This method test the scenario when the endpoint is wrong for subscription
     @isTest
     static void testSubscribeToNewsletterWrongEndpoint() {
        
         // Set up the request body for the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription_Helper.requestBodySubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodySubscription();
         reqBody.clientEmail = '';
         reqBody.firstName = 'CoolRobert';
         reqBody.lastName = 'Shon';
         reqBody.firstName2 = '';
         reqBody.lastName2 = '';
         reqBody.title = '03';
         reqBody.countryCode = 'USA';
         reqBody.nationalityCode = 'USA';
         reqBody.clientPhone='';
 
         reqBody.local = 'eng-us' ;
 
         Test.startTest();
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
 
         req.requestURI = '/services/apexrest/newsletter/unsubscribe'; // request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(JSON.serialize(reqBody));
         RestContext.request = req;
         RestContext.response = res;

 
 
         // Call the subscribeToNewsletter method
         ICX_WS_NewsletterSubscription.subscribeToNewsletter();
 
         Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'robertshon@lv.com'];
         System.assertEquals(false, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to false');
         Test.stopTest();
 
     }

    
    //This method test the scenario of the client that wants to unsubscribe from the newsletter
    @isTest
    static void testUnSubscribeToNewsletter() {
        
        
        // Set up the request body for the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription_Helper.requestBodyUnsubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodyUnsubscription();
        reqBody.clientEmail = 'geneva@lv.com';
        reqBody.clientPhone='';
        reqBody.local = 'kor-kr';

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/newsletter/unsubscribe'; // request URL
        req.httpMethod = 'PATCH'; //HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqBody));
        RestContext.request = req;
        RestContext.response = res;

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('marketingCloudEventResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);



        // Call the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription.unsubscribeFromNewsletter();

        Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'geneva@lv.com'];
        System.assertEquals(false, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to false');
        Test.stopTest();

    }
    
    
    
    
      //This method test the scenario of the client that wants to unsubscribe missing clientEmail
    @isTest
    static void testUnSubscribeToNewsletterMissingField() {
        
        
        // Set up the request body for the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription_Helper.requestBodyUnsubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodyUnsubscription();
        reqBody.clientEmail = '';
        reqBody.clientPhone='';
        reqBody.local = 'kor-kr';

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/newsletter/unsubscribe'; // request URL
        req.httpMethod = 'PATCH'; //HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqBody));
        RestContext.request = req;
        RestContext.response = res;




        // Call the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription.unsubscribeFromNewsletter();

        Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'geneva@lv.com'];
        System.assertEquals(true, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to true');
        Test.stopTest();

    }
    
    //This method test the scenario of the client that wants to unsubscribe from the newsletter with not match
    @isTest
    static void testUnSubscribeToNewsletterNoMatch() {
        
        
        // Set up the request body for the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription_Helper.requestBodyUnsubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodyUnsubscription();
        reqBody.clientEmail = 'geneva1@lv.com';
        reqBody.clientPhone='';
        reqBody.local = 'kor-kr';

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/newsletter/unsubscribe'; // request URL
        req.httpMethod = 'PATCH'; //HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqBody));
        RestContext.request = req;
        RestContext.response = res;




        // Call the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription.unsubscribeFromNewsletter();

        Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'geneva@lv.com'];
        System.assertEquals(true, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to true');
        Test.stopTest();

    }
        
    //This method test the scenario of the client that wants to unsubscribe from the newsletter with wrong endpoint
    @isTest
    static void testUnSubscribeToNewsletterWrongEndpoint() {
        
        
        // Set up the request body for the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription_Helper.requestBodyUnsubscription reqBody = new ICX_WS_NewsletterSubscription_Helper.requestBodyUnsubscription();
        reqBody.clientEmail = 'geneva@lv.com';
        reqBody.clientPhone='';
        reqBody.local = 'kor-kr';

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/newsletter/subscribe'; // request URL
        req.httpMethod = 'PATCH'; //HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqBody));
        RestContext.request = req;
        RestContext.response = res;




        // Call the subscribeToNewsletter method
        ICX_WS_NewsletterSubscription.unsubscribeFromNewsletter();

        Account updatedAccount = [SELECT Newsletter__c, Can_Be_Contacted_By_Email__pc, PersonHasOptedOutOfEmail FROM Account WHERE PersonEmail=:'geneva@lv.com'];
        System.assertEquals(true, updatedAccount.Newsletter__c, 'Expected the Newsletter__c field to be set to true');
        Test.stopTest();

    }
    

}