/********************************************************************************************************************************************/
/* Initiated by Imad ALS  07/19/2021 - Last modified 07/22/2021
######## It is a class of type scheduler to control the execution of the batch for the client purge
######## To start the process every hour with the anonymous console ===> System.schedule('LV purge accounts every hour', '0 0 * * * ?', new BatchAccountDeletionScheduler());

/********************************************************************************************************************************************/


global class BatchAccountDeletionScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        //Get custom Setting
        AccountDeletion__c setting = AccountDeletion__c.getInstance('Account Deletion Batch');  
        if(setting != null && String.isNotBlank(setting.job_Id__c)){
            System.debug('Start Schudler Class in IF');
            //Retrieve the status of the old job based on the job Id stored in the custom settings
            List<AsyncApexJob> aaj = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :setting.job_Id__c]; 
            if(aaj.Size()>0){
                if(aaj[0].Status == 'Completed' || aaj[0].Status == 'Failed'){
                    BatchAccountDeletion cl = new BatchAccountDeletion(0, 0);
                    Id batchInstanceId = Database.executeBatch(cl,200);  
                }else{
                    // Do nothing if the old job is running
                    System.debug('Process OFF  '+ aaj[0].Status);    
                }
            }else{
                BatchAccountDeletion cl = new BatchAccountDeletion(0, 0);
                Id batchInstanceId = Database.executeBatch(cl,200);  
            }     
        }else{
            System.debug('Start Schudler Class in else');
            // for First Execution
            BatchAccountDeletion cl = new BatchAccountDeletion(0, 0);
            Id batchInstanceId = Database.executeBatch(cl,200);  
        }   
    }
}