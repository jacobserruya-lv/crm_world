/*	 * @author Keman WU
* @date creation 04/11/2021
* @description test class for ICX_ReceiptCareServiceCtl
*/
@isTest
public with sharing class ICX_ReceiptCareServiceCtl_TEST {
    @isTest static void myTest() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();   	

        Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
		insert store1;      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        ProductCatalogue__c product = new ProductCatalogue__c(SKU__c ='M55555');
        insert product;
        CareService__c dcs = new CareService__c(recordTypeId = DistantCareRTId, transactionId__c='o658757969',Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id, IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
       insert dcs;
       CareServiceLineItem__c csl = new CareServiceLineItem__c(Quantity__c=1, InstructionCode__c='1234', Instruction_Name_ICONiCS__c='TEST',CareService__c=dcs.id);
       insert csl;
        test.startTest();
        PageReference pageRef = Page.ICX_ReceiptCareService;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(dcs);
        ICX_ReceiptCareServiceCtl controller = new ICX_ReceiptCareServiceCtl(sc);
        controller.getQuotations();
        controller.getUppercaseRepairNumber();
        test.stopTest();

    }
}