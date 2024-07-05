//Created by: Balink 2017
//Description: SOQL querys for Catalog Desktop Application

public with sharing class DAL_ProductCatalog {
	
	public DAL_ProductCatalog() {}
	
	public static final Integer RECORDS_LIMIT = 2000;
	public static final Integer VARIATION_LIMIT = (Integer) (Catalogue_Settings__c.getInstance(System.Label.WSCatalogueTECHUserId)).Variations_Limit__c;

    public static Integer getProductCatalogCount() {
    	try{
    		return [SELECT count() FROM ProductCatalogue__c];
    	}
    	catch(Exception e) { Ctrl_ProductCatalog.log('getProductCatalogCount', e); return 0; }
    }
    
    /*public static List<SObject> getManagementZoneLevel(String zoneLevelName, String zoneLevelFrom, String zoneLevelTo) {
    	String query = 'SELECT '+ zoneLevelFrom + ', ' + zoneLevelTo + ' FROM ' + zoneLevelName;
		return Database.query(query);
    }*/ 
    
    public static Last_Digital_Store__c getLastDigitalStore() {
    	return Last_Digital_Store__c.getInstance();
    }
    
    public static Store_Hierarchy_State__c getStoreHierarchyState() {
    	return Store_Hierarchy_State__c.getInstance(); 
    }

    // public static List<ProductCatalogue__c> getAllProductCatalogs(String searchKey) { 
	// 	List<ProductCatalogue__c> listToReturn = new List<ProductCatalogue__c>();
    // 	try {
    // 		String query = '';
    // 		//List<ProductCatalogue__c> listToReturn = new List<ProductCatalogue__c>();
    // 		//system.debug('I have a search key: '+ searchKey);
    // 		if(searchKey.length() > 1) {
    // 			listToReturn = getProductCatalogsBySearchKey(searchKey);
    // 		} 
    // 		else {
    // 			query += 'SELECT ' + getProductCatalogFields() + ' FROM ProductCatalogue__c  ORDER BY Image1Url__c DESC NULLS LAST LIMIT :RECORDS_LIMIT';
	// 			//System.debug('query ' + query);
	// 			listToReturn = Database.query(query);
    // 		}
	// 		return listToReturn;
    // 	} catch(Exception e) { Ctrl_ProductCatalog.log('getAllProductCategories', e); return null; } 
    // }
    
    public static List<ProductCatalogue__c> getProductCatalogs(Integer offset, Integer pSize) { 
		List<ProductCatalogue__c> listToReturn = new List<ProductCatalogue__c>();
    	try {
    		String query = 'SELECT ' + getProductCatalogFields() + ' FROM ProductCatalogue__c  ORDER BY Image1Url__c DESC NULLS LAST LIMIT :pSize OFFSET :offset';
    		listToReturn =  Database.query(query);
			return listToReturn;
    	} catch(Exception e) { Ctrl_ProductCatalog.log('getAllProductCategories', e); return null; }
    }
    
    /*public static List<ProductCatalogue__c> getProductCatalogsBySKUS(List<String> skus) {
    	try {
    		String query = 'SELECT ' + getProductCatalogFields() + ' FROM ProductCatalogue__c WHERE SKU__c IN :skus LIMIT :RECORDS_LIMIT';
			return Database.query(query); 
    	} catch(Exception e) { Ctrl_ProductCatalog.log('getAllProductCategories', e); return null; }
    }*/
    
    public static List<Store__c> getNearbyStoresByStoreLocation(Double storeLatitude, Double storeLogitude, Decimal range, String storeCode) {
		List<Store__c> stores = new List<Store__c>();
    	try {
    		//List<Store__c> stores = new List<Store__c>();
    		String query = 'SELECT ' + getStoreFields() + ' FROM Store__c ';
    		if(storeLatitude == null || storeLogitude == null) {
    			return stores;
    		}
    		else {
    			query += 'WHERE DISTANCE(StoreLocation__c, GEOLOCATION(:storeLatitude, :storeLogitude), \'km\') <:range ' +
						'AND Status__c = \'Open\' AND RetailStoreId__c != :storeCode AND StoreType__c = \'Store\'';
    		}
    		query += ' LIMIT :RECORDS_LIMIT';
    		stores = Database.query(query); 
			return stores;
    	}
    	catch(Exception e) { Ctrl_ProductCatalog.log('getStoresByName', e); return null; }
    }
    
    
    /*public static List<ProductCatalogue__c> getAllProductCatalogs() { 
    	try {
    		String query = 'SELECT ' + getProductCatalogFields() + ' FROM ProductCatalogue__c WHERE Id IN (SELECT Product_Catalogue__c FROM Product_Store_Availability__c)   LIMIT :RECORDS_LIMIT';
			return Database.query(query);
    	} catch(Exception e) { Ctrl_ProductCatalog.log('getAllProductCatalogs', e); return null; }
    }*/
    
  /*  public static BL_HTTP_Utils requestToGaston(String endpoint, String token, String searchKey){


        BL_HTTP_Utils request = new BL_HTTP_Utils()
                   .get(endpoint + '?q='+searchKey.replaceAll(' ', '%20')+'&fields=skuId,en_E1_commercialName,en_E1_images_url&offset=0&limit=100')
                   .header('Cookie', '__token__=exp' + token)
                   .header('User-Agent', 'AppLauncher/LVAppLauncher')
                   .call();

        System.debug('GASTON REQUEST ' + request);
        return request;
	}*/
	
	public static Gaston__c gastonInstance;
    
    public static String getGastonToken() {
        BL_HTTP_Utils responseToken = new BL_HTTP_Utils()
                .get('callout:GASTON_TOKEN')
				.call();
		String token  = responseToken.responseBody().split('exp')[1].replace('"}','');
        return  token;
	}
	
	public class GastonException extends Exception {

	}

	
    
    /*public static List<Wrapper_ProductCatalog> gastonSearch(String searchKey, Boolean isSFProducts) {
        List<ProductCatalogue__c> listToReturn = new List<ProductCatalogue__c>();
        List<String> skus = new List<String>();
        List<Wrapper_ProductCatalog> pwrappers = new List<Wrapper_ProductCatalog>();
        BL_HTTP_Utils request;
		String properToken;
		Boolean tokenTosave = false;
	        
		gastonInstance = [select id, gastonUrl__c, token__c from gaston__c limit 1];  
		if(gastonInstance == null || gastonInstance.gastonUrl__c == null ){
			throw new GastonException('GASTON_INSTANCE_NOT_DEFINED');
		}
		properToken = gastonInstance.token__c != null ? gastonInstance.token__c : getGastonToken();
		if(gastonInstance.token__c != properToken){
			tokenTosave = true;
			gastonInstance.token__c = properToken;
		}
		
		request = requestToGaston(gastonInstance.gastonUrl__c, properToken, searchKey);
        System.debug('##################### + '+request);
		if (request.statusCode() == 403) {
			System.debug('403: ' + request);
			properToken = getGastonToken();
			if(gastonInstance.token__c != properToken){
				tokenTosave = true;
				gastonInstance.token__c = properToken;
			}
			request = requestToGaston(gastonInstance.gastonUrl__c, properToken, searchKey);
		}
		if(tokenTosave){
			update gastonInstance;
		}
		

		if(request.statusCode() >= 400) {
			throw new GastonException('TOKEN_EXPIRE_OR_REQUEST_FAILED');
		}

		if(request.statusCode() == 200){
			System.debug(request.responseBody());
			List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(request.responseBody());
			System.debug(jsonList);
			for(Object product : jsonList){
				
				Map<String, Object> test = (Map<String, Object>)product;
				Map<String, Object> document =(Map<String, Object>) test.get('document');
				Wrapper_ProductCatalog pc = Wrapper_ProductCatalog.convertToProductCatalogWrapper(document);
				if(searchKey == pc.sku){
					pwrappers = Wrapper_ProductCatalog.convertToProductCatalogWrappers(getProductsCatalogBySkus(new List<String>{pc.sku}), null);
					return pwrappers;
				}
				skus.add(pc.sku);
				pwrappers.add(pc);
			}
			// return 
			if(skus.size() > 0 && isSFProducts == true) {
				system.debug('[PRODUCTS SF]');
				pwrappers = Wrapper_ProductCatalog.convertToProductCatalogWrappers(getProductsCatalogBySkus(skus), null);
			}
		}
        
		return pwrappers;
        
	}*/
	
    
   public static List<ProductCatalogue__c> getProductCatalogsBySearchKey(String searchKey) {
	   List<ProductCatalogue__c> listToReturn = new List<ProductCatalogue__c>();
       System.debug('search key = ' + searchKey );
		try {
			//List<ProductCatalogue__c> listToReturn = new List<ProductCatalogue__c>();
			String findSearchKey = searchKey+'*';

			ProductCatalogue__c test =[Select Id, Name from ProductCatalogue__c Limit 1];

						//String query = 'FIND :searchKey  IN ALL FIELDS RETURNING ProductCatalogue__c(' + getProductCatalogFields() +  '  WHERE SKU__c LIKE \' %'+string.escapeSingleQuotes(searchKey)+'%\' OR Name LIKE \'%'+string.escapeSingleQuotes(searchKey)+'%\' ORDER BY  IsPersoProduct__c ASC, ProductReferential__r.Status__c ASC NULLS FIRST)  LIMIT :RECORDS_LIMIT';
			//String query = 'FIND :findSearchKey  IN ALL FIELDS  RETURNING ProductCatalogue__c(' + string.escapeSingleQuotes(getProductCatalogFields()) +  '  WHERE (isDefaultSku__c = true OR SKU__c = \''+string.escapeSingleQuotes(searchKey)+'\' OR defaultSku__c = \'\') AND  (SKU__c LIKE \' %'+string.escapeSingleQuotes(searchKey)+'%\' OR Name LIKE \'%'+string.escapeSingleQuotes(searchKey)+'%\') ORDER BY  IsPersoProduct__c ASC, ProductReferential__r.Status__c ASC NULLS FIRST)  LIMIT :RECORDS_LIMIT';
			String query = 'FIND :findSearchKey  IN ALL FIELDS  RETURNING ProductCatalogue__c(' + string.escapeSingleQuotes(getProductCatalogFields()) +  '  WHERE (isDefaultSku__c = true OR SKU__c = \''+string.escapeSingleQuotes(searchKey)+'\' OR defaultSku__c = \'\')  AND (NOT Get_Inspired__c LIKE \'%'+string.escapeSingleQuotes(searchKey)+'%\') AND (NOT Discover_the_family_product__c LIKE \'%'+string.escapeSingleQuotes(searchKey)+'%\') ORDER BY  IsPersoProduct__c ASC, ProductReferential__r.Status__c ASC NULLS FIRST)  LIMIT :RECORDS_LIMIT';
			
			//String query = 'FIND :searchKey  IN ALL FIELDS RETURNING ProductCatalogue__c(' + getProductCatalogFields() +  '  WHERE isDefaultSku__c = true AND SKU__c LIKE \'%'+string.escapeSingleQuotes(searchKey)+'%\' OR Name LIKE \'%'+string.escapeSingleQuotes(searchKey)+'%\' AND SKU__c = defaultSku__c ORDER BY  IsPersoProduct__c ASC, ProductReferential__r.Status__c ASC NULLS FIRST)  LIMIT :RECORDS_LIMIT';
			
			//String query = 'SELECT ' + getProductCatalogFields() +  ' FROM ProductCatalogue__c ';
			//query += 'WHERE SKU__c LIKE \'%'+searchKey+'%\' OR Name LIKE \'%'+searchKey+'%\' ORDER BY  IsPersoProduct__c ASC, ProductReferential__r.Status__c ASC NULLS FIRST  LIMIT :RECORDS_LIMIT';
			//system.debug('query ' + query);
			Search.SearchResults searchResults = search.find(query);
			List<Search.SearchResult> productSearchResults  = searchResults.get('ProductCatalogue__c');

			for(Search.SearchResult searchResult : productSearchResults){
				ProductCatalogue__c currentProduct = (ProductCatalogue__c) searchResult.getSObject();
				String ac = currentProduct.AssociateColors__c;
				//system.debug('ac ' + ac);
				//system.debug('sku ' + currentProduct.SKU__c);
				
				if((ac != null && !ac.contains(searchKey)) || currentProduct.SKU__c == searchKey || ac == null){
					listToReturn.add(currentProduct);
				}
			}
			//listToReturn = Database.query(query);
			system.debug('list ' + listToReturn);

			return listToReturn;
		} catch(Exception e) { Ctrl_ProductCatalog.log('getProductCatalogsByFilters', e); return null; }
	}

	public static List<ProductReferential__c> getAllProductReferential(String searchKey) {
		List<ProductReferential__c> PR = new List<ProductReferential__c>();
		String findSearchKey = searchKey+'*';

		try {

		//String productQuery = 'FIND :findSearchKey  IN ALL FIELDS  RETURNING ProductCatalogue__c(' + string.escapeSingleQuotes(getProductCatalogFields()) +  '  WHERE (isDefaultSku__c = true OR SKU__c = \''+string.escapeSingleQuotes(searchKey)+'\' OR defaultSku__c = \'\') AND  (SKU__c LIKE \' %'+string.escapeSingleQuotes(searchKey)+'%\' OR Name LIKE \'%'+string.escapeSingleQuotes(searchKey)+'%\') ORDER BY  IsPersoProduct__c ASC, ProductReferential__r.Status__c ASC NULLS FIRST)  LIMIT :RECORDS_LIMIT';
				
		//String productQuery = 'FIND :findSearchKey  IN ALL FIELDS RETURNING ProductCatalogue__c(' + string.escapeSingleQuotes(getProductCatalogFields()) +  '  WHERE SKU__c LIKE \'%'+string.escapeSingleQuotes(searchKey)+'%\' OR Name LIKE \'%'+string.escapeSingleQuotes(searchKey)+'%\')';
		//String productQuery = 'FIND :findSearchKey  IN ALL FIELDS RETURNING ProductCatalogue__c(' + string.escapeSingleQuotes(getProductCatalogFields()) +  '  WHERE SKU__c LIKE \'%'+string.escapeSingleQuotes(searchKey)+'%\' OR Name LIKE \'%'+string.escapeSingleQuotes(searchKey)+'%\')';
		String productQuery = 'FIND :findSearchKey  IN Name FIELDS  RETURNING ProductCatalogue__c(' + string.escapeSingleQuotes(getProductCatalogFields()) +  '  WHERE (isDefaultSku__c = true OR SKU__c = \''+string.escapeSingleQuotes(searchKey)+'\' OR defaultSku__c = \'\')  ORDER BY  IsPersoProduct__c ASC, ProductReferential__r.Status__c ASC NULLS FIRST)  LIMIT :RECORDS_LIMIT';
			
			Search.SearchResults searchResults = search.find(productQuery);
			List<Search.SearchResult> productSearchResults  = searchResults.get('ProductCatalogue__c');
			List<String> SkuToReturn = new List<String>();
			for(Search.SearchResult searchResult : productSearchResults){
				ProductCatalogue__c currentProduct = (ProductCatalogue__c) searchResult.getSObject();
				SkuToReturn.add(currentProduct.SKU__c);
			}
			//String productQuery = 'SELECT SKU__c  FROM ProductCatalogue__c WHERE SKU__c LIKE \'%'+searchKey+'%\' OR Name LIKE \'%'+searchKey+'%\'';
			//system.debug('my query '+ productQuery);
            /*List<ProductCatalogue__c> products = new List<ProductCatalogue__c>();
            products = Database.query(productQuery);
			List<String> SkuToReturn = new List<String>();
			//string sku = new String();
            for(ProductCatalogue__c pc:products){
				system.debug('in for with sku '+pc.SKU__c);
				
				//if(pc.SKU__c.containsNone('*')){
					//system.debug('not containg a star');
                	SkuToReturn.add(pc.SKU__c);
				//}
            }*/
			system.debug('my sku list '+SkuToReturn);
			String stringSearch='%'+string.escapeSingleQuotes(searchKey)+'%';
			
			/*PR =  [Select Id, Name, Description__c, Status__c, OrderableEMEA__c, OrderableJapan__c, OrderableMiddleEast__c, OrderableNorthAmerica__c, OrderableNorthAsia__c,
				OrderableSouthAsia__c, ImageLink1__c, SKUCode__c, SPO_ImageLink1FrontView__c, SPO_ImageLink2SideView__c, SPO_ImageLink3OtherView__c, SPO_ImageLink4InteriorView__c,
            SPO_ImageLink5OtherView2__c, Group__c, Height__c, Length__c, Witdth__c, MacroColor__c
						FROM ProductReferential__c 
					WHERE (SKUCode__c LIKE :stringSearch OR Name LIKE :stringSearch) 
						AND SKUCode__c NOT IN :SkuToReturn AND Status__c != '30'
						ORDER BY  Status__c ASC NULLS FIRST  LIMIT :RECORDS_LIMIT]; 

			return PR;*/
			
			//String queryPR = 'FIND :findSearchKey  IN ALL FIELDS RETURNING ProductReferential__c(' + string.escapeSingleQuotes(getProductReferentialFields()) +  '  WHERE (SKUCode__c LIKE :stringSearch OR Name LIKE :stringSearch) AND SKUCode__c NOT IN :SkuToReturn AND Status__c != \'30\')';
			String queryPR = 'FIND :findSearchKey  IN ALL FIELDS RETURNING ProductReferential__c(' + string.escapeSingleQuotes(getProductReferentialFields()) +  '  WHERE SKUCode__c NOT IN :SkuToReturn AND Status__c != \'30\')';
			
			//String query = 'SELECT ' + getProductCatalogFields() +  ' FROM ProductCatalogue__c ';
			//query += 'WHERE SKU__c LIKE \'%'+searchKey+'%\' OR Name LIKE \'%'+searchKey+'%\' ORDER BY  IsPersoProduct__c ASC, ProductReferential__r.Status__c ASC NULLS FIRST  LIMIT :RECORDS_LIMIT';
			system.debug('query ' + queryPR);
			Search.SearchResults searchResultsPR = search.find(queryPR);
			List<Search.SearchResult> productSearchResultsPR  = searchResultsPR.get('ProductReferential__c');

			for(Search.SearchResult searchResultPR : productSearchResultsPR){
				ProductReferential__c currentProductPR = (ProductReferential__c) searchResultPR.getSObject();
			PR.add(currentProductPR);
			}
			//listToReturn = Database.query(query);
			system.debug('list ' + PR);

			return PR;

		} catch(Exception e) { Ctrl_ProductCatalog.log('getProducReferentialByFilters', e); return null; }
	}
    
    public static ProductCatalogue__c getProductCatalogById(String productId) { 
		ProductCatalogue__c PC = new ProductCatalogue__c();
    	try {
    		String query = 'SELECT ' +  string.escapeSingleQuotes(getProductCatalogFields()) + ' FROM ProductCatalogue__c WHERE Id =: productId' ;
			List<ProductCatalogue__c> products = Database.query(query); 
			return  (products != null && products.size() == 1) ? products[0] : PC;
    	} catch(Exception e) { Ctrl_ProductCatalog.log('getAllProductCategories', e); return null; }
    	
    }
    
    /*public static List<ProductCatalogue__c> getProductsCatalogByIds(List<String> productsIds) { 
        System.debug('products: ' + productsIds);
		List<ProductCatalogue__c> products = new List<ProductCatalogue__c>();
    	try {
            String query = 'SELECT ' + getProductCatalogFields() + ' FROM ProductCatalogue__c WHERE Id IN :productsIds' ;
			List<ProductCatalogue__c> products = Database.query(query); 
			retrun products;
			//return (products != null && products.size() >= 1) ? products : null;	
    	} catch(Exception e) { Ctrl_ProductCatalog.log('getProductsCatalogByIds', e); return products; }
    	
    }*/
    
    public static List<ProductCatalogue__c> getProductsCatalogBySkus(List<String> productsSkus) { 
        System.debug('products: ' + productsSkus);
        System.debug('products size: ' + productsSkus.size());
		//List<ProductCatalogue__c> products = new List<ProductCatalogue__c>();
    	try {
            String query = 'SELECT ' +  string.escapeSingleQuotes(getProductCatalogFields()) + ' FROM ProductCatalogue__c WHERE SKU__c IN :productsSkus' ;
			List<ProductCatalogue__c> products = Database.query(query); 
            List<ProductCatalogue__c> listToreturn = new List<ProductCatalogue__c>();
            Map<String, ProductCatalogue__c> mapPc = new Map<String, ProductCatalogue__c>();
            for(ProductCatalogue__c pc : products){
                mapPc.put(pc.SKU__c,pc);
            }
            for(String sku : productsSkus){
                if(mapPc.get(sku) != null) {
                    listToreturn.add(mapPc.get(sku));
                }	
            }
            System.debug('getProductsCatalogBySkus: ' + listToreturn);
			return listToreturn;
			//return (products != null && products.size() >= 1) ? products : null;	
    	} catch(Exception e) { Ctrl_ProductCatalog.log('getProductsCatalogBySkus', e); return null; }
    	
    }
    
    
    public static User getUser() {
		try {
    		/*return [SELECT toLabel(MANAGEMENT_ZONE_LEVEL__c), toLabel(MGMT_ZONE_SUB_LEVEL1__c), toLabel(MGMT_ZONE_SUB_LEVEL2__c), toLabel(MGMT_ZONE_SUB_LEVEL3__c), DefaultStore__c
                FROM User WHERE Id =: UserInfo.getUserId()];*/
			/*if(test.isRunningTest()){
				return [SELECT My_Stores_Lists__c, DefaultStore__c, My_Favorites__c
						FROM User limit 1];
			}else{*/
				return [SELECT My_Stores_Lists__c, DefaultStore__c, My_Favorites__c
						FROM User WHERE Id =: UserInfo.getUserId()];
			//}

    	} catch(Exception e) { Ctrl_ProductCatalog.log('getUser', e); return null; }
    }
    
    
    public static List<Store__c> getStoresByNames(List<String> storeNames) {
		try {
    		String query = 'SELECT ' +  string.escapeSingleQuotes(getStoreFields()) + ' FROM Store__c WHERE Name IN :storeNames LIMIT :RECORDS_LIMIT';
			List<Store__c> stores = Database.query(query); 
			return stores;
    	}
    	catch(Exception e) { Ctrl_ProductCatalog.log('getStoresByName', e); return null; }
    }
    
    public static List<Store__c> getStoresByCodes(List<String> storeCodes) {
		try {
    		String query = 'SELECT ' +  string.escapeSingleQuotes(getStoreFields()) + ' FROM Store__c WHERE RetailStoreId__c IN :storeCodes LIMIT :RECORDS_LIMIT';
			List<Store__c> stores = Database.query(query); 
			return stores;
    	}
    	catch(Exception e) { Ctrl_ProductCatalog.log('getStoresByCodes', e); return null; }
    }
    
    public static Store__c getStoreByCode(String storeCode) { 
		Store__c store = new Store__c();
		try {
			List<Store__c> stores = getStoresByCodes(new List<String>{storeCode});
			return (stores != null && stores.size() > 0) ? stores[0] : store;
    	}
    	catch(Exception e) { Ctrl_ProductCatalog.log('getStoresByCode', e); return null; }
    }
    
    public static List<Store__c> getAllStores() {
		try {
    		String query = 'SELECT ' +  string.escapeSingleQuotes(getStoreFields()) + ' FROM Store__c LIMIT :RECORDS_LIMIT';
			List<Store__c> stores = Database.query(query); 
			//return (stores != null && stores.size() > 0) ? stores : stores;
			return stores;
    	}
    	catch(Exception e) { Ctrl_ProductCatalog.log('getStoresByName', e); return null; }
    }
    
    public static List<Store__c> getStoresByIds(List<String> storeIds) {
		try {
    		String query = 'SELECT ' +  string.escapeSingleQuotes(getStoreFields()) + ' FROM Store__c WHERE Id IN :storeIds LIMIT :RECORDS_LIMIT';
			List<Store__c> stores  = Database.query(query); 
			//return (stores != null && stores.size() > 0) ? stores : null;
			return stores;
    	}
    	catch(Exception e) { Ctrl_ProductCatalog.log('getStoresByName', e); return null; }
    }
    
    
    public static Store__c getStoreByName(String storeName) { 
		Store__c store = new Store__c();
		try {
    		List<Store__c> stores  = getStoresByNames(new List<String>{storeName});
    		return (stores != null && stores.size() == 1) ? stores[0] : store;
			
    	}
    	catch(Exception e) { Ctrl_ProductCatalog.log('getStoreByName', e); return null; }
    }
    
    public static Store__c getStoreById(String storeId) {
		Store__c store = new Store__c();
		try {
    		List<Store__c> stores = getStoresByIds(new List<String>{storeId});
    		return (stores != null && stores.size() == 1) ? stores[0] : store;		
    	}
    	catch(Exception e) { Ctrl_ProductCatalog.log('getStoreByName', e); return null; }
    }

	public static List<Store__c> getActiveStores() {
		try {
			String query = 'SELECT ' +  string.escapeSingleQuotes(getStoreFields()) + ' FROM Store__c  WHERE Status__c = \'Open\' AND StoreType__c = \'Store\' ' +
			' ORDER BY RetailStoreId__c ASC';
			List<Store__c> stores = Database.query(query);
			//return (stores != null && stores.size() > 0) ? stores : null;
			return stores;
		
		}
		catch(Exception e) { Ctrl_ProductCatalog.log('getActiveStores', e); return null; }
	}

	/*public static List<Store__c> getStoreHierarchy() {
		try {
			String query = 'SELECT ' +  string.escapeSingleQuotes(getStoreFields()) + ' FROM Store__c  WHERE StoreCountry__c != null AND Status__c = \'Open\' AND (StoreType__c = \'Store\' || StoreType__c =\'POP UP - OON\') GROUP BY MANAGEMENT_ZONE_LEVEL_TECH__c, StoreCountry__c, Name, RetailStoreId__c';
			List<Store__c> stores = Database.query(query);
			return (stores != null && stores.size() > 0) ? stores : null;
		}
		catch(Exception e) { Ctrl_ProductCatalog.log('getStoreHierarchy', e); return null; }
	}*/

	public static List<ProductCatalogue__c> getRecentlyPublishedProducts(Integer numLimitNew) {
		try {
			//String query = 'SELECT ' + getProductCatalogFields() + ' FROM ProductCatalogue__c ORDER BY CreatedDate DESC LIMIT :numLimitNew' ;
			String query = 'SELECT ' +  string.escapeSingleQuotes(getProductCatalogFields()) + ' FROM ProductCatalogue__c WHERE ViewOnline__c = TRUE AND (NOT SKU__c LIKE \'NVSKU%\') AND (CreatedDate = LAST_N_MONTHS:4 OR CreatedDate = THIS_MONTH) AND (isDefaultSku__c = true OR defaultSku__c =\'\') ORDER BY ViewOnlineDate__c DESC NULLS LAST LIMIT :numLimitNew' ;
			//system.debug('query ' + query);
			List<ProductCatalogue__c> products = Database.query(query);
			//system.debug('products'+ products);
			//return (products != null && products.size() >= 1) ? products : null;
			return products;
		} catch(Exception e) { Ctrl_ProductCatalog.log('getRecentlyPublishedProducts', e); return null; }
	}
    
    public static Boolean haveStockInRegion(String zone, String warhouseName, Id productId){
		system.debug('zone '+zone);
		system.debug('warhouseName '+ warhouseName);
		system.debug('productId '+ productId);
        //String Query = 'SELECT Id FROM Product_Stock__c Where Zone__c =:zone AND Store__r.Store_Region__c =:warhouseName AND Product__c =:productId and Quantity__c > 0 AND CreatedDate > 2019-09-01T00:00:00Z';
		//system.debug('Query '+ Query);
	   List<Product_Stock__c> productstock = [SELECT Id FROM Product_Stock__c Where Zone__c =:zone AND Store__r.Store_Region__c =:warhouseName AND Product__c =:productId and Quantity__c > 0 AND CreatedDate > 2019-09-01T00:00:00Z];
		
		//List<Product_Stock__c> productstock = Database.query(Query);
		system.debug('productstock '+ productstock.size());
		if(productstock.size() > 0){
			system.debug('returnig true');
			return true;
		}else{
			return false;
		}
        
    }

	public static List<ProductCatalogue__c> getSizes(String defaultSku, String MarketingColorId, String Order, String OrderBY, String Condition){
		try{
			List<ProductCatalogue__c> products = new List<ProductCatalogue__c>();
			if(defaultSku != null) {
				String query = 'SELECT ' +  string.escapeSingleQuotes(getProductCatalogFields()) + ' FROM ProductCatalogue__c WHERE defaultSku__c =: defaultSku AND MarketingColorId__c =: MarketingColorId ' + Condition + ' ORDER BY '+OrderBY +' ' +Order ;
				system.debug('query ' + query);

				
				if (VARIATION_LIMIT > 0){

					query += ' LIMIT :VARIATION_LIMIT' ;
		    	}

				
				products = Database.query(query);
			}
			return products;
	
		} catch(Exception e) { Ctrl_ProductCatalog.log('getSize', e); return null; }
	}
	
	public static List<ProductCatalogue__c> getColorVariations(String colorSku, String size){
		try{
			List<ProductCatalogue__c> products = new List<ProductCatalogue__c>();
			if(colorSku != null) {
				List<String> colors = colorSku.split(',');
				String query = 'SELECT ' +  string.escapeSingleQuotes(getProductCatalogFields()) + ' FROM ProductCatalogue__c WHERE SKU__c IN :colors AND sizeId__c =:size AND ProductReferential__r.Status__c < \'50\'  Order BY MacroColorName__c';
				
				products = Database.query(query);
			}
			return products;                              
	
		} catch(Exception e) { Ctrl_ProductCatalog.log('getColorVariations', e); return null; }
	}

	public static List<ProductCatalogue__c> getOtherVariations(String bccIds){
		try{
			List<ProductCatalogue__c> products = new List<ProductCatalogue__c>();
			if(bccIds != null) {

				List<String> ids = bccIds.split(',');
				String query = 'SELECT ' +  string.escapeSingleQuotes(getProductCatalogFields()) + ' FROM ProductCatalogue__c WHERE BccProductId__c IN :ids AND (isDefaultSku__c = true OR defaultSku__c =\'\')';
				
				system.debug('query ' + query);
				products = Database.query(query);
			}
			return products;
	
		} catch(Exception e) { Ctrl_ProductCatalog.log('getOtherVariations', e); return null; }
	}

	public static List<ProductCatalogue__c> getSkinVariations(String skus){
		try{
			List<ProductCatalogue__c> products = new List<ProductCatalogue__c>();

			if(skus != null) {
				string skusFormatted = skus.replace('[','');
					   skusFormatted = skusFormatted.replace(']','');
				List<String> ids = skusFormatted.split(',');
				system.debug('getSkinVariations ids : ' +ids );


				String query = 'SELECT ' +  string.escapeSingleQuotes(getProductCatalogFields()) + ' FROM ProductCatalogue__c WHERE SKU__c IN :ids ';
				
				system.debug('query ' + query);
				products = Database.query(query);
			}
			system.debug('getSkinVariations products : ' +products );

			return products;
	
		} catch(Exception e) { Ctrl_ProductCatalog.log('getSkinVariations', e); return null; }
	}

	public static void updateProductPdf(String sku, string pdf){
		//String query = 'UPDATE Pdf_Url__c = \'' +string.escapeSingleQuotes(pdf)+'\' , Pdf_Url_Date ='+date.today() +' Where SKU__c =\''+string.escapeSingleQuotes(sku)+'\'';
		//Database.query(query);
		ProductCatalogue__c pc = [Select Pdf_Url_Date__c, Pdf_Url__c, SKU__c from productCatalogue__c where SKU__c =:sku];
		system.debug('pc' + pc);
		pc.Pdf_Url__c = pdf;
		pc.Pdf_Url_Date__c = Date.today();
		update pc;
	}

	public static String getProductCatalogFields() {
		return 'Id, Name, Description__c, DetailedDescription__c, HeightCm__c, Image1Url__c, Image2Url__c, Image3Url__c, ' +
			'Image4Url__c, Image5Url__c, LengthCm__c, MacroColorName__c, ProductReferential__r.Name, SKU__c, WidthCm__c, Price__c , LengthInch__c, WidthInch__c, HeightInch__c, ' +
            'ProductGroup__c, SizeName__c, SPO_Category__c, ProductReferential__c, IsPersoProduct__c,  StockRequest__c, Category__c, ProductReferential__r.Status__c, MiyCom__c, '+
				'ProductReferential__r.OrderableEMEA__c, ProductReferential__r.OrderableJapan__c, ProductReferential__r.OrderableMiddleEast__c, ProductReferential__r.OrderableNorthAmerica__c, '+
				'ProductReferential__r.OrderableNorthAsia__c, ProductReferential__r.OrderableSouthAsia__c, Capped_Hot_SKU__c, defaultSku__c,  AssociateColors__c, ' +
				'AssociatedModelSize__c, AssociateMaterials__c, BccProductId__c, MacroColorId__c, MaterialName__c, MarketingColorName__c, MarketingColorId__c, TypeName__c, SizeId__c,material_image__c, '+
				'en_E1_size__c,color_image__c, Pdf_Url__c, Pdf_Url_Date__c, Season__c , longSkuId__c, ProductReferential__r.Departement__c, ShoeWidth__c, AssociateSkinMaterials__c, toLabel(SkinMaterial__c) SkinMaterialLabel, '+
            'Model_material__c,Weaving__c,Dyeingprinting__c,Stiching__c,Manufacturingfp__c,Assembly__c,Finition__c,Recycledfp__c,Synth__c,Recyclabilityfp__c,isRecyclable__c,Dangeroussubstances__c,Preciousmetals__c,Rareearth__c,engravingType__c,engravingEnabled__c';
	}
	
	public static String getStoreFields() {
		return 'Id, Name, Address__c, ClosedDate__c, OpeningHours__c, CommercialName__c, Status__c, StoreCountry__c, ' +
				'StoreLocation__c, StoreType__c, Zone__c, Currency__c, RetailStoreId__c, StoreLocation__Latitude__s, ' +
				'StoreLocation__Longitude__s, MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL3__c, '+
				'Store_CountryCode__c, MANAGEMENT_ZONE_LEVEL_TECH__c, toLabel(Store_Region__c), Duty_Free_Store__c';
	}

	public static String getProductReferentialFields() {
		return 'Id, Name, Description__c, Status__c, OrderableEMEA__c, OrderableJapan__c, OrderableMiddleEast__c, OrderableNorthAmerica__c, OrderableNorthAsia__c,'+
				'OrderableSouthAsia__c, ImageLink1__c, SKUCode__c, SPO_ImageLink1FrontView__c, SPO_ImageLink2SideView__c, SPO_ImageLink3OtherView__c,'+
				' SPO_ImageLink4InteriorView__c, SPO_ImageLink5OtherView2__c, Group__c, Height__c, Length__c, Witdth__c, MacroColor__c';
	}

		public static List<ICX_CustomizableProducts__mdt> getPersonalizedProducts()
    {
        List<ICX_CustomizableProducts__mdt> personalizedProducts = [SELECT ProductName__c,ProductCategory__c,customProductImage__c,ProductSKU__c 
                                                                    FROM ICX_CustomizableProducts__mdt WHERE ProductName__c!= NULL];
        return personalizedProducts;
    }

}