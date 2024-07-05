@isTest
public class ICX_Case_Web2Case_TEST {
/*
    private static String buildDescription(String email, String lastname) {
        String country = 'UNITED STATES';
        String language = 'en';
        String message = 'My name is Detective Mike Downing with the Forsyth County' +
            'Sheriff&#39;s Office. I am investigating a fraud case where items were' +
            'purchased from your website. Please have legal team contact me at' +
            '678-513-xxxxx. If no answer please provide contact name and callback' +
            'number. thank you.';
		String natureId = '17';
		String catId = '55';
        //String email = 'mjdowning@xxxxxxx.com';
        String firstname = 'Michael';
        //String lastname = 'Downing';
        String civility = 'Mr';

        String description = 'type:' + civility + '\n' +
            'first_name:' + firstname + '\n' +
            'last_name:' + lastname + '\n' +
            'email address:' + email + '\n' +
            'address1:\n' +
            'city:\n' +
            'zip_code:\n' +
            'country:' + country + '\n' +
            'responseLanguage:' + language + '\n' +
            'message:' + message + '\n' +
            'kanaform:en\n' +
            'contactNatureKanaId:' + natureId + '\n' +
            'repositoryKey:US\n' +
            'contactCategoryKanaId:' + catId;

        return description;
    }
    
    @isTest
    public static void updateWebformList_WebformOkTest() {
        
        String email = 'mjdowning@xxxxxxx.com';
        String lastname = 'Downing';
        
        Case cas = ICX_TestFactory.createCase(null);
        // Automatic value from Salesforce when the Case is created from an email
        cas.Origin = 'Email';
        cas.SuppliedEmail = Label.ICX_NoReplyEmail;//email;
        cas.SuppliedName = 'Michael Downing';
        cas.Description = buildDescription(email, lastname);
        

        String email2 = 'mjuping@xxxxxxx.com';
        String lastname2 = 'Uping';
        
        Case cas2 = ICX_TestFactory.createCase(null);
        // Automatic value from Salesforce when the Case is created from an email
        cas2.Origin = 'Email';
        cas2.SuppliedEmail = Label.ICX_NoReplyEmail;//email2;
        cas2.SuppliedName = 'Michael Uping';
        cas2.Description = buildDescription(email2, lastname2);

        // Web-2-Case are created as SYSTEM user
        User systemUser = [SELECT id, Username, lastname, Country__c FROM user WHERE lastname = 'SYSTEM' AND profile.Name = 'System Administrator' LIMIT 1];
        cas.OwnerId = systemUser.Id;
        cas2.OwnerId = systemUser.Id;
        //insert cas;

        System.runAs(systemUser) {
            Test.startTest();
            //insert cas;
            //ICX_Case_Web2Case.updateWebformList(new List<Case>{cas});
            insert new List<Case> {cas, cas2};
            Test.stopTest();
        }

        List<Case> resultList = [SELECT Id, SuppliedEmail, Description, Origin, AccountId, Country__c, Type, Category__c FROM Case WHERE Account.Lastname = :lastname];
        System.assertEquals(1, resultList.size());
        Case result = resultList.get(0);
        System.debug('result=' + result);
        //System.assertEquals(country, result.Country__c);
        System.assertEquals(cas.Description, result.Description);
        System.assertEquals('Web', result.Origin);
        System.assertEquals(email, result.SuppliedEmail);

        List<Case> resultList2 = [SELECT Id, SuppliedEmail, Description, Origin, AccountId, Country__c, Type, Category__c FROM Case WHERE Account.Lastname = :lastname2];
        System.assertEquals(1, resultList2.size());
        Case result2 = resultList2.get(0);
        System.debug('result2=' + result2);
        //System.assertEquals(country, result.Country__c);
        System.assertEquals(cas2.Description, result2.Description);
        System.assertEquals('Web', result2.Origin);
        System.assertEquals(email2, result2.SuppliedEmail);
    }

    @isTest
    public static void isWebform_KoTest() {
        System.assertEquals(false, ICX_Case_Web2Case.isWebform('Hello'));
    }

    @isTest
    public static void updateWebformList_GovernorLimitTest() {
        
    }*/
}