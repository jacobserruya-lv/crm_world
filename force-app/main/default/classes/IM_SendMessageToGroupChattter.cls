public with sharing class IM_SendMessageToGroupChattter {
	
	@InvocableMethod(label='Send Notifications to Groups' description='Send Message to chatter Groups')
      public static  void sendNotifcationsGroupInvocable(List<ChatterMessage> messageInformation) {
        String groupName = messageInformation[0].groupName;
        String message = messageInformation[0].message;
        sendNotifcationsGroup(groupName, message);
      }

      public static void sendNotifcationsGroup(String groupName, String message){
      	List<CollaborationGroup> cGroups  = [Select Id From CollaborationGroup Where Name LIKE : groupName];
      	if(cGroups.size()>0){
      		FeedItem post = new FeedItem();
	        post.Body = message;
	        post.ParentId = cGroups[0].Id;
	        insert post;
      	}

      }

       public class ChatterMessage{
        @InvocableVariable(label='groupName' required=true)
        public String groupName;

        @InvocableVariable(label='message' required=true)
        public String message;
      }
}