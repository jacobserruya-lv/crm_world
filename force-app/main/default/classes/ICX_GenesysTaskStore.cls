public without sharing class ICX_GenesysTaskStore {
     
    /**
     * Overloading the CreateTask function with default values
     * @see createTask
     * @param dataObj 
     */
    public static Id createTask(ICX_GenesysData dataObj) {
        return createTask(dataObj, false, false);
    }

    /**
     * Create a task from the data received by the PureCloud Extension event
     * @param dataObj
     * @param excludeStore 
     * @param excludeCountry
     */
    public static Id createTask(ICX_GenesysData dataObj, Boolean excludeStore, Boolean excludeCountry) {
        ICX_GenesysData.Interaction inter = dataObj.interaction;
        
        // Avoid to create duplicate Task with the same interactionId, Useful during a retransfer to 1st user
        // No task is found for transfer to another user or monitoring because the Owner is different
        List<Task> existingTasks = [
            SELECT Id FROM Task 
            WHERE CallObject = :inter.id 
            AND OwnerId = :UserInfo.getUserId() 
            AND CreatedDate = TODAY
            LIMIT 1
        ];
        if(existingTasks.size() > 0){
            System.debug('Task with the same CallObject: '+ inter.id + ' fount with ID: ' + existingTasks.get(0).Id);
            return existingTasks.get(0).Id; 
        }
             
        // Vars init
        String inOut = inter.direction =='Inbound' ? 'In' : inter.direction == 'Outbound' ? 'Out' : '';
        String accIds, ICXCountry, LVM_Destination_Country, LVM_SFDCAccountIds, LVM_SFDCAccounts_Identify, phoneNumber, StoreCode, taskId, whatId = null;     
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Call').getRecordTypeId();
        Boolean SFDCAccounts_Identify = false;
        
        // Customs Attributes are not available on outbound calls or on personnal transfer
        if(inter.attributes != null){ 
            // Get AccountIds and Check if multiMatch found
            LVM_SFDCAccountIds = inter.attributes.get('Participant.LVM_SFDCAccountIds');
            LVM_SFDCAccountIds = (LVM_SFDCAccountIds != null) ? LVM_SFDCAccountIds.replace(',', '').replace('|', ',') : null;
            // The field LVM_SFDCAccountIds is limited to 255 chars so we replace it with !!! to indicate to
        	// @see ICX_AccountIdsInvoc to request the accounts linked to the moment of the qualification
        	accIds = LVM_SFDCAccountIds != null && LVM_SFDCAccountIds.length() > 255 ? '!!!PersonalShopper' : LVM_SFDCAccountIds;
            // Multi Match identified
            LVM_SFDCAccounts_Identify = inter.attributes.get('Participant.LVM_SFDCAccounts_Identify'); 
            SFDCAccounts_Identify = (inOut != 'Out' && LVM_SFDCAccounts_Identify != null && LVM_SFDCAccounts_Identify.equals('Multi Match'));        
         	// get Country
            LVM_Destination_Country = inter.attributes.get('Participant.LVM_Destination_Country');
            ICXCountry = LVM_Destination_Country != null ? CountryMapIso().get(LVM_Destination_Country.toUppercase()) : null;
            
            storeCode = inter.attributes.get('Participant.StoreCode');            
            whatId = (inOut != 'Out') ? inter.attributes.get('sf_urlpop') : null;  
        }
        // Assign Client Phone Number
        Boolean isAniNumber = String.isNotBlank(inter.ani) && inter.ani.length() > 1 && inter.ani.substring(1, inter.ani.length() - 1).isNumeric();  
        if(isAniNumber){ // inbound calls
            phoneNumber = inter.ani;
        }
        else if(inter.calledNumber != null){ // internal or transfers
            phoneNumber = inter.calledNumber;
        }    
        else if(inter.isCallback){
            if(inter.phone != null){ // is CTI Callback
                phoneNumber = inter.phone.replace('tel:', '');
            }
            else if(inter.callbackNumbers != null && inter.callbackNumbers.size() > 0){ // is Web Callback
                phoneNumber = inter.callbackNumbers.get(0);
            }  
            // Tag !!! indicate to the class ICX_AccountIdsInvoc to request accounts
            accIds = '!!!callback'; 
        }
        
        Task t = new Task(
			ActionType__c = 'Phone', 
			ActivityDate = +System.today(),
			CallObject = inter.id, 
            CallType = inter.direction,
			Genesys_Queue__c = inter.queueName,
			ICX_Country__c = ICXCountry, // ISO3
			InOut__c = inOut,
            LVM_SFDCAccountIds__c = accIds,
            LVM_SFDCAccounts_Identify__c = SFDCAccounts_Identify,
            OwnerId = UserInfo.getUserId(), // updated on Transfer
            Phone_Calling_Number__c = phoneNumber,
            RecordTypeId = recordTypeId,
            Source__c = 'yes',
            Status = 'Completed', 
            Subject = dataObj.callLog.subject,
            TaskSubtype = 'Call',
            Type = 'Call',
            WhatId = whatId
        );
        
        // Assign storeCode 
        if(storeCode != null && excludeStore == false){
            t.Store_Location__r = new Store__c(RetailStoreId__c = storeCode);
        }
        // Assign destinationCountry
        if(excludeCountry == false){
            t.Country__c = LVM_Destination_Country; // picklist country name
        }  
        System.debug('@@@ Before insert '+ t);
      
        try {
            insert t;
            taskId = t.Id;
        } 
        catch(DmlException e) {
            // Trying to recreate a task without blocking attributes
            if(e.getNumDML() == 1){
                String dmlMessage = e.getDmlMessage(0);
                String errMes = 'Trying to create task without the following fields: ';
                
                if(e.getDmlType(0) == StatusCode.INVALID_FIELD && dmlMessage.contains('RetailStoreId__c')){
                    errMes += 'RetailStoreId__c ' + ((excludeCountry) ? ', Country__c' : '');
                    new Logs.ERROR('ICX_GenesysExtensionPoint','APEX Code', e, errMes);
                    return createTask(dataObj, true, excludeCountry);
                }
                else if(e.getDmlType(0) == StatusCode.INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST && dmlMessage.contains('Country')){
                    errMes += 'Country__c ' + ((excludeStore) ? ', RetailStoreId__c' : '');
                    new Logs.ERROR('ICX_GenesysExtensionPoint','APEX Code', e, errMes);
                    return createTask(dataObj, excludeStore, true);
                }
            }
            new Logs.ERROR('ICX_GenesysExtensionPoint', 'APEX Code', e);
            return null;
        }
        return taskId;
    }

    /**
     * Update Task call duration field
     * @param data of genesys Disconnect event
     */
    public static Id updateTaskDuration(ICX_GenesysData dataObj){      
        // The record ID is provided by the event which allows to update each of the tasks related to the interaction
        System.debug('@@@ Update Call duration');
        String taskId = dataObj.callLog.id;
        if(taskId == null || taskId == '{}'){
            return null;
        }
        Task t = new Task(
            Id = dataObj.callLog.id,
            CallDurationInSeconds = dataObj.interaction.interactionDurationSeconds
        );
        upsert t;
        return t.Id;
    }

    @TestVisible
    private static Map<String,String> CountryMapIso(){
        Map<String,String> mapCountryIso = new Map<String, String>();
        if(mapCountryIso.isEmpty()){
            for (CountryMapping__mdt countrymdt : [SELECT id, Iso3Code__c, Case__c, HasOtherValue__c FROM CountryMapping__mdt WHERE Case__c != null]){
                if(! mapCountryIso.keySet().contains(countrymdt.Case__c))mapCountryIso.put(countrymdt.Case__c, countrymdt.Iso3Code__c);
            }
        }
        System.debug('@@@ CountryMapIso: '+mapCountryIso);
        return mapCountryIso; 
    }
}