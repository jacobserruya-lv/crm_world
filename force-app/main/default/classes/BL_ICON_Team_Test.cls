@isTest
public with sharing class BL_ICON_Team_Test { 

    @isTest static void test_method_one() {
        BL_AppSettings.setAppSettings('Clienteling');
        BL_ICON_Team blTeam = new BL_ICON_Team();
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = '1234';
        insert u;
        system.runAs(u){
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            blTeam.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
        Test.startTest(); 
            blTeam.queryParams = new Map<String, String>{'myTeam' => null};
            blTeam.executeGET();
            blTeam.queryParams = new Map<String, String>{'myTeam' => 'true'};
            blTeam.executeGET();
        Test.stopTest();
        }
    }
}