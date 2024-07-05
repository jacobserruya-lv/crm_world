/**
About
-----
Description: Test class of STAR_PhotoBook_VFCx
Created for: 
Create date: 

Details
-------


Update History
--------------
Jun 23/06 MTOU: creating account as Dream user in LoadData mathod
Sep 05/09 RMOU: PIPA Law enhancements

Issues / TODOs
--------------
*/
@isTest
private class STAR_PhotoBook_VFCx_TEST {
    
    static void UserNotKorean()
    {
        User user = [Select Id, Country__c from User where Id=:UserInfo.getUserId() limit 1];
        user.Country__c = 'FRANCE';
        
        update user;    
        
    }
    
    static void UserKorean()
    {
        /***  Pipa user  ***/
        User user1 = IC_TestFactory.createUser('user@korean.com');
        user1.Country__c = 'KOREA';
        user1.ProfileId = IC_TestFactory.PROFILE_MAP.get(IC_TestFactory.PROFILE_ICON_SA_NAME);
        insert user1;   
        
    }
    
    static void loadData()
    {
        STAR_CustomIterable obj;
        
        Event__c evt;
        Program__c prg1;
        Program__c prg2;
        Program__c prg3;
        Program__c prg4;
        Program__c prg5;
        Program__c prg6;
        Program__c prg7;
        Program__c prg8;
        Program__c prg9;
        Program__c prg10;
        Program__c prg11;
        
        
        //Create new Account
        
        
        List<Account> accList = new List<Account>();
        List<Program__c> progs = new List<Program__c>();
        
        Account account1 = IC_TestFactory.createAccount();
        account1.firstName='Mathieu';
        account1.lastName='Jean-luc';
        accList.add(account1);
        //insert account1;
        
        //Create new Account
        Account account2 = IC_TestFactory.createAccount();
        accList.add(account2);
        //insert account2;
        
        //Create new Account
        Account account3 = IC_TestFactory.createAccount();
        accList.add(account3);
        //insert account3;
        
        //Create new Account
        Account account4 = IC_TestFactory.createAccount();
        account4.PrimaryCountry__pc='France';
        account4.AttachedStore__pc='test';
        
        accList.add(account4);
        //insert account4;
        
        //Create new Account
        Account account5 = IC_TestFactory.createAccount();
        accList.add(account5);
        //insert account5;
        
        //Create new Account
        Account account6 = IC_TestFactory.createAccount();
        accList.add(account6);
        //insert account6;
        
        //Create new Account
        Account account7 = IC_TestFactory.createAccount();
        account7.attachedStoreCountry__pc='KOR';
        accList.add(account7);
        //insert account7;
        
        //Create new Account
        Account account8 = IC_TestFactory.createAccount();
        accList.add(account8);
        //insert account8;
        
        //Create new Account
        Account account9 = IC_TestFactory.createAccount();
        accList.add(account9);
        //insert account9;
        
        //Create new Account
        Account account10 = IC_TestFactory.createAccount();
        accList.add(account10);
        //insert account10;
        
        //Create new Account
        Account account11 = IC_TestFactory.createAccount();
        accList.add(account11);
        //insert account11; 
        
        //Create new Account
        Account account12 = IC_TestFactory.createAccount();
        accList.add(account12);
        //insert account12;
        
        //Create new Account
        Account account13 = IC_TestFactory.createAccount();
        accList.add(account13);
        //insert account13;       
        Profile p = [select id from Profile where name = 'ICON_Interface DREAM'];
        User dream =  Test_Utils.createUser('eqsdqsdqd2');
        system.runAs(dream)
        {   
            insert accList;
        }
        
        //Create new STAR Event ('Event__c' Object ). It will be used when STAR Program is created
        evt = new Event__c();
        evt.Name='EventTest';
        evt.Start_Date__c =Date.today();
        evt.End_Date__c =Date.today();
        evt.Level__c='International';       
        evt.Location__c='PariSelecs';
        evt.Theme__c='Art & Culture';
        evt.Type__c='Exhibition';
        
        insert evt;
        
        //Create new Program1
        prg1 = New Program__c();
        prg1.name='ProgramTest1';
        prg1.AccountId__c = account1.Id;
        prg1.EventId__c = evt.id;
        progs.Add(prg1);
        
        //Create new Program2
        prg2 = New Program__c();
        prg2.name='ProgramTest2';
        prg2.AccountId__c = account2.Id;
        prg2.EventId__c = evt.id;
        prg2.Status__c='Cancelled';
        prg2.Reason__c='This is reason !';
        
        progs.Add(prg2);
        
        //Create new Program3
        prg3 = New Program__c();
        prg3.name='ProgramTest3';
        prg3.AccountId__c = account3.Id;
        prg3.EventId__c = evt.id;
        
        progs.Add(prg3);
        
        //Create new Program4
        prg4 = New Program__c();
        prg4.name='ProgramTest4';
        prg4.AccountId__c = account4.Id;
        prg4.EventId__c = evt.id;
        prg4.Inviting_Zone__c='test';
        prg4.Status__c='test';
        
        
        progs.Add(prg4);
        
        //Create new Program5
        prg5 = New Program__c();
        prg5.name='ProgramTest5';
        prg5.AccountId__c = account5.Id;
        prg5.EventId__c = evt.id;
        
        progs.Add(prg5);
        
        //Create new Program6
        prg6 = New Program__c();
        prg6.name='ProgramTest6';
        prg6.AccountId__c = account6.Id;
        prg6.EventId__c = evt.id;
        
        progs.Add(prg6);
        
        //Create new Program7
        prg7 = New Program__c();
        prg7.name='ProgramTest7';
        prg7.AccountId__c = account7.Id;
        prg7.EventId__c = evt.id;
        
        progs.Add(prg7);
        
        //Create new Program8
        prg8 = New Program__c();
        prg8.name='ProgramTest8';
        prg8.AccountId__c = account8.Id;
        prg8.EventId__c = evt.id;
        
        progs.Add(prg8);
        
        //Create new Program9
        prg9 = New Program__c();
        prg9.name='ProgramTest9';
        prg9.AccountId__c = account9.Id;
        prg9.EventId__c = evt.id;
        
        progs.Add(prg9);
        
        //Create new Program10
        prg10 = New Program__c();
        prg10.name='ProgramTest10';
        prg10.AccountId__c = account10.Id;
        prg10.EventId__c = evt.id;
        
        progs.Add(prg10);
        
        //Create new Program11
        prg11 = New Program__c();
        prg11.name='ProgramTest11';
        prg11.AccountId__c = account11.Id;
        prg11.EventId__c = evt.id;
        
        progs.Add(prg11);
        
        insert progs;
        
    }
    
    
    static testMethod void TestWithUserKorean() {
        UserKorean();
        loadData();        
        ApexPages.currentPage().getParameters().put('eventname','EventTest');
        
        
        STAR_PhotoBook_VFCx photobook = new STAR_PhotoBook_VFCx();
        System.Test.startTest();
        List<SelectOption> selectedQuestions = photobook.zoneOptions;
        List<SelectOption> selectedstatus = photobook.statusOptions;
        
        System.Test.stopTest();
        photobook.hasNext=true;
        photobook.hasPrevious=true;
        
        photobook.ClientName='';
        photobook.EventName='';
        photobook.save();
        
        photobook.ClientName='Jean-luc Mathieu';
        photobook.EventName='EventTest';
        photobook.invitingZone='test';
        photobook.invitationStatus='test';
        photobook.country='France';
        photobook.store='test';

        photobook.save();
        
        photobook.ClientName='';
        photobook.EventName='EventTest';
        photobook.invitingZone='test';
        
        photobook.save();
        
        
        photobook.next();
        
        photobook.print();
        photobook.print2();
        
        
    }
    
    
    
    
}