@isTest
global class IDENTITY_RegistrationHandler_TEST {
    
    
    @isTest static void test_one() {
        try{
        Identity_TestFactory.createSettings();
        
        //String mobile = Identity_Utils.getMobilePhone('972', '0541234567');

        Auth.UserData data1 = new Auth.UserData('123756','','','', 'testme1@test.com','', '','','Facebook', '', new Map<String,String>());

        Map<String,String> aMap = new Map<String,String>();
        aMap.put('login_international_mobile_phone','+1234567890');
        Auth.UserData data2 = new Auth.UserData('12375675275','','','', 'testme22@test.com','', '','','Facebook', '', aMap);
       
        String portalId = 'idd';

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser) {
            User user1 = Identity_TestFactory.createUser('TEST1','TEST1','testme1@test.com','','');
            User user2 = Identity_TestFactory.createUser('TEST2','TEST2','testme2@test.com','0541234567','972');
        }

        Test.startTest();

            // RULE 1: SOCIAL ID / EMAIL           
            System.runAs(thisUser) {
                IDENTITY_RegistrationHandler hdlr = new IDENTITY_RegistrationHandler(); 
                
                User u = hdlr.createUser(portalId, data1);
                User userTest = [SELECT Id, Email FROM User WHERE Id = :u.Id];
				
                System.assertEquals(userTest.Email,'testme1@test.com');
            }

            // RULE 2: MOBILE PHONE          
            System.runAs(thisUser) {
                IDENTITY_RegistrationHandler hdlr = new IDENTITY_RegistrationHandler(); 
                
                User u2 = hdlr.createUser(portalId, data2);
                User userTest2 = [SELECT Id, Email FROM User WHERE Id = :u2.Id];
                System.assertEquals(userTest2.Email,'testme2@test.com');
                
                // TEST THIS WAY INSTEAD OF THROW EXCEPTION 
                hdlr.setPayload(data2);
            }
			 
        Test.stopTest();
       } catch (Exception ex) {
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
    
                User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
                System.runAs(thisUser) {
                    User user1 = Identity_TestFactory.createUser('TEST1','TEST1','testme1@test.com','','');
                    Account acc = [Select id, PersonContactId FROM Account WHERE PersonContactId =: user1.ContactId];
                    Social_Media_Identifier__c smi = new Social_Media_Identifier__c();
                    smi.Social_Id__c = '123756';
                    smi.Social_Media_Type__c = 'Kakao';
                    smi.Client__c = acc.id;
                    insert smi;
                }
                System.runAs(thisUser) {
                    IDENTITY_RegistrationHandler hdlr = new IDENTITY_RegistrationHandler(); 
               
                    User u = hdlr.createUser(portalId, data1);
                    User userTest = [SELECT Id, Email FROM User WHERE Id = :u.Id];
                    
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
    
            IDENTITY_RegistrationHandler hdlr = new IDENTITY_RegistrationHandler(); 
             
             User u = hdlr.createUser(portalId, data1);
             User userTest = [SELECT Id, Email FROM User WHERE Id = :u.Id];
             
             System.assertEquals(userTest.Email,'testme1@test.com');
             Test.stopTest();
         } catch (Exception ex) {
            System.debug(ex.getMessage());
        }  
        
    }
 }