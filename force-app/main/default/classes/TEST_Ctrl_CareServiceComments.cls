@isTest
public class TEST_Ctrl_CareServiceComments {

    /*@isTest
    static void testGetUserName() {
        Test.startTest();
        User testUser = TEST_Utils.createUser('test user');        
        System.runAs(testUser) {
            String str = Ctrl_CareServiceComments.getUserName();
            System.debug('*****from test class '+str);
        }
        Test.stopTest(); 
    }*/
    
    @isTest static void test_method_one() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        test.startTest();
        CareService__c item = new CareService__c(StoreRetailCode__c='A06', client__c=acc.Id);
        insert item;
        Ctrl_CareServiceComments.addICONComment(item.Id, 'a new comment from test');
        test.stopTest();
  }
     @isTest static void test_method_two() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        test.startTest();
        CareService__c item = new CareService__c(StoreRetailCode__c='A06', client__c=acc.Id);
        insert item;
        Ctrl_CareServiceComments.getCareServiceFromId(item.Id);
        test.stopTest();
  }
    
   
}