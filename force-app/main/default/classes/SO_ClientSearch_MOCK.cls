/**
 * This is a webservice mock class for SO_ClientSearch_TEST class
 * [For correct response errorCode need to be 000]
 * @createdBy           Nadav Lichtenshtein, 23-12-2015
 * @lastModifiedBy      Nadav Lichtenshtein, 23-12-2015
 */
@isTest
global class SO_ClientSearch_MOCK implements WebServiceMock
{
    private String errorCode;

    global SO_ClientSearch_MOCK(String errorCode){
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
	  	System.debug('SFDC in SO_ClientSearch_MOCK ');

        /**
         * create the false response data
         */
        //SO_WS_RMS_ClientSearchV3.docTypeRef_LvmHeaderResponse lvmHeaderResponse = new SO_WS_RMS_ClientSearchV3.docTypeRef_LvmHeaderResponse();
        webserviceCommon.docTypeRef_LvmHeaderResponse lvmHeaderResponse = new webserviceCommon.docTypeRef_LvmHeaderResponse();
        lvmHeaderResponse.errorCode       = errorCode;
        lvmHeaderResponse.errorMessage    = 'errorMsg';
        lvmHeaderResponse.errorType       = 'errorType';
        lvmHeaderResponse.warningMessage  = 'warning';

        //SO_WS_RMS_ClientSearchV3.docTypeRef_clientData client = new SO_WS_RMS_ClientSearchV3.docTypeRef_clientData();
        SO_WS_RMS_ClientSearchV6.docTypeRef_clientData client = new SO_WS_RMS_ClientSearchV6.docTypeRef_clientData();
        client.externalClientCode 		= '123';
        client.rmsClientCode 			= '123';
        client.wwRmsClientCode 			= '123';
        client.dreamClientCode			= '123';
        client.clientOriginFirstName	= 'fname';
        client.clientOriginSurName		= 'surname';
        client.storeOriginFirstName		= 'storfname';
        client.storeOriginSurName		= 'storsurname';
        client.katakanaFirstName 		= 'katfname';
        client.katakanaSurName 			= 'katsurname';
        client.gender 					= 'mr';
        client.clientTitle  			= 'title';
        client.civility   				= 'civ';
        client.nationality 				= 'national';
        client.emailAddress 			= 'test@mail.com';
        client.passportNumber 			= '12345';
        client.birthDay 				= '1';
        client.birthMonth 				= '12';
        client.birthYear 				= '1999';
        client.addressLine1 			= 'add1';
        client.addressLine2 			= 'add2';
        client.addressLine3 			= 'add3';
        client.addressZipCode 			= '12345';
        client.addressCity 				= 'city';
        client.addressCountry 			= 'country';
        client.addressProvinceOrState 	= 'state';
        client.addressCitycode 			= '12';
        client.homePhoneNumberCountry 	= '123544354';
        client.homePhoneNumber 			= '534534534'; 
        client.mobilePhoneNumberCountry = '45';
        client.mobilePhoneNumber 		= '6534534534';
        client.workPhoneNumberCountry 	= '23';
        client.workPhoneNumber 			= '12331234';

        //List<SO_WS_RMS_ClientSearchV3.docTypeRef_clientData> clientList = new List<SO_WS_RMS_ClientSearchV3.docTypeRef_clientData>();
        List<SO_WS_RMS_ClientSearchV6.docTypeRef_clientData> clientList = new List<SO_WS_RMS_ClientSearchV6.docTypeRef_clientData>();
        clientList.add(client);

        //SO_WS_RMS_ClientSearchV3.docTypeRef_ClientSearchDataResponse dataresponse= new SO_WS_RMS_ClientSearchV3.docTypeRef_ClientSearchDataResponse();
        SO_WS_RMS_ClientSearchV6.docTypeRef_ClientSearchDataResponse dataresponse= new SO_WS_RMS_ClientSearchV6.docTypeRef_ClientSearchDataResponse();
        dataresponse.lastRecord 				= '1';
        dataresponse.firstRecord 				= '1';
        dataresponse.noRecord 					= '0';
        dataresponse.numberOfClientsReturned 	= '1';
        dataresponse.clientData 				= clientList;

        //SO_WS_RMS_ClientSearchV3.ClientSearchResponse2 clientCreation2 = new SO_WS_RMS_ClientSearchV3.ClientSearchResponse2();
        SO_WS_RMS_ClientSearchV6.ClientSearchResponseType searchResponseType = new SO_WS_RMS_ClientSearchV6.ClientSearchResponseType();
        //clientCreation2.LvmHeaderResponse = lvmHeaderResponse;
        searchResponseType.LvmHeaderResponse = lvmHeaderResponse;
        //clientCreation2.DataResponse = dataresponse;
        searchResponseType.DataResponse = dataresponse;

        //SO_WS_RMS_ClientSearchV3.clientSearchResponse clientCreation1 = new SO_WS_RMS_ClientSearchV3.clientSearchResponse();
        SO_WS_RMS_ClientSearchV6.clientSearchResponse searchResponse = new SO_WS_RMS_ClientSearchV6.clientSearchResponse(); 
        //clientCreation1.ClientSearchResponse = clientCreation2;
        searchResponse.ClientSearchResponse = searchResponseType;

        //SO_WS_RMS_ClientSearchV3.mainServiceResponse respElement = new SO_WS_RMS_ClientSearchV3.mainServiceResponse();
        SO_WS_RMS_ClientSearchV6.mainServiceResponse_cs respElement = new SO_WS_RMS_ClientSearchV6.mainServiceResponse_cs();
        //respElement.clientSearchResponse = clientCreation1;
        respElement.clientSearchResponse = searchResponse;

	    system.debug('respElement ' + respElement);
        response.put('response_x', respElement); 
	}
}