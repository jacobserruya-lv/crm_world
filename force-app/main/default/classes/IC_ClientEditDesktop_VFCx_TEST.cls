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
private class IC_ClientEditDesktop_VFCx_TEST {

    static testMethod void myClientEditDesktopTest() {
        // Data creation
        Account acc = IC_TestFactory.createAccount();
        acc.LastModifierStoreCountry__pc = IC_Factory.getPIPACountryCode('KOREA');
        acc.EventInterest__pc = 'Shop';
        insert acc;
        ApexPages.currentPage().getParameters().put('id',acc.Id);
        ApexPages.StandardController stdController = new ApexPages.Standardcontroller( acc );
        IC_ClientEditDesktop_VFCx controller = new IC_ClientEditDesktop_VFCx(stdController );
        
        Test.startTest();        
        System.assertEquals(controller.client.EventInterest__pc,acc.EventInterest__pc);
        controller.client.EventInterest__pc = 'IT';
        controller.client.Jacket__pc = 'M0';
        controller.client.Dress__pc='D0';
        
        system.debug('### start test with administrator');
        controller.client.Knit__pc = null;
    	controller.client.Pant__pc = null ;
    	controller.client.Shirt__pc = null ;
    	controller.client.Skirt__pc = null ;
    	controller.client.Suit__pc = null ;
    	controller.client.Belt__pc = null ;
    	controller.client.Shoes__pc = null ;
    	controller.client.Ring__pc = null ;        	
    	// Lifestyle & Family
    	controller.client.Spouse__pc = null ;
    	controller.client.AnniversaryYear__pc = null ;
    	controller.client.AnniversaryMonth__pc = null ;
    	controller.client.AnniversaryDay__pc = null ;
    	controller.client.Children__pc = null ;
    	controller.client.Pets__pc = null ;
    	controller.client.ShopsFor__pc = null ;
    	controller.client.PersonalInterest1__pc = null ;
    	controller.client.PersonalInterest2__pc = null ;
    	controller.client.PersonalInterest3__pc = null ;
    	controller.client.FoodPreferences__pc = null ;
    	controller.client.BeveragePreferences__pc = null ;
    	controller.client.PersonAssistantName = null ;
    	controller.client.PersonAssistantPhone = null ;        	
    	//LV Interests
    	controller.client.AccessoriesInterest__pc = null ;
    	controller.client.JewelleryInterest__pc = null ;
    	controller.client.LeatherGoodsInterest__pc = null ;
    	controller.client.RTWInterest__pc = null ;
    	controller.client.ShoesInterest__pc = null ;
    	controller.client.WatchesInterest__pc = null ;
    	controller.client.OtherInterest__pc = null ;
    	controller.client.ServiceInterest__pc = null ;
    	
    	system.debug('### End test with administrator');
        
        
        
        
        controller.saveClient();
        Account a = [select Jacket__pc from Account where Id =:acc.Id];
        System.assertEquals(a.Jacket__pc,'M0');
        Test.stopTest();
    }
    
    static testMethod void myClientEditDesktopTestNotAdminUser() {
        // Data creation
        
        //UserRole role = [select Id from UserRole where Name ='MEX - LV GUADALAJARA PALACIO DE HIERRO - Manager'];
        User usr = IC_TestFactory.createUser('dreamuserLV@lvtest.com');
	  	usr.profileId = IC_UTILS.getSAManagerProfile();
	  	usr.DefaultStore__c = 'UGD';
	  	//usr.UserRoleId = role.Id;
	  	usr.DREAMId__c = '123456';
	  	insert usr;
    
        Account acc = IC_TestFactory.createAccount();
        acc.LastModifierStoreCountry__pc = IC_Factory.getPIPACountryCode('KOREA');
        acc.EventInterest__pc = 'Shop';
        acc.AttachedStore__pc = 'UGD';
        acc.OwnerId = usr.Id;
        acc.TECH_DreamIdSA__pc = '123456';
        insert acc;
	  	
	  	System.runAs(usr) {

            ApexPages.currentPage().getParameters().put('id',acc.Id);
	        ApexPages.StandardController stdController = new ApexPages.Standardcontroller( acc );
	        IC_ClientEditDesktop_VFCx controller = new IC_ClientEditDesktop_VFCx(stdController );
	        
	        Test.startTest();        
	        System.assertEquals(controller.client.EventInterest__pc,null);
	        controller.client.EventInterest__pc = 'IT';
	        controller.client.Jacket__pc = null;  // 'M0'
	        controller.client.Dress__pc=null; // 'D0'
	        
	        system.debug('### start test without administrator');
	        
	        controller.client.Knit__pc = null;
        	controller.client.Pant__pc = null ;
        	controller.client.Shirt__pc = null ;
        	controller.client.Skirt__pc = null ;
        	controller.client.Suit__pc = null ;
        	controller.client.Belt__pc = null ;
        	controller.client.Shoes__pc = null ;
        	controller.client.Ring__pc = null ;        	
        	// Lifestyle & Family
        	controller.client.Spouse__pc = null ;
        	controller.client.AnniversaryYear__pc = null ;
        	controller.client.AnniversaryMonth__pc = null ;
        	controller.client.AnniversaryDay__pc = null ;
        	controller.client.Children__pc = null ;
        	controller.client.Pets__pc = null ;
        	controller.client.ShopsFor__pc = null ;
        	controller.client.PersonalInterest1__pc = null ;
        	controller.client.PersonalInterest2__pc = null ;
        	controller.client.PersonalInterest3__pc = null ;
        	controller.client.FoodPreferences__pc = null ;
        	controller.client.BeveragePreferences__pc = null ;
        	controller.client.PersonAssistantName = null ;
        	controller.client.PersonAssistantPhone = null ;        	
        	//LV Interests
        	controller.client.AccessoriesInterest__pc = null ;
        	controller.client.JewelleryInterest__pc = null ;
        	controller.client.LeatherGoodsInterest__pc = null ;
        	controller.client.RTWInterest__pc = null ;
        	controller.client.ShoesInterest__pc = null ;
        	controller.client.WatchesInterest__pc = null ;
        	controller.client.OtherInterest__pc = null ;
        	controller.client.ServiceInterest__pc = null ;
        	
        	system.debug('### End test without administrator');
        	
        	
	        controller.saveClient();
	        Account a = [select Jacket__pc, Dress__pc from Account where Id =:acc.Id];
	       // System.assertEquals(a.Jacket__pc,'M0');
	      //  System.assertEquals(a.Dress__pc,'D0');
	        Test.stopTest();
	  	}
        
    }
}