/**
  *  About
  *  -----
  *  Description: Client search generic for any application 
  *  Created for: Client search optimization project
  *  Create date: Oct 2015
  *  
  *  Details
  *  -------
  *  
  *  Update History
  *  --------------
  *  Oct 2015 / LV / Created by Simon GOURREAU
  *  Sep 2016 / RMOU / PIPA Law enhancement
  *  
  *  Issues / TODOs
  *  --------------
*/
public without sharing class LV_ClientSearchService { 
    
    
    private static LV_CS002_SearchParameters__c defaultChoice = LV_CS002_SearchParameters__c.getInstance('Service_Query_Settings');
    private static Map<String, List<String>> LabelToAccountFieldsMap = new Map<String, List<String>>();
    
    /**
    * @description Constructor
    */
    public LV_ClientSearchService() {
    }

    
    /**
    * @description Main method to call the Client Search service 
    * @param listFieldsToRetrieve - The list of fields to be in the Select portion of the query
    * @param listSearchCriterias - The list of search criteria used to find client record
    * @param clientPerPage - The query Limit
    * @param currentPage - The query Offset
    * @param OrderByField - Any field to be used in order to sort the result
    * @param isMergedClientSearch - Decision to check merged clients
    * @param queryType - The type of query to run (Automatic, SOSL or SOQL) if not forced at org level
    * @return The list of clients (Account) that match the search criteria
    */
    public static List<Account> searchClient(List<String> listFieldsToRetrieve, List<LV_UTILS.SearchCriteria> listSearchCriterias,
                                                Integer clientPerPage, Integer currentPage, String OrderByField, boolean isMergedClientSearch, String attachedFilter, String queryType){
        System.debug('>> Input ListSearchCriterias: ' + listSearchCriterias);
        System.debug('>> Input clientPerPage: ' + clientPerPage);
        System.debug('>> Input currentPage: ' + currentPage);
        System.debug('>> Input OrderByField: ' + OrderByField);
        System.debug('>> Input isMergedClientSearch: ' + isMergedClientSearch);
        System.debug('>> Input attachedFilter: ' + attachedFilter);
        System.debug('>> Input queryType: ' + queryType);
        
        String queryTypeDecision = '';
        String orderbyString = '';
        List<Account> listAccounts = new List<Account>();
        String queryString = '';
        Integer listSize = listFieldsToRetrieve.size();

        //Create label to fields map to easily fetch the fields required
        list<LV_CS001_SearchLabelToFields__c> LabelToAccountFields = LV_CS001_SearchLabelToFields__c.getall().values();
        
        for(LV_CS001_SearchLabelToFields__c labelToAcc : LabelToAccountFields){
            LabelToAccountFieldsMap.put(labelToAcc.Name, labelToAcc.fields__c.split(','));
        }
        
        //Search on merged clients
        for(LV_UTILS.SearchCriteria searchCriteria: listSearchCriterias){
            if(searchCriteria.Label == 'DreamId' && isMergedClientSearch){
                System.debug('>> Test Dream Id substitution... ');
                searchCriteria.value = isAnOldDreamId(searchCriteria.value);
            }
        }
        System.debug('>> ListSearchCriterias after Dream Id substitution: ' + listSearchCriterias);

        // Determine the type of query to run, SOQL or SOSL, depending on Org level configuration, client application whish
        if(listSize > 0){
            
            if(defaultChoice.SOQL__c){
                queryTypeDecision = 'SOQL';
            }else if(defaultChoice.SOSL__c){
                queryTypeDecision = 'SOSL';
            }else if(defaultChoice.Automatic__c){
                queryTypeDecision = determineQueryType(listSearchCriterias);
            }else if(queryType != null && queryType.trim() != ''){
                queryTypeDecision = queryType;
            }else{
                queryTypeDecision = determineQueryType(listSearchCriterias);
            }
            System.debug('>> queryTypeDecision: ' + queryTypeDecision);
            
            if(OrderByField != null && OrderByField.trim() != ''){
                orderbyString = ' order by ' + OrderByField +  ' ASC NULLS Last';
            }

            if (attachedFilter != null){
                if(attachedFilter.trim() != ''){
                    attachedFilter = ' AND' + attachedFilter + ' ';
                } else {
                    attachedFilter = '';
                }
            } else {
                attachedFilter = '';
            }

            //------------------------- SOQL Part
            if(queryTypeDecision == 'SOQL'){
                queryString = BuildAccountSoqlQuery(listFieldsToRetrieve) + createWhereClauseAccount(listSearchCriterias) + addPIPARule() + attachedFilter;
                system.debug('>> SOQL query : ' + queryString + getOffsetString(clientPerPage , currentPage) + orderbyString);
                listAccounts = Database.query(queryString + orderbyString + getOffsetString(clientPerPage , currentPage) );
            }else if(queryTypeDecision == 'SOSL'){
                //------------------------- SOSL Part   
                queryString = BuildAccountSoslQuery(listFieldsToRetrieve, listSearchCriterias) + createWhereClauseAccount(listSearchCriterias) + addPIPARule() + attachedFilter;
                system.debug('>> SOSL Query : ' + queryString  + orderbyString + getOffsetString(clientPerPage , currentPage) + ')');
                List<List<sObject>> searchResults = Search.query(queryString    + orderbyString + getOffsetString(clientPerPage , currentPage) + ')');
                List<Sobject> listAccountsSearchResult = searchResults[0];
                system.debug('>> SOSL Results : ' + listAccountsSearchResult.size());
                for (Sobject searchResult : listAccountsSearchResult) {
                    Account accountToReturn = (Account) searchResult;
                    listAccounts.add(accountToReturn);
                }   
            }
        }

        system.debug('>> Result : ' + listAccounts);

        return listAccounts;
    }


    /**
    * @description Builds the SOQL select from Account statement from the list of fields to retrieve 
    * @param listFieldsToRetrieve - The list of fields to be in the Select portion of the Soql query
    * @return The SOQL select from Account statement 
    */
    private static String BuildAccountSoqlQuery(List<String> listFieldsToRetrieve){
        return ('SELECT ' + String.join(listFieldsToRetrieve, ',') + ' FROM Account');
    }

    
    /**
    * @description Builds the SOSL query without the where statement
    * @param listFieldsToRetrieve - The list of fields to be in the select portion of the Sosl query
    * @param listSearchCriterias - The search criteria 
    * @return  The SOSL query without the where statement
    */
    private static String BuildAccountSoslQuery(List<String> listFieldsToRetrieve, List<LV_UTILS.SearchCriteria> listSearchCriterias){
        Integer listFieldsToRetrieveSize = listFieldsToRetrieve.size();
        Integer listSearchCriteriasSize = listSearchCriterias.size();
        String queryAccount = 'FIND \'';
        Integer countElementSearchCriteria = 0;
        Integer countElementFieldToRetrieve = 0;        
        String soslScopeDecision = determineSoslScope(listSearchCriterias);
        
        for(LV_UTILS.SearchCriteria searchCriteria : listSearchCriterias){
            countElementSearchCriteria ++;
            
            if(!LV_UTILS.Empty(searchCriteria.value) && searchCriteria.Label != 'Owner'){
                if(searchCriteria.operator == 'startsWith'){
                    if(countElementSearchCriteria < listSearchCriteriasSize){
                        queryAccount += '\"' + searchCriteria.Value + '*\" AND ';
                    } else {
                        queryAccount += '\"' + searchCriteria.Value + '*\"\' IN' + soslScopeDecision + 'RETURNING Account(';
                    }
                } else {
                    if(countElementSearchCriteria < listSearchCriteriasSize){
                        queryAccount += '\"' + searchCriteria.Value + '\" AND ';
                    } else {
                        queryAccount += '\"' + searchCriteria.Value + '\"\' IN' + soslScopeDecision + 'RETURNING Account(';
                    }
                }
            } else if(countElementSearchCriteria == listSearchCriteriasSize){
                queryAccount = queryAccount.removeEnd('AND ') + '\' IN' + soslScopeDecision + 'RETURNING Account(';
            }
        }

        for(String fieldToRetrieve : listFieldsToRetrieve){
            countElementFieldToRetrieve ++;
            
            if(countElementFieldToRetrieve < listFieldsToRetrieveSize){
                queryAccount += fieldToRetrieve + ', ';
            } else {
                queryAccount += fieldToRetrieve + '';
            }
        }

        return queryAccount;
    }

    /**
    * @description Builds the SOQL and SOSL query where clause
    * @param listSearchCriterias - The search criteria 
    * @return  
    */
    private static string createWhereClauseAccount(List<LV_UTILS.SearchCriteria> listSearchCriterias){
        String WhereClause = ' WHERE ';
        system.debug('LabelToAccountFieldsMap : ' + LabelToAccountFieldsMap);
        system.debug('listSearchCriterias : ' + listSearchCriterias);
        
        String whereHolder = '';

        for (LV_UTILS.SearchCriteria searchCriteria : listSearchCriterias){
            if (LabelToAccountFieldsMap.containsKey(searchCriteria.Label)){
                whereHolder += createORExpressionInParentheses(LabelToAccountFieldsMap.get(searchCriteria.Label), searchCriteria.Operator, searchCriteria.Value) + ' AND ';
            }
        }
        //AEF:
        if(String.isNotBlank(whereHolder)) {
           WhereClause += whereHolder.removeEnd('AND ');
        }
        else {

            WhereClause = '';
        }

        return WhereClause;
    }

    /**
    * @description Builds the where statement for criteria associated with several client fields. All client fields are combined with an OR operator.
    * @param fieldList - List of fields to OR between
    * @param Operator - The criteria comparison operator
    * @param Value - The criteria value
    * @return Inner Querry OR 
    */
    private static string createORExpressionInParentheses(List<String> fieldList, String Operator, String Value){
        String ORExpression = '';
        
        for(String field : fieldList){
            if(Operator == 'startsWith'){
                ORExpression += field + ' ' + 'LIKE'  + ' ' + '\'' + String.escapeSingleQuotes(Value) + '%\'' + ' OR ';
            }else{
                ORExpression += field + ' ' + '=' + ' ' + '\'' + String.escapeSingleQuotes(Value) + '\'' + ' OR ';
            }
        }
        
        ORExpression = ORExpression.trim().removeEnd('OR');
        ORExpression = '(' + ORExpression.trim() + ')';
        
        return ORExpression;
    }


    /**
    * @description Builds the Offset and Limit where statement, used for SOQL and SOSL queries
    * @param rowsPerPage - The limit
    * @param currentPageNumber - The offset
    * @return Offset and Limit where statement
    */
    private static String getOffsetString(Integer rowsPerPage, Integer currentPageNumber){
        String offsetLimitString = '';
        Integer lim = rowsPerPage < Integer.valueOf(defaultChoice.Limit__c) ? rowsPerPage : Integer.valueOf(defaultChoice.Limit__c);
        
        offsetLimitString += ' LIMIT ' + lim;
        
        if(currentPageNumber != null){
            offsetLimitString += ' OFFSET ' + currentPageNumber;
        }
        
        return offsetLimitString;
    }

    
    /**
    * @description Function decides what scope to use on SOSL
    * @param listSearchCriterias - The search criteria 
    * @param isMergedClientSearch - Must check client merged
    * @return The Sosl scope
    */
    private static string determineSoslScope(List<LV_UTILS.SearchCriteria> listSearchCriterias){
        String soslScopeDecision = '';
        boolean isFirst = true;
        Map<String,LV_CS003_SearchSOSLScopeMatrix__c> SOSLDecisionMatrix = LV_CS003_SearchSOSLScopeMatrix__c.getall();
        
        for(LV_UTILS.SearchCriteria searchCriteria: listSearchCriterias){
            if(!isFirst && soslScopeDecision != SOSLDecisionMatrix.get(searchCriteria.Label).SOSLSCope__c){
                soslScopeDecision = 'ALL FIELDS';
            }
            else{
                System.debug('searchCriteria.Label >> ' + searchCriteria.Label);
                System.debug('SOSLDecisionMatrix.get(searchCriteria.Label) >> ' + SOSLDecisionMatrix.get(searchCriteria.Label));

                soslScopeDecision = SOSLDecisionMatrix.get(searchCriteria.Label).SOSLSCope__c;
            }
            isFirst = false;
        }
        
        soslScopeDecision = ' ' + soslScopeDecision + ' ';
        
        return soslScopeDecision;
    }

    /**
    * @description Determines what type of query should run, SOQL or SOSL
    * @param listSearchCriterias - List of search criteria
    * @return SOSL or SOQL
    */
    private static string determineQueryType(List<LV_UTILS.SearchCriteria> listSearchCriterias){
        String automaticQueryTypeDecision = 'SOSL';
        Map<String,LV_CS004_SearchSOQLQueryMatrix__c> serviceCriteriaForSOQL = LV_CS004_SearchSOQLQueryMatrix__c.getall();
        System.debug('>> DetermineQueryType serviceCriteriaForSOQL: ' + serviceCriteriaForSOQL);

        for (LV_UTILS.SearchCriteria searchCriteria: listSearchCriterias){
            if (serviceCriteriaForSOQL.containsKey(searchCriteria.Label)){
                automaticQueryTypeDecision = 'SOQL';
                return automaticQueryTypeDecision;
            }
        }
        
        // Go with SOSL by default
        return automaticQueryTypeDecision;
    }

    /**
    * @description Adds the PIPA Law visibility restriction filter is the where clause
    * @return The where clause including the PIPA Law visibility restriction filter
    */
    private static String addPIPARule(){
        String whereString = '';
        
        // The visibility restriction depends on user's country and profile
        if(!IC_Factory.isAdmin()){
            List<String> listPIPACodes = IC_Factory.getListPIPACountryCodesToHide(IC_UTILS.getUserCountry());
            whereString = ' AND (AttachedStoreCountry__pc NOT IN (\'' + String.join(listPIPACodes, '\',\'') + '\'))';
            //whereString += IC_UTILS_Query.buildWhereCLause('AttachedStoreCountry__pc', System.Label.IC_KOREAN_FILTER_CODE, true, IC_UTILS_Query.NOT_EQUAL);
            //whereString =  (whereString.length() > 0? 'AND ' + whereString.removeEnd('AND ').trim(): '');
            }
        
        return whereString;
    }

    /**
    * @description Substitutes the Dream Id provided if it corresponds to a client that has been merged
    * @param dreamid - The Dream Id provided as search criteria 
    * @return The Dream Id that will be used for the search
    */
    private static String isAnOldDreamId(String dreamid) {
        List<MergedClients__c> mergedClient;
        
        // Abandonned and Survivor client Dream Id are store in a custom object : MergedClients__c
        mergedClient = new List<MergedClients__c>([SELECT ID, Absorbed_DreamId__c, MasterClient__c FROM MergedClients__c WHERE Absorbed_DreamId__c=:dreamid LIMIT 1]);

        if(mergedClient != null && mergedClient.size() > 0) {
            return mergedClient.get(0).MasterClient__c;
        }

        return dreamid;
    }

}