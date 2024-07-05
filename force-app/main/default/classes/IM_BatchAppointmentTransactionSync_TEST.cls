@isTest
private class IM_BatchAppointmentTransactionSync_TEST {
    
    @isTest static void test_method_one() {
        ID batchprocessid;
        Account a = new Account();
        a.LastName = 'Europe' + String.valueOf(System.now());
        a.FirstName='Louis';
        a.Salutation = 'Ms';
        a.Segmentation__pc='VIC';
        a.PrimaryAddressLine1__pc='Adresse ligne 1';
        a.PrimaryAddressLine2__pc='Adresse ligne 2';
        a.PrimaryAddressLine3__pc ='Adresse ligne 3';
        a.PrimaryCity__pc='Paris';
        a.PersonEmail='sylvie@lv.com';
        a.PrimaryZipCode__pc='75000';
        a.PrimaryCountry__pc='France';
        a.PassportNumber__pc='ABC12345';
        insert a;

                System.debug('Account: ' + a);
        PPR_PurchProduct__c pp = new PPR_PurchProduct__c();
        pp.DreamIdSA__c = '123';
        pp.Client__c = a.Id;
        pp.TicketNumber__c = '789';
        pp.Amount__c = 4000;
        pp.ConvertedAmountEUR__c = 4000;
        pp.ConvertedAmountUSD__c = 4000;
        pp.ConvertedAmountYEN__c = 4000;
        pp.ConvertedAmountYUAN__c = 4000;
        pp.PurchasedDate__c = Date.today().addDays(-6);
        pp.OrderATGId__c = 'test';
        pp.TransactionRMSId__c = 'transacRMSId';
        pp.TransactionTotalAmount__c = 400.00;
        //pp.WWEmployeeNumber__c = '456789';
        pp.WWEmployeeNumber__c = 'FRE213444';
        pp.CurrencyCode__c = 'EUO';
        pp.PurchaseDateTime__c = Datetime.newInstance(2021, 1, 1, 13, 30, 0);
        insert pp;
                System.debug('Purchase product: ' + pp);
        Event evt = new Event();
        evt.Description='Un event de test';
        evt.ActivityDate = Date.today().addDays(-3);
        evt.StartDateTime = Date.today().addDays(-3);
        evt.EndDateTime=Date.today().addDays(-3);
        evt.Subject='Sujet du test';
        //evt.Occasion__c='Travel';
        evt.Location='Paris';
        evt.IsAllDayEvent=false;
        evt.ShowAs='Free';
        evt.Source__c='Unexcepted';
        evt.Service__c='Test';
        evt.SaleAmount__c=1;
        evt.WhatId=a.Id;
        insert evt;
        System.debug('Event: ' + evt);

        //////////////////
        Account a2 = new Account();
        a2.LastName = 'Europe' + String.valueOf(System.now());
        a2.FirstName='Louis';
        a2.Salutation = 'Ms';
        a2.Segmentation__pc='VIC';
        a2.PrimaryAddressLine1__pc='Adresse ligne 1';
        a2.PrimaryAddressLine2__pc='Adresse ligne 2';
        a2.PrimaryAddressLine3__pc ='Adresse ligne 3';
        a2.PrimaryCity__pc='Paris';
        a2.PersonEmail='sylvie@lv.com';
        a2.PrimaryZipCode__pc='75000';
        a2.PrimaryCountry__pc='France';
        a2.PassportNumber__pc='ABC12345';
        insert a2;


        PPR_PurchProduct__c pp2 = new PPR_PurchProduct__c();
        pp2.DreamIdSA__c = '123';
        pp2.Client__c = a2.Id;
        pp2.TicketNumber__c = '1234567';
        pp2.Amount__c = 1330;
        pp2.ConvertedAmountEUR__c = 1330;
        pp2.ConvertedAmountUSD__c = 1330;
        pp2.ConvertedAmountYEN__c = 1330;
        pp2.ConvertedAmountYUAN__c = 1330;
        pp2.PurchasedDate__c = Date.today().addDays(-1);
        pp2.OrderATGId__c = 'test';
        pp2.TransactionRMSId__c = 'transacRMSId2';
        pp2.TransactionTotalAmount__c = 1330.0;
        //pp.WWEmployeeNumber__c = '456789';
        pp2.WWEmployeeNumber__c = 'FRE213444';
        pp2.CurrencyCode__c = 'EUO';
        pp2.PurchaseDateTime__c = Datetime.newInstance(2021, 1, 1, 13, 30, 0);
        insert pp2;

        Event evt2 = new Event();
        evt2.Description='Un event de test';
        evt2.ActivityDate = Date.today().addDays(-1);
        evt2.StartDateTime = Date.today().addDays(-1);
        evt2.EndDateTime=Date.today().addDays(0);
        evt2.Subject='Sujet du test';
        //evt2.Occasion__c='Travel';
        evt2.Location='Paris';
        evt2.IsAllDayEvent=false;
        evt2.ShowAs='Free';
        evt2.Source__c='Unexcepted';
        evt2.Service__c='Test';
        evt2.SaleAmount__c=1;
        evt2.WhatId=a2.Id;
        insert evt2;

        //////////////////
        Account a3 = new Account();
        a3.LastName = 'Europe' + String.valueOf(System.now());
        a3.FirstName='Louis';
        a3.Salutation = 'Ms';
        a3.Segmentation__pc='VIC';
        a3.PrimaryAddressLine1__pc='Adresse ligne 1';
        a3.PrimaryAddressLine2__pc='Adresse ligne 2';
        a3.PrimaryAddressLine3__pc ='Adresse ligne 3';
        a3.PrimaryCity__pc='Paris';
        a3.PersonEmail='sylvie123@lv.com';
        a3.PrimaryZipCode__pc='75000';
        a3.PrimaryCountry__pc='France';
        a3.PassportNumber__pc='ABC12345';
        insert a3;


        PPR_PurchProduct__c pp3 = new PPR_PurchProduct__c();
        pp3.DreamIdSA__c = '123';
        pp3.Client__c = a3.Id;
        pp3.TicketNumber__c = '0987654321';
        pp3.Amount__c = 590;
        pp3.ConvertedAmountEUR__c = 590;
        pp3.ConvertedAmountUSD__c = 590;
        pp3.ConvertedAmountYEN__c = 590;
        pp3.ConvertedAmountYUAN__c = 590;
        pp3.PurchasedDate__c = Date.today();
        pp3.OrderATGId__c = 'test';
        pp3.TransactionRMSId__c = 'transacRMSId3';
        pp3.TransactionTotalAmount__c = 590.0;
        //pp.WWEmployeeNumber__c = '456789';
        pp3.WWEmployeeNumber__c = 'FRE213444';
        pp3.CurrencyCode__c = 'EUO';
        pp3.PurchaseDateTime__c = Datetime.now();
        insert pp3;

        Event evt3 = new Event();
        evt3.Description='Un event de test';
        evt3.ActivityDate = Date.today().addDays(-3);
        evt3.StartDateTime = Date.today().addDays(-3);
        evt3.EndDateTime=Date.today().addDays(-2);
        evt3.Subject='Sujet du test';
        //evt3.Occasion__c='Travel';
        evt3.Location='Paris';
        evt3.IsAllDayEvent=false;
        evt3.ShowAs='Free';
        evt3.Source__c='Unexcepted';
        evt3.Service__c='Test';
        evt3.SaleAmount__c=1;
        evt3.WhatId=a3.Id;
        insert evt3;

        IM_BatchAppointmentTransactionSync bat = new IM_BatchAppointmentTransactionSync();  
        batchprocessid=Database.executeBatch(bat);

    }
    
}