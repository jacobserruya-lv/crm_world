@isTest
public with sharing class ICX_PPR_voicenotif_scheduleUpdate_TEST {
    static testMethod void test1(){
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Store__c store = ICX_TestFactory.createStore('store1','TESTCODE');
        insert store;
        system.debug(store);
        CareService__c cs = ICX_TestFactory.createCareService(acc.Id);
        cs.store__c = store.id;
        cs.Shipping_Address_Line_1__c='Rou de Rosier';
        cs.Shipping_City__c='Paris';
        cs.Shipping_Country__c='FR';
        cs.Shipping_State_Province__c='Paris';
        cs.Shipping_Zip_Postal_Code__c='12345';
        cs.ICONiCS_Status_Detail__c = 'Delivered to Client';
        insert cs;
        System.debug(cs);
        PPR_PurchProduct__c ppr = new PPR_PurchProduct__c(DCS_Voice_notif__c = false, TransactionType__c = '8', store__c = store.RetailStoreId__c, client__c = acc.Id, TicketNumber__c = '123456' );
        insert ppr;
        system.debug(ppr);
        ICX_PPR_voicenotif_scheduleUpdate myScheduler = new ICX_PPR_voicenotif_scheduleUpdate();
        Test.startTest();
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second());

        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        system.schedule('Test check',nextFireTime, myScheduler);
        Test.stopTest();
    }
}