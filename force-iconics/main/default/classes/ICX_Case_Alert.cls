public without sharing class ICX_Case_Alert {

    @AuraEnabled
    public static Case getCase(Id recordId) {
        if (String.isNotBlank(recordId) && Schema.sObjectType.Case.isAccessible()) {
            try {
                return [SELECT High_Priority__c, Priority, Owner.Name, Account.Name, Type, CaseNumber, Origin, Subject, Description, Case_Origin_IMG__c, Status, CreatedDate, ParentId, Parent.CaseNumber, Request_Age__c FROM Case WHERE Id = :recordId];
            } catch (Exception e) {
                // CODE SCAN ANALYZE 2019
                System.debug('thrown standard DML exception '+e);
            }
        }
        return null;
    }

    @AuraEnabled
    public static List<EmailMessage> getEmails(Id recordId){
        string soql = 'Select Id, Subject, MessageDate, toLabel(Status), Has_Files__c, Incoming, HasAttachment From EmailMessage Where ';
        soql += (recordId.getSobjectType() == Case.SobjectType)?'parentId':'relatedToId';
        soql+= '=:recordId order by MessageDate Desc';
        System.debug('getEmails=' + soql);
        return Database.query(String.escapeSingleQuotes(soql));
    }

    @AuraEnabled
    public static List<ICX_Files.FileWrapper> getRelatedFiles(Id recordId) {
        return ICX_Files.getRelatedFiles(recordId);
    }

    @AuraEnabled
    public static EmailMessage getSourceEmail(Id recordId) {
        if (String.isNotBlank(recordId) && Schema.sObjectType.EmailMessage.isAccessible()) {
            try {
                return [SELECT TextBody, HtmlBody, Subject, FromAddress, FromName, ToAddress, MessageDate FROM EmailMessage WHERE Id = :recordId];
            } catch (Exception e) {
                // CODE SCAN ANALYZE 2019
                System.debug('thrown standard DML exception '+e);
            }
        }
        return null;
    }

    @AuraEnabled
    public static Id getParentRecordId(Id caseRecordId, String sObjectType) {
		Id parentRecordId;
        if (String.isNotBlank(caseRecordId)) {
            try {
				//String query = 'SELECT Id FROM ';
                if ('Task'.equalsIgnoreCase(sObjectType) && Schema.sObjectType.Task.isAccessible()) {
                    // AggregateResult doesn't work for Task
					//query += 'Task WHERE TECH_IsWhatIdCase__c = true AND WhatId = :caseRecordId';
                	List<Task> tskList = [SELECT Id FROM Task WHERE TECH_IsWhatIdCase__c = true AND WhatId = :caseRecordId AND TaskSubtype='Call'];
                    if (!tskList.isEmpty() && tskList.size() == 1) {
                        parentRecordId = tskList[0].Id;
                    }
				} /*else if ('LiveChatTranscript'.equalsIgnoreCase(sObjectType)) {
					//query += 'LiveChatTranscript WHERE CaseId = :caseRecordId';
                	List<LiveChatTranscript> chatList = [SELECT Id FROM LiveChatTranscript WHERE CaseId = :caseRecordId];
                    if (!chatList.isEmpty()) {
                        parentRecordId = chatList[0].Id;
					}
				} else if ('MessagingSession'.equalsIgnoreCase(sObjectType)) {
					//query += 'MessagingSession WHERE CaseId = :caseRecordId';
                	List<MessagingSession> messList = [SELECT Id FROM MessagingSession WHERE CaseId = :caseRecordId];
                    if (!messList.isEmpty()) {
                        parentRecordId = messList[0].Id;
					}
				}*/
            } catch (Exception e) {
                System.debug('thrown standard DML exception '+e);
            }
        }
        return parentRecordId;
    }

    @AuraEnabled
    public static EmailMessage getLastReplyEmail(Id caseRecordId) {
        EmailMessage msg;
        if (String.isNotBlank(caseRecordId) && Schema.sObjectType.EmailMessage.isAccessible()) {
            List<EmailMessage> emailList = [Select Id, FromAddress, CreatedBy.name, Subject, MessageDate, toLabel(Status) StatusLabel, HasAttachment, Has_Files__c, Incoming, ToAddress,TextBody 
                                            From EmailMessage Where ParentId = :caseRecordId and Incoming=false and Status='3' order by createddate DESC];
            if (!emailList.isEmpty()) {
                msg = emailList[0];
            }
        }
        return msg;
    }

}