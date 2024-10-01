@isTest
public with sharing class TWIST_BatchDeleteResetPwdRequest_TEST {

    @TestSetup
    static void setup() {        
        TWIST_Settings__c setting = new TWIST_Settings__c();
        setting.Name = 'TWIST_Settings';
        setting.Purge_ResetPwdRequest__c=1;
        setting.Password_Maxlength__c = 20;
        insert setting; 
    }
    @isTest 
    static void testBatch() {
        ID batchprocessid;  
        
        Reset_Password_Request__c request = new Reset_Password_Request__c(
            Email__c = 'email',
            Token__c = 'token',
            Status__c = TWIST_ResetPasswordTokenService.TOKEN_ISSUED
            );
        insert request;                                                    
                                                            
        Datetime before2days = Datetime.now().addDays(-2);
        Test.setCreatedDate(request.Id, before2days);  
        
        TWIST_BatchDeleteResetPwdRequest myBatch = new TWIST_BatchDeleteResetPwdRequest();
        
        Test.startTest();
        batchprocessid = Database.executeBatch(myBatch,1000);
        Test.stopTest();
        
        List<Reset_Password_Request__c> lst = [SELECT Id FROM Reset_Password_Request__c WHERE Id = :request.Id];
        System.assertequals(lst.isEmpty(), true);
    }

    @isTest 
    static void testScheduler() {
        Test.startTest();
        String cronExpr = '0 0 23 L * ?';
        TWIST_BatchDeleteResetPwdRequest dtc = new TWIST_BatchDeleteResetPwdRequest();
        String jobId = System.schedule('myJobTestJobName', cronExpr, dtc);
        dtc.execute(null);
        Test.stopTest();    
    }
}