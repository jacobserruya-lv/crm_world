@isTest
private class IM_CheckNotificationItems_TEST {
  
  @isTest static void FeedItemAfterInsert() {
  	Push_Notification_Item__c pni  =new Push_Notification_Item__c(UsersIds__c = UserInfo.getUserId()+';',
  		Title__c='test',
  		Need_To_Be_Send__c=false);
  		insert pni;
		pni.isRead__c = false;
    	pni.Need_To_Be_Send__c = true;
    	update pni;

		Push_Notification_Item__c pni2  =new Push_Notification_Item__c(UsersIds__c = UserInfo.getUserId()+';',
  		Title__c='test2',
  		Need_To_Be_Send__c=false);
  		insert pni2;
    	pni2.Need_To_Be_Send__c = true;
		pni2.isRead__c = false;
		pni2.UserRecipient__c = UserInfo.getUserId();
		pni2.Is_Silent_Push__c = false;
    	update pni2;

		Push_Notification_Item__c pni3  =new Push_Notification_Item__c(UsersIds__c = UserInfo.getUserId()+';',
  		Title__c='test3',
		CreatedDate = System.now().addDays(-15),
  		Need_To_Be_Send__c=false);
  		insert pni3;
    	pni3.Need_To_Be_Send__c = true;
		pni3.isRead__c = false;
		pni3.UserRecipient__c = null;
		pni3.Is_Silent_Push__c = false;
    	update pni3;

		System.debug('TTTTTTTTTTTTTT pni3: '+ pni3);

		List<Push_Notification_Item__c> push = new List<Push_Notification_Item__c>();
		push.add(pni);
		push.add(pni2);
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CheckPushNotifications/';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Map<String,Object> body = new Map<String,Object>();
		body.put('notificationsRead', 'Test');
		body.put('notificationIdsToDelete', pni.Id);
		IM_CheckPushNotifications.CheckPushNotifications();
		IM_CheckPushNotifications.updateRead((String)body.get('notificationsRead'));
		IM_CheckPushNotifications.RemoveNotifications((String)body.get('notificationIdsToDelete'));
		IM_CheckPushNotifications.CheckPushNotificationsToPush(pni2.Id, push);
		IM_CheckPushNotifications.CheckPushNotificationsToPush(pni2.Id, push);
	}
}