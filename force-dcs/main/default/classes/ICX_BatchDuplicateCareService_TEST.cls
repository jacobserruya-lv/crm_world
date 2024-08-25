/*	 * @author Keman WU
* @date creation 14/12/2021
* @description test class for ICX_BatchDuplicateCareService
*/
@isTest
public with sharing class ICX_BatchDuplicateCareService_TEST {

    @isTest static void testCancelDuplicateCareservice() {

        set<ID> careIds = new set<ID>();
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 
        Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
		insert store1;      
        Account acc = ICX_TestFactory.createAccount();
        insert acc; 
        
        List<CareService__c> csList = new List<CareService__c>();
        CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id, Description__c='TEST1',Origin__c ='LV App-Form');
        csList.add(dcs1);
      
        CareService__c dcs2 = new CareService__c(recordTypeId = DistantCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id, Description__c='TEST1',Origin__c ='LV App-Form');
        csList.add(dcs2);

        CareService__c dcs3 = new CareService__c(recordTypeId = DistantCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id, Description__c='TEST2',Origin__c ='LV App-Form');
        csList.add(dcs3);

        insert csList;
                           test.startTest();

         Database.executeBatch(new ICX_BatchDuplicateCareService());
        test.stopTest();

        List<CareService__c> lstTOcancel = [select id,Description__c,Client__c,CreatedDate,StoreRetailCode__c from CareService__c where RecordType.DeveloperName = 'DistantCareService' AND ICONiCS_Status_Detail__c ='Cancelled' AND Origin__c ='LV App-Form' ];
        system.assertEquals(1, lstTOcancel.size());
        List<CareService__c> lstCS = [select id,Description__c,Client__c,CreatedDate,StoreRetailCode__c from CareService__c where RecordType.DeveloperName = 'DistantCareService' AND ICONiCS_Status_Detail__c ='New Request' AND Origin__c ='LV App-Form' ];
        system.assertEquals(2, lstCS.size());
    }
}