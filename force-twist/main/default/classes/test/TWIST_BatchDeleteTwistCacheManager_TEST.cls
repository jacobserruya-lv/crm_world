@isTest
public class TWIST_BatchDeleteTwistCacheManager_TEST {
    
    @TestSetup
    static void setup(){
        
        List<TwistCacheManager__c> records = new List<TwistCacheManager__c>();
        for (Integer i=0;i<10;i++) {
            records.add(new TwistCacheManager__c(Key__c = i+'test.sa@louisvuitton.com',
            LangCountry__c ='eng-us', TTL__c = 48,Type__c = 'AGE_RESTRICTION', Value__c = '2024-01-31'));
        }
        insert records;
        Datetime before2days = Datetime.now().addDays(-2);
        for(TwistCacheManager__c elt : records){
           Test.setCreatedDate(elt.Id, before2days); 
        }
    }
    
    @isTest static void testBatch() {
        Test.startTest();
        TWIST_BatchDeleteTwistCacheManager bc = new TWIST_BatchDeleteTwistCacheManager();
        Id batchId = Database.executeBatch(bc,10);
        Test.stopTest();
        List<TwistCacheManager__c> lst = [SELECT Key__c, LangCountry__c, TTL__c, Value__c, Type__c, CreatedDate, isblocked__c FROM TwistCacheManager__c WHERE isblocked__c = false];
		System.assertequals(0, lst.size());
    }
   
   @isTest 
   static void testScheduler() {
       Test.startTest();
       String cronExpr = '0 0 23 L * ?';
       TWIST_BatchDeleteTwistCacheManager myScheduler = new TWIST_BatchDeleteTwistCacheManager();
       String jobId = System.schedule('myJobTestJobName', cronExpr, myScheduler);
	   Test.stopTest();    
   }
}
        