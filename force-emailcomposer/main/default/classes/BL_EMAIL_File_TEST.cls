@isTest
private class BL_EMAIL_File_TEST {

    @TestSetup
    static void createTestData() {
        Account acc = new Account(LastName = 'Europe', FirstName='Louis', PersonEmail='louis@lv.com' );
		insert acc;

        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06');
        insert store;

        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = 'A06';
        u.WWEmployeeNumber__c = 'WW198765467';
        insert u;
    }

    @isTest
    static void createContentAsset(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_File blFiles = new BL_EMAIL_File();
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blFiles.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blFiles.queryParams = new Map<String, String>{
                'application' => 'WARDROBING'
            };
            
            Test.startTest();
                blFiles.requestBody = new Map<String,Object> { 
                    'isAssetEnabled' => true,
                    'title' => 'myimage',
                    'data'=> 'test',
                    'extension' => '.png'
                };  
                blFiles.pathParameters = new Map<String, String>{};
                blFiles.executePOST();
            Test.stopTest();
        }
    }

    @isTest
    static void createContentVersion(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_File blFiles = new BL_EMAIL_File();
        Account contacts = [SELECT Id FROM Account LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blFiles.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blFiles.queryParams = new Map<String, String>{
                'application' => 'WARDROBING'
            };
            
            Test.startTest();
                blFiles.requestBody = new Map<String,Object> { 
                    'recordId' => contacts.id,
                    'isAssetEnabled' => false,
                    'title' => 'myimage',
                    'data'=> 'test',
                    'extension' => '.png'
                };  
                blFiles.pathParameters = new Map<String, String>{};
                blFiles.executePOST();
            Test.stopTest();
        }
    }
}