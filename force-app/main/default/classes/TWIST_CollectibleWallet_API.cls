@RestResource(urlMapping='/collectibleWallet/*')
global without sharing class TWIST_CollectibleWallet_API {

    private static Map<String,Object> requestParameters;

    @testVisible
    private static final String ACCOUNT_ID_KEY = 'accountId';
    @testVisible
    private static final String WALLETS_KEY = 'wallets';
    
    @HttpPatch
    global static void updateCollectibleWallet() {
        RestResponse response;
        try {
            extractRequestParameters();
            if (areRequiredParametersMissing()) {
                response = buildRestResponse(400, Label.EM_required_field_missing);
                return;
            }
            IDENTITY_Utils.updateCollectibleWallet(
                (Object) requestParameters.get(WALLETS_KEY),
                (String) requestParameters.get(ACCOUNT_ID_KEY)
            );
            response = buildRestResponse(200, 'OK');
        }
        catch (Exception e) {
            response = buildRestResponse(400, e.getMessage());
        }
    }

    /* ************************************************************************************************************************** */

    private static void extractRequestParameters() {
        requestParameters = RestContext.request.requestBody == null ? null : (Map<String,Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
    }

    private static Boolean areRequiredParametersMissing() {
        return requestParameters == null
            || requestParameters.isEmpty()
            || !requestParameters.containsKey(WALLETS_KEY)
            || !requestParameters.containsKey(ACCOUNT_ID_KEY)
            || ((List<Object>) requestParameters.get(WALLETS_KEY)).isEmpty()
            || String.isBlank((String) requestParameters.get(ACCOUNT_ID_KEY));
    }

    private static RestResponse buildRestResponse(Integer statusCode, String message) {
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type','application/json');
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf(JSON.serialize(new Map<String,Object> {
            'success' => (statusCode == 200),
            'message' => message
        }));
        return response;
    }
    
}