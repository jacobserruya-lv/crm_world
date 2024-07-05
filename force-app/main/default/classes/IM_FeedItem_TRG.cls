public with sharing class IM_FeedItem_TRG {
    /*=================================================================================================================*/ 
	public static void send(List<FeedItem> feedItems){
        List<Push_Notification_Item__c>pushList=new List<Push_Notification_Item__c>();
		for(FeedItem feed: feedItems) {
	        ConnectApi.FeedItem elem = (ConnectApi.FeedItem) ConnectApi.ChatterFeeds.getFeedElement(null, feed.Id);
	        pushList.addAll(buildUserMsgMap(elem)) ;
	    }
	    if(pushList.size()>0)
	    	insert pushList;
	}

    /*=================================================================================================================*/ 
	private static List<Push_Notification_Item__c> buildUserMsgMap(ConnectApi.FeedItem feed) {
			List<Push_Notification_Item__c>pushList=new List<Push_Notification_Item__c>();
	        Set<String> users = new Set<String>();
	        Set<String> groups = new Set<String>();
	        
	        // set mention users and groups
	        List<ConnectApi.MessageSegment> messageSegments = feed.body.messageSegments;

	        for (ConnectApi.MessageSegment ms : messageSegments) {
	            if (ms.type.name() == 'Mention') {

	                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) ms;

	                if (mentionSegment.record.type == 'User') {
	                    users.add(mentionSegment.record.id);
	                } 
	                else if (mentionSegment.record.type == 'CollaborationGroup') {
	                	groups.add(mentionSegment.record.id);

	                }
	            }
	        }
	        if(users.size()>0){
	        	pushList.add(buildNotification(feed,users));
	        }
	        
	        // get parent group if exist;
	        if(groups.size() == 0 && users.size() == 0  && feed.parent.type == 'CollaborationGroup') {
	        	groups.add(feed.parent.id);
	        }

	         //get all users from all groups (mention and parent)
	        if(groups.size() > 0){
	            List<CollaborationGroupMember> cgmList = [SELECT Id, MemberId,CollaborationGroupId FROM CollaborationGroupMember WHERE CollaborationGroupId IN : groups];
	            Map<String,Set<String>> chatterGroupMap = new Map<String,Set<String>>();

	            for(CollaborationGroupMember cgm: cgmList) {
	            	
	            	if(chatterGroupMap.get(cgm.CollaborationGroupId) == null){
	            		chatterGroupMap.put(cgm.CollaborationGroupId,new Set<String>());
	            	}
	                chatterGroupMap.get(cgm.CollaborationGroupId).add(cgm.MemberId);
	            }

	            for(String groupId : chatterGroupMap.keySet()){
	            	pushList.add(buildNotification(feed,chatterGroupMap.get(groupId)));
	            }
	        }

	        return pushList;
	} 

    /*=================================================================================================================*/ 
	public static Push_Notification_Item__c buildNotification(ConnectApi.FeedItem feed, Set<String> users) {
	        Push_Notification_Item__c pushObj = new Push_Notification_Item__c();
	        String msgContent = '';

	        // set content
	        List<ConnectApi.MessageSegment> messageSegments = feed.body.messageSegments;

	        for (ConnectApi.MessageSegment ms : messageSegments) {
	            if (ms.type.name() == 'Text') {
	                msgContent += ms.text.trim();
	            }
	        }
        String currentUserId = UserInfo.getUserId();
			User user = [SELECT Id, LanguageLocaleKey From User Where Id  =: currentUserId];
			String placeholder= ((IM_Notifications__c.getInstance(user.LanguageLocaleKey))!=null ? IM_Notifications__c.getInstance(user.LanguageLocaleKey).Feed__c :  IM_Notifications__c.getInstance('en_US').Feed__c);
			String orderNumber = [SELECT Id, OrderNumber__c FROM Opportunity where Id =: feed.parent.id LIMIT 1 ]?.OrderNumber__c;
			List<String> filler = new String[]{orderNumber};
           

	        //pushObject
	        //pushObj.Body__c =  msgContent;
			pushObj.Body__c = String.isNotEmpty(orderNumber) ? String.format(placeholder, filler) : 'N/A';
	        pushObj.Title__c = feed.actor.name;
	        pushObj.Type__c = 'Feed';
	        pushObj.ObjectId__c = feed.Id;
	        pushObj.UsersIds__c = '';

			Id parentId = feed.parent.id;
			String sobType = parentId.getSObjectType().getDescribe().getName();

			List<IM_NotificationsMaps__c> objectTypesList = IM_NotificationsMaps__c.getall().values();

			for(IM_NotificationsMaps__c objTypes :objectTypesList){
				if(!test.isRunningTest() ? objTypes.ObjectName__c!= null && objTypes.ObjectName__c == sobType : true){
					pushObj.Type__c = objTypes.Name;
			        pushObj.ObjectId__c = parentId;
				}
			}

			for(String uId : users){
				if(users.size()>1){
					pushObj.UsersIds__c += uId+';';
				} else{
					pushObj.UserRecipient__c = (Id) uId;
				}
			}

        return pushObj;
    }
}