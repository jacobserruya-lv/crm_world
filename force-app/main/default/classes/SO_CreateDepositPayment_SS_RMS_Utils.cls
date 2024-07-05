public with sharing class SO_CreateDepositPayment_SS_RMS_Utils {

    
    
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
    public Class SO_CreateUpdateRmsDepositPaymentResult
    {
        public Boolean calloutSuccessResult;
        public String calloutdepositPaymentRmsId;
    }

    /**
     * [CreatePaymentIntoRMS : The function launch the Callout to Create a Payment into L.V RMS]
     *
     * The Callout response contains :
     * -   The ExternalId (RMS ID) of the Deposit (depositNumber) Created - NULL if an Error occured
     * -   The ExternalId (RMS ID) of the Payment (transactionNumber) Created - NULL if an Error occured - Not used in this case
     * -   The Error that occured -  NULL if no Error occured
     *
     * If the Callout succeeded the next is done:
     *  -  The SFDC Firm Order RMS_TransationNumber__c field is updated with the RMS Id received.
     *  
     * @CreatedBy       J.C on December 2015
     * @LastModifiedBy  J.C on December 2015
     * @return [The RMS Payment Id if the Web Service Callout succeeded, null otherwise]
     */
    public static SO_CreateUpdateRmsDepositPaymentResult CreateDepositOrPaymentIntoRMS(Boolean isPayment)
    {   
        return CreateDepositOrPaymentIntoRMS(isPayment, null);
        /*System.debug('SFDC CreatePaymentIntoRMS');
        SO_CreateDepositPaymentRMS_Utils.SO_CreateUpdateRmsDepositPaymentResult calloutResult = new SO_CreateDepositPaymentRMS_Utils.SO_CreateUpdateRmsDepositPaymentResult();
        calloutResult.calloutSuccessResult = false;

        String depositPaymentRmsId = SO_CreateDepositPaymentRMS_Utils.createDepositOrPaymentIntoRMS_WS(isPayment);
        calloutResult.calloutSuccessResult = true;
        calloutResult.calloutdepositPaymentRmsId = depositPaymentRmsId;
        return calloutResult;*/
    }
    // SPO V2 Lightning
    public static SO_CreateUpdateRmsDepositPaymentResult CreateDepositOrPaymentIntoRMS(Boolean isPayment, Opportunity opp)
    {        
        System.debug('SFDC CreatePaymentIntoRMS');
        SO_CreateDepositPayment_SS_RMS_Utils.SO_CreateUpdateRmsDepositPaymentResult calloutResult = new SO_CreateDepositPayment_SS_RMS_Utils.SO_CreateUpdateRmsDepositPaymentResult();
        calloutResult.calloutSuccessResult = false;

        String depositPaymentRmsId = SO_CreateDepositPayment_SS_RMS_Utils.createDepositOrPaymentIntoRMS_WS(isPayment, opp);
        calloutResult.calloutSuccessResult = true;
        calloutResult.calloutdepositPaymentRmsId = depositPaymentRmsId;
        return calloutResult;
    }

    /**
     * [createDepostiWS : The function creates a Deposit into the L.V RMS using a Web Service callout via the Class SO_WS_RMS_DoSalesCreation]
     * The Callout needs to be activated only if:
     * -   The order is not a display order                   (opportunity.SPO_DisplayOrder__c == false)
     * -   The product is not free                            (opportunity. SPO_Free__c == false)
     * -   The amount of the deposit is not null and is not 0 (opportunity.SPO_DepositAmount__c)
     * 
     * The Callout response contains :
     * -   The ExternalId (RMS ID) of the Deposit (depositNumber) Created - NULL if an Error occured
     * -   The ExternalId (RMS ID) of the Payment (transactionNumber) Created - NULL if an Error occured - Not used in this case
     * -   The Error that occured -  NULL if no Error occured
     *
     * !Important: Either if it is a Deposit Creation or a Payment Creation, the value returned in the transactionNumber and the depositNumber is equal.
     * 
     * @CreatedBy       J.C on December 2015
     * @LastModifiedBy  J.C on December 2015
     * @return [The RMS Deposit Id if the Web Service Callout succeeded, null otherwise]
     */
    private static String createDepositOrPaymentIntoRMS_WS(Boolean isPayment, Opportunity opp)
    {
        System.debug('test MIY-1833 ==> in RMS');
        String calloutDepositPaymentIdResult = '';
        SO_WS_RMS_DoSalesServices createDepositWS     = new SO_WS_RMS_DoSalesServices();
        SO_WS_RMS_DoSalesServices.DataInput dataInput = new SO_WS_RMS_DoSalesServices.DataInput();
        
        system.debug('SFDC createDepositOrPaymentIntoRMS_WS SO_Session.theCurrentBrief: ');// + SO_Session.theCurrentBrief);
        dataInput.StoreCode         = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_StoreCode__c : opp.SPO_StoreCode__c);
        dataInput.rmsClientCode = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_RMSClientId__c : opp.SPO_RMSClientId__c);
        dataInput.wwRmsClientCode = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_wwRMSClientId__c : opp.SPO_wwRMSClientId__c); //MIY-1743 // MIY-1860
        dataInput.OrderNumber       = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_BriefCode__c : opp.OrderNumber__c);//opp.SPO_BriefCode__c);
        dataInput.CaCode            = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_caCode__c : opp.SPO_caCode__c);
        dataInput.lineUnitPrice = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_UnitRetailPriceQuotation__c : opp.SPO_UnitRetailPriceQuotation__c);
        dataInput.lineAmountIncludingTax = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_UnitRetailPriceQuotation__c : opp.SPO_UnitRetailPriceQuotation__c);
      //  dataInput.identifierOfTheStaff = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_caCode__c : opp.SPO_caCode__c); // MIY-1860
    //  dataInput.externalClientCode = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_caCode__c : opp.SPO_caCode__c); // MIY-1858
        dataInput.creationDate = opp.CreatedDate; 
        
        if(isPayment == false){
            dataInput.ActionType        = 'Deposit';
            dataInput.AmountWithTaxes   = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_DepositAmount__c : opp.SPO_DepositAmount__c);
            dataInput.itemCode           = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_SpecialOrderSKUCode__c : opp.SPO_SpecialOrderSKUCode__c);
            dataInput.quantity          = 1;
          //  dataInput.genericItemFlag = true; // MIY-1860
            dataInput.associateCode = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_caCode__c : opp.SPO_caCode__c);
        }

        else if(isPayment == true){
            dataInput.ActionType        = 'Payment';
            dataInput.AmountWithTaxes   = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_UnitRetailPriceQuotation__c : opp.SPO_UnitRetailPriceQuotation__c);
            dataInput.itemCode           = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_SpecialOrderSKUCode__c : opp.SPO_SpecialOrderSKUCode__c);
            dataInput.quantity          = 1;
         //   dataInput.genericItemFlag = true; // MIY-1860
            dataInput.associateCode = (SO_Session.theCurrentBrief != null ? SO_Session.theCurrentBrief.SPO_caCode__c : opp.SPO_caCode__c);
        }

        system.debug('ISRAEL BEFORE CALLOUT > ' + dataInput);
        SO_WS_RMS_DoSalesServices.Result calloutResult = createDepositWS.doSalesServices(dataInput);
        system.debug('SFDC createDepositOrPaymentIntoRMS_WS calloutResult.transactionNumber: ' + calloutResult.transactionNumber);
        system.debug('SFDC createDepositOrPaymentIntoRMS_WS calloutResult.error: ' + calloutResult.error);

        if(String.isNotBlank(calloutResult.TransactionNumber) && String.isBlank(calloutResult.Error)){
            if(isPayment == false){
                calloutDepositPaymentIdResult = calloutResult.DepositNumber;
            }
            else if(isPayment == true){
                calloutDepositPaymentIdResult = calloutResult.TransactionNumber;
            }
        }
        else if(String.isNotBlank(calloutResult.Error)){
            SO_UTIL.exceptionDump('createDepositOrPaymentIntoRMS_WS >> ' + calloutResult.Error);
            throw new SO_UTIL.RMSException(calloutResult.Error);
        }
        else {
            String msg = 'RMS Empty result';
            SO_UTIL.exceptionDump('createAccountIntoRMS_WS.createAccountIntoRMS_WS >> ' + msg);
            throw new SO_UTIL.RMSException(msg);   
        }
        return calloutDepositPaymentIdResult;
    }
    
}