/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-06-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-01-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class BL_ICON_Transactions_Test {
 

 @isTest
    static void testMethodGet(){
        Account acc =  new Account(LastName = 'test'); 
        insert acc;
      
        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_Transactions blClient = new BL_ICON_Transactions();
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = '1234';
        insert u;
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            blClient.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blClient.pathParameters = new Map<String, String>{'clientId' =>acc.Id};
            blClient.queryParams = new Map<String, String>();
           PPR_PurchProduct__c p = new PPR_PurchProduct__c(TicketNumber__c = '210728876',WWEmployeeNumber__c = blClient.me.basicInfos.EmployeeNumber,Client__c = acc.id,Amount__c=995,Name='PF.SARAH RETIRO MNG CERI.');
           insert p;
           List<String> ticketList = new List<String>{'1234','5678'};
            Test.startTest();        
                blClient.executeGET();
                BL_ICON_Transactions_Helper.getAllClientDetails(acc.Id,system.today(),blClient.me);
                BL_ICON_Transactions_Helper.checkEventTransaction(acc.Id,ticketList);

            Test.stopTest();
    }



    @isTest
    static void testMethodGetTransaction(){

        createTestData();
        Account acc = [SELECT id FROM Account LIMIT 1];
        Event env = [SELECT id FROM Event LIMIT 1];

      
        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_Transactions blTransactions = new BL_ICON_Transactions();
        
        User u = [SELECT id,DefaultStore__c FROM user WHERE WWEmployeeNumber__c = 'WW198765467'];

        System.runAs(u){

            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            blTransactions.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            
            Test.startTest(); 

            blTransactions.pathParameters = new Map<String, String>{'clientId' =>acc.Id} ;
            blTransactions.queryParams = new Map<String, String>{'eventId'=> env.id};     
            blTransactions.executeGET();
            Test.stopTest();
        }
    }


    static void createTestData() {
        
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = 'A06';
        u.WWEmployeeNumber__c = 'WW198765467';
        u.Country = 'Los Angeles';

        insert u;

        Map<String, RecordType> recordTypeByDevMap = SO_UTIL.retRecordTypeByDevMap(new Set<String>{'ACC_PersonAccount'});
        RecordType personAccRT = IC_Test_Common.GetPersonAccountRT();

        Account account = new Account(LastName = 'LEE', OwnerId = u.id,AttachedStore__pc = u.DefaultStore__c, PrimaryCountry__pc = u.Country, FirstName = 'JOY');
        account.recordType = personAccRT;
        insert account;

        PPR_PurchProduct__c pp = new PPR_PurchProduct__c();
        pp.DreamIdSA__c = '123';
        pp.Client__c = account.Id;
        pp.TicketNumber__c = '789';
        pp.Amount__c = 4000;
        pp.ConvertedAmountEUR__c = 4000;
        pp.ConvertedAmountYUAN__c = 4000;
        pp.PurchasedDate__c = Date.today();
        pp.OrderATGId__c = 'test';
        pp.TransactionRMSId__c = 'transacRMSId';
        pp.TransactionTotalAmount__c = 400.00;
        pp.WWEmployeeNumber__c = 'WW198765467';
        pp.PurchaseDateTime__c = Datetime.now();
        insert pp;


        Event evt = new Event();
        evt.Description='Un event de test';
        evt.ActivityDate = Date.today().addDays(-3);
        evt.StartDateTime = Date.today().addDays(-3);
        evt.EndDateTime=Date.today().addDays(-2);
        evt.Subject = 'Sujet du test';
        //evt.Occasion__c = 'Travel';
        evt.Location = 'Paris';
        evt.IsAllDayEvent = false;
        evt.ShowAs = 'Free';
        evt.WhatId=account .Id;
        evt.OwnerId = u.Id;
        insert evt;
        Datetime yesterday = Datetime.now().addDays(-3);

        Test.setCreatedDate(evt.Id, yesterday);



    }
}