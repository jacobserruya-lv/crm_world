@isTest
global  class SO_CreateDepositPayment_SS_MOCK implements WebServiceMock  {

    private String errorCode;

    global SO_CreateDepositPayment_SS_MOCK(String errorCode){
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
        SO_WS_RMS_SaleServices.errors err = new SO_WS_RMS_SaleServices.errors();
        err.httpRespCode  = errorCode;
        err.httpRespMsg    = 'errorMsg';
        

        SO_WS_RMS_SaleServices.DataResponse dataresponse = new SO_WS_RMS_SaleServices.DataResponse();
        dataresponse.transactionNumber  = '12345';
        dataresponse.depositNumber		= '111';

        SO_WS_RMS_SaleServices.salesCreationResponse saleCreation1 = new SO_WS_RMS_SaleServices.salesCreationResponse();
        saleCreation1.errors = err;
        saleCreation1.DataResponse = dataresponse;

       // SO_WS_RMS_SaleServices.salesCreationResponse saleCreation1 = new SO_WS_RMS_SaleServices.salesCreationResponse(); 
      //  saleCreation1.SalesCreationResponse = saleCreation2;

        SO_WS_RMS_SaleServices.salesCreationFromNYResponse respElement = new SO_WS_RMS_SaleServices.salesCreationFromNYResponse();
        respElement.LVResponse = saleCreation1;

        system.debug('respElement ' + respElement);
	      
        response.put('response_x', respElement); 
	}
    

}