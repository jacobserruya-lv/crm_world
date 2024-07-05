/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class IC_BatchPurgeActionPlan_TEST {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test 
        
       ID batchprocessid; 
       
        Account compte = IC_testFactory.createAccount();
        compte.ToDelete__c = '1';
        compte.DreamIdMasterClient__c = null;
        insert compte;
       
       ActionPlan__c acp1= new ActionPlan__c(); 
        acp1.Subject__c='test1'; 
        acp1.AccountId__c=null; 
        acp1.IsClosed__c=false; 
        insert acp1;
        
        ActionPlan__c acp2= new ActionPlan__c(); 
        acp2.Subject__c='test2';
        acp2.IsClosed__c=false; 
        insert acp2; 
        
        ActionPlan__c acp3= new ActionPlan__c(); 
        acp3.Subject__c='test3';
        acp3.AccountId__c=compte.Id; 
        acp3.IsClosed__c=false; 
        insert acp3; 
        
         List<ID> listID= new List<ID>(); 
        listID.add(acp3.id);  
        
        Test.startTest();
        IC_BatchPurgeActionPlan myBatch = new IC_BatchPurgeActionPlan();
        batchprocessid = Database.executeBatch(myBatch,10);
        
          myBatch = new IC_BatchPurgeActionPlan(listID);
        batchprocessid = Database.executeBatch(myBatch,10);
       
        Test.stopTest();
        
       List<ActionPlan__c> listAcp= [SELECT ID, AccountId__c, IsClosed__c FROM ActionPlan__c WHERE AccountId__c = null OR AccountId__c =''];
       
       List<ActionPlan__c> listAcp2= [SELECT ID, AccountId__c, IsClosed__c FROM ActionPlan__c WHERE Id = :compte.Id];
       
       System.assertequals(listAcp.size(),0);
        System.assertequals(listAcp2.size(),0);
      
    }
}