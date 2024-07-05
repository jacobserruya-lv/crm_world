//Created by: Balink2017
//Description: call RMS WS for product Availabilities

public class WS_ProductStockAvailability {

	//Call WS & parse response
    public static Map<String, List<Wrapper_ProductStoreAvailability>> getProductsStoreAvailabilities(List<Store__c> stores, List<ProductCatalogue__c> selectedProducts, Store__c defaultStore) {
       try {
    		Map<String, ProductCatalogue__c> selectedProductsSKUs = new Map<String, ProductCatalogue__c>();
    		Map<String, ProductCatalogue__c> selectedProductsIds = new Map<String, ProductCatalogue__c>();
    		Map<String, Store__c> storeCodemap = new Map<String, Store__c>();

           system.debug('selectedProducts '+ selectedProducts);
	        for(ProductCatalogue__c productCatalog : selectedProducts) {
	            selectedProductsSKUs.put(productCatalog.SKU__c, productCatalog);
	            selectedProductsIds.put(productCatalog.Id, productCatalog);
	        }

	        for(Store__c store : stores) {
	        	storeCodemap.put(store.RetailStoreId__c, store);
	        }

			//Custom setting that hold parameters for the request
    		Catalogue_Settings__c CS = Catalogue_Settings__c.getInstance(System.Label.WSCatalogueTECHUserId);

            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(CS.Username_WS_Stock__c+':'+CS.Password_WS_Stock__c));
           	System.debug('Auth ' + authorizationHeader);

            //get the stores data from external WS
    		Http httpProtocol = new Http();
			HttpRequest httpRequest = new HttpRequest();
	        httpRequest.setEndpoint(CS.CatalogueWSURL__c);
	        httpRequest.setMethod('GET');
			httpRequest.setTimeout(120000);
			httpRequest.setHeader('Encoding','UTF-8');
			httpRequest.setHeader('Content-Type','text/xml; charset=utf-8');
			httpRequest.setHeader('Authorization', authorizationHeader);
            for(Integer i=0; i<CS.OptionalHeadersNum__c; i++){
                httpRequest.setHeader('Header'+string.valueOf(i)+'__c', (string)CS.get('Header'+string.valueOf(i)+'__c'));
            }
            //httpRequest.setHeader('SOAPAction', 'WSLV021_webService_v2_0_getPriceAndStocks_Binder_wslv021_main_service'); // for WS V2
			System.debug('NUM OF STORES: ' + stores.size() + ', NUM OF PRODUCTS: ' + selectedProductsSKUs.keySet().size());
			System.debug('HTTP REQUEST: ' + getRequestBody(stores, selectedProductsSKUs.keySet(),CS));
            httpRequest.setBody(getRequestBody(stores, selectedProductsSKUs.keySet(),CS));
			HttpResponse httpResponse = null;

           System.debug('start time ' + DateTime.now());
           httpResponse = httpProtocol.send(httpRequest);
           System.debug('end time ' + DateTime.now());

            Dom.Document doc = httpResponse.getBodyDocument();
			System.debug('httpResponse doc ' + doc.toXmlString());
			Dom.XMLNode address = doc.getRootElement();

			Map<String, List<Wrapper_ProductStoreAvailability>> newProductAvailabilitiesMap = new Map<String, List<Wrapper_ProductStoreAvailability>>();
			List<Wrapper_ProductStoreAvailability> newProductAvailabilitiesList = new List<Wrapper_ProductStoreAvailability>();
			Map<string, Object> myMap = GenericXMLParser.ParseXML(doc.toXmlString(), new Set<String>{'DataResponse', 'Items', 'Entities', 'Stocks'});

			Map<string, Object> responseMap = (myMap != null) ? GenericXMLParser.getNode(myMap, new List<String>{'Envelope', 'Body', 'wslv021_main_serviceResponse', 'getPricesAndStocksResponse', 'getPricesAndStocksResponse'}) : null;
			List<Map<String, Object>> dataResponseMap = (responseMap != null) ? (List<Map<String, Object>>) responseMap.get('DataResponse') : null;

           system.debug('dataResponseMap ' + dataResponseMap);
			if(dataResponseMap != null) {
				for(Map<String, Object> productData : dataResponseMap) {
					List<Object> dataItems = (List<Object>) productData.get('Items');

					String productCode = '', storeCode = '';
					Decimal price = -1;
					String productCurrency = '';
					Store__c currentStore;


                    for(Object dataItem : dataItems) {
                        Map<String, Object> tempObj = (Map<String, Object>) dataItem;
                        if(tempObj.get('code') != null) {
                          String tempCode = (String) tempObj.get('code');
                          productCode = tempCode.indexOf(' ') > 0 ? tempCode.substring(0, tempCode.length() - 1) : tempCode;
                        }

                        if (productCode != '' && selectedProductsSKUs.containsKey(productCode)) {
                            if(newProductAvailabilitiesMap.get(productCode) == null) {
                                newProductAvailabilitiesMap.put(productCode, new List<Wrapper_ProductStoreAvailability>());
                            }

                            if(tempObj.get('Entities') != null) {
                                List<Object> dataEntities = (List<Object>) tempObj.get('Entities');

                                Wrapper_ProductStoreAvailability productAvailability = new Wrapper_ProductStoreAvailability();
                                for(Object dataEntitie : dataEntities) {

                                    Map<String, Object> tempEntitie = (Map<String, Object>) dataEntitie;

									if (tempEntitie.get('code') != '' && tempEntitie.get('code') != null) {
										storeCode = (String) tempEntitie.get('code');

										currentStore = storeCodemap.get(storeCode);
                                        if(currentStore != null) {
											productAvailability.storeId = currentStore.Id;
											productAvailability.storeData = currentStore;
											productAvailability.productCatalogId =
													selectedProductsSKUs.get(productCode).Id;
										}
									}

                                    if (tempEntitie.get('ItemPrice') != '' && tempEntitie.get('ItemPrice') != null) {
                                        Map<String, Object> dataPrice = (Map<String, Object>) tempEntitie.get('ItemPrice');
                                        //productAvailability.price = Math.round(Decimal.valueOf((String) dataPrice.get('price')));
                                        //productAvailability.currencyCoin = (String) dataPrice.get('currency');
                                    }

                                    if(tempEntitie.get('Stocks') != null) {
                                      List<Object> StockItems = (List<Object>) tempEntitie.get('Stocks');


                                        Map<String, Object> firstStockItem = (Map<String, Object>) StockItems[0];
                                        Map<String, Object> secondStockItem = (Map<String, Object>) StockItems[1];
                                        if(firstStockItem.get('typeS') == 'AVAILABLE' && secondStockItem.get('quantity') != null) {
                                            productAvailability.inStock = Math.round(Decimal.valueOf((String) secondStockItem.get('quantity')));
                                        }
                                        else if(firstStockItem.get('typeS') == 'TRANSIT' && secondStockItem.get('quantity') != null) {
                                            productAvailability.inTransit = Math.round(Decimal.valueOf((String) secondStockItem.get('quantity')));
                                        }
                                        else if((firstStockItem.get('typeS') == 'SOLD_ONL' || firstStockItem.get('typeS') == 'SOLD_BO' ) && secondStockItem.get('quantity') != null)  {
                                            productAvailability.inStock = 0;
                                            productAvailability.inTransit = 0;
                                            if(Decimal.valueOf((String) secondStockItem.get('quantity'))  == 1) {
                                                productAvailability.online = true;
                                                productAvailability.csc = true;
                                            }
                                        }

                                        else if((firstStockItem.get('typeS') == 'CSC_ONL' || firstStockItem.get('typeS') == 'CSC_BO') && secondStockItem.get('quantity') != null)  {
                                            productAvailability.inStock = 0;
                                            productAvailability.inTransit = 0;
                                            if(Decimal.valueOf((String) secondStockItem.get('quantity'))  == 1) {
                                                 productAvailability.csc = true;
                                            }
                                        }
                                    }
                                }

                                productAvailability.haveAvailabilities = true;
                                //System.debug('avail '+ productAvailability);
								if(currentStore != null) {
									newProductAvailabilitiesMap.get(productCode).add(productAvailability);
									newProductAvailabilitiesList.add(productAvailability);
								}
                            }
                        }
					}
                }
			}

           if (newProductAvailabilitiesList.isEmpty()){
                System.debug ('no response');
                Map<string, Object> myErrorMap = GenericXMLParser.ParseXML(doc.toXmlString(), new Set<String>{'LvmHeaderResponse'});
                Map<string, Object> responseErrorMap = (myErrorMap != null) ? GenericXMLParser.getNode(myErrorMap, new List<String>{'Envelope', 'Body', 'wslv021_main_serviceResponse', 'getPricesAndStocksResponse', 'getPricesAndStocksResponse'}) : null;
               	system.debug('responseErrorMap ' + responseErrorMap);
                if (responseErrorMap != null ){
                    List<Object> myErrorData = (List<Object>) responseErrorMap.get('LvmHeaderResponse');
                    //system.debug('error Code '  + responseErrorMap);

                   for(Object errorData : myErrorData) {
                       Map<String, Object> error = (Map<String, Object>) errorData;
                       if (error.get('errorCode') != null) {
                           if((String) error.get('errorCode') == '021' || (String) error.get('errorCode') == '030' || (String) error.get('errorCode') == '031'){
                               newProductAvailabilitiesMap.put('ERROR', new List<Wrapper_ProductStoreAvailability>());
                               Wrapper_ProductStoreAvailability mockAvailability = new Wrapper_ProductStoreAvailability();
                               mockAvailability.errorCode = (String) error.get('errorCode');
                               newProductAvailabilitiesMap.get('ERROR').add(mockAvailability);
                               return Wrapper_ProductStoreAvailability.fillDataToProductStoreAvailabilitiesWrappers(newProductAvailabilitiesMap, storeCodemap, defaultStore);
                           }
                       }
                   }
                }
               else {
               	return null;
               }
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
                           Store__c currentStore = storeCodemap.get(storeCodeVal);
                           
                           Wrapper_ProductStoreAvailability mockAvailability = new Wrapper_ProductStoreAvailability();
                           
                           mockAvailability.storeId = currentStore.Id;
                           mockAvailability.storeData = currentStore;
                           mockAvailability.productCatalogId = selectedProductsSKUs.get(productSku).Id;
                           mockAvailability.inStock = 0;
                           mockAvailability.inTransit = 0;
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
           return Wrapper_ProductStoreAvailability.fillDataToProductStoreAvailabilitiesWrappers(newProductAvailabilitiesMap, storeCodemap, defaultStore);


		} catch(Exception e) { Ctrl_ProductCatalog.log('WS_getProductStoreAvailabilities', e); return null; }
	}

	//prepare request body
    public static String getRequestBody(List<Store__c> stores, Set<String> itemCodes, Catalogue_Settings__c CS) {
        		String soapRequest = '<soapenv:Envelope xmlns:soapenv=\'http://schemas.xmlsoap.org/soap/envelope/\' xmlns:wsl=\''+CS.WSL__c+'\'>\n' +
					'<soapenv:Header/>\n' +
		   			'<soapenv:Body>\n' +
		   	 			'<wsl:wslv021_main_service>\n' +
		   	 				'<getPricesAndStocksRequest>\n' +
		   	 					'<getPricesAndStocksRequest>\n' +
		   							'<Data>\n';
        								if(stores != null) {
                                            for(Store__c store : stores) {
                                                soapRequest += '<storeList>' + store.RetailStoreId__c + '</storeList>';
                                            }
                                        }
        								if(itemCodes != null) {
                                            for(String itemCode : itemCodes) {
                                                soapRequest += '<itemList>' + itemCode + '</itemList>';
                                            }
                                        }
		   								soapRequest += '</Data>\n' +
		   						'</getPricesAndStocksRequest>\n' +
		   					'</getPricesAndStocksRequest>\n' +
		   				'</wsl:wslv021_main_service>\n' +
		   			'</soapenv:Body>' +
		   		'</soapenv:Envelope>';
   		return soapRequest;
    }
}