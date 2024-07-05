public class VO_data_Object_Creator_TEST {
    public static final Integer LOOP_SURVERY_LIST = 1;

    public static List<VO_Survey__c> createSurvayList()
    {
        List<String> typeValueList = getPickListValByAPIName('VO_Survey__c','Type__c');

        List<String> surveyTypeValueList = getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        List<String> statusValueList = getPickListValByAPIName('VO_Survey__c','Status__c');
        //List<String> root_CauseValueList = getPickListValByAPIName('VO_Survey__c','Root_Cause__c');
        List<String> channelValueList = getPickListValByAPIName('VO_Survey__c','Channel__c');
        List<Boolean> action_delegated_to_CAValueList = new List<Boolean>{true,false};
        System.debug('number of survey : ' +(typeValueList.size()*surveyTypeValueList.size()*
                                statusValueList.size()*channelValueList.size()
                                *action_delegated_to_CAValueList.size()));
        
        
        Integer i=0;       
        Map<Integer,string> mapStatus = new map<Integer,String>();       
        for(i = 0; i <2; i++){ 
            i++;
            mapStatus.put(i,statusValueList[i]);
        }
        i= 0; 
        Map<Integer,string> mapChannel = new map<Integer,String>();       
        for(i = 0; i <6; i++){ 
            i++;
            mapChannel.put(i,channelValueList[i]);
        }
        
        List<VO_Survey__c> surveyList = new List<VO_Survey__c>();
        Integer recNumber = 0;

        for(String typeValue :typeValueList )
        {
            for(String surveyType: surveyTypeValueList  )
            {
                for(String statusValue: mapStatus.values() )
                {
                //  for(String root_Cause:root_CauseValueList)
                //  {
                        for(string channel: mapChannel.values())
                        {
                            
                            for(Boolean action_delegated_to_CA: action_delegated_to_CAValueList)
                            {
                                for(Integer count = 0 ;count < LOOP_SURVERY_LIST; count++)
                                {
                                    recNumber ++;
                                    surveyList.add(createSurvey(typeValue, surveyType, statusValue, action_delegated_to_CA, recNumber, channel));
                                    //surveyList.add(createSurvey(typeValue, surveyType, statusValue, root_Cause, action_delegated_to_CA, recNumber, channel));
                                }
                            }
                        }
                //  }
                }
            }
        }
        return surveyList;
    }
    static VO_Survey__c createSurvey(String typeValue,String surveyType,String statusValue,Boolean action_delegated_to_CA,Integer recNumber, String channel)
    {
        return new VO_Survey__c (Status__c = statusValue, Action_delegated_to_CA__c = action_delegated_to_CA, Channel__c = channel 
                                , SurveyType__c = surveyType , Type__c = typeValue
                                ,Q01Answer__c ='ans' ,Q01Number__c = recNumber , Q01Section__c='sect',Q01Shortname__c = 'short',Q01Title__c ='title'
                                );
    }

    public static List<String> getPickListValByAPIName(String objectName, String fieldName)
    {
        List<String> ans = new List<String>();
        List<selectOption> ansSelectedOpt = getPicklistValues(objectName,fieldName,'');
        for(selectOption selOpt : ansSelectedOpt)
        {
            ans.add(selOpt.getValue());
        }
        return ans;
    }

    public static Store__c createStore(String storeName, String RetailStoreId, String StoreType)
    {
        return new Store__c(Name = storeName ,ShortName__c = storeName, RetailStoreId__c = RetailStoreId, StoreType__c = StoreType);
        
    }

    public static List<Store__c> createStoreByNum(Integer count)
    {
        List <Store__c> storeList = new List <Store__c>();
        for(Integer i = 0; i<count;i++)
            storeList.add(createStore('store' + i,'A'+i,'Store'));
        //storeList.add(createStore('LV PARIS GALERIES LAFAYETTE','A07','Store'));
        //storeList.add(createStore('LV PARIS CHAMPS ELYSEES','A06','Store'));
        return storeList;
    }

    public static Account createAccount(String accountLastName)
    {
        Id recordTypeBusinessAccount = null;
        if(Account.sObjectType.getDescribe().getRecordTypeInfosByName().containsKey('Person Account')){
            recordTypeBusinessAccount  = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        }
        return new Account(LastName = accountLastName, RecordTypeId = recordTypeBusinessAccount);
    }


    /* KTC */
    /**
     * [Get PickList Values of field by meta data]
     * @param  objectName [Object name]
     * @param  fieldName  [Field name of picklist type]
     * @param  firstVal   [Optional first value for the picklist list]
     * @return            [List of values for the picklist]
     * @createdBy         Niv Goldenberg on 01/06/2015
     * @modifiedBy        Niv Goldenberg on 01/06/2015
     */
    public static List<selectOption> getPicklistValues(String objectName, String fieldName, String unselectedVal) 
    {
        // New list for holding all of the picklist options.
        List<selectOption> options = new List<selectOption>(); 
        
        // If there is a first value being provided.
        if (String.isNotBlank(unselectedVal)) 
        {
            options.add(new selectOption(null, unselectedVal)); 
        }
        
        // Grab the sobject that was passed.
        Schema.sObjectType sobjectType = Schema.getGlobalDescribe().get(objectName);

        // Describe the sobject.
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe(); 
        // Get a map of fields for the passed sobject.
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap(); 
        // Grab the list of picklist values for the passed field on the sobject.
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPickListValues(); 
        
        // For all values in the picklist list.
        for (Schema.PicklistEntry picklistEntryItem : picklistValues) 
        { 
            if(picklistEntryItem.getValue() != 'unknown' && picklistEntryItem.getValue() != 'Other' ) 
            {   
                // Add the value and label to our final list.     
                options.add(new selectOption(picklistEntryItem.getValue(), picklistEntryItem.getLabel())); 
            }
        }
        
        return options; 
    }


}