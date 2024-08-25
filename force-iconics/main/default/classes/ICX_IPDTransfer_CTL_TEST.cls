@isTest
public class ICX_IPDTransfer_CTL_TEST {

    @isTest
    static void test_sendEmailToIPDAndCreateTask()
    {
        // create a case
        Case cas = ICX_TestFactory.createCase(null);
        cas.country__c = 'FRANCE';
        cas.origin = 'Email';
        insert cas;

        // create an EmailMessage
        EmailMessage em = ICX_TestFactory.createEmailOnCase(cas.id, 'fromadd@icxtesting.com', 'toadd@icxtesting.com', true);
        insert em;

        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;

        Attachment attach=new Attachment();   	
    	attach.Name ='image';
    	Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
    	attach.body = bodyBlob;
        attach.parentId = em.id;
        insert attach;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = cas.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;

        

        ApexPages.StandardController sc = new ApexPages.StandardController(cas);
        ICX_IPDTransfer_CTL ctrl = new ICX_IPDTransfer_CTL(sc);

        // run test
        Test.startTest();
      
        ctrl.sendEmailToIPDAndCreateTask();  
        ICX_IPDTransfer_CTL.sendEmailToIPD(cas.id);
        Test.stopTest();
        
        // check if case has been closed
        cas = [Select status from case where id =: cas.id];
        system.assertEquals('Closed', cas.status);
        
        // check if a task has been created with the expected subject
        List<task> t = [Select id from task where whatid =: cas.id and subject =: System.Label.ICX_IPD_TaskSubject];
        System.assertEquals(2, t.size());
    }

}