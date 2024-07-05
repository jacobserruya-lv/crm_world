@isTest
private class Artycap_ExOrder_ClientDetails_VFC_TEST {
	
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
        
        Exclusive_Campaign__c ec = IC_TestFactory.createExclusiveCampaign('Artycapucines 2023');
        ec.Name = 'Artycapucines 2023';
        ec.AMERICAS__c = true;
        ec.ASIA_NORTH_sans_COREE_CHINE__c = true;
        ec.ASIA_SOUTH__c = true;
        ec.CHINA__c = true;
        ec.EMEA__c = true;
        ec.JAPAN__c = true;
        ec.KOREA__c = true;
        insert ec;
        
        Exclusive_Campaign_Product__c ecp = IC_TestFactory.createExclusiveCampaignProduct('Product A');
        ecp.Exclusive_Campaign__c = ec.Id;
        insert ecp;
        
        Exclusive_Campaign_Order__c order = IC_TestFactory.createExclusiveCampaignOrder(acc, ec, ecp, '12345');
        User u = [SELECT id FROM User WHERE IsActive=true AND Currency__c = 'USD' LIMIT 1];
        order.Client_Advisor__c = u.Id;
        List<Store__c> stores = [Select id from Store__c where Zone__r.ZoneId__c = '13' limit 1];
        if (stores.size()>0)
        	order.Store__c = stores[0].Id;
        insert order;
        
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
	        ApexPages.StandardController stdController = new ApexPages.Standardcontroller( order );
	        ApexPages.currentPage().getParameters().put('id',order.Id);
	        
	        Artycap_ExOrder_ClientDetails_VFC controller = new Artycap_ExOrder_ClientDetails_VFC ( stdController );
	        controller = new Artycap_ExOrder_ClientDetails_VFC();

		  	}

        Test.stopTest();        	
    }
        
}