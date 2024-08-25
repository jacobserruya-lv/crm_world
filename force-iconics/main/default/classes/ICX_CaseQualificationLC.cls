/**
 * Controller for ICX_CaseQualification_Flow (Lightning Component)
 **/
public with sharing class ICX_CaseQualificationLC {

    @AuraEnabled(cacheable=true)
    public static String getPicklistMap(String sObjectType, String controllingFieldName, String dependentFieldName) {
        Map<String, List<String>> dependentOptions = DependentPicklistBitset.GetDependentOptions(sObjectType, controllingFieldName, dependentFieldName);

        Map<String, Schema.PicklistEntry> picklistEntryMap = new Map<String, Schema.PicklistEntry>();
		String optionJson = getOptions(sObjectType, dependentFieldName);
        System.debug('optionJson=' + optionJson);
        List<Schema.PicklistEntry> optionList = (List<Schema.PicklistEntry>) JSON.deserialize(optionJson, List<Schema.PicklistEntry>.class);
        for (Schema.PicklistEntry entry : optionList) {
            picklistEntryMap.put(entry.value, entry);
        }
        System.debug('picklistEntryMap=' + picklistEntryMap);
        
        Map<String, List<Schema.PicklistEntry>> entryMap = new Map<String, List<Schema.PicklistEntry>>();
        for (String dependentOption : dependentOptions.keySet()) {
            List<String> dependentOptionList = dependentOptions.get(dependentOption);
            List<Schema.PicklistEntry> pickList = new List<Schema.PicklistEntry>();
            for (String picklistValue : dependentOptionList) {
                System.debug('picklistValue=' + picklistValue);
                if (picklistEntryMap.get(picklistValue) != null) {
                    pickList.add(picklistEntryMap.get(picklistValue));
                } else {
                    // problem as DependentPicklistBitset doesn't manage API name (only Label). This class is used for Catalogue. So this is a workaround
                    for (Schema.PicklistEntry entry : optionList) {
                        if (String.isNotBlank(picklistValue) && picklistValue.equals(entry.label)) {
                            pickList.add(entry);
                            break;
                        }
                    }
                }
            }
            entryMap.put(dependentOption, pickList);
        }
        
        return JSON.serialize(entryMap);
    }

	// Build a list of picklist options (based on DependentPicklistBitset class)
    @AuraEnabled(cacheable=true)
	public static String getOptions(String sObjectType, String controllingFieldName) {
		List<Schema.PicklistEntry> objResults = new List<Schema.PicklistEntry>();
		
		//get the string to sobject global map
		Map<String, Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
		List<String> counts = new List<String>();
		if (!objGlobalMap.containsKey(sObjectType)){
			return null;
		}
		//get the type being dealt with
		Schema.SObjectType pType = objGlobalMap.get(sObjectType);
		Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
		//verify field names
		if (!objFieldMap.containsKey(controllingFieldName)) {
			return null;
		}
		//get the control values
		List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(controllingFieldName).getDescribe().getPicklistValues();
		
		//iterate through the values and get the ones valid for the controlling field name
		DependentPicklistBitset objBitSet = new DependentPicklistBitset();
		
		//set up the results
		for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){
			//get the pointer to the entry
			Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
            if (ctrl_entry.isActive()) {
                //get the label
                String pControllingLabel = ctrl_entry.getLabel();
                String pValue = ctrl_entry.getValue();
                //create the entry with the label
                //objResults.add(pControllingLabel);
                objResults.add(ctrl_entry);
            }
		}
        System.debug('objResults=' + objResults);
        return JSON.serialize(objResults);
    }

   /* @AuraEnabled(cacheable=true)
    public static String getPicklistFast(String origin) {
        String recordTypeId;
        
        String recordTypeDeveloperName;
        if ('Phone'.equals(origin)) {
            recordTypeDeveloperName = 'Call_Case';
            //recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('Call_Case').getRecordTypeId();
        } else if ('Web'.equals(origin) || 'Email'.equals(origin)) {
            recordTypeDeveloperName = 'Web_Email_Case';
        }

        if (String.isNotBlank(recordTypeDeveloperName)) {
            recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
        }

    	String result = ICX_FastQualification.getPicklistFast(recordTypeId, 'Case', new List<String> {'Type', 'Category__c', 'Domaine__c'}, new List<Boolean> {true, false, true});
    	return result;
    }*/

    @AuraEnabled(cacheable=true)
    public static String getRecordTypeId(Id recordId, String sObjectType) {
        String recordTypeId;
        
        if (String.isNotBlank(recordId) && String.isNotBlank(sObjectType)) {
            if ('Task'.equals(sObjectType)) {
                // As User Interface API is not working for the Task object, the Case as Call record type will give dependant picklist instead
                //recordTypeId = IconicsSettings__c.getInstance().CallRecordTypeID__c;

                Task tsk = [SELECT Id, RecordTypeId, CallType FROM Task WHERE Id = :recordId];
                if ('Outbound'.equals(tsk.CallType)) {
                    Id clientelingRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('ICONICS_Clienteling').getRecordTypeId();
                    System.debug('getRecordTypeId>clientelingRTId/tsk.RecordTypeId=' + clientelingRTId + '/' + tsk.RecordTypeId);
                    if (clientelingRTId.equals(tsk.RecordTypeId)) {
                        recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Clienteling').getRecordTypeId();
                    } else {
                        recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call_Case').getRecordTypeId();
                    }
                } else {
                    recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call_Case').getRecordTypeId();
                }
                //sObjectType = 'Case';
            } else {
                String query = 'SELECT RecordTypeId FROM ' + sObjectType + ' WHERE Id = \'' + recordId + '\'';                
                SObject objectResult = (SObject) Database.query(query);
               // if (objectResult != null) {
                if ('Case'.equals(sObjectType)) {
                    recordTypeId = ((Case) objectResult).RecordTypeId;
                } else if ('LiveChatTranscript'.equals(sObjectType) || 'MessagingSession'.equals(sObjectType)) {
                    // As User Interface API is not working for the LiveChatTranscript object, the Case as Call record type will give dependant picklist instead
                    recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Chat').getRecordTypeId();

                    // TODO : for now (18th April 19), no Record Type is set in integ2, pprod, production. Deployment error:
                    // "Variable does not exist: recordTypeId" => as no Record Type is created
                    // IDEA: create the Record Type in a near deployment in order to deploy the Qualification Flow for Chat
                    
                    // Problem : LiveChatTranscript record type id field is empty on creation. Workaround : take the first OR Workflow on creation will force the Record Type Id
                    //List<Schema.RecordTypeInfo> rtChatList = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfos();//.get('Call_Case').getRecordTypeId();
                    //recordTypeId = (rtChatList != null && !rtChatList.isEmpty() ? rtChatList.get(0).getRecordTypeId() : null);

                    //LiveChatTranscript chat = (LiveChatTranscript) objectResult;
                    //if (chat != null) {
                    //    recordTypeId = chat.RecordTypeId;
                    //}
                }
            }
        }
    	return recordTypeId;
    }

    @AuraEnabled(cacheable=true)
    public static ICX_PicklistValuesParser getPicklist(Id recordTypeId, String sObjectType) {
        ICX_PicklistValuesParser result;
        System.debug('recordTypeId / sObjectType=' + recordTypeId + '/' + sObjectType);
        if (String.isNotBlank(recordTypeId) && String.isNotBlank(sObjectType)) {
            result = ICX_FastQualification.callWebservice(sObjectType, recordTypeId);
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static String getFieldList(String parser, List<String> fieldLevelList, List<Boolean> showParentWithChildrenList) {
        String result;
        if (String.isNotBlank(parser)) {
            ICX_PicklistValuesParser parse = (ICX_PicklistValuesParser) JSON.deserialize(parser, ICX_PicklistValuesParser.class);
            result = ICX_FastQualification.getPicklistFast(parse, fieldLevelList, showParentWithChildrenList);
        }
        return result;
    }

}