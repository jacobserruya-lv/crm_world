/*
CreatedDate: Januar 2018
Company: Balink
Author: Jeremy Martiano
Description: Interface Web Sevice to Sync Push Notifications
*/

@RestResource(urlMapping='/CheckPushNotifications')
global with sharing class IM_CheckPushNotifications {
	
	
	/*=================================================================================================================*/

	@HttpPost
	global static ResponseHandler CheckPushNotifications() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		ResponseHandler response = new ResponseHandler();
		res.addHeader('Content-Type','application/json');
		Map<String,Object> body = new Map<String,Object>();
		if ( req.requestBody != null ){
			body = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
		}
		try{
			List<Push_Notification_Item__c> notifRemoved = RemoveNotifications((String)body.get('notificationIdsToDelete'));
			CheckPushNotificationsToPush((String)body.get('notificationIdsToCheck'),notifRemoved);
			updateRead((String)body.get('notificationsRead'));
			res.statusCode= 200;
			response.Status = 'Success';
			//UtilsLogs.addLog('ICON', 'IM_CheckPushNotifications',JSON.serialize(req.params), JSON.serialize(req), response.Status, '');

			new Logs.DEBUG('IM_CheckPushNotifications','API',response.Status);
			return response;
        		

		}catch(Exception e) {
			string error = e.getMessage() + '\n\n' + e.getLineNumber();
			response.Status = 'Error:' + error;
            res.statusCode = 400;
           // UtilsLogs.addLog('ICON','IM_CheckPushNotifications', JSON.serialize(req.params), JSON.serialize(req),'', error);
            new Logs.ERROR('IM_CheckPushNotifications','API',e);
            return response;
        }
	        
    }

	/*=================================================================================================================*/
	 global static void updateRead(String notificationsRead){
		if (notificationsRead != null){
			List<String> pushIds = notificationsRead.split(';');
			if ( pushIds != null && pushIds.size() > 0 ){
				List<Push_Notification_Item__c> toUpdate = [SELECT Id, isRead__c FROM Push_Notification_Item__c Where ID IN : pushIds AND isRead__c = false];
				for(Push_Notification_Item__c push : toUpdate){
					push.isRead__c = true;
				}
				if(toUpdate.size() > 0){
					update toUpdate;
				}
			}
		}
    }

    /*=================================================================================================================*/
    public static List<Push_Notification_Item__c> RemoveNotifications(String notificationIdsToDelete){
		List<Push_Notification_Item__c>  listToReturn = new List<Push_Notification_Item__c>();

		if (notificationIdsToDelete != null) {
			Set<String> iosNotificationIdsList = new Set<String>(notificationIdsToDelete.split(';'));
			List<Push_Notification_Item__c> sfNotificationsToRemove = [
				SELECT Id, UsersIds__c, UserRecipient__c
				FROM Push_Notification_Item__c 
				WHERE Id IN :iosNotificationIdsList
			];

			if(sfNotificationsToRemove.size() > 0) {
				Set<Push_Notification_Item__c> pushToDelete = new Set<Push_Notification_Item__c>();
				Set<Push_Notification_Item__c> pushToUpdate = new Set<Push_Notification_Item__c>();

				for(Push_Notification_Item__c pni: sfNotificationsToRemove) {
					if(pni.UserRecipient__c == null) {
						pni.UsersIds__c = pni.UsersIds__c.remove(UserInfo.getUserId()+';');
						pushToUpdate.add(pni);
					} else {
						pushToDelete.add(pni);
					}				
				}

				if(pushToDelete.size() > 0) {
					delete new List<Push_Notification_Item__c>(pushToDelete);
				}
				if(pushToUpdate.size() > 0) {
					update new List<Push_Notification_Item__c>(pushToUpdate);
				}
				listToReturn.addAll(pushToUpdate);
				listToReturn.addAll(pushToDelete);
			}
		}
    	
		return listToReturn;
    }

    /*=================================================================================================================*/

    public static Void CheckPushNotificationsToPush(String notificationIdsToCheck,List<Push_Notification_Item__c> notificationRemoved) {
    	List<List<sObject>> searchList = new List<List<sObject>>();
    	List<List<sObject>> searchList2 = new List<List<sObject>>();
		List<String>parentIosNotifications = new List<String>();
		List<String> iosNotificationIdsList = new List<String>();

		if ( notificationIdsToCheck != null ){
			iosNotificationIdsList =notificationIdsToCheck.split(';');
			List<Push_Notification_Item__c>iosNotificationsWithParent = [
				SELECT id,Parent_Push__c 
				FROM Push_Notification_Item__c 
				WHERE Parent_Push__c != null AND (Id IN :iosNotificationIdsList OR Id IN :notificationRemoved)
			];
			
			for(Push_Notification_Item__c pni : iosNotificationsWithParent) { 
				parentIosNotifications.add(pni.Parent_Push__c);
			}
		}

		Datetime dateT = System.now().addDays(-15);

		//SOQL for uniques
		Push_Notification_Item__c[] sfNotficationsSingles = [
			SELECT Id,UsersIds__c,Title__c,Body__c,Type__c,ObjectId__c, Need_To_Be_Send__c,Last_Send_Date__c,Parent_Push__c,UserRecipient__c
			FROM Push_Notification_Item__c 
			WHERE Id NOT IN :iosNotificationIdsList  AND
				Id NOT IN :notificationRemoved AND
				isRead__c = FALSE AND
				UserRecipient__c = :UserInfo.getUserId() AND CreatedDate >= :dateT AND Is_Silent_Push__c = FALSE
			ORDER BY Last_Send_Date__c DESC
		];

		 if (sfNotficationsSingles.size() > 0) {
		 	Set<Push_Notification_Item__c> newPushs = new Set<Push_Notification_Item__c>();
    		for(Push_Notification_Item__c pni :sfNotficationsSingles) {
    			pni.Need_To_Be_Send__c = true;
				pni.Last_Send_Date__c = datetime.now();
				newPushs.add(pni);
				if(pni.Parent_Push__c != null) {
					parentIosNotifications.add(pni.Parent_Push__c);
				}
    		}
    		if(newPushs.size() > 0) {
				upsert new List<Push_Notification_Item__c>(newPushs);
			}
		 }
    		 

		 //SOSL for Groups
		String userId = '*'+UserInfo.getUserId()+'*';
		searchList = [
			FIND :userId  IN ALL FIELDS RETURNING 
			Push_Notification_Item__c(Id,UsersIds__c,Title__c,Body__c,Type__c,ObjectId__c,UserRecipient__c,
			Need_To_Be_Send__c,Last_Send_Date__c,Parent_Push__c
			Where Id NOT IN :iosNotificationIdsList  AND
			Id NOT IN :parentIosNotifications AND
			ID NOT IN : notificationRemoved AND
			isRead__c = false AND
			(UserRecipient__c = null OR UserRecipient__c = '')
			AND CreatedDate >= :dateT
			AND Is_Silent_Push__c = false
			Order By Last_Send_Date__c desc)];

		if(searchList.size()>0){		
			Push_Notification_Item__c[] sfNotficationsGroup =(Push_Notification_Item__c [])searchList[0];
			if(sfNotficationsGroup.size()>0){

            	Set<Push_Notification_Item__c>newPushs = new Set<Push_Notification_Item__c>();
    				for(Push_Notification_Item__c pni :sfNotficationsGroup){
    					if(pni.UsersIds__c.split(';').size()>0){
    						Push_Notification_Item__c newPush = 
    						new Push_Notification_Item__c(
    							Title__c = pni.Title__c,
    							Body__c = pni.Body__c,
    							Type__c = pni.Type__c,
    							ObjectId__c= pni.ObjectId__c,
    							UserRecipient__c = UserInfo.getUserId(),
    							Last_Send_Date__c=datetime.now(),
    							Parent_Push__c=pni.Id
    							);
    						newPushs.add(newPush);
    						pni.UsersIds__c = pni.UsersIds__c.remove(UserInfo.getUserId()+';');
    						newPushs.add(pni);
    					}
    				}
    				if(newPushs.size()>0){
    					upsert new List<Push_Notification_Item__c>(newPushs);
    				}

    		}
    	}
    }

    /*=================================================================================================================*/


//Custom Response Object
	global class ResponseHandler {
	    public String Status {get; set;}  
	}
		
}