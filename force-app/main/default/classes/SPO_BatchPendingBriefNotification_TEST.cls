/**
* @description: Test class for the batchable SPO_BatchPendingBriefNotification
* @modification history:
*
*/

@isTest
public class SPO_BatchPendingBriefNotification_TEST {

    @isTest static void test_executePendingBriefNotification()
    {
        Profile p = [Select id from profile where name = 'ICON_SA'];
        // create a CA
        User ca = LV_TestFactory.createUser('CA', 'ca.user@testingbatch.test', 'cuser125', p.Id);
        insert ca;
        
        // create a product referential
        ProductReferential__c pr = LV_TestFactory.createProductReferential('MY PRODUCT', 'N00000');
        insert pr;
        
        // create a store
        Store__c st = LV_TestFactory.createStore('LV My Test Store', 'Store', 'A00', 'FRANCE', 'EUR', 'Open');
        insert st;
        
        // create a client
        Account client = LV_TestFactory.createAccount();
        insert client;
        
        // create an order
        Opportunity order = LV_TestFactory.createOrder('Tesing Order Notification', 
                                                       'Brief in progress', pr.id, st.id, client.id, 
                                                       'Creation (Hardsided & Soft)', 'Leather goods', 'SPO');
        insert order;
        order.OwnerId = ca.id;
        update order;
        Test.setCreatedDate(order.id, Datetime.now().adddays(-21));
        
        // run test
        Test.startTest();
        Database.executeBatch(new SPO_BatchPendingBriefNotification());
        Test.stopTest();
        
        // check test results
        List<Task> t = [Select id from task where whatid =: order.id and ownerid =: ca.id and subject =: System.Label.SO_PendingBriefSubject];
        System.assertEquals(1, t.size());
    }
}