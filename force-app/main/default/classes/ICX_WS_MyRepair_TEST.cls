/*	 * @author Keman WU
* @date creation 04/11/2021
* @description test class for ICX_WS_MyRepair
*/
@isTest
public with sharing class ICX_WS_MyRepair_TEST {

       @isTest static void testCreateRepairOrder() {
     
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 
        Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
		insert store1;      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;       
        CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId,ICONiCS_Status_Detail__c='Pending Customer information', Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id, IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
        insert dcs1;

        test.startTest();
         Test.setMock(HttpCalloutMock.class, new ICX_WS_MyRepair_MOCK());       
         String res = ICX_WS_MyRepair.createRepairOrder(dcs1.id);
        test.stopTest();
    }

    @isTest static void testUpdateRepairOrderStatus() {

        set<ID> careIds = new set<ID>();
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 
        Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
		insert store1;      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;       
        CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId,MyRepairStatus__c='cancelled', Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id, IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
        insert dcs1;
        careIds.add(dcs1.id);

        test.startTest();
         Test.setMock(HttpCalloutMock.class, new ICX_WS_MyRepair_MOCK());       
         ICX_WS_MyRepair.updateRepairOrderStatus(careIds);
        test.stopTest();
    }
}