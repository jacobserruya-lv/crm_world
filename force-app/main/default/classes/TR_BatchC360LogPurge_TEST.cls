/**
* @File Name          : TR_BatchC360LogPurge_TEST.cls
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
private class TR_BatchC360LogPurge_TEST {
    @TestSetup
    static void setup() {
        List<C360_Logs__c> testLogs = new List<C360_Logs__c>();
        C360_Logs__c   log = new C360_Logs__c(
            TR_Apex_Class__c = 'apex_class_TEST',
            TR_APEX_Limits__c = 'apex_Limits',
            TR_Application__c = 'C360',
            TR_Duration__c = 2 ,
            TR_Error__c = 'error_Message',
            TR_EventUuidLog__c = 'eventUuidLog',
            TR_Has_Error__c  = true,
            TR_JSON__c = 'json',
            TR_Level__c = 'ERROR',
            TR_Message__c = 'logMessage',
            TR_Object_Type__c = 'ACCOUNT',
            TR_Record_Id__c = 'record_Id',
            TR_Type__c = 'Outgoing_flow'
        );
        testLogs.add(log);
        C360_Logs__c   log1 = new C360_Logs__c(
            TR_Apex_Class__c = 'apex_class_TEST',
            TR_APEX_Limits__c = 'apex_Limits',
            TR_Application__c = 'C360',
            TR_Duration__c = 2 ,
            TR_Error__c = '',
            TR_EventUuidLog__c = 'eventUuidLog',
            TR_Has_Error__c  = false,
            TR_JSON__c = 'json',
            TR_Level__c = 'DEBUG',
            TR_Message__c = 'logMessage',
            TR_Object_Type__c = 'ACCOUNT',
            TR_Record_Id__c = 'record_Id',
            TR_Type__c = 'Outgoing_flow'
        );
        testLogs.add(log1);
        C360_Logs__c   log2 = new C360_Logs__c(
            TR_Apex_Class__c = 'apex_class_TEST',
            TR_APEX_Limits__c = 'apex_Limits',
            TR_Application__c = 'C360',
            TR_Duration__c = 2 ,
            TR_Error__c = 'error_Message',
            TR_EventUuidLog__c = 'eventUuidLog',
            TR_Has_Error__c  = true,
            TR_JSON__c = 'json',
            TR_Level__c = 'ERROR',
            TR_Message__c = 'logMessage',
            TR_Object_Type__c = 'ACCOUNT',
            TR_Record_Id__c = 'record_Id',
            TR_Type__c = 'Outgoing_flow'
        );
        testLogs.add(log2);
        C360_Logs__c   log3 = new C360_Logs__c(
            TR_Apex_Class__c = 'apex_class_TEST',
            TR_APEX_Limits__c = 'apex_Limits',
            TR_Application__c = 'C360',
            TR_Duration__c = 2 ,
            TR_Error__c = '',
            TR_EventUuidLog__c = 'eventUuidLog',
            TR_Has_Error__c  = false,
            TR_JSON__c = 'json',
            TR_Level__c = 'INFO',
            TR_Message__c = 'logMessage',
            TR_Object_Type__c = 'ACCOUNT',
            TR_Record_Id__c = 'record_Id',
            TR_Type__c = 'Outgoing_flow'
        );
        testLogs.add(log3);
        C360_Logs__c   log4 = new C360_Logs__c(
            TR_Apex_Class__c = 'apex_class_TEST',
            TR_APEX_Limits__c = 'apex_Limits',
            TR_Application__c = 'C360',
            TR_Duration__c = 2 ,
            TR_Error__c = '',
            TR_EventUuidLog__c = 'eventUuidLog',
            TR_Has_Error__c  = false,
            TR_JSON__c = 'json',
            TR_Level__c = 'DEBUG',
            TR_Message__c = 'logMessage',
            TR_Object_Type__c = 'ACCOUNT',
            TR_Record_Id__c = 'record_Id',
            TR_Type__c = 'Outgoing_flow'
        );
        testLogs.add(log4);
        insert testLogs;
        TR_Integration_Manager_Setting__c setting = new TR_Integration_Manager_Setting__c();
        setting.Name = 'Batch_C360_log';
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
            List<C360_Logs__c> logRecords = [SELECT Id FROM C360_Logs__c];
            System.assertEquals(5,logRecords.size());
            TR_C360LogPurge_Scheduler myScheduler = new TR_C360LogPurge_Scheduler();
            String sch = '0 0 23 L * ?';
            Test.startTest();
            system.schedule('Test check', sch, myScheduler);
            myScheduler.execute(null);
            Test.stopTest();
            List<C360_Logs__c> techRecords2 = [SELECT Id FROM C360_Logs__c];
            System.assertEquals(0,techRecords2.size());
        }
    }    
}