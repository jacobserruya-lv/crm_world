/***************************************************************************************************
* @File Name          : TR_IntegrationManagerHandler_TEST.cls
* @Description        : This class was created for the C360 project 
* @Author             : Imad.alsidchikh@vo2-consultant.com
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 01-10-2022
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       01-10-2022         Imad.alsidchikh@vo2-group.com     Initial Version
*****************************************************************************************************/
@isTest(SeeAllData=false)
private class TR_IntegrationManagerHandler_TEST {
    @TestSetup
    public static void setup() {
        /*User use = ICX_TestFactory.createUser(IC_UTILS.getDreamProfile());
        UserRole urole = [Select id from UserRole where name = '# - Corporate' limit 1];
        use.IsActive = true;
        use.UserRoleId = urole.id;
        system.debug(use);
        insert use;*/
        User dreamUser = [Select Id, username,IsActive from User where CommunityNickname = 'dream' and  profileId = :IC_UTILS.getDreamProfile() Limit 1];
        if (dreamUser != null && dreamUser.IsActive == false){
            dreamUser.IsActive = true;
            update dreamUser;
        }
        System.runAs(dreamUser){
            List<TR_Integration_Manager_Setting__c> settings= new List <TR_Integration_Manager_Setting__c>();
            TR_Integration_Manager_Setting__c setting = new TR_Integration_Manager_Setting__c();
            setting.Name = 'C360_Client_Setup';
            setting.Excluded_Profile__c = 'NoProfile';
            setting.Excluded_UserId__c = '005i0000000gx4XAAtestQ';
            setting.Integration_ProfileName__c = 'ICON_Interface DREAM';
            TR_Integration_Manager_Setting__c setting2 = new TR_Integration_Manager_Setting__c();
            setting2.Name = 'C360Synchrone_Client_Setup';
            setting2.Is_Active_C360_Integration__c=true;
            //setting2.Included_Profile__c = 'System Administrator';
            setting2.Included_UserName__c=UserInfo.getUserName();
            setting2.Included_Countries__c='CHN;CHINA';
            System.debug('UserInfo.getUserName(): '+UserInfo.getUserName());
            settings.add(setting);
            settings.add(setting2);
            insert settings;
            List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'Identity User' and UserLicense.name ='External Identity'];
            insert new IC_Config__c( 
                Name = 'Identity User',
                Value__c = profiles.size() > 0 ? profiles[0].Id : ''
            );
            insert new IDENTITY_Settings__c( 
                Username_Suffix__c = '@louisvuitton.com',
                ProfileId__c = !profiles.isEmpty() ? profiles[0].Id : '',
                Activate_New_Design__c = true
            );
            Social_Media_Identifier__c socialmedia = new Social_Media_Identifier__c(Miniprogram_Source__c='test',
                                                                                    Social_Media_Type__c='Line',
                                                                                    
                                                                                    Social_Id__c='test'
                                                                                   );
            List<Social_Media_Identifier__c> smi= new List<Social_Media_Identifier__c>();
            smi.add(socialmedia);
            insert smi;
            System.assertEquals(1,smi.size());
        }
        
        
    } 
    @isTest
    static void createAccountTest1DreamUser() {
        List <Account> accounts = new List<Account>();
        // get DREAM user
        User dreamUser = [Select Id, username from User where CommunityNickname = 'dream' and  profileId = :IC_UTILS.getDreamProfile() Limit 1];
        //User dreamUser = [Select Id, username from User where IsActive = true and profileId = :IC_UTILS.getDreamProfile() Limit 1];
        Store__c store = new Store__c();
        store.Store_CountryCode__c='FRA';
        store.Store_CountryCode__c='FRA';
        store.ISO3_Code__c='FRA';
        
        insert store;
        //perform Insert as DREAM user
        System.runAs(dreamUser){
            Account acc = IC_TestFactory.createAccount();
            acc.AttachedStore__pc='test';
            acc.MobilePhoneCountryCallingCode__pc = '972';
            acc.LocalLoginPhone__pc = '0541234567';
            acc.LoginPhoneCallingCode__pc = '972';
            acc.LocalMobilePhone__pc = '0541234567';
            acc.MobilePhoneCountryCallingCode__pc = '972';
            acc.PrimaryCountry__pc = 'FRANCE';
            acc.Source__c='KBRW';
            acc.Salutation = '02';
            acc.Store__pc=store.id;
            acc.HomeAddressCountryCode__pc = 'FRA';
            Account acc1 = IC_TestFactory.createAccount();
            acc1.AttachedStore__pc='NM5';
            test.startTest();
            accounts.add(acc);
            accounts.add(acc1);
            insert accounts;
            
            String contId = [SELECT Id FROM Contact where AccountId =: acc.Id LIMIT 1][0].Id; 
            CountryLanguage__c locales = IDENTITY_Utils.getLocales(acc.SPO_Country_Code__pc);
            User identityUser = new User(   
                // Identity Fields
                ProfileId = IDENTITY_Settings__c.getInstance().ProfileId__c,
                ContactId = contId,
                
                // Identifier Fields
                Username = acc.PersonEmail+'test',
                Email = acc.PersonEmail+'test',
                MobilePhone = acc.LoginPhone__pc,
                
                // Contact Fields
                Title = acc.PersonTitle,
                LastName = acc.LastName,
                FirstName = acc.FirstName,
                Alias = 'testisp',
                
                // Local Fields
                Country__c = acc.PrimaryCountry__pc,
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = locales.Salesforce_Language__c,
                LocaleSidKey = locales.Salesforce_Locale__c,
                TimeZoneSidKey = 'Europe/Paris'
            );
            insert identityUser;
            
            acc.FirstName='DREAMTEST18';
            acc.Firstname2__pc='DREAMTEST19';
            acc.LastName='TESTDREAM18';
            acc.LastName2__pc='TESTDREAM19';
            
            acc1.FirstName='DREAMTEST18';
            acc1.Firstname2__pc='DREAMTEST19';
            acc1.PrimaryCountry__pc = 'FRANCE';
            acc1.Source__c='Line';
            ACC1.Typology__pc='Client';
            acc1.LastName='TESTDREAM18';
            acc1.LastName2__pc='TESTDREAM19';
            Update accounts;
            test.stopTest();
            List<TECH_IntegrationManager__c> tim = [SELECT Id, Operation__c,Object_Id__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :acc.Id order by CreatedDate ASC]; 
            List<TECH_IntegrationManager__c> tim1 = [SELECT Id, Operation__c,Object_Id__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :acc1.Id order by CreatedDate ASC];
            System.assertEquals(2,tim.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim[0].Operation__c);
            System.assertEquals(TR_Constants.UPDATE_CL360,tim[1].Operation__c);
            //System.assertEquals(2,tim1.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim1[0].Operation__c);
            System.assertEquals(TR_Constants.UPDATE_CL360,tim[1].Operation__c);
            
        }
    }
    @isTest
    static void createAccountTest2SAProfile() {
        User sa1 = IC_TestFactory.createUser('sa1'+String.valueOf(System.today())+'@lvtest.com', IC_UTILS.getSAProfile());
        insert sa1;
        System.runAs(sa1){
            Account acc2 = IC_TestFactory.createAccount();
            acc2.AttachedStore__pc='test';
            test.startTest();
            insert acc2;
            acc2.FirstName='sa1TEST18';
            acc2.Firstname2__pc='sa1TEST19';
            acc2.LastName='TESTsa118';
            acc2.LastName='TESTsa119';
            Update acc2;
            test.stopTest();
            
            List<TECH_IntegrationManager__c> tim = [SELECT Id, Operation__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :acc2.Id];
            
            System.assertEquals(2,tim.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim[0].Operation__c);
            System.assertEquals(TR_Constants.UPDATE_CL360,tim[1].Operation__c);
            
        }
    }
    @isTest
    static void createAccountTest3LVDataStageUser() {
        User dataStage = [SELECT Id FROM User Where Alias = 'ilv d'];
        System.runAs(dataStage){
            Account acc3 = IC_TestFactory.createAccount();
            acc3.AttachedStore__pc='test';
            insert acc3;
            test.startTest();
            acc3.YTDSpendEUR__pc =1000;
            acc3.YTDWatchSpendUSD__pc = 1200;
            update acc3;
            test.stopTest();
            
            List<TECH_IntegrationManager__c> tim = [SELECT Id, Operation__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :acc3.Id];
            
            System.assertEquals(1,tim.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim[0].Operation__c);
            
        }
    }
    @isTest
    static void createAccountTest4MyCCUser() {
        User mycc = [SELECT Id FROM User Where Alias = 'mycc'];
        System.runAs(mycc){
            Account acc4 = IC_TestFactory.createAccount();
            acc4.AttachedStore__pc='test';
            test.startTest();
            insert acc4;
            acc4.FirstName='myccTEST18';
            acc4.Firstname2__pc='myccTEST19';
            acc4.LastName='TESTmycc18';
            acc4.LastName2__pc='TESTmycc19';
            Update acc4;
            test.stopTest();
            
            List<TECH_IntegrationManager__c> tim = [SELECT Id, Operation__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :acc4.Id];
            
            System.assertEquals(2,tim.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim[0].Operation__c);
            System.assertEquals(TR_Constants.UPDATE_CL360,tim[1].Operation__c);
            
        }
    }
    @isTest
    static void createAccountTest5DreamUser() {
        // get DREAM user
        List<Account> accountToInsert = new List<Account>(); 
        User dreamUser = [Select Id, username,country__c from User where CommunityNickname = 'dream' and  profileId = :IC_UTILS.getDreamProfile()  Limit 1];
        dreamuser.Country__c='nulldf';
        Tr_c360_utils.setCountryVal();
        TR_C360_Utils.setStoreCodeVal();
        TR_C360_Utils.getCountry('FRA');
        update dreamuser;
        //perform Insert as DREAM user
        System.runAs(dreamUser){
            Store__c store = new Store__c();
            store.Store_CountryCode__c='FRA';
            store.RetailStoreId__c='test2';
            store.Store_CountryCode__c='test2';
            store.Store_CountryCode__c='FRA';
            store.ISO3_Code__c='FRA';
            insert store;
            
            Account acc = IC_TestFactory.createAccount();
            acc.AttachedStore__pc=null;
            acc.AttachedStoreCode__pc=null;
            acc.MobilePhoneCountryCallingCode__pc = '972';
            acc.LocalLoginPhone__pc = '0541234567';
            acc.LoginPhoneCallingCode__pc = '972';
            acc.LocalMobilePhone__pc = '0541234567';
            acc.MobilePhoneCountryCallingCode__pc = '972';
            acc.PrimaryCountry__pc = 'FRANCE';
            acc.Source__c='MyCC';
            acc.Store__pc=store.id;
            acc.Salutation = '02';
            acc.HomeAddressCountryCode__pc = null;
            
            Account acc1 = IC_TestFactory.createAccount();
            acc1.AttachedStore__pc='test1';
            acc1.Source__c='MyCC';
            acc1.PrimaryCountry__pc ='FRANCE';
            
            
            Account acc2 = IC_TestFactory.createAccount();
            acc2.AttachedStore__pc='test1';
            acc2.Source__c='KBRW';
            acc2.PrimaryCountry__pc ='FRANCE';
            acc2.AttachedStoreCode__pc='test2';
            
            Account acc3 = IC_TestFactory.createAccount();
            acc3.AttachedStore__pc='test1';
            acc3.Source__c='MyLV';
            acc3.PrimaryCountry__pc ='FRANCE';
            acc3.AttachedStoreCode__pc='test2';
            
            Account acc4 = IC_TestFactory.createAccount();
            acc4.AttachedStore__pc='test1';
            acc4.Source__c='Kakaotalk';
            acc4.PrimaryCountry__pc ='FRANCE';
            acc4.AttachedStoreCountry__pc='FRA';
            acc4.AttachedStoreCode__pc='test2';
            
            test.startTest();
            accountToInsert.add(acc);
            accountToInsert.add(acc2);
            accountToInsert.add(acc3);
            accountToInsert.add(acc4);
            
            insert accountToInsert;
            
            String contId = [SELECT Id FROM Contact where AccountId =: acc.Id LIMIT 1][0].Id; 
            CountryLanguage__c locales = IDENTITY_Utils.getLocales(acc.SPO_Country_Code__pc);
            User identityUser = new User(   
                // Identity Fields
                ProfileId = IDENTITY_Settings__c.getInstance().ProfileId__c,
                ContactId = contId,
                
                // Identifier Fields
                Username = acc.PersonEmail+'test',
                Email = acc.PersonEmail+'test',
                MobilePhone = acc.LoginPhone__pc,
                
                // Contact Fields
                Title = acc.PersonTitle,
                LastName = acc.LastName,
                FirstName = acc.FirstName,
                Alias = 'testisp',
                
                // Local Fields
                Country__c = acc.PrimaryCountry__pc,
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = locales.Salesforce_Language__c,
                LocaleSidKey = locales.Salesforce_Locale__c,
                TimeZoneSidKey = 'Europe/Paris'
            );
            insert identityUser;
            insert acc1;
            acc.FirstName='DREAMTEST18';
            acc.Firstname2__pc='DREAMTEST19';
            acc.LastName='TESTDREAM18';
            acc.LastName2__pc='TESTDREAM19';
            acc.PrimaryCountry__pc = 'FRANCE';
            acc.Source__c='llmlsmf';
            acc.Store__pc=store.id;
            acc.Salutation = '02';
            Update acc;
            
            
            acc1.FirstName='DREAMTEST18';
            acc1.Firstname2__pc='DREAMTEST19';
            acc1.LastName='TESTDREAM18';
            acc1.LastName2__pc='TESTDREAM19';
            Update acc1;
            
            acc4.AttachedStoreCountry__pc='MEX';
            update ACC4;
            Social_Media_Identifier__c socialmedia = new Social_Media_Identifier__c(Miniprogram_Source__c='test',
                                                                                    Social_Media_Type__c='Line',
                                                                                    Social_Id__c='test'
                                                                                   );
            insert socialmedia;
            test.stopTest();
            List<TECH_IntegrationManager__c> tim = [SELECT Id, Operation__c,Object_Id__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :acc.Id order by CreatedDate ASC]; 
            List<TECH_IntegrationManager__c> tim1 = [SELECT Id, Operation__c,Object_Id__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :acc1.Id order by CreatedDate ASC];
            System.assertEquals(2,tim.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim[0].Operation__c);
            System.assertEquals(TR_Constants.UPDATE_CL360,tim[1].Operation__c);
            //System.assertEquals(2,tim1.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim1[0].Operation__c);
            System.assertEquals(TR_Constants.UPDATE_CL360,tim[1].Operation__c);
            
        }
    }
    
    @isTest
    static void FailedOpperations() {  
        Profile profile = [SELECT Id FROM Profile WHERE name ='Minimum Access - Salesforce' limit 1];
        User mycc = ICX_TestFactory.createUser(profile.Id);
        insert mycc;
        Account acc = IC_TestFactory.createAccount();
        System.runAs(mycc){
            try{
                TR_IntegrationManagerHandler.AfterUpdate(null, null,null, null);
            } catch (DmlException ex) {
                //System.assertEquals('expected text', ex.getMessage());
            }
            try{
                TR_IntegrationManagerHandler.AfterInsert(null, null);
            } catch (DmlException ex) {
                //System.assertEquals('expected text', ex.getMessage());
            }  
        }
    }
    
    @isTest
    static void CreateMerge() {  
        List<Account> toinsert = new List<Account>();
        Set<id> ids = new Set<id>();
        
        Account acc3 = IC_TestFactory.createAccount();
        acc3.lastname= 'testname';
        acc3.AttachedStore__pc='test1';
        acc3.Source__c='MyLV';
        acc3.PrimaryCountry__pc ='FRANCE';
        acc3.AttachedStoreCode__pc='test2';
        toinsert.add(acc3);
        
        Account acc4 = IC_TestFactory.createAccount();
        acc4.lastname= 'testname';
        acc4.AttachedStore__pc='test1';
        acc4.Source__c='Kakaotalk';
        acc4.PrimaryCountry__pc ='FRANCE';
        acc4.AttachedStoreCountry__pc='FRA';
        acc4.AttachedStoreCode__pc='test2';
        toinsert.add(acc4);
        
        insert toinsert;
        
        ids.add(acc3.id);
        ids.add(acc4.id);
        TR_IntegrationManagerHandler.mergeCheck(ids);
        
        
    }
    @isTest
    static void testSynchroneSendRequestSuccess() {
        // get DREAM user
        User dreamUser = [Select Id, username from User where CommunityNickname = 'dream' and  profileId = :IC_UTILS.getDreamProfile() Limit 1];
        System.runAs(dreamUser){
            // Create a mock account
            String code = String.valueOf(Math.round(Math.random() * 100000));
            Account acc = new Account(
            LastName = 'lastName',
            FirstName = 'firstName',
            PersonEmail = code+'test@test.com',  
            PrimaryCountry__pc = 'CHINA',
            Salutation = '02',
            HomeAddressCountryCode__pc = 'CHN',
            PreferredLanguage__pc = 'CHN',
            RecordTypeId = TR_Constants.recordTypeClient
            );
            Test.startTest();
    
            // Mock HTTP response
            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setHeader('Content-Type', 'application/json');
            mockResponse.setBody('{"auditTrail":{"sourceApplicationCode":"","touchApplicationCode":"","touchApplicationLabel":"","userLogin":"","userName":"","clientTimestamp":"","storeCode":"","countryCodeIso":"","clientServiceCenterCode":"","deviceNumber":""},"identifiers":{"salesforceId":"","c360GoldenId": "12345"},"lastName":"","firstName":"","birthDate":"","gender":{"code":"","label":""},"civility":{"code":"","label":""},"emailAddress":{"emailAddress":""},"mobilePhoneNumber":{"countryCodeIso":"","phoneNumber":""},"residencePostalAddress":{"addressLine1":"","addressLine2":"","addressLine3":"","postalCode":"","city":"","state":"","countryIso":""}}');
            mockResponse.setStatusCode(200);

            // Mock HTTP callout
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
            //Test.setMock(HttpCalloutMock.class, new myMock('200'));

            insert acc;
            Test.stopTest();
            //check that the goldenid from the acound is now 12345 by doing a query then assert equals
            Account acc2 = [SELECT C360GoldenID__c FROM Account WHERE Id = :acc.Id];
            //System.assertEquals('12345', acc2.C360GoldenID__c);
        }
    }
    @isTest
    static void testSynchroneSendRequestClientError() {
        // get DREAM user
        User dreamUser = [Select Id, username from User where CommunityNickname = 'dream' and  profileId = :IC_UTILS.getDreamProfile() Limit 1];
        System.runAs(dreamUser){
            // Create a mock account
            String code = String.valueOf(Math.round(Math.random() * 100000));
            Account acc = new Account(
            LastName = 'lastName',
            FirstName = 'firstName',
            PersonEmail = code+'test@test.com',  
            PrimaryCountry__pc = 'CHINA',
            Salutation = '02',
            HomeAddressCountryCode__pc = 'CHN',
            PreferredLanguage__pc = 'CHN',
            RecordTypeId = TR_Constants.recordTypeClient
            );
            Test.startTest();
    
            // Mock HTTP response
            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setHeader('Content-Type', 'application/json');
            mockResponse.setBody('{"error": "Client error"}');
            mockResponse.setStatusCode(400);

            // Mock HTTP callout
            //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
            Test.setMock(HttpCalloutMock.class, new myMock('401'));

            insert acc;
            Test.stopTest();
            //check that the goldenid from the acound is now 12345 by doing a query then assert equals
            Account acc2 = [SELECT C360GoldenID__c FROM Account WHERE Id = :acc.Id];
            System.assertEquals(null, acc2.C360GoldenID__c);
        }
    }
    @isTest
    static void testSynchroneSendRequestServerError() {
        // get DREAM user
        User dreamUser = [Select Id, username from User where CommunityNickname = 'dream' and  profileId = :IC_UTILS.getDreamProfile() Limit 1];
        System.runAs(dreamUser){
            // Create a mock account
            String code = String.valueOf(Math.round(Math.random() * 100000));
            Account acc = new Account(
            LastName = 'lastName',
            FirstName = 'firstName',
            PersonEmail = code+'test@test.com',  
            PrimaryCountry__pc = 'CHINA',
            Salutation = '02',
            HomeAddressCountryCode__pc = 'CHN',
            PreferredLanguage__pc = 'CHN',
            RecordTypeId = TR_Constants.recordTypeClient
            );
            Test.startTest();
    
            // Mock HTTP response
            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setHeader('Content-Type', 'application/json');
            mockResponse.setBody('{"error": "Server error"}');
            mockResponse.setStatusCode(500);

            // Mock HTTP callout
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
            //Test.setMock(HttpCalloutMock.class, new myMock('500'));
            insert acc;
            Test.stopTest();
            //check that the goldenid from the acound is now 12345 by doing a query then assert equals
            Account acc2 = [SELECT C360GoldenID__c FROM Account WHERE Id = :acc.Id];
            System.assertEquals(null, acc2.C360GoldenID__c);
        }
    }

    @isTest
    static void testSynchroneSendRequestCalloutException() {
        // get DREAM user
        User dreamUser = [Select Id, username from User where CommunityNickname = 'dream' and  profileId = :IC_UTILS.getDreamProfile() Limit 1];
        System.runAs(dreamUser){
            // Create a mock account
            String code = String.valueOf(Math.round(Math.random() * 100000));
            Account acc = new Account(
            LastName = 'lastName',
            FirstName = 'firstName',
            PersonEmail = code+'test@test.com',  
            PrimaryCountry__pc = 'CHINA',
            Salutation = '02',
            HomeAddressCountryCode__pc = 'CHN',
            PreferredLanguage__pc = 'CHN',
            RecordTypeId = TR_Constants.recordTypeClient
            );
            Test.startTest(); 


            // Mock HTTP callout
            //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
            Test.setMock(HttpCalloutMock.class, new myMock('exception'));
            insert acc;
            Test.stopTest();
            //check that the goldenid from the acound is now 12345 by doing a query then assert equals
            Account acc2 = [SELECT C360GoldenID__c FROM Account WHERE Id = :acc.Id];
            System.assertEquals(null, acc2.C360GoldenID__c);
        }
    }

    // Mock HTTP response generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;

        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
    public class myMock implements HttpCalloutMock {  
        String  isMockResponseSuccessful;  // set by constructor, used to vary the mockresponse
        
        public myMock(String MockResponseStatus) {
            this.isMockResponseSuccessful  = isMockResponseSuccessful;
        }
        
        public HttpResponse respond(HttpRequest rqst) {
            HttpResponse mockResponse    = new HttpResponse();
            if (this.isMockResponseSuccessful=='200') {
            mockResponse.setStatusCode(200);
            mockResponse.setHeader('Content-Type', 'application/json');
            mockResponse.setBody('{"auditTrail":{"sourceApplicationCode":"","touchApplicationCode":"","touchApplicationLabel":"","userLogin":"","userName":"","clientTimestamp":"","storeCode":"","countryCodeIso":"","clientServiceCenterCode":"","deviceNumber":""},"identifiers":{"salesforceId":"","c360GoldenId": "12345"},"lastName":"","firstName":"","birthDate":"","gender":{"code":"","label":""},"civility":{"code":"","label":""},"emailAddress":{"emailAddress":""},"mobilePhoneNumber":{"countryCodeIso":"","phoneNumber":""},"residencePostalAddress":{"addressLine1":"","addressLine2":"","addressLine3":"","postalCode":"","city":"","state":"","countryIso":""}}');    
            }
            else if(this.isMockResponseSuccessful=='400') {
            mockResponse.setStatusCode(400);
            mockResponse.setHeader('Content-Type', 'application/json');
            mockResponse.setBody('{"error": "Server error"}');
            mockResponse.setStatus('Bad request');
            }else if (this.isMockResponseSuccessful=='500') {
            mockResponse.setStatusCode(500);
            mockResponse.setHeader('Content-Type', 'application/json');
            mockResponse.setBody('{"error": "Server error"}');
            mockResponse.setStatus('Server error');
            }else{
            //throw an exception if the status is not 200, 400 or 500
            throw new CalloutException('Invalid status code');

            }
            return mockResponse;
        }
    }
}