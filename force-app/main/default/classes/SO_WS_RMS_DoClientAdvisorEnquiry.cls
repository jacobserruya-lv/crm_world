/*
Class SO_WS_RMS_DoClientAdvisorEnquiry
BW - 29/12/2015
*
* @ModficationHistory
* 06/04/2018: MTOU | Using the named credentials and updating endpoint
*/

public with sharing class SO_WS_RMS_DoClientAdvisorEnquiry {

    // To test ----------------------------------------------------------------------
    
    public static string callToTest() {
        SO_WS_RMS_DoClientAdvisorEnquiry ws = new SO_WS_RMS_DoClientAdvisorEnquiry();
        SO_WS_RMS_DoClientAdvisorEnquiry.DataInput dataIn = new SO_WS_RMS_DoClientAdvisorEnquiry.DataInput();
        
        dataIn.storeCode = 'UEC';           // StoreCode is Mandatory
        dataIn.caCode = 'WEB';              // Mandatory

        SO_WS_RMS_DoClientAdvisorEnquiry.Result result = ws.doClientAdvisorEnquiry(dataIn);
        system.debug('##result '+result);
        return 'OK';
    }

    // WS CALL -----------------------------------------------------------------
    
    public Result doClientAdvisorEnquiry (DataInput dataIn) {
        String err = validateInput(dataIn);
        if (!String.isBlank(err)) {
            Result res = new Result();
            res.error = err;
            return res;
        }
        
        SO_WS_RMS_ClientAdvisorEnquiry.ClientAdvisorEnquiry wsMsg = makeMsg (dataIn);
        SO_WS_RMS_ClientAdvisorEnquiry.WSLV018_webService_v1_0_clientAdvisorEnquiry_Port stub = new SO_WS_RMS_ClientAdvisorEnquiry.WSLV018_webService_v1_0_clientAdvisorEnquiry_Port(); 
        stub.timeout_x = SO_WS_Utils.getWSTimeOut();
        //stub.endpoint_x = SO_WS_Utils.getEndPoint('ClientAdvisorEnquiry');
        // use below line of code instead of the one above as soon as the new endpoint is available for WSLV018
        stub.endpoint_x = 'callout:EAI/' + SO_WS_Utils.getEndPoint('ClientAdvisorEnquiry');
        System.debug('++++' + stub.endpoint_x);
        
        Result res;
        if (!SO_WS_Utils.runForTest()) {
            SO_WS_RMS_ClientAdvisorEnquiry.ClientAdvisorEnquiryResponse wsResp = stub.mainService (wsMsg);
            res = getOutput(wsResp);
        }
        else {
            // Just to test without any call to the web service
            SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse wsResp;
            res = getOutput(wsResp);
            res.longName = 'Aur?lie Bouchon';
        }
            
        System.debug('+++++ ' + res);
        return res;
    }

    // Input ---------------------------------------------------------------------------
    
    public class DataInput {
        public String storeCode;                // Mandatory
        public String caCode;                   // Mandatory
    }

    private string validateInput(DataInput dataIn){
        if (String.isBlank(dataIn.storeCode) || String.isBlank(dataIn.caCode))
            return('The store code and the CA Code are mandatory');
        else
            return '';
    }

    private SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiry makeMsg(DataInput dataIn) {
                
        SO_WS_RMS_ClientAdvisorEnquiry.docTypeRef_LvmHeader lvmHeader = new SO_WS_RMS_ClientAdvisorEnquiry.docTypeRef_LvmHeader();
        lvmHeader.version = '1.0';
        lvmHeader.consumer = 'SPO';

        SO_WS_RMS_ClientAdvisorEnquiry.Data caEnquiryData = new SO_WS_RMS_ClientAdvisorEnquiry.Data();
        caEnquiryData.storeCode = dataIn.storeCode;
        caEnquiryData.CACode = dataIn.caCode;
                
        SO_WS_RMS_ClientAdvisorEnquiry.ClientAdvisorEnquiry2 headers = new SO_WS_RMS_ClientAdvisorEnquiry.ClientAdvisorEnquiry2();
        headers.LvmHeader = lvmHeader;
        headers.Data = caEnquirydata;

        SO_WS_RMS_ClientAdvisorEnquiry.ClientAdvisorEnquiry wsMsg = new SO_WS_RMS_ClientAdvisorEnquiry.ClientAdvisorEnquiry();
        wsMsg.ClientAdvisorEnquiry = headers;

        System.debug('++++ ' + wsMsg);        
        return wsMsg;
    }
    
    // Output -----------------------------------------------------------------------------

    public class Result {
        public String error = '';
        public String longName = '';
    }   

    private Result getOutput(SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse wsResp) {
        Result res = new Result();
        
        if (wsResp != null) {
            // WS Error
            if (wsResp.clientAdvisorEnquiryResponse.LvmHeaderResponse.errorCode != '000') {
                res.error = wsResp.clientAdvisorEnquiryResponse.LvmHeaderResponse.errorCode + ' - ' + wsResp.clientAdvisorEnquiryResponse.LvmHeaderResponse.errorMessage;
                return res;
            }
            
            res.longName = wsResp.ClientAdvisorEnquiryResponse.DataResponse.clientAdvisorDetails.longName;
            System.debug('++++ ' + wsResp.clientAdvisorEnquiryResponse.LvmHeaderResponse.errorCode + ' - ' + res.longName);
        }
        return res;
    }
}