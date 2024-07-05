@isTest
public class PDF_DataDisplayController_TEST {

    @isTest
    public static void downloadPDF_Test() {
        PDF_DataDisplayController controller = new PDF_DataDisplayController();
        
        PageReference pageRef = Page.PDF_Generator;
        System.assertEquals(controller.downloadPDF().getUrl(), pageRef.getUrl());
    }
}