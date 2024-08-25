@isTest
global class WS_RMS_Document_TEST {

    @isTest
    public static void executeTest() {
        System.assert(WS_RMS_Document.execute(null) == null);

        Test.setMock(HttpCalloutMock.class, new WS_RMS_Document_MOCK());

        List<String> transactionIdList = new List<String>();
        transactionIdList.add('150220180919001000299');

        Test.startTest();
        List<WS_RMS_Document.Document> resultList = WS_RMS_Document.execute(transactionIdList);
        Test.stopTest();
        
        // Results depend on the WS_RMS_Document_MOCK
        System.assertEquals(2, resultList.size());
        System.assertEquals('Transaction1', resultList.get(0).transactionId);
    }
}