public class ICX_Files  {

	@AuraEnabled
	public static List<FileWrapper> getRelatedFiles(id recordId){
		List<FileWrapper> ret = new List<FileWrapper>();
		List<EmailMessage> relatedMails = ICX_Emails.getEmails(recordId);
		Map<Id, EmailMessage> relatedMailsMap = new Map<Id, EmailMessage>(relatedMails);
        List <Case> lstCase = [select id from case where My_Repairs__c=:recordId];
        List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>();
		 /*  Description: if on CareService record page, show files related to the case which is linked to CareService
         * Modification: 12/07/2021 by Keman WU 
        */
         if (recordId.getSobjectType() == CareService__c.SobjectType)  
         lstContentDocumentLink = [Select ContentDocument.Id, ContentDocument.title, ContentDocument.FileType, ContentDocument.CreatedDate, LinkedEntityId From ContentDocumentLink Where ContentDocument.FileType != 'SNOTE' and (LinkedEntityId=:recordId or LinkedEntityId in :relatedMailsMap.keySet() or LinkedEntityId in :lstCase)];
		else    
        lstContentDocumentLink = [Select ContentDocument.Id, ContentDocument.title, ContentDocument.FileType, ContentDocument.CreatedDate, LinkedEntityId From ContentDocumentLink Where LinkedEntityId=:recordId or LinkedEntityId in :relatedMailsMap.keySet()];
		for(ContentDocumentLink cdl : lstContentDocumentLink ){
			ret.add(new FileWrapper(cdl.ContentDocument, relatedMailsMap.get(cdl.LinkedEntityId)));
		}
		return ret;
	}

	public class FileWrapper{
		@AuraEnabled public ContentDocument file;
		@AuraEnabled public EmailMessage relatedMail;

		public FileWrapper(ContentDocument f, EmailMessage mail){
			file = f;
			relatedMail = mail;
		}
	}

}