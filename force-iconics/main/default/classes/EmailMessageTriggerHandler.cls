public with sharing class EmailMessageTriggerHandler {

    public static void handleBeforeInsert(List<EmailMessage> newEmailList) {
        //webform(newEmailList);
        changeInboundEmailQueue(newEmailList);
    }

    public static void handleAfterInsert(List<EmailMessage> newEmailList)
    {
        setInOutOnTask(newEmailList);
        CheckIsWardrobingTask(newEmailList);
        list<id> emIDs = getEmailMessageID(newEmailList);
        //CSC-291, 292 Clienteling Request status rules
        manageClientelingRequestStatus(newEmailList);
        if(UserInfo.getName()=='SYSTEM')
        {
            //CSC-290 Notification for Clienteling request
            //factorised the old method sendNotificationForResponseRemoteConsent to sendNotificationForResponse
            sendNotificationForResponse(newEmailList);
            //sendNotificationForResponseRemoteConsent(newEmailList);
        }
    }

    
    // ICONiCS function for Webform (lv.com sends an email from 'no-reply@louisvuitton.com')
    // Transform Emailmessage.FromAddress = 'no-reply@louisvuitton.com' to client email (useful when the CSC replies in SF)
    /*private static void webform(List<EmailMessage> newEmailList) {

        for (EmailMessage email : newEmailList) {
            if (Label.ICX_NoReplyEmail.equalsIgnoreCase(email.FromAddress)) {//} && ICX_Case_Web2Case.isWebform(email.TextBody)) { //  && email.Incoming 
                ICX_Case_Web2Case.WebToCaseWrapper wrapper = ICX_Case_Web2Case.buildWrapper(email.TextBody);
                if (wrapper != null && String.isNotBlank(wrapper.email)) {
                    email.FromAddress = wrapper.email;
                }
            }
        }
    }*/

    /**
    *@description
    * when email is sent from a case then set the "In/Out" field 
    * on related task based on the incoming field value
    *@param
    * newEmailList: list of newly created tasks
    **/
    private static void setInOutOnTask(List<EmailMessage> newEmailList)
    {
        System.debug('>>>> In Email Trigger Handler');
        Map<Task,EmailMessage> taskEmailMap = new Map<Task,EmailMessage>();
        List<id> taskIds = new List<id>();
        List<EmailMessage> emList = new List<Emailmessage>();
        for(Emailmessage em : newEmailList)
        {
            // make sure the related task is created and linked to the email
            // and email has been sent from case
            //if(em.Activityid != null && em.Activityid != oldEmailMap.get(em.id).Activityid && String.valueOf(em.parentid).left(3) == '500')
            //System.debug(em.Activityid);
            if(em.Activityid != null && String.isNotBlank(em.parentid) && String.valueOf(em.parentid).left(3) == '500')
            {
                taskIds.add(em.Activityid);
                emList.add(em);
            }
        }
        if(taskIds.size() > 0)
        {
            // get related tasks
            Map<id,Task> taskMap = new Map<id,Task>([SELECT id, Inout__c, ActionType__c  from Task where id in: taskIds]);
            for(Emailmessage em: emList)
            {
                Task t = taskMap.get(em.activityid);
                if(!taskEmailMap.containsKey(t))
                {
                    taskEmailMap.put(t, em);
                }
            }
            System.debug('>>> taskEmailMap: ' + taskEmailMap);
            // call the method that sets the In/Out field on task
          	IC_Task_TRG.setInOutOnTask(taskEmailMap);
        }
        
    }

    /**
    *@description
    * Change the incoming email recipient to the new queue email ([country]@contact.louisvuitton.com) when email is sent to old email queue (contact_[country]@louisvuitton.com)
    * Reason: when CSC users replies to the email, CC field should be empty (CC field is empty only when the email queue is known on this format: [country]@contact.louisvuitton.com)
    * Quick action with predefined fields on CC field don't work
    * 
    *@param
    * newEmailList: list of Emails
    **/
    private static void changeInboundEmailQueue(List<EmailMessage> newEmailList) {
        Map<String, String> queueMap = getQueueEmailMap();

        for (EmailMessage email : newEmailList) {
            System.debug('email=' + email);
            // for incoming email, check the ToAddress with @louisvuitton.com to avoid to loop all old email queues
            if (email != null && email.Incoming && String.isNotBlank(email.ToAddress) && email.ToAddress.containsIgnoreCase('@louisvuitton.com')) {
                // ToAddress can contain many addresses (ex: "test@test.com; alex@test.com")
                // so queueMap.containsKey(email.ToAddress) only works for one email
                for (String oldQueueEmail : queueMap.keySet()) {
                    // this code won't work if the ToAddress contains 2 old queue emails but ok as we still have at least one old queue email 
                    System.debug('oldQueueEmail=' + oldQueueEmail + ', email.ToAddress=' + email.ToAddress);
                    if (email.ToAddress.containsIgnoreCase(oldQueueEmail)) {
                        email.ICX_ToAddress_InitialQueue__c = oldQueueEmail;
                        email.ToAddress = email.ToAddress.toLowerCase().replace(oldQueueEmail, queueMap.get(oldQueueEmail)); // Replace old queue email by new
                        break;
                    }
                }
            }
        }
    }

    // Get Map<Old email, Target email>
    private static Map<String, String> getQueueEmailMap() {
        Map<String, String> queueEmailMap = new Map<String, String>();

        for (ICX_Queue__mdt queue : [SELECT CurrentEmail__c, TargetEmail__c FROM ICX_Queue__mdt WHERE CurrentEmail__c != '']) {
            queueEmailMap.put(queue.CurrentEmail__c, queue.TargetEmail__c);
        }
        return queueEmailMap;
    }

    public static List<id> getEmailMessageID(List<EmailMessage> newEmailList)
    {
        List<id> emIDs = new List<id>();
        for(EmailMessage em: newEmailList)
        {
            emIDs.add(em.id);
        }
        return emIDs;
    }

/**
    *@description
    * when email is sent from Wardrobing (from the account object that include Label.ICX_LookWardrobingUrl) then set the "IsWardrobing__c" field to true
    * on related task  
    *@param
    * newEmailList: list of newly Email Message
    **/
    private static void CheckIsWardrobingTask(List<EmailMessage> newEmailList){
        Schema.DescribeSObjectResult obj = Account.sObjectType.getDescribe();
        string prefixAccount = obj.getKeyPrefix();
       
        List<Task> WardrobingtaskEmail = new List<Task>();
        List<id> taskIds = new List<id>();
        for(Emailmessage em : newEmailList)
        {            
            if(em.Activityid != null && String.isNotBlank(em.relatedToId) && String.valueOf(em.relatedToId).left(3) == prefixAccount && em.TextBody != null && em.TextBody.contains(System.Label.ICX_LookWardrobingUrl)){
                taskIds.add(em.Activityid);
            }
        }
        if(taskIds.size() > 0){
            List<Task> taskList = new List<Task>([SELECT id, IsWardrobing__c from Task where id in: taskIds]);
            IC_Task_TRG.IsWardrobingTask(taskList);
          	
        }
        
    }

     //naomi 11/23
     private static void sendNotificationForResponse (List<EmailMessage> newEmailList)
     {
         Map<Id,EmailMessage> CaseEmailMessageMap = new Map<Id,EmailMessage>();
         Map<EmailMessage,Id> emailMessageOwnerIdMap = new Map<EmailMessage,Id>();
         Map<EmailMessage,Case> emailMessageCaseRemoteConsentMap = new Map<EmailMessage,Case>();
         Map<EmailMessage, Case> emailMessageCaseClientelingMap = new Map<EmailMessage, Case>();
 
 
         for(EmailMessage currentEmailMessage : newEmailList)
         {
             if( currentEmailMessage.Incoming == true && currentEmailMessage.RelatedToId!=null&& 'Case'.equalsIgnoreCase(currentEmailMessage.RelatedToId.getSObjectType().getDescribe().getName()))
             {
 
                 CaseEmailMessageMap.put(currentEmailMessage.RelatedToId,currentEmailMessage);
             }
 
 
         }

         Id remoteConsentRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Remote_Consent').getRecordTypeId(); 
         Id clientelingRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Clienteling').getRecordTypeId();
 
         for(Case currentCase : [SELECT Id, RecordTypeId, OwnerId, CaseNumber FROM CASE WHERE Id IN: CaseEmailMessageMap.keySet() AND ( RecordTypeId =:remoteConsentRTID OR RecordTypeId =:clientelingRTID)])
         {
             
                 emailMessageOwnerIdMap.put(CaseEmailMessageMap.get(currentCase.Id),currentCase.OwnerId);
                 if(currentCase.RecordTypeId == remoteConsentRTID){
                    emailMessageCaseRemoteConsentMap.put(CaseEmailMessageMap.get(currentCase.Id),currentCase);
                 }else if(currentCase.RecordTypeId == clientelingRTID){
                    emailMessageCaseClientelingMap.put(CaseEmailMessageMap.get(currentCase.Id),currentCase);
                 }
                 
             
         }
 
         CustomNotificationType notificationType =  [ SELECT Id, DeveloperName   FROM CustomNotificationType  WHERE DeveloperName = 'Notification_for_Remot_Consent_Response'];
         CustomNotificationType clienteingNotificationType = [ SELECT Id, DeveloperName   FROM CustomNotificationType  WHERE DeveloperName = 'Notification_for_Clienteling_Response'];
         Messaging.CustomNotification notification = new Messaging.CustomNotification();
 
         for(EmailMessage currentEmailMessage : emailMessageOwnerIdMap.keySet() )
         {
 
            if(!emailMessageCaseClientelingMap.isEmpty() && emailMessageCaseClientelingMap.get(currentEmailMessage).RecordTypeId == clientelingRTID){
                notification.setTitle('New Response on Clienteling Case');
                notification.setBody( 'Hello, the client answer to your Clienteling request ' + emailMessageCaseClientelingMap.get(currentEmailMessage).CaseNumber +'.');

                notification.setNotificationTypeId(clienteingNotificationType.Id);

            }else if (!emailMessageCaseRemoteConsentMap.isEmpty() && emailMessageCaseRemoteConsentMap.get(currentEmailMessage).RecordTypeId == remoteConsentRTID){
                notification.setTitle('New Response on Remote Consent Case');
                notification.setBody( 'Hello, the client answer to your Remote Consent request ' + emailMessageCaseRemoteConsentMap.get(currentEmailMessage) +'.');
 
                notification.setNotificationTypeId(notificationType.Id);

            }

             
             notification.setTargetId(currentEmailMessage.RelatedToId);
 
 
             Set<String> recepientIds = new Set<String>{ (String) emailMessageOwnerIdMap.get(currentEmailMessage)};
             try {
                notification.send(recepientIds);
             } catch (Exception e) {
                 System.debug('Error while sending bell notification for remote consent email ' + e);
             }
 
         }
 
 
     }

     /**
    *@description
    * This method is for mananging the Clienteling request's status
    * when email is the reply of clienteling request, set request's status to New
    * when CA send a email from Clienteling request, set request's status to Pending 
    *@param
    * newEmailList: list of newly Email Message
    **/
     private static void manageClientelingRequestStatus(List<EmailMessage> newEmailList){

        System.debug('****Email Message Trigger >>> manageClientelingRequestStatus Starts');

        List<Case> clientelingRequestToUpdateList = new List<Case>();
        Map<Id, EmailMessage> emailMessageCaseClientelingMap = new Map<Id, EmailMessage>();

        Set<Id> newEmailIds = new Set<Id>();
        for(EmailMessage currentEmailMessage : newEmailList){
            newEmailIds.add(currentEmailMessage.Id);
        }

        Id clientelingRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Clienteling').getRecordTypeId();

        for(EmailMessage currentEmailMessage : [SELECT Id, RelatedToId, RelatedTo.RecordTypeId, Incoming FROM EmailMessage WHERE 
        Id IN: newEmailIds AND RelatedToId != null AND RelatedTo.RecordTypeId =: clientelingRTID])
        {
            emailMessageCaseClientelingMap.put(currentEmailMessage.RelatedToId, currentEmailMessage);
        }

        if(emailMessageCaseClientelingMap.size() > 0){
            for(Case currentCase : [SELECT Id, Status FROM Case WHERE Id IN: emailMessageCaseClientelingMap.keySet()]){
                System.debug('****manageClientelingRequestStatus Case: ' + currentCase.Id);
                if(emailMessageCaseClientelingMap.get(currentCase.Id).Incoming == true && UserInfo.getName() == 'SYSTEM'){
                    currentCase.Status = 'New';
                    clientelingRequestToUpdateList.add(currentCase);
                }else if (emailMessageCaseClientelingMap.get(currentCase.Id).Incoming == false){
                    currentCase.Status = 'Pending';
                    clientelingRequestToUpdateList.add(currentCase);
                }
            }
           
            try{
                if(clientelingRequestToUpdateList.size()>0){   
                    update clientelingRequestToUpdateList;
                }     
            }catch(Exception e){
                System.debug('Error while updating Clienteing request status to New ' + e);
            }
        }

     }

}