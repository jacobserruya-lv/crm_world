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
private class IC_ClientView_VFCx_TEST {

    @TestSetup
    public static void setup() {
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
    }

    static testMethod void myClientViewTest() {
    	
    	//custom settings set up
    	ICONSettings__c stt = new ICONSettings__c();
      	stt.ExcepPurchaseUSD__c = 3500;
      	stt.Exceptional_Purchase_Currency__c = 'USD';
      	insert stt;
      	
        // Data creation
        Account acc = IC_TestFactory.createAccount();
        acc.LastModifierStoreCountry__pc = IC_Factory.getPIPACountryCode('KOREA');
        acc.Shoes__pc ='44';
        insert acc;
        PPR_PurchProduct__c pp = IC_TestFactory.createPurchaseProduct(acc.Id);
        insert pp;
        ApexPages.currentPage().getParameters().put('id',acc.Id);
        ApexPages.StandardController stdController = new ApexPages.Standardcontroller( acc );
        IC_ClientView_VFCx controller = new IC_ClientView_VFCx(stdController );
        Test.startTest();
        System.assertEquals(controller.PProducts.size(),1);
        System.assertEquals(controller.client.Shoes__pc, acc.Shoes__pc);
        Pagereference page = controller.logACall();
        System.assertEquals(acc.Id, page.getParameters().get('who_id'));
        page = controller.newToDo();
        System.assertEquals(acc.Id, page.getParameters().get('who_id'));
        page = controller.newAppointment();
        System.assertEquals(acc.Id, page.getParameters().get('who_id'));
        controller.editClient();
        controller.editClient();
        controller.deleteClient();
        String str = controller.openActivitiesLabel;
        str = controller.openActivityHistoriesLabel;
        controller.getActionPlans();
        controller.getEventProg();
        Test.stopTest();
        
        
    }
    
    
    static testMethod void myClientViewTestNotAdmin() {
    	
    	//custom settings set up
    	ICONSettings__c stt = new ICONSettings__c();
      	stt.ExcepPurchaseUSD__c = 3500;
      	stt.Exceptional_Purchase_Currency__c = 'USD';
      	insert stt;
      	
        // Data creation
        Account acc = IC_TestFactory.createAccount();
        acc.LastModifierStoreCountry__pc = IC_Factory.getPIPACountryCode('KOREA');
        acc.Shoes__pc ='44';
        insert acc;
        PPR_PurchProduct__c pp = IC_TestFactory.createPurchaseProduct(acc.Id);
        insert pp;
        
        User usr = IC_TestFactory.createUser('dreamuserLV@lvtest.com');
	  	usr.profileId = IC_UTILS.getSAManagerProfile();
	  	insert usr;
	  	
	  	System.runAs(usr) {
        ApexPages.currentPage().getParameters().put('id',acc.Id);
        ApexPages.StandardController stdController = new ApexPages.Standardcontroller( acc );
        IC_ClientView_VFCx controller = new IC_ClientView_VFCx(stdController );
        Test.startTest();
               
        System.assertEquals(controller.PProducts.size(),1);
        System.assertEquals(controller.client.Shoes__pc, null);
        Pagereference page = controller.logACall();
        System.assertEquals(acc.Id, page.getParameters().get('who_id'));
        page = controller.newToDo();
        System.assertEquals(acc.Id, page.getParameters().get('who_id'));
        page = controller.newAppointment();
        System.assertEquals(acc.Id, page.getParameters().get('who_id'));
        controller.editClient();
        controller.editClient();
        controller.deleteClient();
        Test.stopTest();
        
	  	}
    }
}