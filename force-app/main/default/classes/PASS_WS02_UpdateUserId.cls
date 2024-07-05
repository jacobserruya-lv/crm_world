/*  
*** Balink January 2017
*** DESCRIPTION: WebService From LV to SF with goal to update User Identity (userId is received as parameter)
*/
@RestResource(urlMapping='/TechnicalUpdateIdentity')
global with sharing class PASS_WS02_UpdateUserId {

    /*
    *** DESCRIPTION Update a user Identity.
    ***             Throw exceptions in case of duplicata, required field missing ...   
    *** RETURN      The updated user with its id and username
    */
	@HttpPost
	global static IDENTITY_Utils.ResponseHandler UpdateUserIdentity() {
		
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type','application/json');

		// The body response must be as array format 
		IDENTITY_Utils.ResponseHandler response = new IDENTITY_Utils.ResponseHandler();
		List<IDENTITY_Utils.ResponseHandler> resL = new List<IDENTITY_Utils.ResponseHandler>();

        Map<String,Object> parameters = (Map<String,Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        
        try {
            // TechnicalUpdateIdentity => userId is not null; UpdateIdentity => userId is null so we are using the current uder id 
        	String userId = (parameters.get('userId') != null ? (String)parameters.get('userId') : UserInfo.getUserId());
            Object walletsOfClient = parameters.containsKey('wallets') ? parameters.get('wallets') : null;
        	Account account = Identity_Utils.toAccount(parameters);
            User uIdentity = Identity_Utils.updateMylvClient(account, userId);
            if(walletsOfClient != null){
                Identity_Utils.updateCollectibleWallet(walletsOfClient,account.id);
            }
	        
        	uIdentity = new User(
            	Id = uIdentity.Id,
                Username = uIdentity.Username
            );

            response = new IDENTITY_Utils.ResponseHandler('success', Label.SM_User_and_Account_Updated, uIdentity);
            resL.add(response);
        	
            res.statusCode = 200;
            res.responseBody = Blob.valueOf( JSON.serialize(resL) );
            return response;
        }
        catch(Exception e) {

        	String error = getExceptionMessage(e.getMessage());
            response = new IDENTITY_Utils.ResponseHandler('error', error);
            resL.add(response);

            res.statusCode = 400;
            res.responseBody = Blob.valueOf( JSON.serialize(resL) );
            return response;
        }
    }

    public static String getExceptionMessage(String message) {
        if(message.contains('DUPLICATE_VALUE') || message.contains('DUPLICATE_USERNAME')) {
            return Label.EM_Duplicate_Username;
        }
        else if(message.contains('REQUIRED_FIELD_MISSING')) {
            return Label.EM_required_field_missing;
        }

        return message;
    }
}