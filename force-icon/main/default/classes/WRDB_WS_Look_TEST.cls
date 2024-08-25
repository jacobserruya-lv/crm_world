@isTest
private class WRDB_WS_Look_TEST {
	
	@isTest static void test_save() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		Store__c store1= new Store__c(RetailStoreId__c = 'A06',StoreCountry__c = 'FRANCE',Zone__c = 'a0Oi000000SIBHUEA5');
		insert store1;
        ProductCatalogue__c prd1 = new ProductCatalogue__c(SKU__c = 'M40855');
        insert prd1;
        ProductCatalogue__c prd2 = new ProductCatalogue__c(SKU__c = 'M70662');
        insert prd2;
        ProductCatalogue__c prd3 = new ProductCatalogue__c(SKU__c = 'M70659');
        insert prd3;
         // For Test EcryptLookId
         insert new IDENTITY_Settings__c( 
            Username_Suffix__c = '@louisvuitton.com',
            //ProfileId__c = !profiles.isEmpty() ? profiles[0].Id : '',
           // Integration_User_Id__c = UserInfo.getUserId(),
           // Guest_User_Id__c = !users.isEmpty() ? users[0].Id : '',
            Language_Country_Values__c = 'eng-e1 / fra-fr',
            Default_Language_Country_Parameter__c = 'eng-e1',
            Default_Origin_Parameter__c = 'mylv',
            Community_URL__c = 'https://integ2-louisvuitton.cs70.force.com',
            AES_Key__c = 'iKhco6t8RnE0DaDcTzG3XQ==',
            Deactivate_User_After__c = 365,
            Activate_New_Design__c = true
        );
		String json = '{' +
                    '"is_draft": true,'+
                    '"is_inspiration": false,'+
                    '"layoutUrlMobile": "https://mosaic-prp.louisvuitton.com/composition/300x300/ng:M40855_PM2_Front view:300x200+0+0/ng:M70662_PM2_Front view:150x100+0+200/ng:M70659_PM2_Front view:150x100+150+200",'+
                    '"layoutUrlWeb": "https://mosaic-prp.louisvuitton.com/composition/1200x1200/ng:M40855_PM2_Front view:1200x800+0+0/ng:M70662_PM2_Front view:600x400+0+800/ng:M70659_PM2_Front view:600x400+600+800",'+
                    '"locale": "fr_FR",'+
                    '"master_sku": "M40855",'+
                    '"share_with_store": false,'+
                    '"skus": ["M40855", "M70662", "M70659"],'+
                                       '"user_identifier": "jeremym@balink.net.lv.icon",'+
            	    '"lookId": "a2B3D000000MdkdUAC",'+
                    '"name": "ciao",'+
                    '"validity_date": "2020-07-10",'+
                    '"store_codes": ["A06"],'+
            		'"countries": ["ITALY","JAPAN"],'+
                    '"zones": ["ITALY","JAPAN"]'+
				'}';

		req.requestURI = '/services/apexrest/Look/';
		req.requestBody = Blob.valueOf(json);
		req.httpMethod = 'POST';
		req.addHeader('Content-Type','application/json');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		WRDB_WS_Look.post();


		Test.stopTest();
        BL_ICON_Wardrobing_Encryption bat = new 	BL_ICON_Wardrobing_Encryption();
        ID batchprocessid = Database.executeBatch(bat,2);


	}

    @isTest static void test_save2() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		Store__c store1= new Store__c(RetailStoreId__c = 'A06',StoreCountry__c = 'FRANCE',Zone__c = 'a0Oi000000SIBHUEA5');
		insert store1;
        ProductCatalogue__c prd1 = new ProductCatalogue__c(SKU__c = 'M40855');
        insert prd1;
        ProductCatalogue__c prd2 = new ProductCatalogue__c(SKU__c = 'M70662');
        insert prd2;
        ProductCatalogue__c prd3 = new ProductCatalogue__c(SKU__c = 'M70659');
        insert prd3;
         // For Test EcryptLookId
         insert new IDENTITY_Settings__c( 
            Username_Suffix__c = '@louisvuitton.com',
            //ProfileId__c = !profiles.isEmpty() ? profiles[0].Id : '',
           // Integration_User_Id__c = UserInfo.getUserId(),
           // Guest_User_Id__c = !users.isEmpty() ? users[0].Id : '',
            Language_Country_Values__c = 'eng-e1 / fra-fr',
            Default_Language_Country_Parameter__c = 'eng-e1',
            Default_Origin_Parameter__c = 'mylv',
            Community_URL__c = 'https://integ2-louisvuitton.cs70.force.com',
            AES_Key__c = 'iKhco6t8RnE0DaDcTzG3XQ==',
            Deactivate_User_After__c = 365,
            Activate_New_Design__c = true
        );
		String json = '{' +
                    '"is_draft": true,'+
                    '"is_inspiration": false,'+
                    '"layoutUrlMobile": "https://mosaic-prp.louisvuitton.com/composition/300x300/ng:M40855_PM2_Front view:300x200+0+0/ng:M70662_PM2_Front view:150x100+0+200/ng:M70659_PM2_Front view:150x100+150+200",'+
                    '"layoutUrlWeb": "https://mosaic-prp.louisvuitton.com/composition/1200x1200/ng:M40855_PM2_Front view:1200x800+0+0/ng:M70662_PM2_Front view:600x400+0+800/ng:M70659_PM2_Front view:600x400+600+800",'+
                    '"locale": "fr_FR",'+
                    '"master_sku": "M40855",'+
                    '"share_with_store": false,'+
                    '"skus": ["M40855", "M70662", "M70659"],'+
                                       '"user_identifier": "jeremym@balink.net.lv.icon",'+
            	    '"lookId": "a2B3D000000MdkdUAC",'+
                    '"name": "ciao",'+
                    '"validity_date": "2020-07-10",'+
                    
            		'"countries": ["ITALY","JAPAN"],'+
                    '"zones": ["ITALY","JAPAN"]'+
				'}';

		req.requestURI = '/services/apexrest/Look/';
		req.requestBody = Blob.valueOf(json);
		req.httpMethod = 'POST';
		req.addHeader('Content-Type','application/json');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		WRDB_WS_Look.post();


		Test.stopTest();
        BL_ICON_Wardrobing_Encryption bat = new 	BL_ICON_Wardrobing_Encryption();
        ID batchprocessid = Database.executeBatch(bat,2);


	}

    @isTest static void test_save3() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		Store__c store1= new Store__c(RetailStoreId__c = 'A06',StoreCountry__c = 'FRANCE',Zone__c = 'a0Oi000000SIBHUEA5');
		insert store1;
        ProductCatalogue__c prd1 = new ProductCatalogue__c(SKU__c = 'M40855');
        insert prd1;
        ProductCatalogue__c prd2 = new ProductCatalogue__c(SKU__c = 'M70662');
        insert prd2;
        ProductCatalogue__c prd3 = new ProductCatalogue__c(SKU__c = 'M70659');
        insert prd3;
         // For Test EcryptLookId
         insert new IDENTITY_Settings__c( 
            Username_Suffix__c = '@louisvuitton.com',
            //ProfileId__c = !profiles.isEmpty() ? profiles[0].Id : '',
           // Integration_User_Id__c = UserInfo.getUserId(),
           // Guest_User_Id__c = !users.isEmpty() ? users[0].Id : '',
            Language_Country_Values__c = 'eng-e1 / fra-fr',
            Default_Language_Country_Parameter__c = 'eng-e1',
            Default_Origin_Parameter__c = 'mylv',
            Community_URL__c = 'https://integ2-louisvuitton.cs70.force.com',
            AES_Key__c = 'iKhco6t8RnE0DaDcTzG3XQ==',
            Deactivate_User_After__c = 365,
            Activate_New_Design__c = true
        );
		String json = '{' +
                    '"is_draft": true,'+
                    '"is_inspiration": false,'+
                    '"layoutUrlMobile": "https://mosaic-prp.louisvuitton.com/composition/300x300/ng:M40855_PM2_Front view:300x200+0+0/ng:M70662_PM2_Front view:150x100+0+200/ng:M70659_PM2_Front view:150x100+150+200",'+
                    '"layoutUrlWeb": "https://mosaic-prp.louisvuitton.com/composition/1200x1200/ng:M40855_PM2_Front view:1200x800+0+0/ng:M70662_PM2_Front view:600x400+0+800/ng:M70659_PM2_Front view:600x400+600+800",'+
                    '"locale": "fr_FR",'+
                    '"master_sku": "M40855",'+
                    '"share_with_store": false,'+
                    '"skus": ["M40855", "M70662", "M70659"],'+
                                       '"user_identifier": "jeremym@balink.net.lv.icon",'+
            	    '"lookId": "a2B3D000000MdkdUAC",'+
                    '"name": "ciao",'+
                    '"validity_date": "2020-07-10",'+
                    
            		
                    '"zones": ["ITALY","JAPAN"]'+
				'}';

		req.requestURI = '/services/apexrest/Look/';
		req.requestBody = Blob.valueOf(json);
		req.httpMethod = 'POST';
		req.addHeader('Content-Type','application/json');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		WRDB_WS_Look.post();


		Test.stopTest();
        BL_ICON_Wardrobing_Encryption bat = new 	BL_ICON_Wardrobing_Encryption();
        ID batchprocessid = Database.executeBatch(bat,2);


	}

    
    @isTest static void test_save4() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		Store__c store1= new Store__c(RetailStoreId__c = 'A06',StoreCountry__c = 'FRANCE',Zone__c = 'a0Oi000000SIBHUEA5');
		insert store1;
        ProductCatalogue__c prd1 = new ProductCatalogue__c(SKU__c = 'M40855');
        insert prd1;
        ProductCatalogue__c prd2 = new ProductCatalogue__c(SKU__c = 'M70662');
        insert prd2;
        ProductCatalogue__c prd3 = new ProductCatalogue__c(SKU__c = 'M70659');
        insert prd3;
         // For Test EcryptLookId
         insert new IDENTITY_Settings__c( 
            Username_Suffix__c = '@louisvuitton.com',
            //ProfileId__c = !profiles.isEmpty() ? profiles[0].Id : '',
           // Integration_User_Id__c = UserInfo.getUserId(),
           // Guest_User_Id__c = !users.isEmpty() ? users[0].Id : '',
            Language_Country_Values__c = 'eng-e1 / fra-fr',
            Default_Language_Country_Parameter__c = 'eng-e1',
            Default_Origin_Parameter__c = 'mylv',
            Community_URL__c = 'https://integ2-louisvuitton.cs70.force.com',
            AES_Key__c = 'iKhco6t8RnE0DaDcTzG3XQ==',
            Deactivate_User_After__c = 365,
            Activate_New_Design__c = true
        );
		String json = '{' +
                    '"is_draft": true,'+
                    '"is_inspiration": false,'+
                    '"zones": ["ITALY","JAPAN"],'+
                    '"layoutUrlMobile": "https://mosaic-prp.louisvuitton.com/composition/300x300/ng:M40855_PM2_Front view:300x200+0+0/ng:M70662_PM2_Front view:150x100+0+200/ng:M70659_PM2_Front view:150x100+150+200",'+
                    '"layoutUrlWeb": "https://mosaic-prp.louisvuitton.com/composition/1200x1200/ng:M40855_PM2_Front view:1200x800+0+0/ng:M70662_PM2_Front view:600x400+0+800/ng:M70659_PM2_Front view:600x400+600+800",'+
                    '"locale": "fr_FR",'+
                    '"master_sku": "M40855",'+
                    '"share_with_store": false,'+
                    '"skus": ["M40855", "M70662", "M70659"],'+
                    '"user_identifier": "jeremym@balink.net.lv.icon",'+
            	    '"lookId": "a2B3D000000MdkdUAC",'+
                    '"name": "ciao"'+
                    
				'}';

		req.requestURI = '/services/apexrest/Look/';
		req.requestBody = Blob.valueOf(json);
		req.httpMethod = 'POST';
		req.addHeader('Content-Type','application/json');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		WRDB_WS_Look.post();


		Test.stopTest();
        BL_ICON_Wardrobing_Encryption bat = new 	BL_ICON_Wardrobing_Encryption();
        ID batchprocessid = Database.executeBatch(bat,2);


	}

    @isTest static void test_error() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
         // For Test EcryptLookId
         insert new IDENTITY_Settings__c( 
            Username_Suffix__c = '@louisvuitton.com',
            //ProfileId__c = !profiles.isEmpty() ? profiles[0].Id : '',
           // Integration_User_Id__c = UserInfo.getUserId(),
           // Guest_User_Id__c = !users.isEmpty() ? users[0].Id : '',
            Language_Country_Values__c = 'eng-e1 / fra-fr',
            Default_Language_Country_Parameter__c = 'eng-e1',
            Default_Origin_Parameter__c = 'mylv',
            Community_URL__c = 'https://integ2-louisvuitton.cs70.force.com',
            AES_Key__c = 'iKhco6t8RnE0DaDcTzG3XQ==',
            Deactivate_User_After__c = 365,
            Activate_New_Design__c = true
        );
		String json ='{' +
                    '"is_draft": true,'+
                    '"is_inspiration": false,'+
                    '"layoutUrlMobile": "https://mosaic-prp.louisvuitton.com/composition/300x300/ng:M40855_PM2_Front view:300x200+0+0/ng:M70662_PM2_Front view:150x100+0+200/ng:M70659_PM2_Front view:150x100+150+200",'+
                    '"layoutUrlWeb": "https://mosaic-prp.louisvuitton.com/composition/1200x1200/ng:M40855_PM2_Front view:1200x800+0+0/ng:M70662_PM2_Front view:600x400+0+800/ng:M70659_PM2_Front view:600x400+600+800",'+
                    '"locale": "fr_FR",'+
                    '"master_sku": "M40855",'+
                    '"share_with_store": false,'+
                    '"skus": ["M40855", "M70662", "M70659"],'+
                                       '"user_identifier": "jeremym@balink.net.lv.icon",'+
            	    '"lookId": "a2B3D000000MdkdUAC",'+
                    '"name": "ciao",'+
                    '"validity_date": "2020-07-10",'+
                    '"store_codes": ["A06"],'+
            		'"countries": ["ITALY","JAPAN"],'+
                    '"zones": ["ITALY","JAPAN"]'+
				'}';

		req.requestURI = '/services/apexrest/Look/';
		req.requestBody = Blob.valueOf(json);
		req.httpMethod = 'POST';
		req.addHeader('Content-Type','application/json');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		WRDB_WS_Look.post();
		Test.stopTest();
	}

    @isTest static void test_share() {
        Store__c store1=  new Store__c(RetailStoreId__c = 'A06',StoreCountry__c = 'FRANCE',Zone__c = 'a0Oi000000SIBHUEA5');
		insert store1;
        ProductCatalogue__c prd1 = new ProductCatalogue__c(SKU__c = 'M40855');
        insert prd1;
        ProductCatalogue__c prd2 = new ProductCatalogue__c(SKU__c = 'M70662');
        insert prd2;
        ProductCatalogue__c prd3 = new ProductCatalogue__c(SKU__c = 'M70659');
        insert prd3;
 // For Test EcryptLookId
         insert new IDENTITY_Settings__c( 
            Username_Suffix__c = '@louisvuitton.com',
            //ProfileId__c = !profiles.isEmpty() ? profiles[0].Id : '',
           // Integration_User_Id__c = UserInfo.getUserId(),
           // Guest_User_Id__c = !users.isEmpty() ? users[0].Id : '',
            Language_Country_Values__c = 'eng-e1 / fra-fr',
            Default_Language_Country_Parameter__c = 'eng-e1',
            Default_Origin_Parameter__c = 'mylv',
            Community_URL__c = 'https://integ2-louisvuitton.cs70.force.com',
            AES_Key__c = 'iKhco6t8RnE0DaDcTzG3XQ==',
            Deactivate_User_After__c = 365,
            Activate_New_Design__c = true
        );
        String json1 = '{' +
                    '"is_draft": true,'+
                    '"is_inspiration": false,'+
                    '"layoutUrlMobile": "https://mosaic-prp.louisvuitton.com/composition/300x300/ng:M40855_PM2_Front view:300x200+0+0/ng:M70662_PM2_Front view:150x100+0+200/ng:M70659_PM2_Front view:150x100+150+200",'+
                    '"layoutUrlWeb": "https://mosaic-prp.louisvuitton.com/composition/1200x1200/ng:M40855_PM2_Front view:1200x800+0+0/ng:M70662_PM2_Front view:600x400+0+800/ng:M70659_PM2_Front view:600x400+600+800",'+
                    '"locale": "fr_FR",'+
                    '"master_sku": "M40855",'+
                    '"share_with_store": false,'+
                    '"skus": ["M40855", "M70662", "M70659"],'+
                                       '"user_identifier": "jeremym@balink.net.lv.icon",'+
            	    '"lookId": "a2B3D000000MdkdUAC",'+
                    '"name": "ciao",'+
                    '"validity_date": "2020-07-10",'+
                    '"store_codes": ["A06"],'+
            		'"countries": ["ITALY","JAPAN"],'+
                    '"zones": ["ITALY","JAPAN"],'+
                    '"channel": "SMS"'+
				'}';
        Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(json1);
        WRDB_WS_Look.saveLook(body);
        
        List<Look__c> looks = [select id from look__c Limit 1];
        
        Look__c look = looks[0];
        string name = WRDB_WS_Look.getLookName('M40855');
        Account acc = IC_TestFactory.createAccount();
	    insert acc;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
       
		String json = '{'+
                        
                    '"lookId": "'+ WRDB_WS_Look.getEncryptedId(look.Id) +
                    '","client_id": "'+ acc.Id +
                    '","channel": "SMS"'+
				'}';

		req.requestURI = '/services/apexrest/Look/Share';
		req.requestBody = Blob.valueOf(json);
		req.httpMethod = 'POST';
		req.addHeader('Content-Type','application/json');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		WRDB_WS_Look.post();
		Test.stopTest();
	}

    @isTest static void test_archive() {
        Store__c store1=  new Store__c(RetailStoreId__c = 'A06',StoreCountry__c = 'FRANCE',Zone__c = 'a0Oi000000SIBHUEA5');
		insert store1;
        ProductCatalogue__c prd1 = new ProductCatalogue__c(SKU__c = 'M40855');
        insert prd1;
        ProductCatalogue__c prd2 = new ProductCatalogue__c(SKU__c = 'M70662');
        insert prd2;
        ProductCatalogue__c prd3 = new ProductCatalogue__c(SKU__c = 'M70659');
        insert prd3;
 // For Test EcryptLookId
         insert new IDENTITY_Settings__c( 
            Username_Suffix__c = '@louisvuitton.com',
            //ProfileId__c = !profiles.isEmpty() ? profiles[0].Id : '',
           // Integration_User_Id__c = UserInfo.getUserId(),
           // Guest_User_Id__c = !users.isEmpty() ? users[0].Id : '',
            Language_Country_Values__c = 'eng-e1 / fra-fr',
            Default_Language_Country_Parameter__c = 'eng-e1',
            Default_Origin_Parameter__c = 'mylv',
            Community_URL__c = 'https://integ2-louisvuitton.cs70.force.com',
            AES_Key__c = 'iKhco6t8RnE0DaDcTzG3XQ==',
            Deactivate_User_After__c = 365,
            Activate_New_Design__c = true
        );
        String json1 = '{' +
                    '"is_draft": true,'+
                    '"is_inspiration": false,'+
                    '"layoutUrlMobile": "https://mosaic-prp.louisvuitton.com/composition/300x300/ng:M40855_PM2_Front view:300x200+0+0/ng:M70662_PM2_Front view:150x100+0+200/ng:M70659_PM2_Front view:150x100+150+200",'+
                    '"layoutUrlWeb": "https://mosaic-prp.louisvuitton.com/composition/1200x1200/ng:M40855_PM2_Front view:1200x800+0+0/ng:M70662_PM2_Front view:600x400+0+800/ng:M70659_PM2_Front view:600x400+600+800",'+
                    '"locale": "fr_FR",'+
                    '"master_sku": "M40855",'+
                    '"share_with_store": false,'+
                    '"skus": ["M40855", "M70662", "M70659"],'+
                                       '"user_identifier": "jeremym@balink.net.lv.icon",'+
            	    '"lookId": "a2B3D000000MdkdUAC",'+
                    '"name": "ciao",'+
                    '"validity_date": "2020-07-10",'+
                    '"store_codes": ["A06"],'+
            		'"countries": ["ITALY","JAPAN"],'+
                    '"zones": ["ITALY","JAPAN"]'+
				'}';
        Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(json1);
        WRDB_WS_Look.saveLook(body);
        List<Look__c> looks = [select id from look__c Limit 1];
        Look__c look = looks[0];

        Account acc = IC_TestFactory.createAccount();
	        insert acc;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		String json = '{'+
                    '"lookId": "'+ WRDB_WS_Look.getEncryptedId(look.Id) +'"'+
				'}';

		req.requestURI = '/services/apexrest/Look/Archive';
		req.requestBody = Blob.valueOf(json);
		req.httpMethod = 'POST';
		req.addHeader('Content-Type','application/json');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		WRDB_WS_Look.post();
		Test.stopTest();
	}

     @isTest static void test_getLookByclientId() {
         Store__c store1=  new Store__c(RetailStoreId__c = 'A06',StoreCountry__c = 'FRANCE',Zone__c = 'a0Oi000000SIBHUEA5');
		insert store1;
        ProductCatalogue__c prd1 = new ProductCatalogue__c(SKU__c = 'M40855');
        insert prd1;
        ProductCatalogue__c prd2 = new ProductCatalogue__c(SKU__c = 'M70662');
        insert prd2;
        ProductCatalogue__c prd3 = new ProductCatalogue__c(SKU__c = 'M70659');
        insert prd3;
         // For Test EcryptLookId
         insert new IDENTITY_Settings__c( 
            Username_Suffix__c = '@louisvuitton.com',
            //ProfileId__c = !profiles.isEmpty() ? profiles[0].Id : '',
           // Integration_User_Id__c = UserInfo.getUserId(),
           // Guest_User_Id__c = !users.isEmpty() ? users[0].Id : '',
            Language_Country_Values__c = 'eng-e1 / fra-fr',
            Default_Language_Country_Parameter__c = 'eng-e1',
            Default_Origin_Parameter__c = 'mylv',
            Community_URL__c = 'https://integ2-louisvuitton.cs70.force.com',
            AES_Key__c = 'iKhco6t8RnE0DaDcTzG3XQ==',
            Deactivate_User_After__c = 365,
            Activate_New_Design__c = true
        );

        String jsonInput = '{' +
                    '"is_draft": true,'+
                    '"is_inspiration": false,'+
                    '"layoutUrlMobile": "https://mosaic-prp.louisvuitton.com/composition/300x300/ng:M40855_PM2_Front view:300x200+0+0/ng:M70662_PM2_Front view:150x100+0+200/ng:M70659_PM2_Front view:150x100+150+200",'+
                    '"layoutUrlWeb": "https://mosaic-prp.louisvuitton.com/composition/1200x1200/ng:M40855_PM2_Front view:1200x800+0+0/ng:M70662_PM2_Front view:600x400+0+800/ng:M70659_PM2_Front view:600x400+600+800",'+
                    '"locale": "fr_FR",'+
                    '"master_sku": "M40855",'+
                    '"share_with_store": false,'+
                    '"skus": ["M40855", "M70662", "M70659"],'+
                    '"user_identifier": "jeremym@balink.net.lv.icon",'+
            	    '"lookId": "a2B3D000000MdkdUAC",'+
                    '"name": "ciao",'+
                    '"validity_date": "2020-07-10",'+
                    '"store_codes": ["A06"],'+
            		'"countries": ["ITALY","JAPAN"],'+
                    '"zones": ["ITALY","JAPAN"]'+
				'}';
        Map<String,Object> body = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
        WRDB_WS_Look.saveLook(body);
        List<Look__c> looks = [select id from look__c Limit 1];
        Look__c look = looks[0];

        Account acc = IC_TestFactory.createAccount();
	        insert acc;
        
        Look_Share__c  lookshare = new Look_Share__c(
        Client__c = acc.Id,
        Look__c = look.Id,
        Channel__c = 'LV.com',
        ExternalId__c = '234567LV.com');
         insert lookshare;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/Look/';
        req.addParameter('clientId', acc.Id);
		req.httpMethod = 'GET';
		req.addHeader('Content-Type','application/json');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		WRDB_WS_Look.get();
		Test.stopTest();
	}

    @isTest static void test_getLookBylookId() {
        Store__c store1= new Store__c(RetailStoreId__c = 'A06',StoreCountry__c = 'FRANCE',Zone__c = 'a0Oi000000SIBHUEA5');
		insert store1;
        ProductCatalogue__c prd1 = new ProductCatalogue__c(SKU__c = 'M40855');
        insert prd1;
        ProductCatalogue__c prd2 = new ProductCatalogue__c(SKU__c = 'M70662');
        insert prd2;
        ProductCatalogue__c prd3 = new ProductCatalogue__c(SKU__c = 'M70659');
        insert prd3;
        // For Test EcryptLookId
         insert new IDENTITY_Settings__c( 
            Username_Suffix__c = '@louisvuitton.com',
            //ProfileId__c = !profiles.isEmpty() ? profiles[0].Id : '',
           // Integration_User_Id__c = UserInfo.getUserId(),
           // Guest_User_Id__c = !users.isEmpty() ? users[0].Id : '',
            Language_Country_Values__c = 'eng-e1 / fra-fr',
            Default_Language_Country_Parameter__c = 'eng-e1',
            Default_Origin_Parameter__c = 'mylv',
            Community_URL__c = 'https://integ2-louisvuitton.cs70.force.com',
            AES_Key__c = 'iKhco6t8RnE0DaDcTzG3XQ==',
            Deactivate_User_After__c = 365,
            Activate_New_Design__c = true
        );
        String jsonInput = '{' +
                    '"is_draft": true,'+
                    '"is_inspiration": false,'+
                    '"layoutUrlMobile": "https://mosaic-prp.louisvuitton.com/composition/300x300/ng:M40855_PM2_Front view:300x200+0+0/ng:M70662_PM2_Front view:150x100+0+200/ng:M70659_PM2_Front view:150x100+150+200",'+
                    '"layoutUrlWeb": "https://mosaic-prp.louisvuitton.com/composition/1200x1200/ng:M40855_PM2_Front view:1200x800+0+0/ng:M70662_PM2_Front view:600x400+0+800/ng:M70659_PM2_Front view:600x400+600+800",'+
                    '"locale": "fr_FR",'+
                    '"master_sku": "M40855",'+
                    '"share_with_store": false,'+
                    '"skus": ["M40855", "M70662", "M70659"],'+
                                       '"user_identifier": "jeremym@balink.net.lv.icon",'+
            	    '"lookId": "a2B3D000000MdkdUAC",'+
                    '"name": "ciao",'+
                    '"validity_date": "2020-07-10",'+
                    '"store_codes": ["A06"],'+
            		'"countries": ["ITALY","JAPAN"],'+
                    '"zones": ["ITALY","JAPAN"]'+
				'}';
       Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
        WRDB_WS_Look.saveLook(body);
       List<Look__c> looks = [select id from look__c Limit 1];
       Look__c look = looks[0];

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/Look/';
        req.addParameter('lookId', WRDB_WS_Look.getEncryptedId(look.Id));
		req.httpMethod = 'GET';
		req.addHeader('Content-Type','application/json');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		WRDB_WS_Look.get();
		Test.stopTest();
	}

    @isTest static void test_delete() {
        Store__c store1=  new Store__c(RetailStoreId__c = 'A06',StoreCountry__c = 'FRANCE',Zone__c = 'a0Oi000000SIBHUEA5');
		insert store1;
        ProductCatalogue__c prd1 = new ProductCatalogue__c(SKU__c = 'M40855');
        insert prd1;
        ProductCatalogue__c prd2 = new ProductCatalogue__c(SKU__c = 'M70662');
        insert prd2;
        ProductCatalogue__c prd3 = new ProductCatalogue__c(SKU__c = 'M70659');
        insert prd3;
        // For Test EcryptLookId
         insert new IDENTITY_Settings__c( 
            Username_Suffix__c = '@louisvuitton.com',
            //ProfileId__c = !profiles.isEmpty() ? profiles[0].Id : '',
           // Integration_User_Id__c = UserInfo.getUserId(),
           // Guest_User_Id__c = !users.isEmpty() ? users[0].Id : '',
            Language_Country_Values__c = 'eng-e1 / fra-fr',
            Default_Language_Country_Parameter__c = 'eng-e1',
            Default_Origin_Parameter__c = 'mylv',
            Community_URL__c = 'https://integ2-louisvuitton.cs70.force.com',
            AES_Key__c = 'iKhco6t8RnE0DaDcTzG3XQ==',
            Deactivate_User_After__c = 365,
            Activate_New_Design__c = true
        );
        String jsonInput = '{' +
                    '"is_draft": true,'+
                    '"is_inspiration": false,'+
                    '"layoutUrlMobile": "https://mosaic-prp.louisvuitton.com/composition/300x300/ng:M40855_PM2_Front view:300x200+0+0/ng:M70662_PM2_Front view:150x100+0+200/ng:M70659_PM2_Front view:150x100+150+200",'+
                    '"layoutUrlWeb": "https://mosaic-prp.louisvuitton.com/composition/1200x1200/ng:M40855_PM2_Front view:1200x800+0+0/ng:M70662_PM2_Front view:600x400+0+800/ng:M70659_PM2_Front view:600x400+600+800",'+
                    '"locale": "fr_FR",'+
                    '"master_sku": "M40855",'+
                    '"share_with_store": false,'+
                    '"skus": ["M40855", "M70662", "M70659"],'+
                    '"user_identifier": "jeremym@balink.net.lv.icon",'+
            	    '"lookId": "a2B3D000000MdkdUAC",'+
                    '"name": "ciao",'+
                    '"validity_date": "2020-07-10",'+
                    '"store_codes": ["A06"],'+
            		'"countries": ["ITALY","JAPAN"],'+
                    '"zones": ["ITALY","JAPAN"]'+
				'}';
        Map<String,Object> body = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
        WRDB_WS_Look.saveLook(body);
       List<Look__c> looks = [select id from look__c Limit 1];
       Look__c look = looks[0];

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/Look/'+ WRDB_WS_Look.getEncryptedId(look.Id);
		req.httpMethod = 'DELETE';
		req.addHeader('Content-Type','application/json');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		WRDB_WS_Look.doDelete();
		Test.stopTest();
	}

      @isTest static void LookTriggerHandlerrunTest() {
        LookTriggerHandler.runOnce();
    }
	
}