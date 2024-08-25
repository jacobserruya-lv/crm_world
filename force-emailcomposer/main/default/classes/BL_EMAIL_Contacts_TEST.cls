@isTest
private class BL_EMAIL_Contacts_TEST {

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
    static void searchContact(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_Contacts blContacts = new BL_EMAIL_Contacts();
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            Account contacts = [SELECT Id FROM Account LIMIT 1];
            List<Id> fixedSearchResults= new List<Id>();
            fixedSearchResults.add(contacts.id);
            Test.setFixedSearchResults(fixedSearchResults);

            blContacts.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blContacts.queryParams = new Map<String, String>{
                'searchText' => 'louis@lv.com',
                'application' => 'WARDROBING'
            };
            
            blContacts.path = '/contacts';
            
            Test.startTest();
                blContacts.requestBody = new Map<String,Object>{}; 
                blContacts.pathParameters = new Map<String, String>{};
                blContacts.executeGET();

            Test.stopTest();
        }
    }

    @isTest
    static void getAccountContactById(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_Contacts blContacts = new BL_EMAIL_Contacts();
        Account contacts = [SELECT Id FROM Account LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blContacts.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blContacts.queryParams = new Map<String, String>{
                'application' => 'WARDROBING'
            };
            
            blContacts.path = '/contacts/{id}';
            
            Test.startTest();
                blContacts.requestBody = new Map<String,Object>{}; 
                blContacts.pathParameters = new Map<String, String>{
                    'id' => contacts.id
                };
                blContacts.executeGET();
            Test.stopTest();
        }
    }

    @isTest
    static void getUserContactById(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_Contacts blContacts = new BL_EMAIL_Contacts();
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blContacts.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blContacts.queryParams = new Map<String, String>{
                'application' => 'WARDROBING'
            };
            
            blContacts.path = '/contacts/{id}';
            
            Test.startTest();
                blContacts.requestBody = new Map<String,Object>{}; 
                blContacts.pathParameters = new Map<String, String>{
                    'id' => u.id
                };
                blContacts.executeGET();
            Test.stopTest();
        }
    }
}