/*
Class SO_WS_RMS_DoSalesCreation
BW - 28//11/2015

* @ Modification History
* 06/04/2018: MTOU | Using Named Credentials and updating endpoint
*/

public with sharing class SO_WS_RMS_DoSalesCreation {

    // To test ----------------------------------------------------------------------
    
    // public static string callToTest() {
    //     SO_WS_RMS_DoSalesCreation ws = new SO_WS_RMS_DoSalesCreation();
    //     SO_WS_RMS_DoSalesCreation.DataInput dataIn = new SO_WS_RMS_DoSalesCreation.DataInput();
        
    //     dataIn.storeCode = 'UEC';           // StoreCode is Mandatory
    //     dataIn.actionType = 'Deposit';      // Deposit / Payment        
    //     dataIn.RMSId = '01JR0S';            // Mandatory : client RMS Id
    //     dataIn.orderNumber = 'SP8000';
    //     dataIn.creationDate = null;         // Empty -> today
    //     dataIn.caCode = 'WEB';              // Mandatory
    //     dataIn.SKUCode = '';                // Mandatory for sales
    //     dataIn.depositNumber = '';          // For payment only
    //     dataIn.amountWithTaxes = 800;       // Mandatory and never 0 for deposit
    //     dataIn.paymentMode = '';            // CASH (default), VIS...
    //     dataIn.quantity = null;             // quantity = 1 per default if payment 0 per default if deposit.

    //     SO_WS_RMS_DoSalesCreation.Result result = ws.doSalesCreation(dataIn);
    //     return 'OK';
    // }

    // // WS CALL -----------------------------------------------------------------
    
    // public Result doSalesCreation (DataInput dataIn) {
    //     String err = validateInput(dataIn);
    //     System.debug('doSalesCreation 1');
    //     if (!String.isBlank(err)) {
    //         Result res = new Result();
    //         res.error = err;
    //         return res;
    //     }
    //     System.debug('doSalesCreation 2');
    //     SO_WS_RMS_SalesCreation_v3.salesCreation wsMsg = makeMsg (dataIn);
    //     System.debug('doSalesCreation 3');  
    //     SO_WS_RMS_SalesCreation_v3.WSLV003_webService_v3_0_salesCreation_Port_2 stub = new SO_WS_RMS_SalesCreation_v3.WSLV003_webService_v3_0_salesCreation_Port_2();
    //     System.debug('doSalesCreation 4');   
    //     stub.timeout_x = SO_WS_Utils.getWSTimeOut();
    //     System.debug('doSalesCreation 5');
    //     //stub.endpoint_x = SO_WS_Utils.getEndPoint('SalesCreation');
    //     stub.endpoint_x = 'callout:EAI/' + SO_WS_Utils.getEndPoint('SalesCreation');
    //     System.debug('doSalesCreation 6=' + stub.endpoint_x);

    //     Result res;
    //     if (!runForTest()) {
    //         System.debug('doSalesCreation 11'); 
    //         SO_WS_RMS_SalesCreation_v3.salesCreationResponse wsResp = stub.mainService (wsMsg);
    //         System.debug('doSalesCreation 12'); 
    //         res = getOutput(wsResp);
    //         System.debug('doSalesCreation 7 '+ res);
    //     }
    //     else {
    //         System.debug('doSalesCreation 10'); 
    //         // Just to test without any call to the web service
    //         SO_WS_RMS_SalesCreation_v3.salesCreationResponse wsResp;
    //         res = getOutput(wsResp);
    //         res.transactionNumber = '14712';
    //         res.depositNumber = '14712';
    //         System.debug('doSalesCreation 8');
    //     }
    //     System.debug('doSalesCreation 9');    
    //     System.debug('+++++ ' + res);
    //     return res;
    // }

    // private Boolean runForTest() {
    //     Boolean dontCall = false;
    //     SO_Settings__c WSCallNoCall = SO_Settings__c.getInstance('WSCallNoCall');
    //     if (WSCallNoCall != null) dontCall = (WSCallNoCall.Value__c.toLowercase().trim() == 'nocall');
    //     return dontCall;    
    // }

    // // Input ---------------------------------------------------------------------------
    
    // public class DataInput {

    //     public String actionType;               // Deposit / Invoice        
    //     public String storeCode;                // Mandatory
    //     public String RMSId;                    // Mandatory : client RMS Id
    //     public String orderNumber;              // One deposit per external order number
    //     public Date creationDate;               // Empty -> today
    //     public String caCode;                   // Mandatory
    //     public String SKUCode;                  // Mandatory for sales
    //     public String paymentMode;              // CASH, VIS...
    //     public Integer quantity;
    //     public String depositNumber;
    //     public Decimal amountWithTaxes;
    //     public Decimal amountWithoutTaxes;      
    //     public Decimal vatRate = null;
    //     public Decimal vatAmount = null;

    //     private String actionCode;              // 20-Deposit creation 15-Sales
    //     private String documentType;            // 2-Invoice B-Deposit K-Atg Invoice
    //     private String validationScreen;        // Mandatory if not deposit
    //     private String lineNumber;   
    //     private String applicationOrigin;
    //     private String depositIndicator;     
    // }

    // private string validateInput(DataInput dataIn){
    //     dataIn.actionType = dataIn.actionType.toLowerCase();
    //     dataIn.applicationOrigin = '8';     // SPO Code
    //     dataIn.lineNumber = '1';
    //     if (dataIn.creationDate == null) dataIn.creationDate = Date.today().addDays(-50);
    //     if (dataIn.quantity == null) dataIn.quantity = 0;
    //     if (dataIn.amountWithoutTaxes == null) dataIn.amountWithoutTaxes = 0;
    //     if (dataIn.vatRate == null) dataIn.vatRate = 0;
    //     if (dataIn.actionType.toLowerCase() == 'deposit') {
    //         dataIn.actionCode = '22';//31-3-16 - Change from '20' to '22' (create a waiting deposit) for ticket 892;
    //         dataIn.documentType = 'B';
    //         dataIn.validationScreen = 'PRTCA04';
    //         dataIn.SKUCode = '';
    //         //dataIn.quantity = 0;
    //     }
    //     else
    //     {
    //         dataIn.actionCode = '14';
    //         dataIn.documentType = '9';
    //         dataIn.validationScreen = 'A06M0021A2';
    //         if (!String.isEmpty(dataIn.depositNumber)) dataIn.depositIndicator = '1';//'0';
    //     }

    //     //31-3-16 - START Removed for ticket 892: 
    //     //if (String.isBlank(dataIn.paymentMode)) dataIn.paymentMode = 'CASH';
    //     //31-3-16 - END Removed for ticket 892: 

    //     //dataIn.vatAmount = dataIn.amountWithoutTaxes * dataIn.vatRate;
    //     //dataIn.amountWithTaxes = dataIn.amountWithoutTaxes + dataIn.vatAmount;
    //     return '';
    // }

    // private String makeRMSDate(Date d) {
    //     return String.valueOf(d.year()) + (d.month()<10 ? '0' : '') + String.valueOf(d.month()) + (d.day()<10 ? '0' : '') + String.valueOf(d.day());
    // }

    // private String makeRMSAmount(Decimal d) {
    //     return d != null ? String.valueOf(d.setScale(2)) : '';
    // } 

    // private String makeRMSAmountMultiply(Decimal d, Integer quantity) {
    //     return d != null ? String.valueOf( (d * quantity).setScale(2)) : '';
    // } 

    // private SO_WS_RMS_SalesCreation_v3.salesCreation makeMsg(DataInput dataIn) {
        
    //     SO_WS_RMS_SalesCreation_v3.docTypeRef_SalesHeader salesHeader = new SO_WS_RMS_SalesCreation_v3.docTypeRef_SalesHeader();
    //     salesHeader.applicationOrigin = dataIn.applicationOrigin;       // For SPO
    //     salesHeader.storeCode = dataIn.storeCode;               
    //     salesHeader.rmsClientCode = dataIn.RMSId;                       // Mandatory
    //     salesHeader.externalSalesOrOrderNumber = dataIn.orderNumber;    // Mandatory
    //     salesHeader.actionCode = dataIn.actionCode;                     // 20-Deposit creation 15-Sales
    //     salesHeader.additionalInformation = '';
    //     salesHeader.creationDate = makeRMSDate(dataIn.creationDate);
    //     salesHeader.documentType = dataIn.documentType;                 // 2-Invoice B-Deposit K-Atg Invoice
    //     salesHeader.validationScreenName = dataIn.validationScreen;
    //     salesHeader.numberOfLinesInTheOrder = dataIn.lineNumber;
    //     salesHeader.associateCode = dataIn.caCode;
    //     /*salesHeader.totalSaleAmountExcludingTax = makeRMSAmountMultiply(dataIn.amountWithoutTaxes, dataIn.quantity);
    //     salesHeader.totalSaleAmountIncludingTax = makeRMSAmountMultiply(dataIn.amountWithTaxes, dataIn.quantity);*/
    //     salesHeader.totalSaleAmountExcludingTax = makeRMSAmount(dataIn.amountWithoutTaxes);
    //     salesHeader.totalSaleAmountIncludingTax = makeRMSAmount(dataIn.amountWithTaxes);
    //     salesHeader.totalVatAmount = makeRMSAmount(dataIn.vatAmount);       

    //     SO_WS_RMS_SalesCreation_v3.docTypeRef_PaymentOccurencesOne payment = new SO_WS_RMS_SalesCreation_v3.docTypeRef_PaymentOccurencesOne();
    //     SO_WS_RMS_SalesCreation_v3.docTypeRef_PaymentOccurencesOne[] paymentOccurences = new SO_WS_RMS_SalesCreation_v3.docTypeRef_PaymentOccurencesOne[] {payment};
    //     if(dataIn.actionType.toLowerCase() == 'payment')
    //     {
    //         payment.paymentLineNumber = '01';
    //         payment.depositNumber = dataIn.orderNumber;//dataIn.depositNumber;
    //         payment.depositIndicator = dataIn.depositIndicator;
    //         payment.modeOfPayment = 'ACIM';//'CASH'; //31-3-16 - Removed for ticket 892: 
    //         payment.receivedAmount = makeRMSAmount(dataIn.amountWithTaxes);
    //     }
    //     else
    //     {
    //         payment.receivedAmount = makeRMSAmount(dataIn.amountWithTaxes);
    //     }

    //     SO_WS_RMS_SalesCreation_v3.docTypeRef_ItemOccurencesOne itemOccurence = new SO_WS_RMS_SalesCreation_v3.docTypeRef_ItemOccurencesOne();
    //     SO_WS_RMS_SalesCreation_v3.docTypeRef_ItemOccurencesOne[] itemOccurences = new SO_WS_RMS_SalesCreation_v3.docTypeRef_ItemOccurencesOne[] {itemOccurence};
    //     if(dataIn.actionType.toLowerCase() == 'payment')
    //     {        
    //         itemOccurence.lineNumber = '10';
    //         itemOccurence.itemCode = dataIn.SKUCode;
    //         itemOccurence.quantity = '1';
    //         itemOccurence.vatRate = dataIn.vatRate != null ? makeRMSAmount(dataIn.vatRate) : '';
    //         itemOccurence.lineAmountIncludingTax = dataIn.amountWithTaxes != null && dataIn.actionType.toLowerCase() != 'deposit' ? makeRMSAmount(dataIn.amountWithTaxes) : '';
    //     }
    //     SO_WS_RMS_SalesCreation_v3.docTypeRef_SalesCreationData salesData = new SO_WS_RMS_SalesCreation_v3.docTypeRef_SalesCreationData();  
    //     salesData.salesHeader = salesHeader;
    //     salesData.paymentOccurences = paymentOccurences;
    //     salesData.itemOccurrences = itemOccurences;
        
    //     SO_WS_RMS_SalesCreation_v3.docTypeRef_LvmHeader lvmHeader = new SO_WS_RMS_SalesCreation_v3.docTypeRef_LvmHeader();
    //     lvmHeader.version = '3.1';
    //     lvmHeader.consumer = 'SPO';
                
    //     SO_WS_RMS_SalesCreation_v3.SalesCreation2 headers = new SO_WS_RMS_SalesCreation_v3.SalesCreation2();
    //     headers.LvmHeader = lvmHeader;
    //     headers.Data = salesData;

    //     SO_WS_RMS_SalesCreation_v3.salesCreation wsMsg = new SO_WS_RMS_SalesCreation_v3.salesCreation();
    //     wsMsg.SalesCreation = headers;

    //     //System.debug('\n++++ SO_WS_RMS_SalesCreation_v3.salesCreation:\n' + wsMsg);
    //     System.debug('\n++++ SO_WS_RMS_SalesCreation_v3.salesCreation:\n' + JSON.serializePretty(wsMsg));         
    //     return wsMsg;
    // }
    
    // // Output -----------------------------------------------------------------------------

    // public class Result {
    //     public String error = '';
    //     public String transactionNumber = '';
    //     public String depositNumber = '';
    // }   

    // private Result getOutput(SO_WS_RMS_SalesCreation_v3.salesCreationResponse wsResp) {
    //     Result res = new Result();
        
    //     if (wsResp != null) {
    //         // WS Error
    //         if (wsResp.SalesCreationResponse.LvmHeaderResponse.errorCode != '000') {
    //             res.error = wsResp.SalesCreationResponse.LvmHeaderResponse.errorCode + ' - ' + wsResp.SalesCreationResponse.LvmHeaderResponse.errorMessage;
    //             return res;
    //         }
            
    //         res.transactionNumber = wsResp.SalesCreationResponse.DataResponse.transactionNumber;
    //         res.depositNumber = wsResp.SalesCreationResponse.DataResponse.depositNumber;
    //         System.debug('++++ ' + wsResp.SalesCreationResponse.LvmHeaderResponse.errorCode + ' - ' + res.depositNumber + ' - ' + res.transactionNumber);
    //     }
    //     return res;
    // }
}