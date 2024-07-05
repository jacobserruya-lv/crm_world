//Balink January 2017
//Description: WebService From LV to SF with goal to update User Identity

@RestResource(urlMapping='/UpdateAsset')
global without sharing class IOT_WS_UpdateAsset {
	


    	@HttpPost
    	global static ResponseHandler UpdateAsset(String assetId,String name) {
    		RestResponse res = RestContext.response;
    		ResponseHandler response = new ResponseHandler();
    		res.addHeader('Content-Type','application/json');
    		User u=[Select Id,Contact.AccountId, ContactId From User where Id=:UserInfo.getUserId()];
    		List<Asset> asList=[Select Id From Asset Where id=:assetId and (AccountId=:u.Contact.AccountId OR ContactId=:u.ContactId)];
	        try{	
	        		if(asList.size()>0){
	        			Asset astoUp= new Asset(Id=asList[0].Id,Name=name);
			        	update astoUp;
			        	res.statusCode= 200;
			        	response.Status = 'success';
			            response.Message = 'ASSET_UPDATED';
			            response.Data=astoUp;
		                return response;
		            }
	                else{
	                	throw new AssetException('ASSET_NOT_FOUND');
	                }
	        }catch(Exception e) {
                response.Status = 'error';
                response.Message = e.getMessage();
                res.statusCode= 400;
                return response;
            }

	        

    }

//Custom Response Object
	global class ResponseHandler {
	    public String Status {get; set;}
	    public sObject Data {get;set;}
	    public String Message {get;set;}  
	}

	public class AssetException extends Exception{}
		
}