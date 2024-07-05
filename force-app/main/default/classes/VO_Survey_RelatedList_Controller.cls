/**
     * Controller of the VO_Survey_RelatedList component.
     * @createdBy   RMOU, 10/03/2017
     */

public with sharing class VO_Survey_RelatedList_Controller {

	public VO_Survey_RelatedList_Controller() {
		
	}

	// Returns the list of related surveys
	@AuraEnabled
	public static List<VO_Survey__c> getSurveys (Id accountId){
		return [SELECT id, Name, SurveyType__c, AnswerDate__c, Type__c FROM VO_Survey__c WHERE ClientDreamID__c=:accountId];
	}
}