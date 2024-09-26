@isTest
private class EmailComposer_CTRL_TEST {

    @TestSetup
    static void createTestData() {
        Account acc = new Account(LastName = 'Europe', FirstName='Louis', PersonEmail='louis@lv.com' );
		insert acc;

        Case cse = new Case(Origin = 'Email', Status = 'New', Priority = 'Medium', AccountId = acc.Id, Description ='Un case de Test');
        insert cse;

        Case request = new Case(Origin = 'Email', Status = 'New', Priority = 'Medium',TECH_Country__c='FRA', AccountId = acc.Id, Description ='Un case de Test' ,SuppliedEmail='louis@lv.com' ,SuppliedName = 'Europe Louis');
        insert request;

        Case request2 = new Case(Origin = 'Email', Status = 'New', Priority = 'Medium',TECH_Queue__c='Sweden', AccountId = acc.Id, Description ='Un case de Test' ,SuppliedEmail='louis@lv.com' ,SuppliedName = 'Europe Louis');
        insert request2;
    
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06', Store_CountryCode__c='FR');
        insert store;

        CareService__c c = new CareService__c(Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c);
		insert c;

        Family__c fam = new Family__c();
        insert fam;
        Family_Member__c fm = new Family_Member__c(Family__c = fam.Id);
        insert fm;

        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = 'A06';
        u.WWEmployeeNumber__c = 'WW198765467';
        insert u;

        IconicsSettings__c iconicsSetting = new IconicsSettings__c(EmailTemplateImage__c = 'https://louisvuitton--pprod.sandbox.file.force.com/servlet/servlet.ImageServer?id=015780000009sti&oid=00D780000000OiI&lastMod=1714991315000', 
                                                       CurrentYearLegalNotices__c = '2023');
        insert iconicsSetting;

    }

    @isTest
    static void getDefaultValueAccount(){
        Account contacts = [SELECT Id FROM Account LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            Test.startTest();
                PageReference pageRef = Page.EmailComposer_VF;
                pageRef.getParameters().put('recordId',contacts.Id);
                pageRef.getParameters().put('application','WARDROBING');
                Test.setCurrentPage(pageRef);

                EmailComposer_CTRL controller = new EmailComposer_CTRL();
                EmailComposer_CTRL.getFoldersTemplateName('ICONICS',contacts.Id);
            Test.stopTest();
        }
    }


    @isTest
    static void getDefaultValueCase(){
        Case request = [SELECT Id FROM Case LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            Test.startTest();
                PageReference pageRef = Page.EmailComposer_VF;
                pageRef.getParameters().put('recordId',request.Id);
                pageRef.getParameters().put('application','WARDROBING');
                Test.setCurrentPage(pageRef);

                EmailComposer_CTRL.getFoldersTemplateName('ICONICS',request.Id);
                EmailComposer_CTRL controller = new EmailComposer_CTRL();

            Test.stopTest();
        }
    }

    @isTest
    static void getDefaultValueCaseEmail(){
        Case request = [SELECT Id FROM Case  WHERE SuppliedEmail = 'louis@lv.com' LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            Test.startTest();
                PageReference pageRef = Page.EmailComposer_VF;
                pageRef.getParameters().put('recordId',request.Id);
                pageRef.getParameters().put('application','WARDROBING');
                Test.setCurrentPage(pageRef);

                EmailComposer_CTRL controller = new EmailComposer_CTRL();
            Test.stopTest();
        }
    }

    @isTest
    static void getDefaultValueCaseCountry(){
        Case request = [SELECT Id FROM Case  WHERE TECH_Country__c='FRA' LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            Test.startTest();
                PageReference pageRef = Page.EmailComposer_VF;
                pageRef.getParameters().put('recordId',request.Id);
                pageRef.getParameters().put('application','WARDROBING');
                Test.setCurrentPage(pageRef);

                EmailComposer_CTRL controller = new EmailComposer_CTRL();
            Test.stopTest();
        }
    }
    @isTest
    static void getDefaultValueCaseQueue(){
        Case request = [SELECT Id FROM Case WHERE TECH_Queue__c = 'Sweden' LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];
        
        system.runAs(u){
            Test.startTest();
                PageReference pageRef = Page.EmailComposer_VF;
                pageRef.getParameters().put('recordId',request.Id);
                pageRef.getParameters().put('application','WARDROBING');
                Test.setCurrentPage(pageRef);

                EmailComposer_CTRL controller = new EmailComposer_CTRL();
            Test.stopTest();
        }
    }


    @isTest
    static void getDefaultValueFamilyMember(){
        Family_Member__c family = [SELECT Id FROM Family_Member__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            Test.startTest();
                PageReference pageRef = Page.EmailComposer_VF;
                pageRef.getParameters().put('recordId',family.Id);
                pageRef.getParameters().put('application','WARDROBING');
                Test.setCurrentPage(pageRef);

                EmailComposer_CTRL.getFoldersTemplateName('ICONICS',family.Id);

                EmailComposer_CTRL controller = new EmailComposer_CTRL();
            Test.stopTest();
        }
    }
   
    @isTest
    static void getDefaultValueRepair(){
        CareService__c repair = [SELECT Id FROM CareService__c LIMIT 1];
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            Test.startTest();
                PageReference pageRef = Page.EmailComposer_VF;
                pageRef.getParameters().put('recordId',repair.Id);
                pageRef.getParameters().put('application','WARDROBING');
                Test.setCurrentPage(pageRef);

                EmailComposer_CTRL.getFoldersTemplateName('ICONICS',repair.Id);

                EmailComposer_CTRL controller = new EmailComposer_CTRL();
            Test.stopTest();
        }
    }


    @isTest
    static void getDefaultValueTask(){
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];
        
        system.runAs(u){
            Test.startTest();
            Account a = new Account(LastName = 'Europe', FirstName='Louis', PersonEmail='louis@lv.com' );
            insert a;
            Task t = new Task();
            insert t;
            Task ta = [SELECT Id FROM Task  LIMIT 1];
                PageReference pageRef = Page.EmailComposer_VF;
                pageRef.getParameters().put('recordId',ta.Id);
                pageRef.getParameters().put('application','WARDROBING');
                Test.setCurrentPage(pageRef);

                EmailComposer_CTRL.getFoldersTemplateName('ICONICS',ta.Id);

                EmailComposer_CTRL controller = new EmailComposer_CTRL();
            Test.stopTest();
        }
    }

   
}