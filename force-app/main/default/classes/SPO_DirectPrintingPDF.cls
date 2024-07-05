public class SPO_DirectPrintingPDF {
	
    @AuraEnabled
	public static List<String> getDocumentId(string oppId) {
		System.debug('oppId Order :' + oppId);
		List<String> docId = new List<String>();
		List<ContentDocumentLink> doc = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :oppId];

		for(ContentDocumentLink content : doc){
			docId.add(content.ContentDocumentId);
			System.debug('Content Document Id' + content.ContentDocumentId);	
		}
		
		return docId;
	}
}