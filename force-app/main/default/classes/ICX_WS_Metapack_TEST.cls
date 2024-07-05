/*	 * @author Keman WU
* @date creation 04/11/2021
* @description test class for ICX_WS_Metapack
*/
@isTest
public with sharing class ICX_WS_Metapack_TEST {  

        @isTest static void testcreateShippingOrderMetapack1() {
         set<ID> careIds = new set<ID>();
         Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 
         Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
         insert store1;      
         Account acc = ICX_TestFactory.createAccount();
         insert acc;       
         CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId,Destination__c = '156RAS3',MYLV_Care_Status__c = 'preliminary_assessment_acc',Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10001', Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id, IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
         insert dcs1;
         careIds.add(dcs1.id);   
         
 
         test.startTest();            
          Test.setMock(HttpCalloutMock.class, new ICX_WS_Metapack_MOCK());       
          ICX_WS_Metapack.createShippingOrderMetapack(careIds);
         test.stopTest();
     }
    
     @isTest static void testcreateShippingOrderMetapack2() {
         set<ID> careIds = new set<ID>();
         Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 
         Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
         insert store1;      
         Account acc = ICX_TestFactory.createAccount();
         insert acc;       
         
         CareService__c dcs2 = new CareService__c(recordTypeId = DistantCareRTId,Destination__c = '156RAS3',ICONiCS_Status_Detail__c='Payment Confirmed',Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10001', Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id, IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
         insert dcs2;
         careIds.add(dcs2.id);
 
         test.startTest();            
          Test.setMock(HttpCalloutMock.class, new ICX_WS_Metapack_MOCK());       
          ICX_WS_Metapack.createShippingOrderMetapack(careIds);
         test.stopTest();
     }

 
}