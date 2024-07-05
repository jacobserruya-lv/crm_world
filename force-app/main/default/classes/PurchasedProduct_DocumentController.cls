public class PurchasedProduct_DocumentController {

    @AuraEnabled(cacheable=true)
    public static String getDocumentList(List<String> transactionIdList) {
        //transactionIdList = new List<String>();
        //transactionIdList.add('ORDER_00001');
        //transactionIdList.add('ORDER_00001');
       // transactionIdList.add('150420190122001001015');

        List<WS_RMS_Document.Document> docList = WS_RMS_Document.execute(transactionIdList);
        return JSON.serialize(docList);
    }

    @AuraEnabled(cacheable=true)
    public static String getVisualforceHost() {
        return IconicsSettings__c.getInstance().VisualforceHost__c;
    }
}