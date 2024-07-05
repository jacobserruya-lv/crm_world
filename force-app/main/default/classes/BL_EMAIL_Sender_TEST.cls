@isTest
private class BL_EMAIL_Sender_TEST {

    @TestSetup
    static void createTestData() {
        Account acc = new Account(LastName = 'Europe', FirstName='Louis', PersonEmail='louis@lv.com' );
		insert acc;

        Case cse = new Case(Origin = 'Email', Status = 'New', Priority = 'Medium', AccountId = acc.Id, Description ='Un case de Test');
        insert cse;
    
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06');
        insert store;

        CareService__c c = new CareService__c(Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c);
		insert c;

        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = 'A06';
        u.WWEmployeeNumber__c = 'WW198765467';
        insert u;
    }

    @isTest
    static void sendEmailAccount(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_Sender blSender = new BL_EMAIL_Sender();
        Account contacts = [SELECT Id FROM Account LIMIT 1];
        EmailTemplate template = [SELECT Id ,Subject, HtmlValue  FROM EmailTemplate LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blSender.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blSender.queryParams = new Map<String, String>{
                'application' => 'WARDROBING'
            };
            
            Test.startTest();
                Map<String,Object> defaultContact = BL_EMAIL_Contacts_Helper.getContactById( contacts.Id);
                Map<String,Object> sender = BL_EMAIL_Contacts_Helper.getContactById(u.Id);
                Map<String,Object> body = new Map<String,Object> { 
                    'recordId' => contacts.Id,
                    'subject' => template.Subject,
                    'body'=> '<div></div>',
                    'templateId' => template.Id,
                    'toContacts' => new List<String>{'louis@lv.com'},
                    'ccContacts' => new List<String>{},
                    'bccContacts' => new List<String>{},
                    'sender' => sender,
                    'defaultContact' => defaultContact
                };  

                blSender.requestBody = new Map<String,Object> {
                    'body' => body
                };  
                blSender.pathParameters = new Map<String, String>{};
                blSender.executePOST();

            Test.stopTest();
        }
    }
    
    @isTest
    static void sendEmailAccountRemote(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_Sender blSender = new BL_EMAIL_Sender();
        Account contacts = [SELECT Id FROM Account LIMIT 1];
        EmailTemplate template = [SELECT Id ,Subject, HtmlValue  FROM EmailTemplate LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blSender.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blSender.queryParams = new Map<String, String>{
                'application' => 'WARDROBING'
            };
            
            Test.startTest();
                Map<String,Object> defaultContact = BL_EMAIL_Contacts_Helper.getContactById(contacts.Id);
                Map<String,Object> sender = BL_EMAIL_Contacts_Helper.getContactById(u.Id);
                Map<String,Object> body = new Map<String,Object> { 
                    'recordId' => contacts.Id,
                    'emailType' => 'remoteConsent',
                    'subject' => template.Subject,
                    'body'=> '<div></div>',
                    'templateId' => template.Id,
                    'toContacts' => new List<String>{'louis@lv.com'},
                    'ccContacts' => new List<String>{},
                    'bccContacts' => new List<String>{},
                    'sender' => sender,
                    'defaultContact' => defaultContact
                   
                };  

                blSender.requestBody = new Map<String,Object> {
                    'body' => body
                };  
                blSender.pathParameters = new Map<String, String>{};
                blSender.executePOST();
            Test.stopTest();
        }
    }

    @isTest
    static void sendEmailRequest(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_Sender blSender = new BL_EMAIL_Sender();
        Case request = [SELECT Id, AccountId FROM Case LIMIT 1];
        OrgWideEmailAddress owea = [SELECT Id , Address FROM OrgWideEmailAddress LIMIT 1];
        EmailTemplate template = [SELECT Id ,Subject, HtmlValue  FROM EmailTemplate LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blSender.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blSender.queryParams = new Map<String, String>{
                'application' => 'WARDROBING'
            };
            
            Test.startTest();
                Map<String,Object> defaultContact = BL_EMAIL_Contacts_Helper.getContactById(request.AccountId);
                Map<String,Object> sender = BL_EMAIL_Config_Helper.getSenderAddressByEmail(owea.Address);
                Map<String,Object> body = new Map<String,Object> { 
                    'recordId' => request.Id,
                    'subject' => template.Subject,
                    'body'=> '<div></div>',
                    'templateId' => template.Id,
                    'toContacts' => new List<String>{'louis@lv.com'},
                    'ccContacts' => new List<String>{},
                    'bccContacts' => new List<String>{},
                    'sender' => sender,
                    'defaultContact' => defaultContact
                };  

                blSender.requestBody = new Map<String,Object> {
                    'body' => body
                };  
                blSender.pathParameters = new Map<String, String>{};
                blSender.executePOST();
            Test.stopTest();
        }
    }

    @isTest
    static void sendEmailRepair(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_Sender blSender = new BL_EMAIL_Sender();
        CareService__c repair = [SELECT Id, Client__c FROM CareService__c LIMIT 1];
        OrgWideEmailAddress owea = [SELECT Id , Address FROM OrgWideEmailAddress LIMIT 1];
        EmailTemplate template = [SELECT Id ,Subject, HtmlValue  FROM EmailTemplate LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blSender.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blSender.queryParams = new Map<String, String>{
                'application' => 'WARDROBING'
            };
            
            Test.startTest();
                Map<String,Object> defaultContact = BL_EMAIL_Contacts_Helper.getContactById(repair.Client__c);
                Map<String,Object> sender = BL_EMAIL_Config_Helper.getSenderAddressByEmail(owea.Address);
                Map<String,Object> body = new Map<String,Object> { 
                    'recordId' => repair.Id,
                    'subject' => template.Subject,
                    'body'=> '<div></div>',
                    'templateId' => template.Id,
                    'toContacts' => new List<String>{'louis@lv.com'},
                    'ccContacts' => new List<String>{},
                    'bccContacts' => new List<String>{},
                    'sender' => sender,
                    'defaultContact' => defaultContact
                };  

                blSender.requestBody = new Map<String,Object> {
                    'body' => body
                };  
                blSender.pathParameters = new Map<String, String>{};
                blSender.executePOST();
            Test.stopTest();
        }
    }

    @isTest
    static void sendEmailClienteling(){
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_Sender blSender = new BL_EMAIL_Sender();
        Account contacts = [SELECT Id FROM Account LIMIT 1];
        contacts.SPO_Country_code__pc = 'ABW';
        update contacts;
        EmailTemplate template = [SELECT Id ,Subject, HtmlValue  FROM EmailTemplate LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            blSender.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blSender.queryParams = new Map<String, String>{
                'application' => 'WARDROBING'
            };
            
            Test.startTest();
                Map<String,Object> defaultContact = BL_EMAIL_Contacts_Helper.getContactById(contacts.Id);
                Map<String,Object> sender = BL_EMAIL_Contacts_Helper.getContactById(u.Id);
                Map<String,Object> body = new Map<String,Object> { 
                    'recordId' => contacts.Id,
                    'emailType' => 'clienteling',
                    'subject' => template.Subject,
                    'body'=> '<div></div>',
                    'templateId' => template.Id,
                    'toContacts' => new List<String>{'louis@lv.com'},
                    'ccContacts' => new List<String>{},
                    'bccContacts' => new List<String>{},
                    'sender' => sender,
                    'defaultContact' => defaultContact
                   
                };  

                blSender.requestBody = new Map<String,Object> {
                    'body' => body
                };  
                blSender.pathParameters = new Map<String, String>{};
                blSender.executePOST();
            Test.stopTest();
        }
    }


}