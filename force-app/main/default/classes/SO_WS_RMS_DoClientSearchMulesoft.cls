global with sharing class SO_WS_RMS_DoClientSearchMulesoft{  //MIY-2065 added NEW class to have 2 option (using Mulesoft or not)

    // To test ----------------------------------------------------------------------
    
    public static string callToTest() {
        SO_WS_RMS_DoClientSearchMulesoft ws = new SO_WS_RMS_DoClientSearchMulesoft();
        //SO_WS_RMS_DoClientSearch.DataInput dataIn = new SO_WS_RMS_DoClientSearch.DataInput();
        SO_UTIL.SearchClientData datain = new SO_UTIL.SearchClientData();
        // StoreCode is Mandatory.
        dataIn.StoreCode = 'A06';
        dataIn.givenName = 'virginie';
        dataIn.lastName = 'legrand';
        //dataIn.dreamId = '';
        //dataIn.passportNumber = '';
        //dataIn.zipCode = '';
        //dataIn.zipCode + 'Z';
        //dataIn.country;
        //dataIn.phoneNumber;
        //dataIn.email;

        SO_WS_RMS_DoClientSearchMulesoft.Result result = ws.doClientSearch(dataIn);
        return 'OK';
    }

    // TRANSCODIFICATION AND WS CALL -----------------------------------------------------------------
    //****** 15/12/2021 IASD TODO check if we need this method or not?
    /*public Result doClientSearch (DataInput dataIn) {
        System.debug('++++++++++ OLD WAY TO DO');
        String err = validateInput(dataIn);
        if (!String.isBlank(err)) {
            Result res = new Result();
            res.error = err;
            return res;
        }
        
        SO_WS_RMS_ClientSearchV3.clientSearch wsMsg = makeMsg (dataIn);   
        system.debug('## wsMsg : '+wsMsg);     
        SO_WS_RMS_ClientSearchV3.WSLV013_webService_v3_0_clientSearch_Port stub = new SO_WS_RMS_ClientSearchV3.WSLV013_webService_v3_0_clientSearch_Port(); 
        stub.timeout_x = SO_WS_Utils.getWSTimeOut();
        //stub.endpoint_x = SO_WS_Utils.getEndPoint('ClientSearch');
        stub.endpoint_x = 'callout:EAI/' + SO_WS_Utils.getEndPoint('ClientSearch'); // here a named credentials is used

        Result res;
        if (!SO_WS_Utils.runForTest()) {        
            SO_WS_RMS_ClientSearchV3.clientSearchResponse wsResp = stub.mainService (wsMsg);
            system.debug('SFDC Test wsResp On DoClientSearch : '+wsResp);//added by AH
            res = getOutput(wsResp);
        }
        else
        {
            // Just to test without any call to the web service
            SO_WS_RMS_ClientSearchV3.clientSearchResponse wsRes = new SO_WS_RMS_ClientSearchV3.clientSearchResponse();
            wsRes.ClientSearchResponse = new SO_WS_RMS_ClientSearchV3.ClientSearchResponse2();
            wsRes.ClientSearchResponse.LvmHeaderResponse = new SO_WS_RMS_ClientSearchV3.docTypeRef_LvmHeaderResponse();
            wsRes.ClientSearchResponse.LvmHeaderResponse.errorCode = '000';
            wsRes.ClientSearchResponse.DataResponse = new SO_WS_RMS_ClientSearchV3.docTypeRef_ClientSearchDataResponse();
            wsRes.ClientSearchResponse.DataResponse.clientData = new SO_WS_RMS_ClientSearchV3.docTypeRef_clientData[] {};
            wsRes.ClientSearchResponse.DataResponse.numberOfClientsReturned = '1';
            SO_WS_RMS_ClientSearchV3.docTypeRef_clientData oneClientData = new SO_WS_RMS_ClientSearchV3.docTypeRef_clientData();
            wsRes.ClientSearchResponse.DataResponse.clientData = new SO_WS_RMS_ClientSearchV3.docTypeRef_clientData[] {oneClientData};
            res = getOutput(wsRes);
            ResultLine resLine = new ResultLine();
            res.nbRecords = 1;
            resLine.RMSId='14712';
            resLine.firstName='Raphael';
            resLine.lastName='Bouchon';
            resLine.salutation='02';
            res.resultList = new ResultLine[] {resLine};
        }       

        System.debug('++++++++++ ' + res.error);
        return res;
    }*/
    /*
        AEF: doClientSearch
     */
    public Result doClientSearch (SO_UTIL.SearchClientData dataIn) {
        System.debug('++++++++++ NEW WAY TO DO');
        String err = validateInput(dataIn);
        if (!String.isBlank(err)) {
            Result res = new Result();
            res.error = err;
            return res;
        }
        //15/12/2021 IASD TODO clear V3 from apex class after MEP
        //SO_WS_RMS_ClientSearchV3.clientSearch wsMsg = makeMsg(dataIn); 
        SO_WS_RMS_ClientSearchV6.clientSearch wsMsg = makeMsg_V6(dataIn);          
        //SO_WS_RMS_ClientSearchV3.WSLV013_webService_v3_0_clientSearch_Port stub = new SO_WS_RMS_ClientSearchV3.WSLV013_webService_v3_0_clientSearch_Port(); 
        SO_WS_RMS_ClientSearchV6.WSLV013_webService_v6_0_clientSearch_Port stub = new SO_WS_RMS_ClientSearchV6.WSLV013_webService_v6_0_clientSearch_Port(); 
        stub.timeout_x = SO_WS_Utils.getWSTimeOut();
        //stub.endpoint_x = SO_WS_Utils.getEndPoint('ClientSearch');
        //stub.endpoint_x = 'callout:EAI/' + SO_WS_Utils.getEndPoint('ClientSearch'); // here a named credentials is used
        stub.endpoint_x = 'callout:MULESOFT_SEARCH_CLIENT';
        
        Result res;
        if (!SO_WS_Utils.runForTest()) {        
            //SO_WS_RMS_ClientSearchV3.clientSearchResponse wsResp = stub.mainService (wsMsg);
            SO_WS_RMS_ClientSearchV6.clientSearchResponse wsResp = stub.mainService_cs(wsMsg);
           // res = getOutput(wsResp);
            res = getOutput_V6(wsResp);
        }
        else
        {
            //SO_WS_RMS_ClientSearchV3.clientSearchResponse wsRes = new SO_WS_RMS_ClientSearchV3.clientSearchResponse();
            SO_WS_RMS_ClientSearchV6.clientSearchResponse wsRes = new SO_WS_RMS_ClientSearchV6.clientSearchResponse();
            //wsRes.ClientSearchResponse = new SO_WS_RMS_ClientSearchV3.ClientSearchResponse2();
            wsRes.clientSearchResponse = new SO_WS_RMS_ClientSearchV6.ClientSearchResponseType();
            //wsRes.ClientSearchResponse.LvmHeaderResponse = new SO_WS_RMS_ClientSearchV3.docTypeRef_LvmHeaderResponse();
            wsRes.clientSearchResponse.LvmHeaderResponse = new webserviceCommon.docTypeRef_LvmHeaderResponse();
            wsRes.clientSearchResponse.LvmHeaderResponse.errorCode = '000';
            wsRes.clientSearchResponse.LvmHeaderResponse.errorMessage = 'Client search successful';
            //wsRes.ClientSearchResponse.DataResponse = new SO_WS_RMS_ClientSearchV3.docTypeRef_ClientSearchDataResponse();
            wsRes.clientSearchResponse.DataResponse= new SO_WS_RMS_ClientSearchV6.docTypeRef_ClientSearchDataResponse();
            //wsRes.ClientSearchResponse.DataResponse.clientData = new SO_WS_RMS_ClientSearchV3.docTypeRef_clientData[] {};
            wsRes.clientSearchResponse.DataResponse.clientData = new SO_WS_RMS_ClientSearchV6.docTypeRef_clientData[] {};            
            wsRes.clientSearchResponse.DataResponse.numberOfClientsReturned = '1';
            //SO_WS_RMS_ClientSearchV3.docTypeRef_clientData oneClientData = new SO_WS_RMS_ClientSearchV3.docTypeRef_clientData();
            SO_WS_RMS_ClientSearchV6.docTypeRef_clientData oneClientData = new SO_WS_RMS_ClientSearchV6.docTypeRef_clientData();   
            //wsRes.ClientSearchResponse.DataResponse.clientData = new SO_WS_RMS_ClientSearchV3.docTypeRef_clientData[] {oneClientData};
            wsRes.clientSearchResponse.DataResponse.clientData = new SO_WS_RMS_ClientSearchV6.docTypeRef_clientData[] {oneClientData};            
            
            //res = getOutput(wsRes);
            res = getOutput_V6(wsRes);
            ResultLine resLine = new ResultLine();
            res.nbRecords = 1;
            resLine.RMSId='14712';
            resLine.firstName='Raphael';
            resLine.lastName='Bouchon';
            resLine.salutation='02';
            res.resultList = new ResultLine[] {resLine};
        }       

        System.debug('<==== Webservice returned Code  ====> ' + res.error);
        return res;
    }
 
   // Input ---------------------------------------------------------------------------
    
    /*
    public class DataInput {
        public String storeCode;        // Mandatory. Exact match only.
        public String lastName;         // Start with if * is used at the end of the string
        public String givenName;        // Start with if * is used at the end of the string
        public String country;          // ISO Code on 3 characters. Exact match only. * is not supported
        public String zipCode;          // Always Start with. * is not supported
        public String dreamId;          // Exact match only. * is not supported
        public String passportNumber;   // Exact match only. * is not supported 
        public String phoneNumber;      // Search in all phone numbers. Start with and end with are supported
        public String email;            // Start with if * is used at the end of the string
    } */
    //****** 21/12/2021 BNG method not used in V6
    /*private string validateInput(DataInput dataIn){
        String err = '';
        if (String.isBlank(dataIn.storeCode) || dataIn.storeCode.trim() == '*') {
            err = 'Store code is mandatory';
            return err;
        }
        /*
        if (!string.isBlank(dataIn.lastName) && dataIn.lastName.indexOf('*') >= 0 && dataIn.lastName.replace('*','').trim().length() < 2)
            err = '2 characters minimum are required in a criteria to use a wildcard character\n';
        else if (!string.isBlank(dataIn.givenName) && dataIn.givenName.indexOf('*') >= 0 && dataIn.givenName.replace('*','').trim().length() < 2)
            err = '2 characters minimum are required in a criteria to use a wildcard character\n';
        else if (!string.isBlank(dataIn.phoneNumber) && dataIn.phoneNumber.indexOf('*') >= 0 && dataIn.phoneNumber.replace('*','').trim().length() < 6)
            err = '6 characters minimum are required in the phone number or the email to use a wildcard character\n';
        else if (!string.isBlank(dataIn.phoneNumber) && dataIn.phoneNumber.indexOf('*') >= 0 && dataIn.phoneNumber.replace('*','').trim().length() < 6)
            err = '6 characters minimum are required in the phone number or the email to use a wildcard character\n';
        if (err != '') return err;
        if (dataIn.storeCode.indexOf('*') >= 0) dataIn.storeCode.replace('*','');
        if (!String.isBlank(dataIn.country) && dataIn.country.indexOf('*') >= 0) dataIn.country.replace('*','');
        if (!String.isBlank(dataIn.zipCode) && dataIn.zipCode.indexOf('*') >= 0) dataIn.zipCode.replace('*','');
        if (!String.isBlank(dataIn.dreamId) && dataIn.dreamId.indexOf('*') >= 0) dataIn.dreamId.replace('*','');
        if (!String.isBlank(dataIn.passportNumber) && dataIn.passportNumber.indexOf('*') >= 0) dataIn.passportNumber.replace('*','');
        if ((String.isBlank(dataIn.lastName) || dataIn.lastName.replace('*','').trim() == '') && (String.isBlank(dataIn.givenName) || dataIn.givenName.replace('*','').trim() == '') && (String.isBlank(dataIn.country) || dataIn.country.replace('*','').trim() == '') && (String.isBlank(dataIn.zipCode) || dataIn.zipCode.replace('*','').trim() == '') && (String.isBlank(dataIn.dreamId) || dataIn.dreamId.replace('*','').trim() == '') && (String.isBlank(dataIn.passportNumber) || dataIn.passportNumber.replace('*','').trim() == '') && (String.isBlank(dataIn.phoneNumber) || dataIn.phoneNumber.replace('*','').trim() == '') && (String.isBlank(dataIn.email) || dataIn.email.replace('*','').trim() == '')) {
            err = 'Not all criteria may be empty';
        }
        return err;
    }*/

    /*
        AEF: validateInput
     */
    private string validateInput(SO_UTIL.SearchClientData dataIn){
        String err = '';
        if (String.isBlank(dataIn.storeCode) || dataIn.storeCode.trim() == '*') {
            err = 'Store code is mandatory';
            return err;
        }
        /*
        if (!string.isBlank(dataIn.lastName) && dataIn.lastName.indexOf('*') >= 0 && dataIn.lastName.replace('*','').trim().length() < 2)
            err = '2 characters minimum are required in a criteria to use a wildcard character\n';
        else if (!string.isBlank(dataIn.givenName) && dataIn.givenName.indexOf('*') >= 0 && dataIn.givenName.replace('*','').trim().length() < 2)
            err = '2 characters minimum are required in a criteria to use a wildcard character\n';
        else if (!string.isBlank(dataIn.phoneNumber) && dataIn.phoneNumber.indexOf('*') >= 0 && dataIn.phoneNumber.replace('*','').trim().length() < 6)
            err = '6 characters minimum are required in the phone number or the email to use a wildcard character\n';
        else if (!string.isBlank(dataIn.phoneNumber) && dataIn.phoneNumber.indexOf('*') >= 0 && dataIn.phoneNumber.replace('*','').trim().length() < 6)
            err = '6 characters minimum are required in the phone number or the email to use a wildcard character\n';
        if (err != '') return err;
        if (dataIn.storeCode.indexOf('*') >= 0) dataIn.storeCode.replace('*','');
        if (!String.isBlank(dataIn.country) && dataIn.country.indexOf('*') >= 0) dataIn.country.replace('*','');
        if (!String.isBlank(dataIn.zipCode) && dataIn.zipCode.indexOf('*') >= 0) dataIn.zipCode.replace('*','');
        if (!String.isBlank(dataIn.dreamId) && dataIn.dreamId.indexOf('*') >= 0) dataIn.dreamId.replace('*','');
        if (!String.isBlank(dataIn.passportNumber) && dataIn.passportNumber.indexOf('*') >= 0) dataIn.passportNumber.replace('*','');
        if ((String.isBlank(dataIn.lastName) || dataIn.lastName.replace('*','').trim() == '') && (String.isBlank(dataIn.givenName) || dataIn.givenName.replace('*','').trim() == '') && (String.isBlank(dataIn.country) || dataIn.country.replace('*','').trim() == '') && (String.isBlank(dataIn.zipCode) || dataIn.zipCode.replace('*','').trim() == '') && (String.isBlank(dataIn.dreamId) || dataIn.dreamId.replace('*','').trim() == '') && (String.isBlank(dataIn.passportNumber) || dataIn.passportNumber.replace('*','').trim() == '') && (String.isBlank(dataIn.phoneNumber) || dataIn.phoneNumber.replace('*','').trim() == '') && (String.isBlank(dataIn.email) || dataIn.email.replace('*','').trim() == '')) {
            err = 'Not all criteria may be empty';
        }
        */
        return err;
    }
    //****** 15/12/2021 IASD TODO check if we need this methods or not?
    /*private SO_WS_RMS_ClientSearchV3.clientSearch makeMsg(DataInput dataIn) {
        SO_WS_RMS_ClientSearchV3.clientSearch wsMsg = new SO_WS_RMS_ClientSearchV3.clientSearch();
        
        SO_WS_RMS_ClientSearchV3.docTypeRef_searchCriteria crit = new SO_WS_RMS_ClientSearchV3.docTypeRef_searchCriteria();
        //crit.rmsClientCode;
        //crit.externalClientCode;
        //crit.wwRmsClientCode;
        crit.dreamClientCode = dataIn.dreamId;
        crit.surname = dataIn.lastName;
        crit.givenName = dataIn.givenName;
        //crit.fromClientType;
        //crit.toClientType;
        crit.passportNumber = dataIn.passportNumber;
        //crit.birthdayDate;
        //crit.birthdayMonth;
        //crit.birthdayYear;
        //crit.city;
        //crit.stateOrProvince;
        crit.fromZipCode = dataIn.zipCode;
        crit.toZipCode = dataIn.zipCode + 'Z';

        if(String.isNotBlank(dataIn.country)
            && SO_UTIL.COUNTRY_CODE_BY_STORE_COUNTRY_MAP.containsKey(dataIn.country.toUpperCase()))
        {
            crit.country = SO_UTIL.COUNTRY_CODE_BY_STORE_COUNTRY_MAP.get(dataIn.country.toUpperCase());
        }
        //crit.country = dataIn.country;

        crit.phoneNumber = dataIn.phoneNumber;
        crit.emailAddress = dataIn.email;
        //crit.fromCreationDate;
        //crit.toCreationDate;
        //crit.fromModificationDate;
        //crit.toModificationDate;
        
        SO_WS_RMS_ClientSearchV3.docTypeRef_ClientSearchData searchData = new SO_WS_RMS_ClientSearchV3.docTypeRef_ClientSearchData();
        searchData.searchCriteria = crit;
        searchData.storeCode = dataIn.storeCode;
        searchData.newSearch = '1';
        //searchData.scrollType;
        //searchData.referenceRecordNumber;
        searchData.numberOfClients = '50';
        //searchData.typeOfClient;
        
        SO_WS_RMS_ClientSearchV3.docTypeRef_LvmHeader lvmHeader = new SO_WS_RMS_ClientSearchV3.docTypeRef_LvmHeader();
        lvmHeader.version = '1.0';
        lvmHeader.consumer = 'SPO';
        
        SO_WS_RMS_ClientSearchV3.ClientSearch2 headers = new SO_WS_RMS_ClientSearchV3.ClientSearch2();
        headers.LvmHeader = lvmHeader;
        headers.Data = searchData;
        
        wsMsg.ClientSearch = headers;
                
        return wsMsg;
    } */
    /*
        AEF: makeMsg
     */
    /*
    private SO_WS_RMS_ClientSearchV3.clientSearch makeMsg(SO_UTIL.SearchClientData dataIn) {
        SO_WS_RMS_ClientSearchV3.clientSearch wsMsg = new SO_WS_RMS_ClientSearchV3.clientSearch();
        
        SO_WS_RMS_ClientSearchV3.docTypeRef_searchCriteria crit = new SO_WS_RMS_ClientSearchV3.docTypeRef_searchCriteria();
        //crit.rmsClientCode;
        //crit.externalClientCode;
        //crit.wwRmsClientCode;
        crit.dreamClientCode = dataIn.dreamId;
        crit.surname = dataIn.lastName;
        crit.givenName = dataIn.firstName;
        //crit.fromClientType;
        //crit.toClientType;
        crit.passportNumber = dataIn.passportNumber;
        //crit.birthdayDate;
        //crit.birthdayMonth;
        //crit.birthdayYear;
        //crit.city;
        //crit.stateOrProvince;
        crit.fromZipCode = dataIn.zipCode;
        crit.toZipCode = dataIn.zipCode + 'Z';

        if(String.isNotBlank(dataIn.country)
            && SO_UTIL.COUNTRY_CODE_BY_STORE_COUNTRY_MAP.containsKey(dataIn.country.toUpperCase()))
        {
            crit.country = SO_UTIL.COUNTRY_CODE_BY_STORE_COUNTRY_MAP.get(dataIn.country.toUpperCase());
        }

        crit.phoneNumber = dataIn.phoneNumber;
        crit.emailAddress = dataIn.email;
        //crit.fromCreationDate;
        //crit.toCreationDate;
        //crit.fromModificationDate;
        //crit.toModificationDate;
        
        SO_WS_RMS_ClientSearchV3.docTypeRef_ClientSearchData searchData = new SO_WS_RMS_ClientSearchV3.docTypeRef_ClientSearchData();
        searchData.searchCriteria = crit;
        searchData.storeCode = dataIn.storeCode;
        searchData.newSearch = '1';
        //searchData.scrollType;
        //searchData.referenceRecordNumber;
        searchData.numberOfClients = '50';
        //searchData.typeOfClient;
        
        SO_WS_RMS_ClientSearchV3.docTypeRef_LvmHeader lvmHeader = new SO_WS_RMS_ClientSearchV3.docTypeRef_LvmHeader();
        lvmHeader.version = '1.0';
        lvmHeader.consumer = 'SPO';
        
        SO_WS_RMS_ClientSearchV3.ClientSearch2 headers = new SO_WS_RMS_ClientSearchV3.ClientSearch2();
        headers.LvmHeader = lvmHeader;
        headers.Data = searchData;
        
        wsMsg.ClientSearch = headers;
    }*/
/*
    BNG: makeMsg_V6 (Related to Mulesoft)
 */
private SO_WS_RMS_ClientSearchV6.clientSearch makeMsg_V6(SO_UTIL.SearchClientData dataIn) {
    SO_WS_RMS_ClientSearchV6.clientSearch wsMsg = new SO_WS_RMS_ClientSearchV6.clientSearch();
    SO_WS_RMS_ClientSearchV6.ClientSearchType clientSearchType = new SO_WS_RMS_ClientSearchV6.ClientSearchType();
    webserviceCommon.docTypeRef_LvmHeader lvmHeader = new webserviceCommon.docTypeRef_LvmHeader();
    SO_WS_RMS_ClientSearchV6.docTypeRef_ClientSearchData clientSearchData = new SO_WS_RMS_ClientSearchV6.docTypeRef_ClientSearchData();
    SO_WS_RMS_ClientSearchV6.docTypeRef_searchCriteria crit = new SO_WS_RMS_ClientSearchV6.docTypeRef_searchCriteria();
    //crit.rmsClientCode;
    //crit.externalClientCode;
    //crit.wwRmsClientCode;
    crit.dreamClientCode = dataIn.dreamId;
    crit.surname = dataIn.lastName;
    crit.givenName = dataIn.firstName;
    //crit.fromClientType;
    //crit.toClientType;
    crit.passportNumber = dataIn.passportNumber;
    //crit.birthdayDate;
    //crit.birthdayMonth;
    //crit.birthdayYear;
    //crit.city;
    //crit.stateOrProvince;
    crit.fromZipCode = dataIn.zipCode;
    crit.toZipCode = dataIn.zipCode + 'Z';
    if(String.isNotBlank(dataIn.country)
        && SO_UTIL.COUNTRY_CODE_BY_STORE_COUNTRY_MAP.containsKey(dataIn.country.toUpperCase()))
    {
        crit.country = SO_UTIL.COUNTRY_CODE_BY_STORE_COUNTRY_MAP.get(dataIn.country.toUpperCase());
    }
    crit.phoneNumber = dataIn.phoneNumber;
    crit.emailAddress = dataIn.email;
    //crit.fromCreationDate;
    //crit.toCreationDate;
    //crit.fromModificationDate;
    //crit.toModificationDate;
    
    // To fullfill clientSearchData => Data
    clientSearchData.searchCriteria = crit;
    clientSearchData.storeCode = dataIn.storeCode;
    clientSearchData.newSearch = '1';
    //clientSearchData.scrollType;
    //clientSearchData.referenceRecordNumber;
    clientSearchData.numberOfClients = '50';
    //clientSearchData.typeOfClient;
    lvmHeader.version = '1.0';
    lvmHeader.consumer = 'SPO';
    // Adding Header and Data
    clientSearchType.LvmHeader = lvmHeader;
    clientSearchType.Data = clientSearchData;
    wsMsg.clientSearch = clientSearchType;       
    return wsMsg;
}

    // Output -----------------------------------------------------------------------------

    public class Result {
        public String error = '';
        public Boolean firstRecord = false;
        public Boolean lastRecord = false;
        public Boolean emptyList = false;
        public Integer nbRecords =0;
        public List<ResultLine> resultList;
    }   
        
    public class ResultLine {
        // The fieldnames are closes from the fieldNames in Salesforce
        public String DreamId;
        public String RMSId;
        public String WWRmsClientCode; // empty for RMS stores but not for Xstore
        public String FirstName;
        public String LastName;
        public String FirstNameOrigin;
        public String LastNameOrigin;
        public String Firstname2;
        public String Lastname2;
        public String Salutation;
        public String Title;
        public String Gender;

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
        public String birthdateYear;
    }

   /* private Result getOutput(SO_WS_RMS_ClientSearchV3.clientSearchResponse wsResp) {
        Result res = new Result();
        // WS Error
        if (wsResp.ClientSearchResponse.LvmHeaderResponse.errorCode != '000') {
            res.error = wsResp.ClientSearchResponse.LvmHeaderResponse.errorCode + ' - ' + wsResp.ClientSearchResponse.LvmHeaderResponse.errorMessage;
            return res;
        }
        res.lastRecord = wsResp.ClientSearchResponse.DataResponse.lastRecord == '1' ? true : false;
        res.firstRecord = wsResp.ClientSearchResponse.DataResponse.firstRecord == '1' ? true : false;
        res.emptyList = wsResp.ClientSearchResponse.DataResponse.noRecord == '1' ? true : false;
        SO_WS_RMS_ClientSearchV3.docTypeRef_clientData[] wsLines = wsResp.ClientSearchResponse.DataResponse.clientData;

        res.resultList = new List<ResultLine>();

        if (wsLines == null || wsLines.size() == 0 || res.emptyList) {
            res.nbRecords = 0;
            res.emptyList = true;
            return res;
        }
        res.nbRecords = wsLines.size();

        for (Integer i=0; i < wsLines.size(); i++)
        {
            ResultLine resLine = new ResultLine();
            
            resLine.DreamId = wsLines[i].dreamClientCode;
            resLine.RMSId = wsLines[i].rmsClientCode;
            resLine.WWRmsClientCode = wsLines[i].wwRmsClientCode; // retrieve the wwRmsClientCode
            resLine.FirstName = wsLines[i].storeOriginFirstName;
            resLine.LastName = wsLines[i].storeOriginSurName;
            resLine.FirstNameOrigin = wsLines[i].clientOriginFirstName;
            resLine.LastNameOrigin = wsLines[i].clientOriginSurName;
            resLine.Firstname2 = wsLines[i].katakanaFirstName;
            resLine.Lastname2 = wsLines[i].katakanaSurName;
            resLine.Salutation = wsLines[i].civility;
            resLine.Title = wsLines[i].clientTitle;
            resLine.Gender = wsLines[i].gender;

            resLine.PrimaryAddressLine1 = wsLines[i].addressLine1;
            resLine.PrimaryAddressLine2 = wsLines[i].addressLine2;
            resLine.PrimaryAddressLine3 = wsLines[i].addressLine3;
            resLine.PrimaryCity = wsLines[i].addressCity;
            resLine.PrimaryZipCode = wsLines[i].addressZipCode;
            resLine.PrimaryStateProvince = wsLines[i].addressProvinceOrState;
            resLine.PrimaryCountry = wsLines[i].addressCountry;

            resLine.Nationality = wsLines[i].nationality;
            resLine.PassportNumber = wsLines[i].passportNumber;

            resLine.Email = wsLines[i].emailAddress;            
            resLine.HomePhoneCountryCode = wsLines[i].homePhoneNumberCountry;
            resLine.HomePhone = wsLines[i].homePhoneNumber;
            resLine.MobilePhoneCountryCode = wsLines[i].mobilePhoneNumberCountry;
            resLine.MobilePhone = wsLines[i].mobilePhoneNumber;
            resLine.WorkPhoneCountryCode = wsLines[i].workPhoneNumberCountry;
            resLine.Phone = wsLines[i].workPhoneNumber;

            resLine.BirthdateDay = wsLines[i].birthDay;
            resLine.BirthdateMonth = wsLines[i].birthMonth;
            resLine.birthdateYear = wsLines[i].birthYear;
            
            System.debug('++++++++++ ' + resLine);

            res.resultList.add(resLine);
        }
        System.debug('++++++++++ ' + res.resultList.size());
        return res;
    } */

    private Result getOutput_V6(SO_WS_RMS_ClientSearchV6.clientSearchResponse wsResp) 
    {
        Result res = new Result();
        // WS Error
        if (wsResp.ClientSearchResponse.LvmHeaderResponse.errorCode != '000') {
            res.error = wsResp.ClientSearchResponse.LvmHeaderResponse.errorCode + ' - ' + wsResp.ClientSearchResponse.LvmHeaderResponse.errorMessage;
            return res;
        }
        res.lastRecord = wsResp.ClientSearchResponse.DataResponse.lastRecord == '1' ? true : false;
        res.firstRecord = wsResp.ClientSearchResponse.DataResponse.firstRecord == '1' ? true : false;
        res.emptyList = wsResp.ClientSearchResponse.DataResponse.noRecord == '1' ? true : false;
        SO_WS_RMS_ClientSearchV6.docTypeRef_clientData[] wsLines = wsResp.ClientSearchResponse.DataResponse.clientData;
        res.resultList = new List<ResultLine>();
        if (wsLines == null || wsLines.size() == 0 || res.emptyList) {
            res.nbRecords = 0;
            res.emptyList = true;
            return res;
        }
        res.nbRecords = wsLines.size();
        for (Integer i=0; i < wsLines.size(); i++)
        {
            ResultLine resLine = new ResultLine();
            
            resLine.DreamId = wsLines[i].dreamClientCode;
            resLine.RMSId = wsLines[i].rmsClientCode;
            resLine.WWRmsClientCode = wsLines[i].wwRmsClientCode; // retrieve the wwRmsClientCode
            resLine.FirstName = wsLines[i].storeOriginFirstName;
            resLine.LastName = wsLines[i].storeOriginSurName;
            resLine.FirstNameOrigin = wsLines[i].clientOriginFirstName;
            resLine.LastNameOrigin = wsLines[i].clientOriginSurName;
            resLine.Firstname2 = wsLines[i].katakanaFirstName;
            resLine.Lastname2 = wsLines[i].katakanaSurName;
            resLine.Salutation = wsLines[i].civility;
            resLine.Title = wsLines[i].clientTitle;
            resLine.Gender = wsLines[i].gender;
            resLine.PrimaryAddressLine1 = wsLines[i].addressLine1;
            resLine.PrimaryAddressLine2 = wsLines[i].addressLine2;
            resLine.PrimaryAddressLine3 = wsLines[i].addressLine3;
            resLine.PrimaryCity = wsLines[i].addressCity;
            resLine.PrimaryZipCode = wsLines[i].addressZipCode;
            resLine.PrimaryStateProvince = wsLines[i].addressProvinceOrState;
            resLine.PrimaryCountry = wsLines[i].addressCountry;
            resLine.Nationality = wsLines[i].nationality;
            resLine.PassportNumber = wsLines[i].passportNumber;
            resLine.Email = wsLines[i].emailAddress;            
            resLine.HomePhoneCountryCode = wsLines[i].homePhoneNumberCountry;
            resLine.HomePhone = wsLines[i].homePhoneNumber;
            resLine.MobilePhoneCountryCode = wsLines[i].mobilePhoneNumberCountry;
            resLine.MobilePhone = wsLines[i].mobilePhoneNumber;
            resLine.WorkPhoneCountryCode = wsLines[i].workPhoneNumberCountry;
            resLine.Phone = wsLines[i].workPhoneNumber;
            resLine.BirthdateDay = wsLines[i].birthDay;
            resLine.BirthdateMonth = wsLines[i].birthMonth;
            resLine.birthdateYear = wsLines[i].birthYear;
            
            System.debug('++++++++++ ' + resLine);
            res.resultList.add(resLine);
        }
        System.debug('++++++++++ ' + res.resultList.size());
        return res;
    }

    public static Account MapRmsClientIntoSfdcClient(SO_WS_RMS_DoClientSearchMulesoft.ResultLine incomingRmsClient, Account sfdcClientToMap)
    {
        system.debug('SFDC MapRmsClientIntoSfdcClient incomingRmsClient ' + incomingRmsClient);

        sfdcClientToMap.DREAMID__c                 = incomingRmsClient.DreamId;
        sfdcClientToMap.Salutation                 = incomingRmsClient.Salutation;
        sfdcClientToMap.FirstName                  = incomingRmsClient.FirstName;
        sfdcClientToMap.LastName                   = incomingRmsClient.LastName;
        sfdcClientToMap.Firstname2__pc             = incomingRmsClient.FirstName2;
        sfdcClientToMap.Lastname2__pc              = incomingRmsClient.LastName2;

        //sfdcClientToMap.TypologyCode__pc           = incomingRmsClient.TypologyCode;
        sfdcClientToMap.BirthdateDay__pc           = (incomingRmsClient.BirthdateDay != '0' ? incomingRmsClient.BirthdateDay : null);
        sfdcClientToMap.BirthDateMonth__pc         = (incomingRmsClient.BirthdateMonth != '0' ? incomingRmsClient.BirthdateMonth : null);
        sfdcClientToMap.BirthdateYear__pc          = (incomingRmsClient.BirthdateYear != '0' ? incomingRmsClient.BirthdateYear : null);
        if (incomingRmsClient.BirthdateDay != null && incomingRmsClient.BirthdateDay != '0') {
            sfdcClientToMap.PersonBirthdate = Date.newInstance(
                Integer.valueOf(incomingRmsClient.BirthdateYear),
                Integer.valueOf(incomingRmsClient.BirthdateMonth),
                Integer.valueOf(incomingRmsClient.BirthdateDay));
        }
        sfdcClientToMap.PersonEmail                = incomingRmsClient.Email;

        sfdcClientToMap.GenderCode__pc = incomingRmsClient.Gender;
        sfdcClientToMap.Gender__pc = ('F'.equals(incomingRmsClient.Gender) ? 'Female' : ('M'.equals(incomingRmsClient.Gender) ? 'Male' : null));
        sfdcClientToMap.NationalityCountryCode__pc = incomingRmsClient.Nationality;
        
        //AEF: removed for Ticket 0677
        //sfdcClientToMap.SPO_VATNumber__pc          = incomingRmsClient.VatNumber;
        //sfdcClientToMap.SPO_TaxID__pc              = incomingRmsClient.Taxid;

        // --- Added by MTOU - Harmo: populating "Contactable" fields --- //
        /*sfdcClientToMap.NationalityCountryCode__pc = incomingRmsClient.Nationality;
        sfdcClientToMap.PersonDoNotCall            = incomingRmsClient.DonotCall;
        sfdcClientToMap.DoNotSMS__pc               = incomingRmsClient.DoNotSMS;
        sfdcClientToMap.DoNotContactbyPost__pc     = incomingRmsClient.DoNotContactbyPost;
        sfdcClientToMap.PersonHasOptedOutOfEmail   = incomingRmsClient.HasOptedoutofEmail;*/

        //sfdcClientToMap.Can_Be_Contacted_By_Phone__pc    = incomingRmsClient.DonotCall != NULL? !incomingRmsClient.DonotCall: NULL;
        //sfdcClientToMap.Can_Be_Contacted_By_SMS__pc      = incomingRmsClient.DoNotSMS != NULL? !incomingRmsClient.DoNotSMS: NULL;
        //sfdcClientToMap.Can_Be_Contacted_By_Mail__pc     = incomingRmsClient.DoNotContactbyPost != NULL? !incomingRmsClient.DoNotContactbyPost: NULL;
        //sfdcClientToMap.Can_Be_Contacted_By_Email__pc    = incomingRmsClient.HasOptedoutofEmail != NULL? !incomingRmsClient.HasOptedoutofEmail: NULL;
        // ---End MTOU--- //

        sfdcClientToMap.PrimaryAddressLine1__pc    = incomingRmsClient.PrimaryAddressLine1;
        sfdcClientToMap.PrimaryAddressLine2__pc    = incomingRmsClient.PrimaryAddressLine2;
        sfdcClientToMap.PrimaryAddressLine3__pc    = incomingRmsClient.PrimaryAddressLine3;
        sfdcClientToMap.PrimaryZipCode__pc         = incomingRmsClient.PrimaryZipCode;
        sfdcClientToMap.PrimaryCity__pc            = incomingRmsClient.PrimaryCity;
        //sfdcClientToMap.PrimaryCountry__pc         = incomingRmsClient.PrimaryCountry;
        sfdcClientToMap.SPO_Country_code__pc         = incomingRmsClient.PrimaryCountry;
        sfdcClientToMap.HomeAddressCountryCode__pc = incomingRmsClient.PrimaryCountry;

        if(sfdcClientToMap.SPO_Country_code__pc != 'CHN')
        {
            sfdcClientToMap.PrimaryStateProvince__pc   = incomingRmsClient.PrimaryStateProvince;
        }
        else
        {
            sfdcClientToMap.SPO_Primary_Province_State__pc   = incomingRmsClient.PrimaryStateProvince;
        }
        
        //sfdcClientToMap.HomePhoneCountryCode__pc   = incomingRmsClient.HomePhoneCountryCode;        
        sfdcClientToMap.PersonHomePhone            = incomingRmsClient.HomePhone;
        //sfdcClientToMap.MobilePhoneCountryCode__pc = incomingRmsClient.MobilePhoneCountryCode;
        sfdcClientToMap.PersonMobilePhone          = incomingRmsClient.MobilePhone;
        //sfdcClientToMap.WorkPhoneCountryCode__pc   = incomingRmsClient.WorkPhoneCountryCode;
        sfdcClientToMap.Phone                      = incomingRmsClient.Phone;

        return sfdcClientToMap;
    }
}