@isTest
private class ICX_Emails_Files_Test  {

	private static testmethod void TestMail(){
		Case c = [Select Id From Case limit 1];
		List<EmailMessage> emails = ICX_Emails.getEmails(c.Id);
	}

	private static testmethod void TestFiles(){
		Case c = [Select Id From Case limit 1];
		ICX_Files.getRelatedFiles(c.Id);
	}

	private static testmethod void CaseAccountPicklist(){
		Account a = [Select Id From Account Limit 1];
		ICX_Account_Highlight.getPicklistOptions(a);
	}

	@TestSetup
	private static void init(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Person_Account_Prospect').getRecordTypeId();

		Account pros = new Account(FirstName = 'Louis', LastName = 'Vuitest', PersonEmail = 'louis.vuitest@testiconics.com',
                                   IsProspect__pc = true, RecordTypeId = recordTypeId);
                                   //IsProspect__pc = true, RecordTypeId = System.label.ICS_Prospect_RecordTypeID);
        insert pros;
        
		pros = [Select Id, PersonContactId, PersonEmail From Account Where Id = :pros.Id];

        Case openCa = new Case(Type = 'Complaints',
                            	Origin = 'Email',
                            	Status = 'New',
                            	Subject = 'subject open case ' + Datetime.now(),
                            	Description = 'description open case ' + Datetime.now(),
                           		Accountid = pros.id,
                            	ContactID = pros.PersonContactId,
                               	SuppliedEmail = pros.PersonEmail);
        insert openCA;

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
        contentlink.LinkedEntityId=openCa.Id;
        contentlink.ShareType= 'I';
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setTargetObjectId(pros.PersonContactId);
		email.setTemplateId(template.Id);
		email.setWhatId(openCa.Id);
		email.setSaveAsActivity(true);
		email.setEntityAttachments(new List<Id>{testContent.Id});
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
	}

}