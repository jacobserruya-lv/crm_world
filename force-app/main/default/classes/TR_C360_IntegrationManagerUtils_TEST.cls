/***************************************************************************************************
* @File Name          : TR_C360_IntegrationManagerUtils_TEST.cls
* @Description        : This class was created for the C360 project 
* @Author             : Imad.alsidchikh@vo2-consultant.com
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 01-08-2022
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       01-08-2022         Imad.alsidchikh@vo2-group.com     Initial Version
*****************************************************************************************************/
@isTest(SeeAllData=false)
public class TR_C360_IntegrationManagerUtils_TEST {
    @TestSetup
    public static void setup() {
        
        TR_Integration_Manager_Setting__c setting = new TR_Integration_Manager_Setting__c();
        setting.Name = 'C360_Client_Setup';
        setting.Excluded_Profile__c = 'No_Profile;';
        setting.Excluded_UserId__c = '';
        setting.Integration_ProfileName__c = 'ICON_Interface DREAM';
        insert setting; 
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
    } 
    @isTest
    static void createUpdateAccountTest1() {
        // get Automated Process user
        User autProUser = [Select Id, username from User where Alias = 'autoproc'  Limit 1];
        
        //perform Insert as Automated Process user
        System.runAs(autProUser){
            Account acc = IC_TestFactory.createAccount();
            acc.AttachedStore__pc='test';
            acc.MobilePhoneCountryCallingCode__pc = '972';
            acc.LocalLoginPhone__pc = '0541234567';
            acc.LoginPhoneCallingCode__pc = '972';
            acc.LocalMobilePhone__pc = '0541234567';
            acc.MobilePhoneCountryCallingCode__pc = '972';
            acc.PrimaryCountry__pc = 'FRANCE';
            acc.Salutation = '02';
            acc.HomeAddressCountryCode__pc = 'FRA';
            acc.RecordTypeId = TR_Constants.recordTypeClient;
            Account acc1 = IC_TestFactory.createAccount();
            acc1.RecordTypeId = TR_Constants.recordTypeClient;
            acc1.AttachedStore__pc='test1';
            test.startTest();
            insert acc;
            insert acc1;
            acc.FirstName='DREAMTEST18';
            acc.Firstname2__pc='DREAMTEST19';
            acc.LastName='TESTDREAM18';
            acc.LastName='TESTDREAM19';
            Update acc;
            acc1.FirstName='DREAMTEST18';
            acc1.Firstname2__pc='DREAMTEST19';
            acc1.LastName='TESTDREAM18';
            acc1.LastName='TESTDREAM19';
            Update acc1;
            test.stopTest();
            List<TECH_IntegrationManager__c> tim = [SELECT Id, Operation__c,Object_Id__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :acc.Id order by CreatedDate ASC]; 
            List<TECH_IntegrationManager__c> tim1 = [SELECT Id, Operation__c,Object_Id__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :acc1.Id order by CreatedDate ASC];
            System.assertEquals(1,tim.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim[0].Operation__c);
            System.assertEquals(1,tim1.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim1[0].Operation__c);
            
        }
      
    }
    @isTest
    static void createUpdateAccountTest2(){
          // get Tech Batch user
        User TechBatchUser = [Select Id, username from User where Alias = 'ilevy'  Limit 1];
          System.runAs(TechBatchUser){
            Account acc = IC_TestFactory.createAccount();
            acc.AttachedStore__pc='test';
            acc.MobilePhoneCountryCallingCode__pc = '972';
            acc.LocalLoginPhone__pc = '0541234567';
            acc.LoginPhoneCallingCode__pc = '972';
            acc.LocalMobilePhone__pc = '0541234567';
            acc.MobilePhoneCountryCallingCode__pc = '972';
            acc.PrimaryCountry__pc = 'FRANCE';
            acc.Salutation = '02';
            acc.HomeAddressCountryCode__pc = 'FRA';
            acc.RecordTypeId = TR_Constants.recordTypeClient;
            Account acc1 = IC_TestFactory.createAccount();
            acc1.RecordTypeId = TR_Constants.recordTypeClient;
            acc1.AttachedStore__pc='test1';
            test.startTest();
            insert acc;
            insert acc1;
            acc.FirstName='DREAMTEST18';
            acc.Firstname2__pc='DREAMTEST19';
            acc.LastName='TESTDREAM18';
            acc.LastName='TESTDREAM19';
            Update acc;
            acc1.FirstName='DREAMTEST18';
            acc1.Firstname2__pc='DREAMTEST19';
            acc1.LastName='TESTDREAM18';
            acc1.LastName='TESTDREAM19';
            Update acc1;
            test.stopTest();
            List<TECH_IntegrationManager__c> tim = [SELECT Id, Operation__c,Object_Id__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :acc.Id order by CreatedDate ASC]; 
            List<TECH_IntegrationManager__c> tim1 = [SELECT Id, Operation__c,Object_Id__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :acc1.Id order by CreatedDate ASC];
            System.assertEquals(2,tim.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim[0].Operation__c);
            System.assertEquals(TR_Constants.UPDATE_CL360,tim[1].Operation__c);
         //   System.assertEquals(2,tim1.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim1[0].Operation__c);
            System.assertEquals(TR_Constants.UPDATE_CL360,tim[1].Operation__c);
            
        }
    }
    @isTest
    static void createUpdateAccountWithC360FlowTest() {
        User autProUser = [Select Id, username from User where Alias = 'autoproc'  Limit 1];
        //perform Flow as Automated Process user
        System.runAs(autProUser){
            C360_Tech_Event_Return_Flow__e flowC360 = new C360_Tech_Event_Return_Flow__e();
            flowC360.Body_Json__c = getJson('','','','');
            test.startTest();       
            // C360 Create Account
            TR_C360_IntegrationManager_Utils.setAccountEventBus(flowC360, System.now());
            List<C360_Logs__c> Log01 = [Select id,TR_Has_Error__c,TR_Level__c,TR_Error__c,TR_Object_Type__c, TR_Record_Id__c from C360_Logs__c order by createdDate desc];
            List<Account> accs = [SELECT Id,Name from Account];
            System.assertEquals(1,Log01.size());
            System.assertEquals(False,Log01[0].TR_Has_Error__c);
         //   System.assertEquals(1,accs.size());
            List<TECH_IntegrationManager__c> tim = [SELECT Id, Operation__c,Object_Id__c  FROM TECH_IntegrationManager__c];
            System.assertEquals(1,tim.size());
            // C360 Update Account with SF Id
            flowC360.Body_Json__c = getJson(accs[0].Id,'000001','','');
            TR_C360_IntegrationManager_Utils.setAccountEventBus(flowC360, System.now());
            List<C360_Logs__c> Log02 = [Select id,TR_Has_Error__c,TR_Level__c,TR_Error__c,TR_Object_Type__c, TR_Record_Id__c from C360_Logs__c order by createdDate desc];
            List<Account> accs2 = [SELECT Id,Name from Account];
            System.assertEquals(2,Log02.size());
            System.assertEquals(False,Log02[1].TR_Has_Error__c);
            System.assertEquals(1,accs2.size());
            // C360 Update Account with C360Id
            flowC360.Body_Json__c = getJson('','000001','1','');
            TR_C360_IntegrationManager_Utils.setAccountEventBus(flowC360, System.now());
            List<C360_Logs__c> Log03 = [Select id,TR_Has_Error__c,TR_Level__c,TR_Error__c,TR_Object_Type__c, TR_Record_Id__c from C360_Logs__c order by createdDate desc];
            List<Account> accs3 = [SELECT Id,Name from Account];
            System.assertEquals(3,Log03.size());
            System.assertEquals(False,Log03[2].TR_Has_Error__c);
            System.assertEquals(1,accs3.size());
            // C360 Create Account
            flowC360.Body_Json__c = getJson('','000002','','');
            TR_C360_IntegrationManager_Utils.setAccountEventBus(flowC360, System.now());
            List<C360_Logs__c> Log04 = [Select id,TR_Has_Error__c,TR_Level__c,TR_Error__c,TR_Object_Type__c, TR_Record_Id__c from C360_Logs__c order by createdDate desc];
            List<Account> accs4 = [SELECT Id,Name from Account];
            System.assertEquals(4,Log04.size());
            System.assertEquals(False,Log04[3].TR_Has_Error__c);
            System.assertEquals(2,accs4.size());
            //C360 test merge
            flowC360.Body_Json__c = getJson('','000002','1','000001');
            TR_C360_IntegrationManager_Utils.setAccountEventBus(flowC360, System.now());
            List<Account> accs5 = [SELECT Id,Name from Account];
            //todo create asset
            flowC360.Body_Json__c = getJson('000001','','','');
            EventBus.publish(flowC360);
            test.stopTest();
        }
    }
    public static String getJson(String sfId, String C360Id, String activeFlag , String masterC360Id) {
        String json = '{';
        json += '"activeFlag": "'+activeFlag+'",';
        json += '"residencePostalAddress_addressLine3": "4 Rue de Paris",';
        json += '"residencePostalAddress_addressLine2": "2 Rue de Paris",';
        json += '"residencePostalAddress_addressLine1": "1 Rue de Paris",';
        json += '"touchApplicationCode": "C360",';
        json += '"dreamId": "'+C360Id+'",';
        json += '"passportNumbers": "00000004",';
        json += '"workPhoneNumber_internationnal": "3315456545454",';
        json += '"preferredLanguage_code": "FRA",';
        json += '"City_of_Residence": "Oran",';
        json += '"residencePostalAddress_countryCodeIso": "FRA",';
        json += '"birthDate": "1989-03-21",';
        json += '"clientTimestamp": "2022-06-27T10:35:42.923+02:00",';
        json += '"clientType_code": "02",';
        json += '"clientType_libelle": "Client",';
        json += '"dreamId_master": "'+masterC360Id+'",';
        json += '"firstName": "testen001",';
        json += '"firstName2": "testen001",';
        json += '"gender_code": "M",';
        json += '"gender_libelle": "Male",';
        json += '"homePhoneNumber_countryCodeIso2": "FR",';
        json += '"homePhoneNumber_internationnal": "+33100000000",';
        json += '"lastName": "test123",';
        json += '"lastName2": "test123",';
        json += '"homePhoneNumber_number": "0100000000",';
        json += '"mobilePhoneNumber_internationnalPrefixe": "33",';
        json += '"mobilePhoneNumber_countryCodeIso2": "FR",';
        json += '"mobilePhoneNumber_internationnal": "+33700000000",';
        json += '"mobilePhoneNumber_number": "0700000000",';
        json += '"nationality_code": "FRA",';
        json += '"nationality_libelle": "French",';
        json += '"isOptInToReceiveMarketingEmails": "true",';
        json += '"emailAddress": "test001@test.test",';
        json += '"isOptInToReceiveMails": "true",';
        json += '"isOptInToReceiveCalls": "true",';
        json += '"State_of_Residence": "Test",';
        json += '"Zip_Code": "75001",';
        json += '"civility_code": "02",';
        json += '"salesforceId": "'+sfId+'",';
        json += '"title_code": "02",';
        json += '"workPhoneNumber_countryCodeIso2": "FR",';
        json += '"workPhoneNumber_number": "0100000000",';
        json += '"worldwideId": "",';
        json += '"isOptInToReceiveSms": "true",';
        json += '"residencePostalAddress_country": "French"';
        json += '}';
        return json;
    }
}