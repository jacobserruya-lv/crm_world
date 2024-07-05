/*
	TEST CLASS FOR SPO_DirectPritingPDF 
	Developped by Visal OU - CGI Team
	First Version : 16/01/2018
*/

@isTest
private class SPO_DirectPrintingPDF_TEST
{
	@isTest
	static void testContentDocument()
	{
		//Create new opportunity
		opportunity opp = new opportunity();
		opp.Name = 'Test opp';
		opp.StageName = 'Qualification';
		opp.CloseDate = Date.today() + 3;
		insert opp;
		
		//Create new file/content document
		string be = 'Testing base 64 encode';
		Blob beforeBlob = Blob.valueOf(be);

		//Insert content document data
		ContentVersion ctVersion = new ContentVersion();
		ctVersion.Title = 'Test ContentVersion';
		ctVersion.PathOnClient = '/Test.jpg';
        //ctVersion.ContentUrl = 'http://www.google.com/';
		ctVersion.VersionData = beforeBlob;
		//ctVersion.IsMajorVersion = true;
		insert ctVersion;

		//Query Content Version to use its Id in Content Document Link
		List<ContentVersion> docs = [Select Id,ContentDocumentId, Title From ContentVersion where Id =:ctVersion.Id];

		// Create a new content document link and link it to above Opportunity
		ContentDocumentLink contentLink = new ContentDocumentLink();
		contentLink.LinkedEntityId = opp.id;
		contentLink.ContentDocumentId = docs[0].ContentDocumentId;
		contentLink.ShareType = 'V';
		insert contentLink;

		// call this method, it should return contentLink 
		list<String> ctlink = SPO_DirectPrintingPDF.getDocumentId(opp.id);
		system.assertNotEquals(0,ctlink.size());
	}
}