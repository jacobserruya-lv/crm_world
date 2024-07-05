@isTest
public with sharing class MIY_WS_FinalizeOrderLine_TEST {//created code coverage MIY-1745
    
    @TestSetup
    static void init() {
        Store__c st = LV_TestFactory.createStore('LV TEST STORE MIY', 'Store', 'A00', 'FRANCE', 'EUR', 'Open');
		st.MANAGEMENT_ZONE_LEVEL__c = '15';
		insert st;

		Account client = LV_TestFactory.createAccount();
        insert client;

        ProductCatalogue__c pc = LV_TestFactory.createProductCatalog('MY NEVERFULL', 'P0001', 3, 15, 5, 'Leather Goods');
		pc.Workshop__c = '1798';
        insert pc;
        
        Opportunity mypOrder = LV_TestFactory.createOrder('MY Neverfull bag', 'Creation in progress', null, st.id, client.id, null, null, 'PERSO');
		mypOrder.SPO_DepositSentStatusDate__c = System.today();
        insert mypOrder;
    }

    @isTest
    static void test_doPost() {
        Opportunity mypOrder = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];
		ProductCatalogue__c pc = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c = 'P0001' LIMIT 1];
        SPO_FirmOrder__c fo = LV_TestFactory.createFirmOrder(mypOrder.id, 2, pc.id);

		Test.startTest();
		insert fo;
        Test.stopTest();
        
        fo = [SELECT id, Name, SPO_FirmOrderStatus__c FROM SPO_FirmOrder__c WHERE id =: fo.id];
        MIY_WS_FinalizeOrderLine.doPost(fo.Name);


        fo.SPO_FirmOrderStatus__c = 'Received in store';
        update fo;
        String res = MIY_WS_FinalizeOrderLine.doPost(fo.Name);
    }
}