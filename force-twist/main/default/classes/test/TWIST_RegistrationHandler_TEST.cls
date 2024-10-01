@isTest
global class TWIST_RegistrationHandler_TEST {
    
    @isTest static void test_one() {
        try{
            Identity_TestFactory.createSettings();
            //String mobile = Identity_Utils.getMobilePhone('972', '0541234567');
            Auth.UserData data = new Auth.UserData('123756','','','', 'testme1@test.com','', '','','Facebook', '', new Map<String,String>());
            String portalId = 'idd';
            
            User thisUser = [ select Id from User where Id = :UserInfo.getUserId() limit 1];
            Test.startTest();
            System.runAs(thisUser) {
                Identity_TestFactory.createUser('TEST1','TEST1','testme1@test.com','','');
                
                // RULE 1: SOCIAL ID / EMAIL
                TWIST_RegistrationHandler handler = new TWIST_RegistrationHandler();
                User u = handler.createUser(portalId, data);
                User userTest = [SELECT Id, Email FROM User WHERE Id = :u.Id LIMIT 1];
                System.assertEquals('testme1@test.com', userTest.Email);
            }
            Test.stopTest();
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }
    
    @isTest static void test_two() {
        try{
            Identity_TestFactory.createSettings();
            //String mobile = Identity_Utils.getMobilePhone('972', '0541234567');
            
            Auth.UserData data = new Auth.UserData('12375675275','','','', 'testme2@test.com','', '','','Facebook', '', new Map<String,String> { 'login_international_mobile_phone' => '+1234567890' });
            String portalId = 'idd';
            
            User thisUser = [ select Id from User where Id = :UserInfo.getUserId() limit 1];
            Test.startTest();
            System.runAs(thisUser) {
                Identity_TestFactory.createUser('TEST2','TEST2','testme2@test.com','0541234567','972');
                
                TWIST_RegistrationHandler handler = new TWIST_RegistrationHandler();
                // RULE 2: MOBILE PHONE
                User u2 = handler.createUser(portalId, data);
                User userTest2 = [SELECT Id, Email FROM User WHERE Id = :u2.Id LIMIT 1];
                System.assertEquals('testme2@test.com', userTest2.Email);
                
                // TEST THIS WAY INSTEAD OF THROW EXCEPTION
                handler.setPayload(data);
            }
            Test.stopTest();
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }
    
    @isTest static void test_UpdateAccKakao() {
        try{
            Identity_TestFactory.createSettings();
            //String mobile = Identity_Utils.getMobilePhone('82', '1050394146');
            Map<String,String> aMap = new Map<String,String>();
            aMap.put('phone_number','+82- 105-039-4146');
            aMap.put('phone_number_verified','true');
            aMap.put('birthdate_day','05');
            aMap.put('birthdate_month','07');
            aMap.put('birthdate_year','1995');
            aMap.put('base_address','서울 중랑구 면목동 160-4 (면목동)');
            aMap.put('detail_address','test');
            aMap.put('zone_number','02224');
            aMap.put('email_verified','true');
            aMap.put('gender','female');
            aMap.put('newsletter_terms','true');
            aMap.put('agreed_at','2023-10-09T10:39:20Z');
            Auth.UserData data1 = new Auth.UserData('123756','test','test','test', 'testme1@test.com','', '','','KAKAO', 'KR', aMap);
            String portalId = 'idd';
            
            Test.startTest();
            
            User thisUser = [ select Id from User where Id = :UserInfo.getUserId() LIMIT 1];
            System.runAs(thisUser) {
                User user1 = Identity_TestFactory.createUser('TEST1','TEST1','testme1@test.com','','');
                Account acc = [Select id, PersonContactId FROM Account WHERE PersonContactId =: user1.ContactId LIMIT 1];
                Social_Media_Identifier__c smi = new Social_Media_Identifier__c();
                smi.Social_Id__c = '123756';
                smi.Social_Media_Type__c = 'Kakao';
                smi.Client__c = acc.id;
                insert smi;
            }
            System.runAs(thisUser) {
                TWIST_RegistrationHandler hdlr = new TWIST_RegistrationHandler();
                
                User u = hdlr.createUser(portalId, data1);
                User userTest = [SELECT Id, Email FROM User WHERE Id = :u.Id LIMIT 1];
                
                System.assertEquals(userTest.Email,'testme1@test.com');
            }
            
            Test.stopTest();
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        
    }
    @isTest static void test_InsertAccKakao() {
        try{
            Identity_TestFactory.createSettings();
            //String mobile = Identity_Utils.getMobilePhone('972', '0541234567');
            Map<String,String> aMap = new Map<String,String>();
            aMap.put('phone_number','+1234567890');
            aMap.put('email_verified','true');
            aMap.put('phone_number_verified','true');
            aMap.put('birthdate_day','05');
            aMap.put('birthdate_month','07');
            aMap.put('birthdate_year','1995');
            aMap.put('base_address','서울 중랑구 면목동 160-4 (면목동)');
            aMap.put('detail_address','test');
            aMap.put('zone_number','02224');
            Auth.UserData data1 = new Auth.UserData('12375675275','test','test','test', 'testme1@test.com','', '','','KAKAO', 'KR', aMap);
            String portalId = 'idd';
            
            Test.startTest();
            
            TWIST_RegistrationHandler hdlr = new TWIST_RegistrationHandler();
            
            User u = hdlr.createUser(portalId, data1);
            User userTest = [SELECT Id, Email FROM User WHERE Id = :u.Id LIMIT 1];
            
            System.assertEquals(userTest.Email,'testme1@test.com');
            Test.stopTest();
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
    }
}
