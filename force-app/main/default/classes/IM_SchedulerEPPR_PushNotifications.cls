global class IM_SchedulerEPPR_PushNotifications implements Schedulable {
	global void execute(SchedulableContext sc) {
		IM_BatchEPPR_PushNotifications bat = new IM_BatchEPPR_PushNotifications();	
        Database.executeBatch(bat,10);  
	}
}