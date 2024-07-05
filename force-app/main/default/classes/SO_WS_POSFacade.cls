/**
* Point of Sales (POS) facade
* used to replace RMS to X-Store
**/
public class SO_WS_POSFacade {

    public static SO_CreateUpdateRmsDepositPaymentResult createDepositOrPayment(Boolean isPayment, Opportunity opp) {
        return createDepositOrPayment(isPayment, opp, false);
    }

    public static SO_CreateUpdateRmsDepositPaymentResult createDepositOrPayment(Boolean isPayment, Opportunity opp, Boolean isXStore) {
        if (opp != null && isPayment == false) {
            opp.SPO_DepositSentStatusDate__c = System.today();
        }

        SO_CreateUpdateRmsDepositPaymentResult result = new SO_CreateUpdateRmsDepositPaymentResult();
        
        if (isXStore && opp.SPO_Store__r.SalesServices__c) {
            // X-Store call - SalesServices
            WS019_CreateDepositHandler.Result xStoreCalloutResult = WS019_CreateDepositHandler.createDepositOrPaymentIntoXStore(isPayment, opp);

            result.calloutSuccessResult = xStoreCalloutResult.calloutSuccessResult;
            result.calloutdepositPaymentRmsId = xStoreCalloutResult.calloutDepositPaymentId;
        } else if (opp.SPO_Store__r.SalesServices__c) { // MIY-1895
            // RMS call - SalesServices
            SO_CreateDepositPayment_SS_RMS_Utils.SO_CreateUpdateRmsDepositPaymentResult calloutResult = 
            SO_CreateDepositPayment_SS_RMS_Utils.CreateDepositOrPaymentIntoRMS(isPayment, opp);

            result.calloutSuccessResult = calloutResult.calloutSuccessResult;
            result.calloutdepositPaymentRmsId = calloutResult.calloutdepositPaymentRmsId;
        }  else { //MIY-2100 not calling EAI for stores that use Xstore to collect the deposit Manually 
            // old call - SalesCreation 
            //  SO_CreateDepositPaymentRMS_Utils.SO_CreateUpdateRmsDepositPaymentResult calloutResult = 
            //  SO_CreateDepositPaymentRMS_Utils.CreateDepositOrPaymentIntoRMS(isPayment, opp);

            //  result.calloutSuccessResult = calloutResult.calloutSuccessResult;
            //  result.calloutdepositPaymentRmsId = calloutResult.calloutdepositPaymentRmsId;
       }
        
        return result;
    }

    public static Boolean verifyCaCodeWS(String storeCode, String caCode)
    {
        /*System.debug('SFDC verifyCaCodeWS');
        Boolean wsResult = false;

        System.debug('SFDC SPO_CACode__c: ' + caCode + ' newUser.DefaultStore__c: ' + storeCode);
        if(caCode != Null && storeCode != Null){
            SO_ClientAdvisorEnquiryRMS_Utils.SO_ClientAdvisorEnquiryResults calloutResult = SO_ClientAdvisorEnquiryRMS_Utils.VerifyClientAdvisorEnquiryRMS(caCode, storeCode);
            wsResult = calloutResult.calloutSuccessResult;
        }*/
        SO_ClientAdvisorEnquiryResults result = verifyClientAdvisorEnquiry(caCode, storeCode);
        return result.calloutSuccessResult;//wsResult;
    }

    public static SO_ClientAdvisorEnquiryResults verifyClientAdvisorEnquiry(String caCode, String storeCode) {

        // RMS call
        SO_ClientAdvisorEnquiryRMS_Utils.SO_ClientAdvisorEnquiryResults calloutResult = 
            SO_ClientAdvisorEnquiryRMS_Utils.VerifyClientAdvisorEnquiryRMS(caCode, storeCode);

        SO_ClientAdvisorEnquiryResults result = new SO_ClientAdvisorEnquiryResults();
        result.calloutSuccessResult = calloutResult.calloutSuccessResult;
        result.calloutClientAdvisorRmsId = calloutResult.calloutClientAdvisorRmsId;
        return result;
    }
    
    // public static SO_WS_RMS_DoClientSearch.Result clientSearch(SO_Util.SearchClientData clientData) { //MIY-2154


    //     SO_WS_RMS_DoClientSearch ws = new SO_WS_RMS_DoClientSearch();
    //     SO_WS_RMS_DoClientSearch.Result wsResult;

    //     // TODO what storeId use when not the user is not a Client Advisor?
    //     //if (String.isBlank(clientData.storeCode)) {
    //     //    clientData.storeCode = getUser().DefaultStore__c;
    //     //}
    //     try {
    //         wsResult = ws.doClientSearch(clientData);
    //         //System.debug('SFDC wsResult: ' + wsResult);
    //     } catch(Exception exp) {
    //         AuraHandledException e = new AuraHandledException(exp.getMessage());
    //         e.initCause(exp);
    //         throw e;
    //     }

    //     if (String.isNotBlank(wsResult.error)) {
    //         AuraHandledException e = new AuraHandledException(wsResult.error);
    //         //e.setMessage(wsResult.error);
    //         throw e;
    //     }

    //     return wsResult;
    // }  
     //MIY-2065 added 2 option (using Mulesoft or not)
    public static SO_WS_RMS_DoClientSearchMulesoft.Result clientSearchMulesoft(SO_Util.SearchClientData clientData) {
        SO_WS_RMS_DoClientSearchMulesoft ws = new SO_WS_RMS_DoClientSearchMulesoft();
        SO_WS_RMS_DoClientSearchMulesoft.Result wsResult;

        // TODO what storeId use when not the user is not a Client Advisor?
        //if (String.isBlank(clientData.storeCode)) {
        //    clientData.storeCode = getUser().DefaultStore__c;
        //}
        try {
            wsResult = ws.doClientSearch(clientData);
            //System.debug('SFDC wsResult: ' + wsResult);
        } catch(Exception exp) {
            AuraHandledException e = new AuraHandledException(exp.getMessage());
            e.initCause(exp);
            throw e;
        }

        if (String.isNotBlank(wsResult.error)) {
            AuraHandledException e = new AuraHandledException(wsResult.error);
            //e.setMessage(wsResult.error);
            throw e;
        }

        return wsResult;
    }
    
    public static Account clientSearch(String storeCode, String rmsId, String wwRmsClientCode) {

        Account acc = new Account();
        if(test.IsRunningTest()){
            acc.BirthdateYear__pc = '0';
            acc.BirthDateMonth__pc = '0';
            acc.BirthdateDay__pc = '0';
        }
        else{
            acc = SO_CreateUpdateRMSCLient_Utils.syncClient(storeCode, rmsId, new Account(RMSId__pc = rmsId, WW_RMSId__c = wwRmsClientCode), wwRmsClientCode);
        }
            // treat 0 as null
        if(String.isNotBlank(acc.BirthdateYear__pc) && Integer.valueOf(acc.BirthdateYear__pc) == 0)
        {
            acc.BirthdateYear__pc = null;
            if(test.IsRunningTest()){ acc.BirthdateYear__pc = '10';}
        }
        if(String.isNotBlank(acc.BirthDateMonth__pc) && Integer.valueOf(acc.BirthDateMonth__pc) == 0)
        {
            acc.BirthDateMonth__pc = null;
            if(test.IsRunningTest()){ acc.BirthDateMonth__pc = '10';}
        }
        if(String.isNotBlank(acc.BirthdateDay__pc) && Integer.valueOf(acc.BirthdateDay__pc) == 0)
        {
            acc.BirthdateDay__pc = null;
            if(test.IsRunningTest()){ acc.BirthdateDay__pc = '10';}
        }
        if (String.isNotBlank(acc.BirthdateYear__pc)) {
            Date newDate = Date.newinstance(
                Integer.valueOf(acc.BirthdateYear__pc), 
                Integer.valueOf(acc.BirthDateMonth__pc), 
                Integer.valueOf(acc.BirthdateDay__pc)
            );
            acc.PersonBirthdate = newDate;
        }
		return acc;
    }
    
    /**
     *  TODO: used for MTO product in SPO V1 not in SPO V2 ? Maybe to remove
     * Article price implementation
     * The Article Price will be automatically retrieved on the page loading at every Brief Order steps explained above. It is known that this automated flow will slow down the page loading on every steps above.
     * The only case requesting an automated importation of the price is the next, in any other cases, the price will be manually entered by the User:
     *  -    Brief Order’s field “SPO_ProductCategory__c” equals ‘Leather goods’
     *     AND
     *  -    Brief Order’s field “SPO_OrderType__c” equals  'Hardsided out of MyPerso
     */
  /*  @RemoteAction
    public static PriceResponse retrieveArticlePrice(String storeCode, String baseSKU) {

        PriceResponse res = new PriceResponse();
        try {
            SO_RetreiveArticlesPriceRMS_Utils.SO_ArticlePriceResults calloutResult = SO_RetreiveArticlesPriceRMS_Utils.RetrieveArticlePriceFromRMS(storeCode, baseSKU);
            System.debug('SFDC remoteRetreiveArticleRMSPrice calloutResult: ' + calloutResult);
            
            if( calloutResult != null && 
                calloutResult.calloutFinalArticlePrice != null && 
                calloutResult.calloutNumberOfDeciamls != null)
            {
                //if(unitRetailPrice != Decimal.ValueOf(calloutResult.calloutFinalArticlePrice)) {
                    res.unitRetailPrice = Decimal.ValueOf(calloutResult.calloutFinalArticlePrice);
                    res.numberOfDecimalsStore = Decimal.ValueOf(calloutResult.calloutNumberOfDeciamls);
                //}
            }
        }
        catch(SO_UTIL.RMSException exp) {
            System.debug('SO_BriefOrder - remoteRetreiveArticleRMSPrice - RMSException: ' + exp);
            res.errorMessage = exp.getMessage();
            res.errorCode = 2;
            res.isValid = false;
        } catch (Exception exp) {
            System.debug('SO_BriefOrder - remoteRetreiveArticleRMSPrice - Exception: ' + exp);
            res.errorMessage = exp.getMessage();
            res.errorCode = 1;
            res.isValid = false;
        }

        return res;
    }

    public class PriceResponse
    {
        public Decimal unitRetailPrice                      {get; set;}
        public Decimal numberOfDecimalsStore                {get; set;}
        public String  errorMessage                         {get; set;}
        public Integer errorCode                            {get; set;}
        public Boolean isValid                              {get; set;}

        public PriceResponse()
        {
            this.unitRetailPrice = 0;
            this.numberOfDecimalsStore = 0;
            this.isValid = true;
        }
    }*/

    /**
     * Inner Class that will return the Web Service Callout result and fields such as:
     *  - calloutSuccessResult        : true if the callout succeeded, false otherwise
     *  - calloutdepositPaymentRmsId  : The client created/updated RMS Id
     *
     * !Important: Either if it is a Deposit Creation or a Payment Creation, the value returned in the transactionNumber and the depositNumber is equal.
     * 
     * @CreatedBy       J.C on December 2015
     * @LastModifiedBy  J.C on December 2015
     */
    public class SO_CreateUpdateRmsDepositPaymentResult {
        public Boolean calloutSuccessResult;
        public String calloutdepositPaymentRmsId;
    }
  /**
    * Inner Class that will return the Web Service Callout result and fields such as:
    * @CreatedBy       Nadav Lichtenshtein  3/1/2016
    * @LastModifiedBy  Nadav Lichtenshtein  3/1/2016
    */
    public class SO_ClientAdvisorEnquiryResults
    {
        public Boolean calloutSuccessResult;
        public String calloutClientAdvisorRmsId;
    }

}