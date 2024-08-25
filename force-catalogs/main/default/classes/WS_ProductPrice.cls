public class WS_ProductPrice {

	@AuraEnabled public static Map<String, Map<String, Map<String, Wrapper_ProductPrice>>> ProductsPrices {
		set;get;
	}


	public static Map<String, Map<String, Map<String, Wrapper_ProductPrice>>> getProductsCountryPrice(
			List<Store__c> stores,
			List<ProductCatalogue__c> selectedProducts,
			Store__c defaultStoreCode) {
		try {
			Map<String, ProductCatalogue__c> selectedProductsSKUs = new Map<String, ProductCatalogue__c>();
			Map<String, ProductCatalogue__c> selectedProductsIds = new Map<String, ProductCatalogue__c>();
			Map<String, Store__c> storeCodemap = new Map<String, Store__c>();
			Set<String> StoreCountryCodes = new Set<String>();
			Map<String, String> StoreCountries = new Map<String, String>();
			List<String> Skus = new List<String>();


			//system.debug('selectedProducts ' + selectedProducts);
			for (ProductCatalogue__c productCatalog : selectedProducts) {
				selectedProductsSKUs.put(productCatalog.SKU__c, productCatalog);
				selectedProductsIds.put(productCatalog.Id, productCatalog);
				Skus.add('"' + productCatalog.SKU__c + '"');
			}

			//system.debug('stores ' + stores);
            for (Store__c store : stores) {
				storeCodemap.put(store.RetailStoreId__c, store);
			}

			for (Store__c store : stores) {
				//system.debug('Store_CountryCode__c ' + store.Store_CountryCode__c);
				if (!StoreCountries.containsKey(store.Store_CountryCode__c)) {
					StoreCountries.put(store.Store_CountryCode__c, store.StoreCountry__c);
				}
				StoreCountryCodes.add('"' + store.Store_CountryCode__c + '"');
			}
			/*Catalogue_Settings__c CS = Catalogue_Settings__c.getInstance(System.Label.WSCatalogueTECHUserId);
			Http httpProtocol = new Http();
			HttpRequest httpRequest = new HttpRequest();

			//httpRequest.setEndpoint('https://lv-api-int.vuitton.biz:11930/ws/EAI_GetPricesByCountry/1.0.0/LVItemAPI/v1/webServices/priceByCountry');
			httpRequest.setEndpoint(CS.WS_Price__c);
			httpRequest.setMethod('POST');
			httpRequest.setTimeout(120000);
			httpRequest.setHeader('Encoding', 'UTF-8');
			httpRequest.setHeader('Accept', 'application/json');
			httpRequest.setHeader('Content-Type', 'application/json');
			String authorizationHeader =
					'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(CS.IntegUsername__c + ':' + CS.IntegPassword__c));
			system.debug('CS.IntegUsername__c ' + CS.IntegUsername__c);
			httpRequest.setHeader('Authorization', authorizationHeader);*/
			Http httpProtocol = new Http();
			HttpRequest httpRequest = new HttpRequest();
			//httpRequest.setEndpoint('callout:WS_Product_Price/ws/EAI_GetPricesByCountry/2.0/LVItemAPI/v2/webServices/priceByCountry');
			httpRequest.setEndpoint('callout:WS_Product_Price');
			httpRequest.setMethod('POST');
			httpRequest.setHeader('Encoding', 'UTF-8');
			httpRequest.setHeader('Accept', 'application/json');
			httpRequest.setHeader('Content-Type', 'application/json');
			String selectedSku = String.join(Skus, ',');
			date myDate = date.today();
			string todayDateString = string.valueOfGmt(myDate);
			String todayDate = todayDateString.replaceAll('-', '').substringBeforeLast(' ');

			//for (String CountryCode:StoreCountryCodes) {
			String CountryCodes = String.join(new List<String>(StoreCountryCodes), ',');
			system.debug('country code ' + CountryCodes);
			httpRequest.setBody(
							'{"LVParameters":{"countryCodeList":[' + CountryCodes + '],"itemList":[' + selectedSku +
							'],"effectiveDate":"' +
							todayDate + '","tariffTypeList":["R"]}}');

			system.debug('selectedSku ' + selectedSku);
			HttpResponse httpResponse = null;
			httpResponse = httpProtocol.send(httpRequest);
			//System.debug('httpResponse ' + httpResponse);
			system.debug(httpResponse.getBody());


			getProductPrice(httpResponse.getBody(), CountryCodes, StoreCountries);
			//}
			system.debug('my map ' + ProductsPrices);

			return ProductsPrices;
		} catch (Exception e) {
			Ctrl_ProductCatalog.log('WS_getProductsCountryPrice', e);
			ProductsPrices = new Map<String, Map<String, Map<String, Wrapper_ProductPrice>>>();
			return ProductsPrices;
		}

	}

	public static void getProductPrice(String jsonPrice, String CountryCode, Map<String,String> MapStoreCountries) {

		Map<String, Map<String, Map<String, Wrapper_ProductPrice>>> countryProductPrice =
				new Map<String, Map<String, Map<String, Wrapper_ProductPrice>>>();
		String newJson = jsonPrice.replace('"currency":', '"currencyCode":');
		system.debug('productPriceBeforeParse ' + newJson);
		ProductPriceJsonToApex productPriceParse = ProductPriceJsonToApex.parse(newJson);

		system.debug('productPriceParse ' + productPriceParse);


		/*if (productPriceParse.LVResponse != null) {
			if (productPriceParse.LVResponse.data != null) {
				if (productPriceParse.LVResponse.data.itemPrices != null) {
					system.debug('yyy ' + productPriceParse.LVResponse.data.itemPrices);
					for (ProductPriceJsonToApex.ItemPrices itemPrice:productPriceParse.LVResponse.data.itemPrices) {
						if (ProductsPrices == null) {
							ProductsPrices = new Map<String, Map<String, Wrapper_ProductPrice>>();
						}

						if(!ProductsPrices.containsKey(itemPrice.item)){
							ProductsPrices.put(itemPrice.item, new Map<String,Wrapper_ProductPrice>());
						}
						countryProductPrice = ProductsPrices.get(itemPrice.item);
						Wrapper_ProductPrice itemProductPrice = new Wrapper_ProductPrice();
						itemProductPrice.price = decimal.valueOf(itemPrice.price);
						itemProductPrice.currencyCoin = itemPrice.currency_price;
						itemProductPrice.Country = StoreCountry;
						itemProductPrice.CountryCode = CountryCode;
						countryProductPrice.put(CountryCode, itemProductPrice);
						productsPrices.put(itemPrice.item,countryProductPrice);

					}
				}
			}
		}*/
		if (productPriceParse.LVResponse != null) {
			if (productPriceParse.LVResponse.data != null) {
				if (productPriceParse.LVResponse.data.itemPrices != null) {
					system.debug('yyy ' + productPriceParse.LVResponse.data.itemPrices);
					for (ProductPriceJsonToApex.ItemPrices itemPrice:productPriceParse.LVResponse.data.itemPrices) {
						if (ProductsPrices == null) {
							ProductsPrices = new Map<String, Map<String, Map<String, Wrapper_ProductPrice>>>();
						}

						system.debug('countryCode '+itemPrice.countryCode);
						String myCountryCode = itemPrice.countryCode;
						for(ProductPriceJsonToApex.ItemList item:itemPrice.itemList) {
							system.debug('item' + item.currencyCode);
							if(!ProductsPrices.containsKey(item.item)){
								ProductsPrices.put(item.item, new Map<String,Map<String, Wrapper_ProductPrice>>());
							}
							Map<String, Map<String, Wrapper_ProductPrice>> itemsMap =  ProductsPrices.get(item.item);
							if(!itemsMap.containsKey(myCountryCode)){
								itemsMap.put(myCountryCode, new Map<String, Wrapper_ProductPrice>());
							}
							Map<String, Wrapper_ProductPrice> countryCodeMap = itemsMap.get(myCountryCode);
							/*if(!countryCodeMap.containsKey(item.tariffType)){
								countryCodeMap.put(item.tariffType, )
							}*/
							Wrapper_ProductPrice itemProductPrice = new Wrapper_ProductPrice();
							itemProductPrice.price = decimal.valueOf(item.price);
							itemProductPrice.currencyCoin = item.currencyCode;
							itemProductPrice.Country = MapStoreCountries.get(myCountryCode);
							system.debug(itemProductPrice.Country);
							itemProductPrice.CountryCode = myCountryCode;
							
							countryCodeMap.put(item.tariffType, itemProductPrice);
							itemsMap.put(myCountryCode,countryCodeMap );
							ProductsPrices.put(item.item, itemsMap);

						}




						/*if(!ProductsPrices[itemPrice.item].containsKey(itemPrice.tariffType)){

						}*/
						/*countryProductPrice = ProductsPrices.get(itemPrice.item);
						Wrapper_ProductPrice itemProductPrice = new Wrapper_ProductPrice();
						itemProductPrice.price = decimal.valueOf(itemPrice.price);
						itemProductPrice.currencyCoin = itemPrice.currencyCode;
						itemProductPrice.tarifType = itemPrice.tariffType;
						itemProductPrice.Country = StoreCountry;
						itemProductPrice.CountryCode = CountryCode;
						countryProductPrice.put(CountryCode, itemProductPrice);
						productsPrices.put(itemPrice.item,countryProductPrice);*/


					}
				}
			}

		}
	}
}