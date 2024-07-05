global with sharing class SO_ProductController {

    @AuraEnabled
    public static SO_ProductPagedResult findAll(String searchKey, String category, Boolean obsolete, Decimal pageSize, Decimal pageNumber) {
		System.debug('findAll=' + searchKey + '-' + category + '-' + obsolete);

        String categoryFilter = buildConditionQuery(category, obsolete);
        Boolean isHardsided = category.equals('Hardsided leather goods');

        Integer pSize = (Integer) pageSize;
        Integer offset = ((Integer)pageNumber - 1) * pSize;
        User currentUser = getUser();

        if (String.isBlank(searchKey) || searchKey.length() < 2){
            SO_ProductPagedResult r = new SO_ProductPagedResult();
            List<ProductReferential__c> productList = new List<ProductReferential__c>();
            r.pageSize = pSize;
            r.page = (Integer) pageNumber;

            if (obsolete){
                /*Integer recCount = 0;
                for(AggregateResult result : [SELECT COUNT(Id) total FROM Account]) {
                    recCount+=(Integer)result.get('total');
                    System.debug('No Of Records:'+recCount);
                }*/

                String queryFrom = ' FROM ProductReferential__c ' + categoryFilter;
                queryFrom += ' AND MainGroup__c ' + (isHardsided ? '=' : '!=') + ' \'HARDSIDED\' ';

                //r.total = [SELECT count() FROM ProductReferential__c LIMIT 2000];
                //AggregateResult result = Database.query('SELECT count(id) total ' + queryFrom);// + ' LIMIT 2000');//[SELECT count() FROM ProductReferential__c LIMIT 2000];
                //r.total = result.get('total');

                //productList = [Select Id, Name, SKUCode__c, SPO_ImageLink1FrontView__c, Length__c, Witdth__c, Height__c, ProductCategory__c 
                //                                        From ProductReferential__c ORDER BY SPO_ProductNameSKU__c LIMIT :pSize OFFSET :offset];
                productList = Database.query('SELECT ' + 
                    'Id, MTO__c, Name, SKUCode__c, SPO_ImageLink1FrontView__c, Length__c, Witdth__c, Height__c, ' +
                    'ProductCategory__c, SPO_Category__c, ImageLink1__c, Creation_Sort_Order__c, MainGroup__c ' + 
                    queryFrom + ' ' +
                    'ORDER BY Creation_Sort_Order__c NULLS LAST, MTO__c DESC, SPO_ProductNameSKU__c ' + 
                    'LIMIT :pSize ' + 
                    'OFFSET :offset'
                );

                List<ProductReferential__c> prodRefList = Database.query('Select Id ' + queryFrom + ' LIMIT 2000');
                r.total = prodRefList.size();

            } else {
                List<String> skus = new List<String>();

                List<ProductCatalogue__c> trunksAndCases = Database.query('SELECT ' + 
                    'sku__c, EligibleSpecialOrder__c, MTO__c ' + 
                    'FROM ProductCatalogue__c ' + 
                    categoryFilter + ' ' + 
                    'AND (Category__r.Name LIKE \'Trunks\' OR Category__r.Name LIKE \'%Cases\') AND Unavailable_Special_Order__c = FALSE ' +
                    'ORDER BY MTO__c DESC ' + 
                    'LIMIT 2000'
                );
                system.debug('trunksAndCases: ' +trunksAndCases);
                for (ProductCatalogue__c p : trunksAndCases){
                    skus.add(p.sku__c);
                }

                List<ProductCatalogue__c> everythingElse = Database.query('SELECT ' + 
                    'sku__c, EligibleSpecialOrder__c, MTO__c ' + 
                    'FROM ProductCatalogue__c ' + 
                    categoryFilter + ' ' + 
                    'AND Sku__c NOT IN :skus AND Unavailable_Special_Order__c = FALSE ' +
                    'ORDER BY MTO__c DESC ' + 
                    'LIMIT 2000'
                );
                system.debug('everythingElse: ' +everythingElse);
                for (ProductCatalogue__c p : everythingElse){
                    skus.add(p.sku__c);
                }


                r.total = [Select count() From ProductReferential__c WHERE SKUCode__c IN :skus LIMIT 2000];
                productList =  Database.query('SELECT ' +
                    'MTO__c, Id, Name, SKUCode__c, SPO_ImageLink1FrontView__c, Length__c, Witdth__c, Height__c, ' + 
                    'ProductCategory__c, SPO_Category__c, ImageLink1__c, Creation_Sort_Order__c ' +
                    'FROM ProductReferential__c ' + 
                    'WHERE SKUCode__c IN :skus ' + 
                    'AND MainGroup__c ' + (isHardsided ? '=' : '!=') + ' \'HARDSIDED\' ' +
                    'ORDER BY Creation_Sort_Order__c NULLS LAST, MTO__c DESC, SPO_ProductNameSKU__c ' + 
                    'LIMIT :pSize ' + 
                    'OFFSET :offset'
                );
            }
            
            r.products              = productList; 
            return r;
        }

        //        String key = '%' + searchKey.replaceAll('','%') + '%';
        //String key = '%' + searchKey + '%';
        //searchKey += '*';
        searchKey = '{*' + searchKey + '*}';


        SO_ProductPagedResult r = new SO_ProductPagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;

        // build WHERE condition
        //String whereRequest = 'WHERE SPO_ProductNameSKU__c LIKE :key ';
        //if (String.isNotBlank(category)) {
        //    whereRequest += ' AND ProductCategory__c = :category '; /* TODO get or not condition: AND Status__c = \'40\'';*/
        //}
		/* the result is replaced by below SOSL, so the count result will be calculated otherwise.
        // count results
        String countRequest = 'SELECT count() FROM ProductReferential__c ' + whereRequest;
        System.debug('countRequest=' + countRequest);
        r.total = Database.countQuery(countRequest); */

        // get products
        /*String productRequest = 'SELECT Id, Name, SKUCode__c, SPO_ImageLink1FrontView__c, Length__c, Witdth__c, Height__c, ProductCategory__c FROM ProductReferential__c ' + whereRequest;
        productRequest += ' ORDER BY SPO_ProductNameSKU__c LIMIT :pSize OFFSET :offset';
        r.products = Database.query(productRequest);*/

        List<ProductReferential__c> fullList = new List<ProductReferential__c>();

        if(obsolete){
            //String categoryFilter = String.isNotBlank(category) ? ' WHERE ProductCategory__c = :category ' : ' ';
            //Replace above SOQL by SOSL due to the search of all fields on ProductReferential__c
            String productSearchQuery = 'FIND ' + 
                String.escapeSingleQuotes(searchKey) + ' ' + 
                'IN SIDEBAR FIELDS RETURNING ProductReferential__c('+
                    'Id, MTO__c, Name, SKUCode__c, SPO_ImageLink1FrontView__c, Length__c, Witdth__c, Height__c, ' + 
                    'ProductCategory__c, SPO_Category__c, ImageLink1__c, Creation_Sort_Order__c ' +  
                    categoryFilter + ' ' + 
                    'AND MainGroup__c ' + (isHardsided ? '=' : '!=') + ' \'HARDSIDED\' ' +
                    'ORDER BY Creation_Sort_Order__c NULLS LAST, SPO_ProductNameSKU__c' + 
                ') ' + 
                'LIMIT 2000';
            //productSearchQuery += ' LIMIT ' + pSize + ' OFFSET ' +offset;
            System.debug('productSearchQuery=' + productSearchQuery);
            
            
            Search.SearchResults searchResults              = search.find(productSearchQuery);
            List<Search.SearchResult> productSearchResults  = searchResults.get('ProductReferential__c');
            fullList        = new List<ProductReferential__c>();
            
            for(Search.SearchResult rsl : productSearchResults){
                fullList.add((ProductReferential__c)rsl.getSObject());
                //r.products = (ProductReferential__c)rsl.getSObject();
               // System.debug('Result from SOSL :' + rsl.getSObject());
            }
        } else {
            //String categoryFilter = String.isNotBlank(category) ? ' WHERE ProductGroup__c = :category ' : ' ';
            
            //Replace above SOQL by SOSL due to the search of all fields on ProductReferential__c
            String productSearchQuery = 'FIND ' + 
                String.escapeSingleQuotes(searchKey) + 
                ' IN SIDEBAR FIELDS RETURNING ProductCatalogue__c(' +
                    'Id, Name, Image1Url__c, LengthCm__c, WidthCm__c, HeightCm__c, TypeName__c, TypeId__c,' +
                    'SKU__c,EligibleSpecialOrder__c  ' + 
                    categoryFilter + ' AND Unavailable_Special_Order__c = FALSE'+ ' ' +
                    'ORDER BY SKU__c' +
                ') ' +
                'LIMIT 2000' ;
            //productSearchQuery += ' LIMIT ' + pSize + ' OFFSET ' +offset;
            System.debug('productSearchQuery=' + productSearchQuery);
            
            
            //Search.SearchResults searchResults              = search.find(productSearchQuery);
            //List<Search.SearchResult> productSearchResults  = searchResults.get('ProductCatalogue__c');
            //List<ProductCatalogue__c> listPCat          = new List<ProductCatalogue__c>();
            List<List<sObject>> searchResults				= search.query(productSearchQuery);
            List<ProductCatalogue__c> listPCat			    = ((List<ProductCatalogue__c>)searchResults[0]);

            //for(Search.SearchResult rsl : productSearchResults){
            //    listPCat.add((ProductCatalogue__c)rsl.getSObject());
            //}
            
            // Set of SKU from Product Catalogue to use in query to find Product Referential 
            Set<String>                 skuSet              = new Set<String>();
            for(ProductCatalogue__c pc:listPCat) {
                skuSet.add(pc.SKU__c);
            }

            for(String sku:skuSet){
                System.debug('$$$$$ This is skuSet :' + sku);
            }

            fullList = Database.query('SELECT '+
                'Id, MTO__c, Name, SKUCode__c, SPO_ImageLink1FrontView__c, Length__c, Witdth__c, Height__c, ' +
                'ProductCategory__c, SPO_Category__c, ImageLink1__c, Creation_Sort_Order__c ' +
                'FROM ProductReferential__c ' +
                'WHERE SKUCode__c IN :skuSet ' +
                'AND MainGroup__c ' + (isHardsided ? '=' : '!=') + ' \'HARDSIDED\' ' +
                'ORDER BY Creation_Sort_Order__c NULLS LAST'
            );
        }

        List<ProductReferential__c> listToReturn = new List<ProductReferential__c>();
		List<String> productIds = new List<String>();
		
        for (Integer i = offset;i<fullList.size() &&  i<offset + pSize; i++){
            listToReturn.add(fullList[i]);
            productIds.add(fullList[i].Id); 
            
        }
       
        //List<Product_Store_Availability__c> productsAvailabilities = SO_Product_DAL.getProudctStoreAvailabilityByIds(productIds, 'Product_Referential__c', '');
        //r.productsStoreAvailabilities = SO_ProductStoreAvailability_Wrapper.convertToProductStoreAvailabilitiesWrappers(productsAvailabilities);
        
        r.total = fullList.size();
        r.products = listToReturn;

        /*r.total = [SELECT count() FROM ProductReferential__c
                   WHERE SPO_ProductNameSKU__c LIKE :key
                   AND ProductCategory__c = :category
                   //AND Status__c = '40' // TODO filter on status?
                  ];
        r.products = [SELECT Id, Name, SKUCode__c, SPO_ImageLink1FrontView__c, Length__c, Witdth__c, Height__c, ProductCategory__c FROM ProductReferential__c
                      WHERE SPO_ProductNameSKU__c LIKE :key
                      //AND Status__c = '40'
                      ORDER BY SPO_ProductNameSKU__c LIMIT :pSize OFFSET :offset];*/
        //List<sObject> resultList = [FIND :key RETURNING ProductReferential__c(Id, Name, SKUCode__c, SPO_ImageLink1FrontView__c, Length__c, Witdth__c, Height__c, ProductCategory__c ORDER BY SPO_ProductNameSKU__c LIMIT :pSize OFFSET :offset)][0];
        //r.products = resultList;
        //r.total = resultList.size();
        
        System.debug('$$$$ this is products ' + r);
        return r;
    }
    
    private static String buildConditionQuery(String category, Boolean obsolete) { 
        String categoryFilter = ' ';
        if (String.isNotBlank(category)) {
            if ('Belts'.equals(category)) {
                category = category.toUpperCase();
            } else if (category.containsIgnoreCase('leather goods')) {
                category = 'Leather Goods';
            }
            categoryFilter = ' WHERE SPO_Category__c =  \'' + category + '\''; //WHERE ProductGroup__c = :category ';
        } 
        else {
            categoryFilter = ' WHERE SPO_Category__c IN ' + getProductCategoryListSpecialOrderSosl();
        }

        if(obsolete)
        {
            categoryFilter += ' AND Is_Special_Sku__c = false';
        }
        
        System.debug('categoryFilter=' + categoryFilter + ' / category=' + category);
		return categoryFilter;
    }
/*   Anthony: dev in progress : want to group ProductReferential or ProductCatalogue objects for Lightning components : Product Summary, Product Gallery
    // class to group ProductReferential or ProductCatalogue objects
    public class ProductWrapper {
        public ProductReferential__c referential; //Page should not used the API field name to facilitate maintenance
        public String name;
        public String sku;
        public String category; // ProductReferential__c.itemDimensionGroup__c, ProductCatalogue__c.ProductReferential__r.itemDimensionGroup__c or ProductCatalogue__c.ProductGroup__c
        public String color;
        public String aestheticLine;
        public String department;

        public String length;
        public String width;
        public String height;
        //public String unit;

        public String pictureLink1; // depending on ProductCatalogue__c.FluidRecipeId__c
        public String pictureLink2;
        public String pictureLink3;
        public String pictureLink4;
        public String pictureLink5;
    }

    @AuraEnabled
    public static ProductWrapper findProductBySObjectId(Id productId) {
        ProductWrapper wrapper;

        if (String.isNotBlank(productId)) {
            String myIdPrefix = String.valueOf(productId).substring(0,3);

            ProductReferential__c ref;
            if (Opportunity.sObjectType.getDescribe().getKeyPrefix().equals(myIdPrefix)) {
                ref = findByOpportunityId(productId);
            } else if (ProductReferential__c.sObjectType.getDescribe().getKeyPrefix().equals(myIdPrefix)) {
                ref = findById(productId);
            } else if (SPO_FirmOrder__c.sObjectType.getDescribe().getKeyPrefix().equals(myIdPrefix)) {
                ref = findByFirmOrderId(productId);
            }

            wrapper.name = ref.name;
            wrapper.sku = ref.SKUCode__c;
            wrapper.category = ref.ProductCategory__c; // ProductReferential__c.itemDimensionGroup__c, ProductCatalogue__c.ProductReferential__r.itemDimensionGroup__c or ProductCatalogue__c.ProductGroup__c
            //wrapper.description;
            wrapper.color = ref.MacroColor__c;
            wrapper.department = ref.Departement__c;
                wrapper.aestheticLine = ref.AestheticLine__c;
            
            wrapper.length = ref.Length__c;
            wrapper.width = ref.Witdth__c;
            wrapper.height = ref.Height__c;
            //wrapper.unit = ref.

            wrapper.pictureLink1 = ref.SPO_ImageLink1FrontView__c; // depending on ProductCatalogue__c.FluidRecipeId__c
            wrapper.pictureLink2 = ref.SPO_ImageLink2SideView__c;
            wrapper.pictureLink3 = ref.SPO_ImageLink3OtherView__c;
            wrapper.pictureLink4 = ref.SPO_ImageLink4InteriorView__c;
            wrapper.pictureLink5 = ref.SPO_ImageLink5OtherView2__c;
        }
        return wrapper;
    }*/
    
    @AuraEnabled
    public static ProductReferential__c findBySObjectId(Id productId) {
        if (String.isNotBlank(productId)) {
            String myIdPrefix = String.valueOf(productId).substring(0,3);

            if (Opportunity.sObjectType.getDescribe().getKeyPrefix().equals(myIdPrefix)) {
                return findByOpportunityId(productId);
            } else if (ProductReferential__c.sObjectType.getDescribe().getKeyPrefix().equals(myIdPrefix)) {
                return findById(productId);
            } else if (SPO_FirmOrder__c.sObjectType.getDescribe().getKeyPrefix().equals(myIdPrefix)) {
                return findByFirmOrderId(productId);
            }
        }
        return null;
    }

    @AuraEnabled
    public static Boolean isMTOEnabled(){
        return SO_Settings__c.getValues('isMTOEnabled').value__c == 'true';
    }

    @AuraEnabled
    public static ProductReferential__c findById(Id productId) {
        return [SELECT id, name, SKUCode__c, SPO_ImageLink1FrontView__c, Length__c, Witdth__c, Height__c, ProductCategory__c,
                SPO_ImageLink2SideView__c, SPO_ImageLink3OtherView__c, SPO_ImageLink4InteriorView__c, SPO_ImageLink5OtherView2__c, ImageLink1__c,
                MacroColor__c, AestheticLine__c, Departement__c
                FROM ProductReferential__c
                WHERE Id=:productId];
    }

    @AuraEnabled
    public static ProductReferential__c findBySku(String sku) {
        system.debug('ds le findBySku');
        return [SELECT id, name, SKUCode__c, MainGroup__c
                FROM ProductReferential__c
                WHERE SKUCode__c = :sku];
    }

    @AuraEnabled
    public static ProductReferential__c findByOpportunityId(Id oppId) {
        Opportunity opp =  [SELECT SPO_BaseSKURefmodelSKU__c
                            FROM Opportunity
                            WHERE Id = :oppId];
        return (opp != null ? findById(opp.SPO_BaseSKURefmodelSKU__c) : null);
    }

    private static ProductReferential__c findByFirmOrderId(Id firmOrderId) {
        SPO_FirmOrder__c firmOrder =  [SELECT SPO_BriefName__r.SPO_BaseSKURefmodelSKU__c, ProductCatalogue__r.FluidRecipeId__c
                            FROM SPO_FirmOrder__c
                            WHERE Id = :firmOrderId];
        return (firmOrder != null ? findById(firmOrder.SPO_BriefName__r.SPO_BaseSKURefmodelSKU__c) : null);
    }

    @AuraEnabled
    public static ProductReferential__c getProductNotFound() {
        ProductReferential__c product;
        try {
            String skuCode = SO_Settings__c.getValues(SO_UTIL.PRODUCT_NOT_FOUND_SKU_SETTINGS_NAME).Value__c;
            List<ProductReferential__c> productList = [SELECT Id, Name, SKUCode__c, ProductCategory__c FROM ProductReferential__c WHERE SKUCode__c = :skuCode];
            if (!productList.isEmpty()) {
                product = productList[0];
            }
        } catch(Exception e) {
            SO_UTIL.addErrorMessage(e);
        }

        return product;
    }
    
    // [Special Order] categories available for Special Order app only. 
    // If a new category is necessary, add the value on Opportunity.SPO_ProductCategory__c and be sure the value is in ProductReferential__c.SPO_Category__c (or ProductCatalogue__c.SPO_Category__c)
    @AuraEnabled
    public static String getProductCategoryJson() {
        List<PicklistEntry> values = getProductCategoryListSpecialOrder();
        //List<PicklistEntry> values = ProductReferential__c.ProductCategory__c.getDescribe().getPicklistValues();
        return JSON.serialize(values);
    }
    private static List<PicklistEntry> getProductCategoryListSpecialOrder() {
        return Opportunity.SPO_ProductCategory__c.getDescribe().getPicklistValues();
    }

    // build 'IN' SOSL
    private static String getProductCategoryListSpecialOrderSosl() {
        List<String> catList = new List<String>();
        for (PicklistEntry entry : getProductCategoryListSpecialOrder()) {
            catList.add(entry.value);
        }
        // to handle the changes from MIY-1360
        catList.add('Leather goods');

        String categoryFilter = ' (';
        for (Integer i=0; i < catList.size(); i++) {
            categoryFilter += '\'' + catList.get(i) + '\'';
            if (i != catList.size()-1) {
                categoryFilter += ',';
            }
        }
        categoryFilter += ')';

        return categoryFilter;
    }

    @AuraEnabled
    public static String getStock(Id productId, String storeName) {
        
        if (productId == null) {
            AuraHandledException ahe = new AuraHandledException('No product selected');
            ahe.setMessage('No product selected');
            throw ahe;
        }

        Store__c store;
        try {
            store = getStore(storeName);
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException('Store not found');
            ahe.setMessage('Store not found');
            ahe.initCause(e);
            throw ahe;
        }
        if (store == null || String.isBlank(store.RetailStoreId__c)) {
            AuraHandledException ahe = new AuraHandledException('No store selected');
            ahe.setMessage('No store selected');
            throw ahe;
        }
        String storeCode = store.RetailStoreId__c;
        
        ProductReferential__c product = findById(productId);
        String skuCode = product.SKUCode__c;
        
        // call WS
        SO_WS_RMS_ItemSearch.itemInformation[] items;
        try {
            items = SO_WS_RMS_DoItemSearch.doItemSearch(skuCode, storeCode);
        } catch (Exception e) {
                AuraHandledException ahe = new AuraHandledException(e.getMessage());
                ahe.setMessage(e.getMessage());
                ahe.initCause(e);
                throw ahe;
        }
        
        // convert
        List<Stock> stockList = new List<Stock>();
        for (SO_WS_RMS_ItemSearch.itemInformation item : items) {
            Stock st = new Stock();
            System.debug(item);
            st.quantity = (String.isNotBlank(item.stockQuantity) ? Integer.valueOf(item.stockQuantity) : 0);
            st.sellable = ('N'.equals(item.sellable) ? false : true);
            st.status = item.stockStatus;
            st.store = store.Name;
            st.sku = skuCode;
            st.productName = product.name;
            st.productImage = product.SPO_ImageLink1FrontView__c;
            stockList.add(st);//Store__c.RetailStoreId__c
        }
        return JSON.serialize(stockList); // serialize for Javascript controller
    }
    
    public class Stock {
        public Integer quantity;
        public Boolean sellable;
        public String status;
        public String store;
        public String sku;
        public String productName;
        public String productImage;
    }
    
    public static User getUser() {
        return [SELECT toLabel(MANAGEMENT_ZONE_LEVEL__c), toLabel(MGMT_ZONE_SUB_LEVEL1__c), toLabel(MGMT_ZONE_SUB_LEVEL2__c), toLabel(MGMT_ZONE_SUB_LEVEL3__c), toLabel(DefaultStore__c)
                FROM User
                WHERE Id =: UserInfo.getUserId()];
    }
    
    private static Store__c getStore(String storeName) {
        
        if (String.isBlank(storeName)) {
            User currentUser = getUser();
            String storeCode = currentUser.DefaultStore__c;
            System.debug('storeCode=' + storeCode);
            return [SELECT RetailStoreId__c, Name FROM Store__c WHERE RetailStoreId__c = :storeCode];
            
        }
        System.debug('storeName=' + storeName);
        return [SELECT RetailStoreId__c, Name FROM Store__c WHERE Name = :storeName];
    }
    /*
@RemoteAction @AuraEnabled
public static ProductReferential__c[] getAvailableProudcts() {
return [SELECT id, name, SKUCode__c, SPO_ImageLink1FrontView__c, Length__c, Witdth__c, Height__c, ProductCategory__c 
FROM ProductReferential__c];
// WHERE Date_Listed__c != NULL AND (Date_Agreement__c = NULL OR Date_Agreement__c = LAST_N_DAYS:90)];
}
*/
    @AuraEnabled
    public static String getUserLocationPickListValues(String objName, List<String> fieldNames) {
        try {
            Map<String, Map<String, List<String>>> mapValuesToFields = new Map<String, Map<String, List<String>>>();
            for(Integer i = 0; i < fieldNames.size() - 1; i++) {
            	Map<String, List<String>> dependentPicklist = DependentPicklistBitset.GetDependentOptions(objName, fieldNames[i], fieldNames[i + 1]);
            	mapValuesToFields.put(fieldNames[i], dependentPicklist);
            }
            
            List<SelectOption> defaultStoreValues = SO_UTIL.getPicklistValues('User', 'DefaultStore__c');
            Map<String, List<String>> storeValuesMap = new Map<String, List<String>>();
            
            for(SelectOption selectOption : defaultStoreValues) {
            	storeValuesMap.put(selectOption.getLabel(), null);
            }
            System.debug('storeValuesMapppp ' + Json.serialize(storeValuesMap));
            mapValuesToFields.put('DefaultStore__c', storeValuesMap);
            return Json.serialize(mapValuesToFields);
        } catch(Exception e) { SO_UTIL.log('getUserLocationPickListValues', e); return null; }
    }
    
    @AuraEnabled
    public static String getUserStr() {
    	try {
    		return Json.serialize(getUser());
    	} catch(Exception e) { SO_UTIL.log('getUserStr', e); return null;}
    }

    // Custom Settings ProductSettings to get different picture size
    @AuraEnabled
    public static ProductSettings__c getProductSettings() {
        return ProductSettings__c.getInstance();
    }

}