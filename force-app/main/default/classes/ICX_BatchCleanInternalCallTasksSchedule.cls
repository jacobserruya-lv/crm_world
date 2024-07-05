global class  ICX_BatchCleanInternalCallTasksSchedule implements Schedulable{
global void execute(SchedulableContext SC) {

        ICX_BatchCleanInternalCallTasks batch = new ICX_BatchCleanInternalCallTasks();
    	Database.executeBatch(batch, 200);
       
    }
}