/**
 * This is a webservice mock class for SO_ProductController_TEST class
 * @createdBy           Romain Mouchel-Vallon, 07-09-2017
 * @lastModifiedBy      Romain Mouchel-Vallon, 07-09-2017
 */
 @isTest
public class SO_WS_RMS_DoItemSearch_MOCK implements WebServiceMock {
   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

        System.debug ('request -> ');
        System.debug (request);

        SO_WS_RMS_ItemSearch.docTypeRef_LvmHeaderResponse lhr = new SO_WS_RMS_ItemSearch.docTypeRef_LvmHeaderResponse();
        lhr.errorCode = '000';
        lhr.errorMessage = 'errorMessage';
        lhr.errorType = 'errorType';

        SO_WS_RMS_ItemSearch.DataResponse dResp = new SO_WS_RMS_ItemSearch.DataResponse();
        dResp.itemInformation = new List<SO_WS_RMS_ItemSearch.itemInformation>();

        SO_WS_RMS_ItemSearch.itemInformation iInf = new SO_WS_RMS_ItemSearch.itemInformation ();
        iInf.stockQuantity = '120';
        iInf.sellable = 'Y';
        iInf.stockStatus = 'Status';

        dResp.itemInformation.add(iInf);

        SO_WS_RMS_ItemSearch.itemSearchResponse2 iResp2 = new SO_WS_RMS_ItemSearch.itemSearchResponse2();

        iResp2.LvmHeaderResponse = lhr;
        iResp2.DataResponse = dResp;

        SO_WS_RMS_ItemSearch.itemSearchResponse iResp = new SO_WS_RMS_ItemSearch.itemSearchResponse();

        iResp.itemSearchResponse = iResp2;

        SO_WS_RMS_ItemSearch.mainServiceResponse mResp = new SO_WS_RMS_ItemSearch.mainServiceResponse();
        mResp.itemSearchResponse = iResp;


        response.put('response_x', mResp); 
   }
}