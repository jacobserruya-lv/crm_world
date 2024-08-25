@isTest
private class AttachmentTrigger_Test {
    
	static testMethod void testSetProspectStoreInfo()
    {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        // create an EmailMessage
        EmailMessage em = new EmailMessage();
        em.Subject = 'Test';
        insert em;
        
        Attachment attachment = new Attachment(Name='An attachment',body=blob.valueof('b'),parentId=em.Id);
        insert attachment;
        System.assertEquals('An attachment', attachment.Name); 
    }
}