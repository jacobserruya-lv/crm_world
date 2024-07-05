@RestResource(urlMapping='/GetUserLangAsset')
global with sharing class PASS_WS03_GetUserLang {
	


    	@HttpPost
    	global static ResponseHandler GetUserLangAsset(String assetId) {
    		RestResponse res = RestContext.response;
    		ResponseHandler response = new ResponseHandler();
    		res.addHeader('Content-Type','application/json');
    		List<ResponseHandler> resL =new List<ResponseHandler>();
    		List<Asset> assets =[Select Id, AccountId From Asset Where Id=:assetId];
    		if(assets.size()==1){
    			List<User> users =[Select Id, LanguageLocaleKey From User Where AccountId =:assets[0].AccountId];
    			if(users.size()==1){
    				res.statusCode= 200;
		        	response.Status = 'Success';
		        	response.UserId= users[0].Id;
		        	response.UserLanguage= users[0].LanguageLocaleKey;
		        	return response;

    			} else{
    				res.statusCode= 400;
		            response.Status = 'Error: User not found';
		            return response;
    			}

    		} else {
    			res.statusCode= 400;
		        response.Status = 'Error: Asset not found';
		        return response;
    		}
	        
    }

//Custom Response Object
	global class ResponseHandler {
	    public String Status {get; set;}
	    public String UserId {get;set;}
	    public String UserLanguage {get;set;}
	    
	   
	}
		
}