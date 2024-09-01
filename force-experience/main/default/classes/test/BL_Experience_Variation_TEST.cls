@isTest
public class BL_Experience_Variation_TEST {


    @TestSetup
	static void createTestData() {

		Account acc = IC_TestFactory.createAccount();
		insert acc;

		Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06');
		insert store;

		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = 'A06';
		u.WWEmployeeNumber__c = 'WW198765467';
		insert u;

        User ca = IC_Test_Common.prepareTestUser('ICON_SA');
		ca.DefaultStore__c = 'A06';
		ca.WWEmployeeNumber__c = 'WW198765';
		insert ca;

        Brand_Experience__c ex = new Brand_Experience__c();
        ex.Name = 'test';
        ex.Status__c = 'Ongoing';
        ex.Experience_StartDate__c =  DateTime.Now().AddDays(45);
        ex.Experience_EndDate__c = DateTime.Now().AddDays(72) ;
        ex.RecordTypeId = BL_Experience_Variation_Utils.getRecordTypeExperience('Experience');
    
        insert ex;

        Brand_Experience_Variation__c exVar = new Brand_Experience_Variation__c();
        exVar.Brand_Experience__c = ex.Id;
        exVar.Store__c = store.Id;
        exVar.Name = 'test';
        exVar.Status__c = 'Draft';
        exVar.StartDateTime__c = DateTime.Now().AddDays(46);
        exVar.EndDateTime__c = DateTime.Now().AddDays(47);
        exVar.RecordTypeId = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();
        insert exVar;

        exVar.Status__c = 'Ready';
        update exVar;

        exVar.Status__c = 'Participation Opened';
        update exVar;
        Brand_Experience_Variation_Evite__c evite = new Brand_Experience_Variation_Evite__c();
        evite.Language__c = 'en_US';
        evite.URL__c = 'https://salesforce.com';
        evite.Experience_Variation__c = exVar.Id;
        insert evite;

        Brand_Experience_Variation_Member__c exMember = new Brand_Experience_Variation_Member__c();
        exMember.Brand_Experience_Variation__c = exVar.Id;
        exMember.Client__c = acc.Id;
        exMember.NominationStatus__c = 'Approved';
        exMember.Assigned_CA__c = ca.Id;
        exMember.rsvpState__c = 'Registered';

        insert exMember;
        
        Brand_Experience_Variation_Member_Guest__c guest = new Brand_Experience_Variation_Member_Guest__c(
            Name='Test Guest',
            Relationship__c ='Child',
            Brand_Experience_Variation_Member__c = exMember.Id            
        );
        insert guest;
	}
  

    @isTest
    static void getExperienceVariations(){
             
        BL_AppSettings.setAppSettings('Experience');
        BL_Experience_Variation blexperience = new BL_Experience_Variation();

        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            
            blexperience.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blexperience.queryParams = new Map<String, String>{
                'storeId' => 'A06'
            };
            
            blexperience.path = '/experience-variations';
           
            Test.startTest();
                blexperience.requestBody = new Map<String,Object>{}; 
                blexperience.pathParameters = new Map<String, String>{};
                blexperience.executeGET();
            Test.stopTest();
        }
    }

    @isTest
    static void getExperienceVariationsIconCA(){
             
        BL_AppSettings.setAppSettings('Experience');
        BL_Experience_Variation blexperience = new BL_Experience_Variation();

        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765'];

        system.runAs(u){
            
            blexperience.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blexperience.queryParams = new Map<String, String>{
                'storeId' => 'A06'
            };
            
            blexperience.path = '/experience-variations';
           
            Test.startTest();
                blexperience.requestBody = new Map<String,Object>{}; 
                blexperience.pathParameters = new Map<String, String>{};
                blexperience.executeGET();
            Test.stopTest();
        }
    }

    @isTest
    static void getExperienceVariationByIdCA(){
             
        BL_AppSettings.setAppSettings('Experience');
        BL_Experience_Variation blexperience = new BL_Experience_Variation();

        Brand_Experience_Variation__c variation = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 1];

        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765'];

        system.runAs(u){
            
            blexperience.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blexperience.queryParams = new Map<String, String>{
                'storeId' => 'A06'
            };
            
            blexperience.path = '/experience-variations/{id}';
           
            Test.startTest();
                blexperience.requestBody = new Map<String,Object>{}; 
                blexperience.pathParameters = new Map<String, String>{
                    'id' => variation.id
                };
                blexperience.executeGET();
            Test.stopTest();
        }
    }

    @isTest
    static void getExperienceVariationById(){
             
        BL_AppSettings.setAppSettings('Experience');
        BL_Experience_Variation blexperience = new BL_Experience_Variation();

        Brand_Experience_Variation__c variation = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 1];

        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            
            blexperience.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blexperience.queryParams = new Map<String, String>{
                'storeId' => 'A06'
            };
            
            blexperience.path = '/experience-variations/{id}';
           
            Test.startTest();
                blexperience.requestBody = new Map<String,Object>{}; 
                blexperience.pathParameters = new Map<String, String>{
                    'id' => variation.id
                };
                blexperience.executeGET();
            Test.stopTest();
        }
    }

    @isTest
    static void getExperienceVariationMembers(){
             
        BL_AppSettings.setAppSettings('Experience');
        BL_Experience_Variation blexperience = new BL_Experience_Variation();

        Brand_Experience_Variation__c variation = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 1];

        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            
            blexperience.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blexperience.queryParams = new Map<String, String>{}; 
            blexperience.path = '/experience-variations/{id}/members';
           
            Test.startTest();
                blexperience.requestBody = new Map<String,Object>{}; 
                blexperience.pathParameters = new Map<String, String>{
                    'id' => variation.id
                };
                blexperience.executeGET();
            Test.stopTest();
        }

    }

    @isTest
    static void getExperienceVariationMemberById(){
             
        BL_AppSettings.setAppSettings('Experience');
        BL_Experience_Variation blexperience = new BL_Experience_Variation();

        Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];

        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            
            blexperience.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blexperience.queryParams = new Map<String, String>{}; 
            blexperience.path = '/experience-variations/members/{id}';
           
            Test.startTest();
                blexperience.requestBody = new Map<String,Object>{}; 
                blexperience.pathParameters = new Map<String, String>{
                    'id' => member.id
                };
                blexperience.executeGET();
            Test.stopTest();
        }

    }

    @isTest
    static void getExperienceVariationEvites(){
             
        BL_AppSettings.setAppSettings('Experience');
        BL_Experience_Variation blexperience = new BL_Experience_Variation();

        Brand_Experience_Variation__c variation = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 1];

        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            
            blexperience.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blexperience.queryParams = new Map<String, String>{}; 
            blexperience.path = '/experience-variations/{id}/evites';
           
            Test.startTest();
                blexperience.requestBody = new Map<String,Object>{}; 
                blexperience.pathParameters = new Map<String, String>{
                    'id' => variation.id
                };
                blexperience.executeGET();
            Test.stopTest();
        }
    }

    @isTest
    static void postVariationMember(){
             
        BL_AppSettings.setAppSettings('Experience');
        BL_Experience_Variation blexperience = new BL_Experience_Variation();

        Brand_Experience_Variation__c variation = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 1];
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        Account acc = IC_TestFactory.createAccount();
		insert acc;

        system.runAs(u){
            
            blexperience.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blexperience.queryParams = new Map<String, String>{};
            blexperience.path = '/experience-variations/{id}/members';

            List<Map<String,Object>> records = new List<Map<String,Object>> ();

            Map<String,Object> record = new Map<String,Object>{
                'client' => acc.Id,
                'nominationStatus=' => 'Pending',
                'assignedCa' => u.Id
            }; 

            records.add(record);
           
            Test.startTest();
                blexperience.requestBody = new Map<String,Object>{
                    'records' => records
                }; 
                blexperience.pathParameters = new Map<String, String>{
                    'id' => variation.id
                };
                blexperience.executePOST();
            Test.stopTest();
        }
    }


    @isTest
    static void putVariationMember(){
             
        BL_AppSettings.setAppSettings('Experience');
        BL_Experience_Variation blexperience = new BL_Experience_Variation();

        Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        Account acc = IC_TestFactory.createAccount();
		insert acc;

        system.runAs(u){
            
            blexperience.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blexperience.queryParams = new Map<String, String>{};
            blexperience.path = '/experience-variations/members/{id}';

            Map<String,Object> record = new Map<String,Object>{
                'nominationStatus=' => 'Refused'
            }; 
           
            Test.startTest();
                blexperience.requestBody = record;
                blexperience.pathParameters = new Map<String, String>{
                    'id' => member.id
                };
                blexperience.executePUT();
            Test.stopTest();
        }
    }
    
    @isTest
    static void getExperienceVariationKpi(){
             
        BL_AppSettings.setAppSettings('Experience');
        BL_Experience_Variation blexperience = new BL_Experience_Variation();

        Brand_Experience_Variation__c variation = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 1];

        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            
            blexperience.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blexperience.queryParams = new Map<String, String>{}; 
            blexperience.path = '/experience-variations/{id}/kpi';
           
            Test.startTest();
                blexperience.requestBody = new Map<String,Object>{}; 
                blexperience.pathParameters = new Map<String, String>{
                    'id' => variation.id
                };
                blexperience.queryParams = new Map<String, String>{
                    'features' => 'REGISTRATION;PARTICIPATION'
                };

                blexperience.executeGET();
            Test.stopTest();
        }

    }
    @isTest
    static void testGuestsUpsert(){
             
        BL_AppSettings.setAppSettings('Experience');
        BL_Experience_Variation blexperience = new BL_Experience_Variation();

        //Brand_Experience_Variation__c variation = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 1];
		Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];
        member.rsvpState__c = 'Registered';
        update member;
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];
	
        system.runAs(u){
            
            blexperience.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blexperience.queryParams = new Map<String, String>{}; 
            blexperience.path = '/experience-variations/members/{id}/guests';
           
            Test.startTest();
                blexperience.requestBody = new Map<String,Object>{}; 
                blexperience.pathParameters = new Map<String, String>{
                    'id' => member.id
                };
         List<Object> putItems = (List<Object>)JSON.deserializeUntyped('[ {"id": null, "relationship":"Parent", "member": "' + member.Id + '"}]');
        blexperience.requestBody = new Map<String,Object>{
                    'guests' => putItems
        };
        blexperience.executePUT();
        Test.stopTest();
        }

    }
// @isTest
//     static void testGuestsDelete(){
             
//         BL_AppSettings.setAppSettings('Experience');
//         BL_Experience_Variation blexperience = new BL_Experience_Variation();

//         //Brand_Experience_Variation__c variation = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 1];
// 		Brand_Experience_Variation_Member_Guest__c guest = [SELECT Id FROM Brand_Experience_Variation_Member_Guest__c LIMIT 1];
//         Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];
//         Store__c store = [SELECT Id FROM Store__c LIMIT 1];
//         User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];
	
//         system.runAs(u){
            
//             blexperience.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
//             blexperience.queryParams = new Map<String, String>{}; 
//             blexperience.path = '/experience-variations/members/{id}/guests';
           
//             Test.startTest();
//                 blexperience.requestBody = new Map<String,Object>{}; 
//                 blexperience.pathParameters = new Map<String, String>{
//                     'id' => member.id
//                 };
//          List<Object> delItems = (List<Object>)JSON.deserializeUntyped('[ {'+guest.Id+'}]');
//         blexperience.requestBody = new Map<String,Object>{
//                     'guests' => delItems
//         };
//         blexperience.executeDELETE();
//         Test.stopTest();
//         }
//     }

    @isTest
    static void updateNominationStatusTrigger(){
    
        Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
                   
            Test.startTest();
            member.NominationStatus__c = 'Pending' ;
            update member;
            member.NominationStatus__c = 'Refused';
            update member;

            member.NominationStatus__c = 'Approved';
            update member;
            Test.stopTest();
        }
    }

    @isTest
    static void updateRegistrationStatusTrigger(){
             
        Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
                   
            Test.startTest();
            member.rsvpState__c = 'Registered' ;
            update member;

            member.rsvpState__c = 'Declined' ;
            update member;

            member.rsvpState__c = 'Removed' ;
            update member;
           
            Test.stopTest();
        }
    }

    @isTest
    static void updateParticipationStatusTrigger(){
             
        Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
                   
            Test.startTest();
            member.rsvpState__c = 'Registered' ;
            member.Attendance__c = 'Yes' ;
            update member;

            member.Attendance__c = 'No' ;
            update member;
            Test.stopTest();
        }
    }
    @isTest
    static void testupsertMemberAndRelated(){
             
        BL_AppSettings.setAppSettings('Experience');
        BL_Experience_Variation blexperience = new BL_Experience_Variation();

        Brand_Experience_Variation__c variation = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 1];
		Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];
        member.rsvpState__c = 'Registered';
        update member;
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];
	
        system.runAs(u){
            
            blexperience.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blexperience.queryParams = new Map<String, String>{}; 
            blexperience.path = '/experience-variations/members/{id}/save';
           
            Test.startTest();
                blexperience.requestBody = new Map<String,Object>{}; 
                blexperience.pathParameters = new Map<String, String>{
                    'id' => member.id
                };
         
            List<Object> guests = (List<Object>)JSON.deserializeUntyped('[ {"id": null, "relationship":"Parent", "member": "' + member.Id + '"}]');
            List<Object> appointment = (List<Object>)JSON.deserializeUntyped('[ {"id": null, "startDateTime":"' + Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '", "endDateTime":"' + DateTime.now().addDays(2).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')+ '", "assignedToId":"' + u.Id + + '","subject":"test event","event":  "' + member.Id + '"}]');
            blexperience.requestBody = new Map<String,Object>{
                    'guests' => guests,
                    'appointment' => appointment,
                    'assignedCa' => u.Id,
                    'rsvpstatus'=>'Confirmed',
                    'status' => 'participated'
            };
            blexperience.executePUT();
            Test.stopTest();
            }
    }
   
}