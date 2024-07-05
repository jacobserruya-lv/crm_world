@isTest
public with sharing class BL_ICON_BatchUpdateLineClients_TEST {
@testsetup static void setupMethod(){
        Account acc =  new Account(LastName = 'test', BoundToLVLine__c = false, PrimaryCountry__pc = 'JAPAN');
        insert acc;
         
        Social_Media_Identifier__c sm = new Social_Media_Identifier__c(Social_Id__c = 'ojqn700Qv3x0kSkVikRDXHt', Social_Media_Type__c = 'Line', Client__c = acc.Id);
        insert sm;
         
   }
    
    @isTest static void test_batchUpdateLineClients() {
		
    Test.startTest();
    String jobId = Database.executeBatch(new BL_ICON_BatchUpdateLineClients(), 200);

    Test.stopTest();
   }
}