/**
 * This controller take care of the main process in the PSO application.
 * 1. Handle the communication of the process between the main user roles (Store, Production, Other).
 * 2. Handle the qutation process (if with quotation).
 * 3. Hadnle the creation of order items.
 * 4. Handle the order items production.
 * 5. Handle Deposit sent (RMS).
 * 6. Handle get the RMS price (if without quotation).
 * 7. Handle the order items process in Store. 
 ******** Modification History ********
 * 03/10/2016 - MTOU: displaying error message when deposit is greater than total amount
 * 10/10/2016 - MTOU: indicating the current brief status in Session. Otherwise, criterias for displaying or hiding cancel button are not updated
 */
public class SO_BriefOrder_CTRL extends SO_BaseController{ 

 //   private static Map<String, Map<String, String>> preFillFieldsByProductCategory;
    
 //   public SO_IconByTab icons2               {get{
 //           return this.icons;
 //       }}

 //   static
 //   {
 //       preFillFieldsByProductCategory  = new Map<String, Map<String, String>> 
 //       {


 //           SO_PicklistDependency.OPP_LEATHER_GOOD => new Map<String, String> 
 //           {
 //               'Activity__c'               => 'SPO_Activity2__c', //*
 //               'Departement__c'            => 'SPO_Department__c', //*
 //               //'Family__c'                 => 'SPO_FamilyLG__c',
 //               'Group__c'                  => 'SPO_GroupLG__c',
 //               //'MacroFamily__c'            => 'SPO_MacroFamilyLG__c',
 //               'MacroMaterial__c'          => 'SPO_MacroMaterial__c',
 //               'MainGroup__c'              => 'SPO_MainGroupLG__c',
 //               //'Name'                      => 'SPO_Description__c', //*
 //               //'SubFamily__c'              => 'SPO_SubFamilyLG__c',
 //               'SubGroup__c'               => 'SPO_SubGroup__c' //*
 //           },
            
 //           SO_PicklistDependency.OPP_WATCH => new Map<String, String> 
 //           {
 //               'Activity__c'               => 'SPO_Activity2__c', //*
 //               'AestheticLine__c'          => 'SPO_Aestheticline__c', //*
 //               'Departement__c'            => 'SPO_Department__c', //*
 //               //'Family__c'                 => 'SPO_SubFamilyWatchAcc__c',
 //               'Group__c'                  => 'SPO_GroupAccWatch__c',
 //               'MacroFamily__c'            => 'SPO_MacroFamilyWatchAcc__c',
 //               'MainGroup__c'              => 'SPO_MainGroupAccWa__c',
 //               //'Name'                      => 'SPO_Description__c', //*
 //               'SubAestheticLine__c'       => 'SPO_SubAestheticline__c', //*
 //               'SubFamily__c'              => 'SPO_SubFamilyWatchAcc__c',
 //               'SubGroup__c'               => 'SPO_SubGroup__c', //*
 //               //'WatchBraceletmaterial__c'  => 'SPO_StrapMaterial__c',//'SPO_WatchBraceletmaterial__c',
 //               //'WatchStrapsubmaterial__c'  => 'SPO_StrapMainMaterial__c',
 //               'SubDepartment__c'          => 'SPO_SubDepartment__c'
 //           },
            

 //           SO_PicklistDependency.OPP_ACCESSORY => new Map<String, String> 
 //           { 
 //               'Activity__c'               => 'SPO_Activity2__c', //*
 //               'Departement__c'            => 'SPO_Department__c', //*
 //               'Family__c'                 => 'SPO_SubFamilyWatchAcc__c',
 //               'Group__c'                  => 'SPO_GroupAccWatch__c',
 //               //'MacroFamily__c'            => 'SPO_MacroFamilyWatchAcc__c',
 //               'MainGroup__c'              => 'SPO_MainGroupAccWa__c',
 //               //'Name'                      => 'SPO_Description__c', //*
 //               'SubGroup__c'               => 'SPO_SubGroup__c', //*
 //               'MarketingColor__c'         => 'SPO_MarketingColor__c'
         
 //           }
 //       };                
 //   }

 //   private static List<String> moreFieldsToOppThatNotUsedInPageList = new List<String>
 //   {
 //       'Account.LastName',
 //       //'Opportunity.Account',

 //       'OwnerId',
 //       'SPO_OpportunityCloning__c',
 //       // Material & Colors
 //       'Id',
 //       'Name',
 //       'SPO_OrderType__c', 
 //       'SPO_CreationType__c', 
 //       'SPO_Exo__c',

 //       'SPO_Sizewidth__c',
 //       'SPO_SizeLenght__c',
 //       'SPO_SizeHeight__c',
 //       //'SPO_SizewidthCM__c', 
 //       //'SPO_SizeheightCM__c', 
 //       //'SPO_SizelenghtCM__c',
 //       //'SPO_SizeWidthInch__c',
 //       //'SPO_SizeheightInch__c',
 //       //'SPO_SizelenghtInch__c',
 //       'SPO_Sizeunit__c',
 //       'SPO_Activity2__c',
 //       'SPO_Aestheticline__c',
 //       'SPO_Department__c',
 //       'SPO_FamilyLG__c',
 //       'SPO_FamilyWatchAcc__c',
 //       'SPO_Gender__c',
 //       'SPO_GroupLG__c',
 //       'SPO_GroupAccWatch__c',
 //       //'SPO_SizeHeightCM__c',
 //       //'SPO_SizeLenghtCM__c',
 //       'SPO_MainMaterialSAP__c',
 //       'SPO_MacroFamilyLG__c',
 //       'SPO_MacroFamilyWatchAcc__c',
 //       'SPO_MacroMaterial__c',
 //       'SPO_MadeIn__c',
 //       'SPO_MainGroupLG__c',
 //       'SPO_ExteriorMaterial1__c',
 //       'SPO_ManuFacturerProcess__c',
 //       'SPO_Description__c',
 //       'SPO_SubAestheticline__c',
 //       'SPO_SubFamilyLG__c',
 //       'SPO_SubFamilyWatchAcc__c',
 //       'SPO_SubGroup__c',
 //       'SPO_StrapMaterial__c',
 //       'SPO_StrapColor__c',
 //       'SPO_WristSize__c',
 //       'SPO_StrapMainMaterial__c',
 //       //'SPO_SizewidthCM__c',
 //       'SPO_TypeComposition1__c',
 //       'SPO_SalesType__c',
 //       'SPO_ItemDimensionGroupWatch__c',
 //       'SPO_ItemDimensionGroupAcc__c',
 //       'SPO_Item_DimensionGroupLG__c',
 //       'SPO_SubDepartment__c',
 //       'SPO_DisplayOrder__c',
 //       'SPO_ProductCategory__c',
 //       'SPO_CACode__c',
 //       'SPO_SpecialOrderSKUCodeRef__c',

 //       //Product ref parent:
 //       'SPO_BaseSKURefmodelSKU__c', 
 //       'SPO_BaseSKURefmodelSKU__r.Id',
 //       'SPO_BaseSKURefmodelSKU__r.Name',
 //       'SPO_BaseSKURefmodelSKU__r.ProductCategory__c', 
 //       'SPO_BaseSKURefmodelSKU__r.SKUCode__c',
 //       'SPO_BaseSKURefmodelSKU__r.Activity__c',
 //       'SPO_BaseSKURefmodelSKU__r.AestheticLine__c',
 //       'SPO_BaseSKURefmodelSKU__r.Departement__c',
 //       'SPO_BaseSKURefmodelSKU__r.Family__c',
 //       'SPO_BaseSKURefmodelSKU__r.Gender__c',
 //       'SPO_BaseSKURefmodelSKU__r.Group__c',
 //       'SPO_BaseSKURefmodelSKU__r.Height__c',
 //       'SPO_BaseSKURefmodelSKU__r.Length__c',
 //       'SPO_BaseSKURefmodelSKU__r.MacroFamily__c',
 //       'SPO_BaseSKURefmodelSKU__r.MacroMaterial__c',
 //       'SPO_BaseSKURefmodelSKU__r.MadeIn__c',
 //       'SPO_BaseSKURefmodelSKU__r.MainGroup__c',
 //       'SPO_BaseSKURefmodelSKU__r.MainMaterial__c',
 //       'SPO_BaseSKURefmodelSKU__r.ManuFacturerProcess__c',
 //       'SPO_BaseSKURefmodelSKU__r.MarketingColor__c',
 //       'SPO_BaseSKURefmodelSKU__r.SubAestheticLine__c',
 //       'SPO_BaseSKURefmodelSKU__r.SubFamily__c',
 //       'SPO_BaseSKURefmodelSKU__r.SubGroup__c',
 //       'SPO_BaseSKURefmodelSKU__r.Witdth__c',
 //       'SPO_BaseSKURefmodelSKU__r.WatchBraceletmaterial__c',
 //       'SPO_BaseSKURefmodelSKU__r.WatchStrapcolor__c',
 //       'SPO_BaseSKURefmodelSKU__r.WatchStrapsize__c',
 //       'SPO_BaseSKURefmodelSKU__r.WatchStrapsubmaterial__c',
 //       'SPO_BaseSKURefmodelSKU__r.SubDepartment__c',
 //       'SPO_BaseSKURefmodelSKU__r.SPO_ProductNameSKU__c',
        
 //       //material
 //       //1
 //       'SPO_ExteriorMaterial1localcomment__c',
 //       'SPO_ExtMaterial1zoneapprovercomment__c',
 //       'SPO_ExteriorMaterialColor1__c',
 //       'SPO_ExtMaterialColor1localcomment__c',
 //       'SPO_ExtMatColor1zoneapprover__c',
 //       //2
 //       'SPO_ExteriorMaterial2__c',
 //       'SPO_ExteriorMaterial2localcomment__c',
 //       'SPO_ExtMaterial2zoneapprovercomment__c',
 //       'SPO_ExteriorMaterialColor2__c',
 //       'SPO_ExtMaterialColor2localcomment__c',
 //       'SPO_ExtMatColor2zoneapproverCommen__c',
 //       //3
 //       'SPO_ExteriorMaterial3__c',   
 //       'SPO_ExteriorMaterial3localcomment__c',   
 //       'SPO_ExtMaterial3zoneapprovercomment__c',
 //       'SPO_ExteriorMaterialColor3__c',
 //       'SPO_ExtMaterialColor3localcomment__c',
 //       'SPO_ExtMaterialColor3approvercomment__c',
 //       //lining
 //       'SPO_LiningInteriorColor1__c',
 //       'SPO_LiningInteriorMaterial1__c',
 //       'SPO_LiningColor1LocalComment__c',
 //       'SPO_LiningColor1ZoneApproverComment__c',
 //       'SPO_LiningMaterial1LocalComment__c',
 //       'SPO_LiningMaterial1ZoneApproverComment__c',
 //       'SPO_LiningInteriorColor2__c',
 //       'SPO_LiningInteriorMaterial2__c',
 //       'SPO_LiningColor2LocalComment__c',
 //       'SPO_LiningColor2ZoneApproverComment__c',
 //       'SPO_LiningMaterial2LocalComment__c',
 //       'SPO_LiningMaterial2ZoneApproverComment__c',
 //       //metalic parts
 //       'SPO_ColorMetalicparts__c',
 //       'SPO_ColorMetalicPartsLocalComment__c',
 //       'SPO_ColorMetalicPartsZoneApproverComment__c',
 //       //comment
 //       'SPO_CommercialLocalComment__c',
 //       'SPO_CommercialZoneApproverComment__c',
 //       'SPO_InternalWorkshopComment__c',
 //       'SPO_Lock__c',
 //       'SPO_LockNumber__c',
 //       'SPO_Painting__c',
 //       'SPO_PatchFreeText__c',
 //       'SPO_Patch__c',
 //       'SPO_ClientAccessoriesRequested__c',
 //       'SPO_CommentClientAccessories__c',
 //       'SPO_BeltSize__c',
 //       'SPO_DestinationWatch__c',
 //       //'SPO_DestinationWatchDescription__c',
 //       'SPO_StrapMaterialLocalComment__c',
 //       'SPO_StrapMaterialZoneApproverComment__c',
 //       'SPO_StrapColorLocalComment__c',
 //       'SPO_StrapColorZoneApproverComment__c',

 //       //Add by J.C on December 2015
 //       'SPO_BriefCode__c',
 //       'SPO_SpecialOrderSKUCode__c',
 //       'SPO_DepositNumber__c',
 //       'SPO_DepositAmount__c',
 //       'SPO_SkuQuantity__c',
 //       'SPO_StoreCode__c',
 //       'SPO_Free__c',
 //       'SPO_OF__c',
 //       'SPO_RMSClientId__c',
 //       'SPO_BaseSku__c',
 //       'SPO_TotalAmount__c',
 //       'SPO_UnitRetailPrice__c',
 //       'SPO_Number_Of_decimals_Store__c',
 //       //End of J.C modification

 //       'SPO_ZoneApproval__c',
 //       'SPO_CentralApproval__c',
 //       'SPO_MarketingApproval__c'
 //   };

 //   //--------------------------- Private fields --------------
 //   private ApexPages.StandardController stdController;

 //   ////--------------------------- Public fields --------------
 //   public Opportunity opp                      {get; set;}
 //   public List<SPO_FirmOrder__c> firmOrderList {get; set;}
 //   public Id srcObjId                          {get; set;}
 //   public String wishedDate                    {get; set;}
 //   public Boolean hasQuotation                 {get; set;}
 //   public Boolean displayOrder                 {get; set;}
 //   public String role                          {get; set;}
 //   public String baseRole                      {get; private set;}
 //   public Boolean isReadonlyMode               {get; private set;}
 //   public Boolean isEditMode                   {get; private set;}
 //   public Map<String,String> languagesMap      {get; set;}
 //   public List<String> langCodeList            {get; set;}
 //   public List<String> langLabelList           {get; set;}

 //   public Id currentFirmOrderId                {get; set;}
 //   public Boolean isDepositAmountPayment       {get; set;}

 //   public String currentRecordTypeName         {get; private set;}

 //   public Boolean hideCreateOrderInERP         {get; private set;}

 //   public List<orderDetails_Wrapper> firmOrderWrapperList {get; set; }
 //   public Map<Id, List<orderDetailsHistory_Wrapper>> firmOrderHistoryByFirmOrderIdMap {get; private set;}

 //   public boolean orderDetailIsInEditSection {get;set;}

 //   public List<OpportunityHistory> opportunityHistoryList {get;set;}
 //   public Boolean zoneApproval      {get;set;}
 //   public Boolean centralApproval   {get;set;}
 //   public Boolean marketingApproval {get;set;}
 //   public Boolean isShowFirmOrderSection {get;set;}

 //   public Decimal rmsArticlePriceToDisplayNoQuotation {get; private set;}
 //   public Decimal totalAmountToDisplayNoQuotation {get; private set;}

 //   //Check we should call the RMS price WS:
 //   public Boolean isValidForPriceCall
 //   {
 //       get
 //       {
 //           return  this.Opp.StageName == 'Brief in progress' ||
 //                   this.Opp.StageName == 'Quotation in progress' ||
 //                   this.Opp.StageName == 'Quotation submitted' ||
 //                   this.Opp.StageName == 'Quotation accepted';
 //       }
 //       private set;
 //   }
    

   
    
 //   public SO_BriefOrder_CTRL(ApexPages.StandardController stdController){
 //       PageReference pageRef = validateNoBriefIdBase();
 //       if(pageRef == null)
 //       {
 //           this.stdController = stdController; 

 //           if(!Test.isRunningTest())
 //           {
 //               this.stdController.addFields(moreFieldsToOppThatNotUsedInPageList);
 //           }
            
 //           this.srcObjId = stdController.getId();
 //           if(String.isNotEmpty(srcObjId)) {
 //               init();
 //           }
 //           System.debug('SO_BriefOrder_CTRL - constructor eneded');
 //       }

 //   }

 //   public Boolean clickedOnSendToReferential {get; private set;}
 //   public Boolean clickedOnCreateOrderInERP {get; private set;}

 //   public Boolean isZoneApprovalUser { 
	//	get {return SO_Util.isZoneApprovalUser();}
	//}
    
 //   public Boolean isCRUDSectionPricesOpportunitiesUser { 
	//	get {return SO_Util.isCRUDSectionPricesOpportunitiesUser();}
	//}
    

 //   //override public Boolean getHasCancelButton()
 //   //{
 //   //    Boolean ans = false;
 //   //    if(this.firmOrderList != null)
 //   //    {
 //   //        for(SPO_FirmOrder__c firmOrder : this.firmOrderList)
 //   //        {
 //   //            if(firmOrder.SPO_FirmOrderStatus__c != SO_BaseController.FIRM_ORDER_CANCEL_STATUS)
 //   //            {
 //   //                ans = true;
 //   //                break;
 //   //            }
 //   //        }
 //   //    }
 //   //    return ans && super.getHasCancelButton();
 //   //}

	//////--------------------------- Public methods --------------
 //   override public void init()
 //   {
 //       try
 //       {
 //           this.opp = (Opportunity)this.stdController.getRecord();
 //           this.wishedDate = this.opp.SPO_WishedDate__c != null ? this.opp.SPO_WishedDate__c.format() : this.wishedDate;

 //           getUserRoleAndReadonlyMode();
 //           this.initOpportunityHistoryList();
 //           this.initApprovalBooleanVars();
 //           retFirmOrders();

 //           SO_Session.SessionState ss = SO_Session.retSessionState();
 //           this.displayOrder = ss.displayOrder;
 //           this.isEditMode = false;
            
 //           // Case without quotation?
 //           this.hasQuotation = !SO_OrderPageSwitch.isWithoutQuotation();

 //           preFillFieldsForReferentialSection();
 //           setLanguages();
 //           initIsDepositAmountPayment(opp);
 //           this.currentRecordTypeName = SO_PicklistDependency.retOppRecordTypeByProdCat(this.opp.SPO_ProductCategory__c);
 //           this.hideCreateOrderInERP = true;

 //           buildMixHistoryForEachFirmOrder();
            
 //           this.clickedOnSendToReferential = false;
 //           this.clickedOnCreateOrderInERP = false;
 //           showFirmOrderSection();

 //           initPriceSectionNoQuotation();

 //           // Added by MTOU
 //           this.opp.SPO_SalesType__c = retrievePicklistDefaultValues('SPO_SalesType__c');
 //           this.opp.SPO_Activity2__c = retrievePicklistDefaultValues('SPO_Activity2__c');
 //           this.opp.SPO_Department__c = retrievePicklistDefaultValues('SPO_Department__c');
 //           // Begin MTOU - 20/12/2016 - id #83 
 //           if(this.opp.SPO_ProductCategory__c == SO_PicklistDependency.OPP_ACCESSORY)
 //           {
 //               this.opp.SPO_ManuFacturerProcess__c = retrievePicklistDefaultValues('SPO_ManuFacturerProcess__c');
 //           }
 //          // End MTOU

 //       }
 //       catch(Exception ex){SO_UTIL.addErrorMessage(ex);}

 //   }

 //   /**
 //    * Article price implementation
 //    * The Article Price will be automatically retrieved on the page loading at every Brief Order steps explained above. It is known that this automated flow will slow down the page loading on every steps above.
 //    * The only case requesting an automated importation of the price is the next, in any other cases, the price will be manually entered by the User:
 //    *  -    Brief Order’s field “SPO_ProductCategory__c” equals ‘Leather goods’
 //    *     AND
 //    *  -    Brief Order’s field “SPO_OrderType__c” equals  'Hardsided out of MyPerso
 //    */
 //   @RemoteAction
 //   public static String remoteRetreiveArticleRMSPrice(Decimal unitRetailPrice, String storeCode, String baseSKU)
 //   {
 //       RMSPriceResponse res = new RMSPriceResponse();
 //       try
 //       {
 //           SO_RetreiveArticlesPriceRMS_Utils.SO_ArticlePriceResults calloutResult = SO_RetreiveArticlesPriceRMS_Utils.RetrieveArticlePriceFromRMS(storeCode, baseSKU);
 //           System.debug('SFDC remoteRetreiveArticleRMSPrice calloutResult: ' + calloutResult);
            
 //           if( calloutResult != null && 
 //               calloutResult.calloutFinalArticlePrice != null && 
 //               calloutResult.calloutNumberOfDeciamls != null)
 //           {
 //               /*if(unitRetailPrice != Decimal.ValueOf(calloutResult.calloutFinalArticlePrice))
 //               {*/
 //                   res.unitRetailPrice = Decimal.ValueOf(calloutResult.calloutFinalArticlePrice);
 //                   res.numberOfDecimalsStore = Decimal.ValueOf(calloutResult.calloutNumberOfDeciamls);
 //               //}
 //           }
 //           system.debug('remoteRetreiveArticleRMSPrice res: ' + res);
 //       }
 //       catch(SO_UTIL.RMSException exp) 
 //       {
 //           System.debug('SO_BriefOrder - remoteRetreiveArticleRMSPrice - RMSException: ' + exp);
 //           res.errorMessage = exp.getMessage();
 //           res.errorCode = 2;
 //           res.isValid = false;
 //       }
 //       catch (Exception exp) 
 //       {
 //           System.debug('SO_BriefOrder - remoteRetreiveArticleRMSPrice - Exception: ' + exp);
 //           res.errorMessage = exp.getMessage();
 //           res.errorCode = 1;
 //           res.isValid = false;
 //       }

 //       return JSON.serialize(res);
 //   }

 //   private class RMSPriceResponse
 //   {
 //       public Decimal unitRetailPrice                      {get; set;}
 //       public Decimal numberOfDecimalsStore                {get; set;}
 //       public String  errorMessage                         {get; set;}
 //       public Integer errorCode                            {get; set;}
 //       public Boolean isValid                              {get; set;}

 //       public RMSPriceResponse()
 //       {
 //           this.unitRetailPrice = 0;
 //           this.numberOfDecimalsStore = 0;
 //           this.isValid = true;
 //       }
 //   }

 //   private void initPriceSectionNoQuotation()
 //   {
 //       if(this.opp.SPO_UnitRetailPrice__c != Null && this.opp.SPO_Number_Of_decimals_Store__c != Null){
 //           this.rmsArticlePriceToDisplayNoQuotation = this.opp.SPO_UnitRetailPrice__c.setScale(Integer.ValueOf(this.opp.SPO_Number_Of_decimals_Store__c));
 //           this.totalAmountToDisplayNoQuotation = this.opp.SPO_TotalAmount__c;
 //       }
 //   }

 //   private void reCalculatePricesSection()
 //   {
 //       Opportunity opWithPricesFormlas = new Opportunity();
 //       opWithPricesFormlas.Id = this.opp.Id;
 //       opWithPricesFormlas.SPO_UnitRetailPrice__c = this.opp.SPO_UnitRetailPrice__c;
 //       opWithPricesFormlas.RecalculateFormulas();
 //       this.totalAmountToDisplayNoQuotation = opWithPricesFormlas.SPO_TotalAmount__c;
 //   }

 //   private void initApprovalBooleanVars()
 //   {
 //       if(this.opp != null)
 //       {
 //       //  this.zoneApproval = false;
 //           if(this.opp.SPO_ZoneApproval__c != null)
 //           {
 //               if(this.opp.SPO_ZoneApproval__c == 'Yes') 
 //               {
 //                   this.zoneApproval = true;
 //               }
 //           }

 //           //this.centralApproval = false;
 //           if(this.opp.SPO_CentralApproval__c != null)
 //           {
 //               if(this.opp.SPO_CentralApproval__c == 'Yes') 
 //               {
 //                   this.centralApproval = true;
 //               }
 //           }

 //           //this.marketingApproval = false;
 //           if(this.opp.SPO_MarketingApproval__c != null)
 //           {
 //               if(this.opp.SPO_MarketingApproval__c == 'Yes') 
 //               {
 //                   this.marketingApproval = true;
 //               }
 //           }

 //       }
 //   }

 //   private void updateOppByApprovalBoolean()
 //   {
 //       if(this.opp != null)
 //       {
 //           //No Yes

 //           if(this.zoneApproval != null)
 //           {
 //               if(this.zoneApproval)
 //               {
 //                   this.opp.SPO_ZoneApproval__c = 'Yes';
 //               }
 //               else
 //               {
 //                   this.opp.SPO_ZoneApproval__c = 'No';
 //               }
 //           }
 //           if(this.centralApproval != null)
 //           {
 //               if(this.centralApproval)
 //               {
 //                   this.opp.SPO_CentralApproval__c = 'Yes';
 //               }
 //               else
 //               {
 //                   this.opp.SPO_CentralApproval__c = 'No';
 //               }
 //           }

 //           if(this.marketingApproval != null)
 //           {
 //               if(this.marketingApproval)
 //               {
 //                   this.opp.SPO_MarketingApproval__c = 'Yes';
 //               }
 //               else
 //               {
 //                   this.opp.SPO_MarketingApproval__c = 'No';
 //               }
 //           }
 //       }
 //   }

 //   /**
 //    * Handle the zone checkbox auto save.
 //    */
 //   public PageReference zoneApprovalClick()
 //   {
 //       System.debug('SO_BriefOrder_CTRL - zoneApprovalClick - click:');
 //       try
 //       {
 //           updateOppByApprovalBoolean();
 //           update this.opp;
 //       }catch(DmlException ex){
 //            System.debug('The following exception has occurred: ' + ex.getMessage());

 //       }
 //       return null;    
 //   }

 //   private void initOpportunityHistoryList()
 //   {
 //       System.debug('opportunityHistoryList' );
 //       opportunityHistoryList = new List<OpportunityHistory>();
 //       System.debug('this.opp '+ this.opp);
 //           System.debug('In the IF' + this.opp != null && this.opp.id != null);
 //       if(this.opp != null && this.opp.id != null)
 //       {
 //           System.debug('In the IF' );
 //           opportunityHistoryList = [SELECT CreatedBy.Name, StageName, Probability, CreatedDate
 //                                     FROM OpportunityHistory
 //                                     WHERE OpportunityId =: this.opp.id
 //                                     ];

 //       }
 //       System.debug('opportunityHistoryList : ' + opportunityHistoryList );
 //   }

 //   public PageReference refreshOpportunityHistoryList()
 //   {
 //       try{
 //           initOpportunityHistoryList();    
 //       } catch (Exception ex) {
 //           SO_UTIL.addErrorMessage(ex);
 //       }

 //       return null;
        
 //   }



 //   private void initIsDepositAmountPayment(Opportunity opp)
 //   {
 //       //if true   - DepositAmount is payment - defualt value should be 50% 0f total amount
 //       //otherwise -  0€ by default in a process without paiement

 //       isDepositAmountPayment =  
 //               (
 //                   (opp.SPO_ProductCategory__c == SO_PicklistDependency.OPP_LEATHER_GOOD && opp.SPO_DisplayOrder__c == false && 
 //                       (opp.SPO_OrderType__c ==  SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER || opp.SPO_OrderType__c ==  SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG) 
 //                   )
 //                   ||
 //                   (opp.SPO_ProductCategory__c == SO_PicklistDependency.OPP_WATCH && opp.SPO_OrderType__c ==  SO_PicklistDependency.ORDER_TYPE_SPO_MTO)
 //                   ||
 //                   (opp.SPO_ProductCategory__c ==  SO_PicklistDependency.OPP_ACCESSORY && opp.SPO_OrderType__c ==  SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER)
 //               );
 //   }

 //   /**
 //    * Call the RMS service in order to validate the CA code.
 //    */
 //   public Boolean validateCaCodeWS()
 //   {
 //       Boolean caValidationWsResult = true;
 //       //try{
 //           System.debug('SFDC validateCaCodeWS');

 //           System.debug('SFDC this.opp.SPO_CACode__c: ' + this.opp.SPO_CACode__c);
 //           System.debug('SFDC SO_Session.theCurrentBrief.SPO_CACode__c: ' + SO_Session.theCurrentBrief.SPO_CACode__c);
 //           System.debug('SFDC SO_Session.theCurrentBrief.SPO_StoreCode__c: ' + SO_Session.theCurrentBrief.SPO_StoreCode__c);
 //           if(this.opp.SPO_CACode__c != SO_Session.theCurrentBrief.SPO_CACode__c){
 //               if(this.opp.SPO_CACode__c != Null && this.opp.SPO_Store__c != Null){
 //                   SO_ClientAdvisorEnquiryRMS_Utils.SO_ClientAdvisorEnquiryResults calloutResult = SO_ClientAdvisorEnquiryRMS_Utils.VerifyClientAdvisorEnquiryRMS(this.opp.SPO_CACode__c, this.opp.SPO_StoreCode__c);
 //                   caValidationWsResult = calloutResult.calloutSuccessResult;
 //               }
 //           }
 //       //}
 //       //catch(SO_UTIL.RMSException exp) 
 //       //{
 //       //    this.showMessageOnTop = true;
 //       //    system.debug('SO_UTIL.addErrorMessage ' + exp);
 //       //    SO_UTIL.addErrorMessage(exp);
 //       //}
 //       System.debug('SO_BriefOrder_CTRL - validateCaCodeWS - caValidationWsResult: ' + caValidationWsResult);
 //       return caValidationWsResult;
 //   }


 //   private void preFillFieldsForReferentialSection()
 //   {
 //       if(this.opp.StageName == 'Deposit sent' &&
 //           this.role == SO_OrderPageSwitch.LogicalUserRoleEnum.Production.name() &&
 //           preFillFieldsByProductCategory.containsKey(this.opp.SPO_ProductCategory__c))
 //       {
 //           this.opp.SPO_Description__c = this.opp.Name;
 //           ProductReferential__c soProductRef = this.opp.SPO_BaseSKURefmodelSKU__r;
 //           Map<String, String> preFillFieldsOfThisProductCategory = preFillFieldsByProductCategory.get(this.opp.SPO_ProductCategory__c);
 //           for(String productRefField : preFillFieldsOfThisProductCategory.keySet())
 //           {
 //               Object productRefValue = soProductRef.get(productRefField);
 //               this.opp.put(preFillFieldsOfThisProductCategory.get(productRefField), productRefValue);
 //           }
 //       }
 //   }

 //   /**
 //    * Check the validation of page in terms of user roles and rules.
 //    */
 //   public PageReference validateEnterance() 
 //   {
 //       PageReference pageRef = null;        // Redirect user if cloning brief
 //       try 
 //       {
 //           pageRef = validateNoBriefIdBase();
 //           if(pageRef == null)
 //           {
 //               SO_Session.SessionState ss = SO_Session.retSessionState();
 //               if(null == this.opp.SPO_BaseSKURefmodelSKU__c) 
 //               {
 //                   pageRef = Page.SO_ProductSearch;
 //                   pageRef.getParameters().put('bid', SO_Session.currentBriefId);
 //               } 
 //               else if(! this.opp.SPO_DisplayOrder__c && null == this.opp.AccountId) 
 //               {
 //                   pageRef = Page.SO_ClientSearch;
 //                   pageRef.getParameters().put('bid', SO_Session.currentBriefId);
 //               }
 //               else if(!ss.isProductReady)
 //               {
 //                   pageRef = Page.SO_ProductSpe;
 //                   pageRef.getParameters().put('id', SO_Session.currentBriefId);
 //               }
 //           } 
 //       }
 //       catch(Exception exp) 
 //       {
 //           SO_UTIL.addErrorMessage(exp);
 //           pageRef = null;
 //       }
 //       return pageRef;
 //   }

 //   /**
 //    * Check if fields in page should be in read only mode according to the user roles and opp stage.
 //    */
 //   public void getUserRoleAndReadonlyMode(){
 //       SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
 //       SO_OrderPageSwitch.LogicalUserRoleEnum role = orderPageSwitch.sfoUserRoleByObject(this.opp); 
 //       this.role = role.name();    // can be one of: [Store, Production, Other]
 //       SO_OrderPageSwitch.LogicalUserRoleEnum baseRole = orderPageSwitch.sfoUserRole;
 //       this.baseRole = baseRole.name();    // can be one of: [Store, Production, Other]
 //       System.debug('SO_BriefOrder_CTRL role: '+this.role);
 //       // Set role & readonly
 //       this.isReadonlyMode = SO_OrderPageSwitch.isReadonlyMode();
 //   }

 //   //public void freeClick(){
 //   //    try{
 //   //        this.opp.SPO_Free__c = !this.opp.SPO_Free__c;
 //   //        if (this.opp.SPO_Free__c){
 //   //            // set to zero, render 2 fields
 //   //            this.opp.SPO_DepositAmount__c = 0;
 //   //
 //   //            //SPO_TotalAmount__c = 0, how ? | SPO_TotalAmount__c formula is:(SPO_SkuQuantity__c * SPO_UnitRetailPrice__c)
 //   //        }
 //   //        update this.opp;
 //   //    }catch(Exception ex){
 //   //        System.debug(ex);
 //   //    }
 //   //}

 //   public void updateBrief()
 //   {
 //       System.debug('SO_BriefOrder_CTRL - updateBrief - click');

 //       this.showMessageOnTop = false;

 //       if (role == 'Production' && 'Deposit sent;Creation in progress;In progress;Payment confirmed;Closed Won;Cancelled by store;Cancelled by Production'.contains (opp.StageName))
 //       {
 //           List<String> missingFields = validateReadOnlyFields();
 //           if (!missingFields.isEmpty()) 
 //           {
 //               System.debug (missingFields);

 //               this.showMessageOnTop = true;
 //               SO_UTIL.addErrorMessage('The following fields are required : ' + String.join(missingFields, ', '));
 //           }
 //       }
        
        

 //       try
 //       {
 //           if( SO_UTIL.dateStringIsValid(this.wishedDate) ) {     
 //               this.opp.SPO_WishedDate__c = SO_UTIL.transformDateStringToDateFormat(this.wishedDate);
 //           }

 //           update this.opp; 
 //       }
 //       catch(Exception ex)
 //       {
 //           this.showMessageOnTop = true;
 //           SO_UTIL.addErrorMessage(ex);
 //       }
 //   }

 //   public void requestQuotation()
 //   {
 //       System.debug('SO_BriefOrder_CTRL - requestQuotation - click');

 //       this.showMessageOnTop = false;
 //       try
 //       {
 //           //if(validateCaCodeWS()){
 //               // if 'Free' checkbox is checked - this rule does not make any sense...
 //               //if (this.opp.SPO_Free__c){
 //               //    // zero the unit price
 //               //    this.opp.SPO_UnitRetailPriceQuotation__c = 0;
 //               //    this.opp.SPO_UnitRetailPrice__c = 0;
 //               //}
                

 //               //Opportunity.SPO_WishedDate__c convert to real Date variable
 //               //Date wishedDateTemp;
 //               if( SO_UTIL.dateStringIsValid(this.wishedDate) ) {     
 //                   this.opp.SPO_WishedDate__c = SO_UTIL.transformDateStringToDateFormat(this.wishedDate);
 //               }

 //               this.opp.StageName = 'Quotation in progress';
 //               if(this.hasQuotation == false)
 //               {
 //                   this.opp.StageName = 'Quotation accepted';
 //               }

 //               update this.opp;
 //           //}
 //       }
 //       //catch(SO_UTIL.RMSException exp) 
 //       //{
 //       //    this.showMessageOnTop = true;
 //       //    system.debug('SO_UTIL.addErrorMessage ' + exp);
 //       //    SO_UTIL.addErrorMessage(exp);
 //       //}  
 //       catch(Exception ex){SO_UTIL.addErrorMessage(ex);}

 //       updateIcons();
 //   }

 //   //public void rejectQuotation(){
 //   //    System.debug('SO_BriefOrder_CTRL - rejectQuotation - click');
 //   //    try{
 //   //        this.opp.StageName = 'Quotation rejected';
 //   //        update this.opp;
 //   //    }catch(Exception ex){
 //   //        SO_UTIL.addErrorMessage(ex);
 //   //    }
 //   //    updateIcons();
 //   //}

 //   public void acceptQuotation()
 //   {
 //       System.debug('SO_BriefOrder_CTRL - acceptQuotation - click');
 //       this.showMessageOnTop = false;
 //       try
 //       {
 //           //if(validateCaCodeWS()){
 //               this.opp.StageName = 'Quotation accepted';
 //               update this.opp;
 //           //}
 //       }
 //       //catch(SO_UTIL.RMSException exp) 
 //       //{
 //       //    this.showMessageOnTop = true;
 //       //    system.debug('SO_UTIL.addErrorMessage ' + exp);
 //       //    SO_UTIL.addErrorMessage(exp);
 //       //}
 //       catch(Exception ex){SO_UTIL.addErrorMessage(ex);}

 //       updateIcons();
 //   }

 //   public PageReference createQuotation()
 //   {
 //       System.debug('SO_BriefOrder_CTRL - createQuotation - click');

 //       this.showMessageOnTop = false;
 //       try
 //       {
 //           //if(validateCaCodeWS()){
 //               this.opp.StageName = 'Quotation submitted';
 //               update this.opp;
 //               resetStdController();
 //           //}
 //       }
 //       //catch(SO_UTIL.RMSException exp) 
 //       //{
 //       //    this.showMessageOnTop = true;
 //       //    system.debug('SO_UTIL.addErrorMessage ' + exp);
 //       //    SO_UTIL.addErrorMessage(exp);
 //       //}
 //       catch(Exception ex){SO_UTIL.addErrorMessage(ex);}

 //       updateIcons();
        
 //       return null;
 //   }


 //   public PageReference updateQuotation()
 //   {
 //       System.debug('SO_BriefOrder_CTRL - updateQuotation - click');
          
 //       this.showMessageOnTop = false;
 //       try
 //       {
 //           //if(validateCaCodeWS())
 //           //{
 //               System.debug('SO_BriefOrder_CTRL - updateQuotation - this.opp.SPO_UnitRetailPriceQuotation__c: ' + this.opp.SPO_UnitRetailPriceQuotation__c);
 //               update this.opp;
 //               this.isEditMode = false;
 //               resetStdController();
 //               System.debug('SO_BriefOrder_CTRL - updateQuotation - this.opp.SPO_UnitRetailPriceQuotation__c: ' + this.opp.SPO_UnitRetailPriceQuotation__c);
 //           //}
 //       }
 //       //catch(SO_UTIL.RMSException exp) 
 //       //{
 //       //    this.showMessageOnTop = true;
 //       //    system.debug('SO_UTIL.addErrorMessage ' + exp);
 //       //    SO_UTIL.addErrorMessage(exp);
 //       //}
 //       catch(Exception ex){SO_UTIL.addErrorMessage(ex);}

 //       return null;
 //   }

 //   public PageReference editQuotation()
 //   {
 //       System.debug('SO_BriefOrder_CTRL - editQuotation - click');

 //       this.isEditMode = true;
 //       return null;        
 //   }


 //   public PageReference cloning()
 //   {
 //       PageReference pageRef = null;

 //       try
 //       {
 //           //this.opp.CreatedDate = Datetime.now();
 //           //this.opp.SPO_WishedDate__c = Date.today();

 //           //if(validateCaCodeWS()){
 //               Opportunity clonedOpp = this.opp.clone(false, true);
 //               clonedOpp.StageName = SO_Settings__c.getValues(SO_UTIL.NEW_OPPORTUNITY_STAGENAME_SETTINGS_NAME).Value__c;//SO_OrderPageSwitch.CREATION_IN_PROGRESS;
 //               clonedOpp.CloseDate = Date.today().addDays(Integer.valueOf(SO_Settings__c.getValues(SO_UTIL.NEW_OPPORTUNITY_CLODEDATE_SETTINGS_NAME).Value__c));
 //               clonedOpp.SPO_OpportunityCloning__c = true;
 //               clonedOpp.StageName = 'Brief in progress';      //?

 //               // remove Quote info
 //               clonedOpp.SPO_EstimatedProductionTimeMonths__c = null;
 //               clonedOpp.SPO_Numberofproductivehours__c = null;
 //               clonedOpp.SPO_ExportPrice__c = null;
 //               clonedOpp.SPO_CRS__c = null;
 //               clonedOpp.SPO_ProductionQuoteComment__c = null;
 //               clonedOpp.SPO_ZoneApproverQuoteComment__c = null;
 //               clonedOpp.SPO_RejectQuotationComment__c = null;

 //               //clonedOpp.SPO_DepositSentStatusDate__c = ?
 //               //clonedOpp.SPO_WishedDate__c = ?
 //               insert clonedOpp;

 //               pageRef = Page.SO_ProductSpe;
 //               pageRef.getParameters().put('id', clonedOpp.Id);
 //               //pageRef = pageRef.setRedirect(true);

                
 //               List<Attachment> copiedAttachList = new List<Attachment>();
 //               for(Attachment attachSrc : [SELECT Id, Name, ContentType, CreatedDate, Description, Body 
 //                                           FROM Attachment
 //                                           WHERE ParentId =: this.opp.Id])
 //               {
 //                   //System.debug('attachSrc: ' + attachSrc);
 //                   Attachment attachCopy = attachSrc.clone(false, true);
 //                   //attachCopy.Body = attachSrc.Body;
 //                   attachCopy.ParentId = clonedOpp.Id;
 //                   //System.debug('attachCopy: ' + attachCopy);
 //                   copiedAttachList.add(attachCopy);
 //               }
 //               //System.debug('SO_BriefOrder_CTRL - cloning -  copiedAttachList:' + copiedAttachList);
 //               insert copiedAttachList;
                
 //           //}
 //       }
 //       //catch(SO_UTIL.RMSException exp){
 //       //    this.showMessageOnTop = true;
 //       //    system.debug('SO_UTIL.addErrorMessage ' + exp);
 //       //    SO_UTIL.addErrorMessage(exp);
 //       //}
 //       catch(Exception ex){SO_UTIL.addErrorMessage(ex);}

 //       return pageRef;
 //   }

 //   /**
 //    * Add deposit button logic:
 //    * 0. Make sure the deposit is not greater than the total amount // added by MTOU
 //    * 1. Validate the CA code.
 //    * 2. If this process is not Displya Order and not Free (gift checkbox checked) and the deposit amount is not blank, we call the Depost RMS service.
 //    * 3. Create all order items (firm order object) one for each quantity (Quantity = 3 ==> 3 firm orders).
 //    * 4. Pre filled fields for the referential section (for production view).
 //    */
 //   public PageReference addDeposit()
 //   {
 //       System.debug('SO_BriefOrder_CTRL - addDeposit - click');

 //       this.showMessageOnTop = false;

 //       // Added by MTOU - 03/10/2016
 //       if((!this.hasQuotation && this.opp.SPO_DepositAmount__c > this.opp.SPO_UnitRetailPrice__c*this.opp.SPO_SkuQuantity__c) || (this.hasQuotation && this.opp.SPO_DepositAmount__c > this.opp.SPO_TotalAmount__c) )
 //       {
 //           this.showMessageOnTop = true;
 //           SO_UTIL.addErrorMessage(Label.LV_SO_AddDepositError2); // display error message when deposit amount is greater than the total amout
 //       }
 //       // end MTOU
 //       else
 //       {
 //           initPriceSectionNoQuotation();
 //           try
 //           {
 //               if(validateCaCodeWS())
 //               {               
 //                   /**
 //                    * Added by J.C on December 2015
 //                    * The function launch a Web Service to create A deposit into the RMS and return back his ID.
 //                    * If the Callout succeed we continue, otherwise the Error message is shown to the User and the flow can't go on.
 //                    *
 //                    * ! In case of the Opp SPO_DisplayOrder__c being true or SPO_Free__c being true, we continue to the next step without the WS.
 //                    */
 //                   String depositRmsId = null;

 //                       if(this.opp.SPO_DisplayOrder__c == false 
 //                           && this.opp.SPO_Free__c == false 
 //                           && this.opp.SPO_DepositAmount__c != null 
 //                           )
 //                       {
 //                           System.debug('SO_BriefOrder_CTRL - addDeposit - inside deposit RMS');
 //                           SO_Session.theCurrentBrief.SPO_DepositAmount__c = this.opp.SPO_DepositAmount__c;
 //                           SO_Session.theCurrentBrief.SPO_caCode__c = this.opp.SPO_caCode__c;
 //                           SO_CreateDepositPaymentRMS_Utils.SO_CreateUpdateRmsDepositPaymentResult calloutResult = SO_CreateDepositPaymentRMS_Utils.CreateDepositOrPaymentIntoRMS(false);
 //                           System.debug('SO_BriefOrder_CTRL - addDeposit - calloutResult = '+calloutResult);
                            
 //                           if(calloutResult != null && calloutResult.CalloutSuccessResult == true && calloutResult.CalloutdepositPaymentRmsId != null)
 //                           {
 //                               depositRmsId = calloutResult.CalloutdepositPaymentRmsId;
 //                           }
 //                       }

 //                       if( depositRmsId != null 
 //                           || this.opp.SPO_DisplayOrder__c == true 
 //                           || this.opp.SPO_Free__c == true)
 //                       {
 //                           System.debug('SO_BriefOrder_CTRL - addDeposit - inside process create firm orders:');
 //                           List<SPO_FirmOrder__c> foList = new List<SPO_FirmOrder__c>();
 //                           for (Integer i = 0; i < this.opp.SPO_SkuQuantity__c; i++)
 //                           {
 //                               foList.add(new SPO_FirmOrder__c(SPO_BriefName__c = this.opp.Id, LineNumber__c = i));
 //                           }
 //                           insert foList;

 //                           this.opp.StageName = 'Deposit sent'; // TODO for SPO V2: change the 2 lines by 'Creation in progress'
 //                           SO_Session.theCurrentBrief.StageName = 'Deposit sent'; // added by MTOU: indicating the current brief status in order to refresh the cancel button display criterias
 //                           this.opp.SPO_DepositNumber__c = depositRmsId;
 //                           update this.opp;

 //                           retFirmOrders();
 //                           preFillFieldsForReferentialSection();
 //                           resetStdController();

 //                           if(this.hasQuotation == false)
 //                           {
 //                               reCalculatePricesSection();
 //                           }
 //                       }
 //                   //}


 //               }
 //               else
 //               {
 //                   this.showMessageOnTop = true;
 //                   SO_UTIL.addErrorMessage(Label.LV_SO_AddDepositError);
 //               }
 //           }
 //           catch(SO_UTIL.RMSException exp) 
 //           {
 //               this.showMessageOnTop = true;
 //               SO_UTIL.addErrorMessage(exp);
 //           }
 //           catch (Exception ex) {
 //               this.showMessageOnTop = true;
 //               SO_UTIL.addErrorMessage(ex);
 //           }

 //           updateIcons();
 //       }


 //       return null;
 //   }

 //   /**
 //    * Check if the firm order section should appear, init the buttons click visibilty for Send to Ref and Create order in ERP.
 //    */
 //   private void showFirmOrderSection(){
 //       this.isShowFirmOrderSection = false;

 //       //New process you can move to the next stage by clicking on Create Order in ERP and then Send to Referential or the opposite:
 //       if(this.clickedOnSendToReferential == true || this.clickedOnCreateOrderInERP == true)
 //       {
 //           this.isShowFirmOrderSection = this.clickedOnSendToReferential && this.clickedOnCreateOrderInERP;
 //       }
 //       else
 //       {
 //           Map<Id, SPO_FirmOrder__c> firmOrdersMap = new Map<Id, SPO_FirmOrder__c>(this.firmOrderList);
 //           for(SPO_FirmOrder__History spo_fh : [SELECT Id, CreatedDate, Field, NewValue, OldValue, ParentId 
 //                                                                        FROM SPO_FirmOrder__History 
 //                                                                        WHERE ParentId IN :firmOrdersMap.keySet() AND Field = 'SPO_Substatus__c'
 //                                                                        ORDER BY CreatedDate])
 //           {
 //               if(spo_fh.NewValue == 'Codification' || spo_fh.OldValue == 'Codification')
 //               {
 //                   this.clickedOnSendToReferential = true;
 //               }
 //               if(spo_fh.NewValue == 'Technical data' || spo_fh.OldValue == 'Technical data')
 //               {
 //                   this.clickedOnSendToReferential = true;
 //                   this.clickedOnCreateOrderInERP = true;
 //               }
 //               if(this.clickedOnSendToReferential == true && this.clickedOnCreateOrderInERP == true)
 //               {
 //                   this.isShowFirmOrderSection = true;
 //                   break;
 //               }
 //           }
 //       }

 //       //Old process when the Create Order in ERP button was the last button you clicked on:
 //       //if(this.firmOrderList != null && this.firmOrderList.size() > 0){
 //       //    for(SPO_FirmOrder__c firmOrder : this.firmOrderList){
 //       //        if(firmOrder.SPO_FirmOrderStatus__c != null &&
 //       //            firmOrder.SPO_Substatus__c != 'Codification'){
 //       //            this.isShowFirmOrderSection = true;
 //       //            break;
 //       //        }
 //       //    }
 //       //}
 //   }

 //   public static Map<String, List<String>> mapRequiredReadOnlyFields = new Map<String, List<String>> 
 //   {
 //       SO_PicklistDependency.OPP_LEATHER_GOOD => new List<String>  {'SPO_GroupLG__c',
 //                                                                   'SPO_MainGroupLG__c',
 //                                                                   'SPO_SubFamilyLG__c',
 //                                                                   'SPO_FamilyLG__c',
 //                                                                   'SPO_MacroFamilyLG__c',
 //                                                                   'SPO_Item_DimensionGroupLG__c'},
	
 //       SO_PicklistDependency.OPP_WATCH => new List<String>         {'SPO_GroupAccWatch__c',
 //                                                                   'SPO_MainGroupAccWa__c',
 //                                                                   'SPO_SubFamilyWatchAcc__c',
 //                                                                   'SPO_FamilyWatchAcc__c',
 //                                                                   'SPO_MacroFamilyWatchAcc__c',
 //                                                                   'SPO_ItemDimensionGroupWatch__c'},

 //       SO_PicklistDependency.OPP_ACCESSORY => new List<String>     {'SPO_GroupAccWatch__c',
 //                                                                   'SPO_MainGroupAccWa__c',
 //                                                                   'SPO_SubFamilyWatchAcc__c',
 //                                                                   'SPO_FamilyWatchAcc__c',
 //                                                                  	'SPO_MacroFamilyWatchAcc__c',
 //                                                                   'SPO_ItemDimensionGroupWatch__c'}
 //   };

 //   public List<String> validateReadOnlyFields ()
 //   {
 //       List<String> missingFields = new List<String>();
        
 //       if (opp.SPO_ProductCategory__c == SO_PicklistDependency.OPP_LEATHER_GOOD)
 //       {

 //       	for (String f : mapRequiredReadOnlyFields.get(opp.SPO_ProductCategory__c))
 //       	{
            
            
 //          	 	System.debug (f + ' => ' + opp.get(f));
 //           	if (opp.get(f) == null)
 //               missingFields.add (Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get(f).getDescribe().getLabel());
       		 
            
 //       }
 //       }
 //       return missingFields;
        
 //   }

 //   public PageReference sendToReferential() 
 //   {
 //       System.debug('SO_BriefOrder_CTRL - sendToReferential - click');
        
 //       this.showMessageOnTop = false;

 //       /*16/11/2016: deactivated by MTOU: not tested by LV*/
 //       List<String> missingFields = validateReadOnlyFields();

 //      	 	if (!missingFields.isEmpty())
 //      	 	{
 //          		 System.debug (missingFields);

 //           	this.showMessageOnTop = true;
 //           	SO_UTIL.addErrorMessage('The following fields are required : ' + String.join(missingFields, ', '));

 //               return null;
 //       	}
      

 //       try
 //       {
 //           //if(validateCaCodeWS()){
 //               this.retFirmOrders();

 //               String skuCode = getSKUCode(this.opp.SPO_SpecialOrderSKUCodeRef__c);
 //               this.opp.SPO_SpecialOrderSKUCode__c = skuCode;
 //               this.opp.StageName = 'Creation in progress';
 //               this.opp.SPO_TechMailToreferential__c = true;

 //               for (SPO_FirmOrder__c fo : this.firmOrderList) {
 //                   fo.SPO_FirmOrderStatus__c = 'Creation in progress';
 //                   fo.SPO_Substatus__c       = 'Codification';
 //                   //Added by J.C on January 16 due to a ticket request
 //                   //fo.SPO_TechETLStatus__c   = 'A';
 //                   //End of J.C modification
 //               }

 //               update this.opp;
 //               update this.firmOrderList;

 //               getUserRoleAndReadonlyMode();
 //               this.clickedOnSendToReferential = true;
 //               this.hideCreateOrderInERP = this.opp.SPO_SpecialOrderSKUCode__c == null;
 //               showFirmOrderSection();
 //           //}
 //       } 
 //       //catch(SO_UTIL.RMSException exp) 
 //       //{
 //       //    this.showMessageOnTop = true;
 //       //    system.debug('SO_UTIL.addErrorMessage ' + exp);
 //       //    SO_UTIL.addErrorMessage(exp);
 //       //}
 //       catch (Exception ex) {
 //           //SO_UTIL.addErrorMessage(ex.getMessage());
 //           this.showMessageOnTop = true;
 //       }

 //       updateIcons(this.opp);
 //       //system.debug('icons are: '+this.icons);
            
        
 //       return null;
 //   }

 //   public PageReference createOrderInERP() 
 //   {
 //       System.debug('SO_BriefOrder - createOrderInERP - click');

 //       this.showMessageOnTop = false;

 //      /* 16/11/2016: deactivated by MTOU: not tested by LV*/
 //       List<String> missingFields = validateReadOnlyFields();
 //       if (!missingFields.isEmpty()) 
 //       {
 //           System.debug (missingFields);

 //           this.showMessageOnTop = true;
 //           SO_UTIL.addErrorMessage('The following fields are required : ' + String.join(missingFields, ', '));

 //           return null;
 //       }

 //       try 
 //       {
 //           //if(validateCaCodeWS()){
 //               this.retFirmOrders();
 //               String skuCode = getSKUCode(this.opp.SPO_SpecialOrderSKUCodeRef__c);
 //               this.opp.SPO_SpecialOrderSKUCode__c = skuCode;
 //               this.opp.StageName = 'Creation in progress';

 //               for (SPO_FirmOrder__c fo : this.firmOrderList) {
 //                   fo.SPO_FirmOrderStatus__c = 'Creation in progress';
 //                   fo.SPO_Substatus__c       = 'Technical data';
 //                   fo.SPO_TechETLStatus__c   = 'A';
 //               }
                
 //               update this.opp;
 //               update this.firmOrderList;
 //               this.clickedOnSendToReferential = true;
 //               this.clickedOnCreateOrderInERP = true;
 //               getUserRoleAndReadonlyMode();
 //               this.hideCreateOrderInERP = true;
 //               showFirmOrderSection();
 //           //}
 //       } 
 //       //catch(SO_UTIL.RMSException exp) 
 //       //{
 //       //    this.showMessageOnTop = true;
 //       //    system.debug('SO_UTIL.addErrorMessage on RMS Exception ' + exp);
 //       //    SO_UTIL.addErrorMessage(exp);
 //       //}
 //       catch (Exception ex) {
 //           //SO_UTIL.addErrorMessage(ex);
 //           this.showMessageOnTop = true;
 //       }

 //       updateIcons();
        
 //       return null;
 //   }

    
 //   private String getSKUCode(Id productRefId)
 //   {
 //       String ans = null;
 //       List<ProductReferential__c> productRefList = [SELECT SKUCode__c FROM ProductReferential__c WHERE Id =: productRefId];
 //       if(!productRefList.isEmpty())
 //       {
 //           ans = productRefList[0].SKUCode__c;
 //       }

 //       return ans;
 //   }

 //   /**
 //    * Firm order section butotn, for production view.
 //    */
 //   public PageReference foStartProduction() 
 //   {
 //       System.debug('SO_BriefOrder - foStartProduction - click (currentFirmOrderId = ['+currentFirmOrderId+'])');

 //       if (null == this.currentFirmOrderId)
 //       {
 //           return null;
 //       }

 //       this.showMessageOnTop = false;
 //       try
 //       {
 //           //if(validateCaCodeWS()){
 //               this.opp.StageName = 'In progress';

 //               this.retFirmOrders();

 //               SPO_FirmOrder__c fo = (new Map<Id, SPO_FirmOrder__c>(this.firmOrderList)).get(this.currentFirmOrderId);
 //               fo.SPO_FirmOrderStatus__c = 'Production in progress';
 //               fo.SPO_Substatus__c       = null;

 //               update this.opp;
 //               update fo;
 //           //} 
 //       } 
 //       //catch(SO_UTIL.RMSException exp) 
 //       //{
 //       //    this.showMessageOnTop = true;
 //       //    system.debug('SO_UTIL.addErrorMessage ' + exp);
 //       //    SO_UTIL.addErrorMessage(exp);
 //       //}
 //       catch (Exception ex) {SO_UTIL.addErrorMessage(ex);}

 //       updateIcons();

 //       return null;
 //   }

 //   /**
 //    * Firm order section butotn, for production view.
 //    */
 //   public PageReference launchQA() 
 //   {
 //       System.debug('SO_BriefOrder - launchQA - click (currentFirmOrderId = ['+currentFirmOrderId+'])');

 //       if (null == this.currentFirmOrderId)
 //       {
 //           return null;
 //       }

 //       this.showMessageOnTop = false;
 //       try 
 //       {
 //           //if(validateCaCodeWS()){
 //               this.opp.StageName = 'In progress';

 //               this.retFirmOrders();

 //               SPO_FirmOrder__c fo = (new Map<Id, SPO_FirmOrder__c>(this.firmOrderList)).get(this.currentFirmOrderId);
 //               fo.SPO_FirmOrderStatus__c = 'Production in progress';
 //               fo.SPO_Substatus__c       = 'Quality control';

 //               update this.opp;
 //               update fo;
 //           //}
 //       }
 //       //catch(SO_UTIL.RMSException exp) 
 //       //{
 //       //    this.showMessageOnTop = true;
 //       //    system.debug('SO_UTIL.addErrorMessage ' + exp);
 //       //    SO_UTIL.addErrorMessage(exp);
 //       //} 
 //       catch (Exception ex) {SO_UTIL.addErrorMessage(ex);}

 //       updateIcons();
        
 //       return null;
 //   }

 //   /**
 //    * Firm order section butotn, for store view, visible after the end of distribution statuses are done.
 //    */
 //   public PageReference receivedInStore()
 //   {
 //       System.debug('SO_BriefOrder - receivedInStore - click (currentFirmOrderId = ['+currentFirmOrderId+'])');

 //       if (null == this.currentFirmOrderId)
 //       {
 //           return null;
 //       }
 
 //       this.showMessageOnTop = false;
 //       try 
 //       {
 //           //if(validateCaCodeWS()){
 //               this.opp.StageName = 'In progress';

 //               this.retFirmOrders();

 //               SPO_FirmOrder__c fo = (new Map<Id, SPO_FirmOrder__c>(this.firmOrderList)).get(this.currentFirmOrderId);
 //               fo.SPO_FirmOrderStatus__c = 'Received in store';
 //               fo.SPO_Substatus__c       = null;

 //               update this.opp;
 //               update fo;
 //           //}
 //       }
 //       //catch(SO_UTIL.RMSException exp) 
 //       //{
 //       //    this.showMessageOnTop = true;
 //       //    system.debug('SO_UTIL.addErrorMessage ' + exp);
 //       //    SO_UTIL.addErrorMessage(exp);
 //       //}
 //       catch (Exception ex) {SO_UTIL.addErrorMessage(ex);}

 //       updateIcons();
        
 //       return null;
 //   }

 //   /**
 //    * 1. Firm order section butotn, for store view.
 //    * 2. Call the RMS Payment WS (it's the same WS as Deposit, just with different parameters).
 //    */
 //   public PageReference sendToRMS()
 //   {
 //       System.debug('SO_BriefOrder - sendToRMS - click (currentFirmOrderId = ['+currentFirmOrderId+'])');

 //       if (null == this.currentFirmOrderId)
 //       {
 //           return null;
 //       }
 //       //system.debug('ISRAEL 6');
 //       this.showMessageOnTop = false;
 //       try 
 //       {
 //           //system.debug('ISRAEL 7');
 //           if(validateCaCodeWS())
 //           {
 //               this.opp.StageName = 'In progress';
 //               this.retFirmOrders();
                
 //               //system.debug('ISRAEL 8');
 //               /**
 //                * Added by J.C on December 2015.
 //                * The function launch a Web Service to create A Payment into the RMS and return back his ID.
 //                * If the Callout succeed we continue, otherwise the Error message is shown to the User and the flow can't go on.
 //                */
 //               if(this.opp.SPO_DisplayOrder__c == false){
 //                   //system.debug('ISRAEL 9');
 //                   SO_Session.theCurrentBrief.SPO_caCode__c = this.opp.SPO_caCode__c;
 //                   //system.debug('ISRAEL 10');
 //                   SO_CreateDepositPaymentRMS_Utils.SO_CreateUpdateRmsDepositPaymentResult calloutResult = SO_CreateDepositPaymentRMS_Utils.CreateDepositOrPaymentIntoRMS(true);
                    
 //                   //system.debug('ISRAEL calloutResult = '+calloutResult);
 //                   //system.debug('ISRAEL calloutResult.CalloutSuccessResult = '+calloutResult.CalloutSuccessResult);
 //                   //system.debug('ISRAEL calloutResult.CalloutdepositPaymentRmsId = '+calloutResult.CalloutdepositPaymentRmsId);
 //                   if(calloutResult != Null && calloutResult.CalloutSuccessResult == true && calloutResult.CalloutdepositPaymentRmsId != Null){
 //                       SPO_FirmOrder__c fo = (new Map<Id, SPO_FirmOrder__c>(this.firmOrderList)).get(this.currentFirmOrderId);
 //                       fo.SPO_FirmOrderStatus__c = 'Sent to RMS';
 //                       fo.SPO_Substatus__c       = null;
 //                       //Added by J.C to update the payment transaction number.
 //                       fo.RMS_TransationNumber__c = calloutResult.CalloutdepositPaymentRmsId;
 //                       //End of J.C modification
                        
 //                       update this.opp;
 //                       update fo;
 //                   }
 //               }
 //           }
 //       }
 //       catch(SO_UTIL.RMSException exp) 
 //       {
 //           this.showMessageOnTop = true;
 //           system.debug('SO_UTIL.addErrorMessage ' + exp);
 //           SO_UTIL.addErrorMessage(exp);
 //       }
 //       catch (Exception ex) {
 //           this.showMessageOnTop = true;
 //           SO_UTIL.addErrorMessage(ex);
 //       }
 //       updateIcons();
 //       return null;
 //   }

 //   public PageReference saveFirmOrderRecords()
 //   {
 //       System.debug('SO_BriefOrder - saveFirmOrderRecord - click');
        

 //       try {
 //           update this.firmOrderList;
 //       } catch (Exception ex) {
 //           SO_UTIL.addErrorMessage(ex);
 //       }

 //       return null;
 //   }

 //   /**
 //    * Use for the PDF modal languaes picklist.
 //    */
 //   public void setLanguages(){
 //       languagesMap = new Map<String, String>();

 //       String values = '';
 //       try{
 //           String langCodes = SO_Settings__c.getValues(SO_UTIL.LANGUAGE_CODES_BY_LABEL).Value__c;
 //           langCodeList = langCodes.split(';');

 //           String langNames = SO_Settings__c.getValues(SO_UTIL.LANGUAGES_LABEL_NAMES).Value__c;
 //           langLabelList = langNames.split(';');

 //           if(!langCodeList.isEmpty() && !langLabelList.isEmpty()){
 //               for (Integer i=0; i<langCodeList.Size(); i++){
 //                   languagesMap.put(langCodeList[i], langLabelList[i]);
 //               }
 //           }
 //       }
 //       catch(Exception e){
 //           SO_UTIL.addErrorMessage(e);
 //       }
 //   }

 //   private void retFirmOrders(){
 //       System.debug('retFirmOrders Start : ');
 //       try {
 //           this.firmOrderList = [SELECT SPO_FirmOrderNumber__c, SPO_RevisedDeliveryDate__c, SPO_FirmOrderStatus__c, SPO_Substatus__c
 //                                           FROM SPO_FirmOrder__c 
 //                                           WHERE SPO_BriefName__r.Id =: this.srcObjId];
 //           system.debug('retFirmOrders - this.firmOrderList: '+this.firmOrderList);                                
 //           this.initFirmOrdersWrapper();

 //       }catch (Exception ex){
 //           SO_UTIL.addErrorMessage(ex);
 //       }

 //   }

 //   private void initFirmOrdersWrapper()
 //   {
 //       System.debug('firmOrderWrapperList start: ' + this.firmOrderList);
 //       this.firmOrderWrapperList = new List<orderDetails_Wrapper>();
 //       for(SPO_FirmOrder__c firmOrder : this.firmOrderList)
 //       {
 //           this.firmOrderWrapperList.add(new orderDetails_Wrapper(firmOrder));
 //       }
 //       System.debug('firmOrderWrapperList end: '  + firmOrderWrapperList);
 //   }

 //   public PageReference orderDetailEditMode()
 //   {
 //       this.orderDetailIsInEditSection = true;
 //       return null;
 //   }

 //   public PageReference saveDateEdit()
 //   {
 //       System.debug('SO_BriefOrder - saveDateEdit - click');
        
 //       for(Integer index = 0 ; index<this.firmOrderList.size() && index < this.firmOrderWrapperList.size(); index++)
 //       {
            
 //           this.firmOrderList[index].SPO_RevisedDeliveryDate__c = SO_UTIL.transformDateStringToDateFormat(this.firmOrderWrapperList[index].dateInStringType);
 //       }

 //       this.showMessageOnTop = false;
 //       try 
 //       {
 //           //if(validateCaCodeWS()){
 //               update this.firmOrderList;
 //               this.orderDetailIsInEditSection = false;
 //           //}
 //       } 
 //       //catch(SO_UTIL.RMSException exp) 
 //       //{
 //       //    this.showMessageOnTop = true;
 //       //    system.debug('SO_UTIL.addErrorMessage ' + exp);
 //       //    SO_UTIL.addErrorMessage(exp);
 //       //}
 //       catch (Exception ex) {SO_UTIL.addErrorMessage(ex);}

 //       return null;
 //   }

 //   /**
 //    * Calculate the Firm order mixed history with opportunity for each firm order in the list.
 //    */
 //   @TestVisible private void buildMixHistoryForEachFirmOrderBuckets(
 //       Map<Id, List<orderDetailsHistory_Wrapper>> firmOrderHistoryByFirmOrderIdMap,
 //       List<SPO_FirmOrder__History> firmOrderStatusHistoryList, 
 //       List<SPO_FirmOrder__History> firmOrderSubStatusHistoryList,
 //       List<OpportunityHistory> opportunityHistoryList)
 //   {
 //       Integer listOppProcessSize = opportunityHistoryList.size() - 1;
 //       Integer listFirmStatusProcessSize = firmOrderStatusHistoryList.size() - 1;
 //       Integer k = 0;
 //       Integer j = 0;
 //       Integer lastOppIndex = listOppProcessSize - 1;
 //       Integer lastFirmStatusIndex = listFirmStatusProcessSize - 1;

 //       //Loop on main common status (opp stage)
 //       for(Integer i = 0; i < listOppProcessSize; ++i)
 //       {
 //           //get stage time frame:
 //           Datetime startDateTime = opportunityHistoryList[i].CreatedDate;
 //           Datetime endDateTime = opportunityHistoryList[i + 1].CreatedDate;
            
 //           //Loop on secondry common status (firm order status):
 //           while(j < listFirmStatusProcessSize)
 //           {
 //               //check if firm order status is inside stage time frame:
 //               if(firmOrderStatusHistoryList[j].CreatedDate >= startDateTime && 
 //                   firmOrderStatusHistoryList[j].CreatedDate < endDateTime)
 //               {
 //                   //get firm order status time frame:
 //                   Datetime startStatusDateTime = firmOrderStatusHistoryList[j].CreatedDate;
 //                   Datetime endStatusDateTime = firmOrderStatusHistoryList[j + 1].CreatedDate;

 //                   //Loop on firm order sub status
 //                   while(k < firmOrderSubStatusHistoryList.size())
 //                   {
 //                       //check if firm order sub status is inside firn irder statys time frame:
 //                       if(firmOrderSubStatusHistoryList[k].CreatedDate >= startStatusDateTime && 
 //                           firmOrderSubStatusHistoryList[k].CreatedDate < endStatusDateTime)
 //                       {
 //                           insertDetailHistoryElement(firmOrderHistoryByFirmOrderIdMap.get(firmOrderSubStatusHistoryList[k].ParentId), 
 //                               firmOrderStatusHistoryList[j], 
 //                               firmOrderSubStatusHistoryList[k],
 //                               opportunityHistoryList[i]);

 //                           lastOppIndex = i;
 //                           lastFirmStatusIndex = j;
 //                           ++k;
 //                           continue;
 //                       }
 //                       break;
 //                   }
 //                   ++j;
 //                   continue;
 //               }
 //               break;
 //           }
 //       }

 //       //Loop on secondry common status (firm order status):
 //       while(j < listFirmStatusProcessSize)
 //       {
 //           //get firm order status time frame:
 //           Datetime startStatusDateTime = firmOrderStatusHistoryList[j].CreatedDate;
 //           Datetime endStatusDateTime = firmOrderStatusHistoryList[j + 1].CreatedDate;

 //           //Loop on firm order sub status
 //           while(k < firmOrderSubStatusHistoryList.size())
 //           {
 //               //check if firm order sub status is inside firn irder statys time frame:
 //               if(firmOrderSubStatusHistoryList[k].CreatedDate >= startStatusDateTime && 
 //                   firmOrderSubStatusHistoryList[k].CreatedDate < endStatusDateTime)
 //               {
 //                   insertDetailHistoryElement(firmOrderHistoryByFirmOrderIdMap.get(firmOrderSubStatusHistoryList[k].ParentId), 
 //                       firmOrderStatusHistoryList[j], 
 //                       firmOrderSubStatusHistoryList[k],
 //                       opportunityHistoryList[lastOppIndex + 1]);

 //                   lastFirmStatusIndex = j;
 //                   ++k;
 //                   continue;
 //               }
 //               break;
 //           }
 //           ++j;
 //       }

 //       if(k == firmOrderSubStatusHistoryList.size())
 //       {
 //           insertDetailHistoryElement(firmOrderHistoryByFirmOrderIdMap.get(firmOrderStatusHistoryList[lastFirmStatusIndex + 1].ParentId), 
 //               firmOrderStatusHistoryList[lastFirmStatusIndex + 1], 
 //               new SPO_FirmOrder__History(Field = 'SPO_Substatus__c'),
 //               opportunityHistoryList[lastOppIndex + 1]);
 //       }

 //       while(k < firmOrderSubStatusHistoryList.size())
 //       {
 //           insertDetailHistoryElement(firmOrderHistoryByFirmOrderIdMap.get(firmOrderSubStatusHistoryList[k].ParentId), 
 //               firmOrderStatusHistoryList[lastFirmStatusIndex + 1], 
 //               firmOrderSubStatusHistoryList[k],
 //               opportunityHistoryList[lastOppIndex + 1]);

 //           ++k;
 //       }
 //   }

 //   private void insertDetailHistoryElement(
 //       List<orderDetailsHistory_Wrapper> orderDetailHistoryList,
 //       SPO_FirmOrder__History firmOrderStatusHistory, 
 //       SPO_FirmOrder__History firmOrderSubStatusHistory,
 //       OpportunityHistory opportunityHistory)
 //   {
 //       orderDetailsHistory_Wrapper orderDetailHistory = new orderDetailsHistory_Wrapper();
 //       orderDetailHistory.firmOrderSubStatusHistory = firmOrderSubStatusHistory;
 //       orderDetailHistory.firmOrderStatusHistory = firmOrderStatusHistory;
 //       orderDetailHistory.oppHistory = opportunityHistory;
 //       orderDetailHistoryList.add(orderDetailHistory);
 //   }

 //   /**
 //    * Calculate the Firm order mixed history with opportunity for each firm order in the list.
 //    * Use the private method: buildMixHistoryForEachFirmOrderBuckets. 
 //    */
 //   public void buildMixHistoryForEachFirmOrder()
 //   {
 //       this.firmOrderHistoryByFirmOrderIdMap = new Map<Id, List<orderDetailsHistory_Wrapper>>();
 //       if(!this.firmOrderList.isEmpty())
 //       {
 //           try
 //           {
 //               //SPO_FirmOrder__History
 //               Map<Id, SPO_FirmOrder__c> firmOrdersMap = new Map<Id, SPO_FirmOrder__c>(this.firmOrderList);
 //               for(Id firmOrderId : firmOrdersMap.keySet())
 //               {
 //                   if(!this.firmOrderHistoryByFirmOrderIdMap.containsKey(firmOrderId))
 //                   {
 //                       this.firmOrderHistoryByFirmOrderIdMap.put(firmOrderId, new List<orderDetailsHistory_Wrapper>());
 //                   }
 //               }

 //               List<SPO_FirmOrder__History> firmOrderStatusHistoryList = [SELECT Id, CreatedDate, Field, NewValue, OldValue, ParentId 
 //                                                                    FROM SPO_FirmOrder__History 
 //                                                                    WHERE ParentId IN :firmOrdersMap.keySet() AND Field = 'SPO_FirmOrderStatus__c'
 //                                                                    ORDER BY CreatedDate];
 //               System.debug('buildMixHistoryForEachFirmOrder - SFDC firmOrderStatusHistoryList: ' + firmOrderStatusHistoryList);    

 //               List<SPO_FirmOrder__History> firmOrderSubStatusHistoryList = [SELECT Id, CreatedDate, Field, NewValue, OldValue, ParentId 
 //                                                                    FROM SPO_FirmOrder__History 
 //                                                                    WHERE ParentId IN :firmOrdersMap.keySet() AND Field = 'SPO_Substatus__c'
 //                                                                    ORDER BY CreatedDate];
 //               System.debug('buildMixHistoryForEachFirmOrder - SFDC firmOrderSubStatusHistoryList: ' + firmOrderSubStatusHistoryList); 

 //               List<OpportunityHistory> opportunityHistoryList = [SELECT Id, CreatedDate, StageName 
 //                                                                  FROM OpportunityHistory 
 //                                                                  WHERE OpportunityId =:this.opp.Id
 //                                                                  ORDER BY CreatedDate];
               
 //               System.debug('buildMixHistoryForEachFirmOrder - SFDC opportunityHistoryList: ' + opportunityHistoryList); 

 //               buildMixHistoryForEachFirmOrderBuckets(firmOrderHistoryByFirmOrderIdMap, firmOrderStatusHistoryList, firmOrderSubStatusHistoryList, opportunityHistoryList);

 //               initOpportunityHistoryList();
 //           } 
 //           catch (Exception ex) 
 //           {
 //               System.debug('SO_BriefOrder - Exception - buildMixHistoryForEachFirmOrder: ' + ex.getMessage());
 //               SO_UTIL.addErrorMessage(ex);
 //           } 
 //       }
 //   }


 //   public class orderDetailsHistory_Wrapper
 //   {
 //       public SPO_FirmOrder__History  firmOrderStatusHistory       {get; private set;}
 //       public SPO_FirmOrder__History  firmOrderSubStatusHistory    {get; private set;}
 //       public OpportunityHistory      oppHistory                   {get; private set;}

 //   }

 //   public class orderDetails_Wrapper
 //   {
 //       public SPO_FirmOrder__c firmOrder {get;set;}
 //       public String dateInStringType {get ;
 //                                set
 //                                   {
 //                                       if(SO_UTIL.dateStringIsValid(value))
 //                                       {
 //                                           dateInStringType = value;
 //                                       }
 //                                       else if(dateInStringType == null)
 //                                       {
 //                                           dateInStringType = '';
 //                                       }
 //                                   }
 //                               }

 //       public orderDetails_Wrapper(SPO_FirmOrder__c firmOrder)
 //       {
 //           this.firmOrder = firmOrder;
 //           this.dateInStringType = firmOrder.SPO_RevisedDeliveryDate__c != null ? firmOrder.SPO_RevisedDeliveryDate__c.format() : null;
 //           //this.dateInStringType =  SO_UTIL.transformDateStringToDateFormat(firmOrder.SPO_RevisedDeliveryDate__c);
           
 //       } 
 //   }

 //   private void resetStdController()
 //   {
 //       this.stdController.reset();
 //       this.opp = (Opportunity)this.stdController.getRecord();
 //   }

 //   public String retrievePicklistDefaultValues(String fieldName)
 //   {
 //       String defaultVal = '';
 //       Schema.DescribeFieldResult fieldResult = null;

 //       Map<String, Schema.SObjectField> oppFields = Opportunity.getSObjectType().getDescribe().fields.getMap();
 //       for(Schema.SObjectField oppField: oppFields.values())
 //       {
 //           if(oppField.getDescribe().getName() == fieldName)
 //           {
 //               fieldResult = oppField.getDescribe();
 //           }
 //   	}
 //       List <Schema.PicklistEntry> pickVals = fieldResult.getPicklistValues();
 //       for(Schema.PicklistEntry entry: pickVals)
 //       {
 //           if(entry.isDefaultValue())
 //           {
 //               defaultVal = entry.getValue();
 //           }
 //       }
 //       system.debug('defaultVal2: ' + defaultVal);
 //       return defaultVal;

 //   }
}