/**
 * [SO__Utils]
 * Utility Class
 * 
 * @CreatedBy :      Unknown
addErrorMessage * 
 * Modification History =======
 * 06/07/2016 MTOU: adding a new method to display error message (addDMLMessage)
 * 13/07/2016 MTOU: modifying the "convertDate" method - fixing bug on date format (search used to return wrong results to users with a date format differeent from mm/dd/yyy)
 * 14/10/2016 RMOU: SPO Evols Lot 1
 */
public without sharing class SO_UTIL
{ 
	public static void log(String title, Exception e){
        System.debug('\n\n************************ ' + title + ' *******************\n\n' +
            'Exception: Message: ' + e.getMessage() + '\nStack Trace: ' + e.getStackTraceString() +
            '\n\n************************ END ************************\n\n');
    }

    public static Map<String, String> COUNTRY_CODE_BY_STORE_COUNTRY_MAP = new Map<String, String>
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

	//Custom settings
	public static final String PERSON_ACCOUNT_RECORD_TYPE_SETTINGS_NAME 			= 'PersonAccountRecordTypeName';
	public static final String NEW_OPPORTUNITY_STAGENAME_SETTINGS_NAME 				= 'NewOpportunityStage';
	public static final String NEW_OPPORTUNITY_CLODEDATE_SETTINGS_NAME 				= 'NewOpportunityCloseDate';
	public static final String PRODUCT_NOT_FOUND_SKU_SETTINGS_NAME					= 'ProductNotFoundSKU';
	public static final String LANGUAGE_CODES_BY_LABEL 								= 'LanguageCodesByLabel';
	public static final String LANGUAGES_LABEL_NAMES 								= 'LanguagesLabelNames';
	public static final String PRODUCTS_REFERENTIAL_SUB_FAMILIES 					= 'ProductsReferentialSubFamilies';
	public static final String PRODUCTS_REFERENTIAL_LINING_MATERIAL_DEFAULT_VALUE 	= 'ProductsRefLiningMaterialDefaultValue';

	//Opportunity StageName List
	public static final String QUOTATION_SUBMITTED 		= 'Quotation submitted';
	public static final String CANCELLED_BY_PRODUCTION 	= 'Cancelled by production'; 

	public static final String WSLV;
	public static final String WSENDPOINT;
	static {
		if(Test.isRunningTest())
		{
			WSLV = 'zlvctest';
			WSENDPOINT = 'salesforce-testsss';
		}
		else
		{
			WSLV = SO_Settings__c.getValues('WSLV').Value__c;
			WSENDPOINT = SO_Settings__c.getValues('WSENDPOINT').Value__c;
		}
		
	}
	/**
	 * @description				a method that returns the option list from database values of a specified picklist
	 * @param  fieldResult			[The metadata description of picklist]
	 * @return						List of SelectOptions contain label/value of all picklist items
	 */
	public static SelectOption[] getOptionsFormPicklist(Schema.DescribeFieldResult fieldResult){ 
    
		List<SelectOption> options = new List<SelectOption>();
 
		for( Schema.PicklistEntry pe : fieldResult.getPicklistValues() )
			options.add(new SelectOption(pe.getValue(), pe.getLabel()));
 
		return options;
	}


	/**
	 * @description				Returns record type by name
	 * @return					record type object
	 */
	public static RecordType retRecordType(String recordTypeName){
		return [SELECT Id, Name 
							FROM RecordType 
							WHERE Name =: recordTypeName
							LIMIT 1];
	}


	public static Id retRecordTypeIdByName(String sObjectType, String recordTypeName)
	{
		Id recordTypeId = null;
		try
		{
			recordTypeId = Schema.getGlobalDescribe().get(sObjectType).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		}
		catch(Exception e)
		{
			SO_UTIL.exceptionDump(e);
			recordTypeId = null;
		}

		return recordTypeId;
	}



	public static String generateRandomString(Integer len){
		final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
		String randStr = '';
		while (randStr.length() < len){
			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
			randStr += chars.substring(idx, idx+1);
		}
		return randStr; 
	}



	/**
	 * @description					a method that returns the type of object as string
	 * @param  o					[Object to detect his type]
	 * @return						String name of the object
	 */
	public static string getObjectType(Object o){
		if(o == null) return '';              // we can't say much about null with our current techniques
		if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+''; 
		if(o instanceof Boolean)            return 'Boolean';
		if(o instanceof Id)                 return 'Id';
		if(o instanceof String)             return 'String';
		if(o instanceof Blob)               return 'Blob';
		if(o instanceof Date)               return 'Date';
		if(o instanceof Datetime)           return 'Datetime';
		if(o instanceof Time)               return 'Time';
		if(o instanceof String)             return 'String';
		if(o instanceof Integer)            return 'Integer';
		if(o instanceof Long)               return 'Long';
		if(o instanceof Decimal)            return 'Decimal';  // we can't distinguish between decimal and double
		if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
		if(o instanceof List<object>)       return 'List';
		return 'Object';                    // actually we can't detect maps and sets and maps
	}



	 /**
    * @description		  Selects all fields from sObject
    * @param  objectName  [The name of SObject]
    * @param  fieldPrefix [prepends each field name with this prefix]
    * @param  query       [the query suffix]
    * @param  filters     [list of strings, only fields that contain those strings will be included in the resulting query]
    * @return             [description]
    */
	public static List<SObject> selectAllQuery (String objectName,  String query, String fieldPrefix, String[] filters) 
	{
		String q = 'SELECT ' + String.join(getSObjectFields(objectName, fieldPrefix, filters), ',');
          
        q += query;

        try{
            //System.debug(q);
            List<SObject> out = database.query(q);
            return out;
        } 
        catch (QueryException e){
            return new List<SObject>();
        }        
	}



    /**
     * @description		  get fields list of sObject
     * @param  objectName  [The name of SObject]
     * @param  fieldPrefix  [prepends each field name with this prefix]
     * @param  filters     [list of strings, only fields that contain those strings will be included in the resulting query]
     * @return              [description]
     */
    public static List<String> getSObjectFields (String objectName, String fieldPrefix, String[] filters){
         Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe()
            .get(objectName)
            .getDescribe()
            .fields.getMap(); 
        fieldPrefix = fieldPrefix == null ? '' : fieldPrefix;
        List<String> l = new List<String>();
        for(String s : objectFields.keySet()){
            if (ifContains(filters, s)){
                l.add(fieldPrefix + s);
			}
        }
        return l;
    }



    /**
     * @description		  [Returns true if string contains one of substrings from the input array]
     * @param  stringArray  [description]
     * @param  str          [description]
     * @return              [description]
     */
    public static Boolean ifContains(List<String> stringArray, String str){ 
        if (stringArray == null || String.isBlank(str)) return true;
        str = str.toLowerCase();
        Boolean exists = false;
        for(String s : stringArray){
            //System.debug('EE=' + str + ',' + s.toLowerCase());
             if (str.indexOf(s.toLowerCase()) >= 0){
				return true;
			 }
			 
        }
        //System.debug(exists);
        return false;
    }



	/**
	 * @description					Outputs message as error in VF page
	 * @param message				[The message to output]
	 */
	public static void sendApexErrorMessage(String message){
		ApexPages.Message apexMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
		ApexPages.addMessage(apexMsg);
	}
	/**
	 * @description
	 * @param message [description]
	 */
	public static void sendApexErrorMessage(String message, Exception exp){
		exceptionDump(exp);
		sendApexErrorMessage(message);
	}

	/**
	 * @description					Outputs message as information in VF page
	 * @param message				[The message to output]
	 */
	public static void sendApexInfoMessage(String message){ 
		ApexPages.Message apexMsg = new ApexPages.Message(ApexPages.Severity.INFO, message);
		ApexPages.addMessage(apexMsg);
	}

	/**
	 * @description					Creates or updates person account / portal user
	 * @param account				Account new or old to create or update
	 */
	/* 
	public static Object createOrUpdateClient(Account account){
		
		if (account.Id != null){

			//Update account
			try{
				update account;
			}
			catch(Exception ex){
				sendApexErrorMessage('Account update error: ' + ex.getMessage(),exp);
				return 'Account update error.';	
			}

			return account;

		}

		//Create account
		String rtName = SO_Settings__c.getValues(PERSON_ACCOUNT_RECORD_TYPE_SETTINGS_NAME).Value__c;
		account.RecordTypeId = retRecordType(rtName).Id;

		try{
			insert account;
		}
		catch(Exception ex){
			sendApexErrorMessage('Account create error: ' + ex.getMessage(),exp);
			return 'Account create error.';	
		}

		//Return account object
		return account;
	}*/

	/*public static Object createOrUpdateClient(Account account){
		
		try {
			//Create account
			if(null == account.Id) {
				String rtName = SO_Settings__c.getValues(PERSON_ACCOUNT_RECORD_TYPE_SETTINGS_NAME).Value__c;
				account.RecordTypeId = retRecordType(rtName).Id;
			}

			upsert account;
		}
		catch(Exception exp){
			sendApexErrorMessage('Account create error: ' + exp.getMessage(),exp);
			return 'Account create or update error.';	
		}

		return account;
	}*/

	/**
	 * @description					Returns client by Id
	 */
	/*public static Account retClient(Id clientId){

		Account clientToRetrive = new Account();

		if(clientId != null)  
		{
			String clientFields = String.join(getSObjectFields('Account', null, null), ',');
			
			String query = 'SELECT ' + clientFields
							+ ' FROM Account '
							+ ' WHERE Id = \'' + clientId + '\'';
			

			List<Account> clientList = Database.query(query);

			clientToRetrive = clientList.isEmpty() ? clientToRetrive : clientList[0];
		}
		
		return clientToRetrive;
	}

*/
	/**
	 * @description					Returns Opportunity by Id
	 */
	public static Opportunity retOpportunity(Id opportunityId){

		Opportunity opportunityToRetrive = new Opportunity();

		if(opportunityId != null)  
		{
			String opportunityFields = String.join(getSObjectFields('Opportunity', null, null), ',');
			
			String query = 'SELECT ' + opportunityFields
							+ ' FROM Opportunity '
							+ ' WHERE Id = \'' + opportunityId + '\'';
			
			System.debug('SO_UTIL - retOpportunity - query: ' + query);
			List<Opportunity> opportunityList = Database.query(query);
			System.debug('SO_UTIL - retOpportunity - opportunityList: ' + opportunityList);
			

			opportunityToRetrive = opportunityList.isEmpty() ? opportunityToRetrive : opportunityList[0];
		}
		
		return opportunityToRetrive;
	}

	public static ProductReferential__c retProductReferential(Id PRId){

		ProductReferential__c PRToRetrive = new ProductReferential__c();

		if(PRId != null)  
		{
			String PRFields = String.join(getSObjectFields('ProductReferential__c', null, null), ',');
			
			String query = 'SELECT ' + PRFields
							+ ' FROM ProductReferential__c '
							+ ' WHERE Id = \'' + PRId + '\'';
			
			System.debug('SO_UTIL - retProductReferential - query: ' + query);
			List<ProductReferential__c> PRList = Database.query(query);
			System.debug('SO_UTIL - retProductReferential - PRList: ' + PRList);
			
			PRToRetrive = PRList.isEmpty() ? PRToRetrive : PRList[0];
		}
		
		return PRToRetrive;
	}
	/**
	 * AEF:
	 */
	public static Boolean isEmpty(List<Object> objectList) {
   		return null == objectList || objectList.isEmpty();
    }

	public static Boolean isNotEmpty(List<Object> objectList) {
			return null != objectList && !objectList.isEmpty();
	}

	public static void addErrorMessage(Exception exp) {
		exceptionDump(exp);
		ApexPages.Message apexMsg = new ApexPages.Message(ApexPages.Severity.ERROR, exp.getMessage());
		ApexPages.addMessage(apexMsg);

	}
	
	public static void addErrorMessage(String expMessage) {
		ApexPages.Message apexMsg = new ApexPages.Message(ApexPages.Severity.ERROR, expMessage);
		ApexPages.addMessage(apexMsg);
	}
    
    public static void addDMLMessage (Exception exp)
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, exp.getdmlMessage(0) ); 
        ApexPages.addMessage(msg);
    }

	public static String exceptionDump(Exception exp) {
        String msg = ':::SPO:::\n'+exceptionTrace(exp);
        system.debug(system.LoggingLevel.ERROR, msg);
        return msg;
    } 

    public static String exceptionDump(String msg) {
        system.debug(system.LoggingLevel.ERROR, ':::SPO:::\n' + msg);
        return msg;
    } 

	public static String exceptionTrace(Exception exp) {
        return exp.getStackTraceString() + ' ' + exp.getMessage() + ' ' + exp.getTypeName();
   	}

   	public static list<SelectOption> getPicklistValues(String objName, String fldName) {

		list<SelectOption> optionList = new list<SelectOption>();
		
		Schema.sObjectType objType 				  =  Schema.getGlobalDescribe().get(objName); 
		Schema.DescribeSObjectResult objDescribe  = objType.getDescribe();   
		Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
		List<Schema.PicklistEntry> pickListValues = fieldMap.get(fldName).getDescribe().getPickListValues();
	
		for(Integer X = 0; X < pickListValues.size(); X++){

			Schema.PicklistEntry plValue = pickListValues[X];
			optionList.add(new SelectOption(plValue.getValue(), plValue.getLabel()));
		}

		return optionList;
	}

	public static String addApostrophe(String value) {
		if(String.isNotBlank(value)) {
			return '\'' + value + '\'';
		}
		return null;
	}

	public static Map<String, RecordType> retRecordTypeByDevMap(Set<String> recTypeNameSet) {

		List<RecordType> recordTypeList = 
						[SELECT Id, Name, DeveloperName 
						   FROM RecordType 
						  WHERE DeveloperName IN : recTypeNameSet 
						     //OR Name IN: recTypeNameSet
						];

		Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
		for(RecordType oneRecordType : recordTypeList) {

			recordTypeMap.put(oneRecordType.DeveloperName, oneRecordType);
		}

		return recordTypeMap;
	}

	//Classes
	public class PickListWrapper {

		private sObject 	  target 		 { get; set; }
		private String 		  fieldName		 { get; set; }

		public SelectOption[] pickListValues { get; set; }
		public String 		  selectedValue	 { 
			get;
			set {
				selectedValue = value;
				if(null != target) {
					target.put(fieldName, value);
				} 
			} 
		} 

		public PickListWrapper(String objName, String fldName) {
			this(objName, fldName, null, null);
		}

		public PickListWrapper(String objName, String fldName, String emptyOption, sObject target) {

			this.fieldName = fldName;
			this.target = target;

			if(null != target) {
				selectedValue = String.valueOf(target.get(fldName));
			}

			pickListValues = new List<SelectOption>();
			if(null != emptyOption) {
				pickListValues.add(new SelectOption('', emptyOption));
			}
			pickListValues = getPicklistValues(objName, fldName);
		}

	}

	public virtual class ApplicationException extends Exception {
		
	}

	public class RMSException extends ApplicationException {
		
	}

	public class SearchClientData {

		public String firstName			{ set; get; } // Start with if * is used at the end of the string
		public String lastName 			{ set; get; } // Start with if * is used at the end of the string
		public String givenName 		{ set; get; } // Start with if * is used at the end of the string
		public String email 			{ set; get; } // Start with if * is used at the end of the string
		public String phoneNumber 		{ set; get; } // Search in all phone numbers. Start with and end with are supported
		public String passportNumber	{ set; get; } // Exact match only. * is not supported 
		public String country           { set; get; }
		public String zipCode 			{ set; get; } // Always Start with. * is not supported
		public String dreamId 			{ set; get; } // Exact match only. * is not supported
		public String storeCode 		{ set; get; } // Mandatory. Exact match only.
		
		// ISO Code on 3 characters. Exact match only. * is not supported
		/*
        public SO_UTIL.PickListWrapper country { 
            
            get {
                if(null == country) {
            		country = new SO_UTIL.PickListWrapper('Account', 'BillingCountry', null, null);
                }
                return country;
            }
            set;
        }*/
		//Address a;	
	}

	public class SearchProductData {

		public String orderType 		{ set; get; } 
		public String nameOrSKU			{ set; get; } 
		public String productCategory 	{ set; get; } 

	}

	public class GlobalSearchData {

		public String accountName 					{ set; get; }
		public String statusDateTo 					{ set; get; }
		public String createdDateTo 				{ set; get; }
		public String opportunityExo 				{ set; get; }
		public String statusDateFrom 				{ set; get; }
		public String opportunityName 				{ set; get; }
		public String createdDateFrom 				{ set; get; }
		public String accountGivenName 				{ set; get; }
		public String opportunityCACode 			{ set; get; }
		public String opportunityOrderType 			{ set; get; }
		public String opportunityBriefCode 			{ set; get; }
		public String opportunityZoneApproval 		{ set; get; }
		public String opportunityProductCategory 	{ set; get; }
		public String opportunityCentralApproval 	{ set; get; }
		public String opportunityMarketingApproval 	{ set; get; }
		public String opportunitySpecialOrderSKUCode { set; get; }
		public List<String> filterStatus 			{ set; get; }
		public String asnieresSearchStoreCode		{ set; get; }

	}

	public static Boolean dateStringIsValid(String dateString)
	{
		return String.isNotBlank(dateString) 
					&& dateString.trim() != 'AM' 
					&& dateString.trim() != 'PM';
	}

	public static Date transformDateStringToDateFormat(String dateTimeString)
	{
		/* Split Date String MM/DD/YYYY to integers
		String[] str = dateTimeString.split(' ');
		String[] dts = str[0].split('/');
		System.debug('transformDateStringToDateFormat - dts: ' + dts);
		Date newDate = Date.newInstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
		return newDate;
		*/
		return convertDate(dateTimeString);
	}

	public static DateTime transformDateStringToDateTimeFormat(String dateTimeString)
	{
		/* Split Date String MM/DD/YYYY to integers
		String[] str = dateTimeString.split(' ');
		String[] dts = str[0].split('/');
		System.debug('transformDateStringToDateTimeFormat - dts: ' + dts);
		DateTime newDateTime = DateTime.newInstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
		return newDateTime;
		*/
		return convertDateTime(dateTimeString);


	}

	public static DateTime convertDateTime(String dateString) {

		DateTime dt;
		try {
			if(String.isNotBlank(dateString)) {
				dt = DateTime.parse(dateString);
				return dt;
			}
			else {
				return null;
			}
		}
		catch(Exception exp) {
			String msg = exceptionTrace(exp);
			msg += 'Source string ' + dateString + ' >> ' + msg;
			system.debug(system.LoggingLevel.ERROR, msg);
			return null;
		}

	}

	public static Date convertDate(String dateString) {

		Date dt;
        DateTime dtt;
		try {
			if(String.isNotBlank(dateString)) {
				try {
                    // Begin MTO: fixing date format
                    // received date from javascript is in format mm/dd/yyyy 01:00 AM => remove de time part et retrieve the year, month and day
                    string[] dateStringElt = dateString.split(' ', 2)[0].split('/', 3);
                    dt = Date.newInstance(Integer.valueof(dateStringElt[2]), Integer.valueof(dateStringElt[0]), Integer.valueof(dateStringElt[1]));
					//dt = DateTime.parse(dateString).date();
					// end MTO
					return dt;
				}
				catch(Exception ee) {
					dt = Date.parse(dateString);
					return dt;

				}
			}
			else {
				return null;
			}
			
		}
		catch(Exception exp) {
			String msg = exceptionTrace(exp);
			msg += 'Source string ' + dateString + ' >> ' + msg;
			system.debug(system.LoggingLevel.ERROR, msg);
			return null;
		}
	}

	public static Boolean isAsnieresUser (){
		return getGroupsForUser (Id.valueOf(UserInfo.getUserId())).contains (getAsnieresGroup());
	}

	public static Group getAsnieresGroup (){
		List<Group> groups = [SELECT id, Name, DeveloperName FROM Group WHERE DeveloperName = 'SPO_Asnieres'];
		return groups.isEmpty() ? null : groups.get(0);
	}
    
    //Add BY MAUB
    public static Boolean isZoneApprovalUser (){
        Boolean result = false;
        
        for (Group g : getZoneApprovalGroup ()){
           result = result || getGroupsForUser (Id.valueOf(UserInfo.getUserId())).contains(g);
        }
        
        return result;
		 
	}

    
    public static List<Group> getZoneApprovalGroup (){
        List<Group> groups = [SELECT id, Name, DeveloperName FROM Group WHERE DeveloperName = 'SPO_EuropeApprovalLG'
                              											   	OR DeveloperName = 'SPO_EuropeApprovalWatch'
                             											   	OR DeveloperName = 'SPO_NorthAsiaApprovalLG'
                             											   	OR DeveloperName = 'SPO_NorthAsiaApprovalWatch'	
                             												OR DeveloperName = 'SPO_SouthAsiaApprovalLG'
                             												OR DeveloperName = 'SPO_SouthAsiaApprovalWatch'];
		return groups;
    }
    
    public static Boolean isCRUDSectionPricesOpportunitiesUser (){
		return getGroupsForUser (Id.valueOf(UserInfo.getUserId())).contains (getCRUDSectionPricesOpportunitiesGroup());
	}

    
    public static Group getCRUDSectionPricesOpportunitiesGroup (){
		List<Group> groups = [SELECT id, Name, DeveloperName FROM Group WHERE DeveloperName = 'SPO_CRUD_Section_Prices_Opportunities'];
		return groups.isEmpty() ? null : groups.get(0);
	}
    
 //ADD BY MAUB
	// return list of all groups the user belongs to via direct or indirect membership
	public static Set<Group> getGroupsForUser(Id userId){

	    Set<Id> groupIds = getGroupsForIds(new Set<Id>{userId});
	 	return new Set<Group> ([
						   select Id
						        , Name
						        , DeveloperName
						     from Group
						    where Id IN: groupIds]);

	}

	// return all ids the user belongs to via direct or indirect membership
	public static Set<Id> getGroupsForIds(Set<Id> userOrGroupIds){

	    Set<Id> output = new Set<Id>();

	    Set<Id> nestedGroupIds = new Set<Id>();

	    // only query actual groups and not roles and queues
	    list<GroupMember> records = [
	        select id
	             , GroupId
	             , UserOrGroupId
	          from GroupMember
	         where UserOrGroupId =: userOrGroupIds
	           and UserOrGroupId != null
	           and Group.Type = 'Regular'];

	    for (GroupMember record:records)
	    {
	        // found a group, remember for traversal
	        if (!(record.UserOrGroupId + '').startsWith('005'))
	        {
	            nestedGroupIds.add(record.UserOrGroupId);   
	        }
	        else
	        {
	            output.add(record.GroupId);
	        }
	    }

	    // call self to get nested groups we found
	    if (nestedGroupIds.size() > 0)
	    {
	        output.addAll(getGroupsForIds(nestedGroupIds));
	    }

	    return output;
	}
}