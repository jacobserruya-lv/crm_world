/**
 * Called in qualification flow to match Task with Account
 */
public class ICX_AccountIdsInvoc {
    
    @InvocableMethod(label='Account IDs Collection' description='Get the list of account Ids from the phone number if accountIds is not present in the input var.' category='Iconics')
    public static List<Result> getAccountIds(List<Request> requests) {
        String accountIds = requests[0].accountIds;
        String direction = requests[0].direction;
        String phoneNumber = requests[0].phoneNumber;
        String emailAddress = requests[0].emailAddress;
        Id recordId = requests[0].recordId;
       	String objectType = recordId.getSObjectType().getDescribe().getName();
        
        List<String> accIds = new List<String>();
        Boolean multiMatch = false;
        String whatId = null;
        
        if('Task'.equalsIgnoreCase(objectType)){
            Boolean outCond = String.IsNotBlank(phoneNumber) && direction == 'Out';
            Boolean inCond = String.IsNotBlank(accountIds) && String.IsNotBlank (phoneNumber) && direction == 'In' && accountIds.startsWith('!!!');
            Boolean updateTaskCond = String.IsNotBlank(recordId) && (inCond || outCond);
            Boolean splitCondAlt = String.IsNotBlank(accountIds) && (! accountIds.startsWith('!!!'));
    
            if(inCond || outCond){
                try{
                    for(Account a : [SELECT Id FROM Account WHERE (Phone = :phoneNumber OR PersonMobilePhone = :phoneNumber 
                                                                   OR PersonHomePhone = :phoneNumber) AND (NOT name LIKE 'anonymize%') LIMIT 100])
                    {        
                        accIds.add(a.Id);
                    }
                }catch(QueryException e){ // catch Non-selective query against large Exception on anonymized Accounts
                    new Logs.ERROR('ICX_GenesysExtensionPoint', 'APEX Code', e);
                }
             
                if(updateTaskCond){
                    whatId = (accIds.size() == 1) ? accIds.get(0) : null;
                    Task t = new Task(
                        Id = recordId,
                        LVM_SFDCAccountIds__c = '', // delete the characters !!! on all incoming calls
                        WhatId = whatId
                    );
                    update t; 
                }   
            }
            else if(splitCondAlt){
                accIds = accountIds.split(',');
        	}
        }
        else if('Case'.equalsIgnoreCase(objectType)){
            if(String.isBlank(accountIds) && String.isNotBlank(emailAddress)){
                for(Contact a : [SELECT Id FROM Contact WHERE Email = :emailAddress AND (NOT name LIKE 'anonymize%') LIMIT 100]){        
                    accIds.add(a.Id);
                }
            }
        }
      
        Result result = new Result();
        result.multiMatch = (accIds.size() > 1);
        result.accountCollection = accIds;
        result.whatId = whatId;
        return new List<Result>{result};
    }
    
    public class Request{  
        @InvocableVariable(label='Record Id' required=true)
        public String recordId; 

        @InvocableVariable(label='Account Ids' required=false)
        public String accountIds;  
        
        @InvocableVariable(label='Client Email' required=false)
        public String emailAddress; 
        
        @InvocableVariable(label='Phone direction In or Out bound' required=false)
        public String direction;

        @InvocableVariable(label='Phone number from the Task' required=false)
        public String phoneNumber;
    }
    
    public class Result{
        @InvocableVariable(label='Collection of Account IDs')
        public List<String> accountCollection;    

        @InvocableVariable(label='Is Multi Match')
        public Boolean multiMatch;    

        @InvocableVariable(label='What Id')
        public String whatId;  
    }
}