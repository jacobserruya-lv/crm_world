public class SO_ChoosePath_CTRL extends SO_BaseController {

	//--------------------------- Public fields --------------
	public Opportunity 				newOpportunity 		{get; set;}
	public User 					newUser 			{get; private set;}
	public User 					originalUser 		{get; private set;}
	
	private SO_Session.SessionState theSessionState;


	public SO_ChoosePath_CTRL() {
		this.newOpportunity = new Opportunity();
		theSessionState = new SO_Session.SessionState();

		this.newUser = getUser();
		this.originalUser = new User();
		cloneOriginalZonesValues();
	}

	public PageReference redirectToClientSearchPage() {
		PageReference page = null;
		this.showMessageOnTop = true;
		try {
			theSessionState.mode = SO_Session.OrderMode.CLIENT;
			Boolean notDirtyData = changeOpportunity();
			Boolean caCodeValid = verifyCaCodeWS();

			System.debug('SFDC notDirtyData: ' + notDirtyData + ' caCodeValid: ' + caCodeValid);
			if(notDirtyData && caCodeValid)
			{
				SO_Session.saveSession(this.newOpportunity, theSessionState, true);

				page = System.Page.SO_ClientSearch;
				page.getParameters().put('bid', newOpportunity.Id);
				this.showMessageOnTop = false;
			}
			else{SO_UTIL.addErrorMessage(newUser.DefaultStore__c + ': ' + Label.LV_SO_RetailCodeNotFoundErrorMsg);}

			return page;
		} 
		catch(CalloutException ce){SO_UTIL.addErrorMessage(Label.LV_SO_RMS_ERROR);}
		catch(SO_UTIL.RMSException exp){SO_UTIL.addErrorMessage(exp);}
		catch (DMLException exp){SO_UTIL.addErrorMessage(exp.getdmlMessage(0));}
		catch (Exception exp){SO_UTIL.addErrorMessage(exp);}

		return null;
	}

	public PageReference redirectToProductSearchPage() {
		System.debug('SFDC redirectToProductSearchPage');
		PageReference page = null;
		this.showMessageOnTop = true;
		try {
			theSessionState.mode = SO_Session.OrderMode.PRODUCT;
			Boolean notDirtyData = changeOpportunity();
			Boolean caCodeValid = verifyCaCodeWS();

			if(notDirtyData && caCodeValid)
			{
				SO_Session.saveSession(this.newOpportunity, theSessionState, true);

				page = System.Page.SO_ProductSearch;
				page.getParameters().put('bid', newOpportunity.Id);
				this.showMessageOnTop = false;
			}
			else{SO_UTIL.addErrorMessage(newUser.DefaultStore__c + ': ' + Label.LV_SO_RetailCodeNotFoundErrorMsg);}

			return page;
		} 
		catch(CalloutException ce){SO_UTIL.addErrorMessage(Label.LV_SO_RMS_ERROR);}
		catch(SO_UTIL.RMSException exp){SO_UTIL.addErrorMessage(exp);}
		catch (DMLException exp){SO_UTIL.addErrorMessage(exp.getdmlMessage(0));}
		catch (Exception exp){SO_UTIL.addErrorMessage(exp);}

		return null;
	}

	private Boolean changeOpportunity() 
	{ 
		Boolean ans = false;
		this.newOpportunity.StageName = SO_Settings__c.getValues(SO_UTIL.NEW_OPPORTUNITY_STAGENAME_SETTINGS_NAME).Value__c;//SO_OrderPageSwitch.CREATION_IN_PROGRESS;

		this.newOpportunity.CloseDate = Date.today().addDays(Integer.valueOf(SO_Settings__c.getValues(SO_UTIL.NEW_OPPORTUNITY_CLODEDATE_SETTINGS_NAME).Value__c));

		Store__c store = retStrore(newUser.DefaultStore__c);
		if(null != store) 
		{
			this.newOpportunity.SPO_Store__c = store.Id;
			ans = true;				
		}

		return ans;
	}

	private Boolean verifyCaCodeWS()
	{
		System.debug('SFDC verifyCaCodeWS');
		Boolean wsResult = false;
		String codeVarification = Null;

		System.debug('SFDC SPO_CACode__c: ' + this.newOpportunity.SPO_CACode__c + ' newUser.DefaultStore__c: ' + newUser.DefaultStore__c);
		if(this.newOpportunity.SPO_CACode__c != Null && this.newOpportunity.SPO_Store__c != Null){
			SO_ClientAdvisorEnquiryRMS_Utils.SO_ClientAdvisorEnquiryResults calloutResult = SO_ClientAdvisorEnquiryRMS_Utils.VerifyClientAdvisorEnquiryRMS(this.newOpportunity.SPO_CACode__c, newUser.DefaultStore__c);
		}
		wsResult = true;
		return wsResult;
	}

	private static User getUser(){
		return [SELECT MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL3__c, DefaultStore__c
				FROM User
				WHERE Id =:UserInfo.getUserId()];
	}

	private static Store__c retStrore(String retailStoreId){
		List<Store__c> storeList = 
					   	   [SELECT Id, RetailStoreId__c
							  FROM Store__c
							 WHERE RetailStoreId__c =: retailStoreId];

		return !storeList.isEmpty() ? storeList[0] : null;

	}

	private void cloneOriginalZonesValues()
	{
		this.originalUser.MANAGEMENT_ZONE_LEVEL__c = this.newUser.MANAGEMENT_ZONE_LEVEL__c;
		this.originalUser.MGMT_ZONE_SUB_LEVEL1__c = this.newUser.MGMT_ZONE_SUB_LEVEL1__c;
		this.originalUser.MGMT_ZONE_SUB_LEVEL2__c = this.newUser.MGMT_ZONE_SUB_LEVEL2__c;
		this.originalUser.MGMT_ZONE_SUB_LEVEL3__c = this.newUser.MGMT_ZONE_SUB_LEVEL3__c;
	}
}