trigger Push_Notification_Item_AfterUpdate on Push_Notification_Item__c (after update) {

	IM_PushNotification_Config.afterInsertUpdatePnis(trigger.new, trigger.oldMap);
	
}