public with sharing class MIY_Emails  {

	@AuraEnabled
	public static List<EmailMessage> getEmails(Id recordId){
		string soql = 'Select Id, Subject, MessageDate, toLabel(Status), HasAttachment, Incoming From EmailMessage Where ';
		soql += (recordId.getSobjectType() == Case.SobjectType)?'parentId':'relatedToId';
		soql+= '=:recordId order by MessageDate Desc';
		return Database.query(soql);
	}

}