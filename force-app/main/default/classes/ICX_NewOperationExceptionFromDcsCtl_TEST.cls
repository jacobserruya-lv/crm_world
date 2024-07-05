/*	 * @author Keman WU
* @date creation 12/09/2022
* @description test class for ICX_NewOperationExceptionFromDcsCtl
*/
@isTest
public class ICX_NewOperationExceptionFromDcsCtl_TEST {
    @isTest static void myTest() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();     	
        Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
		insert store1;      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        ProductCatalogue__c product = new ProductCatalogue__c(SKU__c ='M55555');
        insert product;
        CareService__c dcs = new CareService__c(recordTypeId = DistantCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id, IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
        insert dcs;       
        
       
        test.startTest();
        ICX_NewOperationExceptionFromDcsCtl.getCaseRecordTypeID();
        ICX_NewOperationExceptionFromDcsCtl.getCareRecord(dcs.Id);
        test.stopTest();
    }
}