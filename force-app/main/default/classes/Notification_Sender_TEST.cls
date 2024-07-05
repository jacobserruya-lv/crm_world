@isTest
private class Notification_Sender_TEST {
    
    @isTest static void testClass() {

        Integer i = 5;
        Long l = 5;
        Decimal d = 5;
        Notification_Sender.getType(i);
        Notification_Sender.getType(l);
        Notification_Sender.getType(d);

            Identity_TestFactory.createSettings();
            Account acc = Identity_TestFactory.createAccount('gege', 'test1', 'gege@test1.com', '+972549876543', '', true);
            CareService__c care = new CareService__c(
                    ExternalId__c = 'abcdefgh12345',
                    Hot_Status__c = 'New',
                    Red_Code__c = true,
                    SKU__c = 'M51904',
                    TotalAmount__c = null,
                    CA_Code__c = null,
                    StoreRetailCode__c = 'A06',
                    Delivery_Date__c = null,
                    MyRepair_CreatedDate__c = Date.valueOf('2019-06-05'),
                    MyRepairStatus__c = 'productDeliveredToClient',
                    Client__c = acc.id,
                    Shipping_Address_Line_1__c = 'dummy address',
                    Shipping_City__c = 'dummy city',
                    Shipping_Country__c = 'US',
                    Shipping_State_Province__c = 'dummy province',
                    Shipping_Zip_Postal_Code__c = '75001',
                    FollowupBy_Email__c = true);

        Test.startTest();
            insert care;
         Test.stopTest();

         //trigger handler calls to Notification_Sender send method: Notification_Sender.send('CARE SERVICE', 1, null, client_ids, params);        
        list<Notification__c> notifs = [SELECT Id, Application__c, Message_Id__c, Client__c, External_Id__c, LastModifiedDate, Status__c FROM Notification__c];
        list<Notification_Parameter__c> nparams = [SELECT Id, Notification__c, Field__c, LongValue__c FROM Notification_Parameter__c];
        System.debug(notifs);
        System.debug(nparams);
    }
 }


 /************** be carefull for class coverage: must be: 
 MyRepair_CreatedDate__c > System.now().addMonths(-1)
 --> change the date!!!
 ********************************************************/