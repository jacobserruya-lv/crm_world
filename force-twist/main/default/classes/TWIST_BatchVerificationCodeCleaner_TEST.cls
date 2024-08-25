@isTest
public class TWIST_BatchVerificationCodeCleaner_TEST {
   
    @TestSetup
    static void makeData(){

        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Name = 'test';
        settings.PurgeVerificationCodeIntervalInDays__c = 1;
        settings.Password_Maxlength__c = 5 ;

        Registration_Code_Verification_Request__c  verificationCode = new Registration_Code_Verification_Request__c ();

        verificationCode.isDone__c = false ;
        verificationCode.Code__c = '123';

        insert new List<SObject> {verificationCode ,settings} ;

        Datetime last_5_days = Datetime.now().addDays(-5);
        Test.setCreatedDate(verificationCode.Id, last_5_days);
        
    }

    @isTest 
    static void cleanVerificationCode() {

        TWIST_BatchVerificationCodeCleaner myBatch = new TWIST_BatchVerificationCodeCleaner();
		
		Test.startTest();
		Database.executeBatch(myBatch,50);
		Test.stopTest();

        List<Registration_Code_Verification_Request__c> lst = [SELECT Id FROM Registration_Code_Verification_Request__c ];
		
        System.assertequals(0, lst.size());
      
   }

   @isTest 
   static void testScheduler() {
       Test.startTest();
       String cronExpr = '0 0 23 L * ?';
       TWIST_BatchVerificationCodeCleaner myScheduler = new TWIST_BatchVerificationCodeCleaner();
       String jobId = System.schedule('myJobTestJobName', cronExpr, myScheduler);

       Test.stopTest();    
   }

}