/**
 * This is a webservice mock class for SO_RetreiveArticlesPriceRMS_Utils_TEST class
 * [For correct response errorCode need to be 000]
 * @createdBy           Nadav Lichtenshtein	11/1/2016
 * @lastModifiedBy      Nadav Lichtenshtein	11/1/2016
 */
@isTest
global class SO_RetreiveArticlesPriceRMS_Utils_MOCK implements WebServiceMock
{
	private String errorCode;
    private String helpingParameter;

    global SO_RetreiveArticlesPriceRMS_Utils_MOCK(String errorCode, String helpingParameter){
        this.errorCode = errorCode;
        this.helpingParameter = helpingParameter;
    }

	global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) 
	{
		System.debug('SFDC responseNS: ' + responseNS);
		if(responseNS.contains('storeGetID')){
			SO_WS_RMS_StoreGetId.mainServiceResponse respElement = new SO_WS_RMS_StoreGetId.mainServiceResponse();
			respElement = responseFromStoreGetID();
			response.put('response_x', respElement); 
			System.debug('SFDC response: ' + response);
		}
		else{
			SO_WS_RMS_ProductSearch.mainServiceResponse respElement = new SO_WS_RMS_ProductSearch.mainServiceResponse();
			respElement = responseFromProductSearch();
			response.put('response_x', respElement); 
			System.debug('SFDC response: ' + response);
		}
	}

	/**
     * [responseFromStoreGetID, The Mock returnd fake data from SO_WS_RMS_StoreGetId WSDL]
     * @CreatedBy       Nadav Lichtenshtein	11/1/2016
 	 * @LastModifiedBy  Nadav Lichtenshtein	11/1/2016
     */
	private SO_WS_RMS_StoreGetId.mainServiceResponse responseFromStoreGetID()
	{
		SO_WS_RMS_StoreGetId.docTypeRef_LvmHeaderResponse lvmHeaderResponse = new SO_WS_RMS_StoreGetId.docTypeRef_LvmHeaderResponse();
        lvmHeaderResponse.errorCode       = errorCode;
        lvmHeaderResponse.errorMessage    = 'errorMsg';
        lvmHeaderResponse.errorType       = 'errorType';

        SO_WS_RMS_StoreGetId.storeInformation store = new SO_WS_RMS_StoreGetId.storeInformation();
    	store.userProfile 			= 'testUser';
		store.storeName				= 'testStore';
		store.aliasServerID			= '123';
		store.storeLatitude			= 'testLatitude'; 
		store.storeLongitude		= 'testLongitude';
		store.storeCode				= '1234';
		store.country				= 'testCountry';
		store.city					= 'testCity';
		store.storeLocalCurrency	= 'INS';
		store.headOfficeCode		= '123';
		store.zone					= '2';
		store.decimalSeparator		= '2';
		store.thousandsSeparator	= '1';
		store.nbOfDecimals			= this.helpingParameter;

        SO_WS_RMS_StoreGetId.DataResponse dataresponse= new SO_WS_RMS_StoreGetId.DataResponse();
        dataresponse.storeInformation  = store;

        SO_WS_RMS_StoreGetId.storeGetIDResponse2 storeResponse2 = new SO_WS_RMS_StoreGetId.storeGetIDResponse2();
        storeResponse2.LvmHeaderResponse = lvmHeaderResponse;
        storeResponse2.DataResponse = dataresponse;

        SO_WS_RMS_StoreGetId.storeGetIDResponse storeResponse1 = new SO_WS_RMS_StoreGetId.storeGetIDResponse(); 
        storeResponse1.storeGetIDResponse = storeResponse2;

        SO_WS_RMS_StoreGetId.mainServiceResponse respElement = new SO_WS_RMS_StoreGetId.mainServiceResponse();
        respElement.storeGetIDResponse = storeResponse1;

        return respElement;
	}

	/**
     * [responseFromProductSearch, The Mock returnd fake data from SO_WS_RMS_ProductSearch WSDL]
     * @CreatedBy       Nadav Lichtenshtein	11/1/2016
 	 * @LastModifiedBy  Nadav Lichtenshtein	11/1/2016
     */
	private SO_WS_RMS_ProductSearch.mainServiceResponse responseFromProductSearch()
	{
		SO_WS_RMS_ProductSearch.docTypeRef_LvmHeaderResponse lvmHeaderResponse = new SO_WS_RMS_ProductSearch.docTypeRef_LvmHeaderResponse();
        lvmHeaderResponse.errorCode       = errorCode;
        lvmHeaderResponse.errorMessage    = 'errorMsg';
        lvmHeaderResponse.errorType       = 'errorType';

        SO_WS_RMS_ProductSearch.itemInformation item = new SO_WS_RMS_ProductSearch.itemInformation();
    	item.itemCode							= '123';
        item.itemDescription					= 'testDesc';
        item.domesticPriceIncludingTax 			= helpingParameter;
        item.domesticPriceNotIncludingTax 		= '200000';
        item.dutyFreePriceIncludingTax 			= '250000';
        item.dutyFreePriceNotIncludingTax 		= '150000';
        item.currency_x 						= '34';
        item.stockBin 							= 'testBin';
        item.stockBinDescription 				= 'testBinDesc';
        item.geographicalLocation 				= 'testLocation ';
        item.geographicalLocationDescription	= 'testLocationDesc';
        item.stockQuantity 						= '400';
        item.stockStatus						= 'available';
        item.sellable							= 'yes';

		List<SO_WS_RMS_ProductSearch.itemInformation> itemList = new List<SO_WS_RMS_ProductSearch.itemInformation>{item};

        SO_WS_RMS_ProductSearch.DataResponse dataresponse= new SO_WS_RMS_ProductSearch.DataResponse();
        dataresponse.itemInformation  = itemList;

        SO_WS_RMS_ProductSearch.itemSearchResponse2 itemResponse2 = new SO_WS_RMS_ProductSearch.itemSearchResponse2();
        itemResponse2.LvmHeaderResponse = lvmHeaderResponse;
        itemResponse2.DataResponse = dataresponse;

        SO_WS_RMS_ProductSearch.itemSearchResponse itemResponse1 = new SO_WS_RMS_ProductSearch.itemSearchResponse(); 
        itemResponse1.itemSearchResponse = itemResponse2;

        SO_WS_RMS_ProductSearch.mainServiceResponse respElement = new SO_WS_RMS_ProductSearch.mainServiceResponse();
        respElement.itemSearchResponse = itemResponse1;

        system.debug('respElement ' + respElement);
	      
        return respElement;
	}
	
}