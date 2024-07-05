@isTest
global class BatchStoreInfos_TEST {

    @isTest
    static void testBatch() {
        // create a store
        Store__c st = LV_TestFactory.createStore('LV TEST STORE MIY', 'Store', 'A00', 'FRANCE', 'EUR', 'Open');
        insert st;
        BatchStoreInfos myBatch = new BatchStoreInfos();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Database.executeBatch(myBatch,5);
    Test.stopTest();
    }


      static testMethod void testBatch2() {
          
       Store__c st = LV_TestFactory.createStore('LV TEST STORE MIY', 'Store', 'A00', 'FRANCE', 'EUR', 'Open');

        insert st;
           
        BatchStoreInfosScheduler myScheduler = new BatchStoreInfosScheduler();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String sch = '0 0 23 L * ?';
        system.schedule('Test check', sch, myScheduler);
        Test.stopTest();

    }

    global class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            
            //string instance = System.Url.getOrgDomainUrl().toExternalForm();
            //HttpRequest httpRequest = new HttpRequest();
            //httpRequest.setEndpoint(instance + '/services/data/v45.0/ui-api/object-info/case/picklist-values/recordTypeId');
            //System.assertEquals('http://example.com/example/test', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ phone: "+49 (0) 211 864 700 (Kundenservice)", callCenter: false, clickAndCollect: { storeHours: [ { hours: "", day: "Monday" }, { hours: "", day: "Tuesday" }, { hours: "", day: "Wednesday" }, { hours: "", day: "Thursday" }, { hours: "", day: "Friday" }, { hours: "", day: "Saturday" }, { hours: "", day: "Sunday" } ], estimatedDeliveryDate: { time: 1584988159074 }, delayInCC: { }, estimatedDeliveryDateAsString: "23-03-2020", availableForCC: true, cutOff: 13, rmsCode: "J02", delay: 2, closingDays: "Vorübergehend geschlossen" }, street: "Residenzstrasse 2", availableForCC: false, city: "München", @id: "J02", formattedImgUrl: "https://de.louisvuitton.com/images/is/image/lv/1/PP_VP_L/louis-vuitton--StFi_Louis_Vuitton_MUNICH_MAXIMILLIANSTRASSE_311_1_DI3.jpg?wid={IMG_WIDTH}&hei={IMG_HEIGHT}", distance: 0, name: "Louis Vuitton München Residenzpost", path: "deutschland", longitude: 11.578, zipcode: "80333", country: "Deutschland", picture: "StFi_Louis_Vuitton_MUNICH_MAXIMILLIANSTRASSE_311_1_DI3", flagship: false, displayLocateInStore: true, categories: [ "Leather_Goods_and_Accessories", "MLV", "Sunglasses", "Ready_To_Wear_Women", "Ready_To_Wear_Men", "Shoe_Women", "Shoe_Men", "Watches", "Jewelry", "Perfume" ], latitude: 48.14 }');
            res.setStatusCode(200);
            res.setStatus('SUCCESS');
            return res;
        }
    }
}