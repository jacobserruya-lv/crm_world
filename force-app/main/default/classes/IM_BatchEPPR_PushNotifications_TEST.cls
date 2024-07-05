@isTest
private class IM_BatchEPPR_PushNotifications_TEST {
	
	@isTest static void test_method_one() {
		ID batchprocessid;
		if(IM_Notifications__c.getInstance('en_US')==null){
		IM_Notifications__c IMN =  new IM_Notifications__c(Name='en_US',Client_List__c='A new client List was assigned to you : {0}',
			Exceptional_Purchase__c='The client {0} has a new Exceptional Purchase Product : {1} $',Survey__c='A new Survey was created by: {0}',Clients_Reassigned__c='Clients have been reassigned to you {0}');
		insert IMN;}
		Account a = IC_TestFactory.createAccount();
		insert a;
		PPR_PurchProduct__c epp = IC_TestFactory.createPurchaseProduct(a.Id);
		epp.ExceptionalPurchaseFlag__c=true; 
		epp.ExceptionalPurchaseCA__c=true;
		insert epp;
		IM_BatchEPPR_PushNotifications bat = new IM_BatchEPPR_PushNotifications();	
        batchprocessid=Database.executeBatch(bat);

	}
	
	
	
}