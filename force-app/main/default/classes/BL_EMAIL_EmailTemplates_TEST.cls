@isTest
private class BL_EMAIL_EmailTemplates_TEST {

    @TestSetup
	static void createTestData() {
		Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06');
		insert store;

		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = 'A06';
		u.WWEmployeeNumber__c = 'WW198765467';
		insert u;
        
	}

    @isTest
    static void searchEmailTemplate(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_EmailTemplates blTemplates = new BL_EMAIL_EmailTemplates();
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blTemplates.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blTemplates.queryParams = new Map<String, String>{
                'searchText' => 'France',
                'application' => 'WARDROBING',
                'folders' => 'ICONICS_Templates'
            };
            
            blTemplates.path = '/templates';
           
            Test.startTest();
                blTemplates.requestBody = new Map<String,Object>{}; 
                blTemplates.pathParameters = new Map<String, String>{};
                blTemplates.executeGET();

                BL_EMAIL_EmailTemplates_Helper.getEmailTemplateByDeveloperName(null, null);
            Test.stopTest();
        }
    }

    @isTest
    static void getEmailTemplateById(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_EmailTemplates blTemplates = new BL_EMAIL_EmailTemplates();
        EmailTemplate template = [SELECT Id FROM EmailTemplate LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blTemplates.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blTemplates.queryParams = new Map<String, String>{
                'application' => 'WARDROBING'
            };
            
            blTemplates.path = '/templates/{id}';
           
            Test.startTest();
                blTemplates.requestBody = new Map<String,Object>{}; 
                blTemplates.pathParameters = new Map<String, String>{
                    'id' => template.id
                };
                blTemplates.executeGET();
            Test.stopTest();
        }
    }
  
    @isTest
    static void getListEmailTemplate(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_EmailTemplates blTemplates = new BL_EMAIL_EmailTemplates();
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blTemplates.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blTemplates.queryParams = new Map<String, String>{
                'application' => 'WARDROBING',
                'folders' => 'ICONICS_Templates'
            };
            
            blTemplates.path = '/templates';
           
            Test.startTest();
                blTemplates.requestBody = new Map<String,Object>{}; 
                blTemplates.pathParameters = new Map<String, String>{};
                blTemplates.executeGET();
            Test.stopTest();
        }
    }

}