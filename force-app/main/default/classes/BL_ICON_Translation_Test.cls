/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-06-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-30-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class BL_ICON_Translation_Test  {
    @isTest

    static void testMethodGet(){
     
            BL_AppSettings.setAppSettings('Icon');
           
            User u = IC_Test_Common.prepareTestUser('System Administrator');
            insert u;
            BL_ICON_Translation blTrans = new BL_ICON_Translation();
            system.runAs(u){
                Translation__c trans = new Translation__c(Language__c = 'en_US'); 
                trans.Key__c = 'Ok';
                trans.Value__c='Ok';
                insert trans;
                Test.startTest();  
                blTrans.pathParameters  = new Map<String, String>();
                blTrans.pathParameters.put('language',null);
                blTrans.executeGET();
                Test.stopTest();
            }


    }
    
     @isTest

    static void testMethodGet2(){
     
            BL_AppSettings.setAppSettings('Icon');
           
            User u = IC_Test_Common.prepareTestUser('System Administrator');
            insert u;
            BL_ICON_Translation blTrans = new BL_ICON_Translation();
            system.runAs(u){
                Translation__c trans = new Translation__c(Language__c = 'en_US'); 
                trans.Key__c = 'Ok';
                trans.Value__c='Ok';
                insert trans;
                Test.startTest();  
                blTrans.pathParameters  = new Map<String, String>();
                blTrans.pathParameters.put('language','fr');
                blTrans.executeGET();
                Test.stopTest();
            }


    }
}