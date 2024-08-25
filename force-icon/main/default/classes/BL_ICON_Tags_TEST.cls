@istest
public with sharing class BL_ICON_Tags_TEST {
    @TestSetup
    static void createTestData() {
        

        Account acc =  IC_TestFactory.createAccount();
        insert acc;
        Case request = IC_TestFactory.createCase(acc);
        insert request ; 
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = 'A06';
        u.WWEmployeeNumber__c = 'WW198765467';
        insert u;


    }

    
	@isTest
    static void testGetTags(){
        
      
        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_Tags blTags = new BL_ICON_Tags();
        
        //BL_ICON_Tags blTags = new BL_ICON_Tags();

        BL_WS_Router.clientPlatform = 'WECHAT';

        Account acc = [SELECT id FROM Account  LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user WHERE WWEmployeeNumber__c = 'WW198765467'];
        system.runAs(u){
            
            Store__c store = new Store__c(Name = 'LV Paris', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            blTags.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blTags.queryParams = new Map<String, String>();
           
           
            Test.startTest();
                blTags.pathParameters = new Map<String, String>{'clientId' =>acc.Id};
                blTags.executeGET();
            Test.stopTest();
        }

    }
    
    @isTest
    static void testPostTags(){
      
        Tag__c tag = new Tag__c();
        insert tag;

        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_Tags blTags = new BL_ICON_Tags();
        
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];
        system.runAs(u){
            
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            blTags.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blTags.queryParams = new Map<String, String>();
           
           
            Test.startTest();
               String bodyString = '{"records":[{"externalId":"test-send","tagid":"fd466c84a814f9dc1d4b65d4c63f9e2d","tagid_db":"fd466c84a814f9dc1d4b65d4c63f9e2d","type_value":"client_basic","type_label_db":"人的特征","type_label_mp":"备注","dimension_value":"gender","dimension_label_mp":"性别","dimension_label_db":"性别","tag_value":"","tag_label_mp":"","tag_label_db":"女性","intention_label_db":"","relation_value":"client-self","relation_label_db":"本人","relation_label_mp":"本人","relation_color_mp":"black","future_key_dates":[]}]}';
               blTags.requestBody = (Map<String, Object>)JSON.deserializeUntyped(bodyString);
               blTags.executePOST();
            Test.stopTest();
        }
    }


    @isTest
    static void testDeleteTags(){

        // Tag__c tag = new Tag__c();
        // insert tag;
      
        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_Tags blTags = new BL_ICON_Tags();
        
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];
        system.runAs(u){
            
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            blTags.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blTags.queryParams = new Map<String, String>();
           
           
            Test.startTest();
               // blTags.pathParameters = new Map<String, String>{'tagsId' =>tag.Id};

               // blTags.executeDELETE();
            Test.stopTest();
        }
    }
}