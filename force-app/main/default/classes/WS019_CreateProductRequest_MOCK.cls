@isTest
global class WS019_CreateProductRequest_MOCK implements WebServiceMock
{ 
     private String errorCode;

     global WS019_CreateProductRequest_MOCK(String errorCode){
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
        String responseType){
            WS019_CreateProductRequest.mainServiceResponse respElement = new WS019_CreateProductRequest.mainServiceResponse();
			respElement = responseFromCreateProductRequest();
			response.put('response_x', respElement);
        }


        private WS019_CreateProductRequest.mainServiceResponse responseFromCreateProductRequest(){
            
            WS019_CreateProductRequest.docTypeRef_LvmHeaderResponse lvmHeaderResponse = new WS019_CreateProductRequest.docTypeRef_LvmHeaderResponse();
            lvmHeaderResponse.errorCode       = errorCode;
            lvmHeaderResponse.errorMessage    = 'errorMsg';
            lvmHeaderResponse.errorType       = 'errorType';
    
            WS019_CreateProductRequest.docTypeRef_reservationResponseLine items = new WS019_CreateProductRequest.docTypeRef_reservationResponseLine();
            items.errorCode ='4324323';
            items.errorMessage ='error test';
            items.skuCode = 'f34r3f4t3f';
            items.productRequestID ='4329874239423';

            WS019_CreateProductRequest.docTypeRef_reservationResponseLine[] reservationResponseLine = new WS019_CreateProductRequest.docTypeRef_reservationResponseLine[]{items};


            WS019_CreateProductRequest.DataResponse dataResponse = new WS019_CreateProductRequest.DataResponse ();
            dataResponse.reservationResponseLine  = reservationResponseLine ;
            
            WS019_CreateProductRequest.createPRResponse2 createPRResponse2 = new WS019_CreateProductRequest.createPRResponse2();
            createPRResponse2.LvmHeaderResponse = lvmHeaderResponse;
            createPRResponse2.DataResponse = dataResponse;
            
            WS019_CreateProductRequest.createPRResponse createPRResponse = new WS019_CreateProductRequest.createPRResponse();
             createPRResponse.createPRResponse =createPRResponse2 ;
            
            WS019_CreateProductRequest.mainServiceResponse respElement = new WS019_CreateProductRequest.mainServiceResponse();
                respElement.createPRResponse = createPRResponse ;
            
                return respElement;
        }
}