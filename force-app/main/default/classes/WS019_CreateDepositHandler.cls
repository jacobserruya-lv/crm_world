public with sharing class WS019_CreateDepositHandler {
	// Adapted from SO_CreateDepositPaymentRMS_Utils & SO_WS_RMS_DoSalesCreation

	/**
	 * Main entry to call the X-Store deposit/payment web service
	 * @param  isPayment Boolean that is true if making payment, false if making deposit
	 * @param  opp       The order for which a deposit is being made
	 * @return           A simple class that contains the success result and the payment Id
	 */
	public static Result createDepositOrPaymentIntoXStore(Boolean isPayment, Opportunity opp) {
		Result calloutResult = new Result();
		calloutResult.calloutSuccessResult = false;

		String depositPaymentId = createDepositOrPaymentIntoXStore_WS(isPayment, opp);
		calloutResult.calloutSuccessResult = true;
		calloutResult.calloutDepositPaymentId = depositPaymentId;
		return calloutResult;
	}

	public class Result {
		public Boolean calloutSuccessResult;
		public String calloutDepositPaymentId;
	}

	public class DataInput {
		// Data
		public String storeCode;        
	//	public String rmsTransactionNumber;   
		public String externalSalesOrOrderNumber; 
		public String externalClientCode;
	//	public String origin;
	//	public String actionCode;
		public Datetime creationDate;
		public Datetime ExpectedCompletionDate; //MIY-1762  
	//	public String documentType;
		public Decimal totalSaleAmountExcludingTax;
		public Decimal totalSaleAmountIncludingTax;
	//	public Decimal totalVatAmount;
		public String rmsClientCode;
		public String wwRmsClientCode;
		public String associateCode;
	//	public String typeOfPrinting;
		public Decimal totalDepositAmount; //MIY-1762 added by Rachel 10/08/2021
		public String identifierOfTheStaff;
	//	public String numberOfLinesInTheOrder;
		

		// paymentOccurences
		public Decimal amountWithTaxes;

		// itemOccurences
		private String lineNumber;
		public String itemCode;   
		public Integer quantity;   
		public Boolean genericItemFlag;
		public Decimal lineUnitPrice;
		public Decimal lineAmountIncludingTax;
		public String actionType;       // Deposit / Invoice
		public String RMSId;            // Mandatory : client RMS Id
		public String paymentMode;      // CASH, VIS...


		public Decimal amountWithoutTaxes;
		public Decimal vatAmount = null;

	}

	private class SalesCreationResult {
		public String error = '';
		public String transactionNumber = '';
	}

	private string validateInput(DataInput dataIn){
		dataIn.actionType = dataIn.actionType.toLowerCase();

		if (dataIn.creationDate == null) {
			dataIn.creationDate = Date.today().addDays(-50);
		}
		if (dataIn.quantity == null) {
			dataIn.quantity = 0;
		}
		if (dataIn.amountWithoutTaxes == null) {
			dataIn.amountWithoutTaxes = 0;
		}

		if (dataIn.actionType.toLowerCase() == 'deposit') {
		//	dataIn.actionCode = '22';
		//	dataIn.documentType = 'B';
		} else {
		//	dataIn.actionCode = '14';
		//	dataIn.documentType = '9';
			
		}

		return '';
	}

	private String makeDate(Date d) {
		String year = String.valueOf(d.year());
		String month = String.valueOf(d.month()).leftPad(2, '0');
		String day = String.valueOf(d.day()).leftPad(2, '0');

		return day + '-' + month + '-' + year;
	}

	private String makeRMSAmount(Decimal d) {
		return d != null ? String.valueOf(d.setScale(2)) : '';
	}

	private SalesCreationResult getOutput(WS019_CreateDeposit.salesCreationResponse wsResp) {
		SalesCreationResult res = new SalesCreationResult();

		if (wsResp != null) {
			// WS Error
			if (wsResp.errors != null && wsResp.errors.httpRespCode != '000') {
				System.debug(LoggingLevel.ERROR, JSON.serialize(wsResp.errors));
				String msg ='Xstore WS error : ' + wsResp.errors.httpRespCode + ' - ' + wsResp.errors.httpRespMsg; //MIY-2039
				 
				SO_UTIL.exceptionDump(msg); //MIY-2039
				throw new SO_UTIL.RMSException(msg);  //MIY-2039
			}

			res.transactionNumber = wsResp.DataResponse.transactionNumber;
			System.debug(LoggingLevel.INFO, '++++' + res.transactionNumber);
		}
		return res;
	}

	private WS019_CreateDeposit.salesCreation makeMsg(DataInput dataIn) {

		WS019_CreateDeposit.salesCreationData salesData = new WS019_CreateDeposit.salesCreationData();
		salesData.storeCode = dataIn.storeCode;
	//	salesData.rmsTransactionNumber = dataIn.rmsTransactionNumber; 
		salesData.externalSalesOrOrderNumber = dataIn.externalSalesOrOrderNumber; 
	//	salesData.origin = dataIn.origin; 
	//	salesData.actionCode = dataIn.actionCode;
		salesData.creationDate = dataIn.creationDate;
		salesData.ExpectedCompletionDate = dataIn.ExpectedCompletionDate;//MIY-1762
	//	salesData.documentType = dataIn.documentType;
		salesData.totalSaleAmountExcludingTax = makeRMSAmount(dataIn.totalSaleAmountExcludingTax);
		salesData.totalSaleAmountIncludingTax = makeRMSAmount(dataIn.totalSaleAmountIncludingTax);
	//	salesData.totalVatAmount = makeRMSAmount(dataIn.totalVatAmount);
	//	salesData.rmsClientCode = dataIn.rmsClientCode;
		salesData.wwRmsClientCode = dataIn.wwRmsClientCode;
		salesData.associateCode = dataIn.associateCode;
	//	salesData.typeOfPrinting = dataIn.typeOfPrinting;
		salesData.totalDepositAmount = dataIn.totalDepositAmount; //MIY-1762 added by Rachel 10/08/2021
		salesData.identifierOfTheStaff = dataIn.identifierOfTheStaff;
		salesData.externalClientCode = dataIn.externalClientCode;
	//	salesData.numberOfLinesInTheOrder = dataIn.numberOfLinesInTheOrder;


	//	salesData.documentType = dataIn.documentType;         // 2-Invoice B-Deposit K-Atg Invoice
	//	salesData.numberOfLinesInTheOrder = dataIn.lineNumber;
		salesData.totalSaleAmountExcludingTax = makeRMSAmount(dataIn.amountWithoutTaxes);
		salesData.totalSaleAmountIncludingTax = makeRMSAmount(dataIn.amountWithTaxes);

		WS019_CreateDeposit.paymentOccurences payment = new WS019_CreateDeposit.paymentOccurences();
		// if(dataIn.actionType.toLowerCase() == 'payment') {
		// 	payment.receivedAmount = makeRMSAmount(dataIn.amountWithTaxes);
		// } else {
		// 	payment.receivedAmount = makeRMSAmount(dataIn.amountWithTaxes);
		// }
		payment.receivedAmount = makeRMSAmount(dataIn.amountWithTaxes);
		salesData.paymentOccurences = new WS019_CreateDeposit.paymentOccurences[] {payment};

		WS019_CreateDeposit.itemOccurences itemOccurence = new WS019_CreateDeposit.itemOccurences();
		// if(dataIn.actionType.toLowerCase() == 'payment') {
		// 	itemOccurence.lineNumber = '10';
		// 	itemOccurence.itemCode = dataIn.SKUCode;
		// 	itemOccurence.quantity = '1';
		// 	itemOccurence.lineAmountIncludingTax = dataIn.amountWithTaxes != null && dataIn.actionType.toLowerCase() != 'deposit' ? makeRMSAmount(dataIn.amountWithTaxes) : '';
		// }
		itemOccurence.lineNumber = '1';
		itemOccurence.itemCode = dataIn.itemCode;
		itemOccurence.quantity = '1';
		itemOccurence.genericItemFlag = dataIn.genericItemFlag;
	//	itemOccurence.wwRmsClientCode = dataIn.wwRmsClientCode; //MIY-1743
		itemOccurence.associateCode = dataIn.associateCode;
		itemOccurence.lineAmountIncludingTax = dataIn.lineAmountIncludingTax;
		itemOccurence.lineUnitPrice = dataIn.lineUnitPrice;
		salesData.itemOccurences = new WS019_CreateDeposit.itemOccurences[] {itemOccurence};

		// WS019_CreateDeposit.lvmHeader lvmHeader = new WS019_CreateDeposit.lvmHeader();
		// lvmHeader.version = '1.0';
		// lvmHeader.consumer = 'SPO';

		WS019_CreateDeposit.salesCreation2 headers = new WS019_CreateDeposit.salesCreation2();
	//	headers.LvmHeader = lvmHeader;
		headers.Data = salesData;

		WS019_CreateDeposit.salesCreation wsMsg = new WS019_CreateDeposit.salesCreation();
		wsMsg.salesCreation = headers;

		System.debug(LoggingLevel.INFO,JSON.serialize(wsMsg));
		return wsMsg;
	}


	private static String createDepositOrPaymentIntoXStore_WS(Boolean isPayment, Opportunity opp) {
		String calloutDepositPaymentIdResult = '';
		WS019_CreateDepositHandler createDepositWS = new WS019_CreateDepositHandler();
		DataInput dataInput = new DataInput();

		system.debug('Opportunity opp:' + opp);
		system.debug('Opportunity opp 1:' + Date.today().addDays((Integer)opp.SPO_Estimated_date_NOMTO__c*7));


		dataInput.storeCode = opp.SPO_StoreCode__c;
	//	dataInput.rmsTransactionNumber = '0'; //What is this?
		dataInput.externalSalesOrOrderNumber = opp.OrderNumber__c;
	//	dataInput.origin = '1'; // What is this?;
		// dataInput.actionCode = 'X'; Is Assigned on validateInput
		dataInput.creationDate = opp.CreatedDate; 
		dataInput.ExpectedCompletionDate = Date.today().addDays((Integer)opp.SPO_Estimated_date_NOMTO__c*7);//opp.SPO_pdd__c;
	//	dataInput.documentType = 'B'; // What is this?;
		// dataInput.totalSaleAmountExcludingTax = 'X'; Is Assigned on makeMsg
        // dataInput.totalSaleAmountIncludingTax = 'X'; Is Assigned on makeMsg
	//	dataInput.totalVatAmount = null; // What is mediator getting in this case?
		dataInput.rmsClientCode = opp.SPO_RMSClientId__c; 
		dataInput.wwRmsClientCode = opp.SPO_wwRMSClientId__c; // MIY-1743
		dataInput.associateCode = opp.SPO_caCode__c; 
	//	dataInput.typeOfPrinting = null; // What is mediator getting in this case?
		dataInput.totalDepositAmount = opp.SPO_DepositAmount__c; //MIY-1762 added by Rachel 10/08/2021
		dataInput.identifierOfTheStaff = opp.SPO_caCode__c;
		dataInput.externalClientCode = opp.SPO_caCode__c;
	//	dataInput.numberOfLinesInTheOrder = '1'; // !!! SPO only one order line

		// itemOccurences
		dataInput.itemCode = opp.SPO_SpecialOrderSKUCode__c;
		dataInput.genericItemFlag = true;
		dataInput.lineUnitPrice = opp.SPO_UnitRetailPriceQuotation__c;
		dataInput.lineAmountIncludingTax = opp.SPO_UnitRetailPriceQuotation__c;
		
  
  
        // public String numberOfLinesInTheOrder;

		if(isPayment == false) {
			dataInput.ActionType        = 'Deposit';
			dataInput.AmountWithTaxes   = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_DepositAmount__c : opp.SPO_DepositAmount__c);
			dataInput.quantity          = (SO_Session.theCurrentBrief != null
				? (SO_Session.theCurrentBrief.SPO_SkuQuantity__c != null ? Integer.valueOf(SO_Session.theCurrentBrief.SPO_SkuQuantity__c) : 0)
				: (opp.SPO_SkuQuantity__c != null ? Integer.valueOf(opp.SPO_SkuQuantity__c) : 0)
			);
		}

		else if(isPayment == true) {
			dataInput.ActionType        = 'Payment';
			dataInput.AmountWithTaxes   = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_UnitRetailPriceQuotation__c : opp.SPO_UnitRetailPriceQuotation__c);
			// dataInput.itemCode           = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_SpecialOrderSKUCode__c : opp.SPO_SpecialOrderSKUCode__c);
			dataInput.quantity          = 1;
		}

		SalesCreationResult calloutResult = createDepositWS.doSalesCreation(dataInput);
		system.debug(LoggingLevel.INFO, 'calloutResult.transactionNumber: ' + calloutResult.transactionNumber);
		system.debug(LoggingLevel.INFO, 'calloutResult.error: ' + calloutResult.error);

		// if(String.isNotBlank(calloutResult.Error)) {
		// 	SO_UTIL.exceptionDump('createDepositOrPaymentIntoXStore_WS >> ' + calloutResult.Error);
		// 	throw new SO_UTIL.RMSException(calloutResult.Error);
		// }
		// else {
		// 	String msg = 'X-Store Empty result';
		// 	SO_UTIL.exceptionDump('createDepositOrPaymentIntoXStore_WS >> ' + msg);
		// 	throw new SO_UTIL.RMSException(msg);
		// }
		return calloutDepositPaymentIdResult;
	}

	private SalesCreationResult doSalesCreation (DataInput dataIn) {
		String err = validateInput(dataIn);
		if (!String.isBlank(err)) {
			SalesCreationResult res = new SalesCreationResult();
			res.error = err;
			return res;
		}

		WS019_CreateDeposit.salesCreation wsMsg = makeMsg(dataIn);
		WS019_CreateDeposit.LVSaleAPI_v1_webServices_saleServices_Port stub = new WS019_CreateDeposit.LVSaleAPI_v1_webServices_saleServices_Port();
		stub.timeout_x = SO_WS_Utils.getWSTimeOut();
		//stub.endpoint_x = 'callout:NY_EAI/' + 'ws/EAI_saleServices/1.0';
		stub.endpoint_x = 'callout:NOWYOURS_EAI/' + SO_WS_Utils.getEndPoint('SalesCreation3');

		WS019_CreateDeposit.salesCreationResponse wsResp = stub.salesCreationFromNY(wsMsg);
		SalesCreationResult res = getOutput(wsResp);

		System.debug(LoggingLevel.INFO, JSON.serialize(res));
		return res;
	}

}