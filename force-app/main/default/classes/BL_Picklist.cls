/**
 * @group General Utils
 * @author Jeremy Martiano
 * @since March 2020
 * @description Class to return the values of picklist fields listed in the Picklist Metadata
 */
public class BL_Picklist {
   
    /**
     * @description The Wrapper class for the picklist field information
     */
    public class PicklistWrapper{
        public String objectName {get; set;}
        public String fieldName {get;set;}
        public String controllingFieldName {get;set;}
        public String controllingFieldValue {get;set;}
        public String labels {get;set;}
        public String values {get;set;}
        public String id {get;set;}

        public PicklistWrapper(String objectName, String fieldName, String controllingFieldName, String controllingFieldValue){
            this.fieldName = fieldName != null ? fieldName : '';
            this.objectName = objectName;
            this.controllingFieldName = controllingFieldName;
            this.controllingFieldValue = controllingFieldValue;
            this.labels = '';
            this.values = '';
            this.id = String.valueOf((String.valueof(DateTime.now().getTime()) + this.FieldName + this.ObjectName + (String.isNotBlank(this.controllingFieldValue) ? this.controllingFieldValue : '')).hashCode()).replace('-','');
        }
    }


    /**
     * 
     * @param applicationName name of the application
     * @returns `List<PicklistWrapper>`
     * @description Return picklist information connected to specific application
     */
    public static List<PicklistWrapper> getPicklistValues(string applicationName){
        List<PicklistWrapper> picklists = new List<PicklistWrapper>();
        List<String> picklistNameItems = new list<String>();
        picklists  = getPicklistsRecords(applicationName);  
        return picklists;
    }

    /**
     * 
     * @returns `List<PicklistWrapper>`
     * @description Return picklist information
     */
    public static List<PicklistWrapper> getPicklistValues(){
        List<PicklistWrapper> picklists = new List<PicklistWrapper>();
        List<String> picklistNameItems = new list<String>();
        picklists  = getPicklistsRecords(null);  
        return picklists;
    }

    private static List<PicklistWrapper> getPicklistsRecords(string applicationName){
        List<PicklistWrapper> picklistResults = new List<PicklistWrapper>();

            List<String> fields = new List<String>();
            fields.addAll(BL_ObjectDescriber.getFields(BL_Constants.BL_PICKLIST_MDT_NAME).KeySet());
            List<BL_Picklist__mdt> allPicklists  = new BL_EasyQuery()
            .objectName(BL_Constants.BL_PICKLIST_MDT_NAME)
            .fields(fields)
            .condition(string.isBlank(applicationName)? null : BL_Constants.BL_AS_APPLICATION + ' = \'' +  applicationName + '\'')
            .executeQuery()
            .getSObjects();

        //Order Picklist with Labels
        for( BL_Picklist__mdt imPl : allPicklists) {
            if(imPl.Take_All_Object_List__c)
                preperObjectListPicklist(imPl, picklistResults);
            else
                preperObjectFieldPicklist(imPl, picklistResults);
        }

        return picklistResults;
    }

    private static void preperObjectListPicklist(BL_Picklist__mdt imPl, List<PicklistWrapper> picklistResults) {
        PicklistWrapper pL = new PicklistWrapper(imPl.ObjectName__c, getFieldName(imPl), null, null);

        //Get the excluded values
        Set<String> excludeFieldsSet = new Set<String>();
        if(imPl.Exclude_Fields__c != null){
            excludeFieldsSet.addAll(imPl.Exclude_Fields__c.split(';'));
        }

        String query = 'SELECT Id, Name FROM ' + imPl.ObjectName__c + ' WHERE Id NOT IN :excludeFieldsSet';
        List<Object> dataList = Database.query(query);
        List<String> values = new List<String>();
        List<String> labels = new List<String>();
        for(Object obj : dataList) {
            
            Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
            
            pL.Labels += (String)objMap.get('Name') + ';';
            pL.Values += (String)objMap.get('Id') + ';';
        }
        pL.Labels = pL.Labels.removeEnd(';');
        pL.Values = pL.Values.removeEnd(';');
        picklistResults.add(pL);
    }

    private static void preperObjectFieldPicklist(BL_Picklist__mdt imPl, List<PicklistWrapper> picklistResults) {
        PicklistWrapper pL = new PicklistWrapper(imPl.ObjectName__c, getFieldName(imPl), null, null);
        if( imPl.ControllingFieldName__c == null){
            Map<String,String> picklistValLabelMap = new Map<String,String>();
            //Get the excluded values
            Set<String> excludeFieldsSet = new Set<String>();
            if(imPl.Exclude_Fields__c != null){
                excludeFieldsSet.addAll(imPl.Exclude_Fields__c.split(';'));
            }

            //Get PicklistEntries
            List<Schema.PicklistEntry> pleList;
            try{
                pleList = (Schema.getGlobalDescribe())
                .get(imPl.ObjectName__c)
                .getDescribe()
                .fields
                .getMap()
                .get(imPl.FieldName__c)
                .getDescribe()
                .getPicklistValues();
            } catch(Exception e){
                System.debug(e.getStackTraceString() + ' ' + e.getMessage());
                return;
            }
            

            for(Schema.PicklistEntry sPle:pleList){
                picklistValLabelMap.put(sPle.getValue(), sPle.getLabel());
            }

            //if wanted Values in custom metadata
            if(imPl.Values__c != null){
                for(String s : imPl.Values__c.split(';')){
                    if(excludeFieldsSet.isEmpty() ||
                    (!excludeFieldsSet.isEmpty() && !excludeFieldsSet.contains(s))){
                        pL.Values += s.removeStart('\t')+';';
                        pL.Labels += picklistValLabelMap.get(s) != null ?
                            picklistValLabelMap.get(s).removeStart('\t') + ';' : s.removeStart('\t') + ';';
                    }
                }
            }

            else{
                for(Schema.PicklistEntry sPle : pleList){
                    if(excludeFieldsSet.isEmpty() ||
                    (!excludeFieldsSet.isEmpty() && !excludeFieldsSet.contains(sPle.getValue()))){
                        pL.Labels += (sPle.getLabel() + ';');
                        pL.Values += (sPle.getValue() + ';');
                    }
                }

            }

            pL.Labels = pL.Labels.removeEnd(';');
            pL.Values = pL.Values.removeEnd(';');
            picklistResults.add(pL);

        }  else {
            Map<String, List<MyPickListValues>> dependantPickListMap = getFieldDependencies(imPl.ObjectName__c,imPl.ControllingFieldName__c,imPl.FieldName__c);
            for(String key : dependantPickListMap.keySet()){
                PicklistWrapper dpL = new PicklistWrapper(
                    imPl.ObjectName__c,
                    getFieldName(imPl),
                    imPl.ControllingFieldName__c, 
                    key
                );
                for(MyPickListValues mypick : dependantPickListMap.get(key)){
                    dpL.Labels += mypick.Label+';';
                    dpL.Values += mypick.Value +';';
                }
                dpL.Labels=dpL.Labels.removeEnd(';');
                dpL.Values=dpL.Values.removeEnd(';');
                picklistResults.add(dpL);
            }
            
        }
    }

    public static Map<String, List<MyPickListValues>> getFieldDependencies(String objectName, String controllingField, String dependentField) {
        Map<String, List<MyPickListValues>> controllingInfo = new Map<String, List<MyPickListValues>>();

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            controllingInfo.put(currControllingValue.getValue(), new List<MyPickListValues>());
        }

        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);

            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);

            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();


            Integer baseCount = 0;

            for(Integer curr : hexString.getChars())
            {
                MyPickListValues mypicklistValues = new MyPickListValues();
                Integer val = 0;

                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }

                if((val & 8) == 8)
                {
                    mypicklistValues.Label = currDependentValue.getLabel();
                    mypicklistValues.Value = currDependentValue.getValue();
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(mypicklistValues);
                }
                if((val & 4) == 4)
                {
                    mypicklistValues.Label = currDependentValue.getLabel();
                    mypicklistValues.Value = currDependentValue.getValue();
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(mypicklistValues);                    
                }
                if((val & 2) == 2)
                {
                    mypicklistValues.Label = currDependentValue.getLabel();
                    mypicklistValues.Value = currDependentValue.getValue();
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(mypicklistValues);                    
                }
                if((val & 1) == 1)
                {
                    mypicklistValues.Label = currDependentValue.getLabel();
                    mypicklistValues.Value = currDependentValue.getValue();
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(mypicklistValues);                    
                }

                baseCount += 4;
            }            
        } 

    

        return controllingInfo;
    }

    private static String getFieldName(BL_Picklist__mdt imPl){
        return imPl.Is_API_Name__c ? imPl.QualifiedApiName : imPl.FieldName__c;
    }

    public class MyPickListInfo { public String validFor; }
    public class MyPickListValues {
        public String Label {get;set;}
        public String Value {get;set;}
    }

   
}