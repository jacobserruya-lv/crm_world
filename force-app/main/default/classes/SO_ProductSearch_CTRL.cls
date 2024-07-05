public with sharing class SO_ProductSearch_CTRL 
	extends SO_BaseController 
	implements SO_ITablePagination_INTERFACE 
{ 

	private static Set<String> orderTypeForFilterSet;
	private static Map<String,String> descriptionFieldSetRelation;
	
	private static Map<String,String> defaultOrderTypeVlauesFieldSet;

	static {

		orderTypeForFilterSet = new Set<String> {
			 SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG
			,SO_PicklistDependency.ORDER_TYPE_SPO_MTO	
		};

		descriptionFieldSetRelation = new Map<String,String> {

		     SO_PicklistDependency.OPP_ACCESSORY 	=> 'Accessory_Description'
		    ,SO_PicklistDependency.OPP_LEATHER_GOOD => 'Leather_good_Description'
		    ,SO_PicklistDependency.OPP_WATCH 		=> 'Watch_Description'

		};

		defaultOrderTypeVlauesFieldSet = new Map<String, String> {
		     SO_PicklistDependency.OPP_LEATHER_GOOD 	=> null
			,SO_PicklistDependency.OPP_WATCH 			=> SO_PicklistDependency.ORDER_TYPE_SPO_MTO
			,SO_PicklistDependency.OPP_ACCESSORY		=> SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER
		};

	}	

	transient public List<Map<String, Object>> prodReferentialMapList  {get; private set;}

	private Boolean isClear;
	public SO_Session.SessionState theSessionState 			 { get; set; }
	public SO_ProductSearch_CTRL contr 						 { get {return this;} }
	public Integer totalRows 								 { get; set; }
	public Integer startRow  								 { get; set; }
	public Integer endRow    								 { get; set; }
	public Boolean categoryEntered 							 { get; set; }
	public String  nameOrSKU 								 { get; set; }
	public Boolean showTable 								 { get; set; }
	public Boolean isShowProductNotFound 					 { get; set; }
	public String selectedProductRef 						 { get; set; }
	public String productNotFoundId							 { get; set; }
	public String prodCatDependencyJSON						 { get; set; }
	public Boolean isSearch 						 		 { get; private set; }

	public ProductReferential__c 		entryProdReferential { get; set; }
	public List<ProductReferential__c>	prodReferentialList  { get; set; }
	public Map<String, String>      	prodCatDependencyMap { get; set; }

    private Integer resultCounter;

	public Boolean searchAvailable {

		get {
			return
				null == SO_Session.theCurrentBrief
				|| 'Brief in progress'.equalsIgnoreCase(SO_Session.theCurrentBrief.StageName)
				|| 'Quotation in progress'.equalsIgnoreCase(SO_Session.theCurrentBrief.StageName);


		}
	}

	public Opportunity entryOpportunity { 
		get {
			if(null == entryOpportunity) {
				entryOpportunity = new Opportunity();
			}	
			return entryOpportunity;
		}
		set;
	}
	private Schema.FieldSet retDescriptionFieldSet() { 
		
		//System.debug('descriptionFieldSet productCategory >> ' + theSessionState.searchProductData.productCategory);
		String fieldSetName = descriptionFieldSetRelation.get(theSessionState.searchProductData.productCategory);
		return Schema.SObjectType.ProductReferential__c.fieldSets.getMap().get(fieldSetName);
	 
	}

	//---------------------- CTOR ------------------------
    public SO_ProductSearch_CTRL(){
        PageReference pageRef = validateNoBriefIdBase();
        if(pageRef == null)
        {
	    	init();
	    	prodCatDependencyMap = new Map<String, String>();

	    	for(String oneProdCat : SO_PicklistDependency.picklistDependencyByOppCat.keySet()) {

	    		prodCatDependencyMap.put(oneProdCat
					                    ,SO_PicklistDependency.picklistDependencyByOppCat.get(oneProdCat).Referential_Category__c);    		

	    	}

	    	prodCatDependencyJSON = JSON.serialize(prodCatDependencyMap);
       	}
    }
    
    override public void init()
    {
    	try
    	{
	     	categoryEntered = false;   
	     	this.isClear = false;
	     	this.prodReferentialMapList = new List<Map<String, Object>>();

	     	theSessionState = SO_Session.retSessionState();
	     	if(null == theSessionState.searchProductData) {

	     		theSessionState.searchProductData = new SO_UTIL.SearchProductData();
	     	}
	     	else 
	     	{
	     		//System.debug('\nStart Product Search init param: \n\n');
	     		
	     		nameOrSKU 								= theSessionState.searchProductData.nameOrSKU;
	     		entryOpportunity.SPO_ProductCategory__c = theSessionState.searchProductData.productCategory;
	     		entryOpportunity.SPO_OrderType__c 		= theSessionState.searchProductData.orderType;

	     		//System.debug(nameOrSKU + '::' + entryOpportunity.SPO_ProductCategory__c + '::' + entryOpportunity.SPO_OrderType__c);

	     		//System.debug('\nEnd Product Search init param: \n\n');
	     	}

			if(true == theSessionState.displayOrder) {
				entryOpportunity.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
			}
				
	    	this.productNotFoundId = getIdOfProductNotFound();
    	}
		catch(Exception e)
		{
			SO_UTIL.addErrorMessage(e);
		}

    }
	
	public void onCategoryChange() {
		categoryEntered = true;
	}

	public PageReference clear()
	{
		//Clear filter
		this.entryOpportunity = new Opportunity();
		this.nameOrSKU = null;
		this.showTable = false;
		this.totalRows = 0;
		this.startRow = 0;
		this.endRow = 0;
		this.isClear = true;

		theSessionState.searchProductData = new SO_UTIL.SearchProductData();
		SO_Session.saveSession(theSessionState, true);
		return null; 
	}


	public PageReference initialLoadingSearch()
	{
		PageReference pageRef = null;        // Redirect user if cloning brief
        try 
        {
        	pageRef = validateNoBriefIdBase();
        	if(pageRef == null)
        	{
				if(theSessionState.isProductReady == true)
				{
					pageRef = Page.So_productspe;
					pageRef.getParameters().put('id', SO_Session.currentBriefId);
				}
				else
				{
					//System.debug('\nStart Product Search initialLoadingSearch \n\n');
					search();
					//System.debug('\nEnd Product Search initialLoadingSearch \n\n');
				}
        	}

        }
        catch(Exception exp) 
        {
            SO_UTIL.addErrorMessage(exp);
            pageRef = null;
        }
        return pageRef;
	}


	/**
     *  @description        Performs searching
    */
	public PageReference search()
	{
		this.isSearch = true;
		this.resultCounter = 0;
		try 
		{
			this.isShowProductNotFound = SO_PicklistDependency.OPP_LEATHER_GOOD.equalsIgnoreCase(this.entryOpportunity.SPO_ProductCategory__c) &&
									SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER.equalsIgnoreCase(this.entryOpportunity.SPO_OrderType__c);


			this.theSessionState.searchProductData.productCategory 	= this.entryOpportunity.SPO_ProductCategory__c;
			this.theSessionState.searchProductData.orderType 	  	= this.entryOpportunity.SPO_OrderType__c;
			this.theSessionState.searchProductData.nameOrSKU 	  	= this.nameOrSKU;

			if(theSessionState.searchProductData.productCategory == null
				|| theSessionState.searchProductData.orderType == null
				|| theSessionState.searchProductData.nameOrSKU == null)
			{
				this.isSearch = false;
				this.resultCounter = 0;
			}
			else
			{
				setProductRefMapList('ProductsList', null, 0, '', '');
			}

			SO_Session.saveSession(theSessionState, true);
			this.showTable = this.resultCounter > 0;
		}
		catch(Exception exp) 
		{
			SO_UTIL.addErrorMessage(exp);
			showTable = false;
		}
		return null;
	}

/*
FIND {test*} IN ALL FIELDS 
	RETURNING ProductReferential__c 
	(
		Id, Name... 
		WHERE 
			(NOT SKUCode__c LIKE 'S%') AND ProductCategory__c = 'Watches' 
			ORDER BY ProductCategory__c 
			LIMIT 2000
	)
*/

	private String getStrQuery(String sortColumn, String sortOrder)
	{
		String query = 'FIND \'' + nameOrSKU + '\' IN ALL FIELDS RETURNING ProductReferential__c (';
		Set<String> sqlFieldSet = new Set<String> 
		{
			 'Id'
			,'Name' 
			,'Height__c'
			,'Length__c'
			,'Witdth__c'
			,'SKUCode__c'
			,'SPO_ImageLink1FrontView__c' 
			,'SPO_ImageLink2SideView__c' 
			,'SPO_ImageLink3OtherView__c' 
			,'SPO_ImageLink4InteriorView__c' 
			,'SPO_ImageLink5OtherView2__c' 
			,'Description__c'
			,'ProductCategory__c'
			,'Model__c'
			,'Family__c'
			,'ColorVariation__c'
			,'WatchDialcompo__c'
			,'WatchMovementname__c'
			,'Status__c' 
		};

		Schema.FieldSet descriptionFieldSet = retDescriptionFieldSet();
		for(Schema.FieldSetMember fieldSetMember : descriptionFieldSet.getFields()) 
		{
			sqlFieldSet.add(fieldSetMember.getFieldPath());
		}
		query += String.join(new List<String>(sqlFieldSet), ',');

		query += ' WHERE ';
		String searchCat = SO_PicklistDependency.picklistDependencyByOppCat.get(entryOpportunity.SPO_ProductCategory__c).Referential_Category__c;
		query += '(NOT SKUCode__c LIKE \'S%\') AND ProductCategory__c = ' + SO_UTIL.addApostrophe(searchCat);

        SO_Settings__c subFamilies = SO_Settings__c.getValues(SO_UTIL.PRODUCTS_REFERENTIAL_SUB_FAMILIES);
		if(SO_PicklistDependency.OPP_LEATHER_GOOD.equalsIgnoreCase(entryOpportunity.SPO_ProductCategory__c) && 
			orderTypeForFilterSet.contains(entryOpportunity.SPO_OrderType__c) &&
			subFamilies != null) 
		{ 
			query += ' AND Status__c = \'40\'';
            List<String> subFamiliesList = subFamilies.Value__c.split(';');
			String subFamiliesListStr = '\'' + String.join(subFamiliesList,'\',\'') + '\'';
			query += ' AND SubFamily__c IN (' + subFamiliesListStr + ')'; 
		}

		if(String.isNotBlank(sortColumn)) 
		{
			query += ' ORDER BY ' + sortColumn;
		}

		if(String.isNotBlank(sortOrder)) 
		{
			query += ' ' + sortOrder;
		}
		
		query += ' LIMIT 2000)';

		System.debug('SO_ProductSearch - getStrQuery - SOSL Query: ' + query);
		
		return query;

	}
	
	//---------------------- SO_ITablePagination_INTERFACE implementation ------------------------
	public Map<String, String> retColumns(String tableId){

		return new Map<String, String>{
			'Image' => Label.LV_SO_ProductImage + '!!sort-by=false',	//not sortable					 
			'SKUCode__c' => Label.LV_SO_SKU, 
			'ProductCategory__c' => Label.LV_SO_ProductCategory,
			'Name' => Label.LV_SO_CommercialName, 
			'Dimensions' => Label.LV_SO_Dimensions_CM + '!!sort-by=false', 
			'Actions' => Label.LV_SO_Actions + '!!width=250px!!sort-by=false'
		};	
	}

	private void setProductRefMapList(String tableId, Integer lim, Integer offset, String sortColumn, String sortOrder)
	{
		System.debug('setProductRefMapList - lim::offset ' + lim + '::' + offset);
		this.prodReferentialMapList = new List<Map<String, Object>>();
		try
		{
			String query = getStrQuery(sortColumn, sortOrder);
			//System.debug('query >> ' + query);

			this.showTable = false;
			this.resultCounter = 0;
			List<sObject> sObjValList = new List<sObject>();
            List<List<SObject>> searchList = Search.query(query);
            if(!searchList.isEmpty())
            {
                sObjValList = searchList[0];
                if(!sObjValList.isEmpty())
                {
	                this.resultCounter = sObjValList.size();
	                System.debug('setProductRefMapList - resultCounter: ' + resultCounter);
					ApexPages.StandardSetController setController = new ApexPages.StandardSetController(sObjValList);
					//this.list_size <= this.total_size ? this.list_size : this.total_size
					lim = lim == null ? 
						(SO_BootstrapTable_CTRL.MAX_PAGE_SIZE <= this.resultCounter ? SO_BootstrapTable_CTRL.MAX_PAGE_SIZE : this.resultCounter)
						: lim;
					Integer pageNumber = offset / lim + 1;
					setController.setPageSize(lim);
					setController.setpageNumber(pageNumber);

					List<ProductReferential__c> productList = (List<ProductReferential__c>)setController.getRecords();

					Schema.FieldSet descriptionFieldSet = retDescriptionFieldSet();

					for(Integer X = 0; X <productList.size(); X++) {
						ProductReferential__c oneProduct = productList[X];
						Map<String, Object> target = new Map<String, Object>();
						target.put('Image',oneProduct.SPO_ImageLink1FrontView__c);
						target.put('ImageLink2__c',oneProduct.SPO_ImageLink2SideView__c);
						target.put('ImageLink3__c',oneProduct.SPO_ImageLink3OtherView__c);
						target.put('ImageLink4__c',oneProduct.SPO_ImageLink4InteriorView__c);
						target.put('ImageLink5__c',oneProduct.SPO_ImageLink5OtherView2__c);
						target.put('SKUCode__c',oneProduct.SKUCode__c);
						target.put('ProductCategory__c',oneProduct.ProductCategory__c);
						target.put('Name',oneProduct.Name);

						for(Schema.FieldSetMember fieldSetMember : descriptionFieldSet.getFields()) {

							String fieldName = fieldSetMember.getFieldPath();
							if(!target.containsKey(fieldName)) {
								target.put(fieldName, oneProduct.get(fieldName));
							}
						}
						
						target.put('Actions', oneProduct.Id);
						if(null != oneProduct.Length__c
						   && null != oneProduct.Witdth__c
						   && null != oneProduct.Height__c) {

						   	String dimensions = String.format('{0} X {1} X {2}', new String[] { 
										    					 oneProduct.Length__c.format()
										   						,oneProduct.Witdth__c.format()
										   						,oneProduct.Height__c.format()});
							target.put('Dimensions',dimensions);
						}
						else {
							target.put('Dimensions','');
						}

						this.prodReferentialMapList.add(target);
					}
					
					if(!this.prodReferentialMapList.isEmpty())
					{
						this.showTable = true;
					}
                }
            }
		}
		catch(Exception e)
		{
			SO_UTIL.addErrorMessage(e);
		}		
	}

	public List<Map<String, Object>> retQueryResult(String tableId, Integer lim, Integer offset, String sortColumn, String sortOrder)
	{
		setProductRefMapList(tableId, lim, offset, sortColumn, sortOrder);
		return prodReferentialMapList;
	}
	
	public Integer retTotalCount(String tableId)
	{
		Integer totalCount = 0;
		if(this.isClear)
		{
			this.isClear = false;
		}
		else
		{
			try
			{
				totalCount = this.resultCounter;
			}
			catch(Exception e)
			{
				SO_UTIL.addErrorMessage(e);
			}
		}

		return totalCount;
	}

	public void getCurrentPosition(String tableId
								 , Integer totalPages
								 , Integer currentPage
								 , Integer totalRows
								 , Integer currentRow
								 , Integer rowFrom
								 , Integer rowTo)
	{
		if(!this.isClear)
		{
			this.totalRows = totalRows;
			this.startRow = rowFrom;
			this.endRow = rowTo;
		}
	}

	public String retTemplate(String tableId, String field, Object target){

		Map<String, Object> productRef = (Map<String, Object>)target;
		String value = String.valueOf(productRef.get(field));

		if (field == 'Image'){
			String imgTmpl = '<a href="#"><img class="popup-image img-thumbnail" title="<img class=\'img-rounded\'';
			imgTmpl += ' src=\'{0}?wid=300&hei=300\' />"';
			imgTmpl += ' src=\'{0}?wid=60&hei=60\'  /></a>';
			////System.debug('imgPath.value >> ' + value);
			String imgPath = String.isNotBlank(value) ? imgTmpl.replace('{0}', value) : '';
			//System.debug('imgPath >> ' + imgPath);
			return imgPath;

		}
		if (field == 'SKU'){
			return value;
		}
		if (field == 'Category'){ 
			return value;
		}
		if(field == 'Name')
		{
			String producReftId = (String)productRef.get('Actions');
			return '<span id="' + producReftId + '_Name">' + value + '</span>';
		}
		if (field == 'CommercialName'){
			return value;
		}
		if (field == 'Dimensions'){ 
			return value;
		}
		if (field == 'Actions'){
			String producReftId = (String)productRef.get(field);
			String actionStr = '<a href="#open_product" data-id="' + producReftId + '" onclick="producReftId=\'' + producReftId + '\';">See product sheet</a>';
			actionStr += '<input type="button" class="btn btn-default margin-left-md" onclick="onSelectProdRef(\'' + producReftId + '\');" value="Select"/>';
			//actionStr += '<a class="btn btn-default margin-left-md" href="/apex/SO_ProductSpe?id='+ producReftId + '&productRefId=' + producReftId + '">Select</a>';
			//<input type="button" class="btn btn-default margin-left-md" value="Select" onclick="window.location.href=\'/apex/SO_ProductSpe\'" />';
			String imgHolder = '<div id="' + producReftId +'" style="display:none;">';
			imgHolder += '<img class="img-rounded" src="{0}" style="max-width:100%" />';
			imgHolder += '<div class="slides">';
            imgHolder += '<img class="img-thumbnail" src="{1}" />';
            imgHolder += '<img class="img-thumbnail" src="{2}" />';
            imgHolder += '<img class="img-thumbnail" src="{3}" />';
            imgHolder += '<img class="img-thumbnail" src="{4}" /></div>';
                        
			imgHolder = String.format(imgHolder, new String[] {
										 retValue(productRef.get('Image'))
										,retValue(productRef.get('ImageLink2__c'))
										,retValue(productRef.get('ImageLink3__c'))
										,retValue(productRef.get('ImageLink4__c'))
										,retValue(productRef.get('ImageLink5__c')) });

			actionStr = actionStr + imgHolder;

			String descriptionHolder = retDescriptionHolder(productRef);
			actionStr += descriptionHolder; 
			return actionStr;
		}
		return null;	
	}

	//---------------------- Public methods ------------------------
   
	static String retValue(Object val) {
		return null != val ? String.valueOf(val) : '';
	}

	private String retDescriptionHolder(Map<String, Object> target) {
		String oppId = (String)target.get('Actions');
		String str = String.Format('<p id="{0}_p">', new String[] { oppId });
		String conten = '';

		Schema.FieldSet descriptionFieldSet = retDescriptionFieldSet();

		for(Schema.FieldSetMember fieldSetMember : descriptionFieldSet.getFields()) {

			Object fieldValue = target.get(fieldSetMember.getFieldPath());
			String toShowfieldValue = (null != fieldValue) ? String.valueOf(fieldValue) : '&nbsp';
			
			if(String.isNotBlank(conten)) {
				conten += '<br />' + fieldSetMember.getLabel() + ' : '+ toShowfieldValue ;
			}
			else {
				conten = fieldSetMember.getLabel() + ' : '+ toShowfieldValue ;	
			}
		}

        if(String.isNotBlank(conten)) {
        	str += conten;
        }
        else {
        	str += 'NO DESCRIPTION'; //should be custom label
        }
        str += '</p>';
        return str;

	}

	public PageReference updateBriefAndRedirectToProductSpec()
	{
		PageReference pRef = null;
		try
		{
			if(String.isNotBlank(this.selectedProductRef))
			{
				pRef = Page.SO_ProductSpe;
				Opportunity currentBrief = SO_Session.theCurrentBrief;
				if(currentBrief != null)
				{
					pRef.getParameters().put('id', currentBrief.Id);
					currentBrief.SPO_BaseSKURefmodelSKU__c = this.selectedProductRef;
					currentBrief.SPO_ProductCategory__c = entryOpportunity.SPO_ProductCategory__c;
					currentBrief.SPO_OrderType__c = entryOpportunity.SPO_OrderType__c;
					currentBrief.RecordTypeId = SO_UTIL.retRecordTypeIdByName('Opportunity', SO_PicklistDependency.retOppRecordTypeByProdCat(currentBrief.SPO_ProductCategory__c));

					SO_Session.saveSession(currentBrief, theSessionState, true);

					this.selectedProductRef = null;
				}
			}

		}
		catch(Exception exp)
		{
			SO_UTIL.addErrorMessage(exp);
			pRef = null;
		}

		return pRef;
	}

	public String getIdOfProductNotFound()
	{
		String idAns = '';
		try
		{
			String skuCode = SO_Settings__c.getValues(SO_UTIL.PRODUCT_NOT_FOUND_SKU_SETTINGS_NAME).Value__c;
			List<ProductReferential__c> productList = [SELECT Id FROM ProductReferential__c WHERE SKUCode__c = :skuCode];
			if(!productList.isEmpty())
			{
				idAns = productList[0].Id;
			}
		}
		catch(Exception e)
		{
			SO_UTIL.addErrorMessage(e);
		}

		return idAns;
	}

	public void setDefaultValuesForOrderType()
	{
		if(defaultOrderTypeVlauesFieldSet.containsKey(entryOpportunity.SPO_ProductCategory__c))
		{
			entryOpportunity.SPO_OrderType__c = defaultOrderTypeVlauesFieldSet.get(entryOpportunity.SPO_ProductCategory__c);
		}
	}

	public class ProdCatDependency {

		private String oppPD  { get; set; }
		private String prorPD { get; set; }

		public ProdCatDependency(String oppPD, String prorPD) {

			this.oppPD = oppPD;
			this.prorPD = prorPD;

		}
	}

}