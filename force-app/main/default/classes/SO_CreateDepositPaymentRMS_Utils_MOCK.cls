/**
 * This is a webservice mock class for SO_CreateDepositPaymentRMS_Utils_Test class
 * [For correct response errorCode need to be 000]
 * @createdBy           Nadav Lichtenshtein, 23-12-2015
 * @lastModifiedBy      Daniel Tal-Or, 2019-12-16
 */
@isTest
global class SO_CreateDepositPaymentRMS_Utils_MOCK //implements WebServiceMock 
{
  // private String errorCode;

  //   global SO_CreateDepositPaymentRMS_Utils_MOCK(String errorCode){
  //       this.errorCode = errorCode;
  // }
	
	// global void doInvoke(
  //          Object stub,
  //          Object request,
  //          Map<String, Object> response,
  //          String endpoint,
  //          String soapAction,
  //          String requestName,
  //          String responseNS,
  //          String responseName,
  //          String responseType) 
	// {
  //       /**
  //        * create the false response data
  //        */
  //       SO_WS_RMS_SalesCreation_v3.docTypeRef_LvmHeaderResponse lvmHeaderResponse = new SO_WS_RMS_SalesCreation_v3.docTypeRef_LvmHeaderResponse();
  //       lvmHeaderResponse.errorCode       = errorCode;
  //       lvmHeaderResponse.errorMessage    = 'errorMsg';
  //       lvmHeaderResponse.errorType       = 'errorType';
  //       lvmHeaderResponse.warningMessage  = 'warning';

  //       SO_WS_RMS_SalesCreation_v3.docTypeRef_SalesCreationDataResponse dataresponse= new SO_WS_RMS_SalesCreation_v3.docTypeRef_SalesCreationDataResponse();
  //       dataresponse.transactionNumber  = '12345';
  //       dataresponse.depositNumber		= '111';

  //       SO_WS_RMS_SalesCreation_v3.SalesCreationResponse2 saleCreation2 = new SO_WS_RMS_SalesCreation_v3.SalesCreationResponse2();
  //       saleCreation2.LvmHeaderResponse = lvmHeaderResponse;
  //       saleCreation2.DataResponse = dataresponse;

  //       SO_WS_RMS_SalesCreation_v3.salesCreationResponse saleCreation1 = new SO_WS_RMS_SalesCreation_v3.salesCreationResponse(); 
  //       saleCreation1.SalesCreationResponse = saleCreation2;

  //       SO_WS_RMS_SalesCreation_v3.mainServiceResponse respElement = new SO_WS_RMS_SalesCreation_v3.mainServiceResponse();
  //       respElement.salesCreationResponse = saleCreation1;

  //       system.debug('respElement ' + respElement);
	      
  //       response.put('response_x', respElement); 
	// }
	
}