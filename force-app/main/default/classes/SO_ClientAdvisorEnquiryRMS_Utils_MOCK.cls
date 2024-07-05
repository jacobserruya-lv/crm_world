/**
 * This is a webservice mock class for SO_ClientAdvisorEnquiryRMS_Utils_TEST class
 * [For correct response errorCode need to be 000]
 * @createdBy           Nadav Lichtenshtein	4/1/2016
 * @lastModifiedBy      Nadav Lichtenshtein	4/1/2016
 */
@isTest
global class SO_ClientAdvisorEnquiryRMS_Utils_MOCK implements WebServiceMock
{
	private String errorCode;

    global SO_ClientAdvisorEnquiryRMS_Utils_MOCK(String errorCode){
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
        SO_WS_RMS_ClientAdvisorEnquiry.docTypeRef_LvmHeaderResponse lvmHeaderResponse = new SO_WS_RMS_ClientAdvisorEnquiry.docTypeRef_LvmHeaderResponse();
        lvmHeaderResponse.errorCode       = errorCode;
        lvmHeaderResponse.errorMessage    = 'errorMsg';
        lvmHeaderResponse.errorType       = 'errorType';

        SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorDetails client = new SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorDetails();
        client.storeCode					= '123';
        client.caCode 						= '1234';
        client.profileLevel					= 'advice';
        client.longName						= 'long';
        client.localShortName				= 'short';
        client.engShortName					= 'englishname';
        client.title						= 'title';
        client.gender						= 'male';
        client.caUniqueID					= '123';
        client.localLastName				= 'loclast';
        client.localFirstName				= 'locfirst';
        client.engLastName					= 'englast';
        client.engFirstName					= 'engfirst';
        client.phoneCountryCode				= 'countryphone';
        client.phoneInternationalFormat		= 'internationalphone';
        client.phoneNationalFormat 			= 'nationalphone';
        client.emailID 						= 'mailId';
        client.activity 					= 'activity';
        client.passport 					= '12345';

        SO_WS_RMS_ClientAdvisorEnquiry.DataResponse dataresponse= new SO_WS_RMS_ClientAdvisorEnquiry.DataResponse();
        dataresponse.clientAdvisorDetails  = client;

        SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse2 clientAdvisor2 = new SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse2();
        clientAdvisor2.LvmHeaderResponse = lvmHeaderResponse;
        clientAdvisor2.DataResponse = dataresponse;

        SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse clientAdvisor1 = new SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse(); 
        clientAdvisor1.clientAdvisorEnquiryResponse = clientAdvisor2;

        SO_WS_RMS_ClientAdvisorEnquiry.mainServiceResponse respElement = new SO_WS_RMS_ClientAdvisorEnquiry.mainServiceResponse();
        respElement.clientAdvisorEnquiryResponse = clientAdvisor1;

        system.debug('respElement ' + respElement);
	      
        response.put('response_x', respElement); 
	}
	
}