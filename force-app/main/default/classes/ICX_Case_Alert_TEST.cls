@isTest
public class ICX_Case_Alert_TEST {

    @isTest
    public static void getCaseTest() {
        // First test 
        System.assertEquals(null, ICX_Case_Alert.getCase(null));
        
        // Last test
        Case email = ICX_TestFactory.createCase(null);
        insert email;

        Test.startTest();
        Case result = ICX_Case_Alert.getCase(email.Id);
        Test.stopTest();
        
        System.assertEquals(email.Id, result.Id);        
    }

    @isTest
    public static void getEmailsTest() {
        
        Case cas = ICX_TestFactory.createCase(null);
        insert cas;
            
        List<EmailMessage> emailList = new List<EmailMessage>();
        emailList.add(ICX_TestFactory.createEmailOnCase(cas.Id, 'fromAdd@fromAddress.com', 'toAdd@toAdd.com', true));
        emailList.add(ICX_TestFactory.createEmailOnCase(cas.Id, 'fromAdd@fromAddress.com', 'toAdd@toAdd.com', true));
        emailList.add(ICX_TestFactory.createEmailOnCase(cas.Id, 'fromAdd@fromAddress.com', 'toAdd@toAdd.com', false));
        insert emailList;
        
        Test.startTest();
        List<EmailMessage> resultList = ICX_Case_Alert.getEmails(cas.Id);
        Test.stopTest();
        
        System.assertEquals(3, resultList.size());
    }

	@isTest
    public static void getParentRecordId_Task() {
        Case cas = ICX_TestFactory.createCase(null);
        cas.Origin = 'Phone';
        insert cas;

        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        call.WhatId = cas.Id;
        insert call;

        Test.startTest();
        Id resultId = ICX_Case_Alert.getParentRecordId(cas.Id, 'Task');
        Test.stopTest();

        System.assertEquals(call.Id, resultId);
    }

	/*@isTest
    public static void getParentRecordId_LiveChatTranscript() {
        Case cas = ICX_TestFactory.createCase(null);
        cas.Origin = 'Chat';
        insert cas;

        LiveChatTranscript chat = ICX_TestFactory.createLiveChatTranscript();
        chat.CaseId = cas.Id;
        insert chat;

        Test.startTest();
        Id resultId = ICX_Case_Alert.getParentRecordId(cas.Id, 'LiveChatTranscript');
        Test.stopTest();

        System.assertEquals(chat.Id, resultId);
    }

	@isTest
    public static void getParentRecordId_MessagingSession() {
        Case cas = ICX_TestFactory.createCase(null);
        cas.Origin = 'Messaging';
        insert cas;

        MessagingSession mess = ICX_TestFactory.createMessagingSession();
        mess.CaseId = cas.Id;
        insert mess;

        Test.startTest();
        Id resultId = ICX_Case_Alert.getParentRecordId(cas.Id, 'MessagingSession');
        Test.stopTest();

        System.assertEquals(mess.Id, resultId);
    }*/

    @isTest
    public static void getLastReplyEmail() {
        
        Case cas = ICX_TestFactory.createCase(null);
        insert cas;
            
        EmailMessage msg = ICX_TestFactory.createEmailOnCase(cas.Id, 'fromAdd@fromAddress.com', 'toAdd@toAdd.com', false);
        insert msg;
        
        Test.startTest();
        EmailMessage result = ICX_Case_Alert.getLastReplyEmail(cas.Id);
        Test.stopTest();
        
        System.assert(msg != null);
        System.assertEquals(msg.Id, result.Id);
    }

    @isTest
    public static void getSourceEmailTest() {
        EmailMessage msg = ICX_TestFactory.createEmailOnCase(null, 'fromAdd@fromAddress.com', 'toAdd@toAdd.com', false);
        insert msg;
        
        Test.startTest();
        EmailMessage result = ICX_Case_Alert.getSourceEmail(msg.Id);
        Test.stopTest();
        
        System.assert(msg != null);
        System.assertEquals(msg.Id, result.Id);
    }

    @isTest
    public static void getRelatedFilesTest() {
        Case cas = ICX_TestFactory.createCase(null);
        insert cas;

        Test.startTest();
        List<ICX_Files.FileWrapper> resultList = ICX_Case_Alert.getRelatedFiles(cas.Id);
        Test.stopTest();
        
		// Assert not useful this method just call: ICX_Files.getRelatedFiles(recordId). ICX_Files_TEST should do the test
    }

}