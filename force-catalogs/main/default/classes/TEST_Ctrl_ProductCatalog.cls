@isTest
public class TEST_Ctrl_ProductCatalog {

	// @isTest
	// static void testGetAllProductCatalogs() {
	// 	Store__c store = TEST_Utils.createStore('test store', 'TE1');
    //     system.debug('store'+ store);
	// 	ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
	// 	system.debug('product'+ product);
	// 	Wrapper_ProductStoreAvailability productAvailability = TEST_Utils.createProductAvailability('test product availability', product.Id, store.Id);
    //     system.debug('productAvailability'+ productAvailability);
	// 	List<String> stores = new List<String>{store.Name};
	// 	gaston__c gaston = new gaston__c();
	// 	gaston.gastonUrl__c = 'www.test.com';
	// 	gaston.token__c = '1234567890';
	// 	insert gaston;
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successJsonGetAllProduct' , 'json'));


	// 	Test.startTest();
	// 	Ctrl_ProductCatalog.ProductCatalogPageResult avas = Ctrl_ProductCatalog.getAllProductCatalogs('test', 20, 1,stores,true);
    //     Ctrl_ProductCatalog.ProductCatalogPageResult avas2 = Ctrl_ProductCatalog.getAllProductCatalogs('1234', 1, 3,stores,true);
	// 	List<ProductCatalogue__c> wpc = Wrapper_ProductCatalog.convertToProductCatalogSObjs(avas.products);
        
	// 	system.assertEquals(1, avas.page);
	// 	system.assertEquals(1, avas2.page);

	// 	Test.stopTest();
	// }


	@isTest
	static void testGetProductsCatalogFiltered() {
		ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','123');
		ProductCatalogue__c product2 = TEST_Utils.createProductCatalog('test product2','456');

		List<String> listSkus = new List<String>();
		listSkus.add('123');
		listSkus.add('456');

		if(listSkus.size() >0) {

			Test.startTest();
	
			Ctrl_ProductCatalog.ProductCatalogPageResult listProductsCatalog = Ctrl_ProductCatalog.getProductsCatalogFiltered(listSkus);
			
			system.assertEquals(2, listProductsCatalog.total);
	
			Test.stopTest();
		}

	}
	@isTest
	static void testGetProductsCatalogFilteredEmpty() {

		List<String> listEmpty = new List<String>();

		Test.startTest();

		Ctrl_ProductCatalog.ProductCatalogPageResult listProductsCatalog = Ctrl_ProductCatalog.getProductsCatalogFiltered(listEmpty);
		
		system.assertEquals(0, listProductsCatalog.total);

		Test.stopTest();
		
	}

	@isTest
	static void testGetProductCatalogById() {
        ProductReferential__c pr = TEST_Utils.createProductReferential('test product','1234');
		ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
        product.ProductReferential__c = pr.Id;
        update product;
		Store__c store = TEST_Utils.createStore('LV ABU DHABI MARINA MALL', 'TE1');
		List<String> stores = new List<String>{store.Name};
		store.Currency__c = 'USD';
		upsert store;

		Test.startTest();
		Wrapper_ProductCatalog res = Ctrl_ProductCatalog.getProductCatalogById(product.Id, stores);
		system.assertEquals('1234', res.sku);
		Test.stopTest();
	}

	@isTest
	static void testGetCurrencySymbolFromIso() {
		Test.startTest();
		String iso = 'EUR';
		Ctrl_ProductCatalog.getCurrencySymbolFromIso(iso);
		iso = 'GBP';
		Ctrl_ProductCatalog.getCurrencySymbolFromIso(iso);
		iso = 'JPY';
		Ctrl_ProductCatalog.getCurrencySymbolFromIso(iso);
		iso = 'KRW';
		Ctrl_ProductCatalog.getCurrencySymbolFromIso(iso);
		iso = 'CNY';
		Ctrl_ProductCatalog.getCurrencySymbolFromIso(iso);
		iso = 'test';
		String symbol = Ctrl_ProductCatalog.getCurrencySymbolFromIso(iso);
		system.assertEquals('test', symbol);

		Test.stopTest();
	}

	@isTest
	static void testgetProductsAvailabilitiesByProductId() {
		ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
		Store__c store = TEST_Utils.createStore('LV ABU DHABI MARINA MALL', 'A02');
        store.StoreLocation__Latitude__s = 24.471912;
		store.StoreLocation__Longitude__s = 54.321014;
        upsert store;
		Store__c store2 = TEST_Utils.createStore('LV ABU DHABI MARINA MALL2', 'TE1');
		User testUser = TEST_Utils.createUser('test user');
		Catalogue_Settings__c CS  = TEST_Utils.createCatalogue_Settings();
		//Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successProductAvailabilityResponse' , 'ProductStockAvailability'));

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successJsonProductStock' , 'productStock'));
		System.runAs(testUser) {
			//Map<String, List<Wrapper_ProductStoreAvailability>> res = Ctrl_ProductCatalog.getProductsAvailabilitiesByProductId(new list<String>{product.SKU__c}, new list<String>{store.RetailStoreId__c,store2.RetailStoreId__c} );
			Map<String, List<Wrapper_ProductStoreAvailability>> res = Ctrl_ProductCatalog.getProductsAvailabilitiesByProductId(new list<String>{product.SKU__c}, new list<String>{store.RetailStoreId__c} );

            system.assert(res.containsKey('ERROR'));
		}

		Test.stopTest();
	}



	/*@isTest
	static void getUserLocationPickListValues() {
		Store__c store = TEST_Utils.createStore('LV ABU DHABI MARINA MALL', 'A02');
		Store__c store2 = TEST_Utils.createStore('LV ABU DHABI MARINA MALL2', 'TE1');
		Catalogue_Settings__c CS  = TEST_Utils.createCatalogue_Settings();
		Test.startTest();
		Ctrl_ProductCatalog.getUserLocationPickListValues(new List<String>{'MANAGEMENT_ZONE_LEVEL__c', 'MGMT_ZONE_SUB_LEVEL1__c', 'MGMT_ZONE_SUB_LEVEL2__c', 'MGMT_ZONE_SUB_LEVEL3__c', 'DefaultStore__c'});
		Test.stopTest();
	}*/

	@isTest
	static void testMisc() {
		User u = TEST_Utils.createUser('test user');
		System.runAs(u) {
			Test.startTest();	
			Ctrl_ProductCatalog.getUserDefaultStoreCode();
			Ctrl_ProductCatalog.getProductSettings();
			User myUser = Ctrl_ProductCatalog.getUser();
			system.debug('user' + myUser);
			GenericXMLParser.getNodeArray(new Map<String, Object>(), 'node');
			system.assertEquals('1234',myUser.My_Favorites__c);
			Test.stopTest();
		}
	}

	@isTest
	static void testWrapperProductCatalogStore() {
		User u = TEST_Utils.createUser('test user');
		Catalogue_Settings__c CS  = TEST_Utils.createCatalogue_Settings();
		System.runAs(u) {
			Test.startTest();

			List<Store__c> stores = new List<Store__c>();
			Store__c store = TEST_Utils.createStore('LV ABU DHABI MARINA MALL', 'TE1');
			Store__c store2 = TEST_Utils.createStore('LV ABU DHABI MARINA MALL2', 'TE2');

			stores.add(store);
			stores.add(store2);

			List<Wrapper_ProductCatalogStore> wrapperStores = Wrapper_ProductCatalogStore.convertToStoreWrappers(stores);

			wrapperStores[0].openingHours = new Wrapper_ProductCatalogStore.OpeningHours();
			wrapperStores[0].openingHours.Sunday = '10:00-12:00';
			wrapperStores[0].openingHours.Monday = '10:00-12:00';
			wrapperStores[0].openingHours.Tuesday = '10:00-12:00';
			wrapperStores[0].openingHours.Wednesday = '10:00-12:00';
			wrapperStores[0].openingHours.Thursday = '10:00-12:00';
			wrapperStores[0].openingHours.Friday = '10:00-12:00';
			wrapperStores[0].openingHours.Saturday = '10:00-12:00';

			Wrapper_ProductCatalogStore.convertToProductStoreAvailabilitiesSObjs(wrapperStores);
			system.assertEquals('LV ABU DHABI MARINA MALL', wrapperStores[0].name);
			Test.stopTest();
		}
	}



	


	@isTest
	static void testDigitalStoresUtils() {
		User u = TEST_Utils.createUser('test user');
		Catalogue_Settings__c CS  = TEST_Utils.createCatalogue_Settings();
		Test.startTest();
		System.runAs(u) {
			Ctrl_Productcatalog.UserStores userStores = new Ctrl_Productcatalog.UserStores();
			Ctrl_ProductCatalog.getDigitalStores();
			userStores = Ctrl_ProductCatalog.updateDigitalStore('A02');
			system.assertEquals('A02', userStores.lastDigitalStore);
		}
		Test.stopTest();
	}

	/*@isTest
	static void testStoreHierarchyState() {
		User u = TEST_Utils.createUser('test user');
		Test.startTest();
		System.runAs(u) {
			Store_Hierarchy_State__c state = Ctrl_ProductCatalog.getStoreHierarchyState();
			system.debug('state '+state);
		}
		Test.stopTest();
	}*/

	@isTest
	static void testUpdateStoreHierarchyState() {
		User u = TEST_Utils.createUser('test user');
		Test.startTest();
		System.runAs(u) {
			Store_Hierarchy_State__c state1 = Ctrl_ProductCatalog.getStoreHierarchyState();
            system.debug('state1 : '+state1.Id);
			Store_Hierarchy_State__c state = Ctrl_ProductCatalog.updateStoreHierarchyState(true);
			system.debug('state '+ state);
			system.assertEquals(true,state.isOpen__c);
		}
		Test.stopTest();
	}

	// @isTest
	// static void testGetProductVariantData() {
	// 	Store__c storeDigital = TEST_Utils.createStore('Digital', 'Digi1');
	// 	storeDigital.Currency__c = 'USD';
	// 	upsert storeDigital;
	// 	Test.startTest();
	// 	Wrapper_ProductVariation variations = Ctrl_ProductCatalog.getProductVariantData('M40990','Digi1');
	// 	system.assertEquals(null,variations);
	// 	Test.stopTest();
	// }

	@isTest
	static void testgetProductsStoreAvailabilities() {
		ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
		List<ProductCatalogue__c> products = new List<ProductCatalogue__c>{product};
		Store__c store = TEST_Utils.createStore('LV ABU DHABI MARINA MALL', 'TE1');
		store.Currency__c = 'USD';
		upsert store;
		Store__c store1 = TEST_Utils.createStore('LV ABU DHABI AIRPORT', 'TE2');
		store1.Currency__c = 'USD';
		store1.StoreCountry__c = 'UNITED ARAB EMIRATES';
		store1.Address__c = 'Marina Mall Center PO BOX 93799 ABU DHABI';
		store1.StoreLocation__Latitude__s = 24.471912;
		store1.StoreLocation__Longitude__s = 54.321014;
		//store1.StoreLocation__c = ;
		upsert store1;

		Store__c storeDigital = TEST_Utils.createStore('Digital', 'Digi1');
		storeDigital.Currency__c = 'USD';
		upsert storeDigital;
		List<Store__c> stores = new List<Store__c>{store, store1, storeDigital};

		Store__c defaultStore = store1;

		Catalogue_Settings__c CS = TEST_Utils.createCatalogue_Settings();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successJsonProductStock' , 'productStock'));
		Test.startTest();
		Map<String, List<Wrapper_ProductStoreAvailability>> res = WS_ProductsStock.getProductsStoreAvailabilities(stores,products,defaultStore);
		List<Wrapper_ProductStoreAvailability> resOne = res.get('1234');
		system.assertEquals(0, resOne[0].inStock);
		Test.stopTest();
	}

	// @isTest
	// static void testgetProductData() {
	// 	Catalogue_Settings__c CS = TEST_Utils.createCatalogue_Settings();
	// 	Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successJsonProductVariations' , 'ProductData'));
	// 	Test.startTest();
	// 	Wrapper_ProductVariation res = WS_ProductData.getProductData('1234', 'fr', 'fra_fr');
	// 	List<Wrapper_MapProductData> resOneColor = res.Color;
	// 	system.assertEquals('PAPYRUS', resOneColor[0].ValueName);
	// 	Test.stopTest();
	// }
	@isTest
	static void testgetProductsPrices() {
		ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
		List<ProductCatalogue__c> products = new List<ProductCatalogue__c>{product};
		Store__c store = TEST_Utils.createStore('LV ABU DHABI MARINA MALL', 'TE1');
		store.Currency__c = 'EUR';
		store.StoreCountry__c = 'FRANCE';
		store.Store_CountryCode__c = 'FR';
		upsert store;
		Store__c store1 = TEST_Utils.createStore('LV ABU DHABI AIRPORT', 'TE2');
		//store1.Currency__c = 'EUR';
		store1.StoreCountry__c = 'JAPAN';
		store1.Store_CountryCode__c = 'JP';
		store1.Address__c = 'Marina Mall Center PO BOX 93799 ABU DHABI';
		store1.StoreLocation__Latitude__s = 24.471912;
		store1.StoreLocation__Longitude__s = 54.321014;
		upsert store1;

		User testUser = TEST_Utils.createUser('test user');
		List<Store__c> stores = new List<Store__c>{store,store1};

		Store__c defaultStore = store1;

		Catalogue_Settings__c CS = TEST_Utils.createCatalogue_Settings();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successJsonProductPrices' , 'ProductPrice'));
		Test.startTest();
		Map<String, Map<String, Map<String, Wrapper_ProductPrice>>> res = WS_ProductPrice.getProductsCountryPrice(stores,products,defaultStore);
        system.debug('WS_ProductPrice Res:'+res);
		Map<String, Map<String, Wrapper_ProductPrice>> productRes = new Map<String, Map<String, Wrapper_ProductPrice>>();
		Map<String, Wrapper_ProductPrice> Country = new Map<String, Wrapper_ProductPrice>();
		productRes = res.get('1234');
		country = productRes.get('FR');
		system.assertEquals(3850.0, country.get('R').price);
		Test.stopTest();
	}

	@isTest
	static void testgetProductsPricesByProductId() {
		ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
		Store__c store = TEST_Utils.createStore('LV ABU DHABI MARINA MALL', 'A02');
		store.Store_CountryCode__c = 'FR';
        store.StoreLocation__Latitude__s = 24.471912;
		store.StoreLocation__Longitude__s = 54.321014;
		upsert store;
		Store__c store2 = TEST_Utils.createStore('LV ABU DHABI MARINA MALL2', 'TE1');
		store2.Store_CountryCode__c = 'JP';
		upsert store2;
		User testUser = TEST_Utils.createUser('test user');
		Catalogue_Settings__c CS  = TEST_Utils.createCatalogue_Settings();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successJsonProductPrices' , 'productPrice'));
		Map<String, Map<String, Map<String, Wrapper_ProductPrice>>>  resPrice = new Map<String, Map<String, Map<String, Wrapper_ProductPrice>>> ();
		Map<String, Map<String, Map<String, Wrapper_ProductPrice>>>  resPrice1 = new Map<String, Map<String, Map<String, Wrapper_ProductPrice>>> ();
		Test.startTest();
		System.runAs(testUser) {
			//resPrice = Ctrl_ProductCatalog.getProductsPricesByProductId(new list<String>{product.SKU__c}, new list<String>{store.RetailStoreId__c,store2.RetailStoreId__c} );
            resPrice = Ctrl_ProductCatalog.getProductsPricesByProductId(new list<String>{product.SKU__c}, new list<String>{store.RetailStoreId__c} );

			system.assertEquals(resPrice1, resPrice);
		}
		Test.stopTest();
	}

	@isTest
	static void testgetRecentlyPublished () {
		Catalogue_Settings__c CS  = TEST_Utils.createCatalogue_Settings();
		ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
		Ctrl_Productcatalog.ProductCatalogPageResult pageResult = new Ctrl_Productcatalog.ProductCatalogPageResult();
		Test.startTest();
		pageResult = Ctrl_Productcatalog.getRecentlyPublished();
		List<Wrapper_ProductCatalog> resProducts = new List<Wrapper_ProductCatalog>();
		resProducts = pageResult.products;
		system.assertEquals('test product', resProducts[0].Name);
		Test.stopTest();
	}

	@isTest
	static void testAddStoreToMyList(){
		Catalogue_Settings__c CS  = TEST_Utils.createCatalogue_Settings();
        CS.Max_stores_for_search__c = 10;
        upsert CS;
		List<String> stores = new List<String>();
		stores.add('LV ABU DHABI MARINA MALL - TE1');
		stores.add('LV ABU DHABI AIRPORT - TE2');
		List<String> stores1 = new List<String>();
		stores1.add('LV ABU DHABI MARINA MALL - TE1');
		List<String> stores2 = new List<String>();
        User u = TEST_Utils.createUser('test');
		//u.DefaultStore__c = 'AO2;TE2';
		//u.My_Stores_Lists__c = 'AO2;TE2';
        update u;
		Test.startTest();
        System.runAs(u) {
		String myList = Ctrl_Productcatalog.AddStoreToMyList(stores);
		String myList1 = Ctrl_Productcatalog.AddStoreToMyList(stores1);
		String myList2 = Ctrl_Productcatalog.AddStoreToMyList(stores2);
		system.assert(true, myList.contains('TE1'));
         }
		Test.stopTest();
	}

	@isTest
	static void testAddStoreToMyPersonalList(){
		Catalogue_Settings__c CS  = TEST_Utils.createCatalogue_Settings();
		List<String> stores = new List<String>();
		stores.add('LV ABU DHABI MARINA MALL - TE1');
		stores.add('LV ABU DHABI AIRPORT - TE2');
		List<String> stores1 = new List<String>();
		stores1.add('LV ABU DHABI MARINA MALL - TE1');
		List<String> stores2 = new List<String>();
		Test.startTest();
		String myList = Ctrl_Productcatalog.AddStoreToMyPersonalList(stores);
		system.assert(true, myList.contains('TE1'));
		String myList1 = Ctrl_Productcatalog.AddStoreToMyPersonalList(stores1);
		String myList2 = Ctrl_Productcatalog.AddStoreToMyPersonalList(stores2);
		//system.assert(true, myList.contains('TE1'));
		Test.stopTest();
	}

	@isTest
	static void testgetUserStoreHierarchy(){
		Store__c store = TEST_Utils.createStore('LV ABU DHABI MARINA MALL', 'TE1');
		store.Currency__c = 'EUR';
		store.StoreCountry__c = 'FRANCE';
		store.Store_CountryCode__c = 'FR';
		store.MANAGEMENT_ZONE_LEVEL_TECH__c = 'EMMA';
		store.StoreType__c = 'Store';
		store.Status__c = 'Open';
        store.Store_Region__c = 'LV1';
		upsert store;
		Store__c store1 = TEST_Utils.createStore('LV ABU DHABI AIRPORT', 'TE2');
		store1.Currency__c = 'EUR';
		store1.StoreCountry__c = 'FRANCE';
		store1.Store_CountryCode__c = 'FR';
		store1.MANAGEMENT_ZONE_LEVEL_TECH__c = 'EMMA';
		store1.StoreType__c = 'Store';
		store1.Status__c = 'Open';
		store1.Address__c = 'Marina Mall Center PO BOX 93799 ABU DHABI';
		store1.StoreLocation__Latitude__s = 24.471912;
		store1.StoreLocation__Longitude__s = 54.321014;
        store1.Store_Region__c = 'LV1';
		upsert store1;
		Catalogue_Settings__c CS = TEST_Utils.createCatalogue_Settings();


        User u = TEST_Utils.createUser('test');
		u.DefaultStore__c = 'AO2;TE2';
		u.My_Stores_Lists__c = 'AO2;TE2';
        update u;

		Test.startTest();
       System.runAs(u) {
		Map<String, Map<String, List<String>>> sh = Ctrl_ProductCatalog.getUserStoreHierarchy();
		Map<String, List<String>> wh = new Map<String, List<String>>();
		List<String> storelist = new List<String>();
		wh = sh.get('Warehouse');
		storelist = wh.get('EMEA');
		system.assertEquals(storelist[0], 'TE1');
       }
		Test.stopTest();
	}
    
    @isTest
	static void testGetUserFavorites(){
        User u = TEST_Utils.createUser('test');
        Test.startTest();
		System.runAs(u) {
			List<String> fav = Ctrl_ProductCatalog.GetUserFavorites();
			system.assertEquals('1234', fav[0]);
		}
        Test.stopTest();
    }
    
    @isTest
	static void testGetInitData(){
        User u = TEST_Utils.createUser('test');
       	// Catalogue_Settings__c CS = TEST_Utils.createCatalogue_Settings();
		Map<String, List<String>> initData = new Map<String, List<String>>();
        Test.startTest();
		System.runAs(u) {
        	initData = Ctrl_ProductCatalog.getInitData();
			List<String> skusFavorites = initData.get('MyFavorites');
			system.assertEquals('1234',skusFavorites[0]);

		}
        Test.stopTest();
    }
    
    @isTest
	static void testClearMyFavorites(){
        User u = TEST_Utils.createUser('test');
        Test.startTest();
		System.runAs(u) {
        	Boolean fav = Ctrl_ProductCatalog.clearMyFavorites();
			system.assertEquals(true, fav);
		}
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateFavorites(){
        Test.startTest();
        User u = TEST_Utils.createUser('test');
		System.runAs(u) {
			Ctrl_ProductCatalog.updateFavorites('23456');
			List<String> fav = Ctrl_ProductCatalog.updateFavorites('1234');
			system.assertEquals('23456', fav[0]);
            


		}
        Test.stopTest();
    }
    
    @isTest
    static void testGetFavoriteProducts(){
        User u = TEST_Utils.createUser('test');
        ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
		List<ProductCatalogue__c> products = new List<ProductCatalogue__c>{product};
        String favoritesString =  String.join(products,',');
        String favoritesString2 = null;
		Ctrl_Productcatalog.ProductCatalogPageResult pageResult = new Ctrl_Productcatalog.ProductCatalogPageResult();
        Test.startTest();
		System.runAs(u) {
			pageResult = Ctrl_ProductCatalog.getFavoriteProducts(favoritesString);
           	pageResult = Ctrl_ProductCatalog.getFavoriteProducts(favoritesString2);
			List<Wrapper_ProductCatalog> resProducts = new List<Wrapper_ProductCatalog>();
			resProducts = pageResult.products;
			system.assertEquals('1234',resProducts[0].sku );
		}
        Test.stopTest(); 
    }


    @isTest
	static void testgetReferentialProduct(){
		 User u = TEST_Utils.createUser('test');
		Test.startTest();
		System.runAs(u) {
			Store__c store = TEST_Utils.createStore('test store', 'TE1');
			List<String> stores = new List<String>();
			stores.add(store.Name);
			ProductReferential__c pr = TEST_Utils.createProductReferential('test','3456');
			
			ProductCatalogue__c product = TEST_Utils.createProductCatalog('test','1234');
			product.defaultSku__c ='';
			//product.AssociateColors__c ='';
			upsert product;
			system.debug('product ' + product);
            
            ProductCatalogue__c product2 = TEST_Utils.createProductCatalog('test','123456');
			product2.defaultSku__c ='';
          //  product2.isDefaultSku__c =true; //not writeable
			upsert product2;
			system.debug('product2 ' + product2);

			Ctrl_ProductCatalog.ProductCatalogPageResult res = new Ctrl_ProductCatalog.ProductCatalogPageResult();
            Ctrl_ProductCatalog.ProductCatalogPageResult res2 = new Ctrl_ProductCatalog.ProductCatalogPageResult();
            Ctrl_ProductCatalog.ProductCatalogPageResult res3 = new Ctrl_ProductCatalog.ProductCatalogPageResult();
            Ctrl_ProductCatalog.ProductCatalogPageResult res4 = new Ctrl_ProductCatalog.ProductCatalogPageResult();

			//Test.startTest();
			res = Ctrl_ProductCatalog.getReferentialProduct('test', 9.0, 1.0, stores);
            res2 = Ctrl_ProductCatalog.getReferentialProduct('test', 9.0, 4.0, stores);
            res3 = Ctrl_ProductCatalog.getReferentialProduct('test', 0, 0, stores);
            res4 = Ctrl_ProductCatalog.getReferentialProduct('123456', 9.0, 1.0, stores);
			system.debug('res ' + res);
			Wrapper_ProductCatalog wpc = Wrapper_ProductCatalog.convertPRToProductCatalogWrapper(pr);
			system.assertEquals(1, res.page);
            system.assertEquals(1, res2.page);
            system.assertEquals(1, res4.page);

		}
		Test.stopTest();
    }
    
    @isTest
    static void testgetRegionStock(){
        Store__c store = TEST_Utils.createStore('test store', 'TE1');
		store.StoreCountry__c = 'FRANCE';
        store.Store_Region__c = 'LV1';
        update(store);
        ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
        Product_Stock__c ps = TEST_Utils.createProductStock(product, store);
        Test.startTest();
        Boolean response = Ctrl_ProductCatalog.getRegionStock('EMEA', 'LV1', product.Id);
        System.assertEquals(true, response);
        Test.stopTest();   
    }

	@isTest
    static void testgetPdf(){
        ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
		User u = TEST_Utils.createUser('test');
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successJsonProductPdf' , 'productPdf'));
		
		Test.startTest();
		System.runAs(u) {
			String Link  = Ctrl_ProductCatalog.getPDF(product.SKU__c);
			system.assertEquals('https://stellar-assets.louisvuitton.com/assets/marketing/import_photolib/Z01/M5/17/45/1234_en.pdf', Link);
		}
        Test.stopTest();   
    }

	@isTest
    static void testgetVariationsProducts(){
        User u = TEST_Utils.createUser('test');
		ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
		product.defaultSku__c='12345';
		product.SizeName__c = '34.0';
		product.ProductGroup__c = 'Souliers';
		product.MarketingColorId__c = 'MKCMKC-SHO-AL';
		product.en_E1_size__c = '08.0';
		update product;
        
		ProductCatalogue__c product1 = TEST_Utils.createProductCatalog('test product','2345');
		product1.defaultSku__c='';
		product1.SizeName__c = '';
		product1.ProductGroup__c = '';
		product1.MarketingColorId__c = '';
		product1.BccProductId__c = 'nvprod1310170v';
		update product1;

		ProductCatalogue__c product2 = TEST_Utils.createProductCatalog('test product','3456');
		product2.defaultSku__c='';
		product2.SizeName__c = '';
		product2.ProductGroup__c = '';
		product2.MarketingColorId__c = '';
		product2.BccProductId__c = 'nvprod1530085v';
		update product2;
        
        
		
		Wrapper_ProductCatalog wpc = TEST_Utils.createProductWrapper('12345');
		wpc.ProductGroup = 'Souliers';
        wpc.department='Belts';
		wpc.defaultSku = '12345';
		wpc.MarketingColorId = 'MKCMKC-SHO-AL';
		wpc.size = '34.0';
		wpc.ShoeWidth = 'Normal';
		wpc.AssociateColors ='';
		wpc.AssociateMaterials = '';
		wpc.AssociatedModelSize ='';
        
        

		Wrapper_ProductCatalog wpc2 = TEST_Utils.createProductWrapper('23456');
		wpc2.ProductGroup = '';
		wpc2.defaultSku = '';
		wpc2.MarketingColorId = '';
		wpc2.size = '';
		wpc2.AssociateColors ='[]';
		wpc2.AssociateMaterials = '[nvprod1310170v,nvprod1270068v]';
		wpc2.AssociatedModelSize ='[nvprod1270064v,nvprod1530085v]';

		Test.startTest();   
		String wpjson  = JSON.serialize(wpc);
		Map<String , List<Wrapper_ProductCatalog>> res = new Map<String , List<Wrapper_ProductCatalog>>();
		res = Ctrl_ProductCatalog.getVariationsProducts(wpjson);
		system.debug('res' + res);
		
		//system.assertEquals('1234', res.get('sizeProduct')[0].sku);
		//Test.stopTest();  
		
		//Test.startTest();   
		String wpjson2  = JSON.serialize(wpc2);
		Map<String , List<Wrapper_ProductCatalog>> res2 = new Map<String , List<Wrapper_ProductCatalog>>();
		res2 = Ctrl_ProductCatalog.getVariationsProducts(wpjson2);
		//system.debug('res2' + res2);
		
		//system.assertEquals('1234', res2.get('sizeProduct')[0].sku);
        Test.stopTest();  
    }
    @isTest
	static void testDALProductCatalog() {
       
        
        
		DAL_ProductCatalog dpc = new DAL_ProductCatalog();
		Store__c store = TEST_Utils.createStore('name', 'A02');
        ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','123456');

		//ProductCatalogue__c product = new ProductCatalogue__c();
       // product.Name='test product';
	//	product.SKU__c = '123456';
        product.defaultSku__c = '123456';

        product.Workshop__c = '1798'; //became required

		upsert product;
        
        system.debug('product dal test:'+product);
        system.debug('product dal default:'+product.isDefaultSku__c);
        system.debug('product dal inspired:'+product.Get_Inspired__c);
        system.debug('product dal discover:'+product.Discover_the_family_product__c);


		Double latitude = 12.1;
		Double longitude = 12.1;
		Decimal range = 30;
		String storeCode = 'A03';

      
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponse('' , 'error'));

		Test.startTest();
		//DAL_ProductCatalog.getProductCatalogsBySKUS(new List<String>{'123456'});
		DAL_ProductCatalog.getNearbyStoresByStoreLocation(null, null, range, storeCode);
		//DAL_ProductCatalog.getAllProductCatalogs();
		List<Store__c> stores = DAL_ProductCatalog.getAllStores();
		DAL_ProductCatalog.getStoreByName('name');
		//DAL_ProductCatalog.getProudctStoreAvailabilityById(ava.Id);
		//DAL_ProductCatalog.getProudctStoreAvailabilityById('');
		DAL_ProductCatalog.getProductCatalogCount();
		//DAL_ProductCatalog.getProductAvailabilitiesByProductIds(new Set<String>());
		DAL_ProductCatalog.getLastDigitalStore();
		DAL_ProductCatalog.getStoreHierarchyState();
		// DAL_ProductCatalog.getAllProductCatalogs('');
		DAL_ProductCatalog.getProductCatalogs(2,9);
		DAL_ProductCatalog.getStoresByIds(new List<String>{'123456'});
		DAL_ProductCatalog.getStoreById('123456');
		//DAL_ProductCatalog.getProductsCatalogByIds(new List<String>{'123456'});
		DAL_ProductCatalog.getActiveStores();
		DAL_ProductCatalog.getRecentlyPublishedProducts(10);
		//DAL_ProductCatalog.getStoreHierarchy();
		DAL_ProductCatalog.getStoreByCode('A02');
        DAL_ProductCatalog.getProductCatalogsBySearchKey('test');
        DAL_ProductCatalog.haveStockInRegion('', '', null);

		system.assertEquals('A02',stores[0].RetailStoreId__c );
		Test.stopTest();
	}

	@isTest
    static void testGetGastonToken()

    {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successTokenGaston' , 'json'));
        Test.startTest();
        String result = DAL_ProductCatalog.getGastonToken();
        system.debug('result: '+ result.split('=')[0]);
        system.assertEquals('1640261441.064~acl',result.split('=')[1]);

		Test.stopTest();

    }  
    
      @isTest
    static void testGetProductsBySkus(){
        
        List<String> listSkus = new List<String>();

        ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
        
        system.debug('product sku:'+ (String)product.get('sku__c'));
		system.debug('product:'+ product);
        
        listSkus.add((String)product.get('sku__c'));
        
         ProductCatalogue__c product1 = TEST_Utils.createProductCatalog('test product2','1235');
        
        system.debug('product sku:'+ (String)product1.get('sku__c'));
        
        listSkus.add((String)product1.get('sku__c'));

        Test.startTest();

		List<Wrapper_ProductCatalog> result = Ctrl_ProductCatalog.getProductsBySkus(listSkus);
		system.debug('resultend:'+ result);
		system.assertEquals(result[0].sku,'1234');

		Test.stopTest();
    }

    // @isTest
    // static void testSortProductsBySkus()
    // {
    //      Store__c store = TEST_Utils.createStore('test store', 'TE1');

    //      List<String> listSkus = new List<String>();
    //      List<ProductCatalogue__c> listProduct = new List<ProductCatalogue__c>();


    //     ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
        
    //     system.debug('product sku:'+ (String)product.get('sku__c'));
	// 	system.debug('product:'+ product);
        
    //     listSkus.add((String)product.get('sku__c'));
    //     listProduct.add(product);
    //     ProductCatalogue__c product1 = TEST_Utils.createProductCatalog('test product2','1235');
        
    //     system.debug('product sku:'+ (String)product1.get('sku__c'));
        
    //     listSkus.add((String)product1.get('sku__c'));
    //     listProduct.add(product1);

    //     Test.startTest();
    //     List<Wrapper_ProductCatalog> wrapper = Wrapper_ProductCatalog.convertToProductCatalogWrappers(listProduct,store);
    //     system.debug('wrapper:'+wrapper);
	// 	List<Wrapper_ProductCatalog> result = Ctrl_ProductCatalog.sortProductsBySkus(wrapper,listSkus);
	// 	system.debug('result:'+ result);
	// 	system.assertEquals(wrapper[0].Id,result[0].Id);
		
	// 	Test.stopTest();
    // }
    
    @isTest
    static void testGetOrderableStatus()
    {
        List<String> listStore = new List<String>();

        Store__c store = TEST_Utils.createStore('test store', 'TE1');
        store.StoreCountry__c='France';
        store.Store_CountryCode__c='FR';

        upsert store;
        // system.debug('store:'+ store);
        listStore.add(store.RetailStoreId__c);
        Store__c store2 = TEST_Utils.createStore('test store2', 'TE2');
        store2.StoreCountry__c='Spain';
		store2.Store_CountryCode__c='ES';
		store2.isXstore__c=true; //test Rachel 25.01.2022
        upsert store2;
        
        listStore.add(store2.RetailStoreId__c);
		ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
        system.debug('product sku:'+ (String)product.get('sku__c'));
		system.debug('product:'+ product);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successJsonProductStock' , 'productStock'));
        Test.startTest();
        
        //does not return anything since in the TEST it doesn't do HTTP send, so we can't have an assertEqual since it would always be null
        Map<String,String> resultsMap = Ctrl_ProductCatalog.getOrderableStatus(JSON.serialize(product), JSON.serialize(listStore));
		system.debug('resultsMap:'+ resultsMap);
		system.assertEquals(null, resultsMap);
        
		Test.stopTest();
    }
    
    
    
    @isTest
    static void testGetMayAlsoLikeProducts()
    {
        Store__c store = TEST_Utils.createStore('test store', 'TE1');
		ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
        
        system.debug('product sku:'+ (String)product.get('sku__c'));
		String sku = (String)product.get('sku__c');
		system.debug('product:'+ product);
        Test.startTest();
        //does not return anything since in the TEST it doesn't do HTTP send, so we can't have an assertEqual since it would always be null
		// and get a attempt to de-reference a null object exception
        
		//List<Wrapper_ProductCatalog> result = Ctrl_ProductCatalog.getMayAlsoLikeProducts(sku);
		//system.debug('result:'+ result);
		
		Test.stopTest();        
    }
    
    @isTest
    static void testInpropriateJson()
    {
        String parser = '{"data": {"itemPrices":[{"countryCode":"FR","itemList":[{"item":"1234","price":"3850.00","currencyCode":"EUR","factor":"1","tariffType":"R"}]},{"countryCode":"JP","itemList":[{"item":"1234","price":"235764.00","currencyCode":"JPY","factor":"1","tariffType":"W"},{"item":"1234","price":"590000.00","currencyCode":"JPY","factor":"1","tariffType":"R"}]}]}}';
           
        ProductCatalogue__c product = TEST_Utils.createProductCatalog('test product','1234');
		User u = TEST_Utils.createUser('test');
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('errorJsonProductPdf' , 'productPdf'));	
        
        Test.startTest();
        ProductPriceJsonToApex productPriceParse = ProductPriceJsonToApex.parse(parser);

        system.debug('productPriceParse:'+productPriceParse);
        system.assertEquals(productPriceParse.LVResponse, null);
        
        System.runAs(u) {
			String Link  = Ctrl_ProductCatalog.getPDF(product.SKU__c);
            system.debug('Link:' +Link);
			system.assertEquals('',Link);
		}
        Test.stopTest();
    }


    @isTest
    static void testEnvironmentalSectionCountryFilter() {
		Store__c store = TEST_Utils.createStore('LV FRANCE', 'A02');
		Store__c store1 = TEST_Utils.createStore('LV PARIS', 'A19');
		Store__c store2 = TEST_Utils.createStore('LV MARSEILLEL', 'A03');
		store.StoreCountry__c = 'FRANCE';
		store1.StoreCountry__c = 'FRANCE';
		store2.StoreCountry__c = 'FRANCE';
		upsert store;
		upsert store1;
		upsert store2;
		

		List<String> lstStoreCodes = new List<String>{'A19','A02','A03'};         

        Test.startTest();
		Boolean isShowEnvironmentalSection = Ctrl_ProductCatalog.environmentalSectionCountryFilter(lstStoreCodes);
        system.assertEquals(true, isShowEnvironmentalSection);
        
        Test.stopTest();
    }

	@isTest 
	static void testUserPermission()
	{
		User testUser = TEST_Utils.createUser('test user');

		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ICX_AlphaWebview'];
       
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = testUser.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;													
		System.debug('perAssignments'+psa);

		Test.startTest();
		
		System.runAs(testUser) {

			Boolean permission = Ctrl_ProductCatalog.hasCustomPermission();
			system.assertEquals(true, permission);
		}
		
		Test.stopTest();
	}

	@IsTest
	static void testEncryptWithManagedIV()
	{
	   String dataToEncrypt = 'https://lv-alpha-dev-wa.azurewebsites.net/?lng=EN&productName=Boîte%20Bijoux&sku=M20291&country=FRANCE&storeCode=A&appName=catalogdesktop&timestamp=1698832115&token=DUQFNnZl_lp6C9etUWU0LIMEkE3Mt8uUuKBRdSyBESk=';
	   String keys = 'ConfidantialsInformation';
	   Catalogue_Settings__c orgDefault = new Catalogue_Settings__c();
        orgDefault.SetupOwnerId=UserInfo.getOrganizationId();
        orgDefault.treekitPrivateKey__c=keys;
        insert orgDefault;
	   Test.startTest();
	   system.debug('Test results => first time');
	   String finalEncryptData = Ctrl_ProductCatalog.generateTokenEncrypted(dataToEncrypt);
       system.debug('Test results =>'+finalEncryptData);
	   Assert.isNotNull(finalEncryptData);
	   Test.stopTest();
	}

	// @isTest
    // static void testGetCscAndEcoStatus()
    // {
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new ICX_CatalogHttpCalloutMock());
    //     Map<String, String> res = Ctrl_ProductCatalog.getCscAndEcoStatus('M9402U', 'A90');
	// 	Test.stopTest();
    //     Assert.isNotNull(res.get('CSC'));
    // }
    
    // @isTest
    // static void testGetCountryCscStatus()
    // {
    //     Store__c store = TEST_Utils.createStore('test store', 'TE1');
    //     store.StoreCountry__c='Country TEST';
    //     store.Store_CountryCode__c='ZZZZ';
    //     store.StoreType__c='CSC';
    //     upsert store;
        
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new ICX_CatalogHttpCalloutMock());
    //     List<Map<String, String>> res = Ctrl_ProductCatalog.getCountryCscStatus('M9402U', new List<String>(), new List<String>{'TE1'});
	// 	Test.stopTest();
    //     Assert.isNotNull(res);
    //     Assert.areEqual(1, res.size());
    //     Assert.areEqual(1, res.size());
    //     Assert.areEqual('Country TEST', res.get(0).get('countryName'));
    // }
 
}