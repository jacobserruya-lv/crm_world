public class SO_Search_CTRL extends SO_BaseController { 

	public SO_Search_CTRL() 
	{
		init();
		this.theSession = SO_Session.retSessionStateForOpp(this.filterUser);
		if(null != this.theSession.globalSearchData) {

			assignDataFromSession();
		}
		else { 
			this.theSession.globalSearchData = new  SO_UTIL.GlobalSearchData();
		}
	}
	//--------------------------- Public fields --------------
	public static List<String> headerList 
	{
		get
		{ 
			return new List<String> 
			{
				Label.LV_SO_Creation_Date,
				Label.LV_SO_Client_name,
				Label.LV_SO_Name,
				Schema.SobjectType.Opportunity.Fields.SPO_BriefCode__c.Label,
				Label.LV_SO_order_type,
				Schema.SobjectType.Opportunity.Fields.SPO_StoreCode__c.Label,
				Label.LV_SO_Store,
				Schema.SobjectType.Opportunity.Fields.SPO_SpecialOrderSKUCode__c.Label,
				Schema.SobjectType.Opportunity.Fields.SPO_UnitRetailPriceQuotation__c.Label,
				Schema.SobjectType.Opportunity.Fields.SPO_Exo__c.Label,
				Schema.SobjectType.Opportunity.Fields.StageName.Label,
				Label.LV_SO_Action
			};
		}
		private set;
	}


	public List<SO_Table_Wrapper> opportunityResultWrapperList {get; private set;}
	
	public Boolean isAsnieresUser {
		get{return SO_UTIL.isAsnieresUser();}
	}

	public String asnieresSearchStore {
		get; set;
	}
	
	private static final Integer GLOBAL_SEARCH_LIMIT = 2000;

	private static final Map<String, String> fieldNameToLinkFormat = new Map<String, String> 
	{
		'CreatedDate'						=> '',
		'Account.Name' 						=> 'SO_viewclient?id=',
		'Name' 								=> '',
		'SPO_BriefCode__c' 					=> '',
		'SPO_OrderType__c'					=> '',
		'SPO_StoreCode__c' 					=> '',
		'SPO_Store__r.Name'					=> '',
		'SPO_SpecialOrderSKUCode__c'		=> '',
		'SPO_UnitRetailPrice__c'			=> '',
		'SPO_UnitRetailPriceQuotation__c' 	=> '',
		'SPO_Exo__c'                    	=> '',
		'StageName'							=> ''
	};

	private static final Map<String, String> fieldNameToFieldIdName = new Map<String, String> 
	{
		'Account.Name'		=> 'AccountId',
		'SPO_Store__r.Name' => 'SPO_Store__c'
	};

	public static List<String> apiDisplayFieldNames 
	{
		get
		{ 
			return new List<String> 
			{	
				'CreatedDate',
				'Account.Name',
				'Name',
				'SPO_BriefCode__c',
				'SPO_OrderType__c',
				'SPO_StoreCode__c',
				'SPO_Store__r.Name',
				'SPO_SpecialOrderSKUCode__c',
				'SPO_UnitRetailPrice__c',
				'SPO_UnitRetailPriceQuotation__c',
				'SPO_Exo__c',
				'StageName'		
		 	};
		}
		private set;
	}

	public static List<String> apiFieldNames 
	{
		get
		{ 
			return new List<String> 
			{
				'Name',
				'AccountId',
				'SPO_Store__c',
				'SPO_Store__r.Name',
				'Account.Name',
				'SPO_ProductCategory__c',
				'SPO_OrderType__c',
				'LastModifiedDate',
				'StageName',
				'CreatedDate',
				'SPO_StoreCode__c',
				'SPO_SpecialOrderSKUCode__c',
				'SPO_UnitRetailPrice__c',
				'SPO_UnitRetailPriceQuotation__c',
				'SPO_BriefCode__c',
				'SPO_Exo__c'
			};
		}
		private set;
	}

	public SO_UTIL.PickListWrapper briefStatus	 
	{ 

		get {
			if(null == briefStatus) 
			{
				briefStatus = new SO_UTIL.PickListWrapper('Opportunity', 'StageName', null, null);
				List<SelectOption> options = briefStatus.pickListValues;
				for ( Integer i = options.size() - 1; i >= 0; --i )
				{
					SelectOption so = options[i];
					if(so.getValue() == 'Closed Won')
					{
						options.remove( i );
						break;
					} 
				}
			}
			return briefStatus;
		} 
		set; 
	}

	public Opportunity 		filterOpportunity 	{get; set;}
	public List<String>     filterStatus        {get; set;}
	public User 			filterUser 			{get; set;}
	public String 			createdDateFrom 	{get; set;}
	public String 			createdDateTo 		{get; set;}
	public String 			statusDateFrom 		{get; set;}
	public String 			statusDateTo 		{get; set;}
	public String 		   opportunityBriefCode {get; set;}
	public Boolean 			isSearch 			{get; private set;}

	public SO_Search_CTRL contr {get {return this;}}

	private SO_OrderPageSwitch 		orderPageSwitch;
	public 	SO_Session.SessionState theSession { get; set; }
    public String dateFormat {get;set;}



	public override void init()
	{
		try
		{
			this.isSearch = false;
			this.opportunityResultWrapperList 	= new List<SO_Table_Wrapper>();
			this.filterOpportunity 				= new Opportunity(Account = new Account());
			this.filterStatus 					= new List<String>();
			initStringDateFields();

			this.orderPageSwitch 				= new SO_OrderPageSwitch();

			this.filterUser = getUser();
            this.dateFormat = System.today().format();
            system.debug('dateformat: ' + this.dateFormat);
		}
		catch(Exception e)
		{
			SO_UTIL.addErrorMessage(e);
		}
	}

	private void clearSession() {
		this.theSession = new SO_Session.SessionState();
		this.theSession.globalSearchData = new  SO_UTIL.GlobalSearchData();
	}

	private void saveUserSession() {

		User toSaveUser = new User(Id = this.filterUser.Id);
		SO_Session.saveSession(toSaveUser, this.theSession, true);
	}
	/*
	public void firstSearchOrder() {
		if()
		searchOrder()
	}*/

	//public methods:
	public void searchOrder() 
	{
		System.debug('SO_Search_CTRL - searchOrder:');
		this.isSearch = true;
		try
		{
			this.opportunityResultWrapperList.clear();
			List<String> fieldsInQuery = buildQuery();
			System.debug ('fieldsInQuery = '+ fieldsInQuery);

			Date createdDateFromForQuery, createdDateToForQuery, statusDateFromForQuery, statusDateToForQuery;

			if(SO_UTIL.isNotEmpty(filterStatus)
				&& (SO_UTIL.dateStringIsValid(this.statusDateFrom) || SO_UTIL.dateStringIsValid(this.statusDateTo)))
			{
				String statusQuery = ' (Id IN (SELECT OpportunityId FROM OpportunityHistory WHERE StageName IN ( \'' + String.join(filterStatus, '\', \'') + '\' ) ';
				
				if(SO_UTIL.dateStringIsValid(this.statusDateFrom) && !SO_UTIL.dateStringIsValid(this.statusDateTo))
				{	
					statusDateFromForQuery = SO_UTIL.transformDateStringToDateFormat(this.statusDateFrom);
					statusQuery += ' AND DAY_ONLY(CreatedDate) >= :statusDateFromForQuery ';
				}
				else if(SO_UTIL.dateStringIsValid(this.statusDateTo) && !SO_UTIL.dateStringIsValid(this.statusDateFrom))
				{	
					statusDateToForQuery = SO_UTIL.transformDateStringToDateFormat(this.statusDateTo);
					statusQuery += ' AND DAY_ONLY(CreatedDate) <= :statusDateToForQuery ';
				}
				else
				{
					statusDateFromForQuery = SO_UTIL.transformDateStringToDateFormat(this.statusDateFrom);
					statusDateToForQuery = SO_UTIL.transformDateStringToDateFormat(this.statusDateTo);
					statusQuery += ' AND DAY_ONLY(CreatedDate) >= :statusDateFromForQuery AND DAY_ONLY(CreatedDate) <= :statusDateToForQuery ';
				}

				statusQuery += ')) ';
				fieldsInQuery.add(statusQuery);
			}
				
			if((SO_UTIL.dateStringIsValid(this.createdDateFrom) || SO_UTIL.dateStringIsValid(this.createdDateTo)))
			{
				if(SO_UTIL.dateStringIsValid(this.createdDateFrom) && !SO_UTIL.dateStringIsValid(this.createdDateTo))
				{	
					createdDateFromForQuery = SO_UTIL.transformDateStringToDateFormat(this.createdDateFrom);
					fieldsInQuery.add(' DAY_ONLY(CreatedDate) >= :createdDateFromForQuery ');
                    system.debug('## MTOU from date before conversion:' + createdDateFromForQuery);
				}
				else if(SO_UTIL.dateStringIsValid(this.createdDateTo) && !SO_UTIL.dateStringIsValid(this.createdDateFrom))
				{	
					createdDateToForQuery = SO_UTIL.transformDateStringToDateFormat(this.createdDateTo);
					fieldsInQuery.add(' DAY_ONLY(CreatedDate) <= :createdDateToForQuery ');
                    system.debug('## MTOU to date before conversion:' + createdDateToForQuery);
				}
				else
				{
					createdDateFromForQuery = SO_UTIL.transformDateStringToDateFormat(this.createdDateFrom);
					createdDateToForQuery = SO_UTIL.transformDateStringToDateFormat(this.createdDateTo);
					fieldsInQuery.add(' DAY_ONLY(CreatedDate) >= :createdDateFromForQuery AND DAY_ONLY(CreatedDate) <= :createdDateToForQuery ');
                    system.debug('## MTOU to and from date before conversion: ' + createdDateToForQuery + ' ' + createdDateFromForQuery);
				}
			}

			if(SO_OrderPageSwitch.LogicalUserRoleEnum.Production == this.orderPageSwitch.sfoUserRole 
				|| SO_OrderPageSwitch.LogicalUserRoleEnum.Other == this.orderPageSwitch.sfoUserRole)
			{
				Map<ID, Set<String>> permissionMap = SO_OrderPageSwitch.permissionByUserMap;
				Set<String> permissionForCurrUser = permissionMap.get(UserInfo.getUserId());
				if(permissionForCurrUser != null)
				{
					fieldsInQuery.add(' SPO_ProductCategory__c IN :permissionForCurrUser ');
				}
			}

			System.debug('SO_Search_CTRL - searchOrder - fieldsInQuery: ' + fieldsInQuery);
			if(!fieldsInQuery.isEmpty())
			{
				String queryString = 'SELECT ' + String.join(apiFieldNames, ',') 
							+ ' FROM Opportunity WHERE ' + String.join(fieldsInQuery, ' AND ') + ' LIMIT ' + GLOBAL_SEARCH_LIMIT;
				System.debug('SO_Search_CTRL - searchOrder - queryString: ' + queryString);

				List<sObject> sobjectsList = Database.query(queryString);
				System.debug('SO_Search_CTRL - searchOrder - sobjectsList:' + sobjectsList);

				Map<ID, String> targetPageMap = orderPageSwitch.buildTargetPageMap((List<Opportunity>)sobjectsList);
				
				for (Opportunity opp : (List<Opportunity>)sobjectsList)
				{
					this.opportunityResultWrapperList.add(new SO_Table_Wrapper(opp, fieldNameToLinkFormat, fieldNameToFieldIdName, targetPageMap.get(opp.Id)));
				}
			}

			setGlobalSearchData();
			saveUserSession();		
		}
		catch(Exception e)
		{
			this.theSession = SO_Session.retSessionStateForOpp(this.filterUser);
			SO_UTIL.addErrorMessage(e);
		}
	}

	public void clearFilterFields()
	{
		init();
		clearSession();
		saveUserSession();
	}

	private void initStringDateFields()
	{
		this.createdDateFrom 	= null;
		this.createdDateTo 		= null;
		this.statusDateTo 		= null;
		this.statusDateFrom 	= null;
	}

	private static String buildConditionPart(String fieldName, String filedValue) {

		String conditionPart; 
		if(filedValue.endsWith('*')) {
			
			String value = filedValue.removeEnd('*') + '%';
			conditionPart = String.format(' {0} LIKE {1} ', new String[] { fieldName, SO_UTIL.addApostrophe(value) }); 
		}
		else {
			conditionPart = String.format(' {0} = {1} ', new String[] { fieldName, SO_UTIL.addApostrophe(filedValue) }); 	
		}

		System.debug('conditionPart >> ' + conditionPart);

		return conditionPart;

	}

	private List<String> buildQuery()
	{
		//String query = 'SELECT ' + String.join(apiFieldNames, ',') 
		//						+ ' FROM Opportunity ';

		List<String> fieldsInQuery = new List<String>();
		
		// Check Opportunity name
		if(String.isNotBlank(filterOpportunity.Name))
		{
			//fieldsInQuery.add(' Name LIKE \'' + filterOpportunity.Name + '%\' ');
			fieldsInQuery.add(buildConditionPart('Name', filterOpportunity.Name));
		}
		
		// Check SPO_ProductCategory__c
		if(String.isNotBlank(filterOpportunity.SPO_ProductCategory__c))
		{	
			fieldsInQuery.add(' SPO_ProductCategory__c = \'' + filterOpportunity.SPO_ProductCategory__c + '\' ');
		}

		if(SO_UTIL.isNotEmpty(filterStatus)){
			fieldsInQuery.add(' StageName IN ( \'' + String.join(filterStatus, '\', \'') + '\' ) ');
		}

		// Check SPO_OrderType__c
		if(String.isNotBlank(filterOpportunity.SPO_OrderType__c))
		{	
			fieldsInQuery.add(' SPO_OrderType__c = \'' + filterOpportunity.SPO_OrderType__c + '\' ');
		}

		if(String.isNotBlank(this.opportunityBriefCode))
		{	
			//fieldsInQuery.add(' SPO_BriefCode__c LIKE \'' + filterOpportunity.SPO_BriefCode__c + '%\' ');
			fieldsInQuery.add(buildConditionPart('SPO_BriefCode__c', this.opportunityBriefCode));
		}

		if(String.isNotBlank(filterOpportunity.SPO_CACode__c))
		{	
			fieldsInQuery.add(' SPO_CACode__c = \'' + filterOpportunity.SPO_CACode__c + '\' ');
		}

		if(String.isNotBlank(filterOpportunity.SPO_Exo__c))
		{	
			fieldsInQuery.add(' SPO_Exo__c = \'' + filterOpportunity.SPO_Exo__c + '\' ');
		}

		if(String.isNotBlank(filterOpportunity.SPO_SpecialOrderSKUCode__c))
		{	
			fieldsInQuery.add(buildConditionPart('SPO_SpecialOrderSKUCode__c', filterOpportunity.SPO_SpecialOrderSKUCode__c));
		}

		if(String.isNotBlank(filterOpportunity.SPO_ZoneApproval__c))
		{	
			fieldsInQuery.add(' SPO_ZoneApproval__c = \'' + filterOpportunity.SPO_ZoneApproval__c + '\' ');
		}

		if(String.isNotBlank(filterOpportunity.SPO_MarketingApproval__c))
		{	
			fieldsInQuery.add(' SPO_MarketingApproval__c = \'' + filterOpportunity.SPO_MarketingApproval__c + '\' ');
			fieldsInQuery.add(' SPO_DisplayOrder__c = true ');
		}

		if(String.isNotBlank(filterOpportunity.SPO_CentralApproval__c))
		{	
			fieldsInQuery.add(' SPO_CentralApproval__c = \'' + filterOpportunity.SPO_CentralApproval__c + '\' ');
		}

		if(String.isNotBlank(filterUser.MANAGEMENT_ZONE_LEVEL__c))
		{	
			fieldsInQuery.add(' SPO_Store__r.MANAGEMENT_ZONE_LEVEL__c = \'' + filterUser.MANAGEMENT_ZONE_LEVEL__c + '\' ');
		}

		if(String.isNotBlank(filterUser.MGMT_ZONE_SUB_LEVEL1__c))
		{	
			fieldsInQuery.add(' SPO_Store__r.MGMT_ZONE_SUB_LEVEL1__c = \'' + filterUser.MGMT_ZONE_SUB_LEVEL1__c + '\' ');
		}

		if(String.isNotBlank(filterUser.MGMT_ZONE_SUB_LEVEL2__c))
		{	
			fieldsInQuery.add(' SPO_Store__r.MGMT_ZONE_SUB_LEVEL2__c = \'' + filterUser.MGMT_ZONE_SUB_LEVEL2__c + '\' ');
		}

		if(String.isNotBlank(filterUser.MGMT_ZONE_SUB_LEVEL3__c))
		{	
			fieldsInQuery.add(' SPO_Store__r.MGMT_ZONE_SUB_LEVEL3__c = \'' + filterUser.MGMT_ZONE_SUB_LEVEL3__c + '\' ');
		}

		if(String.isNotBlank(filterUser.DefaultStore__c) || String.isNotBlank(asnieresSearchStore))
		{	
			fieldsInQuery.add(' SPO_Store__r.RetailStoreId__c = \'' + (String.isNotBlank (asnieresSearchStore) ? asnieresSearchStore : filterUser.DefaultStore__c) + '\' ');
		}

		// Check Account // Check related Account
		if(filterOpportunity.Account != null)
		{
			if(String.isNotBlank(filterOpportunity.Account.FirstName))
			{                
				String conditionPart = ' (' + buildConditionPart('Account.FirstName', filterOpportunity.Account.FirstName)  + ') ';
				fieldsInQuery.add(conditionPart);
			}

			if(String.isNotBlank(filterOpportunity.Account.LastName))
			{ 
				String conditionPart = ' (' + buildConditionPart('Account.LastName', filterOpportunity.Account.LastName)  + ') ';
				fieldsInQuery.add(conditionPart);
			}		
		}

		//if(!fieldsInQuery.isEmpty())
		//{
		//	query += ' WHERE ' + String.join(fieldsInQuery, ' AND ');
		//}
		
		return fieldsInQuery;					
	}

	private void setGlobalSearchData() {

		this.theSession.globalSearchData.opportunityName 				= filterOpportunity.Name;
		this.theSession.globalSearchData.accountName 					= filterOpportunity.Account.FirstName;
		this.theSession.globalSearchData.accountGivenName 				= filterOpportunity.Account.LastName;
		this.theSession.globalSearchData.opportunityBriefCode 			= opportunityBriefCode;
		this.theSession.globalSearchData.opportunityProductCategory 	= filterOpportunity.SPO_ProductCategory__c;
		this.theSession.globalSearchData.opportunityOrderType 			= filterOpportunity.SPO_OrderType__c;
		this.theSession.globalSearchData.filterStatus 					= filterStatus;
		this.theSession.globalSearchData.createdDateFrom 				= createdDateFrom;
		this.theSession.globalSearchData.createdDateTo 					= createdDateTo;
		this.theSession.globalSearchData.opportunityCACode 				= filterOpportunity.SPO_CACode__c;
		this.theSession.globalSearchData.opportunityExo 				= filterOpportunity.SPO_Exo__c;
		this.theSession.globalSearchData.opportunitySpecialOrderSKUCode = filterOpportunity.SPO_SpecialOrderSKUCode__c;
		this.theSession.globalSearchData.statusDateFrom 				= statusDateFrom;
		this.theSession.globalSearchData.statusDateTo 					= statusDateTo;
		this.theSession.globalSearchData.opportunityZoneApproval 		= filterOpportunity.SPO_ZoneApproval__c;
		this.theSession.globalSearchData.opportunityMarketingApproval 	= filterOpportunity.SPO_MarketingApproval__c;	
		this.theSession.globalSearchData.opportunityCentralApproval 	= filterOpportunity.SPO_CentralApproval__c;
		this.theSession.globalSearchData.asnieresSearchStoreCode		= asnieresSearchStore;
	}

	private void assignDataFromSession() {

		filterOpportunity.Name						= this.theSession.globalSearchData.opportunityName;
		filterOpportunity.Account.FirstName			= this.theSession.globalSearchData.accountName;
		filterOpportunity.Account.LastName			= this.theSession.globalSearchData.accountGivenName;
		opportunityBriefCode						= this.theSession.globalSearchData.opportunityBriefCode;
		filterOpportunity.SPO_ProductCategory__c	= this.theSession.globalSearchData.opportunityProductCategory;
		filterOpportunity.SPO_OrderType__c			= this.theSession.globalSearchData.opportunityOrderType;
		filterStatus								= this.theSession.globalSearchData.filterStatus;
		createdDateFrom								= this.theSession.globalSearchData.createdDateFrom;
		createdDateTo								= this.theSession.globalSearchData.createdDateTo;
		filterOpportunity.SPO_CACode__c				= this.theSession.globalSearchData.opportunityCACode;
		filterOpportunity.SPO_Exo__c				= this.theSession.globalSearchData.opportunityExo;
		                                              
		filterOpportunity.SPO_SpecialOrderSKUCode__c= this.theSession.globalSearchData.opportunitySpecialOrderSKUCode;
		statusDateFrom								= this.theSession.globalSearchData.statusDateFrom;
		statusDateTo								= this.theSession.globalSearchData.statusDateTo;
		filterOpportunity.SPO_ZoneApproval__c		= this.theSession.globalSearchData.opportunityZoneApproval;
		filterOpportunity.SPO_MarketingApproval__c	= this.theSession.globalSearchData.opportunityMarketingApproval;
		filterOpportunity.SPO_CentralApproval__c	= this.theSession.globalSearchData.opportunityCentralApproval;
		asnieresSearchStore							= this.theSession.globalSearchData.asnieresSearchStoreCode;
		System.debug('assignDataFromSession - filterOpportunity: ' + filterOpportunity);

	}

	private User getUser()
	{
		return [SELECT MANAGEMENT_ZONE_LEVEL__c
					  ,MGMT_ZONE_SUB_LEVEL1__c
					  ,MGMT_ZONE_SUB_LEVEL2__c
					  ,MGMT_ZONE_SUB_LEVEL3__c
					  ,SPO_Session_State__c
					  ,DefaultStore__c
				FROM User
				WHERE Id =:UserInfo.getUserId()];
	}
}