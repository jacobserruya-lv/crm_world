/**
 * This is a webservice mock class for SO_CreateUpdateRMSCLient_Utils_TEST class
 * [For correct response errorCode need to be 000]
 * @createdBy           Nadav Lichtenshtein, 23-12-2015
 * @lastModifiedBy      Nadav Lichtenshtein, 23-12-2015
 */
@isTest
global class SO_CreateUpdateRMSCLient_Utils_MOCK implements WebServiceMock 
{	
    private String errorCode;

    global SO_CreateUpdateRMSCLient_Utils_MOCK(String errorCode){
        this.errorCode = errorCode;
    }

	  global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) 
	  {
        /**
         * create the false response data
         */
        SO_WS_RMS_ClientCreationUpdate_v2.DocTypeRef_LvmHeaderResponse lvmHeaderResponse = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_LvmHeaderResponse();
        lvmHeaderResponse.errorCode       = errorCode;
        lvmHeaderResponse.errorMessage    = 'errorMsg';
        lvmHeaderResponse.errorType       = 'errorType';
        lvmHeaderResponse.warningMessage  = 'warning';

        SO_WS_RMS_ClientCreationUpdate_v2.DocTypeRef_ClientCreationUpdateDataResponse dataresponse= new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_ClientCreationUpdateDataResponse();
        dataresponse.rmsClientCode = '12345';

        SO_WS_RMS_ClientCreationUpdate_v2.ClientCreationUpdateResponse2 clientCreation2 = new SO_WS_RMS_ClientCreationUpdate_v2.ClientCreationUpdateResponse2();
        clientCreation2.LvmHeaderResponse = lvmHeaderResponse;
        clientCreation2.DataResponse = dataresponse;

        SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdateResponse clientCreation1 = new SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdateResponse(); 
        clientCreation1.ClientCreationUpdateResponse = clientCreation2;

        SO_WS_RMS_ClientCreationUpdate_v2.mainServiceResponse respElement = new SO_WS_RMS_ClientCreationUpdate_v2.mainServiceResponse();
        respElement.clientCreationUpdateResponse = clientCreation1;

        system.debug('respElement ' + respElement);
	      
        response.put('response_x', respElement); 
		}
}