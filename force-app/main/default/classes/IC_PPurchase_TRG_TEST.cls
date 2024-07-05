@isTest
private class IC_PPurchase_TRG_TEST{

	@TestSetup
    public static void setup() {
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
    }
	
   //#####Test method for a USD Currency######		
   static testMethod void myTriggerTestUSD() 
    {   
    	//create a SA User 
    	// Start test
		Test.starttest();
        User usr = IC_TestFactory.createUser('dreamuserLV@lvtest.com');
	  	usr.profileId = IC_UTILS.getSAProfile();
	  	usr.DefaultStore__c = 'LV GUADALAJARA PALACIO DE HIERRO';
	  	//usr.UserRoleId = role.Id;
	  	usr.DREAMId__c = '123456';
	  	usr.isactive = true;
	  	insert usr;
	  	system.debug('### ASA test devise USD');
    	system.debug('### activ user ' + usr.isactive);
    	
    	
    	
    	// Create data for test
    	Account acc1 = new Account(
	        LastName = 'TCLTest',
	        FirstName='TCLTest',
	        DREAMID__c = '1515',
	        Salutation = 'Mr',
	        LastTrans__pc = System.Today(),
	        Segmentation__pc = 'VIC',
	        PersonDoNotCall = true,
	        PersonHasOptedOutOfEmail = true,
	        DoNotSMS__pc = true,
	        DoNotContactbyPost__pc = true,
	        BirthdateMonth__pc = '1',
	        Gender__pc = 'Male',
	        HistoricalSpendEUR__pc = 250000
        );
        insert acc1;
		
		list<PPR_PurchProduct__c> lPP = new list<PPR_PurchProduct__c>();
					
		ICONSettings__c iconSet = new ICONSettings__c();
		iconSet.ExcepPurchaseUSD__c=70;
		iconSet.Exceptional_Purchase_Currency__c='USD';
		iconSet.AccLastContactTimeRange__c=30;
		
		insert iconSet;
		
		// 2 Products With USD Currencies
		PPR_PurchProduct__c p1 = new PPR_PurchProduct__c(
			Client__c = acc1.Id,
			PurchasedDate__c = System.Today(),
			ProductLine__c = 'Shoes',
			SKU__c = '1515',
			TicketNumber__c = '789',
			Amount__c = 1000,
			ConvertedAmountUSD__c = 1000,
			SA__c=usr.id
			
		);
		lPP.add(p1);
		
		PPR_PurchProduct__c p2 = new PPR_PurchProduct__c(
			Client__c = acc1.Id,
			PurchasedDate__c = System.Today(),
			ProductLine__c = 'Shoes',
			SKU__c = '1515',
			TicketNumber__c = '789',
			Amount__c = 5000,
			ConvertedAmountUSD__c = 5000,
			SA__c=usr.id
		);
		lPP.add(p2);
		IC_PPurchase_TRG.ExcepPurchases(lPP);
		Task t = new task();
		t.RelatedTicketNumber__c = '789';
		t.Subject ='test';
		insert t;
				
		
		// Test insert trigger
		insert lPP;		
		Test.stopTest();	
		
    }	
    
	//#####Test method for a EUR Currency######
    static testMethod void myTriggerTestEUR() 
    {
    	User usr = IC_TestFactory.createUser('dreamuserLV@lvtest.com');
	  	usr.profileId = IC_UTILS.getSAProfile();
	  	usr.DefaultStore__c = 'LV GUADALAJARA PALACIO DE HIERRO';
	  	//usr.UserRoleId = role.Id;
	  	usr.DREAMId__c = '123456';
	  	usr.isactive = true;
	  	insert usr;  	
    	system.debug('### ASA test devise eur');
    	system.debug('### activ user ' + usr.isactive);
    	
    	   	
		// Create data for test 
		Account acc1 = new Account(
	        LastName = 'TCLTest',
	        FirstName='TCLTest',
	        DREAMID__c = '1515',
	        Salutation = 'Mr',
	        LastTrans__pc = System.Today(),
	        Segmentation__pc = 'VIC',
	        PersonDoNotCall = true,
	        PersonHasOptedOutOfEmail = true,
	        DoNotSMS__pc = true,
	        DoNotContactbyPost__pc = true,
	        BirthdateMonth__pc = '1',
	        Gender__pc = 'Male',
	        HistoricalSpendEUR__pc = 250000
        );
        insert acc1;
		
		list<PPR_PurchProduct__c> lPP = new list<PPR_PurchProduct__c>();
				
		ICONSettings__c iconSet = new ICONSettings__c();
		iconSet.ExcepPurchaseUSD__c=70;
		iconSet.Exceptional_Purchase_Currency__c='EUR';
		iconSet.AccLastContactTimeRange__c=30;
		
		insert iconSet;
		
		//2 Products With EUR Currencies
		PPR_PurchProduct__c p3 = new PPR_PurchProduct__c(
			Client__c = acc1.Id,
			PurchasedDate__c = System.Today().adddays(-14),
			ProductLine__c = 'Shoes',
			SKU__c = '1515',
			TicketNumber__c = '777',
			Amount__c = 1000,
			ConvertedAmountEUR__c = 1000,
			SA__c=usr.id
		);
		lPP.add(p3);
		
		PPR_PurchProduct__c p4 = new PPR_PurchProduct__c(
			Client__c = acc1.Id,
			PurchasedDate__c = System.Today().adddays(-14),
			ProductLine__c = 'Shoes',
			SKU__c = '1515',
			TicketNumber__c = '777',
			Amount__c = 5000,
			ConvertedAmountEUR__c = 5000,
			SA__c=usr.id
		);
		lPP.add(p4);
		
		IC_PPurchase_TRG.ExcepPurchases(lPP);
		Task t = new task();
		t.RelatedTicketNumber__c = '777';
		t.Subject ='test';
		insert t;
				
		// Start test
		Test.starttest();
		// Test insert trigger
		insert lPP;		
		Test.stopTest();
		
	}
    
    //#####Test method for a YEN Currency######
    static testMethod void myTriggerTestYEN() 
    {   
        User usr = IC_TestFactory.createUser('dreamuserLV@lvtest.com');
	  	usr.profileId = IC_UTILS.getSAProfile();
	  	usr.DefaultStore__c = 'LV GUADALAJARA PALACIO DE HIERRO';
	  	//usr.UserRoleId = role.Id;
	  	usr.DREAMId__c = '123456';
	  	usr.isactive = true;
	  	insert usr;  	
    	system.debug('### ASA test devise yen');
    	system.debug('### activ user ' + usr.isactive);
    	    	
    	// Create data for test
    	Account acc1 = new Account(
	        LastName = 'TCLTest',
	        FirstName='TCLTest',
	        DREAMID__c = '1515',
	        Salutation = 'Mr',
	        LastTrans__pc = System.Today().adddays(-14),
	        Segmentation__pc = 'VIC',
	        PersonDoNotCall = true,
	        PersonHasOptedOutOfEmail = true,
	        DoNotSMS__pc = true,
	        DoNotContactbyPost__pc = true,
	        BirthdateMonth__pc = '1',
	        Gender__pc = 'Male',
	        HistoricalSpendEUR__pc = 250000
        );
        insert acc1;
		
		list<PPR_PurchProduct__c> lPP = new list<PPR_PurchProduct__c>();
			
		ICONSettings__c iconSet = new ICONSettings__c();
		iconSet.ExcepPurchaseUSD__c=70;
		iconSet.Exceptional_Purchase_Currency__c='YEN';
		iconSet.AccLastContactTimeRange__c=30;
		
		insert iconSet;
		
		// 2 Products With USD Currencies
		PPR_PurchProduct__c p1 = new PPR_PurchProduct__c(
			Client__c = acc1.Id,
			PurchasedDate__c = System.Today().adddays(-14),
			ProductLine__c = 'Shoes',
			SKU__c = '1515',
			TicketNumber__c = '666',
			Amount__c = 1000,
			ConvertedAmountYEN__c = 1000,
			SA__c=usr.id
		);
		lPP.add(p1);
		
		PPR_PurchProduct__c p2 = new PPR_PurchProduct__c(
			Client__c = acc1.Id,
			PurchasedDate__c = System.Today().adddays(-14),
			ProductLine__c = 'Shoes',
			SKU__c = '1515',
			TicketNumber__c = '666',
			Amount__c = 5000,
			ConvertedAmountYEN__c = 5000,
			SA__c=usr.id
		);
		lPP.add(p2);
		IC_PPurchase_TRG.ExcepPurchases(lPP);
		Task t = new task();
		t.RelatedTicketNumber__c = '666';
		t.Subject ='test';
		insert t;
				
		// Start test
		Test.starttest();
		// Test insert trigger
		insert lPP;		
		Test.stopTest();	
		
    }	
    
     //#####Test method for a YUAN Currency######
     static testMethod void myTriggerTestYUAN() 
    {   
        User usr = IC_TestFactory.createUser('dreamuserLV@lvtest.com');
	  	usr.profileId = IC_UTILS.getSAProfile();
	  	usr.DefaultStore__c = 'LV GUADALAJARA PALACIO DE HIERRO';
	  	//usr.UserRoleId = role.Id;
	  	usr.DREAMId__c = '123456';
	  	usr.isactive = true;
	  	insert usr;
	  	system.debug('### ASA test devise yuan');
    	system.debug('### activ user ' + usr.isactive);
    	
    	// Create data for test
    	Account acc1 = new Account(
	        LastName = 'TCLTest',
	        FirstName='TCLTest',
	        DREAMID__c = '1515',
	        Salutation = 'Mr',
	        LastTrans__pc = System.Today().adddays(-14),
	        Segmentation__pc = 'VIC',
	        PersonDoNotCall = true,
	        PersonHasOptedOutOfEmail = true,
	        DoNotSMS__pc = true,
	        DoNotContactbyPost__pc = true,
	        BirthdateMonth__pc = '1',
	        Gender__pc = 'Male',
	        HistoricalSpendEUR__pc = 250000
        );
        insert acc1;
		
		list<PPR_PurchProduct__c> lPP = new list<PPR_PurchProduct__c>();
		
		ICONSettings__c iconSet = new ICONSettings__c();
		iconSet.ExcepPurchaseUSD__c=70;
		iconSet.Exceptional_Purchase_Currency__c='YUAN';
		iconSet.AccLastContactTimeRange__c=30;
		
		insert iconSet;
		
		// 2 Products With USD Currencies
		PPR_PurchProduct__c p1 = new PPR_PurchProduct__c(
			Client__c = acc1.Id,
			PurchasedDate__c = System.Today().adddays(-15),
			ProductLine__c = 'Shoes',
			SKU__c = '1515',
			TicketNumber__c = '555',
			Amount__c = 1000,
			ConvertedAmountYUAN__c = 1000,
			SA__c=usr.id
		);
		lPP.add(p1);
		
		PPR_PurchProduct__c p2 = new PPR_PurchProduct__c(
			Client__c = acc1.Id,
			PurchasedDate__c = System.Today().adddays(-15),
			ProductLine__c = 'Shoes',
			SKU__c = '1515',
			TicketNumber__c = '555',
			Amount__c = 5000,
			ConvertedAmountYUAN__c = 5000,
			SA__c=usr.id
		);
		lPP.add(p2);
		IC_PPurchase_TRG.ExcepPurchases(lPP);
		Task t = new task();
		t.RelatedTicketNumber__c = '555';
		t.Subject ='test';
		insert t;
				
		// Start test
		Test.starttest();
		// Test insert trigger
		insert lPP;		
		Test.stopTest();	
		
    }	
    
}