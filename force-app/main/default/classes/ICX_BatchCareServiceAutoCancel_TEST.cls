/**
* @author Keman WU
* @date Creation 09/12/2021
* @Test class
* @description test class for batch auto cancellation for distant care service
*/
@isTest 
public with sharing class ICX_BatchCareServiceAutoCancel_TEST {
    @isTest static void myTestMethod() {
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
        dcs1.Last_ICONiCS_Status_Changed_Date__c = system.today() - 30;
        update dcs1;
        dcs2.ICONiCS_Status_Detail__c = 'Preliminary Quote Validated';
        dcs2.Last_ICONiCS_Status_Changed_Date__c = system.today() - 30;
        update dcs2;
        ICX_BatchCareServiceAutoCancel batch = new ICX_BatchCareServiceAutoCancel();
        Database.executeBatch(batch,100);
        Test.stopTest();
        CareService__c csToCancel = [select Current_Status_Age__c,ICONiCS_Status_Detail__c from CareService__c where id=: dcs1.Id];
        system.debug('Current_Status_Age__c csToCancel ' +csToCancel.Current_Status_Age__c);
        system.assertEquals('Cancelled', csToCancel.ICONiCS_Status_Detail__c);
        CareService__c cs = [select Current_Status_Age__c,ICONiCS_Status_Detail__c from CareService__c where id=: dcs2.Id];
        system.debug('Current_Status_Age__c cs ' +cs.Current_Status_Age__c);
        system.assertEquals( 'Preliminary Quote Validated', cs.ICONiCS_Status_Detail__c);
    }
}