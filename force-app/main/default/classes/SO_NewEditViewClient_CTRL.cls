public with sharing class SO_NewEditViewClient_CTRL extends SO_BaseController{

    private static Map<String, String> countryCodeByStoreCountryMap = new Map<String, String>
    {
        'ARGENTINA' => 'ARG',
        'ARUBA' => 'ABW',
        'AUSTRALIA' => 'AUS',
        'AUSTRIA' => 'AUT',
        'BAHRAIN' => 'BHR',
        'BARBADE' => 'BRB',
        'BELGIUM' => 'BEL',
        'BRAZIL' => 'BRA',
        'CANADA' => 'CAN',
        'CHILE' => 'CHL',
        'CHINA' => 'CHN',
        'COLOMBIA' => 'COL',
        'CYPRUS' => 'CYP',
        'CZECH REPUBLIC' => 'CZE',
        'DENMARK' => 'DNK',
        'DOMINICAIN REPUBLIC' => 'DOM',
        'FINLAND' => 'FIN',
        'FRANCE' => 'FRA',
        'GERMANY' => 'DEU',
        'GREECE' => 'GRC',
        'GUAM' => 'GUM',
        'HONG KONG' => 'HKG',
        'HUNGARY' => 'HUN',
        'INDIA' => 'IND',
        'INDONESIA' => 'IDN',
        'IRELAND' => 'IRL',
        'ISRAEL' => 'ISR',
        'ITALY' => 'ITA',
        'JAPAN' => 'JPN',
        'JORDANIE' => 'JOR',
        'KAZAKHSTAN' => 'KAZ',
        'KUWAIT' => 'KWT',
        'LEBANON' => 'LBN',
        'LUXEMBOURG' => 'LUX',
        'MACAU' => 'MAC',
        'MALAYSIA' => 'MYS',
        'MEXICO' => 'MEX',
        'MONGOLIA' => 'MNG',
        'MOROCCO' => 'MAR',
        'NETHERLANDS' => 'NLD',
        'NEW ZEALAND' => 'NZL',
        'NORWAY' => 'NOR',
        'PANAMA' => 'PAN',
        'PHILIPPINES' => 'PHL',
        'POLAND' => 'POL',
        'PORTUGAL' => 'PRT',
        'QATAR' => 'QAT',
        'ROMANIA' => 'ROU',
        'RUSSIAN FEDERATION' => 'RUS',
        'SAUDI ARABIA' => 'SAU',
        'SINGAPORE' => 'SGP',
        'SOUTH AFRICA' => 'ZAF',
        'SPAIN' => 'ESP',
        'SWEDEN' => 'SWE',
        'SWITZERLAND' => 'CHE',
        'TAIWAN' => 'TWN',
        'THAILAND' => 'THA',
        'TURKEY' => 'TUR',
        'UKRAINE' => 'UKR',
        'UNITED ARAB EMIRATES' => 'ARE',
        'UNITED KINGDOM' => 'GBR',
        'USA' => 'USA',
        'SAIPAN' => 'USA',
        'URUGUAY' => 'URY',
        'VENEZUELA' => 'VEN',
        'VIETNAM' => 'VNM'
    };

    //--------------------------- Public fields ---------------
    public Boolean isCloning        {get; set;}  
    public Boolean addressValid     {get; set;}

    //--------------------------- Private fields --------------
    private ApexPages.StandardController stdController;
    private String clientId { get; set; }
    private static Set<String> openStageSet;
    private static Set<String> wonStageSet;
    private static Set<String> lostStageSet;
    private static List<String> moreFieldsToClientThatNotUsedInPageList = new List<String> {
        'LastModifiedDate',
        'Salutation',
        'HomePhoneCountrycode__pc',
        'MobilePhoneCountryCode__pc',
        'WorkPhoneCountryCode__pc'
    };

    //--------------------------- Static fields --------------
    static 
    {
        openStageSet = new Set<String>
        {
            'Brief in progress',
            'Quotation in progress',
            'Quotation submitted',
            'Quotation accepted',
            'Deposit sent',
            'Creation in progress',
            'In progress'
        };

        wonStageSet    = new Set<String>
        {
             'Payment confirmed',
             'Closed Won'
        };  

        lostStageSet = new Set<String>
        {
            'Quotation rejected',
            'Cancelled by store',
            'Cancelled by Production',
            'Cancelled - Migrated in Xstore'
        };
    }
    //--------------------------- Public fields --------------
    public SO_NewEditViewClient_CTRL contr  {get {return this;}}
    public Account client                   {get; set;}
    public Contact clientContact            {get; set;}
    public String title                     {get; set;}
    public String birthdateStr              {get; set;}
    public Datetime birthdate               {get; set;}
    public String role                      {get; private set;}
    public Boolean isReadonlyMode           {get; private set;}
    //public String storeCountry              {get; set;}
    public Opportunity opp                  {get; set;}
    public User dummyUserForCountryPickList {get; set;}
    public List<Contact> dummyContactForPhoneCountyCodeList {get;set;} 


    /* Controller */
    public SO_NewEditViewClient_CTRL(ApexPages.StandardController stdController) {
        PageReference pageRef = validateNoBriefIdBase();
        if(pageRef == null)
        {
            this.stdController = stdController;
            if(!Test.isRunningTest()){
                this.stdController.addFields(moreFieldsToClientThatNotUsedInPageList);
            }
            this.clientId = stdController.getId();
            init();
        }

    }


    // Set role & readonly
    public void getUserRoleAndReadonlyMode(){
        SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
        SO_OrderPageSwitch.LogicalUserRoleEnum role = orderPageSwitch.sfoUserRoleByObject(SO_Session.theCurrentBrief); 
        this.role = role.name();    // can be one of: [Store, Production, Other]
        System.debug('SO_BriefOrder_CTRL role: '+this.role);
        this.isReadonlyMode = SO_OrderPageSwitch.isReadonlyMode();


    }

    public void setBirthdate() {
        if(this.client != null 
           && String.isNotBlank(client.BirthdateYear__pc) 
           && String.isNotBlank(client.BirthdateMonth__pc)
           && String.isNotBlank(client.BirthdateDay__pc)) 
        {
            Integer year = Integer.valueOf(client.BirthdateYear__pc);
            Integer month = Integer.valueOf(client.BirthdateMonth__pc); 
            Integer day = Integer.valueOf(client.BirthdateDay__pc);
            this.birthdate = Datetime.newInstance(year, month, day);
            this.birthdateStr = Datetime.newInstance(year, month, day).format();
        }
        else {
            this.birthdate = null;
        }
    }

    public void splitBirthdate() {
        //this.birthdate = SO_UTIL.dateStringIsValid(this.birthdateStr) ? SO_UTIL.transformDateStringToDateTimeFormat(this.birthdateStr) : null;
        this.birthdate = SO_UTIL.convertDate(birthdateStr);
        if (null != this.birthdate && this.client != null){
            client.BirthdateYear__pc = String.valueOf(this.birthdate.year());   
            client.BirthdateMonth__pc = String.valueOf(this.birthdate.month()); 
            client.BirthdateDay__pc = String.valueOf(this.birthdate.day());     
        }   
    }
    public List<OrderViewLine> openOrderViewLineList { 
        get {
            if(null == openOrderViewLineList) {
                openOrderViewLineList = new List<OrderViewLine>();
            }
            return openOrderViewLineList;
        } 
        set; 
    }
    //public List<OrderViewLine> closedOrderViewLineList { 
    //    get {
    //        if(null == closedOrderViewLineList) {
    //            closedOrderViewLineList = new List<OrderViewLine>();
    //        }
    //        return closedOrderViewLineList;
    //    } 
    //    set; 
    //}

    public Boolean showSearchClientBtn {

        get {
            if(null == showSearchClientBtn) {
                showSearchClientBtn = true;
            }
            return showSearchClientBtn;
        }
        set;
    }

    public Boolean isMandatory_VAT {

        get {
            if((client.SPO_Country_code__pc == 'CHL' ||client.SPO_Country_code__pc == 'COL' ||client.SPO_Country_code__pc == 'BRB' ||
                client.SPO_Country_code__pc == 'BRA' ||client.SPO_Country_code__pc == 'GRC'||client.SPO_Country_code__pc == 'FRA') 
                &&
                (this.opp.StageName == 'Quotation accepted' || this.opp.StageName == 'Quotation submitted' ||
                this.opp.StageName == 'Quotation in progress' ||this.opp.StageName == 'Brief in progress' )) {
                isMandatory_VAT = true;
            }
            return isMandatory_VAT;
        }
        set;
    }

    public Boolean isMandatory_TAX {

        get {
            if((client.SPO_Country_code__pc == 'TUR' ||client.SPO_Country_code__pc == 'GRC' ||client.SPO_Country_code__pc == 'ITA' ||
                client.SPO_Country_code__pc == 'MEX' ||client.SPO_Country_code__pc == 'BRA'||client.SPO_Country_code__pc == 'FRA') 
                &&
                (this.opp.StageName == 'Quotation accepted' || this.opp.StageName == 'Quotation submitted' ||
                this.opp.StageName == 'Quotation in progress' ||this.opp.StageName == 'Brief in progress' )) {
                isMandatory_TAX = true;
            }
            return isMandatory_TAX;
        }
        set;
    }

    public Boolean isMandatory_FiscalCode {

        get {
            System.debug('isMandatory_FiscalCode begin');
            if((client.SPO_Country_code__pc == 'ITA' ||client.SPO_Country_code__pc == 'FRA') 
                &&
                (this.opp.StageName == 'Quotation accepted' || this.opp.StageName == 'Quotation submitted' ||
                this.opp.StageName == 'Quotation in progress' ||this.opp.StageName == 'Brief in progress' )) {
                isMandatory_FiscalCode = true;
            }
            else {
                isMandatory_FiscalCode = false;
            }
            System.debug('isMandatory_FiscalCode >> ' + isMandatory_FiscalCode);
            return isMandatory_FiscalCode;
        }
        set;
    }
    

    //--------------------------- Public methods --------------

    public override void init() 
    {
        try
        {
            User thisUserInfo = getUser();
            this.clientContact = new Contact();
            this.client = (Account)this.stdController.getRecord();
            this.client.RecordTypeId = SO_UTIL.retRecordTypeIdByName('Account', SO_Settings__c.getValues(SO_UTIL.PERSON_ACCOUNT_RECORD_TYPE_SETTINGS_NAME).Value__c);
            this.client.SPO_BypassVR__pc = true;

            if (SO_Session.theCurrentBrief != null ){
                this.opp = SO_Session.theCurrentBrief;
            }

            if (this.clientId == null) 
            {
                this.opp.SPO_RMSClientId__c = null;
                Object partitionValue = SO_Session.getValueFromPartition(SO_Session.ACCOUNT_FROM_RMS_CACHE_KEY);
                if(partitionValue != null && 
                    ApexPages.currentPage().getParameters().get('rmsId') != null)
                {
                    Account rmsClientCloned = (Account)partitionValue;
                    SO_CreateUpdateRMSCLient_Utils.mapClonedClientToLocalClient(this.client, rmsClientCloned);
                    system.debug('SFDC NewEditClient init : ' + this.client);
                    
                    this.clientContact.Salutation = this.client.Salutation;
                    this.clientContact.FirstName = this.client.FirstName;
                    this.clientContact.LastName = this.client.LastName;

                    //ticet 824 start:
                    this.client.IsProspect__pc = true;
                    this.client.ProspectForDream__c = true;
                    //ticet 824 end:

                    this.opp.SPO_RMSClientId__c = ApexPages.currentPage().getParameters().get('rmsId').escapeHtml4();
                }
                

                this.title = Label.LV_SO_New_client;

                String storeCountry = null;
                if(String.isNotBlank(this.opp.SPO_Store__r.StoreCountry__c)
                    && SO_UTIL.COUNTRY_CODE_BY_STORE_COUNTRY_MAP.containsKey(this.opp.SPO_Store__r.StoreCountry__c.toUpperCase()))
                {
                    storeCountry = SO_UTIL.COUNTRY_CODE_BY_STORE_COUNTRY_MAP.get(this.opp.SPO_Store__r.StoreCountry__c.toUpperCase());
                }
                if (this.client.NationalityCountryCode__pc == null){
                    this.client.NationalityCountryCode__pc = storeCountry;//thisUserInfo.Country__c ;
                }

                if (this.client.SPO_Country_code__pc == null){
                    this.client.SPO_Country_code__pc = storeCountry;//thisUserInfo.Country__c ;
                }

                this.initdummyContactForPhoneCountyCodeList();

            }
            else {
                
                this.title = this.client.Name;
                this.clientContact.Salutation = this.client.Salutation;
                this.clientContact.FirstName = this.client.FirstName;
                this.clientContact.LastName = this.client.LastName;
                //Data For Brief-Order Section
                List<Opportunity> opportunityList = retOpportunityByClientId(client.Id);

                for(Opportunity oneOrder : opportunityList) 
                {
                    if(openStageSet.contains(oneOrder.StageName)) 
                    {
                        openOrderViewLineList.add(new OrderViewLine(oneOrder));
                    }
                    //else if(wonStageSet.contains(oneOrder.StageName) || lostStageSet.contains(oneOrder.StageName))
                    //{
                    //    closedOrderViewLineList.add(new OrderViewLine(oneOrder));
                    //}
                }
                
                setBirthdate();

                // init Cloning and get real cloning param
                this.isCloning = SO_Session.theCurrentBrief.SPO_OpportunityCloning__c;
                //System.debug('SO_NewEditViewClient_CTRL - checkCloning - ApexPages.currentPage(): '+ApexPages.currentPage());
                
                showSearchClientBtn = (null == SO_Session.theCurrentBrief.AccountId
                                       || true == 'Brief in progress'.equalsIgnoreCase(SO_Session.theCurrentBrief.StageName)); 

                this.cleanLocalPhoneNumbers();
                this.initdummyContactForPhoneCountyCodeList();
            }

        }
        catch(Exception e){
            SO_UTIL.addErrorMessage(e);
        }        
    }

    private void cleanLocalPhoneNumbers()
    {
        this.client.HomePhoneCountrycode__pc = this.client.HomePhoneCountrycode__pc != null && this.client.LocalHomePhone__pc == null ?
                                                null : this.client.HomePhoneCountrycode__pc;
        this.client.MobilePhoneCountryCode__pc = this.client.MobilePhoneCountryCode__pc != null && this.client.LocalMobilePhone__pc == null ?
                                                null : this.client.MobilePhoneCountryCode__pc;
        this.client.WorkPhoneCountryCode__pc = this.client.WorkPhoneCountryCode__pc != null && this.client.LocalWorkPhone__pc == null ?
                                                null : this.client.WorkPhoneCountryCode__pc;
    }

    public void initdummyContactForPhoneCountyCodeList()
    {
        this.dummyContactForPhoneCountyCodeList = new List<Contact>();
        this.dummyContactForPhoneCountyCodeList.add(new Contact(TECH_PhoneCountryCode__c = this.client.HomePhoneCountrycode__pc));
        this.dummyContactForPhoneCountyCodeList.add(new Contact(TECH_PhoneCountryCode__c = this.client.MobilePhoneCountryCode__pc));
        this.dummyContactForPhoneCountyCodeList.add(new Contact(TECH_PhoneCountryCode__c = this.client.WorkPhoneCountryCode__pc));
    }

    public PageReference initPageAction(){

        PageReference pageRef = null;        // Redirect user if cloning brief
        try {
            pageRef = validateNoBriefIdBase();
            System.debug('ApexPages.currentPage().getUrl(): '+ApexPages.currentPage().getUrl()+' Page.SO_NewEditClient.getUrl(): '+Page.SO_NewEditClient.getUrl());
            if ( pageRef == null 
                && 'SO_ViewClient'.equalsIgnoreCase(this.pageName) 
                && null == client.Id
                )
            {
                pageRef = Page.SO_ClientSearch;
                pageRef.getParameters().put('bid', SO_Session.currentBriefId);
            }
            else
            {
                //get true if last client update was more then a minute ago:
                //Boolean isMoreThenAMinuteFromLastUpdate = client.LastModifiedDate != null ? 
                //                                            (DateTime.now().millisecond() - client.LastModifiedDate.millisecond()) > 1 * 60 * 1000
                //                                            : false;
                DateTime dt = DateTime.now();
                DateTime dfLess3Minutes = DateTime.newInstance(dt.date(), time.newInstance(dt.hour(), dt.minute() - 1, 0, 0));
                Boolean isMoreThenAMinuteFromLastUpdate = dfLess3Minutes > client.LastModifiedDate;

                if(!'SO_NewEditClient'.equalsIgnoreCase(this.pageName) 
                    && isMoreThenAMinuteFromLastUpdate ) 
                {

                    Account syncClientAcc = SO_CreateUpdateRMSCLient_Utils.syncClient( SO_Session.theCurrentBrief.SPO_Store__r.RetailStoreId__c
                                                                                       ,SO_Session.theCurrentBrief.SPO_RMSClientId__c
                                                                                       ,this.client, null);
                    Database.update(syncClientAcc);
                    this.stdController.reset();
                    if(!Test.isRunningTest()){
                        this.stdController.addFields(moreFieldsToClientThatNotUsedInPageList);
                    }   
                    this.client = (Account)this.stdController.getRecord(); 
                    this.initdummyContactForPhoneCountyCodeList();      
                }
            }

        }
        catch(SO_UTIL.RMSException exp) 
        {
            this.showMessageOnTop = true;
            SO_UTIL.addErrorMessage(exp);
            pageRef = null;
        }
        catch(Exception exp) {
            SO_UTIL.addErrorMessage(exp);
            pageRef = null;
        }
        return pageRef;
    }

    /**
     *@descriprion              Save client Action.
     *.
    */
    public PageReference saveClient(){

        System.debug('SO_NewEditViewClient_CTRL - saveClient:');
        PageReference pageRef = null;
        try{
            /* If Brazil - check address format */
            if ( this.client.SPO_Country_code__pc != null 
                && this.client.SPO_Country_code__pc == 'BRA')
            {
                // check address Format
                addressValid = false;
                String address = this.client.PrimaryAddressLine1__pc;
                if (address!= null){
                    String[] addressSplited = address.split(',');
                    if (addressSplited.size() == 2){
                        try
                        {
                            Integer addressNumber = Integer.valueOf( addressSplited[1].trim());
                            if (addressNumber > 0) 
                            {
                                addressValid= true;
                                this.client.PrimaryAddressLine1__pc = addressSplited[0].trim() + ', ' + addressSplited[1].trim();
                            }
                        }
                        catch(TypeException te)
                        {
                            //do nothing as this addressNumber remain false.
                        }
                    }
                }
                if (!addressValid){
                    System.debug('Client Save - addressValid: ' + addressValid);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,Label.LV_SO_client_error_message));
                    this.showMessageOnTop = true;
                    return pageRef;
                }
            } 

            this.client.RecordTypeId = SO_UTIL.retRecordTypeIdByName('Account', SO_Settings__c.getValues(SO_UTIL.PERSON_ACCOUNT_RECORD_TYPE_SETTINGS_NAME).Value__c);
            this.client.Salutation = this.clientContact.Salutation;
            this.client.FirstName = this.clientContact.FirstName;
            this.client.LastName = this.clientContact.LastName;

            this.client.HomePhoneCountrycode__pc   =  dummyContactForPhoneCountyCodeList[0].TECH_PhoneCountryCode__c;
            this.client.MobilePhoneCountryCode__pc =  dummyContactForPhoneCountyCodeList[1].TECH_PhoneCountryCode__c;
            this.client.WorkPhoneCountryCode__pc = dummyContactForPhoneCountyCodeList[2].TECH_PhoneCountryCode__c;

            /**
             * Added by J.C on December 2015
             * The function launch a Web Service creating/updating the Client from SFDC into the RMS.
             * If the Callout succeed
             *      -   The opportunity SPO_RMSClientId__c is updated with the Client RMS ID
             *  If the Callout succeed we continue, otherwise the W.S Error message is shown to the User and the flow can't go on.
             */
            system.debug('SFDC saveClient this.client: ' + this.client);  
            SO_CreateUpdateRMSCLient_Utils.SO_CreateUpdateRmsClientResult calloutResult = SO_CreateUpdateRMSCLient_Utils.createUpdateSFDCAccountIntoRMS(this.client, this.opp.SPO_RMSClientId__c);

            if(calloutResult != NULL 
                && calloutResult.calloutSuccessResult == true 
                && calloutResult.calloutClientRmsId != NULL)
            {     
                upsert this.client;
                this.opp.AccountId = this.client.Id;
                this.opp.SPO_RMSClientId__c = calloutResult.calloutClientRmsId;
                upsert this.opp;
                            
                pageRef = Page.SO_ViewClient;
                pageRef.getParameters().put('id', this.client.Id);
                pageRef.getParameters().put('bid', this.opp.Id);
                pageRef = pageRef.setRedirect(true);
            }
        }
        catch(SO_UTIL.RMSException exp) {
            this.showMessageOnTop = true;
            SO_UTIL.addErrorMessage(exp);
            pageRef = null;
        }
        catch(Exception ex){
            this.showMessageOnTop = true;
            SO_UTIL.addErrorMessage(ex);
            pageRef = null;
        }


        return pageRef; 
    }

    public PageReference next()
    {
        PageReference pageRef = Page.SO_ProductSearch;
        try{
            pageRef.getParameters().put('bid', SO_Session.currentBriefId);
            if(SO_Session.theCurrentBrief.SPO_BaseSKURefmodelSKU__c != null)
            {
                pageRef = Page.SO_BriefOrder;
                pageRef.getParameters().put('id', SO_Session.currentBriefId);
            }
        
        }
        catch(Exception e){
            System.debug('SO_NewEditViewClient_CTRL - next - ERROR: ' + e);
        }
        return pageRef;
    }

    //--------------------------- Private methods --------------

    
    private static List<Opportunity> retOpportunityByClientId(String clientId) {

        return
            [SELECT Id, Name, StageName, CreatedDate
                    ,SPO_OrderType__c  
                    ,SPO_BriefCode__c 
                    ,SPO_SkuQuantity__c
                    ,SPO_ExportPrice__c
                    ,SPO_UnitRetailPrice__c
                    ,SPO_BaseSKURefmodelSKU__c
                    ,SPO_BaseSKURefmodelSKU__r.Description__c
              FROM Opportunity 
             WHERE AccountId =: clientId
             ORDER BY CreatedDate DESC NULLS LAST LIMIT 10000];
    }
    

    public class OrderViewLine {

        //public SPO_FirmOrder__c theOrder { get; set; }
        public Opportunity theOrder             { get; private set; }   
        public Decimal totalPrice               { get; private set; } //SPO_UnitRetailPrice__c * TotalOpportunityQuantity
        public String  revisedDeliveryDate      { get; private set; }
        public String iconeToShow               
        { 
            get
            {
                String defualtValue = 'glyphicon glyphicon-time color-info';
                //if(theOrder != null)
                //{
                //    if(wonStageSet.contains(oneOrder.StageName))
                //    {
                //        defualtValue = 'glyphicon glyphicon-ok-sign color-success';
                //    }
                //    else if(lostStageSet.contains(oneOrder.StageName))
                //    {
                //        defualtValue = 'glyphicon glyphicon-remove-sign color-warning';
                //    }
                //}

                return defualtValue;
            } 
            private set; 
        }

        public Decimal quantity  { 
            get {
                if(quantity == null) {
                    quantity = 0;
                }
                return quantity;
            } 
            set; 
        }
    
        private Decimal unitPrice {
            get {
                if(null == unitPrice) {
                    unitPrice = 0;
                }
                return unitPrice;
            }
            set;
        }
        /*
        public OrderViewLine(SPO_FirmOrder__c order) {
            //theOrder = order;
            this.quantity = order.SPO_BriefName__r.SPO_SkuQuantity__c;
            this.unitPrice = order.SPO_BriefName__r.SPO_UnitRetailPrice__c;
            this.totalPrice = this.quantity * this.unitPrice;
            if(null != order.SPO_RevisedDeliveryDate__c) {
                this.revisedDeliveryDate = order.SPO_RevisedDeliveryDate__c.format(); 
            }
        }*/

        public OrderViewLine(Opportunity order) {
            this.theOrder = order;
            this.quantity = order.SPO_SkuQuantity__c;
            this.unitPrice = order.SPO_UnitRetailPrice__c;
            this.totalPrice = this.quantity * this.unitPrice;
            if(null != order.CreatedDate) {
                this.revisedDeliveryDate = order.CreatedDate.date().format(); 
            }
        }
    }

    private User getUser(){
        return [
            SELECT Id,
                   MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL3__c,
                   DefaultStore__c, Country ,Country__c 
              FROM User
             WHERE Id =:UserInfo.getUserId()];
    }
     
}