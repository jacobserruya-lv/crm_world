/**
 * This is a webservice mock class for SO_ClientSearch_TEST class
 * [For correct response errorCode need to be 000]
 * @createdBy           Nadav Lichtenshtein, 23-12-2015
 * @lastModifiedBy      Nadav Lichtenshtein, 23-12-2015
 */
@isTest
global class SO_ClientSearch_Enqiery_MOCK
// implements WebServiceMock
{
//     private String errorCode;

//     global SO_ClientSearch_Enqiery_MOCK(String errorCode){
//         this.errorCode = errorCode;
//     }
    
// 	global void doInvoke(
//            Object stub,
//            Object request,
//            Map<String, Object> response,
//            String endpoint,
//            String soapAction,
//            String requestName,
//            String responseNS,
//            String responseName,
//            String responseType) 
// 	{
// 	  	System.debug('SFDC in SO_ClientSearch_Enqiery_MOCK ');

//         /**
//          * create the false response data
//          */
//         SO_WS_RMS_ClientEnquiryV3.docTypeRef_LvmHeaderResponse lvmHeaderResponse = new SO_WS_RMS_ClientEnquiryV3.docTypeRef_LvmHeaderResponse();
//         lvmHeaderResponse.errorCode       = errorCode;
//         lvmHeaderResponse.errorMessage    = 'errorMsg';
//         lvmHeaderResponse.errorType       = 'errorType';
//         lvmHeaderResponse.warningMessage  = 'warning';

//         SO_WS_RMS_ClientEnquiryV3.docTypeRef_clientHeader client = new SO_WS_RMS_ClientEnquiryV3.docTypeRef_clientHeader();
//         client.clientOriginFirstName	= 'fname';
//         client.clientOriginSurName		= 'surname';
//         client.storeOriginFirstName		= 'storfname';
//         client.storeOriginSurName		= 'storsurname';
//         client.katakanaFirstName 		= 'katfname';
//         client.katakanaSurName 			= 'katsurname';
//         client.gender 					= 'mr';
//         client.clientTitle  			= 'title';
//         client.civility   				= 'civ';
//         client.nationality 				= 'national';
//         client.channelOfCreation 		= 'test';
//         client.emailAddress 			= 'test@mail.com';
//         client.typeOfClient 			= 'client';
//         client.preferredLanguage 		= 'english';
//         client.passportNumber 			= '12345';
//         client.companyName 				= '12345';
//         client.inactivationCode 		= 'city';
//         client.inactivationReason 		= 'country';
//         client.profession 				= 'state';
//         client.vatNumber 				= '12';
//         client.taxId 					= '123544354';
//         client.storeOfCreation 			= '534534534'; 
//         client.storeOfModification 		= '45';
//         client.dateOfCreation 			= '12';
//         client.dateOfModification 		= '23';

//         SO_WS_RMS_ClientEnquiryV3.docTypeRef_birthdate birthday = new SO_WS_RMS_ClientEnquiryV3.docTypeRef_birthdate();
// 		birthday.birthDay 	= '12';
// 		birthday.birthMonth = '2';
// 		birthday.birthYear 	= '1999';

// 		SO_WS_RMS_ClientEnquiryV3.docTypeRef_anniversary universary = new SO_WS_RMS_ClientEnquiryV3.docTypeRef_anniversary();
// 		universary.annivDay 	= '12';
// 		universary.annivMonth 	= '3';
// 		universary.annivYear 	= '2014';

// 		SO_WS_RMS_ClientEnquiryV3.docTypeRef_addressOccurences address = new SO_WS_RMS_ClientEnquiryV3.docTypeRef_addressOccurences();
// 		address.typeOfAddress 			= 'mail';
// 		address.addressLine1 			= 'add1';
// 		address.addressLine2 			= 'add2';
// 		address.addressLine3 			= 'add3';
// 		address.addressZipCode 			= '12345';
// 		address.addressCity 			= 'city';
// 		address.addressCountry 			= 'country';
// 		address.addressProvinceOrState 	= 'state';
// 		address.addressCitycode 		= '123';

// 		SO_WS_RMS_ClientEnquiryV3.docTypeRef_phoneNumbers phone = new SO_WS_RMS_ClientEnquiryV3.docTypeRef_phoneNumbers();
// 		phone.typeOfPhone 			= 'cell';
// 		phone.phoneNumberCountry 	= '12';
// 		phone.phoneNumber 			= '12423423443';
		
// 		SO_WS_RMS_ClientEnquiryV3.docTypeRef_phoneNumbers[] phoneList = new SO_WS_RMS_ClientEnquiryV3.docTypeRef_phoneNumbers[]{phone};
		
// 		SO_WS_RMS_ClientEnquiryV3.docTypeRef_communicationPreference communication = new SO_WS_RMS_ClientEnquiryV3.docTypeRef_communicationPreference();
// 		communication.typeOfCommunicationPreference = 'mail';
// 		communication.communicationPreferenceOption = 'bla';

// 		SO_WS_RMS_ClientEnquiryV3.docTypeRef_communicationPreference[] communicationList = new SO_WS_RMS_ClientEnquiryV3.docTypeRef_communicationPreference[]{communication};

//         SO_WS_RMS_ClientEnquiryV3.docTypeRef_ClientDetailEnquiryDataResponse dataresponse= new SO_WS_RMS_ClientEnquiryV3.docTypeRef_ClientDetailEnquiryDataResponse();
//         dataresponse.externalClientCode 		= '12';
//         dataresponse.rmsClientCode 				= '123';
//         dataresponse.wwRmsClientCode 			= '1234';
//         dataresponse.dreamClientCode 			= '12345';
//         dataresponse.clientHeader 				= client;
//         dataresponse.birthdate 					= birthday;	
//         dataresponse.anniversary 				= universary;	
//         dataresponse.addressOccurences  		= address;
//         dataresponse.phoneNumbers 				= phoneList;
//         dataresponse.communicationPreference 	= communicationList;

//         SO_WS_RMS_ClientEnquiryV3.ClientDetailEnquiryResponse2 clientCreation2 = new SO_WS_RMS_ClientEnquiryV3.ClientDetailEnquiryResponse2();
//         clientCreation2.LvmHeaderResponse = lvmHeaderResponse;
//         clientCreation2.DataResponse = dataresponse;

//         SO_WS_RMS_ClientEnquiryV3.clientDetailEnquiryResponse clientCreation1 = new SO_WS_RMS_ClientEnquiryV3.clientDetailEnquiryResponse(); 
//         clientCreation1.ClientDetailEnquiryResponse = clientCreation2;

//         SO_WS_RMS_ClientEnquiryV3.mainServiceResponse respElement = new SO_WS_RMS_ClientEnquiryV3.mainServiceResponse();
//         respElement.clientDetailEnquiryResponse = clientCreation1;

//         system.debug('respElement ' + respElement);
	      
//         response.put('response_x', respElement); 
// 	}
}