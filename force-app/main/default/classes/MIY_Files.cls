public class MIY_Files  {

	@AuraEnabled
	public static List<FileWrapper> getRelatedFiles(id recordId){
		List<FileWrapper> ret = new List<FileWrapper>();
		List<EmailMessage> relatedMails = MIY_Emails.getEmails(recordId);
		Map<Id, EmailMessage> relatedMailsMap = new Map<Id, EmailMessage>(relatedMails);
		for(ContentDocumentLink cdl : [Select ContentDocument.Id, ContentDocument.title, ContentDocument.FileType, ContentDocument.CreatedDate, LinkedEntityId From ContentDocumentLink Where LinkedEntityId=:recordId or LinkedEntityId in :relatedMailsMap.keySet()]){
			ret.add(new FileWrapper(cdl.ContentDocument, relatedMailsMap.get(cdl.LinkedEntityId)));
		}
		return ret;
	}

	private class FileWrapper{
		@AuraEnabled public ContentDocument file;
		@AuraEnabled public EmailMessage relatedMail;

		public FileWrapper(ContentDocument f, EmailMessage mail){
			file = f;
			relatedMail = mail;
		}
	}

}