global class IM_SchedulerDeleteOldPush implements Schedulable {
	global void execute(SchedulableContext sc) {
		IM_BatchDeleteOldPushNotificationItems bat = new IM_BatchDeleteOldPushNotificationItems();	
        Database.executeBatch(bat,5000);  
	}
}