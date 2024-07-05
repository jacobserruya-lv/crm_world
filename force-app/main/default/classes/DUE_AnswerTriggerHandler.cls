public class DUE_AnswerTriggerHandler {

    public static void afterInsert(List<due__Diduenjoy_Answer__c> newAnswers){

        Map<Id, Decimal> scorestoUpdate = new Map<Id, Decimal>();
        Map<String, Decimal> scoresByInternalid = new Map<String, Decimal>();
       

        for(due__Diduenjoy_Answer__c answer : [SELECT Id, due__Diduenjoy_Feedback__c, due__Diduenjoy_Feedback__r.Name, due__Score__c, due__Position__c, due__Step__c FROM due__Diduenjoy_Answer__c WHERE Id IN:newAnswers]){
            if((answer.due__Diduenjoy_Feedback__r.Name.contains('CSC Post Contact') && answer.due__Step__c == 1 && answer.due__Position__c == 0) || (answer.due__Diduenjoy_Feedback__r.Name.contains('Retail Post Purchase') && answer.due__Step__c == 0 && answer.due__Position__c == 0)){
                scorestoUpdate.put(answer.due__Diduenjoy_Feedback__c, answer.due__Score__c);
            }
        }

        List<due__Diduenjoy_Feedback__c> feedbacks = [SELECT id, due__InternalId__c FROM due__Diduenjoy_Feedback__c WHERE id IN: scorestoUpdate.keySet()]; 
        for(due__Diduenjoy_Feedback__c feedback : feedbacks){
            scoresByInternalid.put(feedback.due__InternalId__c, scorestoUpdate.get(feedback.Id));
        }

        List<VO_Survey__c> surveys = [SELECT Id, GlobalScore__c, FeedbackID__c FROM VO_Survey__c WHERE FeedbackID__c IN: scoresByInternalid.keySet()];
        for(VO_Survey__c survey : surveys){
            survey.GlobalScore__c = scoresByInternalid.get(survey.FeedbackID__c);
        }

        if (!surveys.isEmpty()){
            update surveys;
        }
    }
    public static void afterUpdate(List<due__Diduenjoy_Answer__c> newAnswers, Map<id,due__Diduenjoy_Answer__c> oldMap){

        Map<Id, Decimal> scorestoUpdate = new Map<Id, Decimal>();
        Map<String, Decimal> scoresByInternalid = new Map<String, Decimal>();
       

        for(due__Diduenjoy_Answer__c answer : [SELECT Id, due__Diduenjoy_Feedback__c, due__Diduenjoy_Feedback__r.Name, due__Score__c, due__Position__c, due__Step__c FROM due__Diduenjoy_Answer__c WHERE Id IN:newAnswers]){
            if((answer.due__Diduenjoy_Feedback__r.Name.contains('CSC Post Contact') && answer.due__Step__c == 1 && answer.due__Position__c == 0 && answer.due__Score__c != oldMap.get(answer.Id).due__Score__c) || (answer.due__Diduenjoy_Feedback__r.Name.contains('Retail Post Purchase') && answer.due__Step__c == 0 && answer.due__Position__c == 0 && answer.due__Score__c != oldMap.get(answer.Id).due__Score__c)){
                scorestoUpdate.put(answer.due__Diduenjoy_Feedback__c, answer.due__Score__c);
            }
        }

        List<due__Diduenjoy_Feedback__c> feedbacks = [SELECT id, due__InternalId__c FROM due__Diduenjoy_Feedback__c WHERE id IN: scorestoUpdate.keySet()]; 
        for(due__Diduenjoy_Feedback__c feedback : feedbacks){
            scoresByInternalid.put(feedback.due__InternalId__c, scorestoUpdate.get(feedback.Id));
        }

        List<VO_Survey__c> surveys = [SELECT Id, GlobalScore__c, FeedbackID__c FROM VO_Survey__c WHERE FeedbackID__c IN: scoresByInternalid.keySet()];
        for(VO_Survey__c survey : surveys){
            survey.GlobalScore__c = scoresByInternalid.get(survey.FeedbackID__c);
        }

        if (!surveys.isEmpty()){
            update surveys;
        }
    }
}