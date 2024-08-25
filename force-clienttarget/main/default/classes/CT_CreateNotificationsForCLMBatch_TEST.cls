@isTest
public with sharing class CT_CreateNotificationsForCLMBatch_TEST {
    @isTest
    public static void createNotificationsWithoutLanguageSettings_TEST() {
        List<String> membersList = createClientlistWithMembers();
        List<String> alreadyNotified = new List<String>();
        CT_CreateNotificationsForCLMBatch notificationsBatch = new CT_CreateNotificationsForCLMBatch(membersList, alreadyNotified);
        Database.executeBatch(notificationsBatch);
    }

    @isTest
    public static void createNotificationsForCLMBatch_TEST() {
        List<String> membersList = createClientlistWithMembers();
        createCountryLanguageSettings();
        List<String> alreadyNotified = new List<String>();
        CT_CreateNotificationsForCLMBatch notificationsBatch = new CT_CreateNotificationsForCLMBatch(membersList, alreadyNotified);
        Database.executeBatch(notificationsBatch);
    }

    public static List<String> createClientlistWithMembers() {
        User user = createUser();
        Account acc = createAccount(user.Id, '110592112', true);
        Account acc2 = createAccount(user.Id, '110592116', false);
        Account acc3 = createAccount(user.Id, '110592119', true);
        List<String> clientIdsList = new List<String>{acc.Id, acc2.Id, acc3.Id};
        List<Account> accList = [SELECT PersonContactId FROM Account WHERE Id in :clientIdsList];
        List<String> contactIdsList = new List<String>();

        for (Account a : accList) {
            contactIdsList.add(a.PersonContactId);
        }

        String commaSepIds = contactIdsList.size() > 0 ? String.join(contactIdsList, ';') : '';

        CLI_CliList__c clientList = new CLI_CliList__c(
            Name = 'Test',
            Active__c = true,
            ExpirationDate__c = date.today().addYears(1),
            Description__c = 'Test',
            Is_visible_by_CA__c = true,
            Typology__c = 'NBA Regular',
            Type__c = 'exclusive',
            Offer_Code__c = 'exclu_nba_1_2020',
            Show_In_Icon__c = true,
            TECH_LaunchAddMembersBatch__c = true,
            TECH_TempAccountIds__c = commaSepIds,
            TECH_CreatedFromTCLScreen__c = true,
            OwnerId = user.Id
        );    

        insert clientList;

        List<CLM_CliListMember__c> membersList = new List<CLM_CliListMember__c>();
        for (String id : contactIdsList) {
          CLM_CliListMember__c CLM = new CLM_CliListMember__c(
              ClientList__c = clientList.Id,
              Client__c = id
          );
          membersList.add(CLM);
        }

        insert membersList;

        List<String> clmIds = new List<String>();
        for (CLM_CliListMember__c clm : membersList) {
          clmIds.add(clm.Id);
        }
        return clmIds;
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

    public static Account createAccount(Id userId, String dreamId, Boolean withCountry) {
        Account acc = new Account(
            Firstname = 'test' + randomNumber(),
            LastName = 'test' + randomNumber(),
            PersonEmail = 'test' + dreamId + '@balink.net',
            OwnerId = userId,
            DREAMID__c = dreamId
        );

        if (withCountry) {
            acc.PreferredLanguage__pc = 'JPN';
            acc.AttachedStoreCountry__pc = 'JPN';
            acc.HomeAddressCountryCode__pc = 'JPN';
        }

        insert acc;
        return acc;
    }

    public static Integer randomNumber() {
        return Integer.valueof((Math.random() * 10));
    }


    public static String randomDreamId() {
      String dreamId = '';
      for (Integer i = 0; i < 8; i++) {
          dreamId += randomNumber();
      }
      return dreamId;
    }

    public static void createCountryLanguageSettings() {
        List<Country__c> countries = new List<Country__c>{
          new Country__c(
            Name = 'CHINA',
            tech_duplicate__c = 'China',
            Iso2Code__c = 'CN',
            Iso3Code__c = 'CHN'
          ),
          new Country__c(
            Name = 'JAPAN',
            tech_duplicate__c = 'Japan',
            Iso2Code__c = 'JP',
            Iso3Code__c = 'JPN'
          ),
          new Country__c(
            Name = 'KOREA',
            tech_duplicate__c = 'Korea',
            Iso2Code__c = 'KR',
            Iso3Code__c = 'KOR'
          ),
          new Country__c(
            Name = 'RUSSIA',
            tech_duplicate__c = 'Russia',
            Iso2Code__c = 'RU',
            Iso3Code__c = 'RUS'
          )
        };
        insert countries;
    
        List<Language2__c> languages = new List<Language2__c>{
          new Language2__c(
            Name = 'CHINESE',
            Iso2Code__c = 'ZH',
            Iso3Code__c = 'ZHO'
          ),
          new Language2__c(
            Name = 'JAPANESE',
            Iso2Code__c = 'JA',
            Iso3Code__c = 'JPN'
          ),
          new Language2__c(
            Name = 'KOREAN',
            Iso2Code__c = 'KO',
            Iso3Code__c = 'KOR'
          ),
          new Language2__c(
            Name = 'RUSSIAN',
            Iso2Code__c = 'RU',
            Iso3Code__c = 'RUS'
          )
        };
        insert languages;
    
        List<Country__c> c = [
          SELECT Id, Name
          FROM Country__c
          WHERE Name IN ('CHINA', 'JAPAN', 'KOREA', 'RUSSIA')
        ];
        List<Language2__c> l = [
          SELECT Id, Name
          FROM Language2__c
          WHERE Name IN ('CHINESE', 'JAPANESE', 'KOREAN', 'RUSSIAN')
        ];
    
        List<CountryLanguage__c> cl = new List<CountryLanguage__c>{
          new CountryLanguage__c(
            Name = 'Chinese China',
            ATG_Locale__c = 'zhs-cn',
            Salesforce_Locale__c = 'zh_CN',
            Country__c = c[0].Id,
            Language__c = l[0].Id,
            Default__c = true
          ),
          new CountryLanguage__c(
            Name = 'Japanese Japan',
            ATG_Locale__c = 'jpn-jp',
            Salesforce_Locale__c = 'ja_JP',
            Country__c = c[1].Id,
            Language__c = l[1].Id,
            Default__c = true
          ),
          new CountryLanguage__c(
            Name = 'Korean Korea',
            ATG_Locale__c = 'kor-kr',
            Salesforce_Locale__c = 'ko_KR',
            Country__c = c[2].Id,
            Language__c = l[2].Id,
            
            Default__c = true
          ),
          new CountryLanguage__c(
            Name = 'Russian Russia',
            ATG_Locale__c = 'rus-ru',
            Salesforce_Locale__c = 'ru_RU',
            Country__c = c[3].Id,
            Language__c = l[3].Id,
            Default__c = true
          )
        };
        insert cl;
      }
}