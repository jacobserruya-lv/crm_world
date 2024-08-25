/**
* Restful service to retrieve PDF documents from RMS Conso (invoice, receipt,..)
* REST / JSON
* EAI_CustomerDocumentsAPI Swagger file
**/
public class WS_RMS_Document {

    // return: List<TransactionId, List<Document>> / Document = Invoice pdf blob, receipt pdf blob...
    public static List<Document> execute(List<String> transactionIdList) {

        if (transactionIdList == null || transactionIdList.isEmpty()) {
            return null;
        }

        //List<WS_RMS_DocumentResponse.Documents> documentList;
        List<Document> documentList = new List<Document>();
        try {            
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint('callout:EAI/ws/EAI_CustomerDocumentsAPI/1.0/LVCustomerDocumentsAPI/v1/webServices/resources/CustomerDocuments'); // Setup > Named credentials > EAI
            httpRequest.setMethod('POST');
            httpRequest.setTimeout(120000);
            httpRequest.setHeader('Encoding', 'UTF-8');
            httpRequest.setHeader('Accept', 'application/json');
            httpRequest.setHeader('Content-Type', 'application/json');

            String transactionIds = String.join(transactionIdList, '","');
            System.debug('transactionIds ' + transactionIds);
            
            httpRequest.setBody(
                '{"LVParameters":{"transactionID": ["' + transactionIds + '"]}}');

            Http httpProtocol = new Http();
            HttpResponse httpResponse = httpProtocol.send(httpRequest);
            System.debug('httpResponse ' + httpResponse);
    
            // parse json in object
            WS_RMS_DocumentResponse response = WS_RMS_DocumentResponse.parse(httpResponse.getBody());
    
            if (response != null && response.LVResponse != null && response.LVResponse.data != null && response.LVResponse.data.Documents != null) {
                //documentList = response.LVResponse.data.Documents;
                for (WS_RMS_DocumentResponse.Documents docWs : response.LVResponse.data.Documents) {
                    Document doc = new Document();
                    doc.transactionId = docWs.transactionID;
                    doc.binaryDocList = new List<Blob>();
                    
                    if (docWs.binaryDoc != null) {
                        for (String binary : docWs.binaryDoc) {
                            if (String.isNotBlank(binary)) {
                                Blob blobPdf = EncodingUtil.base64Decode(binary);
                                doc.binaryDocList.add(blobPdf);
                                //doc.binaryDocList.add(EncodingUtil.base64Decode(binary));
                                //doc.binaryDocList.add(Blob.toPDF(binary));
                            }
                        }
                    }
                    doc.transactionName = docWs.transactionID;

                    documentList.add(doc);
                }
            }
        } catch(Exception e) {
            System.debug('Exception e=' + e);
        }
        System.debug('documentList=' + documentList);
        return documentList;
    }
    
    public class Document {
    	public String transactionId;
        public String transactionName;
        public List<Blob> binaryDocList;
    }
}