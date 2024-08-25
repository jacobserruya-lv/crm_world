@isTest
public class ICX_Email_QuickActionDefaults_TEST {

    
    @isTest
    public static void getTemplateIdHelper_OKTest() {
        
        // init
        ICX_Queue__mdt queueMdt = [SELECT Id, EmailTemplateDeveloperName__c, TargetEmail__c FROM ICX_Queue__mdt WHERE QueueDeveloperName__c = 'France'];
        String queueDevName = 'France';

        Case cas = ICX_TestFactory.createCase(null);
        cas.Origin = 'Email';
        cas.TECH_Queue__c = queueDevName;
        insert cas;

		// Test
        ICX_Email_QuickActionDefaults quickAction = new ICX_Email_QuickActionDefaults();
        Test.startTest();
        String templateId = quickAction.getTemplateIdHelper(queueMdt,null,false);
        Test.stopTest();
        
        // Check
        String resultId = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: queueMdt.EmailTemplateDeveloperName__c].Id;
        System.assertEquals(resultId, templateId);
    }
    
    @isTest
    public static void getTemplateIdHelperKO_Test() {
        ICX_Email_QuickActionDefaults quickAction = new ICX_Email_QuickActionDefaults();
        System.assert(quickAction.getTemplateIdHelper(null,null,false) == null);
    }
    
    @isTest
    public static void getEmailTemplateDeveloperName_Default_test() {
        String defaultEmailTemplateDevName = 'AnyTemplate_Dev';

        // Initi
        IconicsSettings__c settings = new IconicsSettings__c();
        settings.DefaultEmailTemplateDevName__c = defaultEmailTemplateDevName;
        insert settings;
        
        // Test and check
        ICX_Email_QuickActionDefaults quickAction = new ICX_Email_QuickActionDefaults();
        System.assertEquals(defaultEmailTemplateDevName, quickAction.getEmailTemplateDeveloperName(null,null,false));        
    }

    @isTest
    public static void onInitDefaultsTest() {
        
        // init
        Case cas = ICX_TestFactory.createCase(null);
        cas.Origin = 'Email';
        cas.TECH_Queue__c = 'France';
        insert cas;
        
        List<QuickAction.QuickActionDefaults> defaults = new List<QuickAction.QuickActionDefaults>();
        
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = Test.newSendEmailQuickActionDefaults(cas.Id, null);
        defaults.add(sendEmailDefaults);

        // Test
        Test.startTest();
        ICX_Email_QuickActionDefaults quickAction = new ICX_Email_QuickActionDefaults();
        quickAction.onInitDefaults(defaults);
        Test.stopTest();

        // Check
        // can't check the email template used, difficult to find a correct
        //String expectedEmailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'France'].Id;
        //sendEmailDefaults.

        // https://salesforce.stackexchange.com/questions/102338/test-class-for-quickaction-quickactiondefaultshandler/103151
        /*String defaultsAsJSON = '[{"targetSObject":{"attributes":{"type":"EmailMessage"},"TextBody":"",'
            + '"FromName":"Test","FromAddress":"test@example.com","HtmlBody":"<html><body></body></html>","BccAddress":"test@example.com",'
            + '"CcAddress":"","ToAddress":"test@example.com","Subject":"Testing"},"contextId":"' + cas.Id + '","actionType":"Email",'
            + '"actionName":"Case.Email","fromAddressList":["salesforce@test.com"]}]';

        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
            (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(defaultsAsJSON, List<QuickAction.SendEmailQuickActionDefaults>.class);*/

    }

}