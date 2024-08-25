@isTest
public class ICX_ProductSearchLookup_LC_TEST {

    @isTest
    public static void search_Test() {
        // Prepare data
        List<ProductCatalogue__c> prodList = new List<ProductCatalogue__c>();
        prodList.add(ICX_TestFactory.createProductCatalogue('Product1', 'M12345'));

        ProductCatalogue__c prod2 = ICX_TestFactory.createProductCatalogue('Product2', 'M12346');
        prodList.add(prod2);

        prodList.add(ICX_TestFactory.createProductCatalogue('Product1', 'M12347'));
        //prodList.add(ICX_TestFactory.createProductCatalogue('XXXX', 'PXXXXX'));
        insert prodList;

        Id [] fixedSearchResults = new List<Id>();
        for (ProductCatalogue__c prod : prodList) {
            fixedSearchResults.add(prod.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);

        // Test
        String searchTerm = 'M1234';
        List<String> selectedIds = new List<String> {String.valueOf(prod2.Id)}; // Test result without 'Product2'
        List<ICX_ProductLookupSearchResult> resultList = ICX_ProductSearchLookup_LC.search(searchTerm, selectedIds);
        
        // Check
        //System.assertEquals(2, resultList.size());
        for (ICX_ProductLookupSearchResult result : resultList) {
            System.assertEquals('Product1', result.getTitle());
        }
    }

    @isTest
    public static void searchRecord_WithoutParent_Test() {
        // Prepare data
        List<ProductCatalogue__c> prodList = new List<ProductCatalogue__c>();
        prodList.add(ICX_TestFactory.createProductCatalogue('Product1', 'M12345'));
        
        ProductCatalogue__c prod2 = ICX_TestFactory.createProductCatalogue('Product2', 'M12346');
        prodList.add(prod2);
        
        ProductCatalogue__c prod3 = ICX_TestFactory.createProductCatalogue('Product1', 'M12347');
        prodList.add(prod3);
        insert prodList;
        
        //Account acc = ICX_TestFactory.createAccount();
        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        insert call;
        
        ICX_ProductEnquired__c prodEnq = ICX_TestFactory.createProductEnquired(prod2.Id, call.Id);
        ICX_ProductEnquired__c prodEnq2 = ICX_TestFactory.createProductEnquired(prod3.Id, null);
        insert new List<ICX_ProductEnquired__c> {prodEnq, prodEnq2};

        // Test
        Test.startTest();
        List<ICX_ProductLookupSearchResult> resultList = ICX_ProductSearchLookup_LC.searchRecord(call.Id);
        Test.stopTest();

        System.assertEquals(1, resultList.size());
        System.assertEquals(prod2.Id, resultList.get(0).getQualification().Product__c);
    }

    @isTest
    public static void searchRecord_WithParent_Test() {
        // Prepare data
        List<ProductCatalogue__c> prodList = new List<ProductCatalogue__c>();
        prodList.add(ICX_TestFactory.createProductCatalogue('Product1', 'M12345'));
        
        ProductCatalogue__c prod2 = ICX_TestFactory.createProductCatalogue('Product2', 'M12346');
        prodList.add(prod2);
        
        ProductCatalogue__c prod3 = ICX_TestFactory.createProductCatalogue('Product1', 'M12347');
        prodList.add(prod3);
        insert prodList;
        
        //Account acc = ICX_TestFactory.createAccount();
        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        insert call;
        
        ICX_ProductEnquired__c prodEnq = ICX_TestFactory.createProductEnquired(prod2.Id, call.Id);

        // Product Enquired created for a new record based on an existing Call
        ICX_ProductEnquired__c prodEnq2 = ICX_TestFactory.createProductEnquired(prod2.Id, null);
        prodEnq2.RelatedTo__c = null;
        prodEnq2.ParentRelatedTo__c = call.Id;
        insert new List<ICX_ProductEnquired__c> {prodEnq, prodEnq2};

        // Test
        Test.startTest();
        List<ICX_ProductLookupSearchResult> resultList = ICX_ProductSearchLookup_LC.searchRecord(call.Id);
        Test.stopTest();

        System.assertEquals(1, resultList.size());
        System.assertEquals(prod2.Id, resultList.get(0).getQualification().Product__c);
        System.assertEquals(prodEnq2.Id, resultList.get(0).getQualification().Id);
    }

    @isTest
    public static void searchUnknownProduct_WithoutParent_Test() {
        // Prepare data
        
        ProductCatalogue__c prod = ICX_TestFactory.createProductCatalogue('Product1', 'M12347');
        insert prod;
        
        //Account acc = ICX_TestFactory.createAccount();
        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        insert call;
        
        ICX_ProductEnquired__c prodEnqUnknownLinkedToCall = ICX_TestFactory.createUnknownProductEnquired(call.Id, 'comment', 'Male', 'Shoes', 'Summer');
        ICX_ProductEnquired__c prodEnqUnknownNotLinkedToCall = ICX_TestFactory.createUnknownProductEnquired(null, 'comment', 'Male', 'Shoes', 'Summer');
        ICX_ProductEnquired__c prodEnqKnownProduct = ICX_TestFactory.createProductEnquired(prod.Id, call.Id);
        insert new List<ICX_ProductEnquired__c> {prodEnqUnknownLinkedToCall, prodEnqUnknownNotLinkedToCall, prodEnqKnownProduct};

        // Test
        Test.startTest();
        List<ICX_ProductLookupSearchResult> resultList = ICX_ProductSearchLookup_LC.searchUnknownProduct(call.Id);
        Test.stopTest();

        System.assertEquals(1, resultList.size());
        System.assertEquals(prodEnqUnknownLinkedToCall.Id, resultList.get(0).getQualification().Id);
    }

    @isTest
    public static void searchUnknownProduct_WithParent_Test() {
        // Prepare data        
        ProductCatalogue__c prod = ICX_TestFactory.createProductCatalogue('Product1', 'M12347');
        insert prod;
        
        //Account acc = ICX_TestFactory.createAccount();
        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        insert call;
        
        ICX_ProductEnquired__c prodEnqParentUnknownLinkedToCall = ICX_TestFactory.createUnknownProductEnquired(call.Id, 'comment', 'Male', 'Shoes', 'Summer');
        ICX_ProductEnquired__c prodEnqChildrenUnknownLinkedToCall = ICX_TestFactory.createUnknownProductEnquired(call.Id, 'comment', 'Male', 'Shoes', 'Summer');
        prodEnqChildrenUnknownLinkedToCall.RelatedTo__c = null;
        prodEnqChildrenUnknownLinkedToCall.ParentRelatedTo__c = call.Id;

        // add Unknown Product not dependant of the 2 first Product Enquired
        ICX_ProductEnquired__c prodEnqOtherUnknownLinkedToCall = ICX_TestFactory.createUnknownProductEnquired(call.Id, 'comment other', 'Male', 'Shoes', 'Summer');

        insert new List<ICX_ProductEnquired__c> {prodEnqParentUnknownLinkedToCall, prodEnqChildrenUnknownLinkedToCall, prodEnqOtherUnknownLinkedToCall};

        // Test
        Test.startTest();
        List<ICX_ProductLookupSearchResult> resultList = ICX_ProductSearchLookup_LC.searchUnknownProduct(call.Id);
        Test.stopTest();

        System.assertEquals(2, resultList.size());
        for (ICX_ProductLookupSearchResult result : resultList) {
            // result should not display the Parent record
            System.assert(result.getQualification().Id != prodEnqParentUnknownLinkedToCall.Id);
        }
    }

    // Search existing records
    @isTest
    public static void searchAll_Test() {
        // Init        
        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        insert call;

        // add product in the call
        ProductCatalogue__c prod = ICX_TestFactory.createProductCatalogue('Product1', 'M12347');
        insert prod;
        ICX_ProductEnquired__c prodEnq = ICX_TestFactory.createProductEnquired(prod.Id, call.Id);
        ICX_ProductEnquired__c prodEnq2 = ICX_TestFactory.createProductEnquired(prod.Id, null);

        // add unknown product in the call
        ICX_ProductEnquired__c unknownProduct = ICX_TestFactory.createUnknownProductEnquired(call.Id, 'comment', 'Male', 'Shoes', 'Summer');
        // add unknown product withour link to the call
        ICX_ProductEnquired__c unknownProductNoCall = ICX_TestFactory.createUnknownProductEnquired(null, 'comment', 'Male', 'Shoes', 'Summer');
        insert new List<ICX_ProductEnquired__c> {prodEnq, prodEnq2, unknownProduct, unknownProductNoCall};

        // Test
        Test.startTest();
        List<List<ICX_ProductLookupSearchResult>> result = ICX_ProductSearchLookup_LC.searchAllRecords(call.Id);
        Test.stopTest();

        // Check
        System.assert(result != null);
        // knownProductResults
        System.assertEquals(1, result.get(0).size());
        System.assertEquals(prodEnq.Id, result.get(0).get(0).getQualification().Id);

        // unknownProductResults
        System.assertEquals(1, result.get(1).size());
        System.assertEquals(unknownProduct.Id, result.get(1).get(0).getQualification().Id);
    }

    @isTest
    public static void addProduct_Task_WithoutParent_WithExistingProduct_Test() {
        // Init
        ProductCatalogue__c prod = ICX_TestFactory.createProductCatalogue('Product1', 'M12347');
        ProductCatalogue__c prod2 = ICX_TestFactory.createProductCatalogue('Product2', 'M12399');
        insert new List<ProductCatalogue__c> {prod, prod2};

        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        call.Product_Sku__c = prod2.Id;
        
        Store__c store = ICX_TestFactory.createStore('Test Store', 'XXX');
        insert store;

        User currentUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_ICONICS_SA);
        currentUser.DefaultStore__c = 'XXX';
        insert currentUser;

        ICX_ProductLookupSearchResult result;
        // Test
        Test.startTest();
        System.runAs(currentUser) {
            insert call;
            result = ICX_ProductSearchLookup_LC.addProduct(prod.Id, call.Id, false, null);
        }
        Test.stopTest();

        // Check
        List<ICX_ProductEnquired__c> resultList = [SELECT Id, Product__c FROM ICX_ProductEnquired__c WHERE Product__c = :prod.Id AND RelatedTo__c = :call.Id];
        System.assertEquals(1, resultList.size());

        // Expect to update the SKU in the Case (from empty to the product)
        Task task = [SELECT Id, Product_Sku__c, Product_Sku_unknown__c FROM Task WHERE Id = :call.Id];
        System.assertEquals(prod2.Id, task.Product_Sku__c);
    }

    @isTest
    public static void addProduct_Case_WithoutParent_WithExistingProduct_Test() {
        // Init
        ProductCatalogue__c prod = ICX_TestFactory.createProductCatalogue('Product1', 'M12347');
        ProductCatalogue__c prod2 = ICX_TestFactory.createProductCatalogue('Product2', 'M12399');
        insert new List<ProductCatalogue__c> {prod, prod2};

        Case cas = ICX_TestFactory.createCase(null);
        cas.Product_Sku__c = prod2.Id; // existing product on the case

        Store__c store = ICX_TestFactory.createStore('Test Store', 'XXX');
        insert store;

        User currentUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_ICONICS_SA);
        currentUser.DefaultStore__c = 'XXX';
        insert currentUser;

        ICX_ProductLookupSearchResult result;
        // Test
        Test.startTest();
        System.runAs(currentUser) {
            insert cas;
            result = ICX_ProductSearchLookup_LC.addProduct(prod.Id, cas.Id, false, null);
        }
        Test.stopTest();

        // Check
        List<ICX_ProductEnquired__c> resultList = [SELECT Id, Request__c, Product__c FROM ICX_ProductEnquired__c WHERE Product__c = :prod.Id AND RelatedTo__c = :cas.Id];
        System.assertEquals(1, resultList.size());

        // Expect to keep the SKU in the Case
        Case caseResult = [SELECT Id, Product_Sku__c FROM Case WHERE Id = :cas.Id];
        System.assertEquals(prod2.Id, caseResult.Product_Sku__c);
        System.assertEquals(caseResult.Id, resultList.get(0).Request__c);
    }

    @isTest
    public static void addProduct_WithoutParent_WithInexistingProduct_Test() {
        // Init
        //ProductCatalogue__c prod = ICX_TestFactory.createProductCatalogue('Product1', 'M12347');
        //insert new List<ProductCatalogue__c> {prod};

        Store__c store = ICX_TestFactory.createStore('Test Store', 'XXX');
        insert store;

        User currentUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_ICONICS_SA);
        currentUser.DefaultStore__c = 'XXX';
        insert currentUser;

        // Comment is not stored during the flow
        String comment = 'Comment for unknown Product';

        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        call.Description = null;
        ICX_ProductLookupSearchResult result;

        // Test
        Test.startTest();
        System.runAs(currentUser) {
            insert call;

            result = ICX_ProductSearchLookup_LC.addProduct(null, call.Id, false, comment);
        }
        Test.stopTest();

        // Check
        List<ICX_ProductEnquired__c> resultList = [SELECT Id, Product__c, Comment__c, Store__c FROM ICX_ProductEnquired__c WHERE Product__c = null AND RelatedTo__c = :call.Id];
        System.assertEquals(1, resultList.size());
        System.assertEquals(comment, resultList.get(0).Comment__c);
        System.assertEquals(store.Id, resultList.get(0).Store__c); // User Store by default for unknown product

        Task task = [SELECT Id, Product_Sku__c, Product_Sku_unknown__c FROM Task WHERE Id = :call.Id];
        System.assertEquals(comment, task.Product_Sku_unknown__c);
    }

    @isTest
    public static void addProduct_WithTaskParent_Test() {
        // Init
        ProductCatalogue__c prod = ICX_TestFactory.createProductCatalogue('Product1', 'M12347');
        ProductCatalogue__c prod2 = ICX_TestFactory.createProductCatalogue('Product2', 'M12399');
        insert new List<ProductCatalogue__c> {prod, prod2};

        Store__c store = ICX_TestFactory.createStore('Test Store', 'XXX');
        insert store;

        User currentUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_ICONICS_SA);
        currentUser.DefaultStore__c = 'XXX';
        insert currentUser;

        ICX_ProductLookupSearchResult result;
        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        call.Product_Sku__c = prod.Id;

        // Test
        Test.startTest();
        System.runAs(currentUser) {
            insert call;

            result = ICX_ProductSearchLookup_LC.addProduct(prod.Id, call.Id, true, null);
        }
        Test.stopTest();

        // Check
        List<ICX_ProductEnquired__c> resultList = [SELECT Id, Product__c FROM ICX_ProductEnquired__c WHERE Product__c = :prod.Id AND RelatedTo__c = null AND ParentRelatedTo__c = :call.Id];
        System.assertEquals(1, resultList.size());

        // Product should not be changed
        Task task = [SELECT Id, Product_Sku__c, Product_Sku_unknown__c FROM Task WHERE Id = :call.Id];
        System.assertEquals(prod.Id, task.Product_Sku__c);
    }

    @isTest
    public static void removeProductEnquired_KnownProduct_WithParent() {
        // Init
        ProductCatalogue__c prod = ICX_TestFactory.createProductCatalogue('Product1', 'M12347');
       // ProductCatalogue__c prod2 = ICX_TestFactory.createProductCatalogue('Product2', 'M12399');
        insert new List<ProductCatalogue__c> {prod};

        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        insert call;

        //ICX_ProductEnquired__c prodEnq = ICX_TestFactory.createProductEnquired(prod.Id, call.Id);
        ICX_ProductEnquired__c prodEnq = new ICX_ProductEnquired__c();
        prodEnq.Product__c = prod.Id;
        prodEnq.ParentRelatedTo__c = call.Id;
        insert prodEnq;

        // Test
        Test.startTest();
        ICX_ProductSearchLookup_LC.removeProductEnquired(prodEnq.Id, true);
        Test.stopTest();

        // Check
        List<ICX_ProductEnquired__c> resultList = [SELECT Id, Product__c FROM ICX_ProductEnquired__c LIMIT 100];
        System.assertEquals(0, resultList.size());
    }

    @isTest
    public static void removeProductEnquired_KnownProduct_WithoutParent_NoDelete() {
        // Init
        ProductCatalogue__c prod = ICX_TestFactory.createProductCatalogue('Product1', 'M12347');
       // ProductCatalogue__c prod2 = ICX_TestFactory.createProductCatalogue('Product2', 'M12399');
        insert new List<ProductCatalogue__c> {prod};

        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        insert call;

        // for New Request, the record is not related to a Task but to a new Request not yet created
        ICX_ProductEnquired__c prodEnq = new ICX_ProductEnquired__c();
        prodEnq.Product__c = prod.Id;
        //prodEnq.ParentRelatedTo__c = call.Id;
        insert prodEnq;

        // Test
        Test.startTest();
        ICX_ProductSearchLookup_LC.removeProductEnquired(prodEnq.Id, true);
        Test.stopTest();

        // Check
        List<ICX_ProductEnquired__c> resultList = [SELECT Id, Product__c FROM ICX_ProductEnquired__c LIMIT 100];
        System.assertEquals(1, resultList.size());
        System.assertEquals(prodEnq.Id, resultList.get(0).Id);
    }

    @isTest
    public static void removeProductEnquired_UnknownProduct_WithoutParent() {
        // Init
        ProductCatalogue__c prod = ICX_TestFactory.createProductCatalogue('Product1', 'M12347');
       // ProductCatalogue__c prod2 = ICX_TestFactory.createProductCatalogue('Product2', 'M12399');
        insert new List<ProductCatalogue__c> {prod};

        String comment = 'myComment';
        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        call.Product_SKU_Unknown__c = comment;
        insert call;

        // Same comment
        ICX_ProductEnquired__c prodEnq = ICX_TestFactory.createUnknownProductEnquired(call.Id, comment, 'Female', 'Leather Goods', 'Spring 19');
        ICX_ProductEnquired__c prodEnq2 = ICX_TestFactory.createUnknownProductEnquired(call.Id, 'newComment', 'Female', 'Leather Goods', 'Spring 19');
        insert new List<ICX_ProductEnquired__c> {prodEnq, prodEnq2};

        // Test
        Test.startTest();
        ICX_ProductSearchLookup_LC.removeProductEnquired(prodEnq.Id, false);
        Test.stopTest();

        // Check
        List<ICX_ProductEnquired__c> resultList = [SELECT Id, Comment__c FROM ICX_ProductEnquired__c LIMIT 100];
        System.assertEquals(1, resultList.size());
        System.assertEquals(prodEnq2.Id, resultList.get(0).Id);

        // Comment task should not be changed
        Task task = [SELECT Id, Product_Sku__c, Product_Sku_unknown__c FROM Task WHERE Id = :call.Id];
        System.assertEquals('newComment', task.Product_Sku_unknown__c);

    }

    @isTest
    public static void removeProduct_WithTaskParent() {
        // Init
        ProductCatalogue__c prod = ICX_TestFactory.createProductCatalogue('Product1', 'M12347');
        ProductCatalogue__c prod2 = ICX_TestFactory.createProductCatalogue('Product2', 'M12399');
        insert new List<ProductCatalogue__c> {prod, prod2};

        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        call.Product_Sku__c = prod.Id;
        insert call;

        ICX_ProductEnquired__c prodEnq = ICX_TestFactory.createProductEnquired(prod.Id, call.Id);
        ICX_ProductEnquired__c prodEnq2 = ICX_TestFactory.createProductEnquired(prod2.Id, call.Id);
        insert new List<ICX_Productenquired__c> {prodEnq, prodEnq2};

        // Test
        Test.startTest();
        ICX_ProductSearchLookup_LC.removeProductEnquired(prodEnq.Id, false);
        Test.stopTest();

        // Check
        List<ICX_ProductEnquired__c> resultList = [SELECT Id, Product__c FROM ICX_ProductEnquired__c];
        System.assertEquals(1, resultList.size());
        System.assertEquals(prodEnq2.Id, resultList.get(0).Id);

        // Product should not be changed
        Task task = [SELECT Id, Product_Sku__c FROM Task WHERE Id = :call.Id LIMIT 1];
        System.assertEquals(prod2.Id, task.Product_Sku__c);
    }

	@isTest
    public static void saveAll_Test() {
        
        String comment = 'myComment';
        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        call.Product_SKU_Unknown__c = comment;
        insert call;

        ICX_ProductEnquired__c prodEnq = ICX_TestFactory.createUnknownProductEnquired(call.Id, comment, 'Female', 'Leather Goods', 'Spring 19');
        //ICX_ProductEnquired__c prodEnq2 = ICX_TestFactory.createUnknownProductEnquired(call.Id, 'newComment', 'Female', 'Leather Goods', 'Spring 19');
        insert new List<ICX_ProductEnquired__c> {prodEnq};

        // update collection
        String newCollection = 'New Collection';
        String json = '[{"icon":"https://www.louisvuitton.com/images/is/image/lv/1/PP_VP_L/louisvuitton--BDRU1PWC12_PM2_Front view.jpg","id":"' + prodEnq.Id + '","isIconUrl":true,"relatedName":"","sObjectType":"ProductCatalogue__c","subtitle":"1A34DE • Souliers","title":"Rivoli Sneaker","qualification":{' 
            + '"Product__c":"","RelatedTo__c":"' + call.Id + '","Id":"' + prodEnq.Id + '","ProductCollection__c":"' + newCollection + '"}}]';

        // Test
        Test.startTest();
        ICX_ProductSearchLookup_LC.saveAll(json);
        Test.stopTest();

        // Check
		List<ICX_ProductEnquired__c> resultList = [SELECT Id, ProductCollection__c FROM ICX_ProductEnquired__c LIMIT 100];
        System.assertEquals(1, resultList.size());
        System.assertEquals(newCollection, resultList.get(0).ProductCollection__c);
    }
    @isTest
    public static void getOpenStores() {
        List<Store__c> store = new list<Store__c>();
        Test.startTest();
        store = ICX_ProductSearchLookup_LC.getOpenStores();
        Test.stopTest();
    }
    @isTest
    public static void getAccountByEmail_Test(){
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Test.startTest();
        ICX_ProductSearchLookup_LC.getAccountByEmail(acc.Id, acc.PersonEmail);
        Test.stopTest();
    }
}