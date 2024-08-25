public class IDENTITY_TestFactory {
    
    public static Account createAccount(String firstName, String lastName, String email, String localPhone, String countryCode, Boolean toInsert) {
        Account a = new Account(
        LastName = lastName,
        FirstName = firstName,
        PersonEmail = email,  
        LocalLoginPhone__pc = localPhone,
        LoginPhoneCallingCode__pc = countryCode,
        LocalMobilePhone__pc = localPhone,
        MobilePhoneCountryCallingCode__pc = countryCode,
        PrimaryCountry__pc = 'FRANCE',
        Salutation = '02',
        HomeAddressCountryCode__pc = 'FRA'
        );
        
        if(!String.isEmpty(localPhone) && !String.isEmpty(countryCode)){
            a.PersonMobilePhone = '+' + countryCode + localPhone;
            a.MobilePhoneCountryCode__pc = 'FR';
        }
        
        if(toInsert){
            insert a;
        }
        return a;
    }
    
    public static User createUser(String firstName, String lastName, String email, String localPhone, String countryCode) {
        Account account = Identity_TestFactory.createAccount(firstName, lastname, email, localPhone, countryCode, true);
        User user = Identity_Utils.createMylvClient(account, 'HDtfqawdv5435!');
        return user;
    }
    
    public static User createSimpleUser(String firstName, String lastName, String email, String phone) {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User user = new User(LastName = lastName,
        FirstName=firstName,
        Alias = IDENTITY_Utils.getAlias(firstName, lastName),
        Email = email,
        TECH_Email__c = email,
        MobilePhone = phone,
        TECH_MobilePhone__c = phone,
        Username = email,
        ProfileId = profileId.id,
        TimeZoneSidKey = 'GMT',
        LanguageLocaleKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LocaleSidKey = 'en_US',
        IsActive = true
        );
        insert user;
        return user;
    }
    
    public static void createSettings() {
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'Identity User' and UserLicense.name ='External Identity'];
        List<User> users = [SELECT Id FROM User WHERE Name LIKE '%GUEST%' LIMIT 1];
        
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = profiles.size() > 0 ? profiles[0].Id : ''
        );
        
        insert new IDENTITY_Settings__c(
        Username_Suffix__c = '@louisvuitton.com',
            ProfileId__c = !profiles.isEmpty() ? profiles[0].Id : '',
            Integration_User_Id__c = UserInfo.getUserId(),
            Guest_User_Id__c = !users.isEmpty() ? users[0].Id : '',
            Language_Country_Values__c = 'eng-e1 / fra-fr',
            Language_Country_Values_2__c = 'eng-in',
            Default_Language_Country_Parameter__c = 'eng-e1',
            Default_Origin_Parameter__c = 'mylv',
            Community_URL__c = 'https://integ2-louisvuitton.cs70.force.com',
            AES_Key__c = 'iKhco6t8RnE0DaDcTzG3XQ==',
            Deactivate_User_After__c = 365,
            Activate_New_Design__c = true,
            Password_Maxlength__c = 100
        );
        
        insert new IDENTITY_Registration_Form_Settings__c(
            Code_Validity_Time__c = 30,
            Default_Code__c = '123',
            Default_To_Email_Address__c = 'test@test.com',
            Sent_Email_Limit__c = 2,
            Sent_SMS_Limit__c = 2
        );
    }
    
    public static void createCountryLanguageSettings() {
        List<Country__c> countries = new List<Country__c>{
            new Country__c(Name='CHINA',    tech_duplicate__c = 'China',    Iso2Code__c = 'CN', Iso3Code__c = 'CHN'),
            new Country__c(Name='JAPAN',    tech_duplicate__c = 'Japan',    Iso2Code__c = 'JP', Iso3Code__c = 'JPN'),
            new Country__c(Name='KOREA',    tech_duplicate__c = 'Korea',    Iso2Code__c = 'KR', Iso3Code__c = 'KOR'),
            new Country__c(Name='RUSSIA',   tech_duplicate__c = 'Russia',   Iso2Code__c = 'RU', Iso3Code__c = 'RUS'),
            new Country__c(Name='BELGIUM',  tech_duplicate__c = 'Belgium',  Iso2Code__c = 'BE', Iso3Code__c = 'BEL')
        };
        insert countries;
        
        List<Language2__c> languages = new List<Language2__c>{
            new Language2__c(Name='CHINESE', Iso2Code__c = 'ZH', Iso3Code__c = 'ZHO'),
            new Language2__c(Name='JAPANESE', Iso2Code__c = 'JA', Iso3Code__c = 'JPN'),
            new Language2__c(Name='KOREAN', Iso2Code__c = 'KO', Iso3Code__c = 'KOR'),
            new Language2__c(Name='RUSSIAN', Iso2Code__c = 'RU', Iso3Code__c = 'RUS'),
            new Language2__c(Name='FRENCH', Iso2Code__c = 'FR', Iso3Code__c = 'FRA')
        };
        insert languages;
        
        List<CountryLanguage__c> countryLanguages = new List<CountryLanguage__c>{
            new CountryLanguage__c(Name = 'Chinese China',      ATG_Locale__c = 'zhs-cn', Salesforce_Locale__c = 'zh_CN', Country__c = countries[0].Id, Language__c = languages[0].Id, Default__c = true, Dispatch_Country__c = '', LVConnect_CS_PhoneNumber__c = '(55) 11 30 60 50 99'),
            new CountryLanguage__c(Name = 'Japanese Japan',     ATG_Locale__c = 'jpn-jp', Salesforce_Locale__c = 'ja_JP', Country__c = countries[1].Id, Language__c = languages[1].Id, Default__c = true, Dispatch_Country__c = ''),
            new CountryLanguage__c(Name = 'Korean Korea',       ATG_Locale__c = 'kor-kr', Salesforce_Locale__c = 'ko_KR', Country__c = countries[2].Id, Language__c = languages[2].Id, Default__c = true, Dispatch_Country__c = ''),
            new CountryLanguage__c(Name = 'Russian Russia',     ATG_Locale__c = 'rus-ru', Salesforce_Locale__c = 'ru_RU', Country__c = countries[3].Id, Language__c = languages[3].Id, Default__c = true, Dispatch_Country__c = ''),
            new CountryLanguage__c(Name = 'Belgium Belgium',    ATG_Locale__c = 'eng-nl', Salesforce_Locale__c = 'fr_FR', Country__c = countries[4].Id, Language__c = languages[4].Id, Default__c = true, Dispatch_Country__c = 'BE', LVConnect_CS_PhoneNumber__c = '800 586 966')
        };
        insert countryLanguages;
    }
    
    public static void createCountryLanguageMiddleEastSettings() {
        List<Country__c> countries = new List<Country__c>{
            new Country__c(Name='UNITED ARAB EMIRATES', tech_duplicate__c = 'UNITED ARAB EMIRATES', Iso2Code__c = 'AE', Iso3Code__c = 'ARE'),
            new Country__c(Name='SAUDI ARABIA', tech_duplicate__c = 'Saudi_Arabia', Iso2Code__c = 'SA', Iso3Code__c = 'SAU')
        };
        insert countries;
        
        List<Language2__c> languages = new List<Language2__c>{
            new Language2__c(Name='ARABIC', Iso2Code__c = 'AR', Iso3Code__c = 'ARA')
        };
        insert languages;
        
        List<CountryLanguage__c> countryLanguages = new List<CountryLanguage__c>{
            new CountryLanguage__c(
            Name = 'a2R0H000003I4So',
                ATG_Locale__c = 'ara-ae',
                Salesforce_Locale__c = 'ar_AE',
                Country__c = countries[0].Id,
                Language__c = languages[0].Id,
                Default__c = true,
                Dispatch_Country__c = '',
                LVConnect_CS_PhoneNumber__c = '(971) 800 VUITTON /(971) 800 884 8866'
            ),
            new CountryLanguage__c(
                Name = 'a2R0H000003I4T9',
                ATG_Locale__c = 'ara-ae',
                Salesforce_Locale__c = 'ar_SA',
                Country__c = countries[1].Id,
                Language__c = languages[0].Id,
                Default__c = false,
                Dispatch_Country__c = 'SA',
                LVConnect_CS_PhoneNumber__c = '(966) 11 211 2705',
                Footer_Config__c = ''
                    +'{'
                    + '"customerServiceMessage": "يتوفر مستشار العميل على مدار الساعة طوال أيام الأسبوع من خلال الاتصال بنا على<span style=\'display:block; direction:ltr !important\'>+966 800 850 0919.</span>يمكنك أيضًا الدردشة أو مراسلتنا عبر البريد الإلكتروني",'
                    + '"displayUserRightsLogo": true'
                    + '}'
            )
        };
        insert countryLanguages;
    }
    
    public static void createCustomEmailLogs() {
        List<Logs__c> emailLogs = new List<Logs__c>{
            new Logs__c(Record_Id__c='test5@test.com',  Apex_Class__c = 'IDENTITY_Registration_CTRL',  Level__c = 'INFO', Message__c = 'EMAIL SENT'),
            new Logs__c(Record_Id__c='test5@test.com',  Apex_Class__c = 'IDENTITY_Registration_CTRL',  Level__c = 'INFO', Message__c = 'EMAIL SENT'),
            new Logs__c(Record_Id__c='test5@test.com',  Apex_Class__c = 'IDENTITY_Registration_CTRL',  Level__c = 'INFO', Message__c = 'EMAIL SENT'),
            new Logs__c(Record_Id__c='test6@test.com',  Apex_Class__c = 'IDENTITY_Registration_CTRL',  Level__c = 'INFO', Message__c = 'EMAIL SENT'),
            new Logs__c(Record_Id__c='test6@test.com',  Apex_Class__c = 'IDENTITY_Registration_CTRL',  Level__c = 'INFO', Message__c = 'EMAIL SENT'),
            new Logs__c(Record_Id__c='test7@test.com',  Apex_Class__c = 'IDENTITY_Registration_CTRL',  Level__c = 'INFO', Message__c = 'EMAIL SENT'),
            new Logs__c(Record_Id__c='test8@test.com',  Apex_Class__c = 'IDENTITY_Registration_CTRL',  Level__c = 'INFO', Message__c = 'EMAIL SENT'),
            new Logs__c(Record_Id__c='test9@test.com',  Apex_Class__c = 'IDENTITY_Registration_CTRL',  Level__c = 'INFO', Message__c = 'EMAIL SENT')
        };
        
        insert emailLogs;
    }
}