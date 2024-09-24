/**
    @Author : 	ouramdane.aouci
    Desc 	:   scheduler of the batch CF_BatchFlagAccountNotSyncWithSFMC
    V 1.0 	:   10/04/2024
*/
global class CF_SchedulerFlagAccountNotSyncWithSFMC implements Schedulable{
	
    global void execute(SchedulableContext sc) {
        CF_BatchFlagAccountNotSyncWithSFMC batchFlagAccount = new CF_BatchFlagAccountNotSyncWithSFMC();
        ID batchProcessId = Database.executebatch(batchFlagAccount);
    }
}