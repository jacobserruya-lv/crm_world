public class SO_WS_RMS_DoSalesServices {

    
      // To test ----------------------------------------------------------------------
    
    public static string callToTest() {
        SO_WS_RMS_DoSalesServices ws = new SO_WS_RMS_DoSalesServices();
        SO_WS_RMS_DoSalesServices.DataInput dataIn = new SO_WS_RMS_DoSalesServices.DataInput();
        
        dataIn.storeCode = 'UEC';           // StoreCode is Mandatory
        dataIn.actionType = 'Deposit';      // Deposit / Payment        
        dataIn.RMSId = '01JR0S';            // Mandatory : client RMS Id
        dataIn.orderNumber = 'SP8000';
        dataIn.creationDate = null;         // Empty -> today
        dataIn.caCode = 'WEB';              // Mandatory
        dataIn.SKUCode = '';                // Mandatory for sales
        dataIn.depositNumber = '';          // For payment only
        dataIn.amountWithTaxes = 800;       // Mandatory and never 0 for deposit
        dataIn.paymentMode = '';            // CASH (default), VIS...
        dataIn.quantity = null;             // quantity = 1 per default if payment 0 per default if deposit.

        SO_WS_RMS_DoSalesServices.Result result = ws.doSalesServices(dataIn);
        return 'OK';
    }

    // WS CALL -----------------------------------------------------------------
    
    public Result doSalesServices (DataInput dataIn) {
        String err = validateInput(dataIn);
        System.debug('doSalesService 1');
        if (!String.isBlank(err)) {
            Result res = new Result();
            res.error = err;
            return res;
        }
        System.debug('doSalesService 2');
        SO_WS_RMS_SaleServices.salesCreation wsMsg = makeMsg (dataIn);
        System.debug('doSalesService 3');  
        SO_WS_RMS_SaleServices.WSLV003_webService_v3_0_salesCreation_Port_4 stub = new SO_WS_RMS_SaleServices.WSLV003_webService_v3_0_salesCreation_Port_4();
        System.debug('doSalesService 4');   
        stub.timeout_x = SO_WS_Utils.getWSTimeOut();
        System.debug('doSalesService 5');
        //stub.endpoint_x = SO_WS_Utils.getEndPoint('SalesService');

        //Yosef Shulman Xstore Integration
        // stub.endpoint_x = 'callout:EAI/' + SO_WS_Utils.getEndPoint('SalesCreation');
        //stub.endpoint_x = 'callout:NY_EAI/' + 'ws/EAI_saleServices/1.0';
        // stub.endpoint_x = 'callout:NY_EAI/' + SO_WS_Utils.getEndPoint('SalesCreation3');
      //  stub.endpoint_x = 'callout:NYTest/' + SO_WS_Utils.getEndPoint('SalesCreation3');
        stub.endpoint_x = 'callout:NOWYOURS_EAI/' + SO_WS_Utils.getEndPoint('SalesCreation3');
        System.debug('doSalesCreation 6 =' + stub.endpoint_x);

        Result res;
        if (!runForTest()) {
           // System.debug(stub.mainService (wsMsg)); 
            SO_WS_RMS_SaleServices.salesCreationResponse wsResp = stub.mainService (wsMsg);
            System.debug('doSalesServices 12'); 
            res = getOutput(wsResp);
            System.debug('doSalesServices 7'+ res);
        }
        else {
            System.debug('doSalesServices 10'); 
            // Just to test without any call to the web service
            SO_WS_RMS_SaleServices.salesCreationResponse wsResp;
            res = getOutput(wsResp);
            res.transactionNumber = '14712';
            res.depositNumber = '14712';
            System.debug('doSalesServices 8');
        }
        System.debug('doSalesServices 9');    
        System.debug('+++++ ' + res);
        return res;
    }

    private Boolean runForTest() {
        Boolean dontCall = false;
        SO_Settings__c WSCallNoCall = SO_Settings__c.getInstance('WSCallNoCall');
        if (WSCallNoCall != null) dontCall = (WSCallNoCall.Value__c.toLowercase().trim() == 'nocall');
        return dontCall;    
    }

    // Input ---------------------------------------------------------------------------
    
    public class DataInput {

        public String actionType;               // Deposit / Invoice        
        public String storeCode;                // Mandatory
        public String RMSId;                    // Mandatory : client RMS Id
        public String orderNumber;              // One deposit per external order number
        public Datetime creationDate;    
        public String caCode;                   // Mandatory
        public String SKUCode;                  // Mandatory for sales
        public String paymentMode;              // CASH, VIS...
        public String depositNumber;
        public Decimal amountWithTaxes;
        public Decimal amountWithoutTaxes;      
        public Decimal vatAmount = null;
        public String rmsClientCode; 
        public String wwRmsClientCode;   // MIY-1860
     //   public String externalClientCode; // MIY-1858
      //  public String identifierOfTheStaff; // MIY-1860

        private String actionCode;              // 20-Deposit creation 15-Sales
        private String documentType;            // 2-Invoice B-Deposit K-Atg Invoice
        private String validationScreen;        // Mandatory if not deposit
        private String origin;
        private String depositIndicator;     

        // itemOccurences
        public Integer quantity;
        public String associateCode;
		public String itemCode;    
		public Decimal lineUnitPrice;
		public Decimal lineAmountIncludingTax;
      //  public Boolean genericItemFlag; // MIY-1860
    }

    private string validateInput(DataInput dataIn){
        dataIn.actionType = dataIn.actionType.toLowerCase();
        dataIn.origin = '8';     // SPO Code
        if (dataIn.quantity == null) dataIn.quantity = 0;
        if (dataIn.amountWithoutTaxes == null) dataIn.amountWithoutTaxes = 0;
        if (dataIn.actionType.toLowerCase() == 'deposit') {
            dataIn.actionCode = '22';//31-3-16 - Change from '20' to '22' (create a waiting deposit) for ticket 892;
            dataIn.documentType = 'B';
            dataIn.validationScreen = 'PRTCA04';
            dataIn.SKUCode = '';
            //dataIn.quantity = 0;
        }
        else
        {
            dataIn.actionCode = '14';
            dataIn.documentType = '9';
            dataIn.validationScreen = 'A06M0021A2';
            if (!String.isEmpty(dataIn.depositNumber)) dataIn.depositIndicator = '1';//'0';
        }

        //31-3-16 - START Removed for ticket 892: 
        //if (String.isBlank(dataIn.paymentMode)) dataIn.paymentMode = 'CASH';
        //31-3-16 - END Removed for ticket 892: 

        //dataIn.vatAmount = dataIn.amountWithoutTaxes * dataIn.vatRate;
        //dataIn.amountWithTaxes = dataIn.amountWithoutTaxes + dataIn.vatAmount;
        return '';
    }

    private String makeRMSDate(Date d) {
        return String.valueOf(d.year()) + (d.month()<10 ? '0' : '') + String.valueOf(d.month()) + (d.day()<10 ? '0' : '') + String.valueOf(d.day());
    }

    private String makeRMSAmount(Decimal d) {
        return d != null ? String.valueOf(d.setScale(2)) : '';
    } 

    private String makeRMSAmountMultiply(Decimal d, Integer quantity) {
        return d != null ? String.valueOf( (d * quantity).setScale(2)) : '';
    } 

    private SO_WS_RMS_SaleServices.salesCreation makeMsg(DataInput dataIn) {
        
        SO_WS_RMS_SaleServices.docTypeRef_SalesCreationData salesData = new SO_WS_RMS_SaleServices.docTypeRef_SalesCreationData();
        salesData.origin = dataIn.origin;       // For SPO
        salesData.storeCode = dataIn.storeCode;               
        salesData.rmsClientCode = dataIn.rmsClientCode; 
		salesData.wwRmsClientCode = dataIn.wwRmsClientCode;                      // Mandatory // MIY-1860
        salesData.externalSalesOrOrderNumber = dataIn.orderNumber;    // Mandatory
        salesData.actionCode = dataIn.actionCode;                     // 20-Deposit creation 15-Sales
        salesData.creationDate = dataIn.creationDate;
        salesData.documentType = dataIn.documentType;                 // 2-Invoice B-Deposit K-Atg Invoice
        salesData.associateCode = dataIn.caCode;
        /*salesData.totalSaleAmountExcludingTax = makeRMSAmountMultiply(dataIn.amountWithoutTaxes, dataIn.quantity);
        salesData.totalSaleAmountIncludingTax = makeRMSAmountMultiply(dataIn.amountWithTaxes, dataIn.quantity);*/
        salesData.totalSaleAmountExcludingTax = makeRMSAmount(dataIn.amountWithoutTaxes);
        salesData.totalSaleAmountIncludingTax = makeRMSAmount(dataIn.amountWithTaxes);
        salesData.totalVatAmount = makeRMSAmount(dataIn.vatAmount);   
       // salesData.identifierOfTheStaff = dataIn.identifierOfTheStaff; // MIY-1860
		//salesData.externalClientCode = dataIn.externalClientCode;    // MIY-1858

        SO_WS_RMS_SaleServices.docTypeRef_PaymentOccurencesOne payment = new SO_WS_RMS_SaleServices.docTypeRef_PaymentOccurencesOne();
        SO_WS_RMS_SaleServices.docTypeRef_PaymentOccurencesOne[] paymentsOccurences = new SO_WS_RMS_SaleServices.docTypeRef_PaymentOccurencesOne[] {payment};
        if(dataIn.actionType.toLowerCase() == 'payment')
        {
            payment.receivedAmount = makeRMSAmount(dataIn.amountWithTaxes);
        }
        else
        {
            payment.receivedAmount = makeRMSAmount(dataIn.amountWithTaxes);
        }

        SO_WS_RMS_SaleServices.docTypeRef_ItemOccurencesOne itemOccurence = new SO_WS_RMS_SaleServices.docTypeRef_ItemOccurencesOne();
        SO_WS_RMS_SaleServices.docTypeRef_ItemOccurencesOne[] itemOccurences = new SO_WS_RMS_SaleServices.docTypeRef_ItemOccurencesOne[] {itemOccurence};
        if(dataIn.actionType.toLowerCase() == 'payment')
        {        
            itemOccurence.itemCode = dataIn.SKUCode;
            itemOccurence.quantity = '1';
            itemOccurence.associateCode = dataIn.associateCode;
         //   itemOccurence.genericItemFlag = dataIn.genericItemFlag; // MIY-1860
            itemOccurence.lineAmountIncludingTax = dataIn.lineAmountIncludingTax;
            itemOccurence.lineUnitPrice = dataIn.lineUnitPrice;
        }else
        {
            itemOccurence.itemCode = dataIn.SKUCode;
            itemOccurence.quantity = '1';
            itemOccurence.associateCode = dataIn.associateCode;
         //  itemOccurence.genericItemFlag = dataIn.genericItemFlag; // MIY-1860
            itemOccurence.lineUnitPrice = dataIn.lineUnitPrice;
            itemOccurence.lineAmountIncludingTax = dataIn.lineAmountIncludingTax;
        }
        // SO_WS_RMS_SalesCreation_v3.docTypeRef_SalesCreationData salesData = new SO_WS_RMS_SalesCreation_v3.docTypeRef_SalesCreationData();  
        salesData.paymentsOccurences = paymentsOccurences;
        salesData.itemOccurences = itemOccurences;
        
        SO_WS_RMS_SaleServices.docTypeRef_LvmHeader lvmHeader = new SO_WS_RMS_SaleServices.docTypeRef_LvmHeader();
         lvmHeader.version = '3.1';
         lvmHeader.consumer = 'SPO';
                
        SO_WS_RMS_SaleServices.SalesCreation2 headers = new SO_WS_RMS_SaleServices.SalesCreation2();
        headers.LvmHeader = lvmHeader;
        headers.Data = salesData;

        SO_WS_RMS_SaleServices.salesCreation wsMsg = new SO_WS_RMS_SaleServices.salesCreation();
        wsMsg.salesCreation = headers;

        System.debug('\n++++ SO_WS_RMS_SaleServices.salesCreation:\n' + JSON.serializePretty(wsMsg));         
        return wsMsg;
    }
    
    // Output -----------------------------------------------------------------------------

    public class Result {
        public String error = '';
        public String transactionNumber = '';
        public String depositNumber = '';
    }   

    private Result getOutput(SO_WS_RMS_SaleServices.salesCreationResponse wsResp) {
        Result res = new Result();
        
        if (wsResp != null) {
            // WS Error
            if (wsResp.errors.httpRespCode != '000') {
                res.error = wsResp.errors.httpRespCode + ' - ' + wsResp.errors.httpRespMsg;
                return res;
            }
            
            res.transactionNumber = wsResp.DataResponse.transactionNumber;
            res.depositNumber = wsResp.DataResponse.depositNumber;
            System.debug('++++ ' + wsResp.errors.httpRespCode+ ' - ' + res.depositNumber + ' - ' + res.transactionNumber);
        }
        return res;
    }
}