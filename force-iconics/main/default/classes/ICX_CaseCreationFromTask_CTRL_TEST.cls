@isTest
public class ICX_CaseCreationFromTask_CTRL_TEST {

    @isTest
    public static void createCaseTest() {
        // Init data
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        ProductCatalogue__c prod = new ProductCatalogue__c();
        prod.SKU__c = 'SKUTEST1234';
        prod.Name = 'PROD TEST';
        insert prod;

        Task call = ICX_TestFactory.creatCallTaskOnAccount(acc.Id);
        call.Product_Sku__c = prod.Id;
        call.Product_SKU_Unknown__c = 'Unknown';
        call.Transaction_Id__c = '12345';
        call.Resolution__c = 'Immediate Response';
        insert call;
        
        // Test
        Id resultCaseId = ICX_CaseCreationFromTask_CTRL.createCase(call.Id);
        
        // Check
        List<Case> caseList = [SELECT Id, Product_Sku__c, Product_SKU_Unknown__c, Resolution__c, Transaction_Id__c FROM Case];
        System.assertEquals(1, caseList.size());

        Case caseResult = caseList.get(0);
        System.assertEquals(caseResult.Id, resultCaseId);
        System.assertEquals(call.Product_Sku__c, caseResult.Product_Sku__c);
        System.assertEquals(call.Product_SKU_Unknown__c, caseResult.Product_SKU_Unknown__c);
        System.assertEquals(call.Transaction_Id__c, caseResult.Transaction_Id__c);
        System.assert(caseResult.Resolution__c == null);
    }
}