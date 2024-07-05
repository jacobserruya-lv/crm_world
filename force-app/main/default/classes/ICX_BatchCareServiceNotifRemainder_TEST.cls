@isTest
private class ICX_BatchCareServiceNotifRemainder_TEST {

    static testMethod void testBatch() {
        IDENTITY_TestFactory.createSettings();
        Id distantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByName().get('Distant Care Service').getRecordTypeId();

        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        //Store__c store = ICX_TestFactory.createStore('US eCommerce Distance Repairs', 'UE4');
        
        Country__c country =new Country__c(Name='USA',    tech_duplicate__c = 'USA',    Iso2Code__c = 'US', Iso3Code__c = 'USA');
        insert country;
        Language2__c lan = new Language2__c(Name='ENGLISH', Iso2Code__c = 'US', Iso3Code__c = 'USA');
        insert lan;
        CountryLanguage__c cl = new CountryLanguage__c(Default__c = true, Country__c = country.id, Language__c=lan.id, ATG_Locale__c = 'eng-nl');
        insert cl;
        List <CareService__c> csList = new List<careService__c>();
        CareService__c cs = ICX_TestFactory.createCareService(acc.Id);
        cs.recordTypeId = distantCareRTId;
        cs.StoreRetailCode__c = 'F92';
        cs.ICONiCS_Status_Detail__c = 'Preliminary Quote Pending Validation';
        cs.Quotation_sent_date__c = Date.today().addDays(-7);
        cs.Shipping_Address_Line_1__c = 'address1';
        cs.Shipping_City__c = 'Paris';
        cs.Shipping_Country__c = 'FR';
        cs.Shipping_State_Province__c = 'France';
        cs.Shipping_Zip_Postal_Code__c = '123456';
        csList.add(cs);
        cs = ICX_TestFactory.createCareService(acc.Id);
        cs.recordTypeId = distantCareRTId;
        cs.StoreRetailCode__c = 'F92';
        cs.ICONiCS_Status_Detail__c = 'Preliminary Quote Pending Validation';
        cs.Quotation_sent_date__c = Date.today().addDays(-21);       
        cs.Shipping_Address_Line_1__c = 'address1';
        cs.Shipping_City__c = 'Paris';
        cs.Shipping_Country__c = 'FR';
        cs.Shipping_State_Province__c = 'France';
        cs.Shipping_Zip_Postal_Code__c = '123456';
        csList.add(cs);
        cs = ICX_TestFactory.createCareService(acc.Id);
        cs.recordTypeId = distantCareRTId;
        cs.StoreRetailCode__c = 'F92';
        cs.ICONiCS_Status_Detail__c = 'Preliminary Quote Validated';
        cs.Shipping_Label_creation_date__c = Date.today().addDays(-21);        
        cs.Shipping_Address_Line_1__c = 'address1';
        cs.Shipping_City__c = 'Paris';
        cs.Shipping_Country__c = 'FR';
        cs.Shipping_State_Province__c = 'France';
        cs.Shipping_Zip_Postal_Code__c = '123456';
        csList.add(cs);
        cs = ICX_TestFactory.createCareService(acc.Id);
        cs.recordTypeId = distantCareRTId;
        cs.StoreRetailCode__c = 'F92';
        cs.ICONiCS_Status_Detail__c = 'Waiting for Payment';
        cs.Last_ICONiCS_Status_Changed_Date__c = Date.today().addDays(-3);        
        cs.Shipping_Address_Line_1__c = 'address1';
        cs.Shipping_City__c = 'Paris';
        cs.Shipping_Country__c = 'FR';
        cs.Shipping_State_Province__c = 'France';
        cs.Shipping_Zip_Postal_Code__c = '123456';
        csList.add(cs);
        cs = ICX_TestFactory.createCareService(acc.Id);
        cs.recordTypeId = distantCareRTId;
        cs.StoreRetailCode__c = 'F92';
        cs.ICONiCS_Status_Detail__c = 'Waiting for Payment';
        cs.Last_ICONiCS_Status_Changed_Date__c = Date.today().addDays(-18);        
        cs.Shipping_Address_Line_1__c = 'address1';
        cs.Shipping_City__c = 'Paris';
        cs.Shipping_Country__c = 'FR';
        cs.Shipping_State_Province__c = 'France';
        cs.Shipping_Zip_Postal_Code__c = '123456';
        csList.add(cs);
        cs = ICX_TestFactory.createCareService(acc.Id);
        cs.recordTypeId = distantCareRTId;
        cs.StoreRetailCode__c = 'F92';
        cs.ICONiCS_Status_Detail__c = 'Waiting for Payment';
        cs.Last_ICONiCS_Status_Changed_Date__c = Date.today().addDays(-90);        
        cs.Shipping_Address_Line_1__c = 'address1';
        cs.Shipping_City__c = 'Paris';
        cs.Shipping_Country__c = 'FR';
        cs.Shipping_State_Province__c = 'France';
        cs.Shipping_Zip_Postal_Code__c = '123456';
        csList.add(cs);

        insert csList;
        for(CareService__c c: [select id,ICONiCS_Status_Detail__c from CareService__c ]){
            system.debug('****CareService : '+c.Id +' '+c.ICONiCS_Status_Detail__c);
        }
        ICX_BatchCareServiceNotifRemainder bcsn = new ICX_BatchCareServiceNotifRemainder();
        Test.startTest();
        Database.executeBatch(bcsn, 1000);
        Test.stopTest();
        List<Notification__c> createdNof = [SELECT id,WhatId__c FROM Notification__c ];
        for(Notification__c n :createdNof ){
            system.debug('****Notif CareService Id : '+n.WhatId__c);
        }
        system.assertEquals(6, createdNof.size());
      
    }
}