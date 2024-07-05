public with sharing class SO_Template_EXT {
	//final static Integer MAX_MSG_SIZE = 50;

	//public SO_Template_EXT(SO_Template_CTRL templateCTRL) {

	//	SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
	//	if(orderPageSwitch.sfoUserRole != null)
	//	{
	//		msgContainer = new SO_MessageContainer();

	//		if(null != SO_Session.currentBriefId) {

	//			List<SPO_Message__c> msgList = retMessageByOppId(SO_Session.currentBriefId);
	//			msgContainer.msgList = retFilteredMessageList(SO_Session.theCurrentBrief, msgList);
	//		}
	//		else {
	//			msgContainer.msgList = new List<SPO_Message__c>();
	//		}
	//	}


	//}

	//public static List<SPO_Message__c> retFilteredMessageList(SObject brief, List<SPO_Message__c> messageList) {

	//	//List<SPO_Message__c> filteredMessageList = new List<SPO_Message__c>();

	//	//SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
	//	//String logicalUserRoleName = orderPageSwitch.sfoUserRoleByObject(brief).name();
	//	//String fieldTmpl = String.format('SPO_ReadBy{0}__c', new String[] { logicalUserRoleName });

	//	//for(Integer X = 0; X < messageList.size() ; X++) {

	//	//	SPO_Message__c oneMsg = messageList[X];
	//		/*
	//		if(UserInfo.getUserId() == oneMsg.createdById || 
	//			(SO_OrderPageSwitch.LogicalUserRoleEnum.Other.name() != logicalUserRoleName && 
	//			logicalUserRoleName != oneMsg.SPO_WritterRole__c) ) { //MY : REMOVE && false == (Boolean)oneMsg.get(fieldTmpl) -NEED TO SEE SEE ALSO!

	//			filteredMessageList.add(oneMsg);
	//		}*/
	//		//AEF: 26/01/2016 change for user in the role "other" 
	//	//	if(UserInfo.getUserId() == oneMsg.createdById 
	//	//	   || logicalUserRoleName != oneMsg.SPO_WritterRole__c) { 

	//	//		filteredMessageList.add(oneMsg);
	//	//	}
	//	//}

	//	//return filteredMessageList;
	//	return messageList;
	//}

	//public SO_MessageContainer msgContainer { get; set; }
	//public String theBriefId {

	//	get {
	//		return SO_Session.currentBriefId;
	//	}
	//}

	//@RemoteAction
	//public static Integer messageCounter() {
	//	SO_Notifications_CTRL notificationsHandler = new SO_Notifications_CTRL(false); 
	//	System.debug('messageCounter >> ' + notificationsHandler.globalMessageCounter);
	//	return notificationsHandler.globalMessageCounter;
	//}

	//@RemoteAction
	//public static Integer messageCounterByOppId(String briefId) {

	//	List<SPO_Message__c> resultMessageList = new List<SPO_Message__c>();
	//	try {

	//		if(String.isBlank(briefId)) return 0;

	//		ID oneBriefId = ID.valueOf(briefId);
	//		Opportunity brief = SO_Session.retOpportunityBy(oneBriefId);
	//		resultMessageList = retFilteredMessageList(brief, retMessageByOppId(oneBriefId));
	//	}
	//	catch(Exception exp){SO_UTIL.exceptionDump(exp);}

	//	return resultMessageList.size();

	//}

	//@RemoteAction
	//public static List<SO_Template_EXT.MessageWrapper> addMessage(String briefId, String msgText) {

	//	List<MessageWrapper> msgWrapperList = new List<MessageWrapper>();

	//	try {

	//		if(String.isBlank(briefId) || String.isBlank(msgText)) return msgWrapperList;

	//		ID oneBriefId = ID.valueOf(briefId);
	//		Opportunity brief = SO_Session.retOpportunityBy(oneBriefId);

	//		SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
	//		String logicalUserRoleName = orderPageSwitch.sfoUserRoleByObject(brief).name();

	//		SPO_Message__c newMessage = new SPO_Message__c();

	//		newMessage.SPO_BriefConcerned__c = oneBriefId;
	//		newMessage.SPO_Message__c 		 = msgText;
	//		newMessage.SPO_WritterRole__c 	 = logicalUserRoleName;

	//		//MY 2015/12/03
	//		String fieldTmpl = String.format('SPO_ReadBy{0}__c', new String[] { logicalUserRoleName });
	//		System.debug('fieldTmpl >> ' + fieldTmpl);
	//		newMessage.put(fieldTmpl, true);

	//		Database.insert(newMessage);

	//		List<SPO_Message__c> resultMessageList = retFilteredMessageList(brief, retMessageByOppId(oneBriefId));

	//		//MY 2015/12/03 
	//		//resultMessageList.add(newMessage);

	//		System.debug('resultMessageList.size >> ' + resultMessageList.size());			

	//		for(Integer X = 0; X < resultMessageList.size(); X++) {
	//			msgWrapperList.add(new MessageWrapper(resultMessageList[X],(Boolean)resultMessageList[X].get(fieldTmpl)));
	//		}
	//	}
	//	catch(Exception exp){SO_UTIL.exceptionDump(exp);}

	//	return msgWrapperList;
	//}


	//@RemoteAction
	//public static List<MessageWrapper> initMassagesFirstTime(String briefId) {

	//	List<MessageWrapper> msgWrapperList = new List<MessageWrapper>();
	//	try {

	//		ID oneBriefId = ID.valueOf(briefId);
	//		Opportunity brief = SO_Session.retOpportunityBy(oneBriefId);

	//		SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
	//		String logicalUserRoleName = orderPageSwitch.sfoUserRoleByObject(brief).name();

	//		//MY 2015/12/03
	//		String fieldTmpl = String.format('SPO_ReadBy{0}__c', new String[] { logicalUserRoleName });
	//		System.debug('fieldTmpl >> ' + fieldTmpl);

	//		List<SPO_Message__c> resultMessageList = retFilteredMessageList(brief, retMessageByOppId(oneBriefId));

	//		//MY 2015/12/03 
	//		//resultMessageList.add(newMessage);

	//		System.debug('resultMessageList.size >> ' + resultMessageList.size());			

	//		for(Integer X = 0; X < resultMessageList.size(); X++) {
	//			msgWrapperList.add(new MessageWrapper(resultMessageList[X],(Boolean)resultMessageList[X].get(fieldTmpl)));
	//		}
	//	}
	//	catch(Exception exp){SO_UTIL.exceptionDump(exp);}

	//	return msgWrapperList;

	//}

	//@RemoteAction
	//public static Boolean readMessage(String briefId) {

	//	List<MessageWrapper> msgWrapperList = new List<MessageWrapper>();
	//	Boolean ans = false;
	//	try {
			
	//		if(String.isBlank(briefId)) return ans;

	//		ID oneBriefId = ID.valueOf(briefId);
	//		Opportunity brief = SO_Session.retOpportunityBy(oneBriefId);

	//		SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
	//		String logicalUserRoleName = orderPageSwitch.sfoUserRoleByObject(brief).name();
	//		String fieldTmpl = String.format('SPO_ReadBy{0}__c', new String[] { logicalUserRoleName });

	//		System.debug('fieldTmpl >> ' + fieldTmpl);

	//		List<SPO_Message__c> resultMessageList = retFilteredMessageList(brief, retMessageByOppId(oneBriefId));

	//		if(resultMessageList.size() >= 3) 
	//		{
	//			for(Integer X = 0; X < resultMessageList.size(); X++) {
	//				resultMessageList[X].put(fieldTmpl, true);
	//			}

	//			Database.update(resultMessageList);
	//			ans = true;
	//		}
	//	}
	//	catch(Exception exp){SO_UTIL.exceptionDump(exp);}

	//	return ans;

	//}

	////MY 2015 12 02 
	//@RemoteAction
	//public static List<MessageWrapper> readMessageRetIdList(String briefId) {

	//	List<MessageWrapper> msgWrapperList = new List<MessageWrapper>();
	//	List<SPO_Message__c> readMsgIdList = new List<SPO_Message__c>();

	//	try {
			
	//		if(String.isBlank(briefId)) return msgWrapperList;

	//		ID oneBriefId = ID.valueOf(briefId);
	//		Opportunity brief = SO_Session.retOpportunityBy(oneBriefId);

	//		SO_OrderPageSwitch orderPageSwitch = new SO_OrderPageSwitch();
	//		String logicalUserRoleName = orderPageSwitch.sfoUserRoleByObject(brief).name();
	//		String fieldTmpl = String.format('SPO_ReadBy{0}__c', new String[] { logicalUserRoleName });


	//		System.debug('fieldTmpl >> ' + fieldTmpl);

	//		List<SPO_Message__c> resultMessageList = retFilteredMessageList(brief, retMessageByOppId(oneBriefId));
	//		System.debug('retMessageByOppId(oneBriefId) : :' + retMessageByOppId(oneBriefId));
	//		System.debug('resultMessageList : :+ ' + resultMessageList);
	//		//if(resultMessageList.size() < 3) {
	//		//	return readMsgIdList = ;
	//		//}

	//		for(Integer X = 0; X < resultMessageList.size(); X++) {
	//			resultMessageList[X].put(fieldTmpl, true);
	//			//MY USE IN THE NEW CONSTRACTOR
	//			msgWrapperList.add(new MessageWrapper(resultMessageList[X],(Boolean)resultMessageList[X].get(fieldTmpl)));
	//		}

	//		Database.update(resultMessageList);
	//	}
	//	catch(Exception exp){SO_UTIL.exceptionDump(exp);}

	//	return msgWrapperList;

	//}

	

	//public static List<SPO_Message__c> retMessageByOppId(ID oppId) {

	//	return
	//		[SELECT Id,
	//				Name,																// Title of message
	//				SPO_Message__c,														// Message text
	//				CreatedDate,														// Creation date
	//				CreatedById,														// Creation Id
	//				CreatedBy.Name,														// Creation Name
	//				SPO_BriefConcerned__c,												//(Opportunity row)
	//				SPO_ReadByStore__c, SPO_ReadByProduction__c, SPO_ReadByother__c,	// Read by bool vals
	//				SPO_WritterRole__c,													// picklist
	//				SystemModstamp
	//				//CreatedBy,	- error
	//	  	 FROM SPO_Message__c		// Object api
	//		 WHERE SPO_BriefConcerned__c =: oppId
	//	  	 ORDER BY CreatedDate ASC
	//	  	 LIMIT : MAX_MSG_SIZE];
	//}

	//public class MessageWrapper {

	//	String  theName 	  { get; set; }
	//	String  theText 	  { get; set; }
	//	String  theDate 	  { get; set; }
	//	String  theId 	      { get; set; }
	//	String  theRole       { get; set; }
	//	Boolean theIsRead     { get; set; } 

	//	public MessageWrapper(SPO_Message__c spoMessage) {

	//		//theName = spoMessage.Name;
	//		theName = spoMessage.CreatedBy.Name;
	//		theText = spoMessage.SPO_Message__c;
	//		theDate = spoMessage.CreatedDate != null ? spoMessage.CreatedDate.format() : null;
	//		theId   = spoMessage.Id;
	//		theRole = spoMessage.SPO_WritterRole__c;
	//	}

	//	public MessageWrapper(SPO_Message__c spoMessage , Boolean isRead) {

	//		//theName = spoMessage.Name;
	//		theName   = spoMessage.CreatedBy.Name;
	//		theText   = spoMessage.SPO_Message__c;
	//		theDate   = spoMessage.CreatedDate.format();
	//		theId     = spoMessage.Id;
	//		theRole   = spoMessage.SPO_WritterRole__c;
	//		theIsRead =  isRead;
	//	}
	//}

	//public Opportunity cancelOpportunity {
	//	get {
	//		if(null == cancelOpportunity)
	//		{
	//			Id briefId = SO_Session.currentBriefId;
	//			if(briefId != null)
	//			{
	//				List<Opportunity> oppList = [SELECT Id, StageName, OwnerId, SPO_StopBriefComment__c, SPO_StopBriefReason__c, SPO_ZoneApproverBriefOrderComment__c
	//						  					FROM Opportunity 
	//						  					WHERE Id = :briefId];

	//				if(!oppList.isEmpty())
	//				{
	//					cancelOpportunity = oppList[0];
	//				} 
	//			}
	//		}
	//		return cancelOpportunity;
	//	}
	//	private set;
	//}

	//public PageReference cancelBrief() {
	//	try
	//	{
	//		cancelOpportunity.StageName =
	//			(new SO_OrderPageSwitch().sfoUserRoleByObject(cancelOpportunity) == SO_OrderPageSwitch.LogicalUserRoleEnum.Production) ?
	//			'Cancelled by Production' : 'Cancelled by store';
	//		update cancelOpportunity;
	//	}
	//	catch(Exception e)
	//	{
	//		System.debug('SO_Template_EXT - cancelBrief - ERRRO: ' + e);
	//	}

	//	return null;
	//}

}