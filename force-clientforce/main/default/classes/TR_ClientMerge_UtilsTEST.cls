/***************************************************************************************************
* @File Name          : TR_ClientMerge_UtilsTEST.cls
* @Description        : This class was created for the C360 project 
* @Author             : Imad.alsidchikh@vo2-consultant.com
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 09-30-2022
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       09-30-2022         Imad.alsidchikh@vo2-group.com     Initial Version
*****************************************************************************************************/
@isTest
public class TR_ClientMerge_UtilsTEST {
    @testSetup 
    static void createTestData() {
        
        List<Account> accounts = new List<Account>();        
        
        // ####### MASTER ACCOUNTS ########
        // ##### MASTER #1
        Account accMaster1;
        accMaster1 = IC_TestFactory.createAccount();
        accMaster1.Dreamid__c = 'TEST894M0';
        accMaster1.lastName = 'MasterClient #0';
        accMaster1.PersonEmail = 'master@master.com';
        accMaster1.Unsubscribe__pc = false;
        accMaster1.UnsubscribeDate__pc = null;
        accMaster1.PersonHasOptedOutOfEmail = false;
        accMaster1.DoNotSMS__pc = false;
        accMaster1.DoNotContactbyPost__pc = false;
        accounts.add(accMaster1);
        // ##### MASTER #2
        Account accMaster2;
        accMaster2 = IC_TestFactory.createAccount();
        accMaster2.Dreamid__c = 'TEST895M0';
        accMaster2.PersonEmail = null;
        accMaster2.lastName = 'MasterClient #1';
        accMaster2.Unsubscribe__pc = false;
        accMaster2.UnsubscribeDate__pc = null;
        accMaster2.PersonHasOptedOutOfEmail = false;
        accMaster2.DoNotSMS__pc = false;
        accMaster2.DoNotContactbyPost__pc = false;
        accounts.add(accMaster2);
        // ####### MASTER ACCOUNTS ########
        // ####### SLAVE ACCOUNTS ########
        // ##### SLAVE #1
        Account account1;
        account1 = IC_TestFactory.createAccount();
        account1.Dreamid__c = 'TEST893S0';
        account1.DreamIdMasterClient__c = 'TEST894M0';
        account1.ToDelete__c = '1';
        account1.lastName = 'SlaveClient #0';
        account1.PersonEmail = 'slave@slave.com';
        account1.Unsubscribe__pc = true;
        account1.UnsubscribeDate__pc = Date.today();
        account1.PersonHasOptedOutOfEmail = true;
        account1.DoNotSMS__pc = true;
        account1.DoNotContactbyPost__pc = true;
        accounts.add(account1);
        // ##### SLAVE #2
        Account account2;
        account2 = IC_TestFactory.createAccount();
        account2.Dreamid__c = 'TEST892S0';
        account2.DreamIdMasterClient__c = 'TEST894M0';
        account2.ToDelete__c = '1';
        account2.lastName = 'SlaveClient #1';
        account2.PersonEmail = 'master@master.com';
        account2.Unsubscribe__pc = true;
        account2.UnsubscribeDate__pc = Date.today();
        account2.PersonHasOptedOutOfEmail = true;
        account2.DoNotSMS__pc = true;
        account2.DoNotContactbyPost__pc = true;
        accounts.add(account2);
        // ##### SLAVE #3
        Account account3;
        account3 = IC_TestFactory.createAccount();
        account3.Dreamid__c = 'TEST891S0';
        account3.DreamIdMasterClient__c = 'TEST895M0';
        account3.ToDelete__c = '1';
        account3.lastName = 'SlaveClient #1';
        account3.PersonEmail = 'slave3@master.com';
        account3.Unsubscribe__pc = true;
        account3.UnsubscribeDate__pc = Date.today();
        account3.PersonHasOptedOutOfEmail = true;
        account3.DoNotSMS__pc = true;
        account3.DoNotContactbyPost__pc = true;
        accounts.add(account3);
        // ####### SLAVE ACCOUNTS ########
        
        insert accounts;
        
        // Create new ActionPlan    
        ActionPlan__c actionPlan = new ActionPlan__c();  
        actionPlan.Comments__c = 'Comments';
        actionPlan.IsClosed__c = false;
        actionPlan.AccountId__c = account1.Id;
        actionPlan.Subject__c =  'subject'  ;            
        insert actionPlan;
        
        // Create new IndividualEmailResult 
        et4ae5__IndividualEmailResult__c em;   
        em = new et4ae5__IndividualEmailResult__c();
        em.et4ae5__Contact__c = [Select Id From Contact WHERE AccountId = :account1.Id].id;       
        et4ae5__SendDefinition__c sd = new et4ae5__SendDefinition__c  ();
        insert sd;
        
        em.et4ae5__SendDefinition__c = sd.id;
        insert em;
        
        Contact contact1 = [Select Id From Contact WHERE AccountId = :account1.Id];
        // Create new SMSDefinition    
        et4ae5__SMSDefinition__c sms = new et4ae5__SMSDefinition__c();
        sms.et4ae5__Contact__c = contact1.id;             
        insert sms;
        
        //Create new STAR Event ('Event__c' Object ). It will be used when STAR Program is created
        Event__c evt = new Event__c();
        evt.Name='EventTest';
        evt.Start_Date__c =Date.today();
        evt.End_Date__c = Date.today();      
        evt.Location__c='PariSelecs';
        evt.Level__c='International';
        evt.Theme__c='Art & Culture';
        evt.Type__c='Exhibition';
        
        insert evt;
        
        //Create new Program
        Program__c prg;
        prg = New Program__c();
        prg.name='ProgramTest';
        prg.AccountId__c = account1.Id;
        prg.EventId__c = evt.id;
        
        insert prg;
        
        // Create new Event 
        Event event;        
        event = IC_TestFactory.createEvent(account1);
        //event.whoID = account.PersonContactId;
        event.whoID = contact1.id;
        insert event;
        
        // Create new Task
        Task task;
        task = IC_TestFactory.createTask(account1);
        //task.whoID = account.PersonContactId;
        task.whoID = contact1.id;
        insert task;
        
        // Create new Task related to an ActionPlan 
        task = IC_TestFactory.createTask(account1);
        task.whoID = contact1.id;
        task.whatID= actionPlan.id;
        insert task;
        
        // Create new Event related to an ActionPlan 
        event = IC_TestFactory.createEvent(account1);
        event.whoID = contact1.id;
        event.whatID= actionPlan.id;
        insert event;
        
        CLI_CliList__c cl = IC_TestFactory.clientlistMembers();
        insert cl;
        
        CLM_CliListMember__c Clm = new CLM_CliListMember__c();
        Clm.Client__c = contact1.id;
        Clm.ClientList__c = Cl.Id;
        insert Clm; 
        
        // Create a case attached to the slave account
        Group g = new Group (Name = 'Queue-France', Type = 'Queue');
        insert g;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueueSObject q = new QueueSobject(QueueID = g.id, SobjectType = 'case');
            insert q;
        }
        
        Case ca = new Case (Type = 'Product Information',
                            Origin = 'Email',
                            Status = 'New',
                            Subject = 'test case subject ' + Datetime.now(),
                            Description = 'test case description ' + Datetime.now(),
                            Accountid = account1.id,
                            ContactID = account1.PersonContactId,
                            Ownerid = g.id);
        insert ca;     
    }
    
    @isTest static void testMergeClient_1() {
        Test.startTest();
        List<Account> accs =[SELECT Id from account];
        Set<Id> acctIds = new Set<Id>();
        for(Account a: accs){
            acctIds.add(a.id);
        }
        TR_IntegrationManagerHandler.mergeCheck(acctIds);
        Test.stopTest(); 
    }
    
    @isTest static void testMergeClient_3() {
        Account absorbed;
        Account master;
        Account master2;
        
        for (Account acc : [Select Id, Dreamid__c From Account Where Dreamid__c='TEST893S0' or Dreamid__c='TEST894M0' or Dreamid__c='TEST895M0']){
            if (acc.Dreamid__c == 'TEST893S0') absorbed = acc;
            if (acc.Dreamid__c == 'TEST894M0') master = acc;
            if (acc.Dreamid__c == 'TEST895M0') master2 = acc;
        }
        
        List<Social_Media_Identifier__c> smis = new List<Social_Media_Identifier__c>();
        List<Exclusive_Experience__c> exps = new List<Exclusive_Experience__c>();
        

        
        //Create new Social Media Identifiers
        Social_Media_Identifier__c smi1 = new Social_Media_Identifier__c();
        smi1.Client__c = absorbed.Id;
        smi1.Social_Media_Type__c = 'WeChat';
        smi1.Social_Id__c = 'TEST001';
        smis.add(smi1);
        
        Social_Media_Identifier__c smi2 = new Social_Media_Identifier__c();
        smi2.Client__c = master.Id;
        smi2.Social_Media_Type__c = 'WeChat';
        smi2.Social_Id__c = 'TEST002';
        smis.add(smi2);
        
        // Create Exclusive Experience
        Exclusive_Experience__c xxpr1 = new Exclusive_Experience__c();
        xxpr1 = IC_TestFactory.createExclusiveExperience(absorbed);
        xxpr1.Offer_Code__c = 'exclu_nba_1_2020';
        exps.add(xxpr1);        
        Exclusive_Experience__c xxpr2 = new Exclusive_Experience__c();
        xxpr2 = IC_TestFactory.createExclusiveExperience(master);
        xxpr2.Offer_Code__c = 'exclu_nba_1_2020';
        exps.add(xxpr2);
        Exclusive_Experience__c xxpr3 = new Exclusive_Experience__c();
        xxpr3 = IC_TestFactory.createExclusiveExperience(master2);
        xxpr3.Offer_Code__c = 'exclu_nba_1_2020';
        exps.add(xxpr3);
        
        
        
        Test.startTest();
        insert smis;
        insert exps;
        List<Account> accs =[SELECT Id from account];
        Set<Id> acctIds = new Set<Id>();
        for(Account a: accs){
            acctIds.add(a.id);
        }
        TR_IntegrationManagerHandler.mergeCheck(acctIds);
        Test.stopTest(); 
    }
    
    @isTest static void testMergeClient_4() {
        Account absorbed;
        Account master;
        Account master2;
        
        for (Account acc : [Select Id, Dreamid__c From Account Where Dreamid__c='TEST893S0' or Dreamid__c='TEST894M0' or Dreamid__c='TEST895M0']){
            if (acc.Dreamid__c == 'TEST893S0') absorbed = acc;
            if (acc.Dreamid__c == 'TEST894M0') master = acc;
            if (acc.Dreamid__c == 'TEST895M0') master2 = acc;
        }
        
		// Create new CallingCampaign
        Calling_Campaign__c cc = new Calling_Campaign__c();
        cc.Client__c = absorbed.Id;
        insert cc;
        
        // Create new Look 
        Look__c l = new Look__c();
        l.SKUs__c = 'T1234;T4567';
        insert l;
        
        // Create new Look Share 
        Look_Share__c ls = new Look_Share__c();
        ls.Look__c = l.Id;
        ls.Client__c = absorbed.Id;
        ls.ExternalId__c = '123456789';
        Test.startTest();
        
        insert ls;
        List<Account> accs =[SELECT Id from account];
        Set<Id> acctIds = new Set<Id>();
        for(Account a: accs){
            acctIds.add(a.id);
        }
        TR_IntegrationManagerHandler.mergeCheck(acctIds);
        Test.stopTest(); 
    }
    
    @isTest static void testMergeClient_5() {
        Account absorbed1;
        Account absorbed2;
        
        for (Account acc : [Select Id, Dreamid__c From Account Where Dreamid__c='TEST893S0' or Dreamid__c='TEST892S0' or Dreamid__c='TEST895M0']){
            if (acc.Dreamid__c == 'TEST893S0') absorbed1 = acc;
            if (acc.Dreamid__c == 'TEST892S0') absorbed2 = acc;
        }
        
        List<Social_Media_Identifier__c> smis = new List<Social_Media_Identifier__c>();
        List<Exclusive_Experience__c> exps = new List<Exclusive_Experience__c>();

        // Create new CallingCampaign
        Calling_Campaign__c cc = new Calling_Campaign__c();
        cc.Client__c = absorbed1.Id;
        insert cc;
        
        // Create new Look 
        Look__c l = new Look__c();
        l.SKUs__c = 'T1234;T4567';
        insert l;
        
        // Create new Look Share 
        Look_Share__c ls = new Look_Share__c();
        ls.Look__c = l.Id;
        ls.Client__c = absorbed1.Id;
        ls.ExternalId__c = '123456789';
        
        
        
        //Create Social Media Identifiers
        Social_Media_Identifier__c smi1 = new Social_Media_Identifier__c();
        smi1.Client__c = absorbed1.Id;
        smi1.Social_Media_Type__c = 'Line';
        smi1.Social_Id__c = 'TEST003';
        smis.add(smi1);
        
        Social_Media_Identifier__c smi2 = new Social_Media_Identifier__c();
        smi2.Client__c = absorbed2.Id;
        smi2.Social_Media_Type__c = 'Line';
        smi2.Social_Id__c = 'TEST004';
        smis.add(smi2);
        
        
        
        // Create Exclusive Experience
        Exclusive_Experience__c xxpr1 = new Exclusive_Experience__c();
        xxpr1 = IC_TestFactory.createExclusiveExperience(absorbed1);
        xxpr1.Offer_Code__c = 'exclu_nba_1_2020';
        exps.add(xxpr1);        
        Exclusive_Experience__c xxpr2 = new Exclusive_Experience__c();
        xxpr2 = IC_TestFactory.createExclusiveExperience(absorbed2);
        xxpr2.Offer_Code__c = 'exclu_nba_1_2020';
        exps.add(xxpr2);
        
        Test.startTest();
        insert ls;
        insert smis;
        insert exps;
        List<Account> accs =[SELECT Id from account];
        Set<Id> acctIds = new Set<Id>();
        for(Account a: accs){
            acctIds.add(a.id);
        }
        TR_IntegrationManagerHandler.mergeCheck(acctIds);
        Test.stopTest(); 
        
    }
    
    @isTest static void testMergeClient_Order() {
        // Init
        Account absorbed1 = [Select Id, DreamIdMasterClient__c From Account Where Dreamid__c='TEST893S0'];
        
        Order__c ord = new Order__c();
        ord.Account__c = absorbed1.Id;
        ord.Name = 'Order123456789';
        ord.OrderNumber__c = 'Order123456789';
        ord.OrderDate__c = DateTime.now(); 
        ord.Source__c = 'KBRW';
        insert ord;
        
        // Test
        Test.startTest();
        List<Account> accs =[SELECT Id from account];
        Set<Id> acctIds = new Set<Id>();
        for(Account a: accs){
            acctIds.add(a.id);
        }
        TR_IntegrationManagerHandler.mergeCheck(acctIds);
        Test.stopTest(); 
        
        // Check
        List<Order__c> resultList = [SELECT Id, Account__c, Account__r.Dreamid__c FROM Order__c LIMIT 10];
        System.assertEquals(absorbed1.DreamIdMasterClient__c, resultList[0].Account__r.Dreamid__c);
        
        List<Account> accList = [SELECT Id, Dreamid__c FROM Account WHERE DreamId__c = 'TEST893S0'];
        System.assertEquals(0, accList.size());
    }
    
    @isTest static void testMergeEvolution() {
        // Init
        Account absorbed1 = [Select Id From Account Where Dreamid__c='TEST893S0'];
		Test.startTest();
        Alias__c alias = new Alias__c();
        alias.Comment__c = 'test';
		insert alias;
        
        Alias_Member__c aliasMember = new Alias_Member__c();
        aliasMember.client__c = absorbed1.Id;
        aliasMember.alias__c = alias.id;
        insert aliasMember;
        
        TR_MyLV_Diamond__c myLvD = new TR_MyLV_Diamond__c();
        myLvD.client__c = absorbed1.Id;
        insert myLvD;
        
        Family__c family = new Family__c();
        insert family;
        
        Family_Member__c fMember = new Family_Member__c();
        fMember.client__c = absorbed1.Id;
        fMember.Family__c = family.id;
        insert fMember;
        
        Tag__c tag = new Tag__c();
        tag.client__c = absorbed1.Id;
        insert tag;

        // Create Collectible_Wallet__c Order
        Collectible_Wallet__c wallet = new Collectible_Wallet__c(Client__c = absorbed1.Id ,Wallet_Id__c = 'TEST' );
        insert wallet;
        
        List<Account> accs =[SELECT Id, dreamid__c from account];
        Set<Id> acctIds = new Set<Id>();
        for(Account a: accs){
            acctIds.add(a.id);
        }
        
        // Test
        
        TR_IntegrationManagerHandler.mergeCheck(acctIds);
        Test.stopTest();
        
		        
        //Check
        List<Alias_Member__c> aliasMembers = [SELECT Id, Client__c FROM Alias_Member__c where client__r.Dreamid__c = 'TEST894M0'];
        System.assertEquals(1, aliasMembers.size());
        List<TR_MyLV_Diamond__c> myLvDs = [SELECT Id, Client__c FROM TR_MyLV_Diamond__c where client__r.Dreamid__c = 'TEST894M0'];
        System.assertEquals(1, myLvDs.size());
        List<Family_Member__c> fMembers = [SELECT Id, Client__c FROM Family_Member__c where client__r.Dreamid__c = 'TEST894M0'];
        System.assertEquals(1, fMembers.size());

         
    }
    
    @isTest static void testMergeEvolution2() {
        // Init
        Account absorbed1 = [Select Id From Account Where Dreamid__c='TEST893S0'];

        Tag__c tag = new Tag__c();
        tag.client__c = absorbed1.Id;
        insert tag;

        // Create Collectible_Wallet__c Order
        Collectible_Wallet__c wallet = new Collectible_Wallet__c(Client__c = absorbed1.Id ,Wallet_Id__c = 'TEST' );
        insert wallet;
        
        List<Account> accs =[SELECT Id, dreamid__c from account];
        Set<Id> acctIds = new Set<Id>();
        for(Account a: accs){
            acctIds.add(a.id);
        }
        
        // Test
        Test.startTest();
        TR_IntegrationManagerHandler.mergeCheck(acctIds);
        Test.stopTest();
        
		        
        //Check
        List<Tag__c> tags = [SELECT Id, Client__c FROM Tag__c where client__r.Dreamid__c = 'TEST894M0'];
        System.assertEquals(1, tags.size());
        List<Collectible_Wallet__c> wallets = [SELECT Id, Client__c FROM Collectible_Wallet__c where client__r.Dreamid__c = 'TEST894M0'];
        System.assertEquals(1, wallets.size());

         
    }
	// LVCLUB (CLUBMEMBERSHIP / BADGECATALOG / EXPERIENCE)  
    @isTest static void TestLVClubMerge_1() {
        // Init
        Account absorbed1 = [Select Id, Dreamid__c From Account Where Dreamid__c='TEST893S0'];
        
        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        
        Club_MemberShip__c clubM2 = new Club_MemberShip__c(
            clientId__c = absorbed1.Id,
            dreamId__c = absorbed1.Dreamid__c,
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = absorbed1.DREAMID__c + '_' + clubSneakers.Name
        );
        insert clubM2;
        
        Test.startTest();
        List<Account> accs =[SELECT Id from account];
        Set<Id> acctIds = new Set<Id>();
        for(Account a: accs){
            acctIds.add(a.id);
        }
        TR_IntegrationManagerHandler.mergeCheck(acctIds);
        Test.stopTest();
        		        
       
        // Check
        List<Club_MemberShip__c> clubs = [SELECT Id, clientId__c FROM Club_MemberShip__c where clientId__r.Dreamid__c = 'TEST894M0'];
        System.assertEquals(1, clubs.size());

    } 
    
    @isTest static void TestLVClubMerge_2() {
        // Init
        List<Club_MemberShip__c> clubs = new List<Club_MemberShip__c>();
        Account absorbed1;
        Account master;

        for (Account acc : [Select Id, Dreamid__c From Account Where Dreamid__c='TEST893S0' or Dreamid__c='TEST894M0']){
            if (acc.Dreamid__c == 'TEST893S0') absorbed1 = acc;
            if (acc.Dreamid__c == 'TEST894M0') master = acc;
        }
        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        
        Club_MemberShip__c clubM1 = new Club_MemberShip__c(
            clientId__c = master.Id,
            dreamId__c = master.Dreamid__c,
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = master.DREAMID__c + '_' + clubSneakers.Name
        );
        clubs.add(clubM1);
            
        Club_MemberShip__c clubM2 = new Club_MemberShip__c(
            clientId__c = absorbed1.Id,
            dreamId__c = absorbed1.Dreamid__c,
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = absorbed1.DREAMID__c + '_' + clubSneakers.Name
        );
        clubs.add(clubM2);
        
        Test.startTest();
        insert clubs;
        List<Account> accs =[SELECT Id from account];
        Set<Id> acctIds = new Set<Id>();
        for(Account a: accs){
            acctIds.add(a.id);
        }
        TR_IntegrationManagerHandler.mergeCheck(acctIds);
        Test.stopTest(); 
        		        
       
        // Check
        List<Club_MemberShip__c> clubs1 = [SELECT Id, clientId__c FROM Club_MemberShip__c where clientId__r.Dreamid__c = 'TEST894M0'];
        System.assertEquals(1, clubs1.size());
        List<Club_MemberShip__c> clubs0 = [SELECT Id, clientId__c FROM Club_MemberShip__c where clientId__r.Dreamid__c = 'TEST893S0'];
        System.assertEquals(0, clubs0.size());

    }
     
    @isTest static void TestLVClubMerge_3() {
        List<Club_MemberShip__c> clubs = new List<Club_MemberShip__c>();
        // Init
        Account absorbed1;
        Account master;
        Account random;

        for (Account acc : [Select Id, Dreamid__c From Account Where Dreamid__c='TEST893S0' or Dreamid__c='TEST894M0' or Dreamid__c='TEST895M0']){
            if (acc.Dreamid__c == 'TEST893S0') absorbed1 = acc;
            if (acc.Dreamid__c == 'TEST894M0') master = acc;
            if (acc.Dreamid__c == 'TEST895M0') random = acc;
        }
        
        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        
        Club_MemberShip__c clubM1 = new Club_MemberShip__c(
            clientId__c = master.Id,
            dreamId__c = master.Dreamid__c,
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = master.DREAMID__c + '_' + clubSneakers.Name
        );
        clubs.add(clubM1);
            
        Club_MemberShip__c clubM2 = new Club_MemberShip__c(
            clientId__c = absorbed1.Id,
            dreamId__c = absorbed1.Dreamid__c,
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = absorbed1.DREAMID__c + '_' + clubSneakers.Name
        );
        clubs.add(clubM2);
        
        Club_MemberShip__c clubM3 = new Club_MemberShip__c(
            clientId__c = random.Id,
            dreamId__c = random.Dreamid__c,
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = random.DREAMID__c + '_' + clubSneakers.Name
        );
        clubs.add(clubM3);
     
        Test.startTest();
        insert clubs;
        Favorite_Club_Member__c favorite = new Favorite_Club_Member__c(
            Name = 'Test',
            clubMemberId__c = clubM2.Id,
            favoriteClubMemberId__c = clubM3.Id
        );
        insert favorite;
        List<Account> accs =[SELECT Id from account];
        Set<Id> acctIds = new Set<Id>();
        for(Account a: accs){
            acctIds.add(a.id);
        }
        TR_IntegrationManagerHandler.mergeCheck(acctIds);
        Test.stopTest();
        		        
       
        // Check
        List<Favorite_Club_Member__c> clubss = [SELECT Id FROM Favorite_Club_Member__c];
        System.assertEquals(1, clubss.size());

    }
    
    @isTest static void TestLVClubMerge_4() {
        List<Club_MemberShip__c> clubs = new List<Club_MemberShip__c>();
        List<Favorite_Club_Member__c> favorites = new List<Favorite_Club_Member__c>();
        // Init
        Account absorbed1;
        Account master;
        Account random;

        for (Account acc : [Select Id, Dreamid__c From Account Where Dreamid__c='TEST893S0' or Dreamid__c='TEST894M0' or Dreamid__c='TEST895M0']){
            if (acc.Dreamid__c == 'TEST893S0') absorbed1 = acc;
            if (acc.Dreamid__c == 'TEST894M0') master = acc;
            if (acc.Dreamid__c == 'TEST895M0') random = acc;
        }
        
        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        
        Club_MemberShip__c clubM1 = new Club_MemberShip__c(
            clientId__c = master.Id,
            dreamId__c = master.Dreamid__c,
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = master.DREAMID__c + '_' + clubSneakers.Name
        );
        clubs.add(clubM1);
            
        Club_MemberShip__c clubM2 = new Club_MemberShip__c(
            clientId__c = absorbed1.Id,
            dreamId__c = absorbed1.Dreamid__c,
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = absorbed1.DREAMID__c + '_' + clubSneakers.Name
        );
        clubs.add(clubM2);
        
        Club_MemberShip__c clubM3 = new Club_MemberShip__c(
            clientId__c = random.Id,
            dreamId__c = random.Dreamid__c,
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = random.DREAMID__c + '_' + clubSneakers.Name
        );
        clubs.add(clubM3);
     
        Test.startTest();
        insert clubs;
        Favorite_Club_Member__c favorite = new Favorite_Club_Member__c(
            Name = 'Test',
            clubMemberId__c = clubM2.Id,
            favoriteClubMemberId__c = clubM3.Id
        );
        favorites.add(favorite);
        
        Favorite_Club_Member__c favorite2 = new Favorite_Club_Member__c(
            Name = 'Test',
            clubMemberId__c = clubM1.Id,
            favoriteClubMemberId__c = clubM3.Id
        );
        favorites.add(favorite2);
        
        Favorite_Club_Member__c favorite3 = new Favorite_Club_Member__c(
            Name = 'Test',
            clubMemberId__c = clubM3.Id,
            favoriteClubMemberId__c = clubM2.Id
        );
        favorites.add(favorite3);
        
        insert favorites;
        List<Account> accs =[SELECT Id from account];
        Set<Id> acctIds = new Set<Id>();
        for(Account a: accs){
            acctIds.add(a.id);
        }
        TR_IntegrationManagerHandler.mergeCheck(acctIds);
        Test.stopTest();
        		        
       
        // Check
        List<Favorite_Club_Member__c> favTest = [SELECT Id FROM Favorite_Club_Member__c where clubMemberId__c =: clubM1.id];
        System.assertEquals(1, favTest.size());
        
        List<Favorite_Club_Member__c> favTest2 = [SELECT Id FROM Favorite_Club_Member__c where favoriteClubMemberId__c =: clubM1.id and clubMemberId__c =: clubM3.id];
        System.assertEquals(1, favTest.size());
        
        List<Favorite_Club_Member__c> favTests = [SELECT Id FROM Favorite_Club_Member__c where favoriteClubMemberId__c =: clubM1.id];
        System.assertEquals(1, favTests.size());

    }

    @isTest static void TestLVClubMerge_5() {
        // Init
        List<Badge_Catalog__c> catal = new List<Badge_Catalog__c>();
        List<Badge_Collection__c> colle = new List<Badge_Collection__c>();
        List<Club_MemberShip__c> clubs = new List<Club_MemberShip__c>();
        Account absorbed1;
        Account master;

        for (Account acc : [Select Id, Dreamid__c From Account Where Dreamid__c='TEST893S0' or Dreamid__c='TEST894M0']){
            if (acc.Dreamid__c == 'TEST893S0') absorbed1 = acc;
            if (acc.Dreamid__c == 'TEST894M0') master = acc;
        }
        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        

        
        Club_MemberShip__c clubM1 = new Club_MemberShip__c(
            clientId__c = master.Id,
            dreamId__c = master.Dreamid__c,
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = master.DREAMID__c + '_' + clubSneakers.Name
        );
        clubs.add(clubM1);
            
        Club_MemberShip__c clubM2 = new Club_MemberShip__c(
            clientId__c = absorbed1.Id,
            dreamId__c = absorbed1.Dreamid__c,
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = absorbed1.DREAMID__c + '_' + clubSneakers.Name
        );
        clubs.add(clubM2);
        
        Club_Season__c season = new Club_Season__c(
            Name = 'test',    
            SeasonNumber__c = 1,
            Club__c = clubSneakers.Id,
            StartDate__c = system.today(),
            EndDate__c = system.today()
        );
        insert season;
        
        Badge_Catalog__c badgeCatalog1 = new Badge_Catalog__c(
            Name = 'Test',
            badgeType__c = 'Global Engagement',
            BadgeSubType__c = 'In-Season',
            Club_Name__c = clubSneakers.Id,
            ClubSeason__c = season.Id
        );
        catal.add(badgeCatalog1);
        
        Badge_Catalog__c badgeCatalog2 = new Badge_Catalog__c(
            Name = 'Test2',
            badgeType__c = 'Global Engagement',
            BadgeSubType__c = 'In-Season',
            Club_Name__c = clubSneakers.Id,
            ClubSeason__c = season.Id
        );
        catal.add(badgeCatalog2);

        Test.startTest();
        insert clubs;
        insert catal;
        
        Badge_Collection__c badgeCollection1 = new Badge_Collection__c(
            Name = 'Test',
            badgeId__c = badgeCatalog1.Id,
            member_Id__c = clubM1.Id,
            badgeFlag__c = false,
            isFavorite__c = false
        );
        colle.add(badgeCollection1);
        
        Badge_Collection__c badgeCollection2 = new Badge_Collection__c(
            Name = 'Test',
            badgeId__c = badgeCatalog1.Id,
            member_Id__c = clubM2.Id,
            badgeFlag__c = true,
            isFavorite__c = true
        );
        colle.add(badgeCollection2);
        
        Badge_Collection__c badgeCollection3 = new Badge_Collection__c(
            Name = 'Test',
            badgeId__c = badgeCatalog2.Id,
            member_Id__c = clubM2.Id,
            badgeFlag__c = true,
            isFavorite__c = true
        );
                
        colle.add(badgeCollection3);
        insert colle;
        
        List<Account> accs =[SELECT Id from account];
        Set<Id> acctIds = new Set<Id>();
        for(Account a: accs){
            acctIds.add(a.id);
        }
        TR_IntegrationManagerHandler.mergeCheck(acctIds);
        Test.stopTest(); 
        		        
       
        // Check
        List<Badge_Collection__c> clubs1 = [SELECT Id FROM Badge_Collection__c where badgeFlag__c= true and isFavorite__c= true and member_Id__c =: clubM1.Id];
        System.assertEquals(2, clubs1.size());


    }

    @isTest static void TestLVClubMerge_6() {
        // Init
        List<Brand_Experience_Variation__c> expVar = new List<Brand_Experience_Variation__c>();
             List<Brand_Experience_Variation_Member__c> expVarMembers = new List<Brand_Experience_Variation_Member__c>();
        List<Club_MemberShip__c> clubs = new List<Club_MemberShip__c>();
        
        Account absorbed1;
        Account master;

        for (Account acc : [Select Id, Dreamid__c From Account Where Dreamid__c='TEST893S0' or Dreamid__c='TEST894M0']){
            if (acc.Dreamid__c == 'TEST893S0') absorbed1 = acc;
            if (acc.Dreamid__c == 'TEST894M0') master = acc;
        }        
        
        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        
        Club_MemberShip__c clubM1 = new Club_MemberShip__c(
            clientId__c = master.Id,
            dreamId__c = master.Dreamid__c,
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = master.DREAMID__c + '_' + clubSneakers.Name
        );
        clubs.add(clubM1);
            
        Club_MemberShip__c clubM2 = new Club_MemberShip__c(
            clientId__c = absorbed1.Id,
            dreamId__c = absorbed1.Dreamid__c,
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = absorbed1.DREAMID__c + '_' + clubSneakers.Name
        );
        clubs.add(clubM2);
        Test.startTest();

        insert clubs;
        
        Brand_Experience__c ex = new Brand_Experience__c(
            Name = 'test',
            Status__c = 'Ongoing',
            ClubName__c = clubSneakers.Id
        );

        insert ex;

        Brand_Experience_Variation__c exVar1 = new Brand_Experience_Variation__c(
            Brand_Experience__c = ex.Id,
            Name = 'test',
            Status__c = 'Preview',
            Type__c = 'Event',
            SubType__c = 'Digital',
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = system.today(),
            EndDateTime__c = system.today().addDays(10)
        );

        expVar.add(exVar1);
        
        Brand_Experience_Variation__c exVar2 = new Brand_Experience_Variation__c(
            Brand_Experience__c = ex.Id,
            Name = 'test',
            Status__c = 'Preview',
            Type__c = 'Event',
            SubType__c = 'Digital',
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = system.today(),
            EndDateTime__c = system.today().addDays(10)
        );

        expVar.add(exVar2);
        
        insert expVar;
        
        Brand_Experience_Variation_Member__c exMember1 = new Brand_Experience_Variation_Member__c(
            Brand_Experience_Variation__c = exVar1.Id,
            ClubMember__c = clubM1.Id,
            Client__c = master.Id,
            Name = 'test',
            Status__c = 'Not Registered',
            rsvpState__c = 'Not Registered'
        );
        expVarMembers.add(exMember1);
        
         Brand_Experience_Variation_Member__c exMember2 = new Brand_Experience_Variation_Member__c(
            Brand_Experience_Variation__c = exVar1.Id,
            ClubMember__c = clubM2.Id,
            Client__c = absorbed1.Id,
            Name = 'test',
            Status__c = 'Declined',
            rsvpState__c = 'Declined'
        );
        expVarMembers.add(exMember2);
        
        Brand_Experience_Variation_Member__c exMember3 = new Brand_Experience_Variation_Member__c(
            Brand_Experience_Variation__c = exVar2.Id,
            ClubMember__c = clubM2.Id,
            Client__c = absorbed1.Id,
            Name = 'test',
            Status__c = 'Registered',
            rsvpState__c = 'Registered'        
        );
        expVarMembers.add(exMember3);
        insert expVarMembers;
        
        List<Account> accs =[SELECT Id from account];
        Set<Id> acctIds = new Set<Id>();
        for(Account a: accs){
            acctIds.add(a.id);
        }
        TR_IntegrationManagerHandler.mergeCheck(acctIds);
        Test.stopTest();
        		        
       
        // Check
        List<Brand_Experience_Variation_Member__c> tests = [SELECT Id FROM Brand_Experience_Variation_Member__c where ClubMember__c =: clubM1.Id];
        System.assertEquals(2, tests.size());

    }
	
	
    
}