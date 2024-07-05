/*
Class SO_WS_RMS_DoProductSearch
BW - 09/01/2015
*/

public with sharing class SO_WS_RMS_DoProductSearch {

	// To test ----------------------------------------------------------------------
	
	public static string callToTest() {
		SO_WS_RMS_DoProductSearch ws = new SO_WS_RMS_DoProductSearch();
		SO_WS_RMS_DoProductSearch.DataInput dataIn = new SO_WS_RMS_DoProductSearch.DataInput();
		
		dataIn.storeCode = 'A06';			// StoreCode is Mandatory
        dataIn.productCode = 'xxx';			// Mandatory

		SO_WS_RMS_DoProductSearch.Result result = ws.doProductSearch(dataIn);
		return 'OK';
	}

	// WS CALL -----------------------------------------------------------------
	
	public Result doProductSearch (DataInput dataIn) {
		String err = validateInput(dataIn);
		if (!String.isBlank(err)) {
			Result res = new Result();
			res.error = err;
			return res;
		}
		
		SO_WS_RMS_ProductSearch.itemSearch wsMsg = makeMsg (dataIn);
		SO_WS_RMS_ProductSearch.WSLV017_webService_v1_0_itemSearch_Port stub = new SO_WS_RMS_ProductSearch.WSLV017_webService_v1_0_itemSearch_Port();	
		stub.timeout_x = SO_WS_Utils.getWSTimeOut();
		stub.endpoint_x = SO_WS_Utils.getEndPoint('ProductSearch');
		
		Result res;
		if (!SO_WS_Utils.runForTest()) {
			SO_WS_RMS_ProductSearch.itemSearchResponse wsResp = stub.mainService (wsMsg);
			res = getOutput(wsResp);
		}
		else {
			// Just to test without any call to the web service
			SO_WS_RMS_ProductSearch.itemSearchResponse wsResp;
			res = getOutput(wsResp);
			res.SPO_UnitRetailPrice = '120000';
			res.priceCurrency = 'EUR';
		}
			
		System.debug('+++++ ' + res);
		return res;
	}

	// Input ---------------------------------------------------------------------------
	
	public class DataInput {
        public String storeCode;				// Mandatory
        public String productCode;				// Mandatory
	}

	private string validateInput(DataInput dataIn){
		if (String.isBlank(dataIn.storeCode) || String.isBlank(dataIn.productCode))
			return('The store code and the product code are mandatory');
		else
			return '';
	}

	private SO_WS_RMS_ProductSearch.itemSearch makeMsg(DataInput dataIn) {
				
        SO_WS_RMS_ProductSearch.docTypeRef_LvmHeader lvmHeader = new SO_WS_RMS_ProductSearch.docTypeRef_LvmHeader();
        lvmHeader.version = '1.0';
        lvmHeader.consumer = 'SPO';

		SO_WS_RMS_ProductSearch.Data productSearchData = new SO_WS_RMS_ProductSearch.Data();
		productSearchData.storeCode = dataIn.storeCode;
		productSearchData.itemCode = dataIn.productCode;
				
		SO_WS_RMS_ProductSearch.itemSearch2 headers = new SO_WS_RMS_ProductSearch.itemSearch2();
		headers.LvmHeader = lvmHeader;
		headers.Data = productSearchData;

		SO_WS_RMS_ProductSearch.itemSearch wsMsg = new SO_WS_RMS_ProductSearch.itemSearch();
		wsMsg.itemSearch = headers;

		System.debug('++++ ' + wsMsg);        
		return wsMsg;
	}
	
	// Output -----------------------------------------------------------------------------

	public class Result {
		public String error = '';
		public String SPO_UnitRetailPrice = '';
		public string priceCurrency = '';
	}	

	private Result getOutput(SO_WS_RMS_ProductSearch.itemSearchResponse wsResp) {
		Result res = new Result();
		
		if (wsResp != null) {
			// WS Error
			if (wsResp.itemSearchResponse.LvmHeaderResponse.errorCode != '000') {
				res.error = wsResp.itemSearchResponse.LvmHeaderResponse.errorCode + ' - ' + wsResp.itemSearchResponse.LvmHeaderResponse.errorMessage;
				return res;
			}

		if (wsResp.itemSearchResponse.DataResponse.itemInformation == null || wsResp.itemSearchResponse.DataResponse.itemInformation.size() == 0) {
				res.error = 'No product found';
				return res;			
		}
			
		res.SPO_UnitRetailPrice = wsResp.itemSearchResponse.DataResponse.itemInformation[0].domesticPriceIncludingTax;
		res.priceCurrency = wsResp.itemSearchResponse.DataResponse.itemInformation[0].currency_x;
		System.debug('++++ ' + wsResp.itemSearchResponse.LvmHeaderResponse.errorCode + ' - ' + res.SPO_UnitRetailPrice + ' - ' + res.priceCurrency);
		}
		return res;
	}
}