public without sharing  class PDFPageController {
    public Opportunity opportunity{get;set;}
    private ApexPages.StandardController stdController;
    public ProductReferential__c product {get;set;}
    public SPO_Colors__c colorInterior1 {get;set;}
    public SPO_Colors__c colorInterior2 {get;set;}
    public SPO_Colors__c colorExtorior1 {get;set;}
    public SPO_Colors__c colorExtorior2 {get;set;}
    public SPO_Colors__c colorExtorior3 {get;set;}
    public ProductSettings__c productSettings {get;set;}
    public ProductCatalogue__c productCatalogue {get;set;}
    public String imageLink {get;set;}
    public Account account {get;set;}
	public String primaryaddress {get;set;}
    public String store {get;set;}
    public User user {get;set;}
    public User createdUser {get;set;}
    public User modifyUser {get;set;}
    public Store__c storeName {get;set;}
    
    public PDFPageController(ApexPages.StandardController standardController)
    {
        stdController = standardController;
        opportunity = (Opportunity)standardController.getRecord();
        
        this.opportunity    = [SELECT SPO_ClientCompleteName__c ,
                            SPO_SizeHeight__c, 
                            SPO_Sizewidth__c, 
                            SPO_SizeLenght__c, 
                            SPO_SizeUnit__c,
                            SPO_Patch__c ,
                            SPO_PatchFreeText__c,
                            SPO_ExteriorMaterial1__c,
                            SPO_ExteriorMaterialColor1__c,
                            SPO_ExteriorMaterial2__c,
                            SPO_ExteriorMaterialColor2__c,
                            SPO_ExteriorMaterial3__c,
                            SPO_ExteriorMaterialColor3__c,
                            SPO_LiningInteriorMaterial1__c,
                            SPO_LiningInteriorColor1__c,
                            SPO_LiningInteriorMaterial2__c,
                            SPO_LiningInteriorColor2__c,
                            SPO_BaseSKURefmodelSKU__c,
                            OrderNumber__c,
                            SPO_DeliveryAddress__c ,
                            SPO_DeliveryAddressComment__c,
                            SPO_DepositAmount__c,
                            SPO_UnitRetailPrice__c ,
                            SPO_DueAmount__c,
                            SPO_CACode__c,
                            SPO_Date_Quotation_accepted__c,
                            SPO_Date_Quotation_submitted__c,
                            StoreAddress__c,
                            FollowUpByClientAdvisor__c,
                            AccountId,
                            SPO_TotalAmount__c,
                            SPO_TotalAmountCurrency__c,
                            TotalOpportunityQuantity,
                            SPO_SkuQuantity__c ,
                            SPO_DepositAmountCurrencyInclude__c,
                            SPO_DueAmountCurrencyInclude__c,
                            CreatedDate,
                            SPO_OrderType__c,
                            SPO_Painting__c,
                            SPO_LiningColor1LocalComment__c,
                            SPO_ColorMetalicparts__c,
                            SPO_Lock__c,
                            SPO_CommercialLocalComment__c, 
                            SPO_InternalWorkshopComment__c,
                            SPO_CommercialZoneApproverComment__c,
                            SPO_MarketingApproval__c,
                            SPO_ProductCategory__c,
                            SPO_StoreCode__c,
                            SPO_Store__c,
                            OwnerId,
                            SPO_EstimatedProductionTimeMonths__c,
                            SPO_EstimatedDistributionTime__c,
                            SPO_StoreCurrency__c,
                            SPO_ExportPrice__c,
                            SPO_Numberofproductivehours__c,
                            SPO_StopBriefReason__c,
                            SPO_StopBriefComment__c,
                            SPO_ProductionQuoteComment__c,
                            SPO_CRS__c,
                            SPO_EstimatedLeadTime__c,
                            SPO_WishedDate__c,
                            SPO_SpecialEvents__c,
                            SPO_TechMailToreferential__c,
                            SPO_TechEmailAlreadySent__c,
                            SPO_SpecialOrderSKUCodeRef__c,
                            Send_to_ERP__c,
                            CreatedById,
                            LastModifiedById,
                            StageName,
                            Probability,
                            SPO_CreationType__c,
                            SPO_SpecialOrderSKUCode__c,
                            SPO_Dimension_comment__c,
                            SPO_Sku_Code_S__c,
                            SPO_PlannedDeliveryDate__c
                            FROM Opportunity where id =: opportunity.Id];
        System.debug('Opportunity >>>>>>>> ' + this.opportunity);
        
		if(this.opportunity.AccountId != null){
            this.account = [SELECT PersonEmail,PrimaryAddress__pc ,PersonHomePhone, PersonMobilePhone,PrimaryAddressCompacted__pc FROM account where Id =: this.opportunity.AccountId];
            if(this.account.PrimaryAddress__pc != null){
                this.primaryaddress = this.account.PrimaryAddress__pc.replace('<br>',' - ');
            }
        }
        
        System.debug('Account >>>>>>>> ' + account);
        
        System.debug('********** primayradress '+primaryaddress);
        this.productSettings = ProductSettings__c.getInstance();

        if(this.opportunity.SPO_BaseSKURefmodelSKU__c != null){
            this.product        = [ SELECT SKUCode__c,
                            ImageLink1__c,
                            Id,
                            name,
                            SPO_ProductNameSKU__c,
                            SPO_ImageLink1FrontView__c,
                            SPO_ImageLink2SideView__c,
                            SPO_ImageLink3OtherView__c,
                            SPO_ImageLink4InteriorView__c,
                            SPO_ImageLink5OtherView2__c

                            FROM ProductReferential__c 
                            where id =: this.opportunity.SPO_BaseSKURefmodelSKU__c];
        this.imageLink = this.productSettings.BccMediumPictureUrl__c + this.product.ImageLink1__c;
        System.debug('Image link from controller ' + product.SPO_ImageLink1FrontView__c); 
        }
        
        System.debug('opportunity SPO_ExteriorMaterialColor1__c' + this.opportunity.SPO_ExteriorMaterialColor1__c);
    	if(this.opportunity.SPO_ExteriorMaterialColor1__c != null && this.opportunity.SPO_ExteriorMaterialColor1__c != 'Other (free text)' && this.opportunity.SPO_ExteriorMaterialColor1__c != 'OTHER'){
            this.colorExtorior1 = [ SELECT id,name,
                            SPO_StaticResourceName__c,
                            SPO_CodeCouleur__c,
                            SPO_Preview__c FROM SPO_Colors__c 
                            where name =: this.opportunity.SPO_ExteriorMaterialColor1__c];
        }
        
        if(this.opportunity.SPO_ExteriorMaterialColor2__c != null && this.opportunity.SPO_ExteriorMaterialColor2__c != 'Other (free text)'){
            this.colorExtorior2 = [ SELECT id,name,
                            SPO_StaticResourceName__c,
                            SPO_CodeCouleur__c,
                            SPO_Preview__c FROM SPO_Colors__c 
                            where name =: this.opportunity.SPO_ExteriorMaterialColor2__c];
        }

        if(this.opportunity.SPO_ExteriorMaterialColor3__c != null && this.opportunity.SPO_ExteriorMaterialColor3__c != 'Other (free text)'){
            this.colorExtorior3 = [ SELECT id,name,
                            SPO_StaticResourceName__c,
                            SPO_CodeCouleur__c,
                            SPO_Preview__c FROM SPO_Colors__c 
                            where name =: this.opportunity.SPO_ExteriorMaterialColor3__c];
        }
        
        System.debug('opportunity.SPO_LiningInteriorColor1__c' + this.opportunity.SPO_LiningInteriorColor1__c);
        if(this.opportunity.SPO_LiningInteriorMaterial1__c != null && 
            this.opportunity.SPO_LiningInteriorMaterial1__c  != 'Other (free text)' 
            && this.opportunity.SPO_LiningInteriorColor1__c != null
            && this.opportunity.SPO_LiningInteriorColor1__c != 'Other (free text)'
            && this.opportunity.SPO_LiningInteriorColor1__c != 'OTHER' ){
            this.colorInterior1 = [ SELECT id,name,
                            SPO_StaticResourceName__c,
                            SPO_CodeCouleur__c,
                            SPO_Preview__c 
                            FROM SPO_Colors__c 
                            where name =: this.opportunity.SPO_LiningInteriorColor1__c];
        }
        
        if(this.opportunity.SPO_LiningInteriorMaterial2__c != null && this.opportunity.SPO_LiningInteriorMaterial2__c  != 'Other (free text)'){
            SPO_Colors__c hasColorInterior2 = new SPO_Colors__c(name = this.opportunity.SPO_LiningInteriorColor2__c);
            if(hasColorInterior2.Name != null) {
                
                this.colorInterior2 = [ SELECT id,name,
                            SPO_StaticResourceName__c,
                            SPO_CodeCouleur__c,
                            SPO_Preview__c 
                            FROM SPO_Colors__c 
                            where name =: this.opportunity.SPO_LiningInteriorColor2__c];
            }
        }
   		List<ProductCatalogue__c> listeProductCatalogue = new List<ProductCatalogue__c>();
        if(this.product.SKUCode__c != null){
            listeProductCatalogue = [SELECT Id, 
                            Image1Url__c  
                            FROM ProductCatalogue__c 
                            where sku__c =: this.product.SKUCode__c];
        }
        

        if(listeProductCatalogue.size() >0){
            this.productCatalogue = listeProductCatalogue.get(0);
        }
        
        System.debug('colorExtorior1' + colorExtorior1);
        System.debug('colorExtorior2' + colorExtorior2);
        System.debug('colorExtorior3' + colorExtorior3);
        System.debug('colorInterior1' + colorInterior1);
        System.debug('colorInterior2' + colorInterior2);

        if(this.opportunity.OwnerId != null){
            this.user = [Select Id,FirstName, LastName, Name from User where Id = : this.opportunity.OwnerId];
        }

        if(this.opportunity.CreatedById != null){
            this.createdUser = [Select Id,FirstName, LastName, Name from User where Id = : this.opportunity.CreatedById];
        }

        if(this.opportunity.LastModifiedById != null){
            this.modifyUser = [Select Id,FirstName, LastName, Name from User where Id = : this.opportunity.LastModifiedById];
        }

        if(this.opportunity.SPO_Store__c != null){
            this.storeName = [Select Id, Name,StoreCountry__c from Store__c where Id = : this.opportunity.SPO_Store__c limit 1];
        }
    }
    
}