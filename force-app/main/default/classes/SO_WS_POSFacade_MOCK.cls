@isTest
public with sharing class SO_WS_POSFacade_MOCK implements WebServiceMock  {

    private String errorCode;
    private String testFunctionName;
    private String extraParameter;

    public SO_WS_POSFacade_MOCK(String errorCode, String testFunctionName, String extraParameter){
        this.errorCode = errorCode;
        this.testFunctionName = testFunctionName;
        this.extraParameter = extraParameter;
    }

    public void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType){
            
        if(this.testFunctionName == 'test_clientSearch1' || this.testFunctionName == 'test_class_SO_WS_RMS_DoClientSearch'){
          //  SO_WS_RMS_ClientSearchV3.mainServiceResponse respElement = responseFromClientSearchRequest();
           SO_WS_RMS_ClientSearchV6.mainServiceResponse_cs respElement = responseFromClientSearchRequest();
            response.put('response_x', respElement);
        }

        else if(this.testFunctionName == 'test_clientSearch2' || this.testFunctionName == 'test_class_SO_WS_RMS_DoClientEnquiry'){
          SO_WS_RMS_ClientEnquiryV1.mainServiceResponse_cde respElement = responseFromClientEnquiryRequest();
          response.put('response_x', respElement);
      }

        else if(this.testFunctionName == 'test_createDepositOrPayment2'){
            WS019_CreateDeposit.salesCreationFromNYResponse respElement = responseFromSalesCreationFromNYRequest();
            response.put('response_x', respElement);
        }

        System.debug(this.testFunctionName + ' - response : ' + response);
    }

 //   private SO_WS_RMS_ClientSearchV3.mainServiceResponse responseFromClientSearchRequest(){
    private SO_WS_RMS_ClientSearchV6.mainServiceResponse_cs responseFromClientSearchRequest(){
    //    SO_WS_RMS_ClientSearchV3.docTypeRef_clientData clientData = new SO_WS_RMS_ClientSearchV3.docTypeRef_clientData();
        SO_WS_RMS_ClientSearchV6.docTypeRef_clientData clientData = new SO_WS_RMS_ClientSearchV6.docTypeRef_clientData();
        clientData.externalClientCode = 'externalClientCode';
        clientData.rmsClientCode = 'rmsClientCode';
        clientData.wwRmsClientCode = 'wwRmsClientCode';
        clientData.dreamClientCode = 'dreamClientCode';
        clientData.clientOriginFirstName = 'clientOriginFirstName';
        clientData.clientOriginSurName = 'clientOriginSurName';
        clientData.storeOriginFirstName = 'storeOriginFirstName';
        clientData.storeOriginSurName = 'storeOriginSurName';
        clientData.katakanaFirstName = 'katakanaFirstName';
        clientData.katakanaSurName = 'katakanaSurName';
        clientData.gender = 'gender';
        clientData.clientTitle = 'clientTitle';
        clientData.civility = 'civility';
        clientData.nationality = 'nationality';
        clientData.emailAddress = 'emailAddress';
        clientData.passportNumber = 'passportNumber';
        clientData.birthDay = 'birthDay';
        clientData.birthMonth = 'birthMonth';
        clientData.birthYear = 'birthYear';
        clientData.addressLine1 = 'addressLine1';
        clientData.addressLine2 = 'addressLine2';
        clientData.addressLine3 = 'addressLine3';
        clientData.addressZipCode = 'addressZipCode';
        clientData.addressCity = 'addressCity';
        clientData.addressCountry = 'addressCountry';
        clientData.addressProvinceOrState = 'addressProvinceOrState';
        clientData.addressCitycode = 'addressCitycode';
        clientData.homePhoneNumberCountry = 'homePhoneNumberCountry';
        clientData.homePhoneNumber = 'homePhoneNumber';
        clientData.mobilePhoneNumberCountry = 'mobilePhoneNumberCountry';
        clientData.mobilePhoneNumber = 'mobilePhoneNumber';
        clientData.workPhoneNumberCountry = 'workPhoneNumberCountry';
        clientData.workPhoneNumber = 'workPhoneNumber';

        if(extraParameter == null){
            clientData = null;
        }

      //  SO_WS_RMS_ClientSearchV3.docTypeRef_clientData[] clientsData = new SO_WS_RMS_ClientSearchV3.docTypeRef_clientData[]{clientData};
        SO_WS_RMS_ClientSearchV6.docTypeRef_clientData[] clientsData = new SO_WS_RMS_ClientSearchV6.docTypeRef_clientData[]{clientData}; 

       // SO_WS_RMS_ClientSearchV3.docTypeRef_LvmHeaderResponse lvmHeaderResponse = new SO_WS_RMS_ClientSearchV3.docTypeRef_LvmHeaderResponse();
        webserviceCommon.docTypeRef_LvmHeaderResponse lvmHeaderResponse = new webserviceCommon.docTypeRef_LvmHeaderResponse();
        lvmHeaderResponse.errorCode = errorCode;
        lvmHeaderResponse.errorMessage = 'errorMsg';
        lvmHeaderResponse.errorType = 'errorType';
        lvmHeaderResponse.warningMessage = 'warningMessage';

      //  SO_WS_RMS_ClientSearchV3.docTypeRef_ClientSearchDataResponse dataResponse = new SO_WS_RMS_ClientSearchV3.docTypeRef_ClientSearchDataResponse();
        SO_WS_RMS_ClientSearchV6.docTypeRef_ClientSearchDataResponse dataResponse = new SO_WS_RMS_ClientSearchV6.docTypeRef_ClientSearchDataResponse();
        dataResponse.clientData = clientsData;
        dataResponse.lastRecord = 'lastRecord';
        dataResponse.firstRecord = 'firstRecord';
        dataResponse.noRecord = extraParameter;
        dataResponse.numberOfClientsReturned = 'numberOfClientsReturned';
        
        //SO_WS_RMS_ClientSearchV3.ClientSearchResponse2 clientSearchResponse2 = new SO_WS_RMS_ClientSearchV3.ClientSearchResponse2();
        SO_WS_RMS_ClientSearchV6.ClientSearchResponseType clientSearchResponseType = new SO_WS_RMS_ClientSearchV6.ClientSearchResponseType();
      //  clientSearchResponse2.LvmHeaderResponse = lvmHeaderResponse;
         clientSearchResponseType.LvmHeaderResponse = lvmHeaderResponse;
       // clientSearchResponse2.DataResponse = dataResponse;
        clientSearchResponseType.DataResponse = dataResponse;          
      //  SO_WS_RMS_ClientSearchV3.clientSearchResponse clientSearchResponse = new SO_WS_RMS_ClientSearchV3.clientSearchResponse();
        SO_WS_RMS_ClientSearchV6.clientSearchResponse clientSearchResponse = new SO_WS_RMS_ClientSearchV6.clientSearchResponse();
       // clientSearchResponse.ClientSearchResponse = clientSearchResponse2;
        clientSearchResponse.ClientSearchResponse = clientSearchResponseType;        
       // SO_WS_RMS_ClientSearchV3.mainServiceResponse mainServiceResponse = new SO_WS_RMS_ClientSearchV3.mainServiceResponse(); 
        SO_WS_RMS_ClientSearchV6.mainServiceResponse_cs mainServiceResponse_cs = new SO_WS_RMS_ClientSearchV6.mainServiceResponse_cs(); 
      // 	mainServiceResponse.clientSearchResponse = clientSearchResponse;
        mainServiceResponse_cs.clientSearchResponse = clientSearchResponse;
      //  System.debug('test_clientSearch1 - mainServiceResponse : ' + mainServiceResponse);    
        System.debug('test_clientSearch1 - mainServiceResponse_cs : ' + mainServiceResponse_cs);
        
       // return mainServiceResponse;
        return mainServiceResponse_cs;
    }

    private SO_WS_RMS_ClientEnquiryV1.mainServiceResponse_cde responseFromClientEnquiryRequest(){
      SO_WS_RMS_ClientEnquiryV1.docTypeRef_clientHeader clientHeader = new SO_WS_RMS_ClientEnquiryV1.docTypeRef_clientHeader();
      clientHeader.clientOriginFirstName = 'clientOriginFirstName';
      clientHeader.clientOriginSurName = 'clientOriginSurName';
      clientHeader.storeOriginFirstName = 'storeOriginFirstName';
      clientHeader.storeOriginSurName = 'storeOriginSurName';
      clientHeader.katakanaFirstName = 'katakanaFirstName';
      clientHeader.katakanaSurName = 'katakanaSurName';
      clientHeader.gender = 'gender';
      clientHeader.clientTitle = 'clientTitle';
      clientHeader.civility = 'civility';
      clientHeader.nationality = 'nationality';
      clientHeader.channelOfCreation = 'channelOfCreation';
      clientHeader.emailAddress = 'emailAddress';
      clientHeader.typeOfClient = 'typeOfClient';
      clientHeader.preferredLanguage = 'preferredLanguage';
      clientHeader.passportNumber = 'passportNumber';
      clientHeader.companyName = 'companyName';
      clientHeader.inactivationCode = 'inactivationCode';
      clientHeader.inactivationReason = 'inactivationReason';
      clientHeader.profession = 'profession';
      clientHeader.vatNumber = 'vatNumber';
      clientHeader.taxId = 'taxId';
      clientHeader.storeOfCreation = 'storeOfCreation';
      clientHeader.storeOfModification = 'storeOfModification';
      clientHeader.dateOfCreation = 'dateOfCreation';
      clientHeader.dateOfModification = 'dateOfModification';

      webserviceCommon.docTypeRef_birthdate birthdate = new webserviceCommon.docTypeRef_birthdate();
      birthdate.birthDay = (extraParameter == null) ? '1' : extraParameter;
      birthdate.birthMonth = (extraParameter == null) ? '10' : extraParameter;
      birthdate.birthYear = (extraParameter == null) ? '1900' : extraParameter;

      webserviceCommon.docTypeRef_anniversary anniversary = new webserviceCommon.docTypeRef_anniversary();
      anniversary.annivDay = '1';
      anniversary.annivMonth = '1';
      anniversary.annivYear = '1900';

      SO_WS_RMS_ClientEnquiryV1.docTypeRef_addressOccurences addressOccurences = new SO_WS_RMS_ClientEnquiryV1.docTypeRef_addressOccurences();
      addressOccurences.typeOfAddress = 'typeOfAddress';
      addressOccurences.addressLine1 = 'addressLine1';
      addressOccurences.addressLine2 = 'addressLine2';
      addressOccurences.addressLine3 = 'addressLine3';
      addressOccurences.addressZipCode = 'addressZipCode';
      addressOccurences.addressCity = 'addressCity';
      addressOccurences.addressCountry = 'addressCountry';
      addressOccurences.addressProvinceOrState = 'addressProvinceOrState';
      addressOccurences.addressCitycode = 'addressCitycode';

      webserviceCommon.docTypeRef_phoneNumbers phoneNumber = new webserviceCommon.docTypeRef_phoneNumbers();
      phoneNumber.typeOfPhone = extraParameter;
      phoneNumber.phoneNumberCountry = 'phoneNumberCountry';
      phoneNumber.phoneNumber = 'phoneNumber';
      webserviceCommon.docTypeRef_phoneNumbers[] phoneNumbers = new webserviceCommon.docTypeRef_phoneNumbers[]{phoneNumber};

      webserviceCommon.docTypeRef_communicationPreference communicationPreference = new webserviceCommon.docTypeRef_communicationPreference();
      communicationPreference.typeOfCommunicationPreference = 'typeOfCommunicationPreference';
      communicationPreference.communicationPreferenceOption = 'communicationPreferenceOption';
      webserviceCommon.docTypeRef_communicationPreference[] communicationPreferences = new webserviceCommon.docTypeRef_communicationPreference[]{communicationPreference};

      webserviceCommon.docTypeRef_contactPreferences contactPreference = new webserviceCommon.docTypeRef_contactPreferences();
      contactPreference.typeOfContactPreference = extraParameter;
      contactPreference.contactPreferenceOption = 'contactPreferenceOption';
      webserviceCommon.docTypeRef_contactPreferences[] contactPreferences = new webserviceCommon.docTypeRef_contactPreferences[]{contactPreference};

      webserviceCommon.docTypeRef_comments comment = new webserviceCommon.docTypeRef_comments();
      comment.commentLineNumber = '0';
      comment.comment = 'comment';
      webserviceCommon.docTypeRef_comments[] comments = new webserviceCommon.docTypeRef_comments[]{comment};

      webserviceCommon.docTypeRef_LvmHeaderResponse lvmHeaderResponse = new webserviceCommon.docTypeRef_LvmHeaderResponse();
      lvmHeaderResponse.errorCode = errorCode;
      lvmHeaderResponse.errorMessage = 'errorMsg';
      lvmHeaderResponse.errorType = 'errorType';
      lvmHeaderResponse.warningMessage = 'warningMessage';
      
      SO_WS_RMS_ClientEnquiryV1.docTypeRef_ClientDetailEnquiryDataResponse dataResponse = new SO_WS_RMS_ClientEnquiryV1.docTypeRef_ClientDetailEnquiryDataResponse();
      dataResponse.externalClientCode = '12';
      dataResponse.rmsClientCode = '123456789';
      dataResponse.wwRmsClientCode = '987654321';
      dataResponse.dreamClientCode = '21';
      dataResponse.clientHeader = clientHeader;
      dataResponse.birthdate = birthdate;
      dataResponse.anniversary = anniversary;
      dataResponse.addressOccurences = addressOccurences;
      dataResponse.phoneNumbers = phoneNumbers;
      dataResponse.communicationPreference = communicationPreferences;
      dataResponse.contactPreferences = contactPreferences;
      dataResponse.comments = comments;
      
      SO_WS_RMS_ClientEnquiryV1.ClientDetailEnquiryResponse ClientDetailEnquiryResponse2 = new SO_WS_RMS_ClientEnquiryV1.clientDetailEnquiryResponse();
      clientDetailEnquiryResponse2.LvmHeaderResponse = lvmHeaderResponse;
      clientDetailEnquiryResponse2.DataResponse = dataResponse;

      SO_WS_RMS_ClientEnquiryV1.clientDetailEnquiryResponseType clientDetailEnquiryResponse = new SO_WS_RMS_ClientEnquiryV1.clientDetailEnquiryResponseType();
      clientDetailEnquiryResponse.ClientDetailEnquiryResponse = clientDetailEnquiryResponse2;
      
      SO_WS_RMS_ClientEnquiryV1.mainServiceResponse_cde mainServiceResponse_cde = new SO_WS_RMS_ClientEnquiryV1.mainServiceResponse_cde();
      mainServiceResponse_cde.clientDetailEnquiryResponseType = clientDetailEnquiryResponse;

      System.debug('test_clientSearch1 - mainServiceResponse : ' + mainServiceResponse_cde);

      return mainServiceResponse_cde;
  }

    private WS019_CreateDeposit.salesCreationFromNYResponse responseFromSalesCreationFromNYRequest(){
        WS019_CreateDeposit.error error = new WS019_CreateDeposit.error();
        error.code = 'code';
        error.level = 'level';
        error.source = 'source';
        error.httpRespMsg = 'httpRespMsg';
        error.timestamp = 'timestamp';

        WS019_CreateDeposit.error[] errorList = new WS019_CreateDeposit.error[]{error};        

        WS019_CreateDeposit.DataResponse dataResponse = new WS019_CreateDeposit.DataResponse();
        dataResponse.transactionNumber = '1';
        dataResponse.depositNumber = '1';
        
        WS019_CreateDeposit.errors errors = new WS019_CreateDeposit.errors();
        errors.error = errorList;
        errors.httpRespCode = 'httpRespCode';
        errors.httpRespMsg = 'httpRespMsg';
        
        WS019_CreateDeposit.salesCreationResponse lvResponse = new WS019_CreateDeposit.salesCreationResponse();
        lvResponse.DataResponse = dataResponse;
        lvResponse.errors = errors;

        WS019_CreateDeposit.salesCreationFromNYResponse mainServiceResponse = new WS019_CreateDeposit.salesCreationFromNYResponse();
        mainServiceResponse.LVResponse = lvResponse;

        System.debug('test_createDepositOrPayment2 - mainServiceResponse : ' + mainServiceResponse);

        return mainServiceResponse;
    }

    private SO_WS_RMS_ClientAdvisorEnquiry.mainServiceResponse responseFromClientAdvisorEnquiryRequest(){
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

        SO_WS_RMS_ClientAdvisorEnquiry.DataResponse dataResponse= new SO_WS_RMS_ClientAdvisorEnquiry.DataResponse();
        dataResponse.clientAdvisorDetails  = client;

        SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse2 clientAdvisor2 = new SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse2();
        clientAdvisor2.LvmHeaderResponse = lvmHeaderResponse;
        clientAdvisor2.DataResponse = dataResponse;

        SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse clientAdvisor1 = new SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse(); 
        clientAdvisor1.clientAdvisorEnquiryResponse = clientAdvisor2;

        SO_WS_RMS_ClientAdvisorEnquiry.mainServiceResponse mainServiceResponse = new SO_WS_RMS_ClientAdvisorEnquiry.mainServiceResponse();
        mainServiceResponse.clientAdvisorEnquiryResponse = clientAdvisor1;

        System.debug('test_class_SO_WS_RMS_DoClientEnquiry - mainServiceResponse : ' + mainServiceResponse);

        return mainServiceResponse;
    }
}