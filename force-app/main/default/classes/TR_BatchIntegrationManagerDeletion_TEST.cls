/**
* @File Name          : TR_BatchIntegrationManagerDeletion_TEST.cls
* @Description        : 
* @Author             : Imad.alsidchikh.ext@louisvuitton.com
* @Group              : 
* @Last Modified By   : Imad.alsidchikh.ext@louisvuitton.com
* @Last Modified On   : 01-12-2022
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       01-12-2022      Imad.alsidchikh.ext@louisvuitton.com     Initial Version
**/
@isTest
private class TR_BatchIntegrationManagerDeletion_TEST {
    @TestSetup
    static void setup() {
        List<TECH_IntegrationManager__c> TesManags = new List<TECH_IntegrationManager__c>();
        TECH_IntegrationManager__c TesManag = new TECH_IntegrationManager__c();
        TesManag.Object_Name__c = TR_Constants.OBJECT_ACCOUNT;
        TesManag.Operation__c = TR_Constants.UPDATE_CL360;
        TesManags.Add(TesManag);
        TECH_IntegrationManager__c TesManag1 = new TECH_IntegrationManager__c();
        TesManag1.Object_Name__c = TR_Constants.OBJECT_SOCIALMEDIA;
        TesManag1.Operation__c = TR_Constants.UPDATE_CL360;
        TesManags.Add(TesManag1);
        TECH_IntegrationManager__c TesManag2 = new TECH_IntegrationManager__c();
        TesManag2.Object_Name__c = TR_Constants.OBJECT_ACCOUNT;
        TesManag2.Operation__c = TR_Constants.CREATE_CL360;
        TesManags.Add(TesManag2);
        insert TesManags;
        
        TR_Integration_Manager_Setting__c setting = new TR_Integration_Manager_Setting__c();
        setting.Name = 'Batch_Deletion_Setup';
        setting.Created_Before_Days__c=0;
        insert setting; 
        
    }
    @isTest
    static void testBatch() {	
        User AdminTest = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        AdminTest.BypassWF__c = true;
        AdminTest.BypassVR__c = true;
        AdminTest.Country__c = 'FRANCE';
        insert AdminTest;
        System.runAs(AdminTest) {
            List<TECH_IntegrationManager__c> techRecords = [SELECT Id FROM TECH_IntegrationManager__c];
            System.assertEquals(3,techRecords.size());
            TR_IntegrationManagerDeletion_Scheduler myScheduler = new TR_IntegrationManagerDeletion_Scheduler();
            String sch = '0 0 23 L * ?';
            Test.startTest();
            system.schedule('Test check', sch, myScheduler);
            myScheduler.execute(null);

            Test.stopTest();
            List<TECH_IntegrationManager__c> techRecords2 = [SELECT Id FROM TECH_IntegrationManager__c];
            System.assertEquals(0,techRecords2.size());
        }
    }    
}