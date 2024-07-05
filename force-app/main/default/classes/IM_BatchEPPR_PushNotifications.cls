global class IM_BatchEPPR_PushNotifications implements Database.Batchable<PPR_PurchProduct__c> {
	
	
	Datetime dateT;
	
	global IM_BatchEPPR_PushNotifications() {
		dateT = System.now() - 3;
	}
	
	global Iterable<PPR_PurchProduct__c> start(Database.BatchableContext BC) {
		List<PPR_PurchProduct__c> EPPRs = [SELECT Id, Client__r.OwnerId, CreatedDate, ConvertedAmountUSD__c,Amount__c,SA__c,Client__c,Client__r.Name
											FROM PPR_PurchProduct__c 
											WHERE CreatedDate > :dateT 
											AND ExceptionalPurchaseFlag__c=true AND ExceptionalPurchaseCA__c=true And TECH_PushNotified__c=false];
		return EPPRs;
	}

   	global void execute(Database.BatchableContext BC, List<PPR_PurchProduct__c> scope) {
		List<Push_Notification_Item__c>pushList=new List<Push_Notification_Item__c>();
		List<PPR_PurchProduct__c>eppsNotified=new List<PPR_PurchProduct__c>();
		Set<String> ownerIds = new Set<String>();
		for(PPR_PurchProduct__c ob : scope)
       {
            ownerIds.add(ob.Client__r.OwnerId);
       }
        Map<Id,User> userMap = new Map<ID, User>([SELECT Id, LanguageLocaleKey From User Where Id IN : ownerIds]);

		for (PPR_PurchProduct__c epp : scope){
            String placeholder= ((IM_Notifications__c.getInstance(userMap.get(epp.Client__r.OwnerId).LanguageLocaleKey))!=null?IM_Notifications__c.getInstance(userMap.get(epp.Client__r.OwnerId).LanguageLocaleKey).Exceptional_Purchase__c:IM_Notifications__c.getInstance('en_US').Exceptional_Purchase__c);
            List<String> fillers = new String[]{epp.Client__r.Name};

            Push_Notification_Item__c pushObj= new Push_Notification_Item__c();
            pushObj.Body__c=String.format(placeholder, fillers);
            pushObj.Type__c = 'ExceptionalProduct';
            pushObj.ObjectId__c = epp.Id;
            pushObj.UserRecipient__c = (Id)epp.Client__r.OwnerId;
            pushList.add(pushObj);
            epp.TECH_PushNotified__c= true;
            eppsNotified.add(epp);
		}
		if(pushList.size()>0){
			insert pushList;
			update eppsNotified;
		}
		

	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}