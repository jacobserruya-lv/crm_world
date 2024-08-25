/*	 * @author Keman WU
* @date creation 23/08/2021
* @description test class for CareService_TriggerHandler
*/
@isTest
public with sharing class CareService_TriggerHandler_TEST {

    @isTest static void myTestMethodDSC1() {
        
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        insert u;
        

        
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 	 
       
        Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
		insert store1;
        

        ProductCatalogue__c product = new ProductCatalogue__c(SKU__c ='M55555');
        product.Workshop__c = '1798'; //became required
        insert product;
        CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id, IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
       insert dcs1;       
      
        test.startTest();      
        system.runAs(u){
        try {
            dcs1.ICONiCS_Status_Detail__c = 'Pending Customer information';                       
            update dcs1;
             
            dcs1.ICONiCS_Status_Detail__c = 'New Request';                       
            update dcs1;
            
            dcs1.ICONiCS_Status_Detail__c = 'Preliminary Quote Pending Validation'; 
            dcs1.Quotation_sent_date__c = system.today();           
            dcs1.packingListNumber__c = '869758758';
            update dcs1;    
            
        } catch (Exception e) {
              system.debug('TestCareService_TriggerHandler_TEST Exception'+e.getMessage());   
        }  
        }
        test.stopTest();
       
        
    }
     @isTest static void myTestMethodDCS2() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 	
      
        Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
		insert store1;
       
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        ProductCatalogue__c product = new ProductCatalogue__c(SKU__c ='M55555');
        product.Workshop__c = '1798'; //became required
        insert product;
        CareService__c dcs2 = new CareService__c(recordTypeId = DistantCareRTId,Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10001',Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id,IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true); 
        
        insert dcs2;
       
        test.startTest();       
        try {
            dcs2.Assigned_To__c = userInfo.getUserId();
            dcs2.SKU__c = 'M41414';
            dcs2.MyRepairStatus__c ='shippedToRepairCenter';
           // dcs2.ICONiCS_Status_Detail__c = 'Received in Repair Center'; 
            update dcs2;
            dcs2.Product__c = product.id;
            dcs2.Care_Expert_Note__c='test note';
           // dcs2.ICONiCS_Status_Detail__c = 'Shipped to Client'; 
            update dcs2;
            dcs2.TransactionId__c='TEST';
            //dcs2.MyRepairStatus__c = 'productDeliveredToClient';
            dcs2.ICONiCS_Status_Detail__c = 'Delivered to Client'; 
            update dcs2;
            dcs2.TransactionId__c='test';
            dcs2.MYLV_Care_Status__c = 'cancelled'; 
            update dcs2;

           
            dcs2.ICONiCS_Status_Detail__c = 'Preliminary Quote Validated';                       
            update dcs2;   
            
        } catch (Exception e) {
              system.debug('TestCareService_TriggerHandler_TEST Exception'+e.getMessage());   
        }  
       
        test.stopTest();
       
        
    }
     @isTest static void myTestMethodSCS1() {
       	
        Id StoreCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('StoreCareService').getRecordTypeId();		
       
        Store__c store2= new Store__c(RetailStoreId__c = 'A06');
		insert store2;
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        ProductCatalogue__c product = new ProductCatalogue__c(SKU__c ='M55555');
        product.Workshop__c = '1798'; //became required
        insert product;
        CareService__c scs1 = new CareService__c(recordTypeId = StoreCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'A06', Store__c = store2.Id, IsToDo__c=true,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today().addMonths(-4),Last_MyRepair_Status_Changed_Date__c = system.today().addMonths(-1),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
        CareService__c scs2 = new CareService__c(recordTypeId = StoreCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'A06', Store__c = store2.Id, IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today().addMonths(-4),Last_MyRepair_Status_Changed_Date__c = system.today().addMonths(-1),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
        CareService__c scs3 = new CareService__c(recordTypeId = StoreCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'A06', Store__c = store2.Id, IsToDo__c=true,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today().addMonths(-4),Last_MyRepair_Status_Changed_Date__c = System.today().addMonths(-3),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
        insert scs1;
        insert scs2;
       
        test.startTest();       
        try {          
                  
            scs1.IsToDo__c = true;
            scs1.ICON_Comments__c ='test'; 
            scs1.Followup_Status__c = 'Pending';                     
            scs1.MYLV_Care_Status__c = 'ready_for_pick_up';           
            update scs1;
            scs3.MYLV_Care_Status__c = 'ready_for_pick_up';           
            update scs1;
            scs2.MYLV_Care_Status__c = 'home_delivery';
            update scs2;
  
        } catch (Exception e) {
              system.debug('TestCareService_TriggerHandler_TEST Exception'+e.getMessage());   
        }  
       
        test.stopTest();
       
        
    }
}