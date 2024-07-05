@isTest
private class MIY_Emails_Files_Test  {

	private static testmethod void TestMail(){
		Opportunity o = [Select Id From Opportunity limit 1];
		List<EmailMessage> emails = MIY_Emails.getEmails(o.Id);
	}

	private static testmethod void TestFiles(){
		Opportunity o = [Select Id From Opportunity limit 1];
		MIY_Files.getRelatedFiles(o.Id);
	}

	@TestSetup
	private static void init(){
		Account pros = new Account(FirstName = 'Louis', LastName = 'Vuitest', PersonEmail = 'louis.vuitest@testiconics.com',
                                   IsProspect__pc = true);
        insert pros;

		Opportunity order = new Opportunity();
		order.Name = 'Test Order';
		order.StageName = 'Brief in progress';
		order.CloseDate = Date.today();
		order.Account = pros;
		insert order;

		pros = [Select Id, PersonContactId, PersonEmail From Account Where Id = :pros.Id];

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		EmailTemplate template;
		System.runAs ( thisUser ) {
			string templateText = '<messaging:emailTemplate subject="{!relatedTo.Name}" recipientType="Contact" relatedToType="Case"><messaging:htmlEmailBody ><ul><li>test content</li></ul></messaging:htmlEmailBody></messaging:emailTemplate>';
			template = new EmailTemplate(
				developerName = 'TestEmailVFTemplate', 
				TemplateType= 'Custom', 
				FolderId = UserInfo.getUserId(), 
				Name = 'TestEmailVFTemplate',
				IsActive = true);
			template.HtmlValue = templateText;
			template.Body = templateText;
			insert template;
		}

		Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;         

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

		ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=order.Id;
        contentlink.ShareType= 'I';
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setTargetObjectId(pros.PersonContactId);
		email.setTemplateId(template.Id);
		email.setWhatId(order.Id);
		email.setSaveAsActivity(true);
		email.setEntityAttachments(new List<Id>{testContent.Id});
		// Removed b/c emailing is forbidden on Perso2
//		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
	}

}