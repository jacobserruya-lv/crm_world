/**
    About
    -----
    Description: Display Clients Details 
    Created for: SOW: IC001 ICON project
    Create date: Feb 2013

    Details
    -------
    Test class for IC_CLientDetail

    Update History
    --------------
    Feb 2013 / IC001/ Created by Axel KAMALAK
    Sep 2016 / PIPA Law enhancement
    
    Issues / TODOs
    --------------
*/

@isTest
private class IC_ClientDetails_VFCx_TEST {
	
    @TestSetup
    public static void setup() {
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
    }
    
    static testMethod void test1() {
        Account acc = IC_TestFactory.createAccount();
        acc.LastModifierStoreCountry__pc = IC_Factory.getPIPACountryCode('KOREA');
        insert acc;
        
        ICONSettings__c iconSet = new ICONSettings__c();
		iconSet.AccLastContactTimeRange__c=30;
		insert iconSet;
        
        /***  Pipa user  ***/
        User user1 = IC_TestFactory.createUser('user@korean.com');
        user1.Country__c = 'KOREA';
        user1.ProfileId = IC_TestFactory.PROFILE_MAP.get(IC_TestFactory.PROFILE_ICON_SA_NAME);
        insert user1;     
           
        User usr = IC_TestFactory.createUser('dreamuserLV@lvtest.com');
	  	usr.profileId = IC_UTILS.getSAProfile();
	  	insert usr;

        /****Creation of new action plan ***/
        ActionPlan__c c = new ActionPlan__c();  
        c.Comments__c = 'Comments';
        c.IsClosed__c = false;
        c.Subject__c =  'subject'  ;      
        insert c;
	  	
        Test.startTest();
		  	System.runAs(usr) {
	        ApexPages.StandardController stdController = new ApexPages.Standardcontroller( acc );
	        ApexPages.currentPage().getParameters().put('id',acc.Id);
	        
	        IC_ClientDetails_VFCx controller = new IC_ClientDetails_VFCx ( stdController );
	        controller = new IC_ClientDetails_VFCx();

		  	}

        Test.stopTest();        	
    }
        
}