global class MIY_PAP_PdfController {
	public PageReference getBody() {
		OrderSettings__c orderSettings = OrderSettings__c.getInstance();
		PageReference currentPage = ApexPages.currentPage();
		Id firmOrderId = currentPage.getParameters().get('id');
		SPO_FirmOrder__c firmOrder = [SELECT Id, Name FROM SPO_FirmOrder__c WHERE Id = :firmOrderId];
		HttpRequest req = new HttpRequest();
		req.setEndpoint(orderSettings.MakeItYoursAppUrl__c + '/api/print/pap/' + firmOrder.Name);
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
		req.setHeader('instanceurl', Url.getOrgDomainUrl().toExternalForm());
		req.setTimeout(60000);//sets maximum timeout
		req.setMethod('GET');
		// Send the request, and return a response
		Http h = new Http();
		HttpResponse res = h.send(req);

		if (res.getStatusCode() == 200) {
			// if the response is ok
			ContentVersion cv = new ContentVersion();
			cv.Title = 'PAP ' + firmOrder.Name + ' ' + String.valueOf(Datetime.now());
			cv.PathOnClient = '/' + res.getHeader('request-id') + '.pdf';
			cv.VersionData = res.getBodyAsBlob();
			insert cv;

			//Query Content Version to use its Id in Content Document Link
			cv = [Select Id, ContentDocumentId, Title From ContentVersion where Id =:cv.Id];

			// Create a new content document link and link it to above Opportunity
			// ContentDocumentLink contentLink = new ContentDocumentLink();
			// contentLink.LinkedEntityId = orderId;
			// contentLink.ContentDocumentId = docs[0].ContentDocumentId;
			// contentLink.ShareType = 'V';
			// insert contentLink;
			// TODO: change to PageReference('/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Pdf&versionId=' + cv.Id)
			return new PageReference('/sfc/servlet.shepherd/document/download/' + cv.ContentDocumentId);
		} else {
			return ApexPages.currentPage();
		}
	}
}