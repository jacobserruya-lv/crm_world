global class BatchFillingVOSurveyScheduler implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        
        BatchFillingVOSurvey bFSurvey = new BatchFillingVOSurvey();
        ID batchProcessId = Database.executebatch(bFSurvey, 25);
    }
}