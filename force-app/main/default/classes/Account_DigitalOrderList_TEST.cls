@Istest
global class Account_DigitalOrderList_TEST  {

    @testSetup  
    static void makeData(){

        store__c store = createStore('A90');
        insert store;

        Account acc = createAccount('test', 'test', null, 'exclusive_sales@yopmail.com');
        insert acc;
        
		ProductCatalogue__c product = new ProductCatalogue__c(SKU__c = 'M43506');
		insert product;
    }
     @isTest static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new Account_DigitalOrderList_TEST.OrderHttpCalloutMock()); 
        Test.startTest();
        Account  acc = [SELECT id  FROM Account limit 1];
        Object response = Account_DigitalOrderListControllerLWC.getDigitalOrder(acc.id);
        Test.stopTest();
        system.assertnotequals(null,response);
    }
	@isTest static void testMethod2() {
		store__c store = [select id, StoreCountry__c from store__c limit 1];
        Test.startTest();
        Map<String, Id> prodMap = Account_DigitalOrderListControllerLWC.getProductMap( new List<String>{'M43506'});
		String country = Account_DigitalOrderListControllerLWC.getStoreCountry(store.id);
		Id caseRT = Account_DigitalOrderListControllerLWC.getCaseRecordTypeID();
        Test.stopTest();
		system.assertnotequals(prodMap.get('M43506'), null);
		system.assertequals(store.StoreCountry__c, country);
        system.assertnotequals(null, caseRT);

    }
    private static store__c createStore(String retailStoreId) {
        store__c storeRecord = new store__c();
        storeRecord.RetailStoreId__c = retailStoreId;
        storeRecord.Name = 'Louis Vuitton';
        storeRecord.StoreType__c = 'CSC' ;
		storeRecord.StoreCountry__c = 'France';
        return storeRecord;
    }
    private static Account createAccount(String firstname, String lastname, String phone, String email) {
        Account acc = new Account();
        acc.Firstname = firstname;
        acc.LastName = lastname;
        acc.PersonMobilePhone = phone;
        acc.PersonEmail = email;
        return acc;
    }
    
    global class OrderHttpCalloutMock implements HttpCalloutMock {

        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(infoOrder());
            response.setStatusCode(200);
            return response; 
        }
    }
     public static string infoOrder(){
        return '{'+
		'   \"customer\":{'+
		'      \"email\":\"exclusive_sales@yopmail.com\",'+
		'      \"salesForceId\":\"0013D00000y8oLJQAY\"'+
		'   },'+
		'   \"orders\":['+
		'      {'+
		'         \"commerceItem\":['+
		'            {'+
		'               \"productDisplayName\":\"Keepall Bandoulière 55\",'+
		'               \"backOrderDisclaimer\":false,'+
		'               \"isExclusive\":false,'+
		'               \"IHS\":false,'+
		'               \"detailedDescription\":\"<ul> \\n <li>Coated Canvas</li> \\n <li>Natural Cowhide Leather trimmings</li> \\n <li>Cotton Textile Lining</li> \\n \\n <li>Golden brass pieces</li> \\n <li>Double zip closure</li> \\n \\n <li>Removable leather ID holder</li> \\n <li>Padlock</li> \\n <li>Cabin size</li> \\n</ul><p>The reference is either made in France, Spain, Italy or in the US.</p>\",'+
		'               \"_links\":{'+
		'                  \"self\":{'+
		'                     \"href\":\"/api/catalog/eng-us/product/M41414\"'+
		'                  },'+
		'                  \"/api/rels/eng-us/change-cart-qty\":{'+
		'                     \"name\":\"change-cart-qty\",'+
		'                     \"href\":\"/api/cart/eng-us/ci4712000061\"'+
		'                  },'+
		'                  \"/api/rels/eng-us/remove-from-cart\":{'+
		'                     \"name\":\"remove-from-cart\",'+
		'                     \"href\":\"/api/cart/eng-us/ci4712000061\"'+
		'                  }'+
		'               },'+
		'               \"mixAndMatchParent\":false,'+
		'               \"fluid\":false,'+
		'               \"quantity\":1,'+
		'               \"mixAndMatch\":false,'+
		'               \"productRelativeURL\":\"https://us-i1f.louisvuitton.com/eng-us/products/keepall-bandouliere-55-monogram-canvas-000698\",'+
		'               \"productMaterialDisplayName\":\"Monogram Canvas\",'+
		'               \"skuDisplayName\":\"Keepall Bandouli?re 55\",'+
		'               \"image\":['+
		'                  {'+
		'                     \"contentUrl\":\"https://us-i1f.louisvuitton.com/images/is/image/lvprp/1/PP_VP_L/louis-vuitton-keepall-bandouli?re-55--M41414_PM2_Front view.jpg?wid={IMG_WIDTH}&hei={IMG_HEIGHT}\"'+
		'                  },'+
		'                  {'+
		'                     \"contentUrl\":\"https://us-i1f.louisvuitton.com/images/is/image/lvprp/1/PP_VP_L/louis-vuitton-keepall-bandouli?re-55--M41414_PM1_Worn view.jpg?wid={IMG_WIDTH}&hei={IMG_HEIGHT}\"'+
		'                  },'+
		'                  {'+
		'                     \"contentUrl\":\"https://us-i1f.louisvuitton.com/images/is/image/lvprp/1/PP_VP_L/louis-vuitton-keepall-bandouli?re-55--M41414_PM1_Side view.jpg?wid={IMG_WIDTH}&hei={IMG_HEIGHT}\"'+
		'                  },'+
		'                  {'+
		'                     \"contentUrl\":\"https://us-i1f.louisvuitton.com/images/is/image/lvprp/1/PP_VP_L/louis-vuitton-keepall-bandouli?re-55--M41414_PM1_Interior view.jpg?wid={IMG_WIDTH}&hei={IMG_HEIGHT}\"'+
		'                  },'+
		'                  {'+
		'                     \"contentUrl\":\"https://us-i1f.louisvuitton.com/images/is/image/lvprp/1/PP_VP_L/louis-vuitton-keepall-bandouli?re-55--M41414_PM1_Detail view.jpg?wid={IMG_WIDTH}&hei={IMG_HEIGHT}\"'+
		'                  },'+
		'                  {'+
		'                     \"contentUrl\":\"https://us-i1f.louisvuitton.com/images/is/image/lvprp/1/PP_VP_L/louis-vuitton-keepall-bandouli?re-55--M41414_PM1_Ambiance view.jpg?wid={IMG_WIDTH}&hei={IMG_HEIGHT}\"'+
		'                  },'+
		'                  {'+
		'                     \"contentUrl\":\"https://us-i1f.louisvuitton.com/images/is/image/lvprp/1/PP_VP_L/louis-vuitton-keepall-bandouli?re-55--M41414_PM1_Back view.jpg?wid={IMG_WIDTH}&hei={IMG_HEIGHT}\"'+
		'                  }'+
		'               ],'+
		'               \"mom\":false,'+
		'               \"productId\":\"000698\",'+
		'               \"fullDepositBackOrder\":false,'+
		'               \"priceInfo\":{'+
		'                  \"currencyCode\":\"EUR\",'+
		'                  \"unitPrice\":\"1,083.33€\",'+
		'                  \"taxAmount\":216.67,'+
		'                  \"price\":\"1,083.33€\",'+
		'                  \"doublePrice\":1083.33,'+
		'                  \"totalPrice\":\"1,083.33€\"'+
		'               },'+
		'               \"skuColorDisplayName\":\"Vuittonite\",'+
		'               \"backOrder\":false,'+
		'               \"catalogRefId\":\"M41414\",'+
		'               \"shippingGroupId\":\"E19394\",'+
		'               \"imageURL\":\"https://us-i1f.louisvuitton.com/images/is/image/lvprp/1/PP_VP_L/louis-vuitton--M41414_PM2_Front view.jpg?wid={IMG_WIDTH}&hei={IMG_HEIGHT}\"'+
		'            }'+
		'         ],'+
		'         \"containsStandard\":true,'+
		'         \"state\":\"PENDING_MERCHANT_ACTION\",'+
		'         \"payPalAvailable\":true,'+
		'         \"containsPerfume\":false,'+
		'         \"commerceItemTotalQuantity\":1,'+
		'         \"containsPerso\":false,'+
		'         \"splitSeveralPackages\":false,'+
		'         \"selectedCC\":false,'+
		'         \"cartPriceInfo\":{'+
		'            \"rawShippingDisplayAmount\":0,'+
		'            \"displayableTotalWithTaxAmount\":\"$1,300.00\",'+
		'            \"displayableShippingAmount\":\"$0.00\",'+
		'            \"currencyCode\":\"EUR\",'+
		'            \"displayableSubTotalAmount\":\"$1,083.33\",'+
		'            \"taxAmount\":216.67,'+
		'            \"rawTotalTaxIncluded\":1300,'+
		'            \"displayableTaxAmount\":\"$216.67\"'+
		'         },'+
		'         \"rmsStoreCode\":\"A90\",'+
		'         \"shippingGroups\":['+
		'            {'+
		'               \"state\":\"INITIAL\",'+
		'               \"deliveryDelay\":\"Frais de livraison offerts\",'+
		'               \"shippingMethod\":\"deliverystandardFR\",'+
		'               \"trackingNumbers\":[ ],'+
		'               \"shippingAddress\":{'+
		'                  \"phoneNumberInternational\":\"+33611223344\",'+
		'                  \"phoneNumberCountry\":\"FR\",'+
		'                  \"displayPhoneNumber\":\"(+33)0611223344\",'+
		'                  \"address1\":\"67 Rue de Romainville\",'+
		'                  \"city\":\"Paris\",'+
		'                  \"title\":\"tMr\",'+
		'                  \"postalCode\":\"75020\",'+
		'                  \"phoneNumber\":\"0611223344\",'+
		'                  \"description\":\"Paris\",'+
		'                  \"firstName\":\"Exclusive\",'+
		'                  \"addressName\":\"add25220010\",'+
		'                  \"lastName\":\"Sales\",'+
		'                  \"mainAddress\":false,'+
		'                  \"country\":\"FR\",'+
		'                  \"phoneNumberType\":\"mobile\"'+
		'               },'+
		'               \"identifier\":\"E19394\"'+
		'            }'+
		'         ],'+
		'         \"commerceItemCount\":1,'+
		'         \"orderOrigin\":\"web\",'+
		'         \"paymentGroups\":['+
		'            {'+
		'               \"billingAddress\":{'+
		'                  \"phoneNumberInternational\":\"+33611223344\",'+
		'                  \"phoneNumberCountry\":\"FR\",'+
		'                  \"displayPhoneNumber\":\"(+33)0611223344\",'+
		'                  \"address1\":\"67 Rue de Romainville\",'+
		'                  \"city\":\"Paris\",'+
		'                  \"title\":\"tMr\",'+
		'                  \"postalCode\":\"75020\",'+
		'                  \"phoneNumber\":\"0611223344\",'+
		'                  \"description\":\"Paris\",'+
		'                  \"firstName\":\"Exclusive\",'+
		'                  \"addressName\":\"add25220010\",'+
		'                  \"lastName\":\"Sales\",'+
		'                  \"mainAddress\":false,'+
		'                  \"country\":\"FR\",'+
		'                  \"phoneNumberType\":\"mobile\"'+
		'               },'+
		'               \"shippingGroupId\":\"E19394\",'+
		'               \"paymentMethod\":\"creditCard\",'+
		'               \"addressName\":\"add25220010\"'+
		'            }'+
		'         ],'+
		'         \"submittedDate\":\"10-15-2020\",'+
		'         \"lastModifiedDate\":\"10-15-2020\",'+
		'         \"containsBo\":false,'+
		'         \"identifier\":\"nx6121040\",'+
		'         \"orderVersion\":86'+
		'      }'+
		'   ]'+
		'}';
    }
    
}