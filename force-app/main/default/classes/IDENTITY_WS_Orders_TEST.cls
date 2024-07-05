@isTest
private class IDENTITY_WS_Orders_TEST {

    @testSetup static void setup() {
           
        Account acct = new Account(
            LastName = 'TCLTest'
           
           
        );
        insert acct;


        Store__c store = new Store__c(    ShortName__c='PARIS S GERMAIN',
                                    StoreType__c='Store',
                                    RetailStoreId__C='A03');
        insert store;                          

        ProductReferential__c productReferential = new ProductReferential__c(   SKUCode__C='LP0003',
                                                                                Name='TURBULENCE 100ML EDP',
                                                                                MacroColor__c='Gris');
        insert productReferential;                                                                
                         

        Order__c order = new Order__c( OrderDate__c=System.Now(),
                                    OrderNumber__c='1234',
                                    Source__c='KBRW',
                                    Store__c=store.Id,
                                    Account__c=acct.Id);

        insert order;


        OrderShipping__c orderShipping = new OrderShipping__c(    Status__c='polled',
                                                            StatusDate__c=System.Now(),
                                                            DeliveryType__c='shipforpickup',
                                                            Order__c=order.Id);  
        insert orderShipping; 



        OrderLine__c orderline = new OrderLine__C(   Quantity__c=1,
                                                SKU__C='LP0003',
                                                Order__c=order.Id,
                                                ProductReferential__c=productReferential.Id,
                                                OrderShipping__c=orderShipping.Id);   
        insert orderline;    

        
    } 

    
    
    @isTest
    static void test1(){

        Id recordId = [SELECT Id FROM Account LIMIT 1 ].Id;

        RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
        
		req.requestURI = '/identity/orders/'+recordId;


		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
        IDENTITY_WS_Orders.get();
        Test.stopTest();
    }

  
    
   
             
}