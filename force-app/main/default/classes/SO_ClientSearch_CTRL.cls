public without sharing class SO_ClientSearch_CTRL
 //extends SO_BaseController 
 //implements SO_ITablePagination_INTERFACE 
{ 

    //public Enum DataSourceEnum { WS, DB }

    //private static Map<String, String> accViewColumsMap;
    //private static Map<String, String> wsViewColumsMap;
    //private static Set<String> toSerializeAccFieldSet;

    //static 
    //{

    //    accViewColumsMap = new Map<String, String>
    //    {
    //        'Name'                      => Label.LV_SO_Name,                        
    //        'PrimaryAddressLine1__pc'   => Label.LV_SO_Address, 
    //        'Location__c'               => Label.LV_SO_Location + '!!sort-by=PrimaryCity__pc', //sorted by PrimaryCity__pc 
    //        'PersonEmail'               => Label.LV_SO_Email, 
    //        'PersonHomePhone'           => Label.LV_SO_Home_phone_country_code,
    //        'PersonMobilePhone'         => Label.LV_SO_Mobile_phone_country_code, 
    //        'Phone'                     => Label.LV_SO_Work_phone_country_code,
    //        'DREAMID__c'                => Label.LV_SO_DREAM_ID,
    //        'PrimaryCity__pc'           => null,     //null tells to the component do not show this column on the table. used inside template formula only
    //        'SPO_Country_code__pc'      => null,
    //        'Actions'                   => Label.LV_SO_Actions + '!!width=250px!!sort-by=false' 
    //    };

    //    wsViewColumsMap = new Map<String, String> 
    //    {

    //         'Name'                 => Label.LV_SO_Name
    //        ,'PrimaryAddressLine1'  => Label.LV_SO_Address
    //        ,'Location__c'          => Label.LV_SO_Location + '!!sort-by=PrimaryCity' //sorted by PrimaryCity__pc
    //        ,'Email'                => Label.LV_SO_Email
    //        ,'HomePhone'            => Label.LV_SO_Home_phone_country_code
    //        ,'MobilePhone'          => Label.LV_SO_Mobile_phone_country_code
    //        ,'Phone'                => Label.LV_SO_Work_phone_country_code
    //        ,'DreamId'              => Label.LV_SO_DREAM_ID
    //        ,'PrimaryCity'          => null
    //        ,'PrimaryCountry'       => null
    //        ,'Actions'              => Label.LV_SO_Actions + '!!width=250px!!sort-by=false' 

    //    };

    //    toSerializeAccFieldSet = new Set<String> 
    //    {
    //        'Name'
    //        ,'PrimaryAddressLine1__pc'
    //        ,'PersonEmail' 
    //        ,'PersonHomePhone'
    //        ,'PersonMobilePhone'
    //        ,'Phone'
    //        ,'DREAMID__c'
    //        ,'PrimaryCity__pc'
    //        ,'SPO_Country_code__pc'
    //    };

    //}

    ////---------------------- Public fields ------------------------
    //public SO_ClientSearch_CTRL contr   {get {return this;}}
    //public Integer totalRows            { get; set; } 
    //public Integer startRow             { get; set; }
    //public Integer endRow               { get; set; }
    //public Integer clieniIndex          { get; set; }
    
    //public Boolean showTable            { get;set; }

    //public String  selectAccountId      { get; set; }
    //public String  productPage          { get; set; }

    //private Integer resultCounter;  
    //private List<Account> accountResultList;
    //private Map<String, String> viewColumsMap;
    //@testVisible private List<Map<String, Object>> generalResultObjMapList;

    //public Boolean         foundResultOnRMS     { get; set; }
    //public Boolean         showNewClientBtn     { get; set; }
    //private DataSourceEnum theDataSource        { get; set; }
    //public Boolean         isSearch             { get; private set; }

    //public  SO_Session.SessionState theSessionState { get; set; }

    //public Boolean  haveClient  { 
    //    get {
    //        return null != SO_Session.theCurrentBrief.AccountId;
    //    }
    //}

    //public Boolean showDisplayOrder {

    //    get {
    //        return 
    //                 !SO_PicklistDependency.OPP_ACCESSORY.equalsIgnoreCase(SO_Session.theCurrentBrief.SPO_ProductCategory__c) 
    //              && !SO_PicklistDependency.OPP_WATCH.equalsIgnoreCase(SO_Session.theCurrentBrief.SPO_ProductCategory__c);
    //    }
    //}

    //public Contact contactForCountry {get; private set;}

    ////---------------------- CTOR ------------------------
    //public SO_ClientSearch_CTRL(){
    //    PageReference pageRef = validateNoBriefIdBase();
    //    if(pageRef == null)
    //    {
    //        resultCounter = 0;
    //        showNewClientBtn = false;
    //        //viewColumsMap = accViewColumsMap;
    //        viewColumsMap = new Map<String, String>();
            
    //        theSessionState = SO_Session.retSessionState();

    //        if(null == theSessionState.searchClientData) {
    //            theSessionState.searchClientData = new SO_UTIL.SearchClientData();
    //        }

    //        this.contactForCountry = new Contact(SPO_Country__c = theSessionState.searchClientData.country);
    //    }


    //    //theSessionState.displayOrder = false; //Maybe will be requested in by kevin
    //}

    //public PageReference initPage() {
    //    //this.isFirstTimeSearch = true;
    //    PageReference pageRef = null;        // Redirect user if cloning brief
    //    try 
    //    {
    //        pageRef = validateNoBriefIdBase();
    //        if(pageRef == null && haveClient) 
    //        { 

    //            if(theSessionState.displayOrder) 
    //            {
    //                theSessionState.displayOrder = false;
    //                SO_Session.saveSession(theSessionState, true);
    //            }

    //            if(false == 'Brief in progress'.equalsIgnoreCase(SO_Session.theCurrentBrief.StageName)) 
    //            {
    //                pageRef = Page.SO_ViewClient;
    //                pageRef.getParameters().put('id',  SO_Session.theCurrentBrief.AccountId);
    //                pageRef.getParameters().put('bid', SO_Session.currentBriefId);
    //                pageRef.setRedirect(true);
    //            }
    //        }
    //    }
    //    catch(Exception exp) 
    //    {
    //        SO_UTIL.addErrorMessage(exp);
    //        pageRef = null;
    //    }
    //    return pageRef;
    //}

    ////---------------------- SO_ITablePagination_INTERFACE implementation ------------------------
    ///**
    //*  @description         returns columns for table
    //*/
    //public Map<String, String> retColumns(String tableId)
    //{
    //    //System.debug('SO_ClientSearch_CTRL - retColumns: ' + tableId);
    //    //System.debug('SO_ClientSearch_CTRL - theDataSource: ' + theDataSource);
    //    //System.debug('SO_ClientSearch_CTRL - viewColumsMap: ' + viewColumsMap);
    //    return viewColumsMap;
    //}

    ///**
    //*  @description         Returns records for current page
    //*/
    //public List<Map<String, Object>> retQueryResult(String tableId, Integer lim, Integer offset, String sortColumn, String sortOrder){

    //    List<Map<String, Object>> resultObjMapList = new List<Map<String, Object>>();

    //    //System.debug('resultObjMapList size >> ' + generalResultObjMapList.size());

    //    if(SO_UTIL.isNotEmpty(generalResultObjMapList)) {

    //        //System.debug('offset >> ' + offset + ' lim >> ' + lim);
    //        Integer size = Math.min(offset + lim, generalResultObjMapList.size());

    //        for(Integer Y = offset; Y < size; Y++) {

    //            resultObjMapList.add(generalResultObjMapList[Y]);
    //        }
    //    }

    //    //System.debug('resultObjMapList >> ' + resultObjMapList);

    //    return resultObjMapList;
    //}
    
    ///**
    //*  @description         Returns total count of rows
    //*/
    //public Integer retTotalCount(String tableId){
    
    //    return resultCounter;
    //}

    ///**
    //*  @description         sets current position in the table
    //*/
    //public void getCurrentPosition(String tableId,      Integer totalPages, 
    //                               Integer currentPage, Integer totalRows, 
    //                               Integer currentRow,  Integer rowFrom, Integer rowTo) 
    //{
    //        this.totalRows = totalRows;
    //        this.startRow = rowFrom;
    //        this.endRow = rowTo;
    //}

    ///**
    //*  @description         returns template for given column
    //*/
    //public String retTemplate(String tableId, String field, Object target){

    //    //System.debug('retTemplate.theDataSource >> ' + theDataSource);

    //    if(DataSourceEnum.WS == theDataSource) {

    //        return wsTemplate(tableId, field, target);
    //    }
    //    else if(DataSourceEnum.DB == theDataSource) {

    //        return dbTemplate(tableId, field, target);  
    //    }

    //    return '';
    //}

    //private String exractValue(Object value, String nullValue) {

    //    //Object value = productRef.get(field);
    //    if(null == value || String.isBlank((String)value)) {

    //        return nullValue; //'&nbsp;';
    //    }
    //    else {
    //        return String.valueOf(value);
    //    }
    //}

    //private String exractValue(Object value) {

    //    return exractValue(value, '');//'&nbsp;'
    //}

    //public String wsTemplate(String tableId, String field, Object target) {

    //    Map<String, Object> productRef = (Map<String, Object>)target;
    //    String value = exractValue(productRef.get(field), '&nbsp;');

    //    //System.debug('TEMPLATE = ' + field + ' >> ' + value);

    //    if (field == 'Location__c'/*Virtual template field*/){
    //        //template formula for this column. We must query the database for the fields used in the template
    //        String city;
    //        String country;

    //        if(productRef.containsKey('PrimaryCity')) {

    //            city = exractValue(productRef.get('PrimaryCity'));   

    //        } else if(productRef.containsKey('PrimaryCity__pc')) {

    //            city = exractValue(productRef.get('PrimaryCity__pc'));
    //        }

    //        if(productRef.containsKey('PrimaryCountry')) {

    //            country = exractValue(productRef.get('PrimaryCountry'));     

    //        } else if(productRef.containsKey('SPO_Country_code__pc')) {

    //            country = exractValue(productRef.get('SPO_Country_code__pc'));
    //        }
            
    //        String address;
    //        if(String.isNotBlank(city)) {
    //            address = city; 
    //        }

    //        if(String.isNotBlank(country)) {
    //            address += ' , ' + country;
    //        }
    //        return  address;
    //    }
    //    else if('Name' == field) {
            
    //        String oneName = String.format('{0} {1} {2} {3}', new String[] { 
    //                                    String.valueOf(productRef.get('FirstName'))
    //                                   ,String.valueOf(productRef.get('Firstname2'))
    //                                   ,String.valueOf(productRef.get('LastName'))
    //                                   ,String.valueOf(productRef.get('Lastname2')) });
            
    //        return oneName;

    //    }
    //    else if('Email' == field) {
    //        return value;
    //    }
        
    //    else if('Phone' == field) {
    //        return value;
    //    }
    //    else if (field == 'Actions'){
    //        return '<input type="button" class="btn btn-default margin-left-md" value="Select" onclick="{0}" />'.replace('{0}', value);
    //    }
    //    else {
    //        return value;
    //    }
    //    return null;
    //}

    //public String dbTemplate(String tableId, String field, Object target) {

    //    Map<String, Object> productRef = (Map<String, Object>)target;
    //    String value = exractValue(productRef.get(field), '&nbsp;');

    //    //System.debug('TEMPLATE = ' + field + ' >> ' + value);

    //    if (field == 'Location__c'/*Virtual template field*/){
    //        //template formula for this column. We must query the database for the fields used in the template
    //        String city = '';
    //        String country = '';

    //        if(productRef.containsKey('PrimaryCity')) {

    //            city = exractValue(productRef.get('PrimaryCity'));   

    //        } else if(productRef.containsKey('PrimaryCity__pc')) {

    //            city = exractValue(productRef.get('PrimaryCity__pc'));
    //        }

    //        if(productRef.containsKey('PrimaryCountry')) {

    //            country = exractValue(productRef.get('PrimaryCountry'));     

    //        } else if(productRef.containsKey('SPO_Country_code__pc')) {

    //            country = exractValue(productRef.get('SPO_Country_code__pc'));
    //        }
            
    //        String address = '';
    //        if(String.isNotBlank(city)) {
    //            address = city; 
    //        }

    //        if(String.isNotBlank(country)) {
    //            address += ' , ' + country;
    //        }
    //        return  address;
    //    }
    //    else if('Name' == field) {

    //        return value;
    //    }
    //    else if('DREAMID__c' == field) {
    //        return value;
    //    }
    //    else if('Email' == field) {
    //        return value;
    //    }
    //    else if ('Actions' == field){
    //        return '<input type="button" class="btn btn-default margin-left-md" value="Select" onclick="{0}" />'.replace('{0}', value);
    //    }
    //    else {
    //        return value;
    //    }
    //    return value;

    //}

    ////---------------------- Public methods ------------------------
   

    //public PageReference cloneClient() {
    //    try {
    //        //System.debug('clieniIndex >> ' + clieniIndex);
    //        Map<String, Object> objMap = generalResultObjMapList[Integer.valueOf(clieniIndex)];
    //        //System.debug('objMap['+ clieniIndex + '] >> ' + JSON.serialize(objMap));

    //        //todo insert client - account
    //        SO_OrderPageSwitch  pageSwitcher = new SO_OrderPageSwitch();

    //        SO_WS_RMS_DoClientEnquiry ws = new SO_WS_RMS_DoClientEnquiry();
    //        SO_WS_RMS_DoClientEnquiry.DataInput dataIn = new SO_WS_RMS_DoClientEnquiry.DataInput();

    //        //dataIn.StoreCode = pageSwitcher.currentUser.DefaultStore__c;
    //        dataIn.StoreCode = SO_Session.theCurrentBrief.SPO_Store__r.RetailStoreId__c;
    //        dataIn.RMSId = (String)objMap.get('RMSId'); //'01295Q'; 

    //        //System.debug('SFDC dataIn: ' + dataIn);
    //        SO_WS_RMS_DoClientEnquiry.Result result = ws.doClientEnquiry(dataIn);
    //        //System.debug('SFDC WS result ' + result);

    //        if(String.isNotBlank(result.error)) {
    //            //System.debug(system.LoggingLevel.ERROR, result.error);
    //            throw new SO_UTIL.ApplicationException(Label.SO_LV_WS_Error);
    //        }

    //        Map<String, RecordType> recordTypeByDevMap = SO_UTIL.retRecordTypeByDevMap(new Set<String>{'ACC_PersonAccount'});

    //        Account newAccount = new Account(); 
    //        newAccount.RecordTypeId = recordTypeByDevMap.get('ACC_PersonAccount').Id;

    //        newAccount = SO_CreateUpdateRMSCLient_Utils.MapRmsClientIntoSfdcClient(result,newAccount);

    //        SO_Session.putValueInPartition(SO_Session.ACCOUNT_FROM_RMS_CACHE_KEY, newAccount);
    //        return redirectToNewClientWithRMSClientData(dataIn.RMSId);
    //    }
    //    catch(Exception exp) {
    //        this.showMessageOnTop = true;
    //        SO_UTIL.addErrorMessage(exp);
    //        return null;

    //    }
    //}

    //public PageReference showAccount() {
    //    return assignClientToOpportunity(this.selectAccountId);
    //}

    //private PageReference redirectToNewClientWithRMSClientData(String rmsId)
    //{
    //    PageReference pageRef = Page.SO_NewEditClient;
    //    pageRef.getParameters().put('bid', SO_Session.currentBriefId);
    //    pageRef.getParameters().put('rmsId', rmsId);
    //    return pageRef;
    //}

    //private PageReference assignClientToOpportunity(String clientID) {

    //    PageReference pageRef = Page.SO_NewEditClient;
    //    pageRef.getParameters().put('id', clientID);
    //    pageRef.getParameters().put('bid', SO_Session.currentBriefId);
    //    return pageRef;
    //}


    //public PageReference checkDisplayOrder() 
    //{
    //    try 
    //    {
    //        clear();
    //    } 
    //    catch(Exception exp) {SO_UTIL.addErrorMessage(exp);}

    //    return null;
    //}

    ///**
    // *  @description        Clears form
    //*/
    //public PageReference clear()
    //{
    //    try 
    //    {
    //        this.showTable = false;
    //        this.isSearch = false;
    //        this.showNewClientBtn = false;
    //        this.foundResultOnRMS = false;
    //        clearSearchResult();
    //    }
    //    catch(Exception exp) {SO_UTIL.addErrorMessage(exp);}

    //    return null;
    //}

    ////Clear filter and result
    //private void clearSearchResult() {

    //    if(null != generalResultObjMapList) {
    //        generalResultObjMapList.clear();
    //    }
    //    generalResultObjMapList = new List<Map<String, Object>>();
    //    theSessionState.searchClientData = new SO_UTIL.SearchClientData();
    //    this.contactForCountry.SPO_Country__c = null;
    //    SO_Session.saveSession(theSessionState, true);
    //}

    ///**
    // *  @description        Performs searching
    //*/
    //public PageReference search()
    //{
    //    showTable = false;
    //    this.showMessageOnTop = false;
    //    if(theSessionState.displayOrder == false)
    //    {
    //        this.foundResultOnRMS = false;
    //        try {

    //            if(String.isBlank(theSessionState.searchClientData.lastName) 
    //                && String.isBlank(theSessionState.searchClientData.email) 
    //                && String.isBlank(theSessionState.searchClientData.phoneNumber) 
    //                && String.isBlank(theSessionState.searchClientData.passportNumber)) 
    //            {
    //                return null;
    //            }

    //            //theSessionState.searchClientData.country = this.contactForCountry.SPO_Country__c;

    //            //if(String.isNotBlank(theSessionState.searchClientData.country)
    //            //    && !SO_UTIL.COUNTRY_CODE_BY_STORE_COUNTRY_MAP.containsKey(theSessionState.searchClientData.country.toUpperCase()))
    //            //{
    //            //    this.showMessageOnTop = true;
    //            //    SO_UTIL.addErrorMessage('"' + theSessionState.searchClientData.country + '" ' + Label.LV_SO_NotValidCountryName);
    //            //    return null;
    //            //}

    //            if(String.isNotBlank(this.contactForCountry.SPO_Country__c)
    //                && !SO_UTIL.COUNTRY_CODE_BY_STORE_COUNTRY_MAP.containsKey(this.contactForCountry.SPO_Country__c.toUpperCase()))
    //            {
    //                this.showMessageOnTop = true;
    //                SO_UTIL.addErrorMessage('"' + this.contactForCountry.SPO_Country__c + '" ' + Label.LV_SO_NotValidCountryName);
    //                return null;
    //            }

    //            theSessionState.searchClientData.country = String.isNotBlank(this.contactForCountry.SPO_Country__c) ? this.contactForCountry.SPO_Country__c.toUpperCase() : null;
    //            theSessionState.searchClientData.storeCode = SO_Session.theCurrentBrief.SPO_Store__r.RetailStoreId__c;
    //            this.foundResultOnRMS = searchFromRMS();
    //            if(this.foundResultOnRMS == false)
    //            {
    //                searchFromSF();
    //            }
    //            //System.debug('SO_ClientSearch_CTRL -  search - this.foundResultOnRMS: ' + this.foundResultOnRMS);
    //            SO_Session.saveSession(theSessionState, true); 
    //        }
    //        catch(Exception exp) 
    //        {
    //            SO_UTIL.addErrorMessage(exp);
    //        }
    //    }
        
    //    return null;
    //}

    //public Boolean searchFromRMS()
    //{
    //    //System.debug('SO_ClientSearch_CTRL - searchFromRMS:');
    //    this.theDataSource = null;
    //    this.showTable = false;
    //    this.isSearch = true;
    //    this.viewColumsMap = new Map<String, String>();

    //    SO_WS_RMS_DoClientSearch ws = new SO_WS_RMS_DoClientSearch();
    //    SO_WS_RMS_DoClientSearch.Result wsResult;
    //    generalResultObjMapList = new List<Map<String, Object>>();
    //    try 
    //    {
    //        wsResult = ws.doClientSearch(theSessionState.searchClientData); 
    //        //System.debug('SFDC wsResult: ' + wsResult);
    //    }
    //    catch(Exception exp) 
    //    {
    //        //System.debug('SO_ClientSearch_CTRL - searchFromRMS - ERROR: ' + exp);
    //        SO_UTIL.addErrorMessage(exp);
    //        wsResult = new SO_WS_RMS_DoClientSearch.Result();
    //    }
        
    //    if(SO_UTIL.isNotEmpty(wsResult.resultList)) 
    //    {

    //        this.theDataSource = DataSourceEnum.WS;

    //        //System.debug('search >> wsResult.resultList >> ' + wsResult.resultList.size());

    //        //columns mapping
    //        viewColumsMap = wsViewColumsMap;

    //        resultCounter = wsResult.nbRecords;
    //        for(Integer X = 0; X < resultCounter; X++) 
    //        {

    //            String serializeStr = JSON.serialize(wsResult.resultList[X]);
    //            //System.debug('serializeStr 1>> X = ' + X + ' >> '+ serializeStr);
    //            serializeStr = serializeStr.replace('null', '""');
    //            ////System.debug('serializeStr 2>> X = ' + X + ' >> '+ serializeStr);

    //            Map<String, Object> desMap = (Map<String, Object>)JSON.deserializeUntyped(serializeStr);
    //            desMap.put('Actions', 'cloneClient(' + X + ')');
    //            ////System.debug('resMap >> ' + desMap);
                
    //            generalResultObjMapList.add(desMap);
    //        }
    //        showTable = true;
    //        //System.debug('SO_ClientSearch_CTRL - searchFromRMS - generalResultObjMapList.isEmpty(): ' + generalResultObjMapList.isEmpty());
    //    }
    //    return !generalResultObjMapList.isEmpty();
    //}

    //public PageReference searchFromSF()
    //{

    //    if(String.isNotBlank(this.contactForCountry.SPO_Country__c)
    //        && !SO_UTIL.COUNTRY_CODE_BY_STORE_COUNTRY_MAP.containsKey(this.contactForCountry.SPO_Country__c.toUpperCase()))
    //    {
    //        this.showMessageOnTop = true;
    //        SO_UTIL.addErrorMessage('"' + this.contactForCountry.SPO_Country__c + '" ' + Label.LV_SO_NotValidCountryName);
    //        return null;
    //    }

    //    //System.debug('SO_ClientSearch_CTRL - searchFromSF:');
    //    theSessionState.searchClientData.country = String.isNotBlank(this.contactForCountry.SPO_Country__c) ? this.contactForCountry.SPO_Country__c.toUpperCase() : null;
    //    this.theDataSource = null;
    //    showNewClientBtn = true;
    //    this.showTable = false;
    //    this.isSearch = true;
    //    this.viewColumsMap = new Map<String, String>();
    //    generalResultObjMapList = new List<Map<String, Object>>();

    //    try
    //    {
    //        accountResultList = foundAccountList(theSessionState.searchClientData);
    //    }
    //    catch(Exception exp) 
    //    {
    //        SO_UTIL.addErrorMessage(exp);
    //        accountResultList = new List<Account>();
    //    }
        
    //    //System.debug('SO_ClientSearch_CTRL - theSessionState.searchClientData: ' + theSessionState.searchClientData);

    //    if(!accountResultList.isEmpty())
    //    {
    //        this.theDataSource = DataSourceEnum.DB;
    //        //columns mapping
    //        viewColumsMap = accViewColumsMap;

    //        resultCounter = accountResultList.size();
    //        //System.debug('search >> accountResultList >> ' + accountResultList);
    //        for(Integer X = 0; X < resultCounter; X++) 
    //        {
    //            Account oneAccount = accountResultList[X];
    //            Map<String, Object> serializedObjMap = new Map<String, Object>();

    //            for(String fieldName : toSerializeAccFieldSet) 
    //            {
    //                Object value = oneAccount.get(fieldName);
    //                if(null != value) 
    //                {
    //                    serializedObjMap.put(fieldName, value);
    //                }
    //            }
    //            serializedObjMap.put('Actions', 'showAccount(\'' + oneAccount.Id + '\');');
    //            generalResultObjMapList.add(serializedObjMap);
    //        }
    //        showTable = true;
    //    }

    //    SO_Session.saveSession(theSessionState, true);

    //    //System.debug('SO_ClientSearch_CTRL - searchFromSF - generalResultObjMapList.isEmpty(): ' + generalResultObjMapList.isEmpty());
    //    //return !generalResultObjMapList.isEmpty();
    //    return null;
    //}

    //public List<Account> foundAccountList(SO_UTIL.SearchClientData inputData) {

    //    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();

    //    if(String.isNotBlank(theSessionState.searchClientData.firstName)) {

    //        if(theSessionState.searchClientData.firstName.endsWith('*')) {

    //            listSearchCriterias.add(createSearchCriteria('GivenName', LV_UTILS.OperatorEnum.startsWith, theSessionState.searchClientData.firstName.remove('*')));
    //        }
    //        else {
    //            listSearchCriterias.add(createSearchCriteria('GivenName', LV_UTILS.OperatorEnum.EQUALS, theSessionState.searchClientData.firstName));
    //        }
    //    }

    //    if(String.isNotBlank(theSessionState.searchClientData.lastName)) {

    //        if(theSessionState.searchClientData.lastName.endsWith('*')) {
                
    //            listSearchCriterias.add(createSearchCriteria('Surname', LV_UTILS.OperatorEnum.startsWith, theSessionState.searchClientData.lastName.remove('*')));
    //        } 
    //        else {
    //            listSearchCriterias.add(createSearchCriteria('Surname', LV_UTILS.OperatorEnum.EQUALS, theSessionState.searchClientData.lastName));
    //        }
    //    }

    //    if(String.isNotBlank(theSessionState.searchClientData.email)) {

    //        if(theSessionState.searchClientData.email.endsWith('*')) {
                
    //            listSearchCriterias.add(createSearchCriteria('Email', LV_UTILS.OperatorEnum.startsWith, theSessionState.searchClientData.email.remove('*')));
    //        }
    //        else {
    //            listSearchCriterias.add(createSearchCriteria('Email', LV_UTILS.OperatorEnum.EQUALS, theSessionState.searchClientData.email));
    //        }
    //    }

    //    if(String.isNotBlank(theSessionState.searchClientData.phoneNumber)) {
    //        if(theSessionState.searchClientData.phoneNumber.endsWith('*')) {

    //            listSearchCriterias.add(createSearchCriteria('Phone', LV_UTILS.OperatorEnum.startsWith, theSessionState.searchClientData.phoneNumber.remove('*')));
    //        }
    //        else {
                
    //            listSearchCriterias.add(createSearchCriteria('Phone', LV_UTILS.OperatorEnum.EQUALS, theSessionState.searchClientData.phoneNumber));
    //        }
    //    }

    //    if(String.isNotBlank(theSessionState.searchClientData.passportNumber)) {

    //        listSearchCriterias.add(createSearchCriteria('Passport', LV_UTILS.OperatorEnum.EQUALS, theSessionState.searchClientData.passportNumber));
    //    }

    //    if(String.isNotBlank(this.contactForCountry.SPO_Country__c)) {

    //        listSearchCriterias.add(createSearchCriteria(
    //            'Country', 
    //            LV_UTILS.OperatorEnum.EQUALS, 
    //            SO_UTIL.COUNTRY_CODE_BY_STORE_COUNTRY_MAP.get(this.contactForCountry.SPO_Country__c.toUpperCase())));
    //        //if(theSessionState.searchClientData.country.endsWith('*')) {

    //        //    listSearchCriterias.add(createSearchCriteria('Country', LV_UTILS.OperatorEnum.startsWith, theSessionState.searchClientData.country.remove('*')));
    //        //}
    //        //else {
    //        //    listSearchCriterias.add(createSearchCriteria('Country', LV_UTILS.OperatorEnum.EQUALS, theSessionState.searchClientData.country));
    //        //}
    //    }
        
    //    if(String.isNotBlank(theSessionState.searchClientData.zipCode)) {

    //        listSearchCriterias.add(createSearchCriteria('ZipCode', LV_UTILS.OperatorEnum.startsWith, theSessionState.searchClientData.zipCode));
    //    }

    //    List<String> listSearchFields = new List<String>(toSerializeAccFieldSet);
    //    Integer clientPerPage = 20;
    //    Integer currentPage = 0;
    //    String  orderByField = null;
    //    Boolean isDreamIdUsed = true;
    //    String  attachedFilter = '';
    //    String  queryType = LV_UTILS.QueryTypeEnum.Automatic.name();

    //    List<Account> listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
    //                                                    currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);
    //    //this.isFirstTimeSearch = true;

    //    return listClient;
    //}

    //private static LV_UTILS.SearchCriteria createSearchCriteria(String label, LV_UTILS.OperatorEnum operator, String value){

    //  LV_UTILS.SearchCriteria searchCriteria = new LV_UTILS.SearchCriteria();
    //  searchCriteria.Label = label;
    //  searchCriteria.Value = value;
    //  searchCriteria.Operator = operator.name();

    //  return searchCriteria;
    //}

    //public PageReference nextAndSetDisplayOrder(){
    //    PageReference pageRef = null;

    //    try
    //    {
    //        // redirect user to the next page
    //        Id briefId = SO_Session.currentBriefId;
    //        if(null != briefId) 
    //        {
    //            if(true == theSessionState.displayOrder) 
    //            {
    //                if(null != SO_Session.theCurrentBrief.SPO_BaseSKURefmodelSKU__c)
    //                {
    //                    pageRef = Page.SO_BriefOrder;
    //                    pageRef.getParameters().put('id', briefId);
    //                }
    //                else
    //                {
    //                    pageRef = Page.SO_ProductSearch;
    //                    pageRef.getParameters().put('bid', briefId);
    //                }
    //            }
    //            else 
    //            { 
                    
    //                pageRef = Page.SO_NewEditClient;
    //                pageRef.getParameters().put('bid', briefId);
    //            }

    //            SO_Session.saveSession(theSessionState, true);
    //        }
    //        else
    //        {
    //            pageRef = Page.SO_ChoosePath;
    //        }

    //    }
    //    catch(Exception e)
    //    {
    //        //System.debug('SO_ClientSearch - nextAndSetDisplayOrder - ERROR: ' + e);
    //        pageRef = null;
    //    }

    //    return pageRef;
    //}
}