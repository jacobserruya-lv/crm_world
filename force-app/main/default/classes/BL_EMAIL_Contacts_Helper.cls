public with sharing class BL_EMAIL_Contacts_Helper {
   
    public static Object searchClientOrUser(String searchTerm,integer pageSize, integer pageIndex) {
        List<Id> selectedIds = new List<Id>();
        List<Object> results = new List<Object>();  
        searchTerm += '*';
      
        String searchQuery = ' FIND :searchTerm IN ALL FIELDS RETURNING ' +
                             ' Account (Id, Name, PersonEmail, PersonContactId WHERE PersonEmail != NULL LIMIT :pageSize OFFSET :pageIndex), ' +
                             ' User (Id, Name, Email, WWEmployeeNumber__c WHERE IsActive = TRUE LIMIT :pageSize OFFSET :pageIndex) ' 
                             ;

        BL_WS_Log.addLogQuery(searchQuery, 'USE CASE SEARCH');

        List<List<SObject>> searchResults =  Search.query(searchQuery);
        results.addAll(setObject(searchResults[0], BL_EMAIL_Constants.USE_CASE_SEARCH_CLIENT, 'Account'));
        results.addAll(setObject(searchResults[1], BL_EMAIL_Constants.USE_CASE_SEARCH_USER, 'User'));
        return results;
    }


    private static List<Object> setObject(List<SObject> records, String useCase, String type){
        List<Object> response = new List<Object>(); 
        
        for(SObject record : records) {
            
            Map<String,Object> result  = new BL_EasyQuery()
                                            .useCase(useCase )
                                            .convertSObjectToWrapper(record);
            result.put('type', type);
            response.add(result);
        } 
        return response;
    }

    public static Map<String, Object> getContactById(Id idContact){
        String useCase;
        String type;

        if(String.isNotEmpty(idContact)){

            if(idContact.getsobjecttype () == Schema.Account.getSObjectType() ){
                useCase =  BL_EMAIL_Constants.USE_CASE_SEARCH_CLIENT;
                type = 'Account';
            } else if(idContact.getsobjecttype () == Schema.User.getSObjectType()){
                useCase =  BL_EMAIL_Constants.USE_CASE_SEARCH_USER;
                type = 'User';
            }

            Map<String,Object> record =  new BL_EasyQuery()
                .useCase(useCase)
                .condition('Id = \'' + idContact + '\'')
                .executeQuery()
                .getMappedObject();
            
            record.put('type', type);
            return record;   
        }

        return null;
    }
}