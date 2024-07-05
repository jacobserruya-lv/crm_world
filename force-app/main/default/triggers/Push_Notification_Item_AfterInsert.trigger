trigger Push_Notification_Item_AfterInsert on Push_Notification_Item__c (after insert) {

	BL_ICON_PushNotification_Config.PushAtferInsertHandler(trigger.new);
	
	IM_PushNotification_Config.afterInsertUpdatePnis(trigger.new, null);
}