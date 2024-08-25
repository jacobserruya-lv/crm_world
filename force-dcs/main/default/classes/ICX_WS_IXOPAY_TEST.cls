/*	 * @author Keman WU
* @date creation 28/07/2023
* @description test class for ICX_WS_IXOPAY
*/
@isTest
public with sharing class ICX_WS_IXOPAY_TEST {
    
	static testMethod void testDebit() {
        set<ID> careIds = new set<ID>();
         Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 
             
         Account acc = ICX_TestFactory.createAccount();
         insert acc;       
         CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId,TotalAmount_Updated__c=55,MYLV_Care_Status__c = 'preliminary_assessment_acc',Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10001',TransactionId__c ='o12345678', Client__c =acc.Id, StoreRetailCode__c = 'F92', IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
         insert dcs1;
         careIds.add(dcs1.id);  

        test.startTest();            
        Test.setMock(HttpCalloutMock.class, new ICX_WS_IXOPAY_MOCK());       
        ICX_WS_IXOPAY.createLinkPBL(careIds);       
       test.stopTest();
		
		
	}
    static testMethod void testRefund() {
        set<ID> careIds = new set<ID>();
         Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 
             
         Account acc = ICX_TestFactory.createAccount();
         insert acc;       
         CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId,MYLV_Care_Status__c = 'preliminary_assessment_acc',Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10001',TransactionId__c ='o12345678', Client__c =acc.Id, StoreRetailCode__c = 'F92', IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
         insert dcs1;
         careIds.add(dcs1.id);  
         Ixopay_Transaction__c myTransaction = new Ixopay_Transaction__c(Care_Service__c = dcs1.id, Status__c = 'Success',Transaction_Type__c ='DEBIT');
        insert myTransaction;
         test.startTest();            
        Test.setMock(HttpCalloutMock.class, new ICX_WS_IXOPAY_MOCK());       
        ICX_WS_IXOPAY.createRefund(dcs1.id);
       test.stopTest();
		
		
	}
    
     static testMethod void testPBL() {
        set<ID> careIds = new set<ID>();
         Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 
             
         Account acc = ICX_TestFactory.createAccount();
         insert acc;       
         CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId,TotalAmount_Updated__c=55,MYLV_Care_Status__c = 'preliminary_assessment_acc',Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10001',TransactionId__c ='o12345678', Client__c =acc.Id, StoreRetailCode__c = 'F92', IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
         insert dcs1;
         careIds.add(dcs1.id);  
        
         test.startTest();            
        Test.setMock(HttpCalloutMock.class, new ICX_WS_IXOPAY_MOCK());       
        ICX_WS_IXOPAY.createPaymentReviewPBL(dcs1.id);
       test.stopTest();
		
		
	}
}