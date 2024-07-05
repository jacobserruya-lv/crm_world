/**
	@Author : ouramdane.aouci
    Desc :    New Batch version since April 2023. 
			  Process only the due_feedback records (without the due_answers records) 
    V 2.0 :   01/04/2023
	Update:   20/10/2023 (creation & mapping of new fields for new feedback types)
	Update:   28/02/2024 (Add & manage new field named 'AdvisorCSRole__c' - SV-308)
*/
global class BatchFillingVOSurvey implements Database.Batchable<sObject> {
    
    private String myQuery;
    //Ensure that all feedbacks in progress will all be inserted
    private DateTime currentTime = System.now().addMinutes(-5); //Leave 5 minutes of margin
    
    global BatchFillingVOSurvey(){
        myQuery = 'SELECT Id, due__CreatedAt__c, CreatedById, due__Segments__c, due__Comment__c, due__InternalId__c, '
            + 'due__Status__c, due__Solved__c, due__Last_Resolution_Date__c, Treated__c '
            + 'FROM due__Diduenjoy_Feedback__c WHERE Treated__c = false AND due__CreatedAt__c <= :currentTime'; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(myQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<due__Diduenjoy_Feedback__c> scope){
        
        //Prepare the VO_Survey list to insert
        List<VO_Survey__c> voSurveyList = new List<VO_Survey__c>();
        Map<String, String> segmentsMap = new Map<String, String>();
        
        //Process each Due_Feedback line (current Batch of records)
        for(due__Diduenjoy_Feedback__c dueFeedback : scope){
            try{
                //Prepare the VO_Survey Object and fill it with the Due_Feedback
                VO_Survey__c vOSurvey = new VO_Survey__c();
                
                String segmentsTxt = dueFeedback.due__Segments__c;
                if(String.isBlank(segmentsTxt)){
                    System.debug('Error, empty due__Segments__c. DueFeedback : ' + dueFeedback.Id);
                    dueFeedback.Treated__c = true; 
                    continue;
                }
                
                //Put the text Field <due__Segments__c> content in a Map
                List<string> segmentsList = segmentsTxt.split('\n');
                segmentsMap.clear();
                for(String part: segmentsList){
                    List<String> subparts = part.split(':', 2);
                    segmentsMap.put(subparts[0].trim(), subparts[1].trim());                          
                }
                
                //Check the Data integrity
                if(checkDataIntegrity(segmentsMap) == false || dueFeedback.due__InternalId__c == null) {
                    System.debug('Missing or empty expected parameters. DueFeedback : ' + dueFeedback.Id + ' | due__InternalId__c: ' + dueFeedback.due__InternalId__c + ' | ' + segmentsTxt);
                    dueFeedback.Treated__c = true; 
                    continue;
                }
                
                //Fill in the fields according to the Survey Type
                if(segmentsMap.get('survey_submitted') == 'yes'){
                    vOSurvey.SurveyType__c = segmentsMap.get('survey-name');
                    
                    if(vOSurvey.SurveyType__c == 'Retail Post Purchase'){
                        vOSurvey.IDTransaction__c = segmentsMap.get('transaction_id');
                        vOSurvey.StoreID__c = segmentsMap.containsKey('store_code') ? segmentsMap.get('store_code') : '';
                        
                    } else if(vOSurvey.SurveyType__c == 'CSC Post Contact'){
                        vOSurvey.Task__c = segmentsMap.get('task_id');
                    
                    } else if(vOSurvey.SurveyType__c == 'Online Post Delivery'){
                        vOSurvey.RequestID__c = segmentsMap.get('request_id');
                        vOSurvey.OrderID__c = segmentsMap.containsKey('order_id') ? segmentsMap.get('order_id') : '';
                        vOSurvey.StoreID__c = segmentsMap.containsKey('website_id') ? segmentsMap.get('website_id') : '';
                    
                    } else if(vOSurvey.SurveyType__c == 'Retail Care Service'){
                        vOSurvey.RepairID__c = segmentsMap.get('repair_id');
                        vOSurvey.StoreID__c = segmentsMap.containsKey('store_code') ? segmentsMap.get('store_code') : '';
                        
                    } else {
                        System.debug('Feedback not concerned by the new Batch: ' + dueFeedback.Id);
                        dueFeedback.Treated__c = true; 
                        continue;
                    }
                } else {
                    //Feedback not submitted, so no sync with VO_Survey
                    System.debug('Feedback not submitted: ' + dueFeedback.Id);
                    dueFeedback.Treated__c = true; 
                    continue;
                }
				
                //Common fields for all surveys
                vOSurvey.Answer_DateTime__c = dueFeedback.due__CreatedAt__c;
                vOSurvey.CreatedById = dueFeedback.CreatedById;
                vOSurvey.SurveyComment__c = dueFeedback.due__Comment__c;
                vOSurvey.Status__c = dueFeedback.due__Status__c;
                vOSurvey.Solved__c = dueFeedback.due__Solved__c;
                vOSurvey.LastResolutionDate__c = dueFeedback.due__Last_Resolution_Date__c;
                
                vOSurvey.DreamIDText__c = segmentsMap.get('client_dream_id');
				vOSurvey.FeedbackID__c = dueFeedback.due__InternalId__c;
				
				vOSurvey.AdvisorWWId__c = segmentsMap.containsKey('advisor_ww_id') ? segmentsMap.get('advisor_ww_id') : '';
				vOSurvey.RespondentProfile__c = segmentsMap.containsKey('respondent_profile') ? segmentsMap.get('respondent_profile') : '';
                vOSurvey.AdvisorCSRole__c = segmentsMap.containsKey('advisor_cs_role') ? segmentsMap.get('advisor_cs_role') : '';
                
                //Unique Key
                //vOSurvey.Tech_Unique_Key__c = vOSurvey.DreamIDText__c + vOSurvey.StoreID__c + vOSurvey.IDTransaction__c + vOSurvey.CountryCode__c; //Old value
                vOSurvey.Tech_Unique_Key__c = vOSurvey.DreamIDText__c + vOSurvey.FeedbackID__c; //New value

                voSurveyList.add(vOSurvey);
                //Treated : Added Field to control the Batch processing (to know if the Feedback is treated or not)
                dueFeedback.Treated__c = true;    
                
            } catch (Exception e) {
                //If exception, this feedback record will be ignored. It will not block the treatment of others
                dueFeedback.Treated__c = true;
                System.debug('####-> ' + e.getTypeName() + '. Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
            }
        }
        
        UPDATE scope;
        
        if(voSurveyList.size() > 0){
            //INSERT voSurveyList;
            Database.SaveResult[] srList = Database.insert(voSurveyList, false); //Default param = true (allorNone)
            
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    //Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {  
                        System.debug(err.getStatusCode() + ' => ' + err.getMessage());
                        System.debug('Survey fields that affected this error: ' + err.getFields());
                        System.debug('----------------------------------------------------------');
                    }
                }
            } 
        }
        
    }
    
    //Check Due_Feedback data integrity 
    private Boolean checkDataIntegrity(Map<String, String> segMap){
        
        //Some fields are required
        if(!segMap.containsKey('survey-name') || String.isBlank(segMap.get('survey-name')) 
           || !segMap.containsKey('client_dream_id') || String.isBlank(segMap.get('client_dream_id'))
           || !segMap.containsKey('survey_submitted') || String.isBlank(segMap.get('survey_submitted'))){
               return false;
           }
        
        if(segMap.get('survey-name') == 'Retail Post Purchase' && (!segMap.containsKey('transaction_id') || String.isBlank(segMap.get('transaction_id')))){
            return false;
            
        } else if(segMap.get('survey-name') == 'CSC Post Contact' && (!segMap.containsKey('task_id') || String.isBlank(segMap.get('task_id')))){
            return false;
            
        } else if(segMap.get('survey-name') == 'Online Post Delivery' && (!segMap.containsKey('request_id') || String.isBlank(segMap.get('request_id')))){
            return false;
            
        } else if(segMap.get('survey-name') == 'Retail Care Service' && (!segMap.containsKey('repair_id') || String.isBlank(segMap.get('repair_id')))){
            return false;
        }
        
        return true;
    }
    
    global void finish(Database.BatchableContext bc){}
}