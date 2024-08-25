@isTest
public class ICX_EmailSpam_TEST {

    private static Case createCaseAddress(String fromAddress) {
        Case email = ICX_TestFactory.createCase(null);
        email.SuppliedEmail = fromAddress;
        return email;
    }

    private static Case createCaseSubject(String subject) {
        Case email = ICX_TestFactory.createCase(null);
        email.Subject = subject;
        email.SuppliedEmail = 'valid@email.com';
        return email;
    }

    @isTest
    public static void checkSpam_AddressSpam_CreateCaseTest() {

        List<Case> emailList = new List<Case>();
        emailList.add(createCaseAddress('return@00pt.jp'));
        emailList.add(createCaseAddress('MAILERDAEMON@email.com'));
        emailList.add(createCaseAddress('talk-noreply@google.com'));
        emailList.add(createCaseAddress('messages-noreply@email.com'));
        emailList.add(createCaseAddress('whatever@louisvuittonmalletier.onmicrosoft.com'));
        emailList.add(createCaseAddress('reply@bounce.emstechno-ecm.com'));
        emailList.add(createCaseAddress('noreply@email.com'));
        emailList.add(createCaseAddress('postmaster@email.com'));
        emailList.add(createCaseAddress('mailer-daemon@email.com'));
        emailList.add(createCaseAddress('webmaster@naver.com'));
        emailList.add(createCaseAddress('naver-mailer@naver.com'));
        //emailList.add(createCaseAddress('mailer-daemon-mailer-daemon@lvmh-fashion.com'));

        Test.startTest();
        insert emailList;
        //ICX_EmailSpam.checkSpam(emailList);
        Test.stopTest();
        
        //List<EmailMessage> resultList = [SELECT Id, ICX_Spam__c FROM EmailMessage WHERE ICX_Spam__c = true];
        List<Case> resultList = [SELECT Id, Spam__c, SpamReason__c FROM Case WHERE Spam__c = true];
        System.assertEquals(emailList.size(), resultList.size());        
        System.assertEquals('Invalid Email', resultList.get(0).SpamReason__c);
    }

   /* @isTest
    public static void checkSpam_AddressSpam_NotCreateCaseTest() {
        
    }*/

    @isTest
    public static void checkSpam_AddressSpam_NotSpamTest() {
        List<Case> emailList = new List<Case>();
        emailList.add(createCaseAddress('valid@email.com'));
        emailList.add(createCaseAddress('firstname.lastname@louisvuitton.com'));
        emailList.add(createCaseAddress('username@hotmail.com'));
        emailList.add(createCaseAddress('username@gmail.com'));
        emailList.add(createCaseAddress('username@yahoo.com'));

        Test.startTest();
        insert emailList;
        //ICX_EmailSpam.checkSpam(emailList);
        Test.stopTest();
        
        //List<EmailMessage> resultList = [SELECT Id, ICX_Spam__c FROM EmailMessage WHERE ICX_Spam__c = false];
        //System.assertEquals(emailList.size(), resultList.size());        
        List<Case> resultList = [SELECT Id, Spam__c FROM Case WHERE Spam__c = false];
        System.assertEquals(emailList.size(), resultList.size());        
    }

    @isTest
    public static void checkSpam_SubjectSpam_CreateCaseTest() {
        List<Case> emailList = new List<Case>();
        emailList.add(createCaseSubject('Mail delivery failed'));
        emailList.add(createCaseSubject('MailSystemError'));
        emailList.add(createCaseSubject('AUTO RE:'));
        emailList.add(createCaseSubject('DeliveryFinalFailure'));
        emailList.add(createCaseSubject('assenzadallufficio'));
        emailList.add(createCaseSubject('Form submission from'));
        emailList.add(createCaseSubject('Absence'));
        emailList.add(createCaseSubject('OnMaternityLeave'));
        emailList.add(createCaseSubject('Automatic reply'));
        emailList.add(createCaseSubject('AUTO:'));
        emailList.add(createCaseSubject('DeliveryError'));
        emailList.add(createCaseSubject('YahooRespuesta'));
        emailList.add(createCaseSubject('Automatisch'));
        emailList.add(createCaseSubject('AbwesendIhre'));
        emailList.add(createCaseSubject('AutomaticMessage'));
        emailList.add(createCaseSubject('Message NOT DELIVERED'));
        emailList.add(createCaseSubject('MensajeAutomatico'));
        emailList.add(createCaseSubject('Vacation reply'));
        emailList.add(createCaseSubject('outoftheoffice'));
        emailList.add(createCaseSubject('DELIVERY FAILURE:'));
        emailList.add(createCaseSubject('ReponseAutomatique'));
        emailList.add(createCaseSubject('DELAY410'));
        emailList.add(createCaseSubject('AUTOREPLY'));
        emailList.add(createCaseSubject('InvitationToConnect'));
        emailList.add(createCaseSubject('UndeliveredMail'));
        emailList.add(createCaseSubject('AutomatedResponse'));
        emailList.add(createCaseSubject('SPAM'));
        emailList.add(createCaseSubject('Conversionfailure'));
        emailList.add(createCaseSubject('Address verification confirmed'));
        emailList.add(createCaseSubject('UndeliverableMail'));
        emailList.add(createCaseSubject('Absent'));
        emailList.add(createCaseSubject('Abwesenheitsmeldung'));
        emailList.add(createCaseSubject('out of the office'));
        emailList.add(createCaseSubject('Abwesenheitsnotiz'));
        emailList.add(createCaseSubject('Please stop using Exotic Skins'));
        emailList.add(createCaseSubject('IsOutOfTheOffice'));
        emailList.add(createCaseSubject('AUTOMATICO'));
        emailList.add(createCaseSubject('AutomaticResponse'));
        emailList.add(createCaseSubject('Autoresponder'));
        emailList.add(createCaseSubject('AutomaticReply'));
        emailList.add(createCaseSubject('abwsend'));
        emailList.add(createCaseSubject('EmailNoLongerInUse'));
        emailList.add(createCaseSubject('DeliveryDelayed'));
        emailList.add(createCaseSubject('Urlaubsabwesenheit'));
        emailList.add(createCaseSubject('OnLeave'));
        emailList.add(createCaseSubject('Quiero una moda sin crueldad'));
        emailList.add(createCaseSubject('failurenotice'));
        emailList.add(createCaseSubject('DeliveryReport'));
        emailList.add(createCaseSubject('RespostaAutomatica'));
        emailList.add(createCaseSubject('DeliveryNotification'));
        emailList.add(createCaseSubject('auto-response'));
        emailList.add(createCaseSubject('Absencedubureau'));
        emailList.add(createCaseSubject('ImOutOfTheOffice'));
        emailList.add(createCaseSubject('I want fashion without cruelty!'));
        emailList.add(createCaseSubject('Automaticka'));
        emailList.add(createCaseSubject('IamAwayFrom'));
        emailList.add(createCaseSubject('Maildeliveryfailedreturningmessagetosender'));
        emailList.add(createCaseSubject('YahooAutoResponse'));
        emailList.add(createCaseSubject('Returnedmail'));
        emailList.add(createCaseSubject('DeliveryFailure'));
        emailList.add(createCaseSubject('MensagemAutomatica'));
        emailList.add(createCaseSubject('Automated'));
        emailList.add(createCaseSubject('Ausencia'));
        emailList.add(createCaseSubject('YahooMessage'));
        emailList.add(createCaseSubject('RespuestaAutomatic'));
        emailList.add(createCaseSubject('DELAY400'));
        emailList.add(createCaseSubject('InvitoACollegarsi'));
        emailList.add(createCaseSubject('Mail delivery failed: returning message to sender'));
        emailList.add(createCaseSubject('JoinMyNetwork'));
        emailList.add(createCaseSubject('Autosvar'));
        emailList.add(createCaseSubject('autoodpowiedz'));
        emailList.add(createCaseSubject('JoinMeOn'));
        emailList.add(createCaseSubject('Away'));
        emailList.add(createCaseSubject('Your email requires verification'));
        emailList.add(createCaseSubject('ReponseEnCasDab'));
        emailList.add(createCaseSubject('Abwesend'));
        emailList.add(createCaseSubject('outofoffice'));
        emailList.add(createCaseSubject('DeliveryStatus'));
        emailList.add(createCaseSubject('Out of Office'));
        emailList.add(createCaseSubject('MessageDAbsence'));
        emailList.add(createCaseSubject('estabsent'));
        emailList.add(createCaseSubject('auto response'));
        emailList.add(createCaseSubject('OnVacation'));
        emailList.add(createCaseSubject('AUTOMATISK'));
        emailList.add(createCaseSubject('AutoNotify'));
        emailList.add(createCaseSubject('Ausente'));
        emailList.add(createCaseSubject('Abwesenheit'));
        emailList.add(createCaseSubject('DeliveryConfirmation'));
        emailList.add(createCaseSubject('LVMANTISPAM'));
        emailList.add(createCaseSubject('AUTORESPONSE'));

        Test.startTest();
        insert emailList;
        //ICX_EmailSpam.checkSpam(emailList);
        Test.stopTest();
        
        //List<EmailMessage> resultList = [SELECT Id, ICX_Spam__c FROM EmailMessage WHERE ICX_Spam__c = true];
        List<Case> resultList = [SELECT Id, Spam__c, SpamReason__c FROM Case WHERE Spam__c = true];
        System.assertEquals(emailList.size(), resultList.size());
        System.assertEquals('Invalid Subject', resultList.get(0).SpamReason__c);
    }

  /*  @isTest
    public static void checkSpam_SubjectSpam_NotCreateCaseTest() {
        
    }*/

    @isTest
    public static void checkSpam_SubjectSpam_NotSpamTest() {
        List<Case> emailList = new List<Case>();
        emailList.add(createCaseSubject('Need information'));
        emailList.add(createCaseSubject('Where is my order?'));

        Test.startTest();
        insert emailList;
        //ICX_EmailSpam.checkSpam(emailList);
        Test.stopTest();
        
        //List<EmailMessage> resultList = [SELECT Id, ICX_Spam__c FROM EmailMessage WHERE ICX_Spam__c = false];
        List<Case> resultList = [SELECT Id, Spam__c FROM Case WHERE Spam__c = false];
        System.assertEquals(emailList.size(), resultList.size());

    }

}