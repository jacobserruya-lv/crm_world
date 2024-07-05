/**
    @Author : 	ouramdane.aouci
    Desc 	:   scheduler of the batch TR_BatchC360DataCatchUp
    V 1.0 	:   27/09/2023
*/
global class TR_SchedulerC360DataCatchUp implements Schedulable{

    global void execute(SchedulableContext sc) {
        
        TR_BatchC360DataCatchUp batchDataCatchUp = new TR_BatchC360DataCatchUp();
        ID batchProcessId = Database.executebatch(batchDataCatchUp);
    }
}