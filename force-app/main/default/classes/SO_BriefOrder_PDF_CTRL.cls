public with sharing class SO_BriefOrder_PDF_CTRL extends SO_BaseController {
	
	private static List<String> moreFieldsToOppThatNotUsedInPageList = new List<String> {
        'StageName',
        'SPO_ProductCategory__c',
        'SPO_OrderType__c',
        'SPO_BaseSKURefmodelSKU__r',
        'SPO_BaseSKURefmodelSKU__r.Name',
        'SPO_SizeUnit__c'
    };

    //--------------------------- Private fields --------------
    private ApexPages.StandardController stdController;

    //----------------------------- Public fields --------------
    public Opportunity opp                      {get; set;}
    public Id srcObjId                          {get; set;}
    public Boolean hasQuotation                 {get; set;}
    public String productCategory 				{get; set;}
    public String orderType 					{get; set;}
    public String stageName 					{get; set;}
    public ProductReferential__c pRef			{get; set;}

    public String exteriorColor                 {get; set;}
    public String interiorColor                 {get; set;}

	public SO_BriefOrder_PDF_CTRL(ApexPages.StandardController stdController){
        this.stdController = stdController;

        if(!Test.isRunningTest()){
            this.stdController.addFields(moreFieldsToOppThatNotUsedInPageList);
        }
        
        this.srcObjId = stdController.getId();
        if(String.isNotEmpty(srcObjId)) {
            init();
        }
        System.debug('SO_BriefOrder_PDF_CTRL - constructor eneded');
    }

    ////--------------------------- Public methods --------------
    override public void init(){

        this.opp = (Opportunity)this.stdController.getRecord();
        this.productCategory = this.opp.SPO_ProductCategory__c;
        this.orderType = this.opp.SPO_OrderType__c;
        this.stageName = this.opp.StageName;
        //this.pRef = this.opp.SPO_BaseSKURefmodelSKU__r;
        this.pRef = retProductReferential(this.opp.SPO_BaseSKURefmodelSKU__r.id);
        //System.debug(pRef.SKUCode__c);
        //System.debug(pRef.Name);

        if(opp !=null)
        {
            getColorsRgbHexMapByNames();

        }

        // Case without quotation
        if (this.opp.SPO_ProductCategory__c== SO_PicklistDependency.OPP_LEATHER_GOOD && this.opp.SPO_OrderType__c==SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG){
            this.hasQuotation = false;
        }else{
            this.hasQuotation=true;
        }
    }

    private void getColorsRgbHexMapByNames() 
    {
        List<SPO_Colors__c> colorsList = retColorListByName();

        for(SPO_Colors__c colorObj : colorsList) 
        {
            if (colorObj.Name == opp.SPO_ExteriorMaterialColor1__c) 
            {
                if(colorObj.SPO_CodeCouleur__c != null)
                {
                    exteriorColor = '#'+colorObj.SPO_CodeCouleur__c;
                }
                else
                {
                    exteriorColor = 'url("'+ SO_ProductSpe_CTRL.extractImage(colorObj.SPO_Preview__c) +'") no-repeat';
                }
                
            }
            if (colorObj.Name == opp.SPO_LiningInteriorColor1__c)
            {
                if(colorObj.SPO_CodeCouleur__c != null)
                {
                    interiorColor = '#'+colorObj.SPO_CodeCouleur__c;
                }
                else
                {
                    interiorColor =  'url("'+ SO_ProductSpe_CTRL.extractImage(colorObj.SPO_Preview__c) +'") no-repeat';
                }
            }
        }
    }


    private ProductReferential__c retProductReferential (Id prId)
    {
        List<ProductReferential__c> productReferential =   [SELECT SKUCode__c, Name 
                                                             FROM ProductReferential__c
                                                             WHERE id=:prId];
        if(!productReferential.isEmpty()) 
        {
            return productReferential[0];
        }
        return null; 

    }
    private List<SPO_Colors__c> retColorListByName() 
    {

        return 
            [SELECT Id, Name 
                   ,SPO_Preview__c
                   ,SPO_CodeCouleur__c
                   ,SPO_Description__c
                   ,SPO_Position__c
              FROM SPO_Colors__c
             WHERE Name =:  opp.SPO_ExteriorMaterialColor1__c 
                   OR Name =: opp.SPO_LiningInteriorColor1__c];
    }

}