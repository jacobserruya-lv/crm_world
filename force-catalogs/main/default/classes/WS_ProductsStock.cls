public with sharing class WS_ProductsStock {
	public class CatalogueRequestException extends Exception {}


	@AuraEnabled public static Map<String, List<Wrapper_ProductStoreAvailability>> newProductAvailabilitiesMap {
		set;get;
	}

	public static Map<String, List<Wrapper_ProductStoreAvailability>> getProductsStoreAvailabilities(List<Store__c> stores, List<ProductCatalogue__c> selectedProducts, Store__c defaultStore) {
		try {
            system.debug('try this' + selectedProducts);
			Map<String, ProductCatalogue__c> selectedProductsSKUs = new Map<String, ProductCatalogue__c>();
			Map<String, ProductCatalogue__c> selectedProductsIds = new Map<String, ProductCatalogue__c>();
			Map<String, Store__c> storeCodemap = new Map<String, Store__c>();
			List<String> Skus = new List<String>();
			List<String> StoresCode = new List<String>();

			system.debug('default store ' + defaultStore);

			system.debug('selectedProducts ' + selectedProducts);
			for (ProductCatalogue__c productCatalog : selectedProducts) {
				selectedProductsSKUs.put(productCatalog.SKU__c, productCatalog);
				selectedProductsIds.put(productCatalog.Id, productCatalog);
				Skus.add('"' + productCatalog.SKU__c + '"');
			}
			system.debug('selectedProductsSKUs ' + selectedProductsSKUs);

			for (Store__c store : stores) {
				storeCodemap.put(store.RetailStoreId__c, store);
				StoresCode.add('"' + store.RetailStoreId__c + '"');
			}

			system.debug('storeCodemap ' + storeCodemap);
			//Custom setting that hold parameters for the request
			// Catalogue_Settings__c CS = Catalogue_Settings__c.getInstance(System.Label.WSCatalogueTECHUserId);

			// String authorizationHeader = 'Basic ' +
			// 		EncodingUtil.base64Encode(Blob.valueOf(CS.Username_WS_Stock__c + ':' + CS.Password_WS_Stock__c));
			// System.debug('Auth ' + authorizationHeader);

			Http httpProtocol = new Http();
			HttpRequest httpRequest = new HttpRequest();
			//httpRequest.setEndpoint('https://lv-api-prp.vuitton.biz:11930/ws/EAI_ItemMultilocationStock/2.0/LVItemMultilocationStockAPI/v2/webServices/ItemMultilocationStock');
			/*httpRequest.setEndpoint(CS.CatalogueWSURL__c);*/
			
			
			// URL PROD
			// httpRequest.setEndpoint('https://lv-api-prp.vuitton.biz:11930/ws/EAI_ItemMultilocationStock/2.0/LVItemMultilocationStockAPI/v2/webServices/ItemMultilocationStock');


			
		
			String endpoint =  '/spl-eu/str-prd-lvl-eai/v1/LVItemMultilocationStockAPI/v2/webServices/ItemMultilocationStock';
			httpRequest.setEndpoint('callout:MULESOFT_Catalog'+ endpoint);
			
				
            httpRequest.setMethod('POST');
            httpRequest.setTimeout(120000);
            httpRequest.setHeader('Encoding', 'UTF-8');
            httpRequest.setHeader('Accept', 'application/json');
            httpRequest.setHeader('Content-Type', 'application/json');
			httpRequest.setHeader('client_id', '{!$Credential.UserName}');
            httpRequest.setHeader('client_secret', '{!$Credential.Password}');
			
			String selectedSku = String.join(Skus, ',');
			String selectedStores = String.join(StoresCode, ',');
			system.debug('selectedStores' + selectedStores);
			system.debug('selectedSku ' + selectedSku);
			system.debug('sending: {"LVParameters" :  {"storeList" : [' + selectedStores + '] ,"itemList" : [' + selectedSku
					+ ']}}');
			httpRequest.setBody('{"LVParameters" :  {"storeList" : [' + selectedStores + '] ,"itemList" : [' + selectedSku +
					']}}');
			//httpRequest.setBody('{"LVParameters" :  {"storeList" : ['+selectedStores+'] }}');
			HttpResponse httpResponse = null;
			system.debug('sending stock start ' + DateTime.now());
			httpResponse = httpProtocol.send(httpRequest);


			system.debug('sending stock end ' + DateTime.now());
			system.debug('getProductsStoreAvailabilities REQUEST BODY : ' + httpResponse.getBody());
			system.debug('getProductsStoreAvailabilities REQUEST STATUS : ' + httpResponse.getStatusCode());
			if((httpResponse.getStatusCode() / 100) != 2){
                throw new CatalogueRequestException('Request return status code: '+ httpResponse.getStatusCode());
    
            }
			newProductAvailabilitiesMap = new Map<String, List<Wrapper_ProductStoreAvailability>>();
			newProductAvailabilitiesMap =
					getProductStock(httpResponse.getBody(), storeCodemap, selectedProductsSKUs, defaultStore);

			system.debug('newProductAvailabilitiesMap ' + newProductAvailabilitiesMap);
			system.debug('sending stock maping end at ' + DateTime.now());
			System.debug('Response API' + httpResponse.getBody());
			if(httpResponse.getBody() == ''){
				System.debug('getProductsStoreAvailabilities httpResponse.getBody() in if ' + httpResponse.getBody());
			}


			return newProductAvailabilitiesMap;

		} catch (Exception e) {
			Ctrl_ProductCatalog.log('WS_ProductsStock', e);
			newProductAvailabilitiesMap = new Map<String, List<Wrapper_ProductStoreAvailability>>();
			newProductAvailabilitiesMap.put('ERROR', new List<Wrapper_ProductStoreAvailability>());
			Wrapper_ProductStoreAvailability mockAvailability = new Wrapper_ProductStoreAvailability();
			mockAvailability.errorCode = 'Error Parsing';
			newProductAvailabilitiesMap.get('ERROR').add(mockAvailability);
			//return Wrapper_ProductStoreAvailability.fillDataToProductStoreAvailabilitiesWrappers(
					//newProductAvailabilitiesMap, storeCodemap, defaultStore);

			return newProductAvailabilitiesMap;

		} /*finally {
			return newProductAvailabilitiesMap;
		}*/
	}

	public static  Map<String, List<Wrapper_ProductStoreAvailability>>  getProductStock(String jsonStock, Map<String, Store__c> storeCodemap, Map<String, ProductCatalogue__c> selectedProductsSKUs, Store__c defaultStore) {

		//Map<String, List<Wrapper_ProductStoreAvailability>> newProductAvailabilitiesMap = new Map<String, List<Wrapper_ProductStoreAvailability>>();
		system.debug('jsonStock ' +jsonStock);
		ProductStockJsonToApex productStockParse = ProductStockJsonToApex.parse(jsonStock);

		Store__c currentStore;
		Boolean stockFlag = false;

		if (productStockParse.LVResponse != null) {
			if (productStockParse.LVResponse.data != null) {
				if (productStockParse.LVResponse.data.storeList != null) {
					system.debug('yyy ' + productStockParse.LVResponse.data.storeList);
					for (ProductStockJsonToApex.storeList store:productStockParse.LVResponse.data.storeList) {
						system.debug('store Code ' + store.storeCode);
						system.debug('codeMap ' + storeCodemap);
						currentStore = storeCodemap.get(store.storeCode);
						for (ProductStockJsonToApex.itemList item: store.itemList) {
							system.debug('item ' + item);
							String itemCode = item.itemCode.trim();
							if(!newProductAvailabilitiesMap.containsKey(itemCode)) {
								newProductAvailabilitiesMap.put(itemCode, new List<Wrapper_ProductStoreAvailability>());
							}
							Wrapper_ProductStoreAvailability productStock = new Wrapper_ProductStoreAvailability();
							productStock.storeId = currentStore.Id;
							productStock.storeData = currentStore;
							productStock.haveAvailabilities = true;
							//productStock.productCatalogId = selectedProductsSKUs.get(item.itemCode).Id;

							if(item.BucketList != null){
								stockFlag=false;
								for(ProductStockJsonToApex.BucketList itemData: item.BucketList){

									if(itemData.BucketId == 'ON_HAND'){
										system.debug('sum ' + itemData.totalQuantity);
										productStock.inStock = Math.round(Decimal.valueOf((String) itemData.totalQuantity));
										productStock.inStock = productStock.inStock < 0? 0: productStock.inStock;
										system.debug('productStock ' + productStock.inStock);
										stockFlag = true;
										break;
									}
									/*else if(itemData.BucketId == 'TRL'){
										productStock.inTransit = Math.round(Decimal.valueOf((String) itemData.totalQuantity));
									}*/
									else if((itemData.BucketId == 'SOLD_ONL' || itemData.BucketId == 'SOLD_BO') &&  itemData.totalQuantity != null){
										productStock.inStock = 0;
										//productStock.inTransit = 0;
										if(Decimal.valueOf((String) itemData.totalQuantity) == 1) {
											productStock.online = true;
											productStock.csc = true;
											stockFlag = true;
										}
										break;
									}
									else if((itemData.BucketId == 'CSC_ONL' || itemData.BucketId == 'CSC_BO') &&  itemData.totalQuantity != null){
										productStock.inStock = 0;
										//productStock.inTransit = 0;
										if(Decimal.valueOf((String) itemData.totalQuantity) == 1) {
											productStock.csc = true;
											stockFlag = true;
										}
										break;
									}
								}
								if(!stockFlag) {
									productStock.inStock = 0;
								}
								system.debug('productStock ' + productStock);
								newProductAvailabilitiesMap.get(itemCode).add(productStock);
							}
						}
					}
				}
			}else{
				//getting error response from ws
				System.debug('There is no data for one of this stores ');
				return null;
			}
		}else{
			//not getting an answer we expected
			return null;
		}
		//add empty availabilities
		List<Wrapper_ProductStoreAvailability> newProductAvailabilitiesListTest = new List<Wrapper_ProductStoreAvailability>();
		for(String productSku : selectedProductsSKUs.keySet()) {
			List<Wrapper_ProductStoreAvailability> productAvailabilities = newProductAvailabilitiesMap.get(productSku);
			if(productAvailabilities == null || productAvailabilities.size() != storeCodemap.size() ) {
				if(productAvailabilities == null) {
					newProductAvailabilitiesMap.put(productSku, new List<Wrapper_ProductStoreAvailability>());
				}
				Map<String, Boolean> isStoreExists = new Map<String, Boolean>();
				for(String storeCodeVal : storeCodemap.keySet()) {
					isStoreExists.put(storeCodeVal, false);
				}
				if(productAvailabilities != null) {
					for(Wrapper_ProductStoreAvailability availability : productAvailabilities) {
						isStoreExists.put(availability.storeData.RetailStoreId__c, true);
					}
				}
				for(String storeCodeVal : isStoreExists.keySet()) {
					if(!isStoreExists.get(storeCodeVal)) {
						currentStore = storeCodemap.get(storeCodeVal);

						Wrapper_ProductStoreAvailability mockAvailability = new Wrapper_ProductStoreAvailability();

						mockAvailability.storeId = currentStore.Id;
						mockAvailability.storeData = currentStore;
						//mockAvailability.productCatalogId = selectedProductsSKUs.get(productSku).Id;
						mockAvailability.inStock = 0;
						//mockAvailability.inTransit = 0;
						mockAvailability.price = -1;
						mockAvailability.haveAvailabilities = false;
						mockAvailability.csc = false;
						mockAvailability.online = false;

						newProductAvailabilitiesMap.get(productSku).add(mockAvailability);
						newProductAvailabilitiesListTest.add(mockAvailability);
					}
				}
			}
		}
		system.debug('newProductAvailabilitiesMap ' + newProductAvailabilitiesMap);



		return Wrapper_ProductStoreAvailability.fillDataToProductStoreAvailabilitiesWrappers(newProductAvailabilitiesMap, storeCodemap, defaultStore);
		//return newProductAvailabilitiesMap;
	}


}


// 12:37:10:632 USER_DEBUG [59]|DEBUG|newProductAvailabilitiesMap {M41414=(Wrapper_ProductStoreAvailability:[csc=false, currencyCoin=null, errorCode=null, googleMapLink=https://maps.google.com/?q=6, place Saint-Germain des Pres75006 PARIS,FRANCE, haveAvailabilities=true, haveInTransit=true, id=null, inStock=null, inTransit=1, isDefault=false, isDigital=false, isNearby=true, locationLatitude=48.853977, locationLongitude=2.33304, online=false, price=null, productCatalogId=null, store=Wrapper_ProductCatalogStore:[address=6, place Saint-Germain des Pres75006 PARIS, commercialName=LOUIS VUITTON PARIS ST GERMAIN DES PRES, country=FRANCE, countryCode=FR, currencyCoin=EUR, id=a0Ni000001E3REQEA3, isDefault=false, isDigital=false, latitude=48.853977, location=null, longitude=2.33304, name=LV PARIS ST GERMAIN DES PRES, openingHours=OpeningHours:[Friday=10:30 - 19:30, Monday=10:30 - 19:30, Saturday=10:30 - 19:30, Sunday=11:00 - 19:00, Thursday=10:30 - 19:30, Tuesday=10:30 - 19:30, Wednesday=10:30 - 19:30], retailStoreId=A03, status=Open], storeData=null, storeId=a0Ni000001E3REQEA3, storeName=LV PARIS ST GERMAIN DES PRES], Wrapper_ProductStoreAvailability:[csc=false, currencyCoin=null, errorCode=null, googleMapLink=https://maps.google.com/?q=40, boulevard Haussmann75009 PARIS,FRANCE, haveAvailabilities=true, haveInTransit=true, id=null, inStock=9, inTransit=null, isDefault=false, isDigital=false, isNearby=true, locationLatitude=48.87, locationLongitude=2.33, online=false, price=null, productCatalogId=null, store=Wrapper_ProductCatalogStore:[address=40, boulevard Haussmann75009 PARIS, commercialName=LOUIS VUITTON PARIS GALERIES LAFAYETTE, country=FRANCE, countryCode=FR, currencyCoin=EUR, id=a0Ni000001E3RETEA3, isDefault=false, isDigital=false, latitude=48.87, location=null, longitude=2.33, name=LV PARIS GALERIES LAFAYETTE, openingHours=OpeningHours:[Friday=9:30 - 20:30, Monday=9:30 - 20:30, Saturday=9:30 - 20:30, Sunday=11:00 - 19:00, Thursday=9:30 - 20:30, Tuesday=9:30 - 20:30, Wednesday=9:30 - 20:30], retailStoreId=A07, status=Open], storeData=null, storeId=a0Ni000001E3RETEA3, storeName=LV PARIS GALERIES LAFAYETTE], Wrapper_ProductStoreAvailability:[csc=false, currencyCoin=null, errorCode=null, googleMapLink=https://maps.google.com/?q=23, Place Vendôme75001 PARIS,FRANCE, haveAvailabilities=true, haveInTransit=true, id=null, inStock=37, inTransit=7, isDefault=false, isDigital=false, isNearby=false, locationLatitude=48.8677, locationLongitude=2.3297102, online=false, price=null, productCatalogId=null, store=Wrapper_ProductCatalogStore:[address=23, Place Vendôme75001 PARIS, commercialName=LOUIS VUITTON PARIS VENDOME, country=FRANCE, countryCode=FR, currencyCoin=EUR, id=a0Ni000001E3RFWEA3, isDefault=false, isDigital=false, latitude=48.8677, location=null, longitude=2.3297102, name=LV PARIS VENDOME, openingHours=OpeningHours:[Friday=11:00 - 18:30, Monday=11:00 - 18:30, Saturday=11:00 - 18:30, Sunday=, Thursday=11:00 - 18:30, Tuesday=11:00 - 18:30, Wednesday=11:00 - 18:30], retailStoreId=A11, status=Open], storeData=null, storeId=a0Ni000001E3RFWEA3, storeName=LV PARIS VENDOME], (already output), (already output), Wrapper_ProductStoreAvailability:[csc=false, currencyCoin=null, errorCode=null, googleMapLink=null, haveAvailabilities=true, haveInTransit=true, id=null, inStock=0, inTransit=0, isDefault=true, isDigital=true, isNearby=false, locationLatitude=null, locationLongitude=null, online=false, price=null, productCatalogId=null, store=Wrapper_ProductCatalogStore:[address=null, commercialName=null, country=AUSTRIA, countryCode=AT, currencyCoin=EUR, id=a0N0x000000oUTrEAM, isDefault=true, isDigital=true, latitude=null, location=null, longitude=null, name=CS Austria, openingHours=null, retailStoreId=G90, status=Open], storeData=null, storeId=a0N0x000000oUTrEAM, storeName=CS Austria], Wrapper_ProductStoreAvailability:[csc=false, currencyCoin=null, errorCode=null, googleMapLink=https://maps.google.com/?q=101 avenue des Champs-Elysées75008 PARIS,FRANCE, haveAvailabilities=false, haveInTransit=true, id=null, inStock=0, inTransit=0, isDefault=false, isDigital=false, isNearby=false, locationLatitude=48.870903, locationLongitude=2.3002145, online=false, price=-1.0, productCatalogId=a170H000009sroWQAQ, store=Wrapper_ProductCatalogStore:[address=101 avenue des Champs-Elysées75008 PARIS, commercialName=LOUIS VUITTON PARIS CHAMPS ELYSEES, country=FRANCE, countryCode=FR, currencyCoin=EUR, id=a0Ni000001E3RESEA3, isDefault=false, isDigital=false, latitude=48.870903, location=null, longitude=2.3002145, name=LV CHAMPS ELYSEES1, openingHours=OpeningHours:[Friday=10:00 - 20:00, Monday=10:00 - 20:00, Saturday=10:00 - 20:00, Sunday=11:00 - 19:00, Thursday=10:00 - 20:00, Tuesday=10:00 - 20:00, Wednesday=10:00 - 20:00], retailStoreId=A06, status=Open], storeData=null, storeId=a0Ni000001E3RESEA3, storeName=LV CHAMPS ELYSEES1], Wrapper_ProductStoreAvailability:[csc=false, currencyCoin=null, errorCode=null, googleMapLink=https://maps.google.com/?q=2, Place Vendôme75001 PARIS,FRANCE, haveAvailabilities=false, haveInTransit=true, id=null, inStock=0, inTransit=0, isDefault=false, isDigital=false, isNearby=true, locationLatitude=48.86655, locationLongitude=2.328927, online=false, price=-1.0, productCatalogId=a170H000009sroWQAQ, store=Wrapper_ProductCatalogStore:[address=2, Place Vendôme75001 PARIS, commercialName=null, country=FRANCE, countryCode=FR, currencyCoin=EUR, id=a0Ni000002Ri6cLEAR, isDefault=false, isDigital=false, latitude=48.86655, location=null, longitude=2.328927, name=LV PARIS MAISON VENDOME, openingHours=null, retailStoreId=A14, status=Open], storeData=null, storeId=a0Ni000002Ri6cLEAR, storeName=LV PARIS MAISON VENDOME], Wrapper_ProductStoreAvailability:[csc=false, currencyCoin=null, errorCode=null, googleMapLink=https://maps.google.com/?q=22 avenue Montaigne 75008 PARIS,FRANCE, haveAvailabilities=false, haveInTransit=true, id=null, inStock=0, inTransit=0, isDefault=false, isDigital=false, isNearby=true, locationLatitude=48.8661, locationLongitude=2.3055038, online=false, price=-1.0, productCatalogId=a170H000009sroWQAQ, store=Wrapper_ProductCatalogStore:[address=22 avenue Montaigne 75008 PARIS, commercialName=LOUIS VUITTON PARIS MONTAIGNE, country=FRANCE, countryCode=FR, currencyCoin=EUR, id=a0Ni000001E3REPEA3, isDefault=false, isDigital=false, latitude=48.8661, location=null, longitude=2.3055038, name=LV PARIS MONTAIGNE, openingHours=OpeningHours:[Friday=10:00 - 19:30, Monday=10:00 - 19:30, Saturday=10:00 - 19:30, Sunday=12:00 - 19:00, Thursday=10:00 - 19:30, Tuesday=10:00 - 19:30, Wednesday=10:00 - 19:30], retailStoreId=A02, status=Open], storeData=null, storeId=a0Ni000001E3REPEA3, storeName=LV PARIS MONTAIGNE], Wrapper_ProductStoreAvailability:[csc=false, currencyCoin=null, errorCode=null, googleMapLink=https://maps.google.com/?q=24, rue de Sevres75007 PARIS,FRANCE, haveAvailabilities=false, haveInTransit=true, id=null, inStock=0, inTransit=0, isDefault=false, isDigital=false, isNearby=true, locationLatitude=48.85, locationLongitude=2.32, online=false, price=-1.0, productCatalogId=a170H000009sroWQAQ, store=Wrapper_ProductCatalogStore:[address=24, rue de Sevres75007 PARIS, commercialName=LOUIS VUITTON PARIS LE BON MARCHE, country=FRANCE, countryCode=FR, currencyCoin=EUR, id=a0Ni000001E3REREA3, isDefault=false, isDigital=false, latitude=48.85, location=null, longitude=2.32, name=LV PARIS LE BON MARCHE, openingHours=OpeningHours:[Friday=10:00 - 20:00, Monday=10:00 - 20:00, Saturday=10:00 - 20:00, Sunday=11:00 - 20:00, Thursday=10:00 - 21:00, Tuesday=10:00 - 20:00, Wednesday=10:00 - 20:00], retailStoreId=A05, status=Open], storeData=null, storeId=a0Ni000001E3REREA3, storeName=LV PARIS LE BON MARCHE], ...)}