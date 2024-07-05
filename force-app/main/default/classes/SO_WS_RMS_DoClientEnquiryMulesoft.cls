/*
Class SO_WS_RMS_DoClientEnquiryMulesoft

Comment : MIY-2065
*/
 
global with sharing class SO_WS_RMS_DoClientEnquiryMulesoft {
 
    // To test  ----------------------------------------------------------------------
   
    public static string callToTest() {
        SO_WS_RMS_DoClientEnquiryMulesoft ws = new SO_WS_RMS_DoClientEnquiryMulesoft();
        SO_WS_RMS_DoClientEnquiryMulesoft.DataInput dataIn = new SO_WS_RMS_DoClientEnquiryMulesoft.DataInput();
        dataIn.StoreCode = 'A90';
        dataIn.wwRmsClientCode = 'C005458156';
 
        SO_WS_RMS_DoClientEnquiryMulesoft.Result result = ws.doClientEnquiry(dataIn);
        system.debug('Test @A :' +result);
        return 'OK';
    }
 
    // TRANSCODIFICATION AND WS CALL -----------------------------------------------------------------
   
    public Result doClientEnquiry (DataInput dataIn) {
        String err = validateInput(dataIn);
        if (!String.isBlank(err)) {
            Result res = new Result();
            res.error = err;
            return res;
        }
       
        SO_WS_RMS_ClientEnquiryV1.clientDetailEnquiryType wsMsg = makeMsg (dataIn);      
        SO_WS_RMS_ClientEnquiryV1.WSLV012_webService_v1_0_clientDetailEnquiry_Port stub = new SO_WS_RMS_ClientEnquiryV1.WSLV012_webService_v1_0_clientDetailEnquiry_Port();
        stub.timeout_x = SO_WS_Utils.getWSTimeOut();
        //stub.endpoint_x = SO_WS_Utils.getEndPoint('ClientEnquiry');
        stub.endpoint_x = 'callout:MULESOFT_SEARCH_CLIENT';
 
        Result res;
        if (!SO_WS_Utils.runForTest()) {
            SO_WS_RMS_ClientEnquiryV1.clientDetailEnquiryResponseType wsResp = stub.mainService_cde(wsMsg);
            system.debug('SFDC Test wsResp Mulesoft : '+wsResp);//added by AH
            res = getOutput(wsResp);
        }
        else {
            // Just to test without any call to the web service
            SO_WS_RMS_ClientEnquiryV1.clientDetailEnquiryResponseType wsRes = new SO_WS_RMS_ClientEnquiryV1.clientDetailEnquiryResponseType();
            wsRes.clientDetailEnquiryResponse = new SO_WS_RMS_ClientEnquiryV1.ClientDetailEnquiryResponse();
            wsRes.ClientDetailEnquiryResponse.LvmHeaderResponse = new webserviceCommon.docTypeRef_LvmHeaderResponse();
            wsRes.ClientDetailEnquiryResponse.LvmHeaderResponse.errorCode = '000';
            wsRes.ClientDetailEnquiryResponse.DataResponse = new SO_WS_RMS_ClientEnquiryV1.docTypeRef_ClientDetailEnquiryDataResponse();
            wsRes.ClientDetailEnquiryResponse.DataResponse.clientHeader = new SO_WS_RMS_ClientEnquiryV1.docTypeRef_clientHeader();
            wsRes.ClientDetailEnquiryResponse.DataResponse.birthdate = new webserviceCommon.docTypeRef_birthdate();
            wsRes.ClientDetailEnquiryResponse.DataResponse.anniversary = new webserviceCommon.docTypeRef_anniversary();
            wsRes.ClientDetailEnquiryResponse.DataResponse.addressOccurences = new SO_WS_RMS_ClientEnquiryV1.docTypeRef_addressOccurences();
            wsRes.ClientDetailEnquiryResponse.DataResponse.phoneNumbers = new webserviceCommon.docTypeRef_phoneNumbers[] {};
            wsRes.ClientDetailEnquiryResponse.DataResponse.communicationPreference = new webserviceCommon.docTypeRef_communicationPreference[] {};
            wsRes.ClientDetailEnquiryResponse.DataResponse.contactPreferences = new webserviceCommon.docTypeRef_contactPreferences[] {};
            res = getOutput(wsRes);
            res.FirstName = 'Raphael';
            res.LastName = 'Bouchon';
            res.Civility = '02';
         
            res.Nationality = 'FRA';
        }
           
        System.debug('+++++ ' + res);
        return res;
    }
 
    // Input ---------------------------------------------------------------------------

    public class DataInput {
        public String storeCode;        // Mandatory. Exact match only.
        public String RMSId;            // Mandatory if DreamId is empty.
        public String DreamId;          // Not used
        public String wwRmsClientCode;  // filled in for stores coming from Xstore, empty for stores from RMS
    }

    private string validateInput(DataInput dataIn){
        String err = '';
        if (String.isBlank(dataIn.storeCode) || String.isBlank(dataIn.RMSId)) {
            err = 'Store code and RMSId are mandatory';
        }
        return err;
    }
 
    private SO_WS_RMS_ClientEnquiryV1.clientDetailEnquiryType makeMsg(DataInput dataIn) {
        SO_WS_RMS_ClientEnquiryV1.clientDetailEnquiryType wsMsg = new SO_WS_RMS_ClientEnquiryV1.clientDetailEnquiryType();
        SO_WS_RMS_ClientEnquiryV1.clientDetailEnquiry wsMsg2 = new SO_WS_RMS_ClientEnquiryV1.clientDetailEnquiry();
        SO_WS_RMS_ClientEnquiryV1.docTypeRef_ClientDetailEnquiryData client = new SO_WS_RMS_ClientEnquiryV1.docTypeRef_ClientDetailEnquiryData();
        client.storeCode = dataIn.storeCode;
        client.rmsClientCode = dataIn.RMSId;
        client.wwRmsClientCode = dataIn.wwRmsClientCode;
         
        webserviceCommon.docTypeRef_LvmHeader lvmHeader = new webserviceCommon.docTypeRef_LvmHeader();
        lvmHeader.version = '4.0';
        lvmHeader.consumer = 'SPO';
       
       // SO_WS_RMS_ClientEnquiryV3.ClientDetailEnquiry2 headers = new SO_WS_RMS_ClientEnquiryV3.ClientDetailEnquiry2();
       wsMsg2.LvmHeader = lvmHeader;
       wsMsg2.Data = client;
       wsMsg.ClientDetailEnquiry = wsMsg2;
       
     
               
        return wsMsg;
    }
    // Output -----------------------------------------------------------------------------

    public class Result {
        public String error = '';
        public String RMSId;
        public String DreamId;
        public String FirstName;
        public String LastName;
        public String FirstNameOrigin;
        public String LastNameOrigin;
        public String Firstname2;
        public String Lastname2;
        public String Salutation;
        public String Title;
        public String Civility;
     
        public String Gender;
        public String TypologyCode;
        public string PreferredLanguage;
        public String Company;

        public String PrimaryAddressLine1;
        public String PrimaryAddressLine2;
        public String PrimaryAddressLine3;
        public String PrimaryCity;
        public String PrimaryZipCode;
        public String PrimaryStateProvince;
        public String PrimaryCountry;

        public String Nationality;
        public String PassportNumber;
        public String Email;            
        public String HomePhoneCountryCode;
        public String HomePhone;
        public String MobilePhoneCountryCode;
        public String MobilePhone;
        public String WorkPhoneCountryCode;
        public String Phone;

        public String BirthdateDay;
        public String BirthdateMonth;
        public String BirthdateYear;
        public String AnniversaryDay;
        public String AnniversaryMonth;
        public String AnniversaryYear;
        
        public Boolean HasOptedOutOfEmail;
        public Boolean DoNotContactbyPost;
        public Boolean DoNotCall;
        public Boolean DoNotSMS;
        
        public String vatNumber;
        public String taxId;
    }

 private Result getOutput(SO_WS_RMS_ClientEnquiryV1.clientDetailEnquiryResponseType wsResp) {
        Result res = new Result();
        
        // WS Error
        if (wsResp.ClientDetailEnquiryResponse.LvmHeaderResponse.errorCode != '000' && wsResp.ClientDetailEnquiryResponse.LvmHeaderResponse.errorCode != '') {
            res.error = wsResp.ClientDetailEnquiryResponse.LvmHeaderResponse.errorCode + ' - ' + wsResp.ClientDetailEnquiryResponse.LvmHeaderResponse.errorMessage;
            System.debug ('++++ ' + res.error);
            return res;
        }
        res.RMSId = wsResp.ClientDetailEnquiryResponse.DataResponse.rmsClientCode;
        res.DreamId = wsResp.ClientDetailEnquiryResponse.DataResponse.dreamClientCode;
        
        SO_WS_RMS_ClientEnquiryV1.docTypeRef_clientHeader clh = wsResp.ClientDetailEnquiryResponse.DataResponse.clientHeader;

        res.FirstNameOrigin = clh.clientOriginFirstName;
        res.LastNameOrigin = clh.clientOriginSurName;
        res.FirstName = clh.storeOriginFirstName;
        res.LastName = clh.storeOriginSurName;
        res.FirstName2 = clh.katakanaFirstName;
        res.LastName2 = clh.katakanaSurName;
        res.Gender = clh.gender;
        res.Title = clh.clientTitle;
        res.Civility = clh.civility;
      
        res.Nationality = clh.nationality;
        //clh.channelOfCreation;
        res.Email = clh.emailAddress;
        res.TypologyCode = clh.typeOfClient;
        res.PreferredLanguage = clh.preferredLanguage;
        res.PassportNumber = clh.passportNumber;
        res.Company = clh.companyName;
        //clh.inactivationCode;
        //clh.inactivationReason;
        //clh.profession;
        res.vatNumber = clh.vatNumber;
        res.taxId = clh.taxId;
        //clh.storeOfCreation;
        //clh.storeOfModification;
        //clh.dateOfCreation;
        //clh.dateOfModification;
        
        webserviceCommon.docTypeRef_birthdate bd = wsResp.ClientDetailEnquiryResponse.DataResponse.birthdate; 

        res.BirthdateDay = bd.birthDay;
        res.BirthdateMonth = bd.birthMonth;
        res.BirthdateYear = bd.birthYear;

        webserviceCommon.docTypeRef_anniversary aniv = wsResp.ClientDetailEnquiryResponse.DataResponse.anniversary;

        res.AnniversaryDay = aniv.annivDay;
        res.AnniversaryMonth = aniv.annivMonth;
        res.AnniversaryYear = aniv.annivYear;

        SO_WS_RMS_ClientEnquiryV1.docTypeRef_addressOccurences addr = wsResp.ClientDetailEnquiryResponse.DataResponse.addressOccurences;

        res.PrimaryAddressLine1 = addr.addressLine1;
        res.PrimaryAddressLine2 = addr.addressLine2;
        res.PrimaryAddressLine3 = addr.addressLine3;
        res.PrimaryCity = addr.addressCity;
        res.PrimaryZipCode = addr.addressZipCode;
        res.PrimaryStateProvince = addr.addressProvinceOrState;
        res.PrimaryCountry = addr.addressCountry;

        webserviceCommon.docTypeRef_phoneNumbers[] phones = wsResp.ClientDetailEnquiryResponse.DataResponse.phoneNumbers;

        System.debug('Phone List Values >>'+ phones);

        for(Integer i=0; i < phones.size(); i++) {
            if (phones[i].typeOfPhone == '3' && !String.isBlank(phones[i].phoneNumber)) {
                res.Phone = phones[i].phoneNumber;
                res.WorkPhoneCountryCode = phones[i].phoneNumberCountry;
            }
            if (phones[i].typeOfPhone == '2' && !String.isBlank(phones[i].phoneNumber)) {
                res.MobilePhone = phones[i].phoneNumber;
                res.MobilePhoneCountryCode = phones[i].phoneNumberCountry;
            }
            if (phones[i].typeOfPhone == '1' && !String.isBlank(phones[i].phoneNumber)) {
                res.HomePhone = phones[i].phoneNumber;
                res.HomePhoneCountryCode = phones[i].phoneNumberCountry;
            }
        }

        webserviceCommon.docTypeRef_contactPreferences[] comPrefs = wsResp.ClientDetailEnquiryResponse.DataResponse.contactPreferences;

        for(Integer i=0; i < comPrefs.size(); i++) {
            if (comPrefs[i].typeOfContactPreference == '1') { // 1=E-mails
                res.HasOptedOutOfEmail = comPrefs[i].contactPreferenceOption == '0' ? true : false;
            }
            if (comPrefs[i].typeOfContactPreference  == '2') { // 2=Postal mails
                res.DoNotContactbyPost = comPrefs[i].contactPreferenceOption == '0' ? true : false;
            }
            if (comPrefs[i].typeOfContactPreference  == '3') { // 3=Calls
                res.DoNotCall = comPrefs[i].contactPreferenceOption == '0' ? true : false;
            }
            if (comPrefs[i].typeOfContactPreference  == '4') { // 4=SMS/MMS
                res.DoNotSMS = comPrefs[i].contactPreferenceOption== '0' ? true : false;
            }
        }

        return res;
    }
}