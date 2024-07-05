/*
Class SO_WS_RMS_DoStoreGetId
BW - 09/01/2015
*/

public with sharing class SO_WS_RMS_DoStoreGetId {

    // To test ----------------------------------------------------------------------
    
    public static string callToTest() {
        SO_WS_RMS_DoStoreGetId ws = new SO_WS_RMS_DoStoreGetId();
        SO_WS_RMS_DoStoreGetId.DataInput dataIn = new SO_WS_RMS_DoStoreGetId.DataInput();
        
        dataIn.storeCode = 'A06';           // StoreCode is Mandatory

        SO_WS_RMS_DoStoreGetId.Result result = ws.doStoreGetId(dataIn);
        return 'OK';
    }

    // WS CALL -----------------------------------------------------------------
    
    public Result doStoreGetId (DataInput dataIn) {
        String err = validateInput(dataIn);
        if (!String.isBlank(err)) {
            Result res = new Result();
            res.error = err;
            return res;
        }
        
        SO_WS_RMS_StoreGetId.storeGetId wsMsg = makeMsg (dataIn);
        SO_WS_RMS_StoreGetId.WSLV016_webService_v1_0_storeGetID_Port stub = new SO_WS_RMS_StoreGetId.WSLV016_webService_v1_0_storeGetID_Port(); 
        stub.timeout_x = SO_WS_Utils.getWSTimeOut();
        stub.endpoint_x = SO_WS_Utils.getEndPoint('StoreGetId');
        
        Result res;
        if (!SO_WS_Utils.runForTest()) {
            SO_WS_RMS_StoreGetId.storeGetIdResponse wsResp = stub.mainService (wsMsg);
            res = getOutput(wsResp);
        }
        else {
            // Just to test without any call to the web service
            SO_WS_RMS_StoreGetId.storeGetIDResponse wsResp;
            res = getOutput(wsResp);
            res.nbOfDecimals = '2';
        }
            
        System.debug('+++++ ' + res);
        return res;
    }

    // Input ---------------------------------------------------------------------------
    
    public class DataInput {
        public String storeCode;                // Mandatory
        public String productCode;              // Mandatory
    }

    private string validateInput(DataInput dataIn){
        if (String.isBlank(dataIn.storeCode))
            return('The store code is mandatory');
        else
            return '';
    }

    private SO_WS_RMS_StoreGetId.storeGetID makeMsg(DataInput dataIn) {
                
        SO_WS_RMS_StoreGetId.docTypeRef_LvmHeader lvmHeader = new SO_WS_RMS_StoreGetId.docTypeRef_LvmHeader();
        lvmHeader.version = '1.0';
        lvmHeader.consumer = 'SPO';

        SO_WS_RMS_StoreGetId.Data StoreGetIdData = new SO_WS_RMS_StoreGetId.Data();
        StoreGetIdData.storeCode = dataIn.storeCode;
                
        SO_WS_RMS_StoreGetId.storeGetID2 headers = new SO_WS_RMS_StoreGetId.storeGetID2();
        headers.LvmHeader = lvmHeader;
        headers.Data = StoreGetIdData;

        SO_WS_RMS_StoreGetId.storeGetID wsMsg = new SO_WS_RMS_StoreGetId.storeGetID();
        wsMsg.storeGetId = headers;

        System.debug('++++ ' + wsMsg);        
        return wsMsg;
    }
    
    // Output -----------------------------------------------------------------------------

    public class Result {
        public String error = '';
        public String nbOfDecimals = '';
    }   

    private Result getOutput(SO_WS_RMS_StoreGetId.storeGetIDResponse wsResp) {
        Result res = new Result();
        System.debug('++++ ' + wsResp);
        if (wsResp != null) {
            // WS Error
            if (wsResp.storeGetIDResponse.LvmHeaderResponse.errorCode != '000' && wsResp.storeGetIDResponse.LvmHeaderResponse.errorCode != '1' ) {
                res.error = wsResp.storeGetIDResponse.LvmHeaderResponse.errorCode + ' - ' + wsResp.storeGetIDResponse.LvmHeaderResponse.errorMessage;
                return res;
            }

            res.nbOfDecimals = wsResp.storeGetIdResponse.DataResponse.storeInformation.nbOfDecimals;
            System.debug('++++ ' + wsResp.storeGetIdResponse.LvmHeaderResponse.errorCode + ' - ' + res.nbOfDecimals);
        }
        return res;
    }
}