global with sharing class BL_ICON_SearchClient_Helper {
        
    public static Object searchByText(string searchText , String filters, integer pageSize, integer pageIndex, Map<String, Object> userDetails){
        if(BL_WS_Router.clientPlatform == 'WECHAT'){ 
            List<String> clientIds = new List<String>();
            List<String> tagLabels = new List<String>();
            List<String> filtersList = filters != null ? filters.split(';') : new List<String>();
            String tagFindCondition = searchText != null ? searchText.replaceAll(',', ' OR ') : '';

            if(!filtersList.contains('tag')){// search client +tag
                List<Account> sosl = (List<Account>) new BL_EasyQuery()
                .objectName('Account')
                .fields(new List<String>{'Id'})
                .condition(String.isNotBlank(filters) ? getWhereCondition(filters, userDetails) : null )
                .pagination(pageIndex, pageSize)
                .searchText(searchText)
                .executeSearch()
                .getSObjects();

                for(Account acc: sosl){
                    clientIds.add(acc.id);
                }
                
            }
            //tag search
            List<Tag__c> sosl_tags = (List<Tag__c>) new BL_EasyQuery()
            .objectName('Tag__c')
            .fields(new List<String>{'client__c', 'Value_MP__c'})
            .condition('OwnerId = \''+userDetails.get('id')+'\'')
            .pagination(pageIndex, pageSize)
            .searchText(tagFindCondition)
            .executeSearch()
            .getSObjects();

            for(Tag__c tag: sosl_tags){
                if(tag.client__c != null && !clientIds.contains(tag.client__c)){
                    clientIds.add(tag.client__c);
                }
                if(!tagLabels.contains(tag.Value_MP__c )){
                    tagLabels.add(tag.Value_MP__c);
                }
            }
            

            BL_WS_Log.addLogNotes('ClientIds', clientIds);
            List<Map<String, Object>> results = new list<Map<String, Object>>();
            String inputList = '';
            if(tagLabels.size() > 0){
                for(string word: tagLabels){
                    inputList += ' \''+word.trim()+'\' ,';
                }
                inputList = inputList.substring(0, inputList.length()-1);
            }
            else{
                inputList = '\'\'';
            }
            
            if(clientIds.size() > 0){
                Map<String,String> conditionMap = new Map<String,String>{
                    '{OWNER_ID}' => String.valueOf(userDetails.get('id')),
                    '{SEARCH_INPUT_LIST}' =>inputList
                };
                BL_EasyQuery easyQuery = new BL_EasyQuery();
                easyQuery.useCase(BL_ICON_Constants.USE_CASE_SEARCH_CLIENT_SOQL);
                easyQuery.condition('Id IN (' + '\'' + String.join((clientIds), '\',\'') + '\''+')');
                easyQuery.setCustomFieldString(conditionMap);
                easyQuery.executeQuery();
                List<Map<String, Object>> clients = easyQuery.getMappedObjects();

                Map<String, Map<String, Object>> clientsMap = new Map<String, Map<String, Object>>();
                for(Map<String, Object> client: clients){
                    clientsMap.put((String)client.get('id'), client);
                }

                for (String clientId: clientIds){
                    results.add(clientsMap.get(clientId));
                }
            }

            return results;
        } else {
            return new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_SEARCH_CLIENT)
            .condition(String.isNotBlank(filters) ? getWhereCondition(filters, userDetails) : null )
            .pagination(pageIndex, pageSize)
            .searchText(searchText)
            .executeSearch()
            .getMappedObjects();

            //  return new BL_EasyQuery()
            // .useCase(BL_ICON_Constants.USE_CASE_SEARCH_CLIENT)
            // .condition(getSearchSOQLWhereCondition(searchText)  + (String.isNotBlank(filters) ? ' AND ' + getWhereCondition(filters, userDetails) : '') )
            // .pagination(pageIndex, pageSize)
            // .executeQuery()
            // .getMappedObjects();

        }
        
    }
    
    private static String getWhereCondition(String filters, Map<String, Object> userDetails) {
        List<String> filtersList = filters.split(';');
        List<String> filtersConditions = new List<String>();
        String whereCondition = '';
        for(String filter : filtersList){
            switch on  filter{
                when  'attachedToMe' {
                    whereCondition += ' OwnerId =  \'' +  userDetails.get('id') + '\' AND ';
                }
                when 'myStore' {
                    whereCondition += ' AttachedStore__pc = \'' +  userDetails.get('storeCode') + '\' AND ';
                }
                when 'myCountry' {
                    whereCondition += ' PrimaryCountry__pc = \'' +  userDetails.get('country') + '\' AND ';
                }
                when 'myZone' {
                    
                }
                when 'transactionWithMe' {
                    whereCondition += ' Id in (select client__c from PPR_PurchProduct__c where WWEmployeeNumber__c = \'' +  userDetails.get('wwEmployeeNumber') + '\') AND ';
                }
                when else {		  
                    return null;
                }
            }
        }
        return whereCondition.removeEnd('AND ');
    }

    /*private static String getSearchSOQLWhereCondition(String searchtext) {
        String searchTextLiked = '\'%'+searchtext+'%\'';
        List<String> conditions = new  List<String>{
            ' Name LIKE ' + searchTextLiked,  
            ' LocalMobilePhone__pc LIKE ' + searchTextLiked,
            ' LocalHomePhone__pc LIKE ' + searchTextLiked,
            ' LocalWorkPhone__pc LIKE ' + searchTextLiked,
            ' DREAMID__c LIKE ' + searchTextLiked,
            ' FirstName LIKE ' + searchTextLiked,
            ' LastName LIKE ' + searchTextLiked,
            ' Firstname2__pc LIKE ' + searchTextLiked,
            ' Lastname2__pc LIKE ' + searchTextLiked,
            ' PersonEmail LIKE ' + searchTextLiked,
            ' PassportNumber__pc LIKE ' + searchTextLiked,
            ' RMSId__pc LIKE ' + searchTextLiked,
            ' PersonHomePhone LIKE ' + searchTextLiked,
            ' PersonMobilePhone LIKE ' + searchTextLiked
        };

        return ' ( ' + String.join(conditions, ' OR ') + ' ) ';
    }*/
}