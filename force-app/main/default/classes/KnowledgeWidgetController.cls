/**
* Author: Basile NGOULOU
* Date: 06/05/2021
* Description: This class was written to search knowledge articles by keywords.
* and filter internal articles by zone (client service)
**/
public with sharing class KnowledgeWidgetController {
    // Maximum  returned records, after search
    private final static Integer MAX_RESULTS = 50;
    private final static String EXTERNAL_RECORDTYPE = 'External';
    private final static String INTERNAL_RECORDTYPE = 'Internal';

    @AuraEnabled(cacheable=true)
    public static List<String> knowledgeRecordTypes() {
        List<String> knowledgeRecordTypesValues = new List<String>();
        // Query all Knowledge__kav active record types
        for (RecordType recordType : [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND SobjectType = 'Knowledge__kav' ORDER BY DeveloperName ASC]) {
            knowledgeRecordTypesValues.add(recordType.DeveloperName);
        }
        return knowledgeRecordTypesValues;
    }

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> knowledgeArticles(String searchText, String recordTypeDeveloperName, String selectedClientService) {
            List<List<Knowledge__kav>> searchResults = new  List<List<Knowledge__kav>>();
        	List<Knowledge__kav> matchedArticles = new List<Knowledge__kav>();
        	List<List<Knowledge__kav>> articlesNotRanked = new  List<List<Knowledge__kav>>();

            // Found articles after Searching
            List<Knowledge__kav> foundArticles = new List<Knowledge__kav>();

        	Id recordTypeExternalId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('External').getRecordTypeId();
			Id recordTypeInternalId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        
            // Searching words in Knowledge articles. Search in Title, Summary and Article_Body__c
        if (String.isNotBlank(searchText)){
            if (String.isNotBlank(recordTypeDeveloperName) && recordTypeDeveloperName == EXTERNAL_RECORDTYPE){
                system.debug('Case External : recordTypeExternalId ==> '+recordTypeExternalId); 
                searchResults = [FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav (Id,Title,Summary,Article_Body__c,ArticleTotalViewCount WHERE (RecordTypeId = :'recordTypeExternalId' OR RecordType.DeveloperName = :recordTypeDeveloperName) AND language = 'en_US' ORDER BY ArticleTotalViewCount DESC LIMIT :MAX_RESULTS)];
                system.debug('External'+searchResults.size());
            } else if(String.isNotBlank(recordTypeDeveloperName) && recordTypeDeveloperName == INTERNAL_RECORDTYPE){
                system.debug('Case Internal: recordTypeInternalId ==> '+recordTypeInternalId); 
                searchResults = [FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav (Id,Title,Summary,Article_Body__c,Rank_at_the_top__c, ArticleTotalViewCount WHERE (RecordTypeId = :'recordTypeInternalId' OR RecordType.DeveloperName = :recordTypeDeveloperName) AND Rank_at_the_top__c = true AND Client_Service__c includes (:selectedClientService) AND language = 'en_US' ORDER BY SystemModStamp DESC LIMIT :MAX_RESULTS)];
                articlesNotRanked = [FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav (Id,Title,Summary,Article_Body__c,Rank_at_the_top__c, ArticleTotalViewCount WHERE (RecordTypeId = :'recordTypeInternalId' OR RecordType.DeveloperNAme = :recordTypeDeveloperName) AND Rank_at_the_top__c = false AND Client_Service__c includes (:selectedClientService) AND language = 'en_US' ORDER BY ArticleTotalViewCount DESC LIMIT :MAX_RESULTS)];
                searchResults.addAll(articlesNotRanked);
                system.debug('Returned search internal articles ===> ' +searchResults);
            } else{
                searchResults = [FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav (Id,Title,Summary,Article_Body__c,ArticleTotalViewCount WHERE language = 'en_US' ORDER BY ArticleTotalViewCount DESC LIMIT :MAX_RESULTS)];
            }
            // Found Articles respecting search criteria
            for(List<Knowledge__kav> knos: searchResults){
             foundArticles.addAll(knos);  
              system.debug('Size of found articles =>  ' +foundArticles.size());
            }
            if(foundArticles.size()>0){
               for(Knowledge__kav anArticle :  foundArticles){
                    for(String s: searchText.split(' ')){
                        if(anArticle.Title.containsIgnoreCase(s) && !matchedArticles.contains(anArticle)){ 
                            matchedArticles.add(anArticle);
                        }
                        if(String.isNotBlank(anArticle.Summary) && anArticle.Summary.containsIgnoreCase(s) && !matchedArticles.contains(anArticle)){
                            matchedArticles.add(anArticle);
                        }
                        if(String.isNotBlank(anArticle.Article_Body__c) && anArticle.Article_Body__c.containsIgnoreCase(s) && !matchedArticles.contains(anArticle)){
                            matchedArticles.add(anArticle);
                        }
                    }
                    system.debug('matchedArticles ==> '+matchedArticles);
            	}
            }
        }
        return matchedArticles;
    }
}