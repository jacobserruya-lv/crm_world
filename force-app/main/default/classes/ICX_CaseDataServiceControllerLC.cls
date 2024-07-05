public with sharing class ICX_CaseDataServiceControllerLC {

    private static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_TYPE_COMPLAINTS = 'Complaints';
    
      // get Account id from record id
    // used for force:recordData with Account object in the record detail page 
    @AuraEnabled(cacheable=true)
    public static Id getAccountIdByField(String recordId,String accountField) {
        system.debug('accountField :'+accountField);
        system.debug('recordId :'+recordId);
        Id accId;
        if (String.isNotBlank(recordId)) {
            try {
                String objectType;
                try {
                    Id recId = Id.valueOf(recordId);
                    objectType = recId.getSObjectType().getDescribe().getName();
                } catch (Exception e) {
                    System.debug('Invalid record id ' + recordId);
                }
                if('Task'.equalsIgnoreCase(objectType)){
                    List<Task> taskList =  [SELECT AccountId, WhoId, WhatId FROM Task WHERE Id = :recordId WITH SECURITY_ENFORCED];
                    if (!taskList.isEmpty()) {
                        if (String.isNotBlank(taskList.get(0).AccountId)) {
                            accId = taskList.get(0).AccountId;
                        } else if (String.isNotBlank(taskList.get(0).WhoId)) {
                            accId = [SELECT AccountId FROM Contact WHERE Id = :taskList.get(0).WhoId].AccountId;
                        } else if (String.isNotBlank(taskList.get(0).WhatId) && String.valueOf(taskList.get(0).WhatId).left(3) == '001') {
                            accId = [SELECT AccountId FROM Contact WHERE Id = :taskList.get(0).WhatId].AccountId;
                        }
                    }
                }else{                   
                    sObject sobj = Database.query('SELECT '+ accountField +' FROM '+ objectType +' WHERE Id = :recordId');
                      accId = String.valueof(sobj.get(accountField));
                }

            } catch (Exception e) {
                // CODE SCAN ANALYZE 2019
                System.debug('thrown standard DML exception '+e);
            }
        }
        System.debug('getAccountId=' + accId);
        return accId;
    }
    
    // get Account id from case id
    // used for force:recordData with Account object in the Case detail page 
    @AuraEnabled(cacheable=true)
    public static Id getAccountId(String caseId) {
        Id accId;
        if (String.isNotBlank(caseId)) {
            try {
                String objectType;
                try {
                    Id recId = Id.valueOf(caseId);
                    objectType = recId.getSObjectType().getDescribe().getName();
                } catch (Exception e) {
                    System.debug('Invalid record id ' + caseId);
                }

                if ('Case'.equalsIgnoreCase(objectType)) {
                    // AccountId field should not be empty but it could be
                    accId = [SELECT AccountId FROM Case WHERE Id = :caseId].AccountId;   
                } else if ('Task'.equalsIgnoreCase(objectType)) {
                    List<Task> taskList =  [SELECT AccountId, WhoId, WhatId FROM Task WHERE Id = :caseId WITH SECURITY_ENFORCED];
                    if (!taskList.isEmpty()) {
                        if (String.isNotBlank(taskList.get(0).AccountId)) {
                            accId = taskList.get(0).AccountId;
                        } else if (String.isNotBlank(taskList.get(0).WhoId)) {
                            accId = [SELECT AccountId FROM Contact WHERE Id = :taskList.get(0).WhoId].AccountId;
                        } else if (String.isNotBlank(taskList.get(0).WhatId) && String.valueOf(taskList.get(0).WhatId).left(3) == '001') {
                            accId = [SELECT AccountId FROM Contact WHERE Id = :taskList.get(0).WhatId].AccountId;
                        }
                    }
                    //return [SELECT AccountId, WhoId FROM Task WHERE Id = :caseId].AccountId;   
                } else if ('Calling_Campaign__c'.equalsIgnoreCase(objectType)) {
                    // Client__c field should not be empty but it could be
                    accId = [SELECT Client__c FROM Calling_Campaign__c WHERE Id = :caseId].Client__c;   
                } else if ('LiveChatTranscript'.equalsIgnoreCase(objectType)) {
                    accId = [SELECT AccountId FROM LiveChatTranscript WHERE Id = :caseId].AccountId; 
                } else if ('MessagingSession'.equalsIgnoreCase(objectType)) {
                    accId = [SELECT EndUserAccountId FROM MessagingSession WHERE Id = :caseId].EndUserAccountId;
                }  else if ('Exclusive_Campaign_Order__c'.equalsIgnoreCase(objectType)) {
                    accId = [SELECT Client__c FROM Exclusive_Campaign_Order__c WHERE Id = :caseId].Client__c;
                }else if ('Account'.equalsIgnoreCase(objectType)) {
                    accId = caseId;
                }else if ('CareService__c'.equalsIgnoreCase(objectType)) {
                    accId = [SELECT Client__c FROM CareService__c WHERE Id = :caseId].Client__c;
                }else if('VO_Survey__c'.equalsIgnoreCase(objectType)){
                    accId = [SELECT ClientDreamID__c FROM VO_Survey__c WHERE Id = :caseId].ClientDreamID__c;
                }
            } catch (Exception e) {
                // CODE SCAN ANALYZE 2019
                System.debug('thrown standard DML exception '+e);
            }
        }
        System.debug('getAccountId=' + accId);
        return accId;
    }


    //get whoId to find task linked to accId
    public static Id getWhoId(Id accId) {
        
        Id whoId;
        if (accId!=null) {

            whoId= [SELECT PersonContactId FROM Account WHERE Id = :accId].PersonContactId;
        }
    return whoId;
}


    /**
     * @description:
     * Retrieves all indicators for an account
     * 
     * @param: 
     * recordId = ID of the account or related id attached to the case
     **/
    @AuraEnabled
    public static IndicatorWrapper getIndicatorList(Id recordId) {
        IndicatorWrapper wrapper = new IndicatorWrapper();
        try {
            System.debug('Print the recordId'+ recordId);
            Id accId = getAccountId(recordId);
            wrapper.openCaseList = generateWrapperList(getOpenCaseList(accId));
            wrapper.complaintList = generateWrapperList(getComplaintCaseList(accId));//getComplaintIndicator(recordId);
            wrapper.careList = getCareServiceList(accId);
            wrapper.openMessagingList = generateWrapperList(getOpenMessagingSessionList(accId));
            wrapper.liveChatTranscriptList = generateWrapperList(getLiveChatTranscript(accId));
            wrapper.taskList = generateWrapperList(getTask(accId));
            wrapper.surveyList = generateWrapperList(getVoicesList(accId));

        } catch (Exception e) {
            // CODE SCAN ANALYZE 2019
            System.debug('thrown standard DML exception '+e);
            
        }

        return wrapper;
    }

    public class IndicatorWrapper {
        @AuraEnabled
        public List<ItemWrapper> openCaseList;
        //public List<Case> openCaseList;

        /*@AuraEnabled
        public List<Case> followUpList;

        @AuraEnabled
        public List<sObject> pendingAnswersList;*/
        @AuraEnabled
        public List<ItemWrapper> openMessagingList;
        //public List<MessagingSession> openMessagingList;

        @AuraEnabled
        public List<ItemWrapper> liveChatTranscriptList;

        @AuraEnabled
        public List<ItemWrapper> taskList;

        @AuraEnabled
        public List<ItemWrapper> complaintList;
        //public List<Case> complaintList;

        @AuraEnabled
        public List<CareService__c> careList;

        @AuraEnabled
        public List<ItemWrapper> surveyList;
    }

    private class ItemWrapper {
        @AuraEnabled
        public String id;

        @AuraEnabled
        public sObject record;

        @AuraEnabled
        public String label;

        @AuraEnabled
        public String image;

        @AuraEnabled
        public Decimal age;

        @AuraEnabled
        public String subLabel;
    }

	private static List<ItemWrapper> generateWrapperList(List<sObject> recordList) {
        List<ItemWrapper> resultList = new List<ItemWrapper>();

        //System.debug('recordList=' + recordList);
        if (recordList != null && !recordList.isEmpty()) {
            sObject obj = recordList.get(0);
            String type;
            if (obj != null) {
                type = obj.getSObjectType().getDescribe().getName();
            }
            
            for (sObject record : recordList) {
                //System.debug('record=' + record);
                ItemWrapper result;
                if ('Case'.equals(type)) {
                    // Case record
                    Case rec = (Case) record;

                    result = new ItemWrapper();
                    result.id = rec.Id;
                    result.record = rec;
                    result.label = rec.CaseNumber + ' - ' + rec.Status;
                    result.image = rec.Case_Origin_IMG__c;
                    result.age = rec.Request_Age__c;
                    result.subLabel = ('Call_Case'.equals(rec.RecordType.DeveloperName) || 'Web_Email_Case'.equals(rec.RecordType.DeveloperName) ? '' : rec.RecordType.Name);
                    System.debug('case record:'+result);

                } else if ('MessagingSession'.equals(type)) {
                    // MessagingSession record (starts by "0Mw")
                    MessagingSession rec = (MessagingSession) record;

                    result = new ItemWrapper();
                    result.id = rec.Id;
                    result.record = rec;
                    result.label = rec.Name + ' - ' + rec.Status;
                    result.image = '<img src="/resource/iconics/images/channel/messaging.jpg" alt="Messaging" style="height:30px; width:30px;" border="0"/>'; // record.ChannelType
//                    result.age = (System.today()).daysBetween(Date.valueOf(rec.createdDate));//getDurationInDays(rec.CreatedDate);
                    result.age = (Date.valueOf(rec.createdDate)).daysBetween(System.today());//getDurationInDays(rec.CreatedDate);
                    result.subLabel = rec.ChannelType;
                }
                else if ('LiveChatTranscript'.equals(type))
                {
                    LiveChatTranscript rec = (LiveChatTranscript) record;

                    result = new ItemWrapper();
                    result.id = rec.Id;
                    result.record = rec;
                    result.image = '<img src="/resource/iconics/images/channel/LiveChatIcon.jpg" alt="Live_Chat" style="height:30px; width:30px;" border="0"/>'; 
                    result.age = (Date.valueOf(rec.createdDate)).daysBetween(System.today());//getDurationInDays(rec.CreatedDate);
                }
                else if ('Task'.equals(type))
                {

                    Task rec = (Task) record;

                    result = new ItemWrapper();
                    result.id = rec.Id;
                    result.record = rec;
                    result.image = '<img src="https://louisvuitton--iconicsdev.my.salesforce.com/img/icon/t4v35/standard/task_120.png" alt="Task" style="height:30px; width:30px;" border="0"/>'; 
                    result.age = (Date.valueOf(rec.createdDate)).daysBetween(System.today());//getDurationInDays(rec.CreatedDate);
                    System.debug('task record:'+result);
                }
                else if('VO_Survey__c'.equals(type))
                {

                    VO_Survey__c rec = (VO_Survey__c) record;

                    result = new ItemWrapper();
                    result.id = rec.Id;
                    result.record = rec;
                    result.label = rec.Name + ' - ' + rec.Status__c;
                    result.image = '<img src="/resource/iconics/images/client360/Survey/voiceIcon.svg" alt="Survey" style="height:30px; width:30px;" border="0"/>';
                    result.age = (Date.valueOf(rec.createdDate)).daysBetween(System.today());
                    System.debug('Voice record' + result);


                }

                if (result != null) {
                    resultList.add(result);
                }
            }
            
        }
        return resultList;
    }

    /*public static Integer getDurationInDays(DateTime createdDate) {
        //Integer oneDay = 24*60*60*1000; // hours*minutes*seconds*milliseconds
        //DateTime today = System.today();
        //DateTime secondDate = new Date(createdDate);

        //Decimal diffDays = Math.round(Math.abs((System.today() - createdDate)));
		//console.log("diffDays", diffDays);
        Integer dt1 = (System.today()).daysBetween(Date.valueOf(createdDate));
        return diffDays;
    }*/

    @TestVisible
    private static List<CareService__c> getCareServiceList(Id recordId) {
        List<CareService__c> careList = new List<CareService__c>();

        Id accId = getAccountId(recordId);
        System.debug('getAccountId >' + accId);
        if (String.isNotBlank(accId)) {
            careList = [SELECT Id, Name, Client__c, CreatedDate, SKU__c, TransactionId__c, Product_Sku_unknown__c, toLabel(MyRepairStatus__c) labelStatus, Followup_Status__c, Store__r.Name, Product_Name__c,ICONiCS_Status_Detail__c	 FROM CareService__c WHERE Client__c = :accId
							AND (NOT MyRepairStatus__c IN ('productDeliveredToClient', 'cancelled', 'sentToRMS')) WITH SECURITY_ENFORCED];
        }
        System.debug('getCareServiceList>careList=' + careList);
        return careList;
    }

    @TestVisible
    private static List<MessagingSession> getOpenMessagingSessionList(Id recordId) {
        List<MessagingSession> messagingList = new List<MessagingSession>();

        Id accId = getAccountId(recordId);
        System.debug('getAccountId >' + accId);
        if (String.isNotBlank(accId)) {
            messagingList = [SELECT Id, Name, CreatedDate, ChannelType, Status
                            FROM MessagingSession WHERE MessagingEndUser.AccountId = :accId
							AND (NOT Status IN ('Ended')) WITH SECURITY_ENFORCED];
        }
        System.debug('getMessagingSessionList>messagingList=' + messagingList);
        return messagingList;
    }

     /**
     * @description:
     * Retrieves the live chat for an account
     * 
     * @param: 
     * recordId = ID of the account or related id attached to the case
     **/
    @TestVisible
    private static List<LiveChatTranscript> getLiveChatTranscript(Id recordId) {
        List<LiveChatTranscript> liveChatTranscriptList = new List<LiveChatTranscript>();

        Id accId = getAccountId(recordId);
        System.debug('getAccountId >' + accId);
        if (String.isNotBlank(accId)) {
            liveChatTranscriptList = [SELECT Id, Name, CreatedDate, Status
                            FROM LiveChatTranscript WHERE LiveChatTranscript.AccountId = :accId
							 WITH SECURITY_ENFORCED];
        }
        System.debug('getLiveChatTranscript>liveChatTranscriptList=' + liveChatTranscriptList);
        return liveChatTranscriptList;
    }
      /**
     * @description:
     * Retrieves the task for an account
     * 
     * @param: 
     * recordId = ID of the account or related id attached to the case
     **/
    @TestVisible
    private static List<Task> getTask(Id recordId) {
        List<Task> taskList = new List<Task>();

        System.debug('recordIdTask >' + recordId);

        Id accId = getAccountId(recordId);
        System.debug('getAccountIdTask >' + accId);

        Id whoId = getWhoId(accId);
        System.debug('getWhoId >' + whoId);

        if (String.isNotBlank(accId)) {
            taskList = [SELECT Id, WhoId, CreatedDate, Status, CallType,RecordType.DeveloperName, RecordType.Name
                            FROM Task WHERE WhoId = :whoId
							 WITH SECURITY_ENFORCED];
        }
        System.debug('getTask>taskList=' + taskList);
        return taskList;
    }
    /**
     * @description:
     * Retrieves the open cases for an account
     * 
     * @param: 
     * recordId = ID of the account or related id attached to the case
     **/
    @AuraEnabled
    public static List<Case> getOpenCaseList(Id recordId) {

        try {
            if (String.isNotBlank(recordId)) {
                String objectType = recordId.getSObjectType().getDescribe().getName();
                if ('Account'.equalsIgnoreCase(objectType)) {
                    return getOpenCaseListByAccountId(recordId);
                    //return [SELECT Id, CaseNumber, CreatedDate, Status, Subject, Description, Owner.Name, Request_Age__c, Case_Origin_IMG__c FROM CASE WHERE 
                    //        status != :CASE_STATUS_CLOSED AND AccountId = :recordId ORDER BY CreatedDate DESC];
                } else if ('Case'.equalsIgnoreCase(objectType)) {
                    // get all open cases related to the email
                    /*Case cas = [SELECT Id, SuppliedEmail FROM Case WHERE Id = :recordId];
                    if (cas != null && String.isNotBlank(cas.SuppliedEmail)) {
                        return [SELECT Id, CaseNumber, CreatedDate, Status, Subject, Description, Owner.Name, Request_Age__c, Case_Origin_IMG__c FROM CASE WHERE 
                                status != :CASE_STATUS_CLOSED AND SuppliedEmail = :cas.SuppliedEmail ORDER BY CreatedDate DESC];                        
                    }*/
                    //String whereCondition = 'status != \'' + CASE_STATUS_CLOSED + '\'';
                    String whereCondition = 'IsClosed = false ';
                    return getRelatedCaseList(recordId, whereCondition);
                    /*Case cas = [SELECT Id, SuppliedEmail, AccountId FROM Case WHERE Id = :recordId];
                    if (cas != null && (String.isNotBlank(cas.SuppliedEmail) || String.isNotBlank(cas.AccountId))) {
                        // get all open cases with the account id (existing account) or the inbound email (cases with or without account)
                        String query = 'SELECT Id, CaseNumber, CreatedDate, Status, Subject, Description, Owner.Name, Request_Age__c, Case_Origin_IMG__c FROM CASE WHERE status != \'' + CASE_STATUS_CLOSED + '\'';
                        query += ' AND (';
                        query += (String.isNotBlank(cas.SuppliedEmail) ? ' SuppliedEmail = \'' + cas.SuppliedEmail + '\'' : '');
                        query += (String.isNotBlank(cas.SuppliedEmail) && String.isNotBlank(cas.AccountId) ? ' OR ' : '');
                        query += (String.isNotBlank(cas.AccountId) ? ' AccountId = \'' + cas.AccountId + '\'' : '');
                        query += ')';
                        query += ' ORDER BY CreatedDate DESC';
                        System.debug('getOpenCaseList>Query=' + query);
                        return Database.query(query);
                    }*/
                }
                
            }
        } catch (Exception e) {
            // CODE SCAN ANALYZE 2019
            System.debug('thrown standard DML exception '+e);
            
        }
            
        return new List<Case>();
    }

    private static List<Case> getOpenCaseListByAccountId(Id accId) {
        List<Case> result = new List<Case>();
        if (String.isNotBlank(accId)) {
	        result = [SELECT Id, CaseNumber, CreatedDate, Status, Subject, Description, Owner.Name, Request_Age__c, Case_Origin_IMG__c, RecordType.DeveloperName, RecordType.Name, Resolution__c FROM Case
                      WHERE IsClosed = false AND AccountId = :accId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
           	 	//status != :CASE_STATUS_CLOSED AND AccountId = :accId ORDER BY CreatedDate DESC];
        }
        return result;
    }

    private static List<Case> getRelatedCaseList(Id caseId, String whereCondition) {
        List<Case> result = new List<Case>();
        if (String.isNotBlank(caseId)) {
            Case cas = [SELECT Id, SuppliedEmail, AccountId FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
            if (cas != null && (String.isNotBlank(cas.SuppliedEmail) || String.isNotBlank(cas.AccountId))) {
                String suppliedEmail = cas.SuppliedEmail;
                // get all open cases with the account id (existing account) or the inbound email (cases with or without account)
                //String whereCondition = 'status != \'' + CASE_STATUS_CLOSED + '\'';
                String query = 'SELECT Id, CaseNumber, CreatedDate, Status, Subject, Description, Owner.Name, Request_Age__c, Case_Origin_IMG__c, RecordType.DeveloperName, RecordType.Name, Resolution__c FROM CASE ';
//                query += (String.isNotBlank(whereCondition) ? ' WHERE ' + whereCondition + ' AND ' : ' WHERE ');
                query += (String.isNotBlank(whereCondition) ? ' WHERE ' + whereCondition + ' AND ' : ' WHERE ');
                query += ' (';
                //query += (String.isNotBlank(cas.SuppliedEmail) ? ' SuppliedEmail = ' + cas.SuppliedEmail : '');
                query += (String.isNotBlank(cas.SuppliedEmail) ? ' SuppliedEmail = :suppliedEmail' : '');
                query += (String.isNotBlank(cas.SuppliedEmail) && String.isNotBlank(cas.AccountId) ? ' OR ' : '');
                String accId = cas.AccountId;
                query += (String.isNotBlank(cas.AccountId) ? ' AccountId = :accId' : '');
                query += ')';
                query += ' ORDER BY CreatedDate DESC';
                System.debug('query=' + query);
                result = Database.query(String.escapeSingleQuotes(query));
            }
        }
        return result;
    }

    /**
     * @description:
     * Update object to an account
     * 
     * @param: 
     * accountId = ID of the client attached to the case
     **/
    @AuraEnabled
    public static void updateRecord(String recordId, Id accountId) {
        System.debug('updateRecord recordId/accountId=' + recordId + '/' + accountId);
        
        if (String.isNotBlank(accountId) && String.isNotBlank(recordId)) {

            List<Account> accList = [SELECT Id, PersonContactId FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED];
            
            if (!accList.isEmpty() && String.isNotBlank(accList.get(0).PersonContactId)) {
                
                String objectType;
                try {
                    Id recId = Id.valueOf(recordId);
                    objectType = recId.getSObjectType().getDescribe().getName();
                } catch (Exception e) {
                    System.debug('Invalid record id ' + recordId);
                }
                if ('Task'.equalsIgnoreCase(objectType) && Schema.sObjectType.Task.isUpdateable()) {
                    Task tsk = new Task();
                    tsk.Id = recordId;
                    tsk.WhoId = accList.get(0).PersonContactId;
                    update tsk;
                    
                } else if ('Case'.equalsIgnoreCase(objectType)) {
                    Case caseDetail = [SELECT Id, SuppliedEmail, AccountId, ContactId FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED];
                    if (caseDetail != null && Schema.sObjectType.Case.isUpdateable()) {
                        caseDetail.AccountId = accountId;
                        caseDetail.ContactId = accList.get(0).PersonContactId;
                        update caseDetail;
                        if (!String.isBlank(caseDetail.SuppliedEmail)) {
                            // Link the new account with all open cases without account and with the same email
                            List<Case> caseList = new List<Case>();
                            for (Case cas : [SELECT Id, ContactId, OwnerId FROM Case WHERE Id != :caseDetail.Id AND SuppliedEmail = :caseDetail.SuppliedEmail AND ContactId = '']) {  // AND Id != :recordId];
                                String owner = String.valueof(cas.OwnerId);
                                // Validation rule VR6_CASE_ChangeOwnerMandatory
                                if (!owner.startsWith('00G')) {
                                    cas.ContactId = accList.get(0).PersonContactId;
                                    cas.AccountId = accList.get(0).Id;
                                    caseList.add(cas);                                    
                                }
                            }
                            if (!caseList.isEmpty()) {
                                System.debug('caseList=' + caseList);
                                update caseList;
                            }
                        }
                    } 
                } else if ('LiveChatTranscript'.equalsIgnoreCase(objectType) && Schema.sObjectType.LiveChatTranscript.isUpdateable()) {
                    LiveChatTranscript chat = new LiveChatTranscript();
                    chat.Id = recordId;
                    chat.ContactId = accList.get(0).PersonContactId;
                    chat.AccountId = accList.get(0).Id;
                    update chat;
                } else if ('MessagingSession'.equalsIgnoreCase(objectType) && Schema.sObjectType.MessagingEndUser.isUpdateable()) {
                    // Can't update MessagingSession.EndUserAccountId => workaround : update account in MessagingEndUser
                    List<MessagingSession> messList = [SELECT MessagingEndUserId FROM MessagingSession WHERE Id = :recordId WITH SECURITY_ENFORCED];
                    if (!messList.isEmpty()) {
                        MessagingEndUser mess = new MessagingEndUser();
                        mess.Id = messList[0].MessagingEndUserId;
                        mess.ContactId = accList.get(0).PersonContactId;
                        mess.AccountId = accList.get(0).Id;
                        update mess;
                    }
                    
                } else if ('Exclusive_Campaign_Order__c'.equalsIgnoreCase(objectType) && Schema.sObjectType.Exclusive_Campaign_Order__c.isUpdateable()) {
                   		Exclusive_Campaign_Order__c ExclusiveCampaignOrder= new Exclusive_Campaign_Order__c();
                        ExclusiveCampaignOrder.id = recordId;
                        ExclusiveCampaignOrder.Client__c = accList.get(0).Id;
                       
                        update ExclusiveCampaignOrder;

                }else if ('Alias__c'.equalsIgnoreCase(objectType) && Schema.sObjectType.Alias__c.isUpdateable()) {
                  List<Alias_Member__c> lstAm = [SELECT Client__c, ALias__c FROM Alias_Member__c WHERE Alias__c = :recordId WITH SECURITY_ENFORCED];
                    Set<Id> setOldClients = new Set<Id> ();
                    if (!lstAm.isEmpty()) {
                        for(Alias_Member__c oldAm : lstAm){
                            setOldClients.add(oldAm.Client__c);
                        }
                    }
                    if(setOldClients.contains(accList.get(0).Id)){
                        system.debug('Error Alias memeber');
                        throw new DMLException('The Client is already added to the Alias');
                    }
                    system.debug('setOldClients '+setOldClients);
                        if(!setOldClients.contains(accList.get(0).Id)){
                        Alias_Member__c newAm = new Alias_Member__c (Client__c = accList.get(0).Id, Alias__c = recordId );                        
                        Insert newAm; 
                    } 
                }
            }
        }
    }

    /**
     * @description:
     * Retrieves the number of open and closed complaint cases created within the last 20 days
     * and attached to a specific client
     * 
     * @param:
     * accountId = ID of the client attached to the case
     **/
    private static List<Case> getRecentComplaintCaseList(String accountId) {
    	return [SELECT id, Status FROM Case WHERE 
                Type = :CASE_TYPE_COMPLAINTS
               	AND AccountId = :accountId
                AND Status != :CASE_STATUS_CLOSED
                AND createdDate = LAST_N_DAYS:20
               ];
    }

    /**
     * @description:
     * Retrieves the number of open and closed complaint cases
     * and attached to a specific client
     * 
     * @param:
     * recordId = ID of the client attached to the case or the related id
     **/
    private static List<Case> getComplaintCaseList(Id recordId) {

        System.debug('getComplaintCaseList > recordId=' + recordId);
        if (String.isNotBlank(recordId)) {
            String objectType = recordId.getSObjectType().getDescribe().getName();
            if ('Account'.equalsIgnoreCase(objectType)) {
                return [SELECT Id, CaseNumber, CreatedDate, Status, Subject, Description, Owner.Name, Request_Age__c, Case_Origin_IMG__c, RecordType.DeveloperName, RecordType.Name, Resolution__c FROM Case WHERE 
                        Type = :CASE_TYPE_COMPLAINTS AND AccountId = :recordId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
            } else if ('Case'.equalsIgnoreCase(objectType)) {
                //String whereCondition = 'Type = \'' + CASE_TYPE_COMPLAINTS + '\'';
                String whereCondition = 'Type = :CASE_TYPE_COMPLAINTS';// + CASE_TYPE_COMPLAINTS;
                return getRelatedCaseList(recordId, whereCondition);

                // get all open cases related to the email
                /*Case cas = [SELECT Id, SuppliedEmail FROM Case WHERE Id = :recordId];
                System.debug('getComplaintCaseList > cas=' + cas);
                if (cas != null && String.isNotBlank(cas.SuppliedEmail)) {
                    return [SELECT Id, CaseNumber, CreatedDate, Status, Subject, Description, Owner.Name, Request_Age__c, Case_Origin_IMG__c FROM Case WHERE 
                            Type = :CASE_TYPE_COMPLAINTS
                            //AND AccountId = :recordId
                            AND SuppliedEmail = :cas.SuppliedEmail
                            //AND createdDate = LAST_N_DAYS: 20
                            ORDER BY CreatedDate DESC];
                }*/
            }

            /*return [SELECT Id, CaseNumber, CreatedDate, Status, Subject, Description, Owner.Name, Request_Age__c, Case_Origin_IMG__c FROM Case WHERE 
                    Type = :CASE_TYPE_COMPLAINTS
                    AND AccountId = :recordId
                    //AND createdDate = LAST_N_DAYS: 20
                    ORDER BY CreatedDate DESC
                   ];*/
        }
        return new List<Case>();
    }

    /**
     * @description:
     * Retrieves the number of open and closed complaint cases
     * and attached to a specific client
     * 
     * @param:
     * recordId = ID of the client attached to the case or the related record Id
     **/
    @AuraEnabled
    public static String getComplaintIndicator(String recordId) {
        ComplaintCaseWrapper wrapper = new ComplaintCaseWrapper();

        wrapper.complaintList = getComplaintCaseList(recordId);
		wrapper.recentComplaintList = getRecentComplaintCaseList(recordId);
		System.debug('wrapper=' + wrapper);
        return JSON.serialize(wrapper);
    }

    public class ComplaintCaseWrapper {
        @AuraEnabled
        public List<Case> recentComplaintList;

        @AuraEnabled
        public List<Case> complaintList;
    }

    private static List<VO_Survey__c> getVoicesList(Id recordId)
    {
        LIst<VO_Survey__c> results = new List<VO_Survey__c>();
        if(String.isNotBlank(recordId))
        {
            results = [SELECT Id,Status__c,DreamID__c,Solved__c,Name,RespondentProfile__c,ClientDreamID__c,CreatedDate,DreamIDText__c FROM VO_Survey__c
                       WHERE Status__c = 'Live'
                       AND RespondentProfile__c = 'Score 1-3'
                       AND Solved__c = false 
                       AND ClientDreamID__c = : recordId
                    ];
        }
             System.debug('Show the surveys instances' + results);
        return results;
    }
    
}