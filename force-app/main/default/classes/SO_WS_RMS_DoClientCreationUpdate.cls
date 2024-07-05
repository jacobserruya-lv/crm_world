/*
Class SO_WS_RMS_DoClientCreationUpdate
BW - 18/10/2015
*/

public with sharing class SO_WS_RMS_DoClientCreationUpdate {

    // To test ----------------------------------------------------------------------
    
    public static string callToTest(Boolean use_v5) {
        SO_WS_RMS_DoClientCreationUpdate ws = new SO_WS_RMS_DoClientCreationUpdate();
        SO_WS_RMS_DoClientCreationUpdate.DataInput dataIn = new SO_WS_RMS_DoClientCreationUpdate.DataInput();

        
        dataIn.storeCode = 'A06';      // StoreCode is Mandatory
        dataIn.RMSId = '';           // rmsClientCode - If it exists, it's an update.If it doesn't exist, it is a creation
        dataIn.dreamId = '';         // dreamClientCode
        dataIn.firstName = 'Esther';      // Mandatory
        dataIn.lastName = 'Test';    // Mandatory
        dataIn.firstName2 = '';        // katakanaFirstName
        dataIn.lastName2 = '';        // katakanaSurnameName;
        dataIn.title = '02';        // Mandatory and must be a valid value
        dataIn.nationality = 'FRA';      // Code ISO
        dataIn.channelOfCreation = '';    // Always empty
        dataIn.typeOfClient = '7';      // 1=XXX 5=LVMH 6=LVM 7=Prospect(default when creation) 9=VIP  
        dataIn.preferredLanguage = '';    // Preferred language
        dataIn.passportNumber = '';
        dataIn.company = '';        
        //dataIn.inactivationCode;  
        //dataIn.inactivationReason;
        //dataIn.profession;
        dataIn.primaryAddressLine1 = '12 rue de la paix';
        dataIn.primaryAddressLine2 = '';
        dataIn.primaryAddressLine3 = '';
        dataIn.primaryAddressZipCode = '75002';
        dataIn.primaryAddressCity = 'Paris';
        dataIn.primaryAddressCountry = 'FRA';
        dataIn.primaryAddressProvinceOrState = '';
        //dataIn.addressCounty = '';
        dataIn.homePhoneNumberCountry = 'FR';        // typeOfPhone1 : 1  
        dataIn.homePhoneNumber = '061432676579';      
        dataIn.mobilePhoneNumberCountry = 'FR';      // typeOfPhone1 : 2
        dataIn.mobilePhoneNumber = '0657367499';    
        dataIn.workPhoneNumberCountry = 'FR';        // typeOfPhone1 : 3
        dataIn.workPhoneNumber = '061432676570';        

    dataIn.birthdateDay = '28';
    dataIn.birthDateMonth = '5';
    dataIn.birthDateYear = '1972';

        dataIn.PersonDoNotCall = true;
        dataIn.DoNotSMS = false;
        dataIn.DoNotContactbyPost = true;
        dataIn.PersonHasOptedOutOfEmail = false;
  
        dataIn.personalEmail = 'esthertest@gmail.com';
        dataIn.vatNumber = '1';
        dataIn.taxId = '2';

        if(use_v5){
            System.debug('v5 test');
            SO_WS_RMS_DoClientCreationUpdate.Result result = ws.doClientCreationUpdatev5(dataIn);
        }
        else
        {
            System.debug('original test');
            SO_WS_RMS_DoClientCreationUpdate.Result result = ws.doClientCreationUpdate(dataIn);
        }
        return 'OK';
    }

    // TRANSCODIFICATION AND WS CALL -----------------------------------------------------------------
    
    public Result doClientCreationUpdate (DataInput dataIn) {
        String err = validateInput(dataIn);
        if (!String.isBlank(err)) {
            Result res = new Result();
            res.error = err;
            return res;
        }
        
        SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdate wsMsg = makeMsg (dataIn);        
        SO_WS_RMS_ClientCreationUpdate_v2.WSLV004_webService_v2_0_clientCreationUpdate_Port stub = new SO_WS_RMS_ClientCreationUpdate_v2.WSLV004_webService_v2_0_clientCreationUpdate_Port();   
        stub.timeout_x = SO_WS_Utils.getWSTimeOut();
        stub.endpoint_x = SO_WS_Utils.getEndPoint('ClientCreationUpdate');

        Result Res;
        if (!SO_WS_Utils.runForTest()) {
            SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdateResponse wsResp = stub.mainService (wsMsg);
            res = getOutput(wsResp);
        }
        else {
            // Just to test without any call to the web service
            SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdateResponse wsResp;
            res = getOutput(wsResp);
            res.RMSId = '01JR0V';
        }       
        System.debug('+++++ ' + res);
        return res;
    }

    public Result doClientCreationUpdatev5 (DataInput dataIn) {
        System.debug('Enter doClientCreationUpdatev5');
        String err = validateInput(dataIn);
        if (!String.isBlank(err)) {
            Result res = new Result();
            res.error = err;
            return res;
        }
        
        SO_WS_RMS_ClientCreationUpdate_v5.clientCreationUpdate wsMsg = makeMsg_v5 (dataIn); 
        System.debug('wsMsg' + wsMsg);       
        // SO_WS_RMS_ClientCreationUpdate_v5.WSLV004_webService_v5_0_clientCreationUpdate_Port stub = new SO_WS_RMS_ClientCreationUpdate_v5.WSLV004_webService_v5_0_clientCreationUpdate_Port();   
        // stub.timeout_x = SO_WS_Utils.getWSTimeOut();
        // stub.endpoint_x = SO_WS_Utils.getEndPoint('ClientCreationUpdate');

        Result Res;
        if ( !Test.isRunningTest() && !SO_WS_Utils.runForTest()) {
            System.debug('not in run for test');
            SO_WS_RMS_ClientCreationUpdate_v5.clientCreationUpdateResponse wsResp = invoke_v5 (wsMsg);
            res = getOutput_v5(wsResp);
        }
        else {
            // Just to test without any call to the web service
            SO_WS_RMS_ClientCreationUpdate_v5.clientCreationUpdateResponse wsResp;
            res = getOutput_v5(wsResp);
            res.RMSId = '01JR0V';
        }       
        System.debug('+++++ ' + res);
        return res;
    }

    public SO_WS_RMS_ClientCreationUpdate_v5.clientCreationUpdateResponse invoke_v5(SO_WS_RMS_ClientCreationUpdate_v5.clientCreationUpdate wsMsg) {
        XMLSerializer serializer = new XMLSerializer();
        String serializedXML = serializer.serialize(wsMsg,true, null);
        // String body = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:cli="http://WSLV004/webService.v5_0/clientCreationUpdate"> <soap:Header/> <soap:Body> <cli:mainService><clientCreationUpdate>'+serializedXML+'</clientCreationUpdate></cli:mainService> </soap:Body> </soap:Envelope>';
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cli="http://WSLV004/webService/v6_0/clientCreationUpdate"> <soapenv:Header/> <soapenv:Body> <cli:mainService_ccu><clientCreationUpdate>'+serializedXML+'</clientCreationUpdate></cli:mainService_ccu> </soapenv:Body> </soapenv:Envelope>';
        system.debug(body);
        HTTP_UTILS httpUtils = new HTTP_UTILS()
            // .post('callout:NY_EAI/ws/EAI_clientCreationUpdate/5.0.0')
            .post('callout:SOCIAL')
            .header('Content-Type', 'application/xml')

            // .header('Content-Type', 'application/soap+xml')
            // .header('SoapAction', 'WSLV004_webService_v5_0_clientCreationUpdate_Binder_mainService')
            .timeout(30000)
            //.header('Authorization','Basic U0ZVc2VyOlNGVXNlckxWMjAxNyo=')
            .body(body)
            .call();
        String response = httpUtils.responseBody();
        system.debug(response);
        if(String.isBlank(response)) {
            return  null;
        }
        // response = response.replace('<?xml version=\'1.0\' encoding=\'UTF-8\'?><soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope"><soapenv:Body><ser-root:mainServiceResponse xmlns:ser-root="http://WSLV004/webService.v5_0/clientCreationUpdate" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><clientCreationUpdateResponse>', '');
        response = response.replace('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><ccu:mainServiceResponse_ccu xmlns:ccu="http://WSLV004/webService/v6_0/clientCreationUpdate">', '');
        response  = response.replace('<clientCreationUpdateResponse>','');
        // response = response.replace('</clientCreationUpdateResponse></ser-root:mainServiceResponse></soapenv:Body></soapenv:Envelope>', '');
        response = response.replace('</clientCreationUpdateResponse>', '');
        response = response.replace('</ccu:mainServiceResponse_ccu></soapenv:Body></soapenv:Envelope>', '');
        response = response.replaceAll('xsi:nil="true"', '');
        System.debug('RESPONSE TO PARSE'+response);
        SO_WS_RMS_ClientCreationUpdate_v5.clientCreationUpdateResponse deSerializedLibrary = (SO_WS_RMS_ClientCreationUpdate_v5.clientCreationUpdateResponse)serializer.deSerialize(response,SO_WS_RMS_ClientCreationUpdate_v5.clientCreationUpdateResponse.class);
        System.debug(deSerializedLibrary);
        return deSerializedLibrary;
    }



    // Input ---------------------------------------------------------------------------
    
    public class DataInput {
        
        public String storeCode;                // Mandatory
        public String RMSId;                    // rmsClientCode - If it exists, it's an update. If it doesn't exist, it is a creation
        public String WW_RMSId;                    // rmsClientCode - If it exists, it's an update. If it doesn't exist, it is a creation
        public String dreamId;                  // dreamClientCode
        public String firstName;                // Mandatory
        public String lastName;                 // Mandatory
        public String firstName2;               // katakanaFirstName
        public String lastName2;                // katakanaSurnameName;
        public String title;                    // Civility
        public String nationality;              // Code ISO
        public String channelOfCreation;
        public String preferredContactChannel;  // contactability : 1=E-mails 2=Postal mails 3=Calls 4=SMS/MMS      
        public String typeOfClient;             // 1=XXX 5=LVMH 6=LVM 7=Prospect(default) 9=VIP  
        public String preferredLanguage;        // Preferred language
        public String passportNumber;           // pasportNumber;
        public String company;              
        public String personalEmail;
        public String vatNumber;
        public String taxId;
        //public String inactivationCode;   
        //public String inactivationReason;
        //public String profession;
        public String birthdateDay;
        public String birthdateMonth;
        public String birthdateYear;
        
        public Boolean PersonDoNotCall;
        public Boolean DoNotSMS;
        public Boolean DoNotContactbyPost;
        public Boolean PersonHasOptedOutOfEmail;

        public Boolean IsBoundInMyLV;
        public Boolean IsBoundInWechat;
        public Boolean IsBoundInLine;
        public Boolean IsBoundInKakao;

        public String primaryAddressLine1;
        public String primaryAddressLine2;
        public String primaryAddressLine3;
        public String primaryAddressZipCode;
        public String primaryAddressCity;
        public String primaryAddressCountry;
        public String primaryAddressProvinceOrState;
        //public String address1County;
        public String homePhoneNumberCountry;       // internationalCountryCodePhoneNumber1
        public String homePhoneNumber;              //personalPhoneNumber
        public String mobilePhoneNumberCountry;     // internationalCountryCodePhoneNumber2
        public String mobilePhoneNumber;            // mobilePhoneNumber
        public String workPhoneNumberCountry;       // internationalCountryCodePhoneNumber3
        public String workPhoneNumber;              // professionalPhoneNumber

        //public String commentsLine1;
        //public String commentsLine2;
    }

    private string validateInput(DataInput dataIn){
        if (String.isEmpty(dataIn.typeOfClient) && String.isBlank(dataIn.RMSId)) dataIn.TypeOfClient = '7';     // Prospect
        if (String.isEmpty(dataIn.firstName) || String.isEmpty(dataIn.lastName)) return 'Firstname and Lastname are mandatory';
        return '';
    }

    private SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdate makeMsg(DataInput dataIn) {

        SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_clientHeader clientHeader = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_clientHeader();
        
        clientHeader.storeOriginFirstName = dataIn.FirstName;       // Mandatory
        clientHeader.storeOriginSurName = dataIn.lastName;      // Mandatory
        //clientHeader.clientOriginFirstName = dataIn.FirstName;
        //clientHeader.clientOriginLastName = dataIn.lastName;
        clientHeader.katakanaFirstName = String.isBlank(dataIn.firstName2) ? '' : dataIn.firstName2;
        clientHeader.katakanaSurName = String.isBlank(dataIn.lastName2) ? '' : dataIn.lastName2;
        clientHeader.gender = '';
        //clientHeader.clientTitle = dataIn.Title;
        clientHeader.civility = dataIn.title;
        clientHeader.nationality = dataIn.nationality;
        clientHeader.channelOfCreation = dataIn.channelOfCreation;
        clientHeader.eMailAddress = dataIn.personalEmail;
        clientHeader.typeOfClient = dataIn.typeOfClient;
        clientHeader.preferredLanguage = dataIn.preferredLanguage;
        clientHeader.passportNumber = dataIn.passportNumber;
        clientHeader.companyName = dataIn.company;
        //clientHeader.inactivationCode = '';
        //clientHeader.inactivationReason = '';
        clientHeader.profession = '';
        clientHeader.vatNumber = dataIn.vatNumber;
        clientHeader.taxId = dataIn.taxId;  
        
        SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_ClientCreationUpdateData client = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_ClientCreationUpdateData(); 

        client.applicationOrigin = '8';         // SPO Code  (1 pour MyPerso)
        client.storeCode = dataIn.storeCode;                
        client.rmsClientCode = dataIn.RMSId;    // Empty in creation
        client.dreamClientCode = dataIn.dreamId;
        client.clientHeader = clientHeader;

        if (!String.isBlank(dataIn.primaryAddressLine1) || !String.isBlank(dataIn.primaryAddressLine2) || !String.isBlank(dataIn.primaryAddressLine3) || !String.isBlank(dataIn.primaryAddressZipCode) || !String.isBlank(dataIn.primaryAddressCity) || !String.isBlank(dataIn.primaryAddressCountry) || !String.isBlank(dataIn.primaryAddressProvinceOrState)) {
            SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_addressOccurences address = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_addressOccurences();
            address.addressLine1 = dataIn.primaryAddressLine1;
            address.addressLine2 = dataIn.primaryAddressLine2;
            address.addressLine3 = dataIn.primaryAddressLine3;
            address.addressZipCode = dataIn.primaryAddressZipCode;
            address.addressCity = dataIn.primaryAddressCity;
            address.addressCountry = dataIn.primaryAddressCountry;
            address.addressProvinceOrState = dataIn.primaryAddressProvinceOrState;
            //address.addressCityCode = '';
            client.addressOccurences = address;
        }

        SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_phoneNumbers homePhone; 
        if (!String.isBlank(dataIn.homePhoneNumber) && String.isNotBlank(dataIn.HomePhoneNumberCountry)) {
             homePhone = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_phoneNumbers();
             homePhone.typeOfPhone = '1';  // Home
             homePhone.phoneNumber = dataIn.homePhoneNumber;
             homePhone.phoneNumberCountry = dataIn.homePhoneNumberCountry;
        }
        SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_phoneNumbers mobilePhone;
        if (!String.isBlank(dataIn.mobilePhoneNumber)) {
             mobilePhone = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_phoneNumbers();
             mobilePhone.typeOfPhone = '2';  // mobile
             mobilePhone.phoneNumber = dataIn.mobilePhoneNumber;
             mobilePhone.phoneNumberCountry = dataIn.mobilePhoneNumberCountry;
        }
        SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_phoneNumbers workPhone;
        if (!String.isBlank(dataIn.workPhoneNumber) && String.isNotBlank(dataIn.WorkPhoneNumberCountry)) {
             workPhone = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_phoneNumbers();
             workPhone.typeOfPhone = '3';  // work
             workPhone.phoneNumber = dataIn.workPhoneNumber;
             workPhone.phoneNumberCountry = dataIn.workPhoneNumberCountry;
        }
        
        if (homePhone != null || mobilePhone != null || workPhone != null) {
            SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_phoneNumbers[] phones = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_phoneNumbers[] {};
            if (homePhone != null) phones.add(homePhone); 
            if (mobilePhone != null) phones.add(mobilePhone); 
            if (workPhone != null) phones.add(workPhone);
            client.phoneNumbers = phones;
        }
        
        if (!String.isBlank(dataIn.birthdateMonth) || !String.isBlank(dataIn.birthdateMonth) || !String.isBlank(dataIn.birthdateMonth)) {
            SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_birthdate birthdate = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_birthdate();
            if (!String.isBlank(dataIn.birthdateDay)) birthdate.birthDay = dataIn.birthdateDay;
            if (!String.isBlank(dataIn.birthdateMonth)) birthdate.birthMonth = dataIn.birthdateMonth;
            if (!String.isBlank(dataIn.birthdateYear)) birthdate.birthYear = dataIn.birthdateYear;
            client.birthDate = birthdate;
        }
        
        SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_contactPreferences[] contPref = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_contactPreferences[] {};

        SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_contactPreferences cp1 = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_contactPreferences();
        cp1.typeOfContactPreference = '1';
        cp1.contactPreferenceOption = dataIn.PersonHasOptedOutOfEmail !=null ? '0' : '1';
        contPref.add(cp1);

        SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_contactPreferences cp2 = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_contactPreferences();
        cp2.typeOfContactPreference = '2';
        cp2.contactPreferenceOption = dataIn.DoNotContactbyPost !=  null ? '0' : '1';
        contPref.add(cp2);

        SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_contactPreferences cp3 = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_contactPreferences();
        cp3.typeOfContactPreference = '3';
        cp3.contactPreferenceOption = dataIn.PersonDoNotCall != null ? '0' : '1';
        contPref.add(cp3);

        SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_contactPreferences cp4 = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_contactPreferences();
        cp4.typeOfContactPreference = '4';
        cp4.contactPreferenceOption =  dataIn.DoNotSMS != null ? '0' : '1';
        contPref.add(cp4);

        client.contactPreferences = contPref;

        SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_LvmHeader lvmHeader = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_LvmHeader();
        lvmHeader.version = '1.0';
        lvmHeader.consumer = 'SPO';
                
        SO_WS_RMS_ClientCreationUpdate_v2.ClientCreationUpdate2 headers = new SO_WS_RMS_ClientCreationUpdate_v2.ClientCreationUpdate2();
        headers.LvmHeader = lvmHeader;
        headers.Data = client;

        SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdate wsMsg = new SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdate();
        wsMsg.ClientCreationUpdate = headers;

        System.debug('++++ ' + wsMsg);        
        return wsMsg;
    }
    

    private SO_WS_RMS_ClientCreationUpdate_v5.clientCreationUpdate makeMsg_v5(DataInput dataIn) {

        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_clientHeader clientHeader = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_clientHeader();
        
        clientHeader.storeOriginFirstName = dataIn.FirstName;       // Mandatory
        clientHeader.storeOriginSurName = dataIn.lastName;      // Mandatory
        //clientHeader.clientOriginFirstName = dataIn.FirstName;
        //clientHeader.clientOriginLastName = dataIn.lastName;
        clientHeader.katakanaFirstName = String.isBlank(dataIn.firstName2) ? '' : dataIn.firstName2;
        clientHeader.katakanaSurName = String.isBlank(dataIn.lastName2) ? '' : dataIn.lastName2;
        clientHeader.gender = '';
        //clientHeader.clientTitle = dataIn.Title;
        clientHeader.civility = String.isNotBlank(dataIn.title) ? dataIn.title : '00';
        clientHeader.nationality = String.isNotBlank(dataIn.nationality) ? dataIn.nationality : '777';
        clientHeader.channelOfCreation = dataIn.channelOfCreation;
        clientHeader.eMailAddress = dataIn.personalEmail;
        clientHeader.typeOfClient = dataIn.typeOfClient;
        clientHeader.preferredLanguage = dataIn.preferredLanguage;
        clientHeader.passportNumber = dataIn.passportNumber;
        clientHeader.companyName = dataIn.company;
        //clientHeader.inactivationCode = '';
        //clientHeader.inactivationReason = '';
        clientHeader.profession = '';
        clientHeader.vatNumber = dataIn.vatNumber;
        clientHeader.taxId = dataIn.taxId;  
        
        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_ClientCreationUpdateData client = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_ClientCreationUpdateData(); 

        client.applicationOrigin = 'S';         // SPO Code  (1 pour MyPerso)
        client.storeCode = dataIn.storeCode;                
        client.rmsClientCode = dataIn.RMSId;    // Empty in creation
        client.wwRmsClientCode = dataIn.WW_RMSId;    // Empty in creation
        client.dreamClientCode = dataIn.dreamId;
        client.clientHeader = clientHeader;

        if (!String.isBlank(dataIn.primaryAddressLine1) || !String.isBlank(dataIn.primaryAddressLine2) || !String.isBlank(dataIn.primaryAddressLine3) || !String.isBlank(dataIn.primaryAddressZipCode) || !String.isBlank(dataIn.primaryAddressCity) || !String.isBlank(dataIn.primaryAddressCountry) || !String.isBlank(dataIn.primaryAddressProvinceOrState)) {
            SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_addressOccurences address = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_addressOccurences();
            address.addressLine1 = dataIn.primaryAddressLine1;
            address.addressLine2 = dataIn.primaryAddressLine2;
            address.addressLine3 = dataIn.primaryAddressLine3;
            address.addressZipCode = dataIn.primaryAddressZipCode;
            address.addressCity = dataIn.primaryAddressCity;
            address.addressCountry = dataIn.primaryAddressCountry;
            address.addressProvinceOrState = dataIn.primaryAddressProvinceOrState;
            //address.addressCityCode = '';
            client.addressOccurences = address;
        }

        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_phoneNumbers homePhone;
        if (!String.isBlank(dataIn.homePhoneNumber) && String.isNotBlank(dataIn.HomePhoneNumberCountry)) {
             homePhone = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_phoneNumbers();
             homePhone.typeOfPhone = '1';  // Home
             homePhone.phoneNumber = dataIn.homePhoneNumber;
             homePhone.phoneNumberCountry = dataIn.homePhoneNumberCountry;
        }
        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_phoneNumbers mobilePhone;
        if (!String.isBlank(dataIn.mobilePhoneNumber)) {
             mobilePhone = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_phoneNumbers();
             mobilePhone.typeOfPhone = '2';  // mobile
             mobilePhone.phoneNumber = dataIn.mobilePhoneNumber;
             mobilePhone.phoneNumberCountry = dataIn.mobilePhoneNumberCountry;
        }
        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_phoneNumbers workPhone;
        if (!String.isBlank(dataIn.workPhoneNumber)  && String.isNotBlank(dataIn.WorkPhoneNumberCountry)) {
             workPhone = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_phoneNumbers();
             workPhone.typeOfPhone = '3';  // work
             workPhone.phoneNumber = dataIn.workPhoneNumber;
             workPhone.phoneNumberCountry = dataIn.workPhoneNumberCountry;
        }
        
        if (homePhone != null || mobilePhone != null || workPhone != null) {
            SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_phoneNumbers[] phones = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_phoneNumbers[] {};
            if (homePhone != null) phones.add(homePhone); 
            if (mobilePhone != null) phones.add(mobilePhone); 
            if (workPhone != null) phones.add(workPhone);
            client.phoneNumbers = phones;
        }
        
        if (!String.isBlank(dataIn.birthdateMonth) || !String.isBlank(dataIn.birthdateMonth) || !String.isBlank(dataIn.birthdateMonth)) {
            SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_birthdate birthdate = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_birthdate();
            if (!String.isBlank(dataIn.birthdateDay)) birthdate.birthDay = dataIn.birthdateDay;
            if (!String.isBlank(dataIn.birthdateMonth)) birthdate.birthMonth = dataIn.birthdateMonth;
            if (!String.isBlank(dataIn.birthdateYear)) birthdate.birthYear = dataIn.birthdateYear;
            client.birthDate = birthdate;
        }
        
        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_contactPreferences[] contPref = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_contactPreferences[] {};

        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_contactPreferences cp1 = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_contactPreferences();
        cp1.typeOfContactPreference = '1';
        cp1.contactPreferenceOption = dataIn.PersonHasOptedOutOfEmail == true ? '0' : '1';
        contPref.add(cp1);

        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_contactPreferences cp2 = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_contactPreferences();
        cp2.typeOfContactPreference = '2';
        cp2.contactPreferenceOption = dataIn.DoNotContactbyPost == true ? '0' : '1';
        contPref.add(cp2);

        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_contactPreferences cp3 = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_contactPreferences();
        cp3.typeOfContactPreference = '3';
        cp3.contactPreferenceOption = dataIn.PersonDoNotCall == true ? '0' : '1';
        contPref.add(cp3);

        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_contactPreferences cp4 = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_contactPreferences();
        cp4.typeOfContactPreference = '4';
        cp4.contactPreferenceOption =  dataIn.DoNotSMS == true ? '0' : '1';
        contPref.add(cp4);

        client.contactPreferences = contPref;

        // Adding the communicationPreferences data
        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_communicationPreference[] commPrefs = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_communicationPreference[] {};

        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_communicationPreference myLvPref = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_communicationPreference();
        myLvPref.typeOfCommunicationPreference = '1';
        myLvPref.communicationPreferenceOption =  dataIn.IsBoundInMyLV == true ? '0' : '1';
        commPrefs.add(myLvPref);

        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_communicationPreference wechatPref = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_communicationPreference();
        wechatPref.typeOfCommunicationPreference = '2';
        wechatPref.communicationPreferenceOption =  dataIn.IsBoundInWechat == true ? '0' : '1';
        commPrefs.add(wechatPref);

        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_communicationPreference linePref = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_communicationPreference();
        linePref.typeOfCommunicationPreference = '3';
        linePref.communicationPreferenceOption =  dataIn.IsBoundInLine == true ? '0' : '1';
        commPrefs.add(linePref);

        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_communicationPreference kakaoPref = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_communicationPreference();
        kakaoPref.typeOfCommunicationPreference = '4';
        kakaoPref.communicationPreferenceOption =  dataIn.IsBoundInKakao == true ? '0' : '1';
        commPrefs.add(kakaoPref);

        client.communicationPreferences = commPrefs;

        SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_LvmHeader lvmHeader = new SO_WS_RMS_ClientCreationUpdate_v5.docTypeRef_LvmHeader();
        lvmHeader.version = 'V18';
        lvmHeader.consumer = 'Salesforce';
                
        SO_WS_RMS_ClientCreationUpdate_v5.ClientCreationUpdate2 headers = new SO_WS_RMS_ClientCreationUpdate_v5.ClientCreationUpdate2();
        headers.LvmHeader = lvmHeader;
        headers.Data = client;

        SO_WS_RMS_ClientCreationUpdate_v5.clientCreationUpdate wsMsg = new SO_WS_RMS_ClientCreationUpdate_v5.clientCreationUpdate();
        wsMsg.ClientCreationUpdate = headers;

        System.debug('++++ ' + wsMsg);        
        return wsMsg;
    }
    
    

    // Output -----------------------------------------------------------------------------

    public class Result {
        public String error = '';
        public String RMSId = '';
        public String WW_RMSId = '';
    }   

    private Result getOutput(SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdateResponse wsResp) {
        Result res = new Result();

        if (wsResp != null) {       
            // WS Error
            if (wsResp.ClientCreationUpdateResponse.LvmHeaderResponse.errorCode != '000') {
                res.error = wsResp.ClientCreationUpdateResponse.LvmHeaderResponse.errorCode + ' - ' + wsResp.ClientCreationUpdateResponse.LvmHeaderResponse.errorMessage;
                return res;
            }
            
            res.RMSId = wsResp.ClientCreationUpdateResponse.DataResponse.rmsClientCode;
            System.debug('++++ ' + wsResp.ClientCreationUpdateResponse.LvmHeaderResponse.errorCode + ' - ' + res.RMSId);
        }
        return res;
    }

    private Result getOutput_v5(SO_WS_RMS_ClientCreationUpdate_v5.clientCreationUpdateResponse wsResp) {
        Result res = new Result();

        if (wsResp != null && wsResp.ClientCreationUpdateResponse !=  null) {       
            // WS Error
            if (wsResp.ClientCreationUpdateResponse!= null && wsResp.ClientCreationUpdateResponse.LvmHeaderResponse!= null&&  wsResp.ClientCreationUpdateResponse.LvmHeaderResponse.errorCode != '000') {
                res.error = wsResp.ClientCreationUpdateResponse.LvmHeaderResponse.errorCode + ' - ' + wsResp.ClientCreationUpdateResponse.LvmHeaderResponse.errorMessage;
                return res;
            }
            
            res.RMSId = wsResp.ClientCreationUpdateResponse.DataResponse.rmsClientCode;
            res.WW_RMSId = wsResp.ClientCreationUpdateResponse.DataResponse.wwRmsClientCode;

            System.debug('++++ ' + wsResp.ClientCreationUpdateResponse.LvmHeaderResponse.errorCode + ' - ' + res.RMSId);
        }
        return res;
    }
}