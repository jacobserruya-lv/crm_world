/***************************************************************************************************
* @File Name          : TR_SocialMediaIdentifierHandler_TEST.cls
* @Description        : This class was created for the C360 project 
* @Author             : Imad.alsidchikh@vo2-consultant.com
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 01-11-2022
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       01-11-2022         Imad.alsidchikh@vo2-group.com     Initial Version
* Updates 
  Sept 2024 (CF-1570)
*****************************************************************************************************/
@isTest
private class TR_SocialMediaIdentifierHandler_TEST {
    @TestSetup
    static void setup() {
        
        TR_Integration_Manager_Setting__c setting = new TR_Integration_Manager_Setting__c();
        setting.Name = 'C360_SocialMedia_Setup';
        setting.Excluded_Profile__c = '';
        setting.Excluded_UserId__c = '';
        setting.Integration_ProfileName__c = 'ICON_Interface DREAM';
        insert setting; 
        TR_Integration_Manager_Setting__c setting2 = new TR_Integration_Manager_Setting__c();
        setting2.Name = 'C360_Client_Setup';
        setting2.Excluded_Profile__c = 'LV_Interface_Datastage;';
        setting2.Excluded_UserId__c = '005i0000000gx4XAAQ';
        setting2.Integration_ProfileName__c = 'ICON_Interface DREAM';
        insert setting2; 
    } 
    @isTest
    static void createSocialMediaTest() {
            Account acc = IC_TestFactory.createAccount();
            acc.AttachedStore__pc='test';
            insert acc;
            Account acc1 = IC_TestFactory.createAccount();
            acc1.AttachedStore__pc='test';
            insert acc1;
            List<Social_Media_Identifier__c> smis = new List<Social_Media_Identifier__c>();
            Social_Media_Identifier__c smi1 = IC_TestFactory.createSocialMediaIdentifier(acc.Id,'Line');
            Social_Media_Identifier__c smi2 = IC_TestFactory.createSocialMediaIdentifier(acc1.Id,'KakaoTalk message');
            test.startTest();
            insert smi1;
            insert smi2;
            smi1.Social_Media_Type__c = 'WeChat'; smi1.Opt_In__c = true;
            update smi1;
        	smi1.Opt_In__c = false; update smi1; //This line; To cover the updateSFMCFlag method (CF-1570)
            smi2.Social_Media_Type__c = 'Line';   smi2.Opt_In__c = false;
            update smi2;
            test.stopTest();
            List<TECH_IntegrationManager__c> tim = [SELECT Id, Operation__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :smi1.Id]; 
            List<TECH_IntegrationManager__c> tim1 = [SELECT Id, Operation__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :smi2.Id];
            System.assertEquals(3,tim.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim[0].Operation__c);
            System.assertEquals(TR_Constants.UPDATE_CL360,tim[1].Operation__c);
            System.assertEquals(2,tim1.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim1[0].Operation__c);
            System.assertEquals(TR_Constants.UPDATE_CL360,tim1[1].Operation__c);
    }
    @isTest
    static void createSocialMediaTest2() {
        // get DREAM user
        User d1m = [Select Id, username from User where alias  = 'ilevy' Limit 1];
        
        //perform Insert as d1m user
        System.runAs(d1m){
            Account acc = IC_TestFactory.createAccount();
            acc.AttachedStore__pc='test';
            insert acc;
            Account acc1 = IC_TestFactory.createAccount();
            acc1.AttachedStore__pc='test';
            insert acc1;
            List<Social_Media_Identifier__c> smis = new List<Social_Media_Identifier__c>();
            Social_Media_Identifier__c smi1 = IC_TestFactory.createSocialMediaIdentifier(acc.Id,'Line');
            Social_Media_Identifier__c smi2 = IC_TestFactory.createSocialMediaIdentifier(acc1.Id,'KakaoTalk message');
            test.startTest();
            insert smi1;
            insert smi2;
            smi1.Social_Media_Type__c = 'WeChat';
            update smi1;
            smi2.Social_Media_Type__c = 'Line';
            update smi2;
            test.stopTest();
            List<TECH_IntegrationManager__c> tim = [SELECT Id, Operation__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :smi1.Id order by Operation__c asc]; 
            List<TECH_IntegrationManager__c> tim1 = [SELECT Id, Operation__c  FROM TECH_IntegrationManager__c  where Object_Id__c  = :smi2.Id order by Operation__c asc];
            System.assertEquals(2,tim.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim[0].Operation__c);
            System.assertEquals(TR_Constants.UPDATE_CL360,tim[1].Operation__c);
            System.assertEquals(2,tim1.size());
            System.assertEquals(TR_Constants.CREATE_CL360,tim1[0].Operation__c);
            System.assertEquals(TR_Constants.UPDATE_CL360,tim1[1].Operation__c);
            
        }
    }
}