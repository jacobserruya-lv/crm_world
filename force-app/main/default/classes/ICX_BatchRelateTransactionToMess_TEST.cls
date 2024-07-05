@isTest
public class ICX_BatchRelateTransactionToMess_TEST {
	@testSetup 
	static void TransactionCallsCreation() {   
		Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ACC_PersonAccount').getRecordTypeId();

        Account client1 = new Account();
		client1.LastName ='Test Client';
		client1.RecordTypeId = personAccountRTId;
        
        insert client1;
            
        //Create products
		ProductCatalogue__c products = new ProductCatalogue__c(SKU__c='TST321');
		insert products;

		//Create createMessagingEndUser        
        List<Account> accountList = [select id ,PersonContactId from account];
		MessagingSession messages = createMessagingSession(accountList.get(0),products,'nx123',2);
		insert messages;

		//Create transactions
		
        
        PPR_PurchProduct__c purchasedProduct2 = createPurchasedProduct(client1 , 'TST321' ,'nx123');
        purchasedProduct2.OrderATGId__c = 'nx123';
        insert purchasedProduct2;
        Datetime yesterday = Datetime.now().addDays(-1);
		Test.setCreatedDate(purchasedProduct2.Id, yesterday);
	}
	
	@isTest static void executeBatch() {
		Test.startTest();
		Id batchId = Database.executeBatch(new ICX_BatchRelateTransactionToMessaging());
		Test.stopTest();

		PPR_PurchProduct__c ppr2 = [SELECT Id FROM PPR_PurchProduct__c WHERE SKU__c='TST321'];
		MessagingSession case2 = [SELECT Id,Purchased_Product__c,AcceptTime,MessagingEndUserID,EndUserAccountId ,EndUserContactId ,MessagingEndUser.AccountId,MessagingEndUser.ContactId FROM MessagingSession WHERE Sku_Number__c='TST321'limit 1];
		System.assertEquals(ppr2.Id, case2.Purchased_Product__c);
        system.debug('case2' +case2);
	}
	
	private static PPR_PurchProduct__c createPurchasedProduct(Account client , String SKU ,String TicketNumber){
        
        PPR_PurchProduct__c purchasedProduct = new PPR_PurchProduct__c();
		purchasedProduct.Client__c = client.Id;
		purchasedProduct.SKU__c = SKU ;
		purchasedProduct.Store__c = 'T11';
		purchasedProduct.TransactionStoreType__c='CSC';
		purchasedProduct.PurchasedDate__c  = Date.today().addDays(1);
		purchasedProduct.TicketNumber__c = TicketNumber;
		purchasedProduct.Quantity__c = 1; 
        
        return purchasedProduct;
    }

    private static MessagingEndUser createMessagingEndUser(Id messagingChannelId , Integer i,Account client) {
    
        MessagingEndUser enduser = new MessagingEndUser();
        endUser.Name = 'test'+i;
        endUser.messagingChannelId = messagingChannelId;
        endUser.MessageType = 'Text';
        endUser.MessagingPlatformKey = 'test'+i;
        endUser.ContactId = client.PersonContactId;
        endUser.AccountId = client.id;

        return endUser;
    }
    
    private static MessagingSession createMessagingSession(Account client , ProductCatalogue__c product ,String TicketNumber ,Integer i) {
        MessagingChannel chan = [SELECT Id FROM MessagingChannel LIMIT 1]; 
        MessagingEndUser enduser =  createMessagingEndUser(chan.Id,i,client);
        insert enduser;
        
        MessagingSession mess = new MessagingSession();
        mess.Status = 'Active';
        mess.Product_SKU__c = product.id;
        mess.AcceptTime = Date.today();
        mess.Transaction_Id__c = TicketNumber;
        mess.MessagingChannelId = chan.Id;
        mess.MessagingEndUserId = enduser.id; 
        mess.OwnerId = userinfo.getuserid();
        
        return mess;
    }
}