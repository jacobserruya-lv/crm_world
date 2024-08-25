@isTest
private class CareServiceLineItem_TriggerHandler_TEST {
    static testMethod void myTest() {
        Repair_Instruction_Tranlation__c instruction1 = new Repair_Instruction_Tranlation__c();
        instruction1.Instruction_Code__c = '00001';
        instruction1.LanguageLocaleKey__c = 'en_US';
        instruction1.Client_Translated_Instruction_Name__c = 'clientTest1';
        instruction1.Translated_Instruction_Name__c = 'technicalTest1';
        insert instruction1;
        Repair_Instruction_Tranlation__c instruction2 = new Repair_Instruction_Tranlation__c();
        instruction2.Instruction_Code__c = '00002';
        instruction2.LanguageLocaleKey__c = 'en_US';
        instruction2.Translated_Instruction_Name__c = 'technicalTest2';
        insert instruction2;
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        CareService__c cs = ICX_TestFactory.createCareService(acc.Id);
        cs.LanguageLocaleKey__c = 'en_US';
        cs.Package_Declared_Value__c =12;
        cs.CurrencyCode__c = 'DLS';
        cs.Parcel_Size__c = 'Small size';
        insert cs;
        CareServiceLineItem__c csItem = new CareServiceLineItem__c(careService__c = cs.Id,InstructionCode__c='00001' );
        CareServiceLineItem__c csItem2 = new CareServiceLineItem__c(careService__c = cs.Id,InstructionCode__c='00000' );
        Test.startTest();
        insert csItem;
        insert csItem2;
        csItem = [select id, Instruction_Name_ICONiCS__c from careServiceLineItem__c where id=: csItem.Id];
        system.assertEquals( instruction1.Client_Translated_Instruction_Name__c, csItem.Instruction_Name_ICONiCS__c);
        csItem.InstructionCode__c='00002';      
        update csItem;        
        csItem = [select id, Instruction_Name_ICONiCS__c from careServiceLineItem__c where id=: csItem.Id];
        system.assertEquals( instruction2.Translated_Instruction_Name__c, csItem.Instruction_Name_ICONiCS__c);
        Test.stopTest();
    }

    
}