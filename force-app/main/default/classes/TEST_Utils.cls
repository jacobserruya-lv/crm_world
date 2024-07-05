public with sharing class TEST_Utils {

	public static ProductCatalogue__c createProductCatalog(String name, String sku) {
		ProductCatalogue__c p = new ProductCatalogue__c(Name = name, SKU__c = sku, ViewOnline__c = true, ViewOnlineDate__c =Date.today());
        p.Workshop__c = '1798'; //became required
		insert p;
		return p;
	}
    
    public static ProductReferential__c createProductReferential(String name, String sku) {
		ProductReferential__c pr = new ProductReferential__c(Name = name, SKUCode__c = sku, OrderableEMEA__c='Orderable', OrderableJapan__c='Not Orderable');
		insert pr;
		return pr;
	}

	public static Store__c createStore(String name, String storeCode) {
		Store__c s = new Store__c(Name = name);
		s.StoreType__c = 'Store';
		s.Status__c = 'Open';
		s.OpeningHours__c = '{"Sunday":"10:00-12:00", "Monday":"10:00-12:00", "Tuesday":"10:00-12:00", "Wednesday":"10:00-12:00", "Thursday":"10:00-12:00", "Friday":"10:00-12:00", "Saturday":"10:00-12:00"}';
		s.RetailStoreId__c = storeCode;
		insert s;
		return s;
	}

	/*public static Product_Store_Availability__c createProductAvailability(String name, String productId, String storeId) {
		Product_Store_Availability__c pa = new Product_Store_Availability__c(Name = name, Store__c = storeId, Product_Catalogue__c = productId);
		pa.InTransit__c = 1;
		pa.InStock__c = 10;
		pa.Price__c = 100;
		insert pa;
		return pa;
	}*/

	public static Wrapper_ProductStoreAvailability createProductAvailability(String name, String productId, String storeId) {
		Wrapper_ProductStoreAvailability pa =
				new Wrapper_ProductStoreAvailability();
		//pa.Name = name;
		//pa.Store__c = storeId;
		pa.productCatalogId = productId;
		//pa.InTransit = 1;
		pa.InStock = 10;
		pa.Price = 100;
		pa.locationLatitude = 25;
		pa.locationLongitude = 26;
		pa.googleMapLink = 'test';
		//insert pa;
		return pa;
	}
	/*public static Product_Store_Availability__c createProductAvailability(String name, String storeCode) {
		ProductCatalogue__c p = createProductCatalog(name);
		Store__c s = createStore(name, storeCode);
		return createProductAvailability(name, p.Id, s.Id);
	}*/

    public static User createDreamUser() {
        
               Profile p = [SELECT Id FROM Profile WHERE Name = 'ICON_Interface DREAM'];
        
        		User u = new User(
				UserName = '' + UserInfo.getOrganizationId() + System.now().millisecond() + 'dream@icon.vuitton.com.pprod_test', // Avoiding duplicates
				Email ='icontechnicaluserTEST@louisvuitton.com',
				LastName = 'dreamTest',
				ProfileId = p.id,
                //User License = 'Salesforce',
                //CommunityNickname = 'dreamTest',
                //Role = '# - Corporate',    
				LocaleSidKey = 'en_US',
                BypassVR__c = false,
				LanguageLocaleKey = 'en_US',
				TimeZoneSidKey = 'GMT',
				EmailEncodingKey = 'UTF-8',
				Alias = 'dreamT',
				DefaultStore__c = 'TE1',
                IsActive = true,
				My_Favorites__c = '1234');
		insert u;
		return u;
        
    }
    
	public static User createUser(String uName) {
		Profile sysAdmin = getSysAdminUserProfile();
		User u = new User(
				UserName = '' + UserInfo.getOrganizationId() + System.now().millisecond() + 'test@balink.net', // Avoiding duplicates
				Email ='test@balink.net',
				LastName = 'test',
				ProfileId = sysAdmin.Id,
				LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US',
				TimeZoneSidKey = 'GMT',
				EmailEncodingKey = 'UTF-8',
				Alias = 'userlv',
				DefaultStore__c = 'TE1',
				My_Favorites__c = '1234');
		insert u;
		return u;
	}

	public static Profile getSysAdminUserProfile() {
		return [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
	}

	public static Catalogue_Settings__c createCatalogue_Settings() {
		Catalogue_Settings__c CS = new Catalogue_Settings__c(Digital_Stores__c ='UEC,UIC,URZ,NM5,V02,A90,F90,H90,K90,J90,L36',
				IntegUsername__c = 'username',
				IntegPassword__c = 'password',
				CatalogueWSURL__c = 'http://www.test.com',
				Name = Label.WSCatalogueTECHUserId,
				OptionalHeadersNum__c = 0,
				A90__c = 'http://www.test.com',
				WS_Price__c = 'http://www.test.com',
				User_Agent__c = 'test',
				Number_Of_New_Porducts__c = 10,
				Max_stores_for_search__c = 4,
				Digital_Store_List_Other_Price__c ='Z12');

		insert CS;
		return CS;
	}
    
    public static Product_Stock__c createProductStock(ProductCatalogue__c product, Store__c store) {
		Product_stock__c ps = new Product_Stock__c(
			Zone__c='EMEA', 
			Product__c = product.Id, 
			Store__c = store.Id, 
			Quantity__c = 1,
			Source__c = 'RMS Conso');
        insert ps;
        return ps;
	}

	public static Wrapper_ProductCatalog createProductWrapper(String Sku){
		Wrapper_ProductCatalog wpc =
				new Wrapper_ProductCatalog();
		wpc.sku = Sku;
		return wpc;
	}

	/** Methods dedicated to unit tests, for the sake of simplification */
	
	public static void assertTrue(Object o, Object message) {
		System.assertEquals(true, o, message);
	}

	public static void assertTrue(Object o) {
		assertTrue(o, 'Error');
	}

	public static void assertFalse(Object o, Object message) {
		System.assertEquals(false, o, message);
	}

	public static void assertFalse(Object o) {
		assertFalse(o, 'Error');
	}
	
	public static void assertNull(Object o, Object message) {
		System.assertEquals(null, o, message);
	}

	public static void assertNull(Object o) {
		assertNull(o, 'Error');
	}

	public static void assertNotNull(Object o, Object message) {
		System.assertNotEquals(null, o, message);
	}

	public static void assertNotNull(Object o) {
		assertNotNull(o, 'Error');
	}

}