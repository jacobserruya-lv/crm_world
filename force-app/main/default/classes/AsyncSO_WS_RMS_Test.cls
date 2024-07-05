/**
* This is a test class for :
* AsyncSO_WS_RMS_ClientEnquiryV3
* AsyncSO_WS_RMS_ClientSearchV3
* AsyncSO_WS_RMS_SalesCreation_v3
* AsyncSO_WS_RMS_SaleServices
* AsyncWS019_CreateDeposit
* SO_WS_RMS_Async_ProductSearch

* @createdBy           Calev Machiah, 11-08-2022
* @lastModifiedBy      Calev Machiah, 11-08-2022
*/

@isTest
private class AsyncSO_WS_RMS_Test { // MIY-2154
    
    // @testSetup
	// public static void setup(){

	// 	List<Store__c> ls = new List<Store__c>();
	// 	ls.add(new Store__c (Name='ST1', RetailStoreId__c='ST1'));
	// 	ls.add(new Store__c (Name='ST2', RetailStoreId__c='ST2'));
	// 	ls.add(new Store__c (Name='ST3', RetailStoreId__c=''));

	// 	insert ls;

	// 	ProductReferential__c p = new ProductReferential__c(SKUCode__c = 'SKU1');
	// 	insert p;
	// }

	// @isTest
	// public static void test_AsyncSO_WS_RMS(){
        
		
        
	// 	try{
    //     AsyncWS019_CreateDeposit.AsyncLVSaleAPI_v1_webServices_saleServices_Port babi = new AsyncWS019_CreateDeposit.AsyncLVSaleAPI_v1_webServices_saleServices_Port();
    //     AsyncWS019_CreateDeposit.salesCreationFromNYResponseFuture fdbabi = babi.beginSalesCreationFromNY(null,null);
    //             }
    //     catch(Exception e){
    //         system.debug('error');
    //     }

    //     try{       
    //     AsyncSO_WS_RMS_SalesCreation_v3.AsyncWSLV003_webService_v3_0_salesCreation_Port_2 newRep6 = new AsyncSO_WS_RMS_SalesCreation_v3.AsyncWSLV003_webService_v3_0_salesCreation_Port_2();
    //     AsyncSO_WS_RMS_SalesCreation_v3.mainServiceResponseFuture badabooba = newRep6.beginMainService(null, null);
    //     }
    //     catch(Exception e){
    //         system.debug('error');
    //     }    

    //     try{       
    //     AsyncSO_WS_RMS_ClientSearchV3.AsyncWSLV013_webService_v3_0_clientSearch_Port newRep7 = new AsyncSO_WS_RMS_ClientSearchV3.AsyncWSLV013_webService_v3_0_clientSearch_Port();       
    //     AsyncSO_WS_RMS_ClientSearchV3.mainServiceResponseFuture tatoo =  newRep7.beginMainService(null, null);     
    //     }
    //     catch(Exception e){
    //         system.debug('error');
    //     }
        
    //     try{          
    //     AsyncSO_WS_RMS_ClientEnquiryV3.AsyncWSLV012_webService_v3_0_clientDetailEnquiry_Port newRepaa = new AsyncSO_WS_RMS_ClientEnquiryV3.AsyncWSLV012_webService_v3_0_clientDetailEnquiry_Port();
    //     AsyncSO_WS_RMS_ClientEnquiryV3.mainServiceResponseFuture babyaaa = newRepaa.beginMainService(null ,null); 
    //         }
    //     catch(Exception e){
    //         system.debug('error');
    //     }
        


    //     try{         
    //     SO_WS_RMS_Async_ProductSearch.AsyncWSLV017_webService_v1_0_itemSearch_Port clientTest = new SO_WS_RMS_Async_ProductSearch.AsyncWSLV017_webService_v1_0_itemSearch_Port();
    //     SO_WS_RMS_Async_ProductSearch.mainServiceResponseFuture future2 = clientTest.beginMainService(null ,null); 
    //     }
    //     catch(Exception e){
    //         system.debug('error');
    //     }
        
    //     try{       
    //     AsyncSO_WS_RMS_SaleServices.AsyncWSLV003_webService_v3_0_salesCreation_Port_2 newRep6 = new AsyncSO_WS_RMS_SaleServices.AsyncWSLV003_webService_v3_0_salesCreation_Port_2();
    //     AsyncSO_WS_RMS_SalesCreation_v3.mainServiceResponseFuture badabooba = newRep6.beginMainService(null, null);
    //     }
    //     catch(Exception e){
    //         system.debug('error');
    //     } 

    //     Test.setMock(WebServiceMock.class, new AsyncSO_WS_RMS_Mock());
        
	// 	Test.startTest();
        
	// 	try{  
	// 	ProductReferential__c p = [SELECT id FROM ProductReferential__c WHERE SKUCode__c = 'SKU1' LIMIT 1];
	// 	String stockJSON = SO_ProductController.getStock(p.id, 'ST1');
    //     }
    //     catch(Exception e){
    //         system.debug('error');
    //     }
        
	// 	Test.stopTest();

	// }
}