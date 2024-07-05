/**
* Calling RMS to get the stock for a product in a store
*/
public class SO_WS_RMS_DoItemSearch {

    public static SO_WS_RMS_ItemSearch.itemInformation[] doItemSearch(String skuCode, String storeCode) {//DataInput dataIn) {

        // init webservice
        SO_WS_RMS_ItemSearch.docTypeRef_LvmHeader header = new SO_WS_RMS_ItemSearch.docTypeRef_LvmHeader();
        header.version = '1.0';
        header.consumer = 'SPO';

        SO_WS_RMS_ItemSearch.Data data = new SO_WS_RMS_ItemSearch.Data();
        data.storeCode = storeCode;//'K01';
        data.itemCode = skuCode;//'M60419';
        //input.description = '';

        SO_WS_RMS_ItemSearch.itemSearch2 input2 = new SO_WS_RMS_ItemSearch.itemSearch2();
        input2.Data = data;
        input2.LvmHeader = header;

        SO_WS_RMS_ItemSearch.itemSearch input = new SO_WS_RMS_ItemSearch.itemSearch();
        input.itemSearch = input2;

        SO_WS_RMS_ItemSearch.WSLV017_webService_v1_0_itemSearch_Port stub = new SO_WS_RMS_ItemSearch.WSLV017_webService_v1_0_itemSearch_Port(); 
        stub.timeout_x = SO_WS_Utils.getWSTimeOut();
        //stub.endpoint_x = 'https://salesforce.vuitton.biz:11813/ws/WSLV017/webService/v1_0/itemSearch';//SO_WS_Utils.getEndPoint('ClientSearch');
//        stub.endpoint_x =   'https://salesforce.vuitton.biz:11813/ws/WSLV009.webService:stockEnquiry_HV/WSLV009_webService_stockEnquiry_HV_Port';//SO_WS_Utils.getEndPoint('ClientSearch');
//        stub.endpoint_x =   'https://salesforce.vuitton.biz:11813/ws/WSLV017.webService:itemSearch/WSLV017_webService_v1_0_itemSearch_Port';//SO_WS_Utils.getEndPoint('ClientSearch');
//        stub.endpoint_x = 'https://salesforce.vuitton.biz:11813/ws/WSLV017/webService.v1_0:itemSearch/WSLV017_webService_v1_0_itemSearch_Port';
//          stub.endpoint_x = 'https://salesforce.vuitton.biz:11813/ws/WSLV017.webService:itemSearch/WSLV017_webService_v1_0_itemSearch_Port';
         // stub.endpoint_x = 'https://salesforce.vuitton.biz:11813/ws/WSLV017.webService.v1_0:itemSearch/WSLV017_webService_v1_0_itemSearch_Port';

//        stub.endpoint_x = 'http://llvcp020d:6550/ws/WSLV017.webService.v1_0:itemSearch?WSDL';
//   //     stub.endpoint_x = 'http://llvcp020d:6550/ws/WSLV017.webService.v1_0:itemSearch/WSLV017_webService_v1_0_itemSearch_Port';
 //       stub.endpoint_x = 'https://llvcp020d:11817/ws/WSLV017.webService.v1_0:itemSearch/WSLV017_webService_v1_0_itemSearch_Port';

//        stub.endpoint_x = 'https://salesforce.vuitton.biz:11817/ws/WSLV017.webService.v1_0:itemSearch/WSLV017_webService_v1_0_itemSearch_Port';
        stub.endpoint_x = SO_WS_Utils.getEndPoint('ProductSearch');
        
//    stub.endpoint_x='http://requestb.in/1knlzz61';

        System.debug('input=' + input);
        // calling webservice
        //try {
            SO_WS_RMS_ItemSearch.itemSearchResponse wsResp = stub.mainService(input);
            System.debug('wsResp=' + wsResp);

            if (wsResp != null) {
                SO_WS_RMS_ItemSearch.itemSearchResponse2 response = wsResp.itemSearchResponse;
                if (response != null) {
                    if (response.LvmHeaderResponse != null && !'000'.equals(response.LvmHeaderResponse.errorCode)) {
                        System.debug('Error: ' + response.LvmHeaderResponse);
                        throw new RMSException(response.LvmHeaderResponse.errorMessage);
                        //throw new AuraException(response.LvmHeaderResponse);
                    } else if (response.DataResponse != null) {
                        System.debug('response.DataResponse: ' + response.DataResponse);
                        
                        return response.DataResponse.itemInformation;
                    }
                }
            }
        /*} catch (Exception e) {
            System.debug('exception=' + e);
        }*/
        return null;
    }

    public class RMSException extends Exception {}
/*
    public static SO_WS_RMS_StockEnquiry.docTypeRef_stockLineOne[] doStockEnquiry(String storeCode, List<String> skuList) {//DataInput dataIn) {

        // init webservice
        SO_WS_RMS_StockEnquiry.docTypeRef_stockEnquiry_HVData input = new SO_WS_RMS_StockEnquiry.docTypeRef_stockEnquiry_HVData();
        input.storeCode = storeCode;//'K01';
        input.SKU = skuList;//new String[]{'M60419'};
        //input.location = new String[]{};
        //input.geographicalArea = new String[]{};
        //input.typeOfQuantity = '';
        //input.fullStock = '';
        System.debug('input=' + input);

        SO_WS_RMS_StockEnquiry.stockEnquiry_HV2 data = new SO_WS_RMS_StockEnquiry.stockEnquiry_HV2();
        data.Data = input;
        System.debug('data=' + data);

        SO_WS_RMS_StockEnquiry.stockEnquiry_HV hv = new SO_WS_RMS_StockEnquiry.stockEnquiry_HV();
        hv.stockEnquiry_HV = data;
        System.debug('stockEnquiry_HV=' + hv);

        SO_WS_RMS_StockEnquiry.WSLV009_webService_stockEnquiry_HV_Port stub = new SO_WS_RMS_StockEnquiry.WSLV009_webService_stockEnquiry_HV_Port(); 
        stub.timeout_x = SO_WS_Utils.getWSTimeOut();
        stub.endpoint_x = 'https://salesforce.vuitton.biz:11813/ws/WSLV009.webService:stockEnquiry_HV/WSLV009_webService_stockEnquiry_HV_Port';//SO_WS_Utils.getEndPoint('ClientSearch');

        // calling webservice
        try {
            System.debug('hv=' + hv);
            SO_WS_RMS_StockEnquiry.stockEnquiry_HVResponse wsResp = stub.mainService(hv);
            System.debug('wsResp=' + wsResp);

            if (wsResp != null) {
                SO_WS_RMS_StockEnquiry.stockEnquiry_HVResponse2 response = wsResp.stockEnquiry_HVResponse;
                if (response != null) {
                    if (response.LvmHeaderResponse != null && String.isNotBlank(response.LvmHeaderResponse.errorCode)) {
                        System.debug('Error: ' + response.LvmHeaderResponse);
                    } else if (response.DataResponse != null) {
                        System.debug('response.DataResponse: ' + response.DataResponse);
                        System.debug('response.DataResponse.folderName: ' + response.DataResponse.folderName);
                        System.debug('response.DataResponse.fileName: ' + response.DataResponse.fileName);

                        return response.DataResponse.stockLine;
                    }
                }
            }
        } catch (Exception e) {
            System.debug('exception=' + e);
        }
        return null;
    }*/
}