/**
 * [SO_ClientAdvisorEnquiryRMS_Utils]
 * Utility Class handling the RMS SO_WS_RMS_DoProductSearch and SO_WS_RMS_DoStoreGetId Web Services.
 * 
 * It is used to get the article prices.
 * The LV system requires 2 callout to get the price:
 *  -   1 callout to get the number of decimals into the price
 *  -   1 callout to get the price
 *
 * The web service is called from:
 * 
 * @CreatedBy       Jonathan Cohen on January 2016
 * @LastModifiedBy  Jonathan Cohen on January 2016
 */
public with sharing class SO_RetreiveArticlesPriceRMS_Utils 
{

	/**
    * Inner Class that will return the Web Service Callout result and fields such as:
    * @CreatedBy       Jonathan Cohen on January 2016
 	* @LastModifiedBy  Jonathan Cohen on January 2016
    */
    public Class SO_ArticlePriceResults
    {
        public Boolean calloutSuccessResult;
        public String calloutFinalArticlePrice;
        public String calloutNumberOfDeciamls;
    }

    /**
     * [RetrieveArticlePriceFromRMS : The function launch 2 Callouts to retreive the Article price from the RMS]
     *
     * The LV system requires 2 callout to get the price:
	 *  -   1 callout to get the number of decimals into the price
	 *  -   1 callout to get the price
 	 *
 	 * The Callout response contains :
	 * -   The Article Price
	 * -   The Number of Decimals into the Article Price
	 * -   The Error that occured -  NULL if no Error occured
     *  
     * @CreatedBy       Jonathan Cohen on January 2016
 	 * @LastModifiedBy  Jonathan Cohen on January 2016
     * @return [If Web Service Callout succeeded, null otherwise]
     */
    public static SO_ArticlePriceResults RetrieveArticlePriceFromRMS(String storeCode, String baseSKU)
    {   
        System.debug('RetrieveArticlePriceFromRMS - START:');
        SO_RetreiveArticlesPriceRMS_Utils.SO_ArticlePriceResults calloutResult = new SO_RetreiveArticlesPriceRMS_Utils.SO_ArticlePriceResults();
        calloutResult.calloutSuccessResult = false;

        calloutResult.calloutNumberOfDeciamls   = SO_RetreiveArticlesPriceRMS_Utils.StoreGetIdFromRMS(storeCode);
        calloutResult.calloutFinalArticlePrice  = SO_RetreiveArticlesPriceRMS_Utils.ProductSearchIntoRMS(storeCode, baseSKU);
        calloutResult.calloutSuccessResult      = true;

        System.debug('SFDC calloutResult: ' + calloutResult);
        return calloutResult;
    }

    /**
     * [StoreGetIdFromRMS]
     * The web service StoreGetId is used to get the number of decimals in the price of the product for the store.
     * 
     * @CreatedBy       Jonathan Cohen on January 2016
 	 * @LastModifiedBy  Jonathan Cohen on January 2016
     * @return [A String representing the number of decimals into the price.]
     */
    public static String StoreGetIdFromRMS(String storeCode)
    {    
        String numberOfDecimalsIntoPrice		     = null;
        SO_WS_RMS_DoStoreGetId retreiveDecimalNumber = new SO_WS_RMS_DoStoreGetId();
        SO_WS_RMS_DoStoreGetId.DataInput dataInput   = new SO_WS_RMS_DoStoreGetId.DataInput();

        dataInput.StoreCode = storeCode;
        SO_WS_RMS_DoStoreGetId.Result calloutResult = retreiveDecimalNumber.doStoreGetId(dataInput);
        system.debug('SFDC calloutResult: ' + calloutResult);

        if(String.isNotBlank(calloutResult.nbOfDecimals) && String.isBlank(calloutResult.Error)){
            numberOfDecimalsIntoPrice = calloutResult.nbOfDecimals;
        }
        else if(String.isNotBlank(calloutResult.Error)){
            SO_UTIL.exceptionDump('Error >> ' + calloutResult.Error);
            throw new SO_UTIL.RMSException(calloutResult.Error);
        }
        else{
            String msg = 'RMS Empty result';
            SO_UTIL.exceptionDump('StoreGetIdFromRMS >> ' + msg);
            throw new SO_UTIL.RMSException(msg);   
        }
        return numberOfDecimalsIntoPrice;
    }

    /**
     * [ProductSearchIntoRMS]
     * The web service ProductSearch is used to get the price of the product for the store.
     * The decimal of the price has to be put at the position given by the number of decimals returned by the second web service StoreGetId.
     * According to specification we don't use priceCurrency which return from the WS call
     * 
     * @CreatedBy       Jonathan Cohen on January 2016
 	 * @LastModifiedBy  Jonathan Cohen on January 2016
     * @return [A String representing the price without the number of decimals into the price.]
     */
    public static String ProductSearchIntoRMS(String storeCode, String baseSKU)
    {   
        String articlePriceWithoutDecimals 			   = null;
        SO_WS_RMS_DoProductSearch retreiveProductPrice = new SO_WS_RMS_DoProductSearch();
        SO_WS_RMS_DoProductSearch.DataInput dataInput  = new SO_WS_RMS_DoProductSearch.DataInput();

        dataInput.storeCode     = storeCode;
        dataInput.productCode   = baseSKU;

        SO_WS_RMS_DoProductSearch.Result calloutResult = retreiveProductPrice.doProductSearch(dataInput);
        system.debug('SFDC calloutResult: ' + calloutResult);

        if(String.isNotBlank(calloutResult.SPO_UnitRetailPrice) && String.isBlank(calloutResult.Error)){
            articlePriceWithoutDecimals = calloutResult.SPO_UnitRetailPrice;
        }
        else if(String.isNotBlank(calloutResult.Error)){
            SO_UTIL.exceptionDump('Error >> ' + calloutResult.Error);
            throw new SO_UTIL.RMSException(calloutResult.Error);
        }
        else {
            String msg = 'RMS Empty result';
            SO_UTIL.exceptionDump('StoreGetIdFromRMS >> ' + msg);
            throw new SO_UTIL.RMSException(msg);   
        }
        return articlePriceWithoutDecimals;
    }
}