public with sharing class ICX_GenesysController {
    
    @AuraEnabled
    public static Id getTaskId(String interactionId, Integer isClienteling, Integer isMonitoring){
        try{
            Task t = null;
            List<Task> tasks = [SELECT Id, Subject, CallType, recordTypeId,
                                CreatedDate, CallDurationInSeconds, LVM_SFDCAccountIds__c, OwnerId
                                FROM Task WHERE CreatedDate = TODAY AND CallObject = :interactionId 
                                AND CreatedById = :UserInfo.getUserId() ORDER BY CreatedDate DESC];
            if (tasks.size() > 0) {
                System.debug('@@@ Id found : '+tasks.get(0).Id);
                t = tasks.get(0);
                if(isClienteling == 1){
                    System.debug('@@@ Clienteling Call: '+t.Id+ ' - update the recordType');
                    Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('ICONICS_Clienteling').getRecordTypeId();
                    t.Subject = 'Clienteling '+t.Subject;
                    t.recordTypeId = recordTypeId;
                    update t;
                }
                else if(isMonitoring == 1 && t.Subject.startsWith('Monitoring') == false){
                    System.debug('@@@ Monitoring Call: '+t.Id);
                    String monitorUserId = ICX_GenesysSettings__c.getOrgDefaults().MonitoringUserId__c;
                    t.LVM_SFDCAccountIds__c = null;
                    t.OwnerId = monitorUserId != null ? monitorUserId : t.OwnerId;
                    t.Subject = 'Monitoring '+t.Subject;
                    t.WhatId = null; 
                    t.WhoId = null;
                    update t;
                }
                return t.Id;
            } 
       	}catch(Exception e){
            throw new AuraHandledException('Error Exception happend '+e.getMessage());           
		}
        return null;
    }

    /**
     * Update Genesys Fields on Case
     * 
     * @param caseId
     * @param Genesys ParticipantId
     * @param Genesys ConversationId
     */
    @AuraEnabled
    public static Case updateCase(String caseId, String conversationId, String participantId) {
        if(String.isNotBlank(caseId) && String.isNotBlank(conversationId) && String.isNotBlank(participantId)){
            System.debug('@@@ Update case ownerId + Conversation and participant IDs');
            // SOQL without "createdDate" filter, to get the Cases that remained in the genesys queue
            List<Case> cases = [
                SELECT Id, ICX_GenesysParticipantID__c, ICX_GenesysConversationId__c, Origin, OwnerId
                FROM Case WHERE Id = :caseId
            ];
            if(cases.size() > 0){
                Case c = cases.get(0);
                Boolean isCasePicking = String.isBlank(c.ICX_GenesysParticipantID__c) 
                    && c.OwnerId.getSObjectType().getDescribe().getName() == 'User'
                    && ! [SELECT Id, IsTechnicalUser__c FROM User WHERE Id = :c.OwnerId].IsTechnicalUser__c;
       
                c.ICX_GenesysConversationId__c = conversationId;
                c.ICX_GenesysParticipantID__c = participantId;
                c.OwnerId = isCasePicking ? c.OwnerId : UserInfo.getUserId();
                c.ICX_CasePickingUserId__c = isCasePicking ? UserInfo.getUserId() : null;
                update c;
                return c;
            }
        }
        return null;
    }

    /**
     * Set Case Owner to initial Queue on CTI transfer
     * 
     * @param caseId
     * @param Genesys ConversationId
     */
    @AuraEnabled
    public static Id setCaseOwnerToInitialQueue(String conversationId) {
        if(String.isNotBlank(conversationId)){
            System.debug('@@@ Update case OwnerId with initial Queue');
            List<Case> cases = [
                SELECT Id, ICX_GenesysConversationId__c, OwnerId, TECH_Queue_ID__c
                FROM Case  
                WHERE createdDate = TODAY
                AND ICX_GenesysConversationId__c = :conversationId
            ];
            if(cases.size() > 0){
                Case c = cases.get(0);
                if(String.isNotBlank(c.TECH_Queue_ID__c)){
                    c.OwnerId = c.TECH_Queue_ID__c;
                    update c;
                    return c.Id;
                }
            }
        }
        return null;
    }

    /**
     * Get Genesys custom settings
     */
    @AuraEnabled
    public static Map<String, Object> getSettings() {
        return new Map<String, Object>{
            'clientelingStatusId' => ICX_GenesysSettings__c.getOrgDefaults().ClientelingStatusId__c,
            'monitoringStatusId' => ICX_GenesysSettings__c.getOrgDefaults().MonitoringStatusId__c,
            'retryLimit' => ICX_GenesysSettings__c.getOrgDefaults().TaskRetryLimit__c
        };  
    }
}