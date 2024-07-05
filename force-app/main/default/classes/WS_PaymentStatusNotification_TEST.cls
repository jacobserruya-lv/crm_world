/*	 * @author Keman WU
* @date creation 28/07/2023
* @description test class for WS_PaymentStatusNotification
*/
@isTest 
public with sharing class WS_PaymentStatusNotification_TEST {
    
    static testMethod void succesTest() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 
             
         Account acc = ICX_TestFactory.createAccount();
         insert acc;       
         CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId,MYLV_Care_Status__c = 'preliminary_assessment_acc',Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10001',TransactionId__c ='o12345678', Client__c =acc.Id, StoreRetailCode__c = 'F92', IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
         insert dcs1;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
       
        req.requestURI = '/IxopayPaymentStatus';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        String requestString = '{'+
		'"result": "OK",'+
		'"uuid": "524fea6f5ed864b06741",'+
		'"merchantTransactionId": "20230413155356",'+
		'"purchaseId": "20230525-524fea6f5ed864b06741",'+
		'"transactionType": "PREAUTHORIZE",'+
		'"paymentMethod": "Creditcard",'+
		'"amount": 9.99,'+
		'"currency": "EUR",'+
		'"merchantMetaData": "o12345678",'+
		'"customer": {'+
		'"identification": "00003001",'+
		'"firstName": "Max",'+
		'"lastName": "Mustermann",'+
		'"billingPhone": "0679258098",'+
		'"billingAddress1": "3 rue Bailleul",'+
		'"billingCity": "Paris",'+
		'"billingPostcode": "75001",'+
		'"billingState": "Ile-de-france",'+
		'"billingCountry": "FR",'+
		'"shippingFirstName": "Max",'+
		'"shippingLastName": "Mustermann",'+
		'"shippingAddress1": "3 rue Bailleul",'+
		'"shippingCity": "Paris",'+
		'"shippingPostcode": "75001",'+
		'"shippingState": "Ile-de-france",'+
		'"shippingCountry": "EN",'+
		'"email": "Max.Mustermann.ext@louisvuitton.com",'+
		'"ipAddress": "165.225.20.239"'+
		'},'+
		'"returnData": {'+
		'"_TYPE": "cardData",'+
		'"type": "visa",'+
		'"cardHolder": "marouen bachoual",'+
		'"expiryMonth": "05",'+
		'"expiryYear": "2023",'+
		'"binDigits": "41111111",'+
		'"firstSixDigits": "411111",'+
		'"lastFourDigits": "1111",'+
		'"fingerprint": "FNjYSZpHtQLgKuqvvOJ7+u+cmvgRets0jEwL1SZrgXXvPTPiPYlqb9oSy+ps7OB9HwLZYFx3SK05Zl5saVHMsA",'+
		'"threeDSecure": "OFF",'+
		'"eci": "05",'+
		'"binBrand": "VISA",'+
		'"binBank": "JPMORGAN CHASE BANK N.A.",'+
		'"binType": "",'+
		'"binLevel": "",'+
		'"binCountry": "US"'+
		'}'+
		'}';
        req.requestBody =  blob.valueOf(requestString);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();       
        WS_PaymentStatusNotification.doPost();
        Test.stopTest();
    }
    
    static testMethod void ErrorTest1() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 
             
         Account acc = ICX_TestFactory.createAccount();
         insert acc;       
         CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId,MYLV_Care_Status__c = 'preliminary_assessment_acc',Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10001',TransactionId__c ='o12345678', Client__c =acc.Id, StoreRetailCode__c = 'F92', IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
         insert dcs1;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
       
        req.requestURI = '/IxopayPaymentStatus';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        String requestString = '{'+
		'"result": "ERROR",'+
		'"uuid": "524fea6f5ed864b06741",'+
		'"merchantTransactionId": "20230413155356",'+
		'"purchaseId": "20230525-524fea6f5ed864b06741",'+
		'"transactionType": "PREAUTHORIZE",'+
		'"paymentMethod": "Creditcard",'+
		'"amount": 9.99,'+
		'"currency": "EUR",'+
		'"merchantMetaData": "o12345678",'+
		'"customer": {'+
		'"identification": "00003001",'+
		'"firstName": "Max",'+
		'"lastName": "Mustermann",'+
		'"billingPhone": "0679258098",'+
		'"billingAddress1": "3 rue Bailleul",'+
		'"billingCity": "Paris",'+
		'"billingPostcode": "75001",'+
		'"billingState": "Ile-de-france",'+
		'"billingCountry": "FR",'+
		'"shippingFirstName": "Max",'+
		'"shippingLastName": "Mustermann",'+
		'"shippingAddress1": "3 rue Bailleul",'+
		'"shippingCity": "Paris",'+
		'"shippingPostcode": "75001",'+
		'"shippingState": "Ile-de-france",'+
		'"shippingCountry": "EN",'+
		'"email": "Max.Mustermann.ext@louisvuitton.com",'+
		'"ipAddress": "165.225.20.239"'+
		'},'+
		'"returnData": {'+
		'"_TYPE": "cardData",'+
		'"type": "visa",'+
		'"cardHolder": "marouen bachoual",'+
		'"expiryMonth": "05",'+
		'"expiryYear": "2023",'+
		'"binDigits": "41111111",'+
		'"firstSixDigits": "411111",'+
		'"lastFourDigits": "1111",'+
		'"fingerprint": "FNjYSZpHtQLgKuqvvOJ7+u+cmvgRets0jEwL1SZrgXXvPTPiPYlqb9oSy+ps7OB9HwLZYFx3SK05Zl5saVHMsA",'+
		'"threeDSecure": "OFF",'+
		'"eci": "05",'+
		'"binBrand": "VISA",'+
		'"binBank": "JPMORGAN CHASE BANK N.A.",'+
		'"binType": "",'+
		'"binLevel": "",'+
		'"binCountry": "US"'+
		'}'+
		'}';
        req.requestBody =  blob.valueOf(requestString);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();       
        WS_PaymentStatusNotification.doPost();
        Test.stopTest();
    }
    static testMethod void ErrorTest2() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 
             
         Account acc = ICX_TestFactory.createAccount();
         insert acc;       
         CareService__c dcs1 = new CareService__c(recordTypeId = DistantCareRTId,MYLV_Care_Status__c = 'preliminary_assessment_acc',Shipping_Address_Line_1__c='test',Shipping_City__c='test',Shipping_Country__c='US',Shipping_State_Province__c='NY',Shipping_Zip_Postal_Code__c='10001',TransactionId__c ='o12345678', Client__c =acc.Id, StoreRetailCode__c = 'F92', IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
         insert dcs1;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
       
        req.requestURI = '/IxopayPaymentStatus';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        String requestString = '{Hello}';
        req.requestBody =  blob.valueOf(requestString);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();       
        WS_PaymentStatusNotification.doPost();
        Test.stopTest();
    }
}