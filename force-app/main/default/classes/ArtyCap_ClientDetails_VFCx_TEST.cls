@isTest
private class ArtyCap_ClientDetails_VFCx_TEST {
	
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
        
        PreReservation__c preResa = new PreReservation__c();
        preResa.Client__c = acc.Id;
        preResa.Product__c = ecp.Id;
        List<Store__c> stores = [Select id from Store__c where Zone__r.ZoneId__c = '13' limit 1];
        if (stores.size()>0)
        	preResa.Store__c = stores[0].Id;
        insert preResa;
        
        ICONSettings__c iconSet = new ICONSettings__c();
		iconSet.AccLastContactTimeRange__c=30;
		insert iconSet;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ArtyCappucines_Corporate'];

        /***  Pipa user  ***/
        User user1 = IC_TestFactory.createUser('user@korean.com');
        user1.Country__c = 'KOREA';
        user1.ProfileId = IC_TestFactory.PROFILE_MAP.get(IC_TestFactory.PROFILE_ICON_SA_NAME);
        insert user1;     
           
        PermissionSetAssignment psa1 = new PermissionSetAssignment();
		psa1.AssigneeId= user1.Id;
        psa1.PermissionSetId = ps.Id;
        
        User usr = IC_TestFactory.createUser('dreamuserLV@lvtest.com');
	  	usr.profileId = IC_UTILS.getSAProfile();
	  	insert usr;
        
        PermissionSetAssignment psa2 = new PermissionSetAssignment();
		psa2.AssigneeId= usr.Id;
        psa2.PermissionSetId = ps.Id;

        /****Creation of new action plan ***/
        ActionPlan__c c = new ActionPlan__c();  
        c.Comments__c = 'Comments';
        c.IsClosed__c = false;
        c.Subject__c =  'subject'  ;      
        insert c;
	  	
        Test.startTest();
		  	System.runAs(usr) {
                insert psa1;
                insert psa2;
	        ApexPages.StandardController stdController = new ApexPages.Standardcontroller( preResa );
	        ApexPages.currentPage().getParameters().put('id',preResa.Id);
	        
	        Artycap_ClientDetails_VFC controller = new Artycap_ClientDetails_VFC ( stdController );
	        controller = new Artycap_ClientDetails_VFC();

		  	}

        Test.stopTest();        	
    }
        
}