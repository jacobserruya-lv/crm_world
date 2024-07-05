public with sharing class ExperienceVariationTriggerHandler {
    public static void handleTrigger(List<Brand_Experience_Variation__c> newList, Map<Id, Brand_Experience_Variation__c> newMap, List<Brand_Experience_Variation__c> oldList, Map<Id, Brand_Experience_Variation__c> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT{
                handleBeforeInsert(newList);
            }
            when AFTER_UPDATE {
                handleAfterUpdate(newList, oldMap);
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate(newList, oldMap);
            }
            when else {
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
    }

    public static void handleBeforeInsert(List<Brand_Experience_Variation__c> variations) {
        Set<Id> experiencesIds = new Set<Id>();
        Set<Id> storeIds = new Set<Id>();
        Id physicalEventRTId = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();
        for (Brand_Experience_Variation__c var : variations) {
            experiencesIds.add(var.Brand_Experience__c);
            storeIds.add(var.Store__c); 
        }

        //SE-344 Get currecy of store **Keman WU**                  
        Map<Id, Store__c> storeCurrencyMap = new Map<Id, Store__c>([SELECT Id, Currency__c FROM Store__c WHERE Id IN :storeIds]);      
        Map<Id, Brand_Experience__c> experiences = new Map<Id, Brand_Experience__c>([
            SELECT Id, Reference__c, RecordTypeId, (SELECT Id, Reference__c FROM Brand_Experience_Variations__r ORDER BY CreatedDate DESC LIMIT 1)
            FROM Brand_Experience__c 
            WHERE Id 
            IN :experiencesIds
        ]);
        
        for (Integer i = 0; i < variations.size(); i++) {
            Brand_Experience_Variation__c variation = variations[i];
            Brand_Experience__c experience = experiences.get(variation.Brand_Experience__c);
            Integer variationIndex = experience.Brand_Experience_Variations__r.isEmpty() ? i + 1 : getStatusCounter(experience.Brand_Experience_Variations__r[0]) + i + 1;
            String formattedIndex = String.valueOf(variationIndex).leftPad(6, '000000');

            variation.Reference__c = experience.Reference__c + '-' + formattedIndex;
            checkLimitRegistrationValue(variation);
            Boolean isExperienceRecordType =checkExperienceRecordType(experience.RecordTypeId);
            setCARegistration(variation, isExperienceRecordType);
            setGuestsAuthorized(variation, isExperienceRecordType);
            setNominationByCA(variation, physicalEventRTId, isExperienceRecordType);  
            setTargetingMethod(variation,isExperienceRecordType);
            setVariationTypes(variation);
            setAttendanceByCA(variation, physicalEventRTId, isExperienceRecordType);

            //SE-344 Fill currency__c when Store__c is filled if currency__c is not filled **Keman WU**
            if(variation.RecordTypeId == physicalEventRTId && variation.Currency__c == null && variation.Store__c != null ){
                variation.Currency__c = storeCurrencyMap.get(variation.Store__c).Currency__c;
            }
        }
    }
    private static boolean checkExperienceRecordType(Id recordType) {
        return recordType == BL_Experience_Variation_Utils.getRecordTypeExperience('Experience');
    }
   
    public static void handleAfterUpdate(List<Brand_Experience_Variation__c> newList, Map<Id, Brand_Experience_Variation__c> oldMap) {
        List<Id> experiencesIdsToCheck = new List<Id>();
        List<Id> variationIdsToSentPush = new List<Id>();
        List<Id> experiencesVariationsIdsToCheck = new List<Id>();

        for (Brand_Experience_Variation__c variation : newList) {
            Brand_Experience_Variation__c oldVariation = oldMap.get(variation.Id);
            if (variation.status__c != oldVariation.status__c) {
                if (variation.status__c == 'Ready') {
                    variationIdsToSentPush.add(variation.Id);
                    variationIdsToSentPush.add(variation.Id);
                }
                if(!experiencesIdsToCheck.contains(variation.Brand_Experience__c)){
                    experiencesIdsToCheck.add(variation.Brand_Experience__c);
                }
               
               
            }
           
            if( variation.status__c != oldVariation.status__c || variation.RequiredClientRegistration__c != oldVariation.RequiredClientRegistration__c ){
                experiencesVariationsIdsToCheck.add(variation.Id);
                experiencesVariationsIdsToCheck.add(variation.Id);
            }
            
        }
     
        if (!variationIdsToSentPush.isEmpty()){
            IM_SendPushNotifications.experienceVariationSendPush(variationIdsToSentPush);
        }

        if (!experiencesVariationsIdsToCheck.isEmpty()){
            System.enqueueJob(new QueuableExpVariationUpdateMembers(experiencesVariationsIdsToCheck));
        }

        if (experiencesIdsToCheck.isEmpty()) {
            return;
        }

        List<Brand_Experience_Variation__c> variationsToCheck = [SELECT Id, Status__c, Brand_Experience__c FROM Brand_Experience_Variation__c WHERE Brand_Experience__c IN :experiencesIdsToCheck AND Brand_Experience__r.RecordType.DeveloperName = 'Club_Experience'];

        Map<Id, ExperienceStatusCalculator> statusCalculatorByExperience = new Map<Id, ExperienceStatusCalculator>();
        for (Brand_Experience_Variation__c variation : variationsToCheck) {   
            if (!statusCalculatorByExperience.containsKey(variation.Brand_Experience__c)) {
                statusCalculatorByExperience.put(
                    variation.Brand_Experience__c, new ExperienceStatusCalculator()
                );
            }
            
            switch on variation.status__c {
                when 'Draft' {
                    statusCalculatorByExperience.get(variation.Brand_Experience__c).draft++;
                }
                when 'Ready' {
                    statusCalculatorByExperience.get(variation.Brand_Experience__c).ready++;
                }
                when 'Preview' {
                    statusCalculatorByExperience.get(variation.Brand_Experience__c).preview++;
                }
                when 'Registration Opened' {
                    statusCalculatorByExperience.get(variation.Brand_Experience__c).registrationOpened++;
                }
                when 'Registration Closed' {
                    statusCalculatorByExperience.get(variation.Brand_Experience__c).registrationClosed++;
                }
                when 'Selection Opened' {
                    statusCalculatorByExperience.get(variation.Brand_Experience__c).selectionOpened++;
                }
                when 'Selection Closed' {
                    statusCalculatorByExperience.get(variation.Brand_Experience__c).selectionClosed++;
                }
                when 'Participation Opened' {
                    statusCalculatorByExperience.get(variation.Brand_Experience__c).participationOpened++;
                }
                when 'Ended' {
                    statusCalculatorByExperience.get(variation.Brand_Experience__c).ended++;
                }
            }

            statusCalculatorByExperience.get(variation.Brand_Experience__c).variationListSize++;
        }

        List<Brand_Experience__c> updatedExperiences = new List<Brand_Experience__c>();
        for (String experienceId : experiencesIdsToCheck) {
            String updatedStatus = statusCalculatorByExperience.get(experienceId)?.getStatus();

            if (String.isNotBlank(updatedStatus)) {
                updatedExperiences.add(
                    new Brand_Experience__c(
                        Id = experienceId, 
                        Status__c = updatedStatus
                    )
                );
            }
        }
        System.debug('*******  nao ' +updatedExperiences);
        if (!updatedExperiences.isEmpty()) {
            update updatedExperiences;
        }
    }

    public static void handleBeforeUpdate(List<Brand_Experience_Variation__c> newList, Map<Id, Brand_Experience_Variation__c> oldMap) {
        List<Brand_Experience_Variation__c> experienceVariations = BL_Experience_Variation_Utils.getVariatonsById(oldMap.keyset());
        Map<Id,Id> recordTypeByVariation = BL_Experience_Variation_Utils.getrecordTypeByVariation(experienceVariations);
        Id physicalEventRTId = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();  
        //SE-344 Get currecyof store **Keman WU**
        Set<Id> storeIds = new Set<Id>();
        for (Brand_Experience_Variation__c variation : newList){
            storeIds.add(variation.Store__c);  
        } 
             
        Map<Id, store__c> storeCurrencyMap = new Map<Id, store__c>([SELECT Id, Currency__c FROM store__c WHERE Id IN :storeIds]);

        for (Brand_Experience_Variation__c variation : newList) {
            Brand_Experience_Variation__c oldVariation = oldMap.get(variation.Id);
            Boolean statusChanged = variation.status__c != oldVariation.status__c ;
            Boolean statusIsReady =  variation.status__c == 'Ready';
            Boolean isExperienceRecordType = recordTypeByVariation.get(variation.Id) == BL_Experience_Variation_Utils.getRecordTypeExperience('Experience');

            if (statusChanged && statusIsReady && isExperienceRecordType){
                variation.RegistrationStartDateTime__c = System.now() ;
                variation.RegistrationEndDateTime__c = variation.StartDateTime__c.addMinutes(-1)  ;
                variation.RequiredClientRegistration__c = 'Mandatory' ; 
            }
            checkLimitRegistrationValue(variation);
            setRequiredAppointment(variation, isExperienceRecordType);
            
            //SE-344 Update currency__c when Store__c is filled if currency__c was null **Keman WU**
            if(variation.RecordTypeId == physicalEventRTId && oldVariation.Currency__c == null && variation.Store__c != null ){
                variation.Currency__c = storeCurrencyMap.get(variation.Store__c).Currency__c;
            }
        }
    }

    private static Integer getStatusCounter(Brand_Experience_Variation__c variation) {
        String lastVarReference = variation.Reference__c;   
        
        if (String.isBlank(lastVarReference)) return 0;
        
        Integer variationCounterIndex = lastVarReference.indexOf('_') > -1 ? lastVarReference.indexOf('_') : lastVarReference.indexOf('-');
       
        if (variationCounterIndex < 0) return 0;
        
        String varCounter = lastVarReference.substring(variationCounterIndex + 1);        
        return Integer.valueOf(varCounter);
    }
    private static void checkLimitRegistrationValue(Brand_Experience_Variation__c variation) {
        if (!variation.ClientRegistrationDateLimit__c || variation.RequiredClientRegistration__c == 'No Registration'){
            variation.RegistrationStartDateTime__c = null;
            variation.RegistrationEndDateTime__c = null;
            variation.ClientRegistrationDateLimit__c = false;
        }
    }

    private static void setCARegistration(Brand_Experience_Variation__c variation, boolean isExperienceRecordType) {
        if(isExperienceRecordType){
            variation.Registration_by_CA__c=true;
        }
        else {
            variation.Registration_by_CA__c=false;
        }
    }

    private static void setGuestsAuthorized(Brand_Experience_Variation__c variation, boolean isExperienceRecordType) {
        Id physicalEventRecordType = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();
        if (variation.RecordTypeId==physicalEventrecordType) {
            if(isExperienceRecordType){
                variation.Guests_Authorized__c = true; //Default value is false, True only if Event.RT='Experience' AND variation.RT='Physical_Event'
            }
        }
    }
    private static void setRequiredAppointment(Brand_Experience_Variation__c variation, boolean isExperienceRecordType) {
        if(isExperienceRecordType){
            if (variation.RequiredClientRegistration__c=='Mandatory') {
                variation.Required_Appointment__c  = true; 
            }
        }
    }

    private static void setNominationByCA(Brand_Experience_Variation__c variation, Id physicalEventRTId, boolean isExperienceRecordType) {
        if(isExperienceRecordType && variation.RecordTypeId==physicalEventRTId){
            variation.Nomination_by_CA__c  = true; 
        }
    }

    private static void setAttendanceByCA(Brand_Experience_Variation__c variation, Id physicalEventRTId, boolean isExperienceRecordType ) {
        if(isExperienceRecordType && variation.RecordTypeId==physicalEventRTId)            
                variation.AttendanceByCA__c  = true;             
    }

    private static void setTargetingMethod(Brand_Experience_Variation__c variation, boolean isExperienceRecordType) {
        if(isExperienceRecordType){
            variation.TargetingMethod__c  = 'Manual'; 
        }
        else { //'Club' RecordType
            variation.TargetingMethod__c  = 'Dynamic'; 
        }
    }
    private static void setVariationTypes(Brand_Experience_Variation__c variation) {
        Id physicalEventRTId =Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();
        Id contentRTId =Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Content').getRecordTypeId();
        Id digitalEventRTId =Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Digital_Event_Variation').getRecordTypeId();
        Id exclusiveOfferEventRTId =Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Exclusive_Offer').getRecordTypeId();
        if (variation.RecordTypeId==physicalEventRTId) {
            variation.Type__c = 'Event';
            variation.SubType__c = 'Physical';
        }
        else if (variation.RecordTypeId==contentRTId) {
            variation.Type__c = 'Content';
            variation.SubType__c = 'Webview';
        }
        else if (variation.RecordTypeId==digitalEventRTId) {
            variation.Type__c = 'Event';
            variation.SubType__c = 'Digital';
        }
        else if (variation.RecordTypeId==exclusiveOfferEventRTId) {
            variation.Type__c = 'Exclusive Offer';
            variation.SubType__c = 'Exclusive Drop';
        }
    }

    class ExperienceStatusCalculator {
        Integer variationListSize = 0;
        Integer draft = 0;
        Integer ready = 0;
        Integer preview = 0;
        Integer registrationOpened = 0;
        Integer registrationClosed = 0;
        Integer selectionOpened = 0;
        Integer selectionClosed = 0;
        Integer participationOpened = 0;
        Integer ended = 0;
    
        private String getStatus() {
            if (isPartiallyReady()) {
                return 'Partially Ready';
            } else if (isReady()) {
                return 'Ready';
            } else if (isOnGoing()) {
                return 'Ongoing';
            } else if (isEnded()) {
                return 'Ended';
            } else {
                return null;
            }
        }
    
        private boolean isPartiallyReady() {
            return ready > 0 && !isReady();
        }
    
        private boolean isReady() {
            return (ready + preview + registrationOpened + registrationClosed + selectionOpened + selectionClosed) == variationListSize;
        }
    
        private boolean isOnGoing() {
            return (participationOpened > 0 || ended > 0) && ended != variationListSize;
        }
    
        private boolean isEnded() {
            return ended == variationListSize;
        }
    }
}