@isTest
private class IDENTITY_WS_PurchaseHistory_TEST {

    @testSetup static void setup() {
           
        Account acct = new Account(
            LastName = 'TCLTest'
        );
        insert acct;

        List<String> storeTypes = new List<String>{'Store','Web','CSC','Store'};
        List<Boolean> flag1 = new List<Boolean>{true,false,false,false};
        List<Boolean> flag2 = new List<Boolean>{false,true,false,false};  
        List<Boolean> flag3 = new List<Boolean>{false,false,true,false};
        List<Boolean> flag4 = new List<Boolean>{false,false,false,true};
        List<Integer> price = new List<Integer>{225,225,225,-225};


        List<PPR_PurchProduct__c> purchases = new List<PPR_PurchProduct__c>();
        for (Integer i=0;i<4;i++) {
            purchases.add(new PPR_PurchProduct__c(    
                OrderATGId__c='ABEY69',
                RMSSKUCode__c='LP0001',
                StoreRetailCode__c='WFR',
                Store__c='WFR',
                Quantity__c=1,
                Amount__c=price.get(i),
                TransactionTotalAmount__c=225,
                CurrencyCode__c='EUR',
                MacroMaterial__c='TEXTILE',
                Model__c='HKB05WZQD 2054 MULTI ZIP LIGHT',
                ProductLine__c='Ready To Wear',
                Name='APOGEE 100ML EDP01',
                TransactionCCFlag__c=flag1.get(i),
                TransactionStHFlag__c=flag2.get(i),
                TransactionEAFlag__c=flag3.get(i),
                TransactionStSFlag__c=flag4.get(i),
                TransactionStoreType__c=storeTypes.get(i),
                TicketNumber__c='261779608',
                Client__c=acct.Id));
        }
        // Insert all opportunities for all accounts.
        insert purchases;

        PPR_PurchProduct__c purchase = new PPR_PurchProduct__c(    
            OrderATGId__c='ABEY69',
            RMSSKUCode__c='LP0001',
            StoreRetailCode__c='WFR',
            Store__c='WFR',
            Quantity__c=1,
            Amount__c=225,
            TransactionTotalAmount__c=225,
            CurrencyCode__c='EUR',
            MacroMaterial__c='TEXTILE',
            Model__c='HKB05WZQD 2054 MULTI ZIP LIGHT',
            ProductLine__c='Ready To Wear',
            Name='APOGEE 100ML EDP01',
            TransactionCCFlag__c=false,
            TransactionStHFlag__c=false,
            TransactionEAFlag__c=false,
            TransactionStSFlag__c=false,
            TransactionStoreType__c='Web',
            TicketNumber__c='261779608',
            Client__c=acct.Id);
        //insert purchase;
        
    } 

    
    
    @isTest
    static void test1(){

        Id recordId = [SELECT Id FROM Account LIMIT 1 ].Id;

        RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
        
    req.requestURI = '/identity/purchaseHistory/'+recordId;


    req.httpMethod = 'GET';
        req.addParameter('exclude', '1,2');
        req.addParameter('orderType', 'digital,retail,CSC');
    RestContext.request = req;
    RestContext.response = res;

        Test.startTest();
        IDENTITY_WS_PurchaseHistory.get();
        Test.stopTest();
    }

  
    
   
             
}