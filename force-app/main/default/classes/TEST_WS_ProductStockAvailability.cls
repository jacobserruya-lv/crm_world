@isTest
public class TEST_WS_ProductStockAvailability {
    
    
	@isTest
	static void testGetProductsStoreAvailabilities() {
        
        List<String> selectedStoresRetailStoreId = new List<String>();

        Store__c store = TEST_Utils.createStore('test store', 'TE1');
       	store.StoreLocation__Latitude__s = 24.471912;
		store.StoreLocation__Longitude__s = 54.321014;

        upsert store;
        selectedStoresRetailStoreId.add(store.RetailStoreId__c);

        Store__c store2 = TEST_Utils.createStore('test store2', 'TE2');
        store2.StoreLocation__Latitude__s = 24.471912;
		store2.StoreLocation__Longitude__s = 54.321014;

        upsert store2;
        selectedStoresRetailStoreId.add(store2.RetailStoreId__c);
        
        system.debug('selectedStoresRetailStoreId:'+selectedStoresRetailStoreId);

		ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
        String productId = (String)product.get('Id');
        
        Catalogue_Settings__c CS  = TEST_Utils.createCatalogue_Settings();
     
		System.debug('CS: ' + CS);
        upsert CS;

       // User u = TEST_Utils.createUser('test');

        
        
        Decimal numOfStoresRequested = selectedStoresRetailStoreId.size();
    	User currentUser = DAL_ProductCatalog.getUser();
    	
        system.debug('currentUser:'+currentUser);
    	Last_Digital_Store__c lastDigitalStore = DAL_ProductCatalog.getLastDigitalStore();

    	Store__c defaultStore = (String.isNotEmpty(lastDigitalStore.StoreRetailId__c)) ? 
    		DAL_ProductCatalog.getStoreByCode(lastDigitalStore.StoreRetailId__c) : 
        	store;
    		//DAL_ProductCatalog.getStoreByCode(currentUser.DefaultStore__c);

        system.debug('defaultStore:'+defaultStore);

    	ProductCatalogue__c selectedProduct = DAL_ProductCatalog.getProductCatalogById(productId);
		for(Integer i = 0; i < selectedStoresRetailStoreId.size(); i++) {
			if(selectedStoresRetailStoreId[i] == defaultStore.RetailStoreId__c) {
				selectedStoresRetailStoreId.remove(i);
			}
		}
		
		List<Store__c> selectedStores = DAL_ProductCatalog.getStoresByCodes(selectedStoresRetailStoreId); 
		
        
		//selectedStores.add(defaultStore);
        system.debug('selectedStore:'+selectedStores);
		
    	if(selectedStores != null && selectedStores.size() == 2 && selectedStores[0].StoreLocation__c != null) {
    		List<Store__c> nearbyStores = DAL_ProductCatalog.getNearbyStoresByStoreLocation(selectedStores[0].StoreLocation__c.getLatitude(),selectedStores[0].StoreLocation__c.getLongitude(), 30, selectedStores[0].RetailStoreId__c);
    		if(nearbyStores != null) {
    			selectedStores.addAll(nearbyStores);
    		}
    	}
        
        

      	  Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successProductAvailabilityResponse_Quantity1' , 'ProductStockAvailability'));

        
        
        Test.startTest();

    	Map<String, List<Wrapper_ProductStoreAvailability>> productAvailabilityMap = WS_ProductStockAvailability.getProductsStoreAvailabilities(selectedStores, new List<ProductCatalogue__c>{selectedProduct}, defaultStore);
        system.debug('result:'+productAvailabilityMap);
        system.assertEquals(productAvailabilityMap.values()[0],productAvailabilityMap.get('1234'));
        

        Test.stopTest();
        

        
        


  
        
        
    }
    
    @isTest
	static void testGetProductsStoreAvailabilitiesWithErrorCode() {
        
        List<String> selectedStoresRetailStoreId = new List<String>();

        Store__c store = TEST_Utils.createStore('test store', 'TE1');
       	store.StoreLocation__Latitude__s = 24.471912;
		store.StoreLocation__Longitude__s = 54.321014;

        upsert store;
        selectedStoresRetailStoreId.add(store.RetailStoreId__c);

        Store__c store2 = TEST_Utils.createStore('test store2', 'TE2');
        store2.StoreLocation__Latitude__s = 24.471912;
		store2.StoreLocation__Longitude__s = 54.321014;

        upsert store2;
        selectedStoresRetailStoreId.add(store2.RetailStoreId__c);
        
        system.debug('selectedStoresRetailStoreId:'+selectedStoresRetailStoreId);

		ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
        String productId = (String)product.get('Id');
        
        Catalogue_Settings__c CS  = TEST_Utils.createCatalogue_Settings();
     
		System.debug('CS: ' + CS);
        upsert CS;

       // User u = TEST_Utils.createUser('test');

        
        
        Decimal numOfStoresRequested = selectedStoresRetailStoreId.size();
    	User currentUser = DAL_ProductCatalog.getUser();
    	
        system.debug('currentUser:'+currentUser);
    	Last_Digital_Store__c lastDigitalStore = DAL_ProductCatalog.getLastDigitalStore();

    	Store__c defaultStore = (String.isNotEmpty(lastDigitalStore.StoreRetailId__c)) ? 
    		DAL_ProductCatalog.getStoreByCode(lastDigitalStore.StoreRetailId__c) : 
        	store;
    		//DAL_ProductCatalog.getStoreByCode(currentUser.DefaultStore__c);

        system.debug('defaultStore:'+defaultStore);

    	ProductCatalogue__c selectedProduct = DAL_ProductCatalog.getProductCatalogById(productId);
		for(Integer i = 0; i < selectedStoresRetailStoreId.size(); i++) {
			if(selectedStoresRetailStoreId[i] == defaultStore.RetailStoreId__c) {
				selectedStoresRetailStoreId.remove(i);
			}
		}
		
		List<Store__c> selectedStores = DAL_ProductCatalog.getStoresByCodes(selectedStoresRetailStoreId); 
		
        
		//selectedStores.add(defaultStore);
        system.debug('selectedStore:'+selectedStores);
		
    	if(selectedStores != null && selectedStores.size() == 2 && selectedStores[0].StoreLocation__c != null) {
    		List<Store__c> nearbyStores = DAL_ProductCatalog.getNearbyStoresByStoreLocation(selectedStores[0].StoreLocation__c.getLatitude(),selectedStores[0].StoreLocation__c.getLongitude(), 30, selectedStores[0].RetailStoreId__c);
    		if(nearbyStores != null) {
    			selectedStores.addAll(nearbyStores);
    		}
    	}
        
        
       	  Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successProductAvailabilityResponse' , 'ProductStockAvailability'));


        
        
        Test.startTest();

    	Map<String, List<Wrapper_ProductStoreAvailability>> productAvailabilityMap = WS_ProductStockAvailability.getProductsStoreAvailabilities(selectedStores, new List<ProductCatalogue__c>{selectedProduct}, defaultStore);
        system.debug('result:'+productAvailabilityMap);
        system.assertEquals(productAvailabilityMap.values()[0],productAvailabilityMap.get('1234'));
        

        Test.stopTest();
        

        
        


  
        
        
    }
}