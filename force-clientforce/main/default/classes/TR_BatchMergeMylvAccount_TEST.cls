@isTest
private class TR_BatchMergeMylvAccount_TEST {
    
    Private static User user,user2,user3,user4;  
    Private static List<User> users = new List<User>();  
    Private static List<Account> accountsToUpdate = new List<Account>();  
    Private static List<TECH_Merge_Manager__c> techMrgManagers = new List<TECH_Merge_Manager__c>(); 
    
    @testSetup
    private static void setup(){
        
        //Specify the Custom Setting
        Transverse_Batchs_Setup__c setting = new Transverse_Batchs_Setup__c();
        setting.name = 'Batch Merge Mylv';
        setting.Limit__c = '100000';
        setting.Batch_Worker_Size__c = '50';
        INSERT setting;
        
        Identity_TestFactory.createSettings();
        
        String code = String.valueOf(Math.round(Math.random() * 100000));
        String password = 'HDtfqawdv5435!';
        List<Account> accounts = new List<Account>();          
        Account accMaster,accChild;
        
        // ####### ACCOUNTS ########
        // ##### Master #2
        Account account1;
        account1 = IC_TestFactory.createAccount();
        account1.Dreamid__c = '1111111111';
        account1.DreamIdMasterClient__c = '';
        account1.ToDelete__c = '0';
        account1.FirstName = 'DU#1';
        account1.lastName = 'DUJEAN#1';
        account1.PersonEmail =  code + 'marc@louisvuitton.com';
        accounts.add(account1);
        
        // ##### SLAVE #2
        Account account2;
        account2 = IC_TestFactory.createAccount();
        account2.Dreamid__c = '2222222222';
        account2.DreamIdMasterClient__c = '1111111111';
        account2.ToDelete__c = '1';
        account2.FirstName = 'CO#01';
        account2.lastName = 'COMPTE#01';
        account2.PersonEmail =  code + 'lisa@louisvuitton.com';
        accounts.add(account2);
        
        // ##### Master #2
        Account account3;
        account3 = IC_TestFactory.createAccount();
        account3.Dreamid__c = 'TEST200191';
        account3.DreamIdMasterClient__c = '';
        account3.ToDelete__c = '0';
        account3.FirstName = 'Mas#1';
        account3.lastName = 'Master#1';
        account3.PersonEmail = 'Master2@Master.com';
        accounts.add(account3);
        
        // ##### SLAVE #2
        Account account4;
        account4 = IC_TestFactory.createAccount();
        account4.Dreamid__c = 'TEST200192';
        account4.DreamIdMasterClient__c = 'TEST200191';
        account4.ToDelete__c = '1';
        account4.FirstName = 'Sla#01';
        account4.lastName = 'Slave#01';
        account4.PersonEmail = 'slave@slave.com';
        account4.Date_Identity__pc = Date.today();
        accounts.add(account4);
        
        // ##### Master #3
        Account account5;
        account5 = IC_TestFactory.createAccount();
        account5.Dreamid__c = 'TEST200193';
        account5.DreamIdMasterClient__c = '';
        account5.FirstName = 'Mas#3';
        account5.lastName = 'Master#3';
        account5.PersonEmail = 'Master2@Master.com';
        accounts.add(account5);
        
        // ##### SLAVE #3
        Account account6;
        account6 = IC_TestFactory.createAccount();
        account6.Dreamid__c = 'TEST200194';
        account6.DreamIdMasterClient__c = 'TEST200193';
        account6.FirstName = 'Sl#3';
        account6.lastName = 'Slave#3';
        account6.PersonEmail = 'slave2@5slave.com';
        account6.Date_Identity__pc = Date.today();
        accounts.add(account6); 
        INSERT accounts;
        
        //created Asset
        Asset ass= New Asset();
        ass.Name='TEST001';
        ass.AccountId=account6.Id;
        ass.Serial_Number__c='232323232323';
        INSERT ass;
        //get contactId
        Set<Id> accIds = New Set<Id>();
         accIds.add(account1.Id);
         accIds.add(account2.Id);
         accIds.add(account4.Id);
         accIds.add(account6.Id);
        List<Contact> conts = [SELECT id , AccountId  from Contact WHERE AccountId IN :  accIds];
        Map<String,String> mapContacts = new Map<String,String>();
        for(contact co :conts){
          mapContacts.put(co.AccountId,co.Id);  
        }
        user = createExternalIdentity(account1,mapContacts.get(account1.Id));
        users.add(user);
        user2 = createExternalIdentity(account2,mapContacts.get(account2.Id)); 
        users.add(user2);
        user3 = createExternalIdentity(account4,mapContacts.get(account4.Id)); 
        users.add(user3);
        user4 = createExternalIdentity(account6,mapContacts.get(account6.Id));
        users.add(user4);
        
        TECH_Merge_Manager__c techMrgManager = new TECH_Merge_Manager__c();
        techMrgManager.Master_DreamId__c = account1.DREAMID__c;
        techMrgManager.Master_SalesforceId__c = account1.Id;
        techMrgManager.Child_DreamId__c = account2.DREAMID__c;
        techMrgManager.Child_SalesforceId__c = account2.Id;
        techMrgManager.Done__c = false;
        techMrgManagers.add(techMrgManager);
        TECH_Merge_Manager__c techMrgManager2 = new TECH_Merge_Manager__c();
        techMrgManager2.Master_DreamId__c = account3.DREAMID__c;
        techMrgManager2.Master_SalesforceId__c = account3.Id;
        techMrgManager2.Child_DreamId__c = account4.DREAMID__c;
        techMrgManager2.Child_SalesforceId__c = account4.Id;
        techMrgManager2.Done__c = false;
        techMrgManagers.add(techMrgManager2);
        TECH_Merge_Manager__c techMrgManager3 = new TECH_Merge_Manager__c();
        techMrgManager3.Master_DreamId__c = account5.DREAMID__c;
        techMrgManager3.Master_SalesforceId__c = account5.Id;
        techMrgManager3.Child_DreamId__c = account6.DREAMID__c;
        techMrgManager3.Child_SalesforceId__c = account6.Id;
        techMrgManager3.Done__c = false;
        techMrgManagers.add(techMrgManager3);
        
        //Update Slave Account With MasterClientSFID
        account2.MasterClientSFID__c = account1.Id;
        accountsToUpdate.Add(account2);
        account4.MasterClientSFID__c = account3.Id;
        accountsToUpdate.Add(account4);
        account6.MasterClientSFID__c = account5.Id;
        account6.PersonEmail='test@test.com';
        accountsToUpdate.Add(account6);
        UPDATE(accountsToUpdate);
        INSERT(techMrgManagers);
        INSERT(users);
    }
    
    @isTest
    private static void batchTest(){
        Test.startTest();  
        String cronExpr = '0 0 23 L * ?';
        TR_BatchMergeMylvAccount MylvMerge = new TR_BatchMergeMylvAccount();
        String jobId = System.schedule('MergeTESTMYLV', cronExpr, MylvMerge);
        MylvMerge.execute(null);
        Test.stopTest();
        System.assertEquals(6, [SELECT COUNT() FROM Account], 'Accounts');
        System.assertEquals(3, [SELECT COUNT() FROM TECH_Merge_Manager__c where Done__c=true], 'TECH_Merge_Manager');
    }
    private static User createExternalIdentity(Account client,String contactId) {
        
        User identityUser = new User(
            
            // Identity Fields
            ProfileId = IDENTITY_Settings__c.getInstance().ProfileId__c,
            ContactId = contactId,
            
            // Identifier Fields
            Username = client.PersonEmail,
            Email = client.PersonEmail,
            MobilePhone = client.LoginPhone__pc,
            
            // Contact Fields
            Title = client.PersonTitle,
            LastName = client.LastName,
            FirstName = client.FirstName,
            Alias = client.FirstName,
            
            // Local Fields
            Country__c = client.PrimaryCountry__pc,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Paris'
        );
        
        // Don't send any welcome email
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = false;
        dlo.EmailHeader.triggerOtherEmail = false;
        identityUser.setOptions(dlo);
        return identityUser;
    }
}