/*	 * @author Keman WU
* @date creation 26/10/2022
* @description test class for Task_TriggerHandler
*/
@istest
public with sharing class Task_TriggerHandler_TEST {
    @isTest static void myTestMethod1() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Id dpcaRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId();
        Case existingDPCA = new Case(AccountId=acc.Id,RecordTypeId=dpcaRTId);
        insert existingDPCA;  
        Task tsk = ICX_TestFactory.createEmailTaskOnCase(existingDPCA.Id);
        tsk.ActivityDate= system.today();
        Test.startTest();   
        insert tsk  ;   
        Case myDPCA = [select Id , Coming_Action__c from case where RecordTypeId=:dpcaRTId];
        System.assertEquals(tsk.ActivityDate, myDPCA.Coming_Action__c);
        
        Test.stopTest();
    }

    }