global without sharing class UtilsLogs{

    public static void addLog(string fromApp,string className, string params, string request, string response, string error){
        try{
            List<LogsSetting__mdt> logsSettings = [Select Id, QualifiedApiName, To_Log__c From LogsSetting__mdt Where QualifiedApiName = :className AND To_Log__c = true];
            List<User> users = [Select Id, Is_Tracked_Logs__c From User Where Id = : UserInfo.getUserId() AND Is_Tracked_Logs__c = true];
            if(logsSettings.size()>0 && users.size()> 0){
            
                
                Logs__c myLog = new Logs__c();
            
                myLog.User__c = UserInfo.getUserId();
                myLog.From__c = fromApp;
                myLog.Params__c = params;
                myLog.Request__c = request;
                myLog.Response__c = response;
                myLog.Error__c = error;
                myLog.ClassName__c = className;
                
                insert  myLog;
            }
           
        } catch (Exception e){
            UtilsLogs.addLog(fromApp, className, '', '','', 'ERROR INSERT LOGS');
        }
        
        
    }
}