@isTest
public with sharing class CT_UpdateClientsQueue_TEST {
    @isTest
    public static void createClientListBatch_TEST() {
        User user = createUser();
        User user2 = createUser();
        Account acc = createAccount(user.Id, '110592123');
        Account acc2 = createAccount(user.Id, '110592127');
        Account acc3 = createAccount(user.Id, '11279443');

        List<Account> accList = new List<Account>{acc, acc2, acc3};
        for (Account a : accList) {
            a.OwnerId = user2.Id;
        }
        
        CT_UpdateClientsQueue updateClientsQueue = new CT_UpdateClientsQueue(accList);
        Id jobId = System.enqueueJob(updateClientsQueue);
    }
    
    public static User createUser() {
        ApexPages.standardController controller = new ApexPages.standardController(new Account());
        Global_ClientViewDispatch_VFCx extension = new Global_ClientViewDispatch_VFCx(controller);
        Account currentAccount = extension.currentAccount;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'STAR_Corporate'];
        User user = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id,
				TimeZoneSidKey = 'America/Los_Angeles', UserName = randomNumber() + 'adminUser@testlv.com');
        insert user;
        return user;
    }

    public static Account createAccount(Id userId, String dreamId) {
        Account acc = new Account(
            Firstname = 'test' + randomNumber(),
            LastName = 'test' + randomNumber(),
            PersonEmail = 'test' + dreamId + '@balink.net',
            OwnerId = userId,
            DREAMID__c = dreamId
        );
        insert acc;  
        return acc;
    }

    public static Integer randomNumber() {
        return Integer.valueof((Math.random() * 10000));
    }
}