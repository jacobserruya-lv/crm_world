/**
 * This controller handle the product specificaiton:
 * 1. Customize the product (Color, Materials, etc.).
 * 2. Different customization for each product type.
 * 3. Allow adding attachments.
 * 4. Showing tracking fields for the Opp.
 * 
 * Modifcation History =============
 * 06/07/2016 MTOU: displaying error message on the page
 * 31/08/2016 MTOU: removing Account from tracking fields to be displayed (SOQL query filter)
 */
public class SO_ProductSpe_CTRL extends SO_BaseController{ 
	
	/**
	* @createdBy                Ofir Aghai
	*/
	//--------------------------- Private fields --------------
	private ApexPages.StandardController mStdController;
	
	

	//--------------------------- Public fields --------------
	public Id srcObjId 	{ get; set; } 
	public SO_ProductSpe_CTRL contr { get{return this;}}

	public ProductReferential__c pReferential 		{ get; set; }
	public SO_Session.SessionState  theSessionState 	{ get; set; }
	public String targetField { get; set; }

	public SO_QuotationContainer quotationContainer { 
		get {
			if(null == quotationContainer) {
				quotationContainer = new SO_QuotationContainer();
			}
			return quotationContainer; 
		} 
		set; 
	}

	public Boolean leatherGood_Creation 							{ get; set; }
	public Boolean leatherGood_Creation_OrderDisplay 				{ get; set; }
	public Boolean leatherGood_HarsidedOutOfMyPerso 				{ get; set; }
	public Boolean leatherGood_HarsidedOutOfMyPerso_OrderDisplay 	{ get; set; }
	public Boolean watch_SpoMto									 	{ get; set; }
	public Boolean accessory_Creation							 	{ get; set; }
	public Integer seeTranslation									{ get; set; }
	public Integer exteriorCntr										{ get; set; }
	public Integer liningCntr										{ get; set; }
	public String  toRemoveAttId 									{ get; set; }
	//history
	public List<OpportunityFieldHistory>	opportunityHistoryList	{get; private set;}		
					
	public String opportunityOrderType 								{ get; private set; }
	public String selectValuePainting  								{ get; set; }
	public String role                          					{get; private set;}
	public String baseRole 											{get; private set;}
	public Boolean isReadonlyMode               					{get; private set;}
	public Boolean hasQuotation                 					{get; private set;}

	//--------------------------- Public methods --------------
	/**
	 * Validate the page and init it.
	 */
	public SO_ProductSpe_CTRL(ApexPages.StandardController stdController) 
	{
        PageReference pageRef = validateNoBriefIdBase();
        if(pageRef == null)
        {
			this.srcObjId = stdController.getId();
			init();
        }   

	}

	public override void init()
	{
		try 
		{
			quotationContainer.oneOpportunity = retOpportunityById(srcObjId);
			quotationContainer.opportunityOrderType = quotationContainer.oneOpportunity.SPO_OrderType__c;
			quotationContainer.attachmentList =	retAttachmentListByOppId(srcObjId); 
			quotationContainer.colorNameToCodeMap = retColorNameToCodeMap();

			theSessionState = SO_Session.retSessionStateForOpp(quotationContainer.oneOpportunity);

			// Case without quotation
            this.hasQuotation = !SO_OrderPageSwitch.isWithoutQuotation();

			/* History List */
			this.opportunityHistoryList = getOpportunityHistoryList(this.srcObjId);

			// Get user role & if readonlyMode
			getUserRoleAndReadonlyMode();

			setProductRelatedRules();
			
			initColorSectionCounters();
		}
		catch (Exception  ex)
		{
			SO_UTIL.addErrorMessage(ex);
		}
	}

	private List<OpportunityFieldHistory> getOpportunityHistoryList(Id oppId)
	{
		return [SELECT CreatedBy.Name, OpportunityId, Opportunity.Name, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedById 
				FROM OpportunityFieldHistory 
				WHERE OpportunityId =: oppId
                AND Field != 'Account' // added by MTOU - account field not evaluated
				ORDER BY CreatedDate DESC];
	}

	/**
	 * Set init rules for the page.
	 * 1. Check current process type.
	 * 2. Prefilled fields.
	 */
	private void setProductRelatedRules()
	{
		/* Product Referencial */
		if(quotationContainer.oneOpportunity.SPO_BaseSKURefmodelSKU__r != null)
		{
			this.pReferential = quotationContainer.oneOpportunity.SPO_BaseSKURefmodelSKU__r;

			// init our 4 variable with false
			this.leatherGood_Creation=false;
			this.leatherGood_Creation_OrderDisplay=false;
			this.leatherGood_HarsidedOutOfMyPerso=false;
			this.leatherGood_HarsidedOutOfMyPerso_OrderDisplay=false;
			this.watch_SpoMto=false;
			this.accessory_Creation=false;
			
			preFilledFields();

			// save real data in temp variables
			String temp_productCategory = quotationContainer.oneOpportunity.SPO_ProductCategory__c;
			String temp_orderType = quotationContainer.oneOpportunity.SPO_OrderType__c; 
			
			if(SO_PicklistDependency.OPP_LEATHER_GOOD == temp_productCategory)
			{
				this.leatherGood_Creation = temp_orderType==SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
					
				if(temp_orderType==SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG)
				{
					quotationContainer.oneOpportunity.SPO_CreationType__c = 'Hardsided';
					leatherGood_HarsidedOutOfMyPerso = true;
				}
			}
			else if(SO_PicklistDependency.OPP_WATCH == temp_productCategory)
			{
				this.watch_SpoMto = temp_orderType==SO_PicklistDependency.ORDER_TYPE_SPO_MTO;
			}
			else if(SO_PicklistDependency.OPP_ACCESSORY == temp_productCategory)
			{
				this.accessory_Creation = temp_orderType==SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
			}
		}
		else 
		{
			this.pReferential = new ProductReferential__c();
		}
	}

	private void preFilledFields()
	{
		// Init Size field
		this.quotationContainer.oneOpportunity.SPO_Sizeunit__c = this.quotationContainer.oneOpportunity.SPO_Sizeunit__c == null 
																? 'Cm' 
																: this.quotationContainer.oneOpportunity.SPO_Sizeunit__c;

		SO_Settings__c productRefLiningMaterialVal = SO_Settings__c.getValues(SO_UTIL.PRODUCTS_REFERENTIAL_LINING_MATERIAL_DEFAULT_VALUE);
		Boolean isNotSpecialBlankLiningMaterial = productRefLiningMaterialVal != null && productRefLiningMaterialVal.Value__c != this.pReferential.SPO_LiningMaterial1__c;
		//init lining material from product ref attached to this opp:
		if(this.pReferential.SPO_LiningMaterial1__c != null
			&& isNotSpecialBlankLiningMaterial)
		{
			contr.quotationContainer.oneOpportunity.SPO_LiningInteriorMaterial1__c = this.pReferential.SPO_LiningMaterial1__c;
		}
	}

	/**
	 * Init color buttons sections (each add color button section).
	 * countr == 1 show only the first section.
	 * countr == 2 show second section as well.
	 * countr == 3 show 3rd section as well.
	 */
	private void initColorSectionCounters()
	{
		// counters init to 1 for show the basic field
		this.exteriorCntr=1;
		this.liningCntr=1;

		if(quotationContainer.oneOpportunity != null)
		{
			if(quotationContainer.oneOpportunity.SPO_ExteriorMaterial2__c != null)
			{
				this.exteriorCntr = 2;
				if(quotationContainer.oneOpportunity.SPO_ExteriorMaterial3__c != null)
				{
					this.exteriorCntr = 3;
				}
			}
			if(quotationContainer.oneOpportunity.SPO_LiningInteriorMaterial2__c != null)
			{
				this.liningCntr = 2;
			}
		}
	}

	public PageReference refreshAttachmentList() {

		System.debug('quotationContainer.attachmentList.size >> ' + quotationContainer.attachmentList.size());
		quotationContainer.attachmentList =	retAttachmentListByOppId(srcObjId);

		return null;
	}

	public PageReference removeAttachment() {

		System.debug('toRemoveAttId >> ' + toRemoveAttId);
		Map<ID, Attachment> attachmentMap = new Map<ID, Attachment>(quotationContainer.attachmentList);

		Database.delete(new String[] { toRemoveAttId });
		attachmentMap.remove(toRemoveAttId); 
		quotationContainer.attachmentList = attachmentMap.values();

		return null;
	}

	public PageReference addFormAttachment() {

		Integer valueIndex = Integer.valueOf(selectValuePainting) - 1;
		list<SelectOption> optionList = SO_UTIL.getPicklistValues ('Opportunity', 'SPO_Painting__c'); 
		SelectOption selectedOpption = optionList[valueIndex];
		String searchPattern = '%' + selectedOpption.getValue() + '%';

		List<Document> docList = 
						[SELECT Id, Name, Body, DeveloperName, Type
						   FROM Document 
						  WHERE Name like : searchPattern
						  LIMIT 1];

		if(SO_UTIL.isNotEmpty(docList)) {

			Attachment newAttachment = new Attachment();
			newAttachment.Body = docList[0].Body;
			newAttachment.Name = docList[0].Name+'.'+docList[0].Type;
			newAttachment.ParentId = this.srcObjId;
			newAttachment.ContentType = docList[0].Type;
			Database.insert(newAttachment);

			quotationContainer.attachmentList =	retAttachmentListByOppId(srcObjId);
		} 

		return null;
	} 

	public static Opportunity retOpportunityById(ID oppId) {
		//SPO_PatchColor__c, 
		//SPO_HotStamping__c, 
		//SPO_HotStampingletters__c,
		return
			[SELECT 
					Id,Name,AccountId,OwnerId,
					SPO_OrderType__c, 
					SPO_CreationType__c, 
					SPO_Exo__c,
			        SPO_Sizewidth__c,
        			SPO_SizeLenght__c,
       				SPO_SizeHeight__c,
					//SPO_SizewidthCM__c, 
					//SPO_SizeheightCM__c, 
					//SPO_SizelenghtCM__c,
					//SPO_SizeWidthInch__c,
					//SPO_SizeheightInch__c,
					//SPO_SizelenghtInch__c,
					SPO_Sizeunit__c,
					SPO_ProductCategory__c,
					SPO_CACode__c,
					SPO_OpportunityCloning__c,

					//sku product ref:
					SPO_BaseSKURefmodelSKU__c, 
					SPO_BaseSKURefmodelSKU__r.ProductCategory__c, 
					SPO_BaseSKURefmodelSKU__r.SKUCode__c,
					SPO_BaseSKURefmodelSKU__r.Name,
					SPO_BaseSKURefmodelSKU__r.SPO_ProductNameSKU__c,
					SPO_BaseSKURefmodelSKU__r.SPO_LiningMaterial1__c,

					//material
					//1
					SPO_ExteriorMaterial1__c,
					SPO_ExteriorMaterial1localcomment__c,
					SPO_ExtMaterial1zoneapprovercomment__c,
					SPO_ExteriorMaterialColor1__c,
					SPO_ExtMaterialColor1localcomment__c,
					SPO_ExtMatColor1zoneapprover__c,
					//2
					SPO_ExteriorMaterial2__c,
					SPO_ExteriorMaterial2localcomment__c,
					SPO_ExtMaterial2zoneapprovercomment__c,
					SPO_ExteriorMaterialColor2__c,
					SPO_ExtMaterialColor2localcomment__c,
					SPO_ExtMatColor2zoneapproverCommen__c,
					//3
					SPO_ExteriorMaterial3__c,	
					SPO_ExteriorMaterial3localcomment__c,	
					SPO_ExtMaterial3zoneapprovercomment__c,
					SPO_ExteriorMaterialColor3__c,
					SPO_ExtMaterialColor3localcomment__c,
					SPO_ExtMaterialColor3approvercomment__c,

					//lining
					//1
					SPO_LiningInteriorColor1__c,
					SPO_LiningInteriorMaterial1__c,
					SPO_LiningColor1LocalComment__c,
					SPO_LiningColor1ZoneApproverComment__c,
					SPO_LiningMaterial1LocalComment__c,
					SPO_LiningMaterial1ZoneApproverComment__c,
					//2
					SPO_LiningInteriorColor2__c,
					SPO_LiningInteriorMaterial2__c,
					SPO_LiningColor2LocalComment__c,
					SPO_LiningColor2ZoneApproverComment__c,
					SPO_LiningMaterial2LocalComment__c,
					SPO_LiningMaterial2ZoneApproverComment__c,

					//metalic parts
					SPO_ColorMetalicparts__c,
                    SPO_ColorMetalicPartsLocalComment__c,
                    SPO_ColorMetalicPartsZoneApproverComment__c,

                    ///comment
					SPO_CommercialLocalComment__c,
					SPO_CommercialZoneApproverComment__c,
					SPO_InternalWorkshopComment__c,

					SPO_NoPersonNeeded__c,
					SPO_Lock__c,
					SPO_LockNumber__c,
					SPO_Painting__c,
					SPO_PaintingYN__c,
					SPO_PatchFreeText__c,
					SPO_Patch__c,
					SPO_ClientAccessoriesRequested__c,
					SPO_CommentClientAccessories__c,

					SPO_WristSize__c,
					SPO_BeltSize__c,
					SPO_DestinationWatch__c,
					//SPO_DestinationWatchDescription__c,

					SPO_StrapMaterialLocalComment__c,
					SPO_StrapMaterialZoneApproverComment__c,
					SPO_StrapColor__c,
					SPO_StrapColorLocalComment__c,
					SPO_StrapColorZoneApproverComment__c,
					SPO_StrapMaterial__c,

					SPO_Session_State__c,
					SPO_DisplayOrder__c,

					StageName

			FROM Opportunity 
			WHERE id = :oppId];

			//combinedAttachment
			//(SELECT CreatedDate, Title, FileExtension, FileType FROM CombinedAttachments)

	} 

	public static List<Attachment> retAttachmentListByOppId(ID oppId) {

		return 
			[SELECT Id, Name
				  , ContentType 
				  , CreatedDate
				  , Description
				  , Body
			   FROM Attachment
			  WHERE ParentId =: oppId];
	}

	/**
	 * Clean all the fields on the product specification page.
	 */
	public void cleanButton(){ 
		System.debug('SO_ProductSpe - cleanButton');
		Opportunity opp = this.quotationContainer.oneOpportunity;
		if(opp != null){
			quotationContainer.colorNameToCodeMap = retColorNameToCodeMap();

			System.debug('SO_ProductSpe - cleanButton - OPP: ' + opp);
			// Personalization Section
			opp.SPO_Painting__c = null;
			opp.SPO_PaintingYN__c = null;
			opp.SPO_Patch__c = null;
			opp.SPO_PatchFreeText__c = null;
			opp.SPO_Lock__c = null;
			opp.SPO_LockNumber__c = null;
			opp.SPO_ClientAccessoriesRequested__c = null;
			opp.SPO_CommentClientAccessories__c = null;
			opp.SPO_WristSize__c = null;
			opp.SPO_BeltSize__c = null;
			opp.SPO_DestinationWatch__c = null;

			// Materials Section
			opp.SPO_ExteriorMaterial1__c = null;
			opp.SPO_ExteriorMaterial1localcomment__c = null;
			opp.SPO_ExtMaterial1zoneapprovercomment__c = null;
			opp.SPO_ExteriorMaterialColor1__c = null;
			opp.SPO_ExtMaterialColor1localcomment__c = null;
			opp.SPO_ExtMatColor1zoneapprover__c = null;
			opp.SPO_ExteriorMaterial2__c = null;
			opp.SPO_ExteriorMaterial2localcomment__c = null;
			opp.SPO_ExtMaterial2zoneapprovercomment__c = null;
			opp.SPO_ExteriorMaterialColor2__c = null;
			opp.SPO_ExtMaterialColor2localcomment__c = null;
			opp.SPO_ExtMatColor2zoneapproverCommen__c = null;
			opp.SPO_ExteriorMaterial3__c = null;
			opp.SPO_ExteriorMaterial3localcomment__c = null;
			opp.SPO_ExtMaterial3zoneapprovercomment__c = null;
			opp.SPO_ExteriorMaterialColor3__c = null;
			opp.SPO_ExtMaterialColor3localcomment__c = null;
			opp.SPO_ExtMaterialColor3approvercomment__c = null;
			opp.SPO_Sizewidth__c = null;
			opp.SPO_SizeHeight__c = null;
			opp.SPO_SizeLenght__c = null;
			opp.SPO_LiningInteriorMaterial1__c = null;
			opp.SPO_LiningMaterial1LocalComment__c = null;
			opp.SPO_LiningMaterial1ZoneApproverComment__c = null;
			opp.SPO_LiningInteriorColor1__c = null;
			opp.SPO_LiningColor1LocalComment__c = null;
			opp.SPO_LiningColor1ZoneApproverComment__c = null;
			opp.SPO_LiningInteriorMaterial2__c = null;
			opp.SPO_LiningMaterial2LocalComment__c = null;
			opp.SPO_LiningMaterial2ZoneApproverComment__c = null;
			opp.SPO_LiningInteriorColor2__c = null;
			opp.SPO_LiningColor2LocalComment__c = null;
			opp.SPO_LiningColor2ZoneApproverComment__c = null;
			opp.SPO_ColorMetalicparts__c = null;
			opp.SPO_ColorMetalicPartsLocalComment__c = null;
			opp.SPO_ColorMetalicPartsZoneApproverComment__c = null;
			opp.SPO_StrapMaterial__c = null;
			opp.SPO_StrapMaterialLocalComment__c = null;
			opp.SPO_StrapMaterialZoneApproverComment__c = null;
			opp.SPO_StrapColor__c = null;
			opp.SPO_StrapColorLocalComment__c = null;
			opp.SPO_StrapColorZoneApproverComment__c = null;

			// Comment Section
			opp.SPO_CommercialLocalComment__c = null;
			opp.SPO_CommercialZoneApproverComment__c = null;
			opp.SPO_InternalWorkshopComment__c = null;

			// Description Section
			opp.SPO_CreationType__c = null;
			if(SO_PicklistDependency.OPP_LEATHER_GOOD == opp.SPO_ProductCategory__c
				&& opp.SPO_OrderType__c == SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG)
			{
				opp.SPO_CreationType__c = 'Hardsided';
			}
			
			//Init additional sections:
			this.exteriorCntr = 1;
			this.liningCntr = 1;

			opp.SPO_NoPersonNeeded__c = false;

			showMessageOnTop = false;

			System.debug('SO_ProductSpe - cleanButton - OPP after clean: ' + opp);
		}
	} 

	/**
	 * Increase countr for color section by 1.
	 */
	public void incExteriorCntr (){
		if (this.exteriorCntr <3){
			this.exteriorCntr++;
		}
	}

	/**
	 * Decrease countr for color section by 1.
	 */
	public void decExteriorCntr (){
		System.debug('decExteriorCntr:');
		if (this.exteriorCntr >1){
			System.debug('this.exteriorCntr: ' + this.exteriorCntr);
			System.debug('quotationContainer.colorNameToCodeMap: ' + quotationContainer.colorNameToCodeMap);
			if(this.exteriorCntr == 3){
				this.quotationContainer.oneOpportunity.SPO_ExteriorMaterial3__c =null;
				this.quotationContainer.oneOpportunity.SPO_ExteriorMaterialColor3__c =null;
				quotationContainer.colorNameToCodeMap = retColorNameToCodeMap();
			}
			else if(this.exteriorCntr == 2){
				this.quotationContainer.oneOpportunity.SPO_ExteriorMaterial2__c =null;
				this.quotationContainer.oneOpportunity.SPO_ExteriorMaterialColor2__c =null;
			}
			this.exteriorCntr--;
			System.debug('this.exteriorCntr--: ' + this.exteriorCntr);
		}
	}

	/**
	 * Increase countr for color section by 1.
	 */
	public void incLiningCntr (){
		if (this.liningCntr <3){
			this.liningCntr++;
		}
	}

	/**
	 * Decrease countr for color section by 1.
	 */
	public void decLiningCntr (){
		if (this.liningCntr >1){
			this.quotationContainer.oneOpportunity.SPO_LiningInteriorMaterial2__c =null;
			this.quotationContainer.oneOpportunity.SPO_LiningInteriorColor2__c =null;
			this.liningCntr--;
		}
	}

	public PageReference backToClient(){
		PageReference pageRef;
		// redirect user to the next page
		if(quotationContainer.oneOpportunity.AccountId != null) {

			pageRef = Page.SO_ViewClient;
			pageRef.getParameters().put('id', quotationContainer.oneOpportunity.AccountId);
			pageRef.getParameters().put('bid', srcObjId);
		}
		else { //if(quotationContainer.oneOpportunity.AccountId == null)
			
			pageRef = Page.SO_ClientSearch;
			pageRef.getParameters().put('bid', srcObjId);
		}

		return pageRef;
	}

	/**
	 * Save the product specification for this opp, redirect to Brief order if client is already selected otherwise to Client Search page.
	 */
	public PageReference saveAndNext(){

		
		try {
			quotationContainer.colorNameToCodeMap = retColorNameToCodeMap();
			if (quotationContainer.oneOpportunity.SPO_Exo__c=='Yes'
				&& quotationContainer.oneOpportunity.SPO_ProductCategory__c == SO_PicklistDependency.OPP_LEATHER_GOOD
				&& quotationContainer.oneOpportunity.SPO_OrderType__c == SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG) 
			{
				String errorMessage = Label.LV_SO_ProductSpe_ErrorMessage;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errorMessage));

				return null;
			}
			else 
			{
				// Save opportunity in s.f
				//upsert this.pReferential;
				//quotationContainer.oneOpportunity.SPO_NoPersonNeeded__c
				PageReference pageRef = null;

				//MY change isProductReady to true
				theSessionState.isProductReady = true; 
				//SO_Session.saveSession(theSessionState, true);
				SO_Session.assignSession(quotationContainer.oneOpportunity, theSessionState);
				update quotationContainer.oneOpportunity;


				// redirect user to the next page
				if(true == theSessionState.displayOrder || null != quotationContainer.oneOpportunity.AccountId) {

					pageRef = Page.SO_BriefOrder;
					pageRef.getParameters().put('id', srcObjId);
				}
				else { //if(quotationContainer.oneOpportunity.AccountId == null)
					
					pageRef = Page.SO_ClientSearch;
					pageRef.getParameters().put('bid', srcObjId);
				}

				return pageRef;
			}
		}
		catch (Exception  exp) {
            // 06/07/2016 MTOU: displaying error message on page
			String type = exp.getTypeName();
            if(exp instanceof DmlException)
            {
                SO_UTIL.addDMLMessage(exp);
            }
            else
            {
              SO_UTIL.addErrorMessage(exp);    
            }
            showMessageOnTop = true;
            // end MTOU
			return null;
		}
		
	}

	/**
	 * Init fields after color controlling field change.
	 */
	public void initStrapColorField(){
		System.debug('initStrapColorField');
		this.quotationContainer.colorNameToCodeMap = retColorNameToCodeMap();
		this.quotationContainer.oneOpportunity.SPO_StrapMaterialLocalComment__c = null;
		this.quotationContainer.oneOpportunity.SPO_StrapMaterialZoneApproverComment__c = null;
		
		this.quotationContainer.oneOpportunity.SPO_StrapColor__c = null;
		this.quotationContainer.oneOpportunity.SPO_StrapColorLocalComment__c = null;
		this.quotationContainer.oneOpportunity.SPO_StrapColorZoneApproverComment__c = null;
	}

	/**
	 * Init fields after color controlling field change.
	 */
	public void initExteriorMaterial1Field(){
		System.debug('initExteriorMaterial1Field');
		this.quotationContainer.colorNameToCodeMap = retColorNameToCodeMap();
		this.quotationContainer.oneOpportunity.SPO_ExteriorMaterial1localcomment__c = null;
		this.quotationContainer.oneOpportunity.SPO_ExtMaterial1zoneapprovercomment__c = null;

		this.quotationContainer.oneOpportunity.SPO_ExteriorMaterialColor1__c = null;
		this.quotationContainer.oneOpportunity.SPO_ExtMaterialColor1localcomment__c = null;
		this.quotationContainer.oneOpportunity.SPO_ExtMatColor1zoneapprover__c = null;
	}

	/**
	 * Init fields after color controlling field change.
	 */
	public void initExteriorMaterial2Field(){
		System.debug('initExteriorMaterial2Field');
		this.quotationContainer.colorNameToCodeMap = retColorNameToCodeMap();
		this.quotationContainer.oneOpportunity.SPO_ExteriorMaterial2localcomment__c = null;
		this.quotationContainer.oneOpportunity.SPO_ExtMaterial2zoneapprovercomment__c = null;

		this.quotationContainer.oneOpportunity.SPO_ExteriorMaterialColor2__c = null;
		this.quotationContainer.oneOpportunity.SPO_ExtMaterialColor2localcomment__c = null;
		this.quotationContainer.oneOpportunity.SPO_ExtMatColor2zoneapproverCommen__c = null;
	}

	/**
	 * Init fields after color controlling field change.
	 */
	public void initExteriorMaterial3Field(){
		System.debug('initExteriorMaterial2Field');
		this.quotationContainer.colorNameToCodeMap = retColorNameToCodeMap();
		this.quotationContainer.oneOpportunity.SPO_ExteriorMaterial3localcomment__c = null;
		this.quotationContainer.oneOpportunity.SPO_ExtMaterial3zoneapprovercomment__c = null;

		this.quotationContainer.oneOpportunity.SPO_ExteriorMaterialColor3__c = null;
		this.quotationContainer.oneOpportunity.SPO_ExtMaterialColor3localcomment__c = null;
		this.quotationContainer.oneOpportunity.SPO_ExtMaterialColor3approvercomment__c = null;
	}

	/**
	 * Init fields after color controlling field change.
	 */
	public void initLiningInteriorMaterial1Field(){
		System.debug('initLiningInteriorMaterial1Field');
		this.quotationContainer.colorNameToCodeMap = retColorNameToCodeMap();
		this.quotationContainer.oneOpportunity.SPO_LiningMaterial1LocalComment__c = null;
		this.quotationContainer.oneOpportunity.SPO_LiningMaterial1ZoneApproverComment__c = null;

		this.quotationContainer.oneOpportunity.SPO_LiningInteriorColor1__c = null;
		this.quotationContainer.oneOpportunity.SPO_LiningColor1LocalComment__c = null;
		this.quotationContainer.oneOpportunity.SPO_LiningColor1ZoneApproverComment__c = null;
	}

	/**
	 * Init fields after color controlling field change.
	 */
	public void initLiningInteriorMaterial2Field(){
		System.debug('initLiningInteriorMaterial2Field');
		this.quotationContainer.colorNameToCodeMap = retColorNameToCodeMap();
		this.quotationContainer.oneOpportunity.SPO_LiningMaterial2LocalComment__c = null;
		this.quotationContainer.oneOpportunity.SPO_LiningMaterial2ZoneApproverComment__c = null;
		
		this.quotationContainer.oneOpportunity.SPO_LiningInteriorColor2__c = null;
		this.quotationContainer.oneOpportunity.SPO_LiningColor2LocalComment__c = null;
		this.quotationContainer.oneOpportunity.SPO_LiningColor2ZoneApproverComment__c = null;
	}

	public PageReference clearOppFields(){
		initCreationTypePicklistFields();

		this.quotationContainer.oneOpportunity.SPO_Sizewidth__c =null;
		this.quotationContainer.oneOpportunity.SPO_SizeHeight__c =null;
		this.quotationContainer.oneOpportunity.SPO_SizeLenght__c =null;
		this.quotationContainer.oneOpportunity.SPO_PatchFreeText__c =null;

		this.quotationContainer.oneOpportunity.SPO_Painting__c =null;
		this.quotationContainer.oneOpportunity.SPO_PaintingYN__c =null;
		this.quotationContainer.oneOpportunity.SPO_Patch__c =null;
		this.quotationContainer.oneOpportunity.SPO_ColorMetalicparts__c =null;
		this.quotationContainer.oneOpportunity.SPO_LockNumber__c =null;
		this.quotationContainer.oneOpportunity.SPO_Lock__c =null;
		this.quotationContainer.oneOpportunity.SPO_ClientAccessoriesRequested__c =null;
		this.quotationContainer.oneOpportunity.SPO_StrapMaterial__c =null;
		this.quotationContainer.oneOpportunity.SPO_StrapColor__c =null;
		this.quotationContainer.oneOpportunity.SPO_WristSize__c =null;
		this.quotationContainer.oneOpportunity.SPO_DestinationWatch__c =null;

		// Description Section
		this.quotationContainer.oneOpportunity.SPO_CreationType__c = null;
		if(SO_PicklistDependency.OPP_LEATHER_GOOD == this.quotationContainer.oneOpportunity.SPO_ProductCategory__c
			&& this.quotationContainer.oneOpportunity.SPO_OrderType__c == SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG)
		{
			this.quotationContainer.oneOpportunity.SPO_CreationType__c = 'Hardsided';
		}

		//Init additional sections:
		this.exteriorCntr = 1;
		this.liningCntr = 1;

		showMessageOnTop = false;

		return null;
	}

	public void initCreationTypePicklistFields(){
		this.quotationContainer.oneOpportunity.SPO_ExteriorMaterial1__c =null;
		this.quotationContainer.oneOpportunity.SPO_ExteriorMaterialColor1__c =null;
		this.quotationContainer.oneOpportunity.SPO_ExteriorMaterial2__c =null;
		this.quotationContainer.oneOpportunity.SPO_ExteriorMaterialColor2__c =null;
		this.quotationContainer.oneOpportunity.SPO_ExteriorMaterial3__c =null;
		this.quotationContainer.oneOpportunity.SPO_ExteriorMaterialColor3__c =null;

		this.quotationContainer.oneOpportunity.SPO_LiningInteriorColor1__c =null;
		this.quotationContainer.oneOpportunity.SPO_LiningInteriorMaterial1__c =null;
		this.quotationContainer.oneOpportunity.SPO_LiningInteriorColor2__c =null;
		this.quotationContainer.oneOpportunity.SPO_LiningInteriorMaterial2__c =null;
	}

	public PageReference initCreationTypeDependentFields(){
		System.debug('SO_ProductSpe_CTRL - initCreationTypeDependentFields:');
		initCreationTypePicklistFields();

		//this.quotationContainer.oneOpportunity.SPO_ColorMetalicparts__c =null;

		//this.quotationContainer.oneOpportunity.SPO_StrapColor__c =null;
		//this.quotationContainer.oneOpportunity.SPO_StrapMaterial__c =null;

		this.exteriorCntr=1;
		this.liningCntr=1;

		return null;
	}

	public void updateExo(){
		String exo;
		try{
			exo = ApexPages.currentPage().getParameters().get('exo').escapeHtml4();
			if (exo!= null){
				System.debug('SO_ProductSpe_CTRL - updateExo - exo: '+exo);
				System.debug('SO_ProductSpe_CTRL - updateExo - this.quotationContainer.oneOpportunity.SPO_Exo__c: '+this.quotationContainer.oneOpportunity.SPO_Exo__c);
				this.quotationContainer.oneOpportunity.SPO_Exo__c = exo;
			}
		}catch(Exception ex){
			SO_UTIL.addErrorMessage(ex);
		}	
	}

	/**
	 * This remote action use to create the custom color picker.
	 * It takes the color names from the assosicated picklist, and try to match them against the color records in the data base.
	 * In the end it returns a JSON of the validated colors objects.
	 */
	@RemoteAction 
	public static String getColorsRgbHexMapByNames(List<String> colorListNames) {

   		List<SPO_Colors__c> colorsList = retColorListByName(colorListNames);
		List<ColorPicker> ColorPickerList = new List<ColorPicker>();

		for(SPO_Colors__c colorObj : colorsList) {
			for (String nameInPickList : colorListNames){
				if (colorObj.Name.toUpperCase() == nameInPickList.toUpperCase()) {
					ColorPickerList.add(new ColorPicker(colorObj.SPO_CodeCouleur__c, 
						colorObj.SPO_Preview__c, colorObj.Name, 
						nameInPickList, colorObj.SPO_Position__c));
				}
			}
		}

		ColorPickerList.sort();
		String jsonResultList = JSON.serialize(ColorPickerList);
		return jsonResultList;
	}

	/**
	 * Build the color map for the color buttons.
	 */
	public Map<String,String> retColorNameToCodeMap() {

		String defaultStyle = 'background-color:transparent;';

		Set<String> colorFieldSet = new Set<String> 
		{ 
			 'SPO_StrapColor__c'
			,'SPO_LiningInteriorColor1__c'
			,'SPO_LiningInteriorColor2__c'
			,'SPO_ExteriorMaterialColor1__c'
			,'SPO_ExteriorMaterialColor2__c'
			,'SPO_ExteriorMaterialColor3__c'
		};

		Set<String> colorNameSet = new Set<String>();
		Map<String,String> colorNameToCodeMap = new Map<String,String>();
		colorNameToCodeMap.put(Label.LV_SO_Other_free_text, defaultStyle);
		Map<String, String> colorNamebyColorNameLowerCaseMap = new Map<String,String>();

		for(String oneColorField : colorFieldSet) 
		{
			String oneColorFieldVal = (String)quotationContainer.oneOpportunity.get(oneColorField);
			if(String.isNotBlank(oneColorFieldVal)) 
			{
				colorNameToCodeMap.put(oneColorFieldVal, defaultStyle);
				colorNamebyColorNameLowerCaseMap.put(oneColorFieldVal.toLowerCase(), oneColorFieldVal);
			}
		}

		String colorTempl = 'color:#{0};';
		/* "background-size": "cover"
            ,"width":"14px"
            ,"height":"14px"
            ,"display":"inline-block"
            ,"margin-top":"2px"
            ,"margin-bottom":"-2px"
            ,"background" : e.target.style.background*/
		//String backgroundTempl = 'background:url(\"{0}\") no-repeat;background-size:cover;color: transparent;';
		String backgroundTempl = 'background-size:cover;width:14px;height:14px;display:inline-block;margin-top:2px;margin-bottom:-2px;background:url(\"{0}\") no-repeat;';

		List<SPO_Colors__c> colorList = retColorListByName(new List<String>(colorNameToCodeMap.keySet()));

		for(SPO_Colors__c oneColor : colorList) 
		{
			if(String.isNotBlank(oneColor.Name)
				&& !colorNamebyColorNameLowerCaseMap.containsKey(oneColor.Name.toLowerCase()))
			{
				continue;
			}
			String colorName = colorNamebyColorNameLowerCaseMap.get(oneColor.Name.toLowerCase());

			if(String.isNotBlank(oneColor.SPO_CodeCouleur__c)) 
			{
				colorNameToCodeMap.put(colorName, String.format(colorTempl, new String[] {oneColor.SPO_CodeCouleur__c}));
			}
			else if(String.isNotBlank(oneColor.SPO_Preview__c)) 
			{
				String imgUrl = extractImage(oneColor.SPO_Preview__c);
				colorNameToCodeMap.put(colorName, String.format(backgroundTempl, new String[] {imgUrl}));
			}
			else 
			{
				colorNameToCodeMap.put(colorName, defaultStyle);
			}

		}

		system.debug('colorNameToCodeMap: '+colorNameToCodeMap);
		return colorNameToCodeMap;
		
	}

	public static String extractImage(String imgTag) {

		String url = imgTag.substringBetween('src="', '"');
		return String.isNotBlank(url) ? url : imgTag;
	}

	public static List<SPO_Colors__c> retColorListByName(List<String> colorListNames) {

		return 
			[SELECT Id, Name 
			       ,SPO_Preview__c
			       ,SPO_CodeCouleur__c
			       ,SPO_Description__c
			       ,SPO_Position__c
		      FROM SPO_Colors__c
   			 WHERE Name IN :colorListNames];
	}


	// Upload File Attachment
	@RemoteAction
    public static String doUploadAttachment(String acctId, String attachmentBody, String attachmentName, String attachmentId) {
        if(acctId != null) {
            Account acct = getAccount(acctId);
            if(acct != null) {
                if(attachmentBody != null) {
                    Attachment att = getAttachment(attachmentId);
                    String newBody = '';
                    if(att.Body != null) {
                        newBody = EncodingUtil.base64Encode(att.Body);
                    }
                    newBody += attachmentBody;
                    att.Body = EncodingUtil.base64Decode(newBody);
                    if(attachmentId == null) {
                        att.Name = attachmentName;
                        att.parentId = acct.Id;
                    }
                    upsert att;
                    return att.Id;
                } else {
                    return 'Attachment Body was null';
                }
            } else {
                return 'Account could not be found';
            }
        } else {
            return 'Account Id was null';
        }
    }
     
    @RemoteAction
    public static String doSubmitForm(String acctId, String description, String website, String phone) {
        if(acctId != null) {
            Account acct = getAccount(acctId);
            if(acct != null) {
                acct.Description = description;
                acct.Website = website;
                acct.Phone = phone;
                update acct;
                return 'Success';
            } else {
                return 'Account could not be found';
            }
        } else {
            return 'Account Id was null';
        }
    }
     
    private static Account getAccount(String acctId) {
        list<Account> accounts = [SELECT Id/*, Name*/
                                  FROM Account
                                  WHERE Id =: acctId];
        if(accounts.isEmpty()) {
            return null;
        } else {
            return accounts[0];
        }
    }
     
    private static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body
                                        FROM Attachment 
                                        WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }
	
	// Set role & readonly
    public void getUserRoleAndReadonlyMode(){
        SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
        SO_OrderPageSwitch.LogicalUserRoleEnum role = orderPageSwitch.sfoUserRoleByObject(this.quotationContainer.oneOpportunity);
        this.role = role.name();    		// can be one of: [Store, Production, Other] 
        SO_OrderPageSwitch.LogicalUserRoleEnum baseRole = orderPageSwitch.sfoUserRole;
        this.baseRole = baseRole.name();    // can be one of: [Store, Production, Other]
        System.debug('SO_BriefOrder_CTRL role: '+this.role);
        
        this.isReadonlyMode = SO_OrderPageSwitch.isReadonlyMode();
    }

	public class ColorPicker implements Comparable 
	{
		public String colorCode 		{get; set;}
		public String colorImage		{get; set;}
		public String colorObjName 		{get; set;}
		public String valueInPicklist	{get; set;}
		public Decimal position 		{get; set;}

		public ColorPicker(String colorCode, 
			String colorImage, String colorObjName, 
			String valueInPicklist, Decimal position) 
		{
			this.colorCode 			= colorCode;
			this.colorImage 		= extractImage(colorImage);
			this.colorObjName 		= colorObjName;
			this.valueInPicklist 	= valueInPicklist;
			this.position 			= position;
		}

		public Integer compareTo(Object compareTo) 
		{
			Integer compareToResult = -1;
			ColorPicker otherColor = (ColorPicker)compareTo;

	        if (this.position == otherColor.position) 
	        {
	        	compareToResult = 0;
	        }

	        if (this.position > otherColor.position) 
	        {
	        	compareToResult = 1;
	        }

			if(compareToResult == 0)
			{
				compareToResult = this.colorObjName.compareTo(otherColor.colorObjName);
			}

			return compareToResult;
		}

	}
}