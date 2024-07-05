/**
 * [SO_ClientAdvisorEnquiryRMS_Utils]
 * Utility Class handling the RMS SO_WS_RMS_DoClientAdvisorEnquiry, it used to validate the CA Code
 *
 * The web service has to be called :
 * -	From the VF : SO_ChoosePath in which the CA Code is entered
 * -	When the CA Code is modified in the VF SO_BriefOrder
 * 
 * @CreatedBy       Nadav Lichtenshtein	3/1/2016
 * @LastModifiedBy  Nadav Lichtenshtein	3/1/2016
 */
public with sharing class SO_ClientAdvisorEnquiryRMS_Utils 
{

	/**
    * Inner Class that will return the Web Service Callout result and fields such as:
    * @CreatedBy       Nadav Lichtenshtein	3/1/2016
    * @LastModifiedBy  Nadav Lichtenshtein	3/1/2016
    */
    public Class SO_ClientAdvisorEnquiryResults
    {
        public Boolean calloutSuccessResult;
        public String calloutClientAdvisorRmsId;
    }

    /**
    * [CreatePaymentIntoRMS : The function launch the Callout to Create a validate the CA Code]
    *
 	* The Callout response contains :
	* -   The CA Code (longName)
	* -   The Error that occured -  NULL if no Error occured
    *  
    * @CreatedBy       Nadav Lichtenshtein	3/1/2016
    * @LastModifiedBy  Nadav Lichtenshtein	3/1/2016
    * @return [If Web Service Callout succeeded, null otherwise]
    */
    public static SO_ClientAdvisorEnquiryResults VerifyClientAdvisorEnquiryRMS(String caCode, String storeCode)
    {        
        SO_ClientAdvisorEnquiryRMS_Utils.SO_ClientAdvisorEnquiryResults calloutResult = new SO_ClientAdvisorEnquiryRMS_Utils.SO_ClientAdvisorEnquiryResults();
        calloutResult.calloutSuccessResult = false;

        String clientAdvisorEnquiryRmsId = SO_ClientAdvisorEnquiryRMS_Utils.ValidateCACodeInRMS_WS(caCode, storeCode);
        calloutResult.calloutSuccessResult = true;
        calloutResult.calloutClientAdvisorRmsId = clientAdvisorEnquiryRmsId;
        return calloutResult;
    }

    /**
	 * [createDepostiWS : The function creates a Deposit into the L.V RMS using a Web Service callout via the Class SO_WS_RMS_DoSalesCreation]
	 *
	 * The field below are published in the object SO_WS_RMS_DoClientAdvisorEnquiry.DataInput
	 *
	 * The web service is called with:
	 * SO_WS_RMS_DoClientAdvisorEnquiry.Result result = ws.doClientAdvisorEnquiry(dataIn);
	 * 
	 * @CreatedBy       Nadav Lichtenshtein	3/1/2016
     * @LastModifiedBy  Nadav Lichtenshtein	3/1/2016
	 * @return [The RMS Deposit Id if the Web Service Callout succeeded, null otherwise]
	 */
    private static String ValidateCACodeInRMS_WS(String caCode, String storeCode)
    {
        System.debug('SFDC ValidateCACodeInRMS_WS');
        String calloutCaValidationRmsId = '';
        SO_WS_RMS_DoClientAdvisorEnquiry createDepositWS     = new SO_WS_RMS_DoClientAdvisorEnquiry();
        SO_WS_RMS_DoClientAdvisorEnquiry.DataInput dataInput = new SO_WS_RMS_DoClientAdvisorEnquiry.DataInput();
        
        dataInput.StoreCode         = storeCode;
        dataInput.CaCode            = caCode;

        SO_WS_RMS_DoClientAdvisorEnquiry.Result calloutResult = createDepositWS.doClientAdvisorEnquiry(dataInput);
        system.debug('SFDC ValidateCACodeInRMS_WS calloutResult.longName: ' + calloutResult.longName);
        system.debug('SFDC ValidateCACodeInRMS_WS calloutResult.error: ' + calloutResult.error);

        if(String.isNotBlank(calloutResult.longName) && String.isBlank(calloutResult.Error)){
            	calloutCaValidationRmsId = calloutResult.longName;
        }
        else if(String.isNotBlank(calloutResult.Error)){
            SO_UTIL.exceptionDump('ValidateCACodeInRMS_WS >> ' + calloutResult.Error);
            throw new SO_UTIL.RMSException(calloutResult.Error);
        }
        else {
            String msg = 'RMS Empty result';
            SO_UTIL.exceptionDump('ValidateCACodeInRMS_WS.createAccountIntoRMS_WS >> ' + msg);
            throw new SO_UTIL.RMSException(msg);   
        }
        return calloutCaValidationRmsId;
    }
}