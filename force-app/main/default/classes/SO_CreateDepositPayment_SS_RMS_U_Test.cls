@IsTest
public class SO_CreateDepositPayment_SS_RMS_U_Test {
    @IsTest
    static void testCreateDepositOrPaymentIntoRMS1() {
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName= 'In progress', CloseDate = Date.today(),SPO_RMSClientId__c = 'RMSClientId',
                                          SPO_wwRMSClientId__c = 'wwRMSClientId', OrderNumber__c = 'OrderNumber', SPO_caCode__c = 'caCode',
                                          SPO_UnitRetailPriceQuotation__c = 100.0, SPO_DepositAmount__c = 50.0, SPO_SpecialOrderSKUCode__c = 'SKUCode',
                                          SPO_Free__c = false, SPO_DisplayOrder__c = false/*, CreatedDate = Date.today()*/);
        insert opp;
        
        Test.setMock(WebServiceMock.class, new SO_CreateDepositPayment_SS_MOCK('000'));
        
        
        Test.startTest();
        try{
            SO_Session.startSession(opp);
            SO_CreateDepositPayment_SS_RMS_Utils.SO_CreateUpdateRmsDepositPaymentResult result1 = SO_CreateDepositPayment_SS_RMS_Utils.CreateDepositOrPaymentIntoRMS(false, opp);
            System.assert(result1.calloutSuccessResult);
            System.assertNotEquals(null, result1.calloutdepositPaymentRmsId);
            
            SO_CreateDepositPayment_SS_RMS_Utils.SO_CreateUpdateRmsDepositPaymentResult result2 = SO_CreateDepositPayment_SS_RMS_Utils.CreateDepositOrPaymentIntoRMS(true, opp);
            System.assert(result2.calloutSuccessResult);
            System.assertNotEquals(null, result2.calloutdepositPaymentRmsId);
        }
        catch(Exception exp) {
            system.assert(exp instanceof SO_UTIL.RMSException); 
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testCreateDepositOrPaymentIntoRMS2() {
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName= 'In progress', CloseDate = Date.today(),SPO_RMSClientId__c = 'RMSClientId',
                                          SPO_wwRMSClientId__c = 'wwRMSClientId', OrderNumber__c = 'OrderNumber', SPO_caCode__c = 'caCode',
                                          SPO_UnitRetailPriceQuotation__c = 100.0, SPO_DepositAmount__c = 50.0, SPO_SpecialOrderSKUCode__c = 'SKUCode',
                                          SPO_Free__c = false, SPO_DisplayOrder__c = false/*, CreatedDate = Date.today()*/);
        insert opp;
        
        Test.setMock(WebServiceMock.class, new SO_CreateDepositPayment_SS_MOCK(''));
        
        
        Test.startTest();
        try{
            SO_Session.startSession(opp);
            SO_CreateDepositPayment_SS_RMS_Utils.SO_CreateUpdateRmsDepositPaymentResult result1 = SO_CreateDepositPayment_SS_RMS_Utils.CreateDepositOrPaymentIntoRMS(false, opp);
            System.assert(result1.calloutSuccessResult);
            System.assertNotEquals(null, result1.calloutdepositPaymentRmsId);
            
            SO_CreateDepositPayment_SS_RMS_Utils.SO_CreateUpdateRmsDepositPaymentResult result2 = SO_CreateDepositPayment_SS_RMS_Utils.CreateDepositOrPaymentIntoRMS(true, opp);
            System.assert(result2.calloutSuccessResult);
            System.assertNotEquals(null, result2.calloutdepositPaymentRmsId);
        }
        catch(Exception exp) {
            system.assert(exp instanceof SO_UTIL.RMSException); 
        }
        Test.stopTest();
    }
}