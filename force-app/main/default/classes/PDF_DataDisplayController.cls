/*
 * Download PDF
 * http://www.vermanshul.com/2017/07/lightning-generate-pdf-from-lightning.html
 */
public class PDF_DataDisplayController {
	public String PDFData {get; set;} 
	public String fileName {get; set;} 
    
    public PDF_DataDisplayController(){
        PDFData = '';
        fileName = '';
    }
    
    public PageReference downloadPDF(){
        System.PageReference pageRef = Page.PDF_Generator;//new System.PageReference('/apex/PDFGenerator');
    
        //ensure pdf downloads and is assigned with defined name
      //  pageRef.getHeaders().put('content-disposition', 'attachment; filename=Document.pdf');
      //  pageRef.getHeaders().put('data', 'application/pdf;base64,' + PDFData);

        //Blob contentData = pageRef.getContentAsPDF();
        //return 'data:application/pdf;base64,' + EncodingUtil.base64Encode(PDFData);     

        return pageRef;
    }
    
}