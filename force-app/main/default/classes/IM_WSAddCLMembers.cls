@RestResource(urlMapping='/AddCLMembers')
global with sharing class IM_WSAddCLMembers {
	
    /*=================================================================================================================*/

    	@HttpPost
    	global static ResponseHandler AddCLMembers(String clientListId, String clientIds) {
    		RestResponse res = RestContext.response;
    		ResponseHandler response = new ResponseHandler();
    		res.addHeader('Content-Type','application/json');
    		List<ResponseHandler> resL =new List<ResponseHandler>();
    		List<String> clientIdsList=clientIds.split(';');

    		List<CLM_CliListMember__c> clmsToUpdate = new List<CLM_CliListMember__c>();
    		List<Contact> contactsToAdd =[Select Id From Contact 
    		Where AccountId IN:clientIdsList];

            List<CLM_CliListMember__c> existingCLM =[Select Client__c From CLM_CliListMember__c Where ClientList__c =:clientListId And Client__c IN :contactsToAdd];

    		Set<String> existingCLMSet =new Set<String>();
            for(CLM_CliListMember__c clm :existingCLM){
                existingCLMSet.add(clm.Client__c);
            }

            if(contactsToAdd.size()>0){
    			try{
    				for(Contact c :contactsToAdd){
                        if(!existingCLMSet.contains(c.Id)){
        					CLM_CliListMember__c clm =new CLM_CliListMember__c(	Client__c=c.Id, ClientList__c=clientListId );
        					clmsToUpdate.add(clm);
                        }
    				}

    				if(clmsToUpdate.size()>0){
    					insert clmsToUpdate;
    				}
                    
    				res.statusCode= 200;
		        	response.Status = 'Success';
		        	return response;

    			}catch(Exception e) {
	                response.Status = 'Error:'+e.getMessage();
	                res.statusCode= 400;
	                return response;
	            }
    			
    		} else{
    				res.statusCode= 200;
		            response.Status = 'Error: Clients not found';
		            return response;
    			}

	        
    }
    /*=================================================================================================================*/    

//Custom Response Object
	global class ResponseHandler {
	    public String Status {get; set;}   
	}
		
}