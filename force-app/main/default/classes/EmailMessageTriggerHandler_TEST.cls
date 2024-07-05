@isTest
public class EmailMessageTriggerHandler_TEST {

    /*@isTest
    public static void webform_Test() {
        EmailMessage email = new EmailMessage();
        email.FromAddress = Label.ICX_NoReplyEmail;
        email.ToAddress = 'queueTEST@contact.louisvuitton.com';

        String country = 'UNITED STATES';
        String language = 'en';
        String message = 'My name is Detective Mike Downing with the Forsyth County';
		String natureId = '17';
		String catId = '55';
        String emailClient = 'mjdowning@xxxxxxx.com';
        String firstname = 'Michael';
        String lastname = 'Downing';
        String civility = 'Mr';
        
        email.Subject = 'Louis Vuitton';
        email.TextBody = 'type:' + civility + '\n' +
            'first_name:' + firstname + '\n' +
            'last_name:' + lastname + '\n' +
            'email address:' + emailClient + '\n' +
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

        Test.startTest();
        insert email;
        Test.stopTest();
        
        List<EmailMessage> resultList = [SELECT Id, FromAddress FROM EmailMessage];
        System.assertEquals(1, resultList.size());
        
        System.assertEquals(emailClient, resultList.get(0).FromAddress);
    }*/

    @isTest
    public static void changeInboundEmailQueue_Test() {
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'whatever@email.com';
        
        // Current email should be @louisvuitton.com in the ICX_Queue__mdt records
        ICX_Queue__mdt queueEmailFrance = [SELECT CurrentEmail__c, TargetEmail__c FROM ICX_Queue__mdt WHERE DeveloperName = 'France'];
        email.ToAddress = 'test@test.com; ' + queueEmailFrance.CurrentEmail__c + '; another@email.com';
        
        email.Subject = 'Louis Vuitton TEST';
        email.TextBody = 'hello test';
        email.Incoming = true;


        Test.startTest();
        insert email;
        Test.stopTest();
        
        List<EmailMessage> resultList = [SELECT Id, ToAddress, ICX_ToAddress_InitialQueue__c FROM EmailMessage];
        System.assertEquals(1, resultList.size());
        
        System.assertEquals(queueEmailFrance.CurrentEmail__c, resultList.get(0).ICX_ToAddress_InitialQueue__c);
        System.assertEquals('test@test.com; ' + queueEmailFrance.TargetEmail__c + '; another@email.com', resultList.get(0).ToAddress);
    }

    @isTest
    public static void sendNotificationForResponseRemoteConsent_TEST() {


        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        Id caseRecordIdRemoteConsent = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Remote_Consent').getRecordTypeId();

        Case ca = ICX_TestFactory.createCase(acc.id);
        ca.RecordTypeId = caseRecordIdRemoteConsent;

        insert ca;


        EmailMessage email = new EmailMessage();
        email.FromAddress = 'whatever@email.com';
        
        // Current email should be @louisvuitton.com in the ICX_Queue__mdt records
        ICX_Queue__mdt queueEmailFrance = [SELECT CurrentEmail__c, TargetEmail__c FROM ICX_Queue__mdt WHERE DeveloperName = 'France'];
        email.ToAddress = queueEmailFrance.CurrentEmail__c;
        
        email.Subject = 'Louis Vuitton TEST';
        List<Messaging.RenderEmailTemplateBodyResult> renderResults = Messaging.renderEmailTemplate(null, ca.Id, new List<String>{'{!Case.Thread_Token}'});
        String reference = renderResults[0].getMergedBody();
        email.TextBody = 'hello test ' +reference;
        email.Incoming = true;
        email.RelatedToId = ca.Id;

        User systemUser =[SELECT Id FROM User WHERE Name='SYSTEM' LIMIT 1];
        Test.startTest();
        System.runAs(systemUser)
        {

            insert email;
        }
        Test.stopTest();
        
    }

    @isTest
    public static void sendNotificationForResponseClienteing_TEST(){
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        Id caseRecordIdClienteling = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Clienteling').getRecordTypeId();

        Case ca = ICX_TestFactory.createCase(acc.id);
        ca.RecordTypeId = caseRecordIdClienteling;

        insert ca;


        EmailMessage email = new EmailMessage();
        email.FromAddress = 'whatever@email.com';
        
        // Current email should be @louisvuitton.com in the ICX_Queue__mdt records
        ICX_Queue__mdt queueEmailFrance = [SELECT CurrentEmail__c, TargetEmail__c FROM ICX_Queue__mdt WHERE DeveloperName = 'France'];
        email.ToAddress = queueEmailFrance.CurrentEmail__c;
        
        email.Subject = 'Louis Vuitton TEST';
        List<Messaging.RenderEmailTemplateBodyResult> renderResults = Messaging.renderEmailTemplate(null, ca.Id, new List<String>{'{!Case.Thread_Token}'});
        String reference = renderResults[0].getMergedBody();
        email.TextBody = 'hello test ' +reference;
        email.Incoming = true;
        email.RelatedToId = ca.Id;

        User systemUser =[SELECT Id FROM User WHERE Name='SYSTEM' LIMIT 1];
        Test.startTest();
        System.runAs(systemUser)
        {

            insert email;
        }
        Test.stopTest();
    }

    @isTest
    public static void changeClientelingStatusToNewTest (){
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        Id caseRecordIdClienteling = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Clienteling').getRecordTypeId();

        Case ca = ICX_TestFactory.createCase(acc.id);
        ca.RecordTypeId = caseRecordIdClienteling;
        ca.Status = 'Pending';

        insert ca;

        EmailMessage email = new EmailMessage();
        email.Subject = 'Louis Vuitton TEST';
        List<Messaging.RenderEmailTemplateBodyResult> renderResults = Messaging.renderEmailTemplate(null, ca.Id, new List<String>{'{!Case.Thread_Token}'});
        String reference = renderResults[0].getMergedBody();
        email.TextBody = 'hello test ' +reference;
        email.Incoming = true;
        email.RelatedToId = ca.Id;

        User systemUser =[SELECT Id FROM User WHERE Name='SYSTEM' LIMIT 1];
        Test.startTest();
        System.runAs(systemUser)
        {

            insert email;
        }
        Test.stopTest();

        Case newCase = [SELECT Id, Status FROM Case WHERE Id =: ca.Id LIMIT 1 ] ;
        System.assertEquals('New', newCase.Status);

    }

    @isTest
    public static void changeClientelingStatusToPendingTest () {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        Id caseRecordIdClienteling = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Clienteling').getRecordTypeId();

        Case ca = ICX_TestFactory.createCase(acc.id);
        ca.RecordTypeId = caseRecordIdClienteling;
        ca.Status = 'New';

        insert ca;

        EmailMessage email = new EmailMessage();
        email.FromAddress = 'whatever@email.com';
        
        ICX_Queue__mdt queueEmailFrance = [SELECT CurrentEmail__c, TargetEmail__c FROM ICX_Queue__mdt WHERE DeveloperName = 'France'];
        email.ToAddress = 'test@test.com; ' + queueEmailFrance.CurrentEmail__c + '; another@email.com';
        
        email.Subject = 'Louis Vuitton TEST';
        email.TextBody = 'hello test';
        email.Incoming = false;
        email.RelatedToId = ca.Id;


        Test.startTest();
        insert email;
        Test.stopTest();

        Case newCase = [SELECT Id, Status FROM Case  WHERE Id =: ca.Id LIMIT 1] ;
        System.assertEquals('Pending', newCase.Status);
    }
}