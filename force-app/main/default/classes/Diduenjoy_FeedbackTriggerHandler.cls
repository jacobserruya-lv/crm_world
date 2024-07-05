/**
    @Author : ouramdane.aouci
    Desc :    event handler on the due__Diduenjoy_Feedback Object
    V 1.0 :   08/06/2023
*/
public class Diduenjoy_FeedbackTriggerHandler {
    
    //Update some synchronized Voice fields when updated in Due_Feedback
    public static void afterUpdate(List<due__Diduenjoy_Feedback__c> newList, Map<Id, due__Diduenjoy_Feedback__c> oldMap){
        
        System.debug('newList Size: '+newList.size());
        //Collect only the records concerned by the treatment
        Map<String, due__Diduenjoy_Feedback__c> dueFeedbackMap = new Map<String, due__Diduenjoy_Feedback__c>();
        
        for(due__Diduenjoy_Feedback__c dueFeedback : newList){
            if(dueFeedback.due__Status__c != oldMap.get(dueFeedback.Id).due__Status__c 
               || dueFeedback.due__Solved__c != oldMap.get(dueFeedback.Id).due__Solved__c 
               || dueFeedback.due__Last_Resolution_Date__c != oldMap.get(dueFeedback.Id).due__Last_Resolution_Date__c){
                   //Include this record
                   dueFeedbackMap.put(dueFeedback.due__InternalId__c, dueFeedback);
               }
        }
        
        if(dueFeedbackMap.size() > 0){
            //Retrieve Matching Surveys
            List<VO_Survey__c> surveysToUpdateList = [SELECT Id, Status__c, Solved__c, LastResolutionDate__c, FeedbackID__c FROM VO_Survey__c WHERE FeedbackID__c IN :dueFeedbackMap.keySet()];
            
            if(surveysToUpdateList.size() > 0){
                System.debug('surveysToUpdateList Size: '+surveysToUpdateList.size());
                due__Diduenjoy_Feedback__c dueF;    
                
                for(VO_Survey__c survey : surveysToUpdateList){
                    if(dueFeedbackMap.containsKey(survey.FeedbackID__c)){
                        dueF = dueFeedbackMap.get(survey.FeedbackID__c);
                        if(survey.Status__c != dueF.due__Status__c){
                            survey.Status__c = dueF.due__Status__c;
                        }
                        if(survey.Solved__c != dueF.due__Solved__c){
                            survey.Solved__c = dueF.due__Solved__c;
                        }
                        if(survey.LastResolutionDate__c != dueF.due__Last_Resolution_Date__c){
                            survey.LastResolutionDate__c = dueF.due__Last_Resolution_Date__c;
                        }
                    }
                }
                
                UPDATE surveysToUpdateList;
            }
        }
    }
}