@RestResource(urlMapping='/validateCaCode/*')
global with sharing class ValidateCaCode_API {
    private static void sendResponse(Integer statusCode, Boolean caValidationWsResult, String message) {
        if (RestContext.response == null) {
            RestContext.response = new RestResponse();
        }
        RestContext.response.statusCode = statusCode;
        RestContext.response.addHeader('Content-Type', 'application/json');
        if (message == null) {
            message = '';
        }
        RestContext.response.responseBody = Blob.valueOf('{"caValidationWsResult": ' + caValidationWsResult + ', "message": "' + message + '"}');
    }

    @HttpGet
    global static void validateCaCode() {
        try {
            Boolean caValidationWsResult = false;
            String caCode = RestContext.request.params.get('caCode');
        	String storeId = RestContext.request.params.get('storeId');
            
            System.debug('SFDC validateCaCodeWS Using API');
        	System.debug('SFDC this.opp.SPO_CACode__c: ' + caCode);
        	System.debug('SFDC this.opp.SPO_Store__c: ' + storeId);

            Store__c store = [SELECT RetailStoreId__c FROM Store__c WHERE Id = :storeId LIMIT 1];
            String storeCode = store.RetailStoreId__c;
            System.debug('storeCode' + storeCode);

            if (caCode == null || storeCode == null) {
                String message = 'CA code or store code is empty';
                sendResponse(200, caValidationWsResult, message);
            } else {
                 SO_WS_POSFacade.SO_ClientAdvisorEnquiryResults calloutResult = new SO_WS_POSFacade.SO_ClientAdvisorEnquiryResults();
                 if (!Test.isRunningTest()) {
            	    calloutResult = SO_WS_POSFacade.verifyClientAdvisorEnquiry(caCode, storeCode);
                 } else {
                    if (caCode == 'validCaCode') {
                        calloutResult.calloutSuccessResult = true;
                    } else {
                        calloutResult.calloutSuccessResult = false;
                    }
                 }
            
            	System.debug('RMS VerifyClientAdvisorEnquiryRMS=' + calloutResult);
            	caValidationWsResult = calloutResult.calloutSuccessResult;
            
                if (!caValidationWsResult) {
                    String message =  String.format('Error for the input CA code {0} and the store code {1}', new String[]{caCode, storeCode});
                    sendResponse(200, caValidationWsResult, message);
                } else {
                    sendResponse(200, caValidationWsResult, null);
                }
            }
     
        } catch (Exception e) {
            String message = e.getMessage().replaceAll('&apos;', '\'');
            System.debug('message: ' + message);
            String errorCode = message.substring(0, 3);
            System.debug('errorCode: ' + errorCode);
            // Only if the Error is '003' (CA code not found) we return caValidationWsResult = false
            if (errorCode != '003') {
                sendResponse(200, true, null);
            } else {
            sendResponse(200, false, message);
            }
        }
    }
}