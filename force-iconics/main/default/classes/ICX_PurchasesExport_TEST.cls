@isTest
public class ICX_PurchasesExport_TEST {
    public ICX_PurchasesExport_TEST() {}

    @testSetup static void setup(){
        Account acc = ICX_TestFactory.createAccount();
        acc.DREAMID__c = '1235678901';
        insert acc;
    }
    
    @isTest static void getAllPurchasesTest(){
        String newSearch = '1' ;
        String scrollType = 'NEXT';
        String refSaleID;
        String numTrans = '40';

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        // Account currentAcc = [SELECT Id, DREAMID__c FROM Account WHERE DREAMID__c =: '1235678901' LIMIT 1];
        Test.startTest();
        mock.setStaticResource('C360getPurchases');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        ICX_PurchasesExport.createExportPurchase('1235678901');
        Test.stopTest();

        List<Export_Purchases_Tracability__c> records = [SELECT Id, DreamId__c , Status__c
                                                  FROM  Export_Purchases_Tracability__c 
                                                  WHERE DreamId__c = '1235678901'];
            
        System.assertEquals('Ready To Download',records[0].Status__c, 'The callout returned a response.');
    }
    
     @isTest static void getAllPurchasesTestFailed(){
         String newSearch = '1' ;
         String scrollType = 'NEXT';
         String refSaleID;
         String numTrans = '40';

         StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
         Account currentAcc = [SELECT Id, DREAMID__c FROM Account WHERE DREAMID__c =: '1235678901' LIMIT 1];
         try{
             Test.startTest();
             mock.setStaticResource('C360Error');
             mock.setStatusCode(404);
             mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
             Test.setMock(HttpCalloutMock.class, mock);
             ICX_PurchasesExport.createExportPurchase('1235678');
             Test.stopTest();
    
            List<Export_Purchases_Tracability__c> records = [SELECT Id, DreamId__c , Status__c
                                                      FROM  Export_Purchases_Tracability__c 
                                                      WHERE DreamId__c = '1235678'];
                
            System.assertEquals('Failed',records[0].Status__c, 'The callout returned a failed response.'); 
         } catch(Exception e) {
             List<Export_Purchases_Tracability__c> records = [SELECT Id, DreamId__c , Status__c
                                                      FROM  Export_Purchases_Tracability__c 
                                                      WHERE DreamId__c = '1235678'];
             System.assertEquals('Failed',records[0].Status__c, 'The callout returned a failed response.'); 
         }
         
     }
    
    
    @isTest static void getAllPurchasesTestEmpty(){
         String newSearch = '1' ;
         String scrollType = 'NEXT';
         String refSaleID;
         String numTrans = '40';

         StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
         Account currentAcc = [SELECT Id, DREAMID__c FROM Account WHERE DREAMID__c =: '1235678901' LIMIT 1];
         try{
             Test.startTest();
             mock.setStaticResource('C360getPurchasesEmpty');
             mock.setStatusCode(200);
             mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
             Test.setMock(HttpCalloutMock.class, mock);
             ICX_PurchasesExport.createExportPurchase('102206970');
             Test.stopTest();
    
            List<Export_Purchases_Tracability__c> records = [SELECT Id, DreamId__c , Status__c
                                                      FROM  Export_Purchases_Tracability__c 
                                                      WHERE DreamId__c = '102206970'];
             
             system.debug('recordTESSSSSSSSSSST' + records[0].Status__c);
                
            System.assertEquals('No data for this client',records[0].API_Error_Message__c, 'The callout returned a failed response.'); 
         } catch(Exception e) {
             List<Export_Purchases_Tracability__c> records = [SELECT Id, DreamId__c , Status__c
                                                      FROM  Export_Purchases_Tracability__c 
                                                      WHERE DreamId__c = '102206970'];
             System.assertEquals('Failed',records[0].Status__c, 'The callout returned a failed response.'); 
         }
         
     }
}