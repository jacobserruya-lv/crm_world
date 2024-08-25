/*	 * @author Keman WU
* @date creation 14/11/2021
* @description test class for ICX_BatchCancelMyRepairOrder
*/
@isTest
public with sharing class ICX_BatchCancelMyRepairOrder_TEST {

    @isTest static void testUpdateRepairOrderStatus() {

        set<ID> careIds = new set<ID>();
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 
        Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
		insert store1;      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;       
        CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId,ICONiCS_Status_Detail__c='Initiated in MyRepairs as a Draft', Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id,Last_ICONiCS_Status_Changed_Date__c = system.today() - 30);
        insert dcs1;
        careIds.add(dcs1.id);

        test.startTest();
         Test.setMock(HttpCalloutMock.class, new ICX_WS_MyRepair_MOCK());       
         Database.executeBatch(new ICX_BatchCancelMyRepairOrder(careIds),1);
        test.stopTest();
    }
}