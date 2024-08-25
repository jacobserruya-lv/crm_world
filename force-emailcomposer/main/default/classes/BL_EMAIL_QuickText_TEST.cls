@isTest
private class BL_EMAIL_QuickText_TEST {

    @TestSetup
    static void createTestData() {
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06');
        insert store;

        QuickText quick = new QuickText(Name='quick', Message='Message {!Account.LastName}', Channel='Email', Language__c='English');
        insert quick;

        Account acc = new Account(LastName = 'Europe', FirstName='Louis', PersonEmail='louis@lv.com' );
		insert acc;

        Case cse = new Case(Origin = 'Email', Status = 'New', Priority = 'Medium', AccountId = acc.Id, Description ='Un case de Test');
        insert cse;

        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = 'A06';
        u.WWEmployeeNumber__c = 'WW198765467';
        insert u;
    }

    @isTest
    static void searchQuickText(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_QuickText blQuickText = new BL_EMAIL_QuickText();
        Store__c store = [SELECT Id FROM Store__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blQuickText.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blQuickText.queryParams = new Map<String, String>{
                'searchText' => 'France',
                'application' => 'WARDROBING'
            };
            
            blQuickText.path = '/quick-texts';
            
            Test.startTest();
                blQuickText.requestBody = new Map<String,Object>{}; 
                blQuickText.pathParameters = new Map<String, String>{};
                blQuickText.executeGET();
            Test.stopTest();
        }
    }

    @isTest
    static void getQuickTextById(){     
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_QuickText blQuickText = new BL_EMAIL_QuickText();
        QuickText quickText = [SELECT Id FROM QuickText LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blQuickText.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blQuickText.queryParams = new Map<String, String>{
                'application' => 'WARDROBING'
            };
            
            blQuickText.path = '/quick-texts/{id}';
            
            Test.startTest();
                blQuickText.requestBody = new Map<String,Object>{}; 
                blQuickText.pathParameters = new Map<String, String>{
                    'id' => quickText.id
                };
                blQuickText.executeGET();
            Test.stopTest();
        }
    }

    @isTest
    static void getQuickTextByIdWithRecordId(){     
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_QuickText blQuickText = new BL_EMAIL_QuickText();
        Case request = [SELECT Id, AccountId FROM Case LIMIT 1];
        QuickText quickText = [SELECT Id FROM QuickText LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blQuickText.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blQuickText.queryParams = new Map<String, String>{
                'application' => 'WARDROBING',
                'recordId' => request.Id
            };
            
            blQuickText.path = '/quick-texts/{id}';
            
            Test.startTest();
                blQuickText.requestBody = new Map<String,Object>{}; 
                blQuickText.pathParameters = new Map<String, String>{
                    'id' => quickText.id
                };
                blQuickText.executeGET();
            Test.stopTest();
        }
    }
    @isTest
    static void getQuickText(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_QuickText blQuickText = new BL_EMAIL_QuickText();
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blQuickText.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blQuickText.queryParams = new Map<String, String>{
                'application' => 'WARDROBING',
                'feature' => 'recent'
            };
            
            blQuickText.path = '/quick-texts';
            
            Test.startTest();
                blQuickText.requestBody = new Map<String,Object>{}; 
                blQuickText.pathParameters = new Map<String, String>{};
                blQuickText.executeGET();
            Test.stopTest();
        }
    }

    @isTest
    static void getListQuickText(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_QuickText blQuickText = new BL_EMAIL_QuickText();
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blQuickText.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blQuickText.queryParams = new Map<String, String>{
                'application' => 'WARDROBING',
                'feature' => 'all'
            };
            
            blQuickText.path = '/quick-texts';
            
            Test.startTest();
                blQuickText.requestBody = new Map<String,Object>{}; 
                blQuickText.pathParameters = new Map<String, String>{};
                blQuickText.executeGET();
            Test.stopTest();
        }
    }
}