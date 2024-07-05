@isTest
public class PurchasedProduct_DocumentController_TEST {

    @isTest
    public static void getDocumentList_Test() {
        // No need to verify the result as WS_RMS_Document_TEST is already ok
        List<String> resultList = (List<String>) System.JSON.deserialize(PurchasedProduct_DocumentController.getDocumentList(null), List<String>.class);
        System.assert(resultList == null);
    }

    @isTest
    public static void getVisualforceHost_Test() {
        String host = 'louisvuitton--pprod--c.cs95.visual.force.com';
        IconicsSettings__c settings = new IconicsSettings__c();
        settings.VisualforceHost__c = host;
        insert settings;
        
        Test.startTest();
		System.assertEquals(host, PurchasedProduct_DocumentController.getVisualforceHost());
        Test.stopTest();
    }
}