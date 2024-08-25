/*	 * @author Keman WU
* @date creation 13/10/2022
* @description test class for ICX_RequestPaymentCtrl
*/
@isTest
public with sharing class ICX_RequestPaymentCtrl_TEST {
    @isTest static void myTest1() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();   	

        Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
		insert store1;    
        
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        ProductCatalogue__c product = new ProductCatalogue__c(SKU__c ='M55555');
        insert product;
        List<CareService__c> lstDCS = new List<CareService__c>();
        CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId,Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10001',Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id,IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true,ICONiCS_Status_Detail__c='Repair finalized',TotalAmount_Updated__c=0); 

        insert dcs1;

       test.startTest();
       ICX_RequestPaymentCtrl.requestPayment(dcs1.id);
       test.stopTest();
    }
    @isTest static void myTest2() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();   	

        Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
		insert store1;    
           
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        ProductCatalogue__c product = new ProductCatalogue__c(SKU__c ='M55555');
        insert product;
        List<CareService__c> lstDCS = new List<CareService__c>();
        
        CareService__c dcs2 = new CareService__c(recordTypeId = DistantCareRTId,Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10001',Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id,IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true,ICONiCS_Status_Detail__c='Repair finalized',TotalAmount_Updated__c=100); 
   
        insert dcs2;

       test.startTest();
       ICX_RequestPaymentCtrl.requestPayment(dcs2.id);
       test.stopTest();
    }
    @isTest static void myTest3() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();   	

          
        Store__c store2= new Store__c(RetailStoreId__c = 'J91');
		insert store2;     
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        ProductCatalogue__c product = new ProductCatalogue__c(SKU__c ='M55555');
        insert product;
        List<CareService__c> lstDCS = new List<CareService__c>();
        
        CareService__c dcs3 = new CareService__c(recordTypeId = DistantCareRTId,Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='DE',Shipping_Zip_Postal_Code__c='10001',Client__c =acc.Id, StoreRetailCode__c = 'J91', Store__c = store2.Id,IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true,ICONiCS_Status_Detail__c='Repair finalized',TotalAmount_Updated__c=200); 
        
        insert dcs3;

       test.startTest();
       ICX_RequestPaymentCtrl.requestPayment(dcs3.id);
       test.stopTest();
    }
    @isTest static void myTest4() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();   	

          
        Store__c store2= new Store__c(RetailStoreId__c = 'J91');
		insert store2;     
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        ProductCatalogue__c product = new ProductCatalogue__c(SKU__c ='M55555');
        insert product;
        List<CareService__c> lstDCS = new List<CareService__c>();
        
        CareService__c dcs3 = new CareService__c(recordTypeId = DistantCareRTId,Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='DE',Shipping_Zip_Postal_Code__c='10001',Client__c =acc.Id, StoreRetailCode__c = 'J91', Store__c = store2.Id,IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true,ICONiCS_Status_Detail__c='Repair finalized',TotalAmount_Updated__c=0); 
        
        insert dcs3;

       test.startTest();
       ICX_RequestPaymentCtrl.requestPayment(dcs3.id);
       test.stopTest();
    }
}