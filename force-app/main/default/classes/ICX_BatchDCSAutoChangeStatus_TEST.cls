/**
* @author Keman WU
* @date Creation 09/12/2021
* @Test class
* @description test class for batch auto cancellation for distant care service
*/
@isTest 
public with sharing class ICX_BatchDCSAutoChangeStatus_TEST {
    @isTest static void testCancel() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();      
		
        Store__c store= new Store__c(RetailStoreId__c = 'UE4');
		insert store;
      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store.Id,TransactionId__c='o123456789');
        CareService__c dcs2 = new CareService__c(recordTypeId = DistantCareRTId,Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10001',Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store.Id); 
       
        insert dcs1;
        insert dcs2;
        Test.startTest();
        dcs1.ICONiCS_Status_Detail__c = 'Preliminary Quote Pending Validation';
        dcs1.Quotation_sent_date__c  = system.today() - 30;
        update dcs1;
        dcs2.ICONiCS_Status_Detail__c = 'Preliminary Quote Validated';
        dcs2.Shipping_Label_creation_date__c  = system.today() - 110;
        update dcs2;
        ICX_BatchDCSAutoChangeStatus batch = new ICX_BatchDCSAutoChangeStatus();
        Database.executeBatch(batch,100);
        Test.stopTest();
        CareService__c csToCancel = [select Current_Status_Age__c,ICONiCS_Status_Detail__c from CareService__c where id=: dcs1.Id];
        system.debug('Current_Status_Age__c csToCancel ' +csToCancel.Current_Status_Age__c);
        system.assertEquals('Cancelled', csToCancel.ICONiCS_Status_Detail__c);
        CareService__c cs = [select Current_Status_Age__c,ICONiCS_Status_Detail__c from CareService__c where id=: dcs2.Id];
        system.debug('Current_Status_Age__c cs ' +cs.Current_Status_Age__c);
        system.assertEquals( 'Cancelled', cs.ICONiCS_Status_Detail__c);
    }
    @isTest static void testConfirmAddress() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();      
		
        Store__c store= new Store__c(RetailStoreId__c = 'UE4');
		insert store;
      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store.Id,TransactionId__c='o123456789');
        
        insert dcs1;
       
        Test.startTest();
        dcs1.ICONiCS_Status_Detail__c = 'Confirm Address';
        dcs1.Confirm_Address_Send_Date__c  = system.today() - 3;
        update dcs1;
       
        ICX_BatchDCSAutoChangeStatus batch = new ICX_BatchDCSAutoChangeStatus();
        Database.executeBatch(batch,100);
        Test.stopTest();
        CareService__c csToChange = [select ICONiCS_Status_Detail__c from CareService__c where id=: dcs1.Id];
         system.assertEquals('Payment Received', csToChange.ICONiCS_Status_Detail__c);
        
    }
    @isTest static void testWaitingPayment() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();      
		
        Store__c store= new Store__c(RetailStoreId__c = 'UE4');
		insert store;
      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store.Id,TransactionId__c='o123456789',Shipping_Address_Line_1__c='test',Shipping_City__c='New York',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10002');
        
        insert dcs1;
       
        Test.startTest();
        dcs1.ICONiCS_Status_Detail__c = 'Waiting for Payment';
        dcs1.Last_ICONiCS_Status_Changed_Date__c  = system.today() - 91;
        update dcs1;
       
        ICX_BatchDCSAutoChangeStatus batch = new ICX_BatchDCSAutoChangeStatus();
        Database.executeBatch(batch,100);
        Test.stopTest();
        CareService__c csToChange = [select ICONiCS_Status_Detail__c from CareService__c where id=: dcs1.Id];
         system.assertEquals('Payment Review', csToChange.ICONiCS_Status_Detail__c);
        
    }
    @isTest static void testPaymentInitiated() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();      
		
        Store__c store= new Store__c(RetailStoreId__c = 'UE4');
		insert store;
      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store.Id,TransactionId__c='o123456789',Shipping_Address_Line_1__c='test',Shipping_City__c='New York',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10002');
        
        insert dcs1;
       
        Test.startTest();
        dcs1.ICONiCS_Status_Detail__c = 'Payment Initiated';
        dcs1.PBL_Created_Date__c  = system.today() - 91;
        update dcs1;
       
        ICX_BatchDCSAutoChangeStatus batch = new ICX_BatchDCSAutoChangeStatus();
        Database.executeBatch(batch,100);
        Test.stopTest();
        CareService__c csToChange = [select ICONiCS_Status_Detail__c from CareService__c where id=: dcs1.Id];
         system.assertEquals('Payment Review', csToChange.ICONiCS_Status_Detail__c);
        
    }
}