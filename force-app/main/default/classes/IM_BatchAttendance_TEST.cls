@isTest
private class IM_BatchAttendance_TEST {
    
    @isTest static void test_method_one() {
        ID batchprocessid;
        User user = IC_TestFactory.createUser(String.valueOf(System.today())+'@lvtest.com', IC_UTILS.getDreamProfile());
        user.BypassVR__c = true;
        insert user;

        Account account = IC_TestFactory.createAccount();
        account.ownerId = user.Id;
        insert account;

        System.runAs(user) {
        Test.startTest();
        Event event = IC_TestFactory.createEvent();
        insert event;
        event.StartDateTime = Date.today().addDays(-3);
        event.EndDateTime = Date.today().addDays(-3);
        event.Sale__c = false;
        event.No_Transaction__c = false;
        event.ClientNoShow__c = false;
        update event;
        System.debug('QQQQQQQQQQQQ event: ' + event);

        Event event2 = IC_TestFactory.createEvent();
        insert event2;
        event2.StartDateTime = Date.today().addDays(-3);
        event2.EndDateTime = Date.today().addDays(-3);
        event2.Sale__c = true;
        event2.No_Transaction__c = false;
        event2.ClientNoShow__c = false;
        update event2;
        System.debug('QQQQQQQQQQQQ event: ' + event2);

        Event event3 = IC_TestFactory.createEvent();
        insert event3;
        event3.StartDateTime = Date.today().addDays(-3);
        event3.EndDateTime = Date.today().addDays(-3);
        event3.Sale__c = false;
        event3.No_Transaction__c = true;
        event3.ClientNoShow__c = false;
        update event3;
        System.debug('QQQQQQQQQQQQ event: ' + event3);

        Event event4 = IC_TestFactory.createEvent();
        insert event4;
        event4.StartDateTime = Date.today().addDays(-3);
        event4.EndDateTime = Date.today().addDays(-3);
        event4.Sale__c = false;
        event4.No_Transaction__c = true;
        event4.ClientNoShow__c = true;
        update event4;
        System.debug('QQQQQQQQQQQQ event: ' + event4);

        IM_BatchAttendance batch = new IM_BatchAttendance();
        batchprocessid=Database.executeBatch(batch);
        Test.stopTest();
        }
    }
}