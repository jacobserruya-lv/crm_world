/**Modification History
*  10/10/2016 | MTOU | Removing "Cancel button" when status equals "Deposit Sent" or "Creation in progress"
*/
public virtual class SO_BaseController{ 



	private static Map<String, Map<String, SO_IconByTab>> preFillIconsByRoleAndStage;
	
	public String userLanguageLocaleKey {get; private set;}

	public static String FIRM_ORDER_CANCEL_STATUS = 'Received in store';
	public static Set<String> breifStagesForStoreOtherCancelButton;
	public static Set<String> breifStagesForProductionCancelButton;

    static
    {
        preFillIconsByRoleAndStage = new Map<String, Map<String, SO_IconByTab>> 
        {
            'Store' => new Map<String, SO_IconByTab> 
            {
                'Brief in progress' => new SO_IconByTab('question-sign','question-sign','ban-circle'),
                'Quotation in progress' => new SO_IconByTab('check', 'lock', 'time'),
                'Quotation submitted' => new SO_IconByTab('check', 'lock', 'question-sign'),
                'Quotation accepted' => new SO_IconByTab('check', 'lock', 'question-sign'),
                'Deposit sent' => new SO_IconByTab('check', 'lock', 'time'),
                'Creation in progress' => new SO_IconByTab('check', 'lock', 'time'),
                'In progress' => new SO_IconByTab('check', 'lock', 'question-sign'),
                'Payment confirmed' => new SO_IconByTab('check', 'lock', 'lock'),
                'Closed Won' => new SO_IconByTab('lock', 'lock', 'lock'),
                'Cancelled by store' => new SO_IconByTab('lock', 'lock', 'lock'),
                'Cancelled by Production' => new SO_IconByTab('lock', 'lock', 'lock'),
				'Cancelled - Migrated in Xstore' => new SO_IconByTab('lock', 'lock', 'lock')
            },
            
            'Production' => new Map<String, SO_IconByTab> 
            {
                'Brief in progress' => new SO_IconByTab('lock', 'lock', 'lock'),
                'Quotation in progress' => new SO_IconByTab('check', 'check', 'question-sign'),
                'Quotation submitted' => new SO_IconByTab('check', 'check', 'time'),
                'Quotation accepted' => new SO_IconByTab('lock', 'check', 'time'),
                'Deposit sent' => new SO_IconByTab('lock', 'check', 'time'),
                'Creation in progress' => new SO_IconByTab('lock', 'check', 'question-sign'),
                'In progress' => new SO_IconByTab('lock', 'lock', 'question-sign'),
                'Payment confirmed' => new SO_IconByTab('lock', 'lock', 'lock'),
                'Closed Won' => new SO_IconByTab('lock', 'lock', 'lock'),
                'Cancelled by store' => new SO_IconByTab('lock', 'lock', 'lock'),
                'Cancelled by Production' => new SO_IconByTab('lock', 'lock', 'lock'),
				'Cancelled - Migrated in Xstore' => new SO_IconByTab('lock', 'lock', 'lock')
            }
        };

        breifStagesForStoreOtherCancelButton = new Set<String>
        {
        	'Brief in progress',
			'Quotation in progress',
			'Quotation submitted',
			'Quotation rejected',
			'Quotation accepted'
            // 10/10/2016 - MTOU: deactivating "Deposit Sent" and "Creation in progress status"
			//'Deposit sent', 
			//'Creation in progress'
        };

        breifStagesForProductionCancelButton = new Set<String>
        {
        	'Brief in progress',
			'Quotation in progress'
        };                
    }

	//---------------- Public fields ----------------------------------------------
	public String tabView{
        get{
            return ApexPages.currentPage().getParameters().get('tab');
        }
    }

	
	public String pageName{
        get{
			String name = ApexPages.currentPage().getUrl().substringAfterLast('/').toLowerCase();
			if (name.indexOf('?') >= 0)
				return name.substringBefore('?');
			return name;
        }
    }

	public String navActiveTab{get;Set;}

	public List<SO_BreadcrumbParameter> breadcrumbs {get;Set;}

    public String oppAccessory 				{ get{ return SO_PicklistDependency.OPP_ACCESSORY;  } }
	public String prorAccessory 			{ get{ return SO_PicklistDependency.PROR_ACCESSORY; } }
	public String oppRecTypeNameAccessory 	{ get{ return SO_PicklistDependency.OPP_REC_TYPE_NAME_ACCESSORY; } }
                                                          
	public String oppLeatherGood 			{ get{ return SO_PicklistDependency.OPP_LEATHER_GOOD; } }
	public String prorLeatherGood 			{ get{ return SO_PicklistDependency.PROR_LEATHER_GOOD; } }
	public String oppRecTypeNameLeatherGood { get{ return SO_PicklistDependency.OPP_REC_TYPE_NAME_LEATHER_GOOD; } }
                                                          
	public String oppWatch 					{ get{ return SO_PicklistDependency.OPP_WATCH; } }
	public String prorWatch 				{ get{ return SO_PicklistDependency.PROR_WATCH; } }
	public String oppRecTypeNameWatch 		{ get{ return SO_PicklistDependency.OPP_REC_TYPE_NAME_WATCH; } }

	public String orderTypeSpoMto 		 	{ get { return SO_PicklistDependency.ORDER_TYPE_SPO_MTO; } } 
	public String orderTypeSpecialOrder  	{ get { return SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER; } }
	public String orderTypeMtoOnCatalog  	{ get { return SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG; } }

	public Boolean showMessageOnTop 		{get; set;}
	public SO_IconByTab icons 				{get; set;}
	
	public String concatenateTitle 			{get; set;}

	//---------------- CTOR----------------------------------------------
	public SO_BaseController(){
		updateIcons();

		breadcrumbs = new List<SO_BreadcrumbParameter>{
			new SO_BreadcrumbParameter('client', null, this.icons.tabClientIcon, 1,'CLIENT', Label.LV_SO_SelectClient, ''),
			new SO_BreadcrumbParameter('product', null, this.icons.tabProductIcon, 2,'PRODUCT', Label.LV_SO_SelectProduct, ''),
			new SO_BreadcrumbParameter('brief-order', null, this.icons.tabBriefOrderIcon, 3,'BRIEF ORDER', Label.LV_SO_SelectClientNProductFirst, '/apex/SO_brieforder')
		};

		this.concatenateTitle = SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_ConcatenateTitle__c : '';
		setUserLangaugeLocalKey();
	}

	private void setUserLangaugeLocalKey()
	{
		SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
		this.userLanguageLocaleKey = orderPageSwitch.currentUser != null ? orderPageSwitch.currentUser.LanguageLocaleKey : null;
	}

	public virtual Boolean getHasCancelButton()
	{
		Boolean ans = false;
		SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
		SO_OrderPageSwitch.LogicalUserRoleEnum roleOfUserEnum = orderPageSwitch.sfoUserRoleByObject(SO_Session.theCurrentBrief);
		ans = (SO_OrderPageSwitch.LogicalUserRoleEnum.Production != roleOfUserEnum && 
				breifStagesForStoreOtherCancelButton.contains(SO_Session.theCurrentBrief.StageName)) 
			|| 
			(SO_OrderPageSwitch.LogicalUserRoleEnum.Production == roleOfUserEnum && 
				breifStagesForProductionCancelButton.contains(SO_Session.theCurrentBrief.StageName));

		return ans;
	}

	public void updateIcons(Opportunity theCurrentBrief)
	{
		SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
		String stageName = '';
		String roleOfUser = '';
		SO_OrderPageSwitch.LogicalUserRoleEnum roleOfUserEnum;
		Id clientId;
		Boolean displayOrder = false;
		Boolean isProductReady = false;

		if(theCurrentBrief != null){
			SO_Session.SessionState sessionState = SO_Session.retSessionState();
			if(sessionState != null){
				displayOrder = sessionState.displayOrder;
				isProductReady = sessionState.isProductReady;
			}
			
			stageName = theCurrentBrief.StageName;
			roleOfUserEnum = orderPageSwitch.sfoUserRoleByObject(theCurrentBrief);
			if(roleOfUserEnum != null){
				roleOfUser = roleOfUserEnum.name();
			}
			clientId = theCurrentBrief.AccountId;
		}

		if(roleOfUser == 'Other'){
        	roleOfUser = 'Store';
        }

        System.debug('role::stage --> ' + roleOfUser + '::' + stageName);
        if(roleOfUser == 'Store' || roleOfUser == 'Production'){
        	this.icons = preFillIconsByRoleAndStage.get(roleOfUser).get(stageName);
        }
        System.debug('updateIcons - this.icons : ' + this.icons);

        if(stageName == 'Brief in progress' && roleOfUser == 'Store' && this.icons != null){
        	if(displayOrder || (clientId != null)){
				this.icons.tabClientIcon = 'check';
			}
			if(isProductReady){
				this.icons.tabProductIcon = 'check';
			}
			if((displayOrder || (clientId != null)) && isProductReady){
				this.icons.tabBriefOrderIcon = 'question-sign';
			}
        }

        if(this.icons == null){
        	this.icons = new SO_IconByTab('', '', '');
        }
	}

	public void updateIcons(){
		updateIcons(SO_Session.theCurrentBrief);
	}

	
	//---------------- Public methods----------------------------------------------
	public virtual void init(){

	}


	
	/**
	* @description                returns breadcrumb object        
	*/
	public SO_BreadcrumbParameter getBreadcrumb(String name){
		for(SO_BreadcrumbParameter breadcrumb : this.breadcrumbs){
			if (breadcrumb.name == name){
				return breadcrumb;
			}
		}
		return null;
	}


	/**
	* @description               sets state of all breadcrumbs        
	*/
	public void setBreadcrumbsState(String state){
		for(SO_BreadcrumbParameter breadcrumb : this.breadcrumbs){
			breadcrumb.state = state;
		}		
	}

	public PageReference validateNoBriefIdBase() {

		SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
		if(orderPageSwitch.sfoUserRole == null)
		{
			return new PageReference('/home/home.jsp').setRedirect(true);
		}
		
		return (null == SO_Session.currentBriefId && (this.pageName != 'so_choosepath'&& this.pageName != 'so_notifications'&& this.pageName != 'so_search')) ?
			Page.SO_ChoosePath :
			null;
	}

	/**
	* @description               action for test purposes        
	*/
	/*public PageReference testAction(){
		return null;
	}*/

	public class SO_IconByTab{
		public String tabClientIcon {get; set;}
		public String tabProductIcon {get; set;}
		public String tabBriefOrderIcon {get; set;}

		public SO_IconByTab(String clientIcon, String productionIcon, String briefOrderIcon){
			this.tabClientIcon = clientIcon;
			this.tabProductIcon = productionIcon;
			this.tabBriefOrderIcon = briefOrderIcon;
		}
	}
	

}