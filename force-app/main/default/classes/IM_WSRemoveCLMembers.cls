@RestResource(urlMapping='/RemoveCLMember')
global with sharing class IM_WSRemoveCLMembers {
	
    /*=================================================================================================================*/ 

    	@HttpPost
    	global static ResponseHandler RemoveCLMember(String clientListId, String clientIds) {
    		RestResponse res = RestContext.response;
    		ResponseHandler response = new ResponseHandler();
    		res.addHeader('Content-Type','application/json');
    		List<ResponseHandler> resL =new List<ResponseHandler>();

            List<String> clientIdsList=clientIds.split(';');
    		List<CLM_CliListMember__c> cLMemberstoRemove =[Select Id, ClientList__c, Client__c, Client__r.AccountId From CLM_CliListMember__c 
    		Where ClientList__c=:clientListId AND (Client__c IN:clientIdsList OR Client__r.AccountId IN:clientIdsList)];

    		if(cLMemberstoRemove.size()>0){
                
    			try{
    				delete cLMemberstoRemove;
    				res.statusCode= 200;
		        	response.Status = 'Success';
		        	return response;

    			}catch(Exception e) {
	                response.Status = 'Error:'+e.getMessage();
	                res.statusCode= 400;
	                return response;
	            }
    			
    		} else{
    				res.statusCode= 400;
		            response.Status = 'Error: Client List Member not found.';
		            return response;
    			}

	        
    }
    /*=================================================================================================================*/ 
//Custom Response Object
	global class ResponseHandler {
	    public String Status {get; set;}   
	}
		
}