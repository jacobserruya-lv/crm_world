public class SO_Template_CTRL extends SO_BaseController { 
  
  

	//--------------------------- Public fields --------------
	public SO_Template_CTRL contr{get {return this;}}

	public SO_BreadcrumbParameter briefOrderTab {get; set;}
	private SO_BreadcrumbParameter clientTab {get;set;}
	private SO_BreadcrumbParameter productTab{get;set;}

	/* Controller */
	public SO_Template_CTRL(){
		
		//super();
		//this.mStdController = stdController;

		initTabs();
		initBreadCrumbs();
		initBreadCrumnbsIfHaveBrief();



	}
	private void initTabs()
	{
		clientTab = getBreadcrumb('client');
		productTab = getBreadcrumb('product');
		briefOrderTab = getBreadcrumb('brief-order');		
	}

	private void initBreadCrumnbsIfHaveBrief()
	{
		if(null != SO_Session.currentBriefId) 
		{
			if(true == SO_Session.theCurrentBrief.SPO_DisplayOrder__c || null != SO_Session.theCurrentBrief.AccountId) {
				clientTab.url = '/apex/SO_ViewClient?id=' + SO_Session.theCurrentBrief.AccountId + '&bid=' + SO_Session.currentBriefId;
				
				if(SO_Session.theCurrentBrief.SPO_DisplayOrder__c != true)
				{
					clientTab.description = SO_Session.theCurrentBrief.Account.Salutation;

					if(String.isNotBlank(clientTab.description)) {

					 	clientTab.description += '&nbsp' + SO_Session.theCurrentBrief.Account.LastName;
					}
					else {
						
						clientTab.description = SO_Session.theCurrentBrief.Account.LastName;	
					}
				}
				else
				{
					clientTab.description = Label.LV_SO_OrderDisplay;
				}

			}
			else {
				clientTab.url = '/apex/SO_ClientSearch?bid=' + SO_Session.currentBriefId;	
				briefOrderTab.state = 'hidden';
			}


			if(null != SO_Session.theCurrentBrief.SPO_BaseSKURefmodelSKU__c) {
				productTab.url = '/apex/SO_ProductSpe?id=' + SO_Session.currentBriefId;
				//productTab.description = SO_Session.theCurrentBrief.SPO_BaseSKURefmodelSKU__r.Name;
				productTab.description = SO_Session.theCurrentBrief.Name;
				briefOrderTab.url = '/apex/SO_BriefOrder?id=' + SO_Session.currentBriefId;
				briefOrderTab.description = SO_Session.theCurrentBrief.StageName;
			}
			else {
				productTab.url = '/apex/SO_ProductSearch?bid=' + SO_Session.currentBriefId;	
				briefOrderTab.state = 'hidden';
			}

			if(!SO_Session.retSessionState().isProductReady)
			{
				briefOrderTab.state = 'hidden';
			}


		}
		else {
			clientTab.url = '/apex/SO_ClientSearch';		
			productTab.url = '/apex/SO_ProductSearch';
			briefOrderTab.state = 'hidden';
		}

	}


	private void initBreadCrumbs ()
	{
		if (this.pageName == 'so_clientsearch'
			|| this.pageName == 'so_neweditclient'
			|| this.pageName == 'so_viewclient') 
		{
			this.navActiveTab = 'new-spe';
			getBreadcrumb('client').state = 'active';		

		}

		if (this.pageName == 'so_productsearch')
		{
			this.navActiveTab = 'new-spe';
			getBreadcrumb('product').state = 'active';		
		}

		if (this.pageName == 'so_productspe')
		{
			this.navActiveTab = 'new-spe';
			getBreadcrumb('product').state = 'active';
		}

		if (this.pageName == 'so_brieforder')
		{
			this.navActiveTab = null != SO_Session.currentBriefId 
								&& SO_Session.theCurrentBrief.StageName == 'Brief in progress' ? 'new-spe' : 'follow-up';
			getBreadcrumb('brief-order').state = 'active';	 
		}

		if (this.pageName == 'so_neweditclient')
		{
			this.navActiveTab = 'new-spe';
			getBreadcrumb('client').state = 'active';		
		}

		/* Without navbar */
		if (this.pageName == 'so_search')
		{
			this.navActiveTab = 'search';
		}

		if (this.pageName == 'so_notifications')
		{
			this.navActiveTab = 'notifications';
		}

		if (this.pageName == 'so_choosepath')
		{
			this.navActiveTab = 'new-spe';
		}



	}
	
	public PageReference validateNoBriefId() {

		return validateNoBriefIdBase();
	}

}