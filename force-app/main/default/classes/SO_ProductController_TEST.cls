@isTest
private class SO_ProductController_TEST {

	@testSetup
	public static void setup(){

		List<Store__c> ls = new List<Store__c>();
		ls.add(new Store__c (Name='ST1', RetailStoreId__c='ST1'));
		ls.add(new Store__c (Name='ST2', RetailStoreId__c='ST2'));
		ls.add(new Store__c (Name='ST3', RetailStoreId__c=''));

		insert ls;

		ProductReferential__c p = new ProductReferential__c(SKUCode__c = 'SKU1');
		insert p;
	}

	@isTest
	public static void test_getUserStr(){
		String uJSON = SO_ProductController.getUserStr();
		User u = (User) JSON.deserialize(uJSON, User.class);
		System.assertEquals(UserInfo.getUserId(), u.id);
	}

	@isTest
	public static void test_getStoreNoStore(){

		Test.startTest();

		ProductReferential__c p = [SELECT id FROM ProductReferential__c WHERE SKUCode__c = 'SKU1' LIMIT 1];

		try{
			String stockJSON = SO_ProductController.getStock(p.id, 'ST0');
			System.assert(false, 'The exception should be thrown');
		} catch (Exception e){
			System.debug('1 - e.getMessage() = ' + e.getMessage());
			System.AssertEquals('Store not found', e.getMessage());
		}

		try{
			String stockJSON = SO_ProductController.getStock(p.id, '');
			System.assert(false, 'The exception should be thrown');
		} catch (Exception e){
			System.debug('2 - e.getMessage() = ' + e.getMessage());
			//System.AssertEquals('Store not found', e.getMessage());
		}

		try{
			String stockJSON = SO_ProductController.getStock(p.id, 'ST3');
			System.assert(false, 'The exception should be thrown');
		} catch (Exception e){
			System.debug('3 - e.getMessage() = ' + e.getMessage());
			System.AssertEquals('No store selected', e.getMessage());
		}

		try{ //
			String stockJSON = SO_ProductController.getStock(p.id, 'ST4');
			System.assert(false, 'The exception should be thrown');
		} catch (Exception e){
			System.debug('4 - e.getMessage() = ' + e.getMessage());
			System.assertEquals('Store not found', e.getMessage());
		}

		// try{ //
		// 	String stockJSON = SO_ProductController.getStock(p.id, null);
		// 	System.assert(false, 'The exception should be thrown');
		// } catch (Exception e){
		// 	System.debug('5 - e.getMessage() = ' + e.getMessage());
		// 	System.assertEquals('Store not found', e.getMessage());
		// }

		Test.stopTest();
	}

	@isTest
	public static void test_getStoreNoProduct(){
		Test.starttest();

		try{
			String stockJSON = SO_ProductController.getStock(null, 'ST0');
			System.assert(false, 'The exception should be thrown');
		} catch (Exception e){
			System.AssertEquals('No product selected', e.getMessage());
		}
	}

	@isTest
	public static void test_getStockOneProduct(){

		Test.setMock(WebServiceMock.class, new SO_WS_RMS_DoItemSearch_MOCK());

		Test.startTest();

		ProductReferential__c p = [SELECT id FROM ProductReferential__c WHERE SKUCode__c = 'SKU1' LIMIT 1];
		String stockJSON = SO_ProductController.getStock(p.id, 'ST1');

		Test.stopTest();

		System.assertNotEquals(null, stockJSON);

		List<SO_ProductController.Stock> stockList = (List<SO_ProductController.Stock>)JSON.deserialize(stockJSON, List<SO_ProductController.Stock>.class);

		System.assertEquals(1, stockList.size());

		SO_ProductController.Stock stock = stockList[0];
		System.assertEquals(120, stock.quantity);
		System.assert(stock.sellable);
		System.assertEquals('Status', stock.status);
	}

	@isTest
	public static void test_getProductCategoryJSON(){
		String pCatJSON = SO_ProductController.getProductCategoryJson();
		List<PicklistEntry> pCat = (List<PicklistEntry>) JSON.deserialize(pCatJSON, List<PicklistEntry>.class);
		System.assertEquals(Opportunity.SPO_ProductCategory__c.getDescribe().getPicklistValues().size(), pCat.size());
	}

    @isTest
    public static void test_findBySku(){

      ProductReferential__c p = new ProductReferential__c();
      p.SKUCode__c = 'SIM';

      insert p;

      ProductReferential__c p0 = SO_ProductController.findBySku(p.SKUCode__c);

     	System.assertEquals(p.SKUCode__c, p0.SKUCode__c);

    }

     @isTest
    public static void test_findByOpportunityId(){

        ProductReferential__c p = new ProductReferential__c();
        p.SKUCode__c = 'SIM';
        insert p;


         Opportunity opp  		= new Opportunity();
        opp.Name = 'otest';
        opp.SPO_ProductCategory__c = 'Leather Goods';
        opp.SPO_OrderType__c = 'SPO/MTO';
        opp.SPO_CreationType__c = 'otest';
        opp.StageName = 'Brief in progress';
        opp.CloseDate = Date.today();
        opp.SPO_BaseSKURefmodelSKU__c= p.Id;
        insert opp;

        SO_ProductController.findByOpportunityId(opp.Id);

    }

    @isTest
    public static void test_findBySObjectId(){
        ProductReferential__c p = new ProductReferential__c();
        p.SKUCode__c = 'SIM';
        insert p;

        Opportunity opp  		= new Opportunity();
        opp.Name = 'otest';
        opp.SPO_ProductCategory__c = 'Leather Goods';
        opp.SPO_OrderType__c = 'SPO/MTO';
        opp.SPO_CreationType__c = 'otest';
        opp.StageName = 'Brief in progress';
        opp.CloseDate = Date.today();
        opp.SPO_SpecialOrderSKUCodeRef__c = p.Id;

        insert opp;

       	SPO_FirmOrder__c fo = new SPO_FirmOrder__c();
        //fo.Name = 'fotest';
        fo.LineNumber__c = 0.0;
        fo.SPO_BriefName__c = opp.Id;
       // fo.ProductCatalogue__r.FluidRecipeId__c = '34257080';

        insert fo;

         System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$'+opp.Id);
         System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$'+fo.Id);
        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$'+p.Id);

        //SO_ProductController.findBySObjectId(opp.Id);
        //SO_ProductController.findBySObjectId(fo.Id);

		ProductReferential__c pr1 = SO_ProductController.findBySObjectId(p.Id);
		ProductReferential__c pr2 = SO_ProductController.findBySObjectId(null);
    }

    @isTest
    public static void test_findAll(){
        String sk = 'abc';
        String c = 'Belts';
        Boolean b = true;
        Decimal ps = 10;
        Decimal pn = 1;

        SO_ProductPagedResult ppr1 = SO_ProductController.findAll(sk, c, b, ps, pn);

        Boolean b0 = false;
        String c0 = '';

        SO_ProductPagedResult ppr2 = SO_ProductController.findAll(sk, c0, b0, ps, pn);

        String sk1 = 'a';
        String c1 = 'Belt';
        Boolean b1 = false;
        Decimal ps1 = 10;
        Decimal pn1 = 1;

        SO_ProductPagedResult ppr3 = SO_ProductController.findAll(sk1, c1, b1, ps1, pn1);

		SO_ProductPagedResult ppr4 = SO_ProductController.findAll(sk1, 'Leather Goods', b1, ps1, pn1);
		SO_ProductPagedResult ppr5 = SO_ProductController.findAll(sk1, 'Hardsided leather goods', b, ps1, pn1);
    }

    @isTest
    public static void test_getUserLocationPickListValues(){
		String objn = 'otest';
      	String objn0 = 'otest';

      	List<String> l = new List<String>();
		l.add(objn);
      	l.add(objn0);

		String picklistJsonValues1 = SO_ProductController.getUserLocationPickListValues(objn, l);
		String picklistJsonValues2 = SO_ProductController.getUserLocationPickListValues('', null);
    }

    @isTest
    public static void test_getProductNotFound(){
		// ProductReferential__c pr1 = new ProductReferential__c(SKUCode__c = 'SIM', Name = 'Pr1', ProductCategory__c = 'Watches');
		ProductReferential__c pr1 = new ProductReferential__c(SKUCode__c = 'SIM');
		insert pr1;

		ProductReferential__c pr2 = SO_ProductController.getProductNotFound();
    }

    @isTest
    public static void test_getProductSettings(){

        SO_ProductController.getProductSettings();

    }

	@isTest
	public static void test_isMTOEnabled(){
		try{
			Boolean isMtoEnabled = SO_ProductController.isMTOEnabled();
			System.assertEquals(isMtoEnabled, true);
			System.assertEquals(isMtoEnabled, false);
		}

		catch(Exception error){
			System.assertEquals('Attempt to de-reference a null object', error.getMessage());
		}
	}
}