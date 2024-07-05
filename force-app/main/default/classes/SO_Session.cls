/*
	AEF:	class Session
 */
public with sharing class SO_Session {

	public Enum OrderMode { PRODUCT, CLIENT }

	public static String PARTITION_NAME = 'local.SPOPartition';
	public static String ACCOUNT_FROM_RMS_CACHE_KEY = 'selectedRMSAccount';

	private static Cache.SessionPartition SESSION_PARTITION_SPO;

	public static Cache.SessionPartition sessionPartition
	{
		get
		{
			if(SESSION_PARTITION_SPO == null)
			{
				SESSION_PARTITION_SPO = Cache.Session.getPartition(PARTITION_NAME);
			}
			return SESSION_PARTITION_SPO;
		}
	}

	public static void putValueInPartition(String key, Object value)
	{
		Cache.Partition.validateKeyValue(false, key, value);
		if(sessionPartition != null && SESSION_PARTITION_SPO.isAvailable())
		{
			SESSION_PARTITION_SPO.put(key, value);
		}
	}

	public static Object getValueFromPartition(String key)
	{
		Object ans = null;
		if(sessionPartition != null && SESSION_PARTITION_SPO.contains(key))
		{
			ans = SESSION_PARTITION_SPO.get(key);
		}
		return ans;
	}

	private static ID briefId;

	public static ID currentBriefId {

		get {
			if(null == briefId && ApexPages.currentPage() != null) {

				String paramId = ApexPages.currentPage().getParameters().get('id');
				if(String.isNotBlank(paramId) && paramId.startsWith('006')) {
					briefId = ID.valueOf(paramId);
				}
				else {
					paramId = ApexPages.currentPage().getParameters().get('bid');
					if(String.isNotBlank(paramId) && paramId.startsWith('006')) {
						briefId = ID.valueOf(paramId);
					}
				}
			}//if(null == briefId)
			return briefId;
		}
	}

	private static Opportunity brief;

	public static Opportunity theCurrentBrief {
		 get {
		 	return currentBriefById(currentBriefId);
		 }
	}

	public static void startSession(Opportunity opp) {
		briefId = opp.Id;
		brief = opp;
		//return retSessionState();
	}

	public static Opportunity currentBriefById(ID oppId) {

		System.debug('oppId >> ' + oppId + ', brief >> ' + brief);

		if( (null != oppId) && (null == brief || (brief != null && oppId != brief.Id) ) ) {
			briefId = oppId;
			brief = retOpportunityBy(oppId);
		}
		System.debug('currentBriefById - brief: ' + brief);
		return brief;
	}

	public static SO_Session.SessionState retSessionState() {

		return retSessionStateForOpp(theCurrentBrief);
	}

	public static SO_Session.SessionState retSessionStateForOpp(SObject sobj) {
		SO_Session.SessionState currentState;
		String sessionState = (null != sobj) ? ((String) sobj.get('SPO_Session_State__c')) : null;

		if (String.isNotBlank(sessionState)) {
			try {
				currentState = (SO_Session.SessionState)JSON.deserialize(sessionState, SO_Session.SessionState.class);
			} catch(Exception exp) {
				SO_UTIL.exceptionDump(exp);
				currentState = new SO_Session.SessionState();
			}
		} else {
			currentState = new SO_Session.SessionState();
		}	

		// Begin RMOU
		if (!UserInfo.getSessionId().equals(currentState.sessionID))
			currentState = new SO_Session.SessionState();

		// End RMOU

		if(sobj instanceof Opportunity) {
			currentState.displayOrder = ((Opportunity) sobj).SPO_DisplayOrder__c;
		}

		return currentState;

	}

	public static void saveSession(SO_Session.SessionState state, Boolean toDataBase) {

		saveSession(theCurrentBrief, state, toDataBase);
	}

	public static void saveSession(Opportunity opp, SO_Session.SessionState state, Boolean toDataBase) {

		briefId = opp.Id;
		brief 	= opp;

		assignSession(opp, state);
		
		brief.SPO_DisplayOrder__c = state.displayOrder;

		if(toDataBase) {
			updateCurrentBrief();			
		}
	}

	public static void saveSession(User oneUser, SO_Session.SessionState state, Boolean toDataBase) {

		assignSession(oneUser, state);
		if(toDataBase) {
			Database.update(oneUser);
		}

	}

	public static void assignSession(SObject target, SO_Session.SessionState state) {

		state.sessionID = UserInfo.getSessionId();
		String jsonStr = JSON.serialize(state);
		System.debug( 'target ID >> ' + target.Id + ' state >> ' + jsonStr);

		target.put('SPO_Session_State__c', jsonStr);

	}

	public static void updateCurrentBrief() {

		if(null != brief) {
			Database.upsert(brief);
		}
	}	

	/*
		AEF: If necessary, the required fields can be added here.  
	 */
	public static Opportunity retOpportunityBy(ID oppId) {
		Opportunity ans = new Opportunity();

		List<Opportunity> oppList = [SELECT 
					Id, Name
					,OwnerId
					,StageName
					,SPO_DisplayOrder__c
					,AccountId
					,Account.Name
					,Account.FirstName
					,Account.LastName
					,toLabel(Account.Salutation)
					,SPO_OpportunityCloning__c
					,SPO_Store__c
					,SPO_Store__r.RetailStoreId__c
					,SPO_Store__r.StoreCountry__c
					,SPO_StoreCode__c
					,SPO_Session_State__c
					,SPO_BaseSKURefmodelSKU__c
					,SPO_BaseSKURefmodelSKU__r.Name
					,SPO_BaseSKURefmodelSKU__r.SKUCode__c
					,SPO_ProductCategory__c
					,SPO_OrderType__c 
					,SPO_RMSClientId__c
					,SPO_Free__c
					,SPO_DepositAmount__c
					,SPO_UnitRetailPriceQuotation__c
					,SPO_SpecialOrderSKUCode__c
					,SPO_DepositNumber__c
					,SPO_BriefCode__c
					,SPO_caCode__c
					,SPO_Sizewidth__c
					,SPO_BaseSku__c 
					,SPO_ConcatenateTitle__c
					,SPO_SkuQuantity__c
			  FROM  Opportunity
			  WHERE Id =: oppId];
		if(!oppList.isEmpty())
		{
			ans = oppList[0];
		} 
			
		return ans;
	}


	/*
		AEF: If necessary, the required fields can be added here.  
	 */
	public Class SessionState {

		public OrderMode mode 			{ get; set; }
		public Boolean isProductReady 	{
			get {
				if(null == isProductReady) {
					isProductReady = false;
				}
				return isProductReady;
			}  
			set; 
		}
		public Boolean   displayOrder 	{ 
			
			get {
				if(null == displayOrder) {
					displayOrder = false;
				}
				return displayOrder;
			} 
			set; 
		}

		// RMOU : added sessionID
		public String sessionID {get; set; }

		public SO_UTIL.SearchClientData  searchClientData 	{ get; set; }
		public SO_UTIL.SearchProductData searchProductData 	{ get; set; }
		public SO_UTIL.GlobalSearchData  globalSearchData   { get; set; }

	}

}