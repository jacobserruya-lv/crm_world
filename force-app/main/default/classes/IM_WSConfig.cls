@RestResource(urlMapping='/GetConfigValues')
global with sharing class IM_WSConfig {

    static String getIconVersionFromHeader(RestRequest req) {
        String iconVersion;
        String userAgent = req.headers.get('User-Agent');
        if(userAgent != null) {
            List<String> userAgentSplit = userAgent.split('ICON');
            if(userAgentSplit[1] != null) {
                userAgentSplit = userAgentSplit[1].split('/');
                if(userAgentSplit[1] != null) {
                    userAgentSplit = userAgentSplit[1].split('(0)');
                    String splitValue = userAgentSplit[0].substring(0, userAgentSplit[0].length() -1);
                    if(splitValue.length() <= 7) {
                        iconVersion = splitValue;
                    }
                }
            }    
        }
        return iconVersion;
    }

    @HttpPost
    global static Void WSConfigPost() {
        RestRequest req = RestContext.request;
        try{
            Map<String,Object> body = new Map<String,Object>();
            if ( req.requestBody != null ){
                body = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
            }
            String iconVersion = (String)body.get('iconVersion');
            List<User> currentUser = [SELECT id FROM User WHERE id = :UserInfo.getUserId()];
            if(currentUser[0] != null) {
                currentUser[0].IconVersion__c = iconVersion;    
                update currentUser;
            }
        }catch(Exception e) {
            string error = e.getMessage() + '\n\n' + e.getLineNumber();
           // UtilsLogs.addLog('ICON','IM_CheckPushNotifications', JSON.serialize(req.params), JSON.serialize(req),'', error);
            new Logs.ERROR('IM_WSConfig', 'API', e);
        }
    }

    @HttpGET
    global static Void WSConfig() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Integer i=1;
        ResponseHandler response =new ResponseHandler();
        response.Picklists =new List<PickList>();
        res.addHeader('Content-Type','application/json');
        res.statusCode= 200;

        try{
            User u = [SELECT Country__c,Currency__c,ProfileId FROM User WHERE Id = :UserInfo.getUserId()];
            response.Config_Data = new ConfigData();
            response.Config_Data.UserCurrency = u.Currency__c;
            //Get all picklist from custom setting
            List<IM_PicklistConfig__c> allPicklists = [
                SELECT Id, Name, FieldName__c,ObjectName__c,Values__c,GetCustomLabels__c, Exclude_Fields__c,ControllingFieldName__c 
                FROM IM_PicklistConfig__c
            ];
            //Get Country config of the user
            List<CountryConfig__c> countryConfig = [
                SELECT Id, Name, ClientNameDisplay__c, Country_Code__c, Law_Settings__c, SecondName__c, CannotEditClients__c, 
                    Kakao__c, Line__c, Wechat__c, WhatsApp__c, Zalo__c, Viber__c, Line_Works__c
                FROM CountryConfig__c 
                WHERE Name = :u.Country__c
            ];
          
            for(CountryConfig__c cc: countryConfig) {
                response.Config_Data.ClientNameDisplay = cc.ClientNameDisplay__c;
                response.Config_Data.Line = cc.Line__c;
                response.Config_Data.Kakao = cc.Kakao__c;
                response.Config_Data.Wechat = cc.Wechat__c;
                response.Config_Data.WhatsApp = cc.WhatsApp__c;
                response.Config_Data.Zalo = cc.Zalo__c;
                response.Config_Data.Viber = cc.Viber__c;
                response.Config_Data.LineWorks = cc.Line_Works__c;
                response.Config_Data.SecondName = cc.SecondName__c;
                response.Config_Data.CannotEditClients = cc.CannotEditClients__c;
            }
            //Get all Law Settings Country
            
            response.Config_Data.Law_SettingsNames = '';
            response.Config_Data.Law_SettingsCodes  = '';
            if( u.ProfileId != System.Label.IC_System_Admin_Profile_Id && u.ProfileId != System.Label.IC_LVAdministrator_ProfileID ){
	            List<CountryConfig__c> lawSettingsList = [
                    SELECT Id,Name,Law_Settings__c, Country_Code__c 
                    FROM CountryConfig__c 
                    WHERE Law_Settings__c = TRUE AND Name != :u.Country__c 
                ];
	            for(CountryConfig__c ls:lawSettingsList){
	                response.Config_Data.Law_SettingsNames += ls.Name + ';' ;
	                response.Config_Data.Law_SettingsCodes += ls.Country_Code__c + ';' ;
	            }
            }

            //Get StorePilot
            response.Config_Data.IsInStorePilot = IC_UTILS.isInPilotBeta('ICON');

            //Order Picklist with Labels
            for(IM_PicklistConfig__c imPl:allPicklists) {
                if( imPl.ControllingFieldName__c == null){
                    PickList pL = new PickList(
                            imPl.ObjectName__c.removeEnd('__c').removeEnd('__pc'),
                            imPl.FieldName__c.removeEnd('__c').removeEnd('__pc'),
                            null, 
                            null
                        );
                    Set<String>excludeFieldsSet =new Set<String>();
                    if(imPl.Exclude_Fields__c!=null){
                        excludeFieldsSet.addAll(imPl.Exclude_Fields__c.split(';'));
                    }
                    else{
                        excludeFieldsSet.clear();
                    }
                    Map<String,String> picklistValLabelMap=new Map<String,String>();
                    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
                    Schema.DescribeFieldResult fieldResult = (gd.get(imPl.ObjectName__c)).getDescribe().fields.getMap().get(imPl.FieldName__c).getDescribe();

                    List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
                    for(Schema.PicklistEntry sPle:pleList){
                        picklistValLabelMap.put(sPle.getValue(),sPle.getLabel());
                    }

                    if(imPl.Values__c!=null){
                        String[] picklistValues=imPl.Values__c.split(';');
                        for(String s:picklistValues){ 
                            if(excludeFieldsSet.isEmpty() || !excludeFieldsSet.isEmpty()&&!excludeFieldsSet.contains(s)){ 
                                pL.Values+=s.removeStart('\t')+';';
                                if(!imPl.GetCustomLabels__c){
                                     pL.Labels+=(picklistValLabelMap.get(s)!=null?picklistValLabelMap.get(s).removeStart('\t')+';':s.removeStart('\t')+';');
                                }
                                else{
                                    pL.Labels+=(getCustomLabel(s)!=''?getCustomLabel(s)+';':(picklistValLabelMap.get(s)!=null?picklistValLabelMap.get(s).removeStart('\t')+';':s.removeStart('\t')+';'));
                                }
                            }
                        }
                    }
                    else{
                        for(Schema.PicklistEntry sPle:pleList){
                            if(excludeFieldsSet.isEmpty()|| !excludeFieldsSet.isEmpty()&&!excludeFieldsSet.contains(sPle.getValue())){
                                pL.Labels+=(sPle.getLabel()+';');    
                                pL.Values+=(sPle.getValue()+';');
                            }
                        }

                    }
                    pL.Labels=pL.Labels.removeEnd(';');
                    pL.Values=pL.Values.removeEnd(';');
                    response.Picklists.add(pL);

                } else {
                    Map<String, List<MyPickListValues>> dependantPickListMap = getFieldDependencies(imPl.ObjectName__c,imPl.ControllingFieldName__c,imPl.FieldName__c);
                    Integer j = 1;
                    for(String key : dependantPickListMap.keySet()){
                        PickList dpL = new PickList(
                            imPl.ObjectName__c.removeEnd('__c').removeEnd('__pc'),
                            imPl.FieldName__c.removeEnd('__c').removeEnd('__pc'),
                            imPl.ControllingFieldName__c.removeEnd('__c').removeEnd('__pc'), 
                            key
                        );
                        for(MyPickListValues mypick : dependantPickListMap.get(key)){
                            dpL.Labels += mypick.Label+';';
                            dpL.Values += mypick.Value +';';
                        }
                        dpL.Labels=dpL.Labels.removeEnd(';');
                        dpL.Values=dpL.Values.removeEnd(';');
                        response.Picklists.add(dpL);
                        j++;
                    }
                    
                }
                
                i++;
            }
            String result  = JSON.serialize(response);
          //  UtilsLogs.addLog('ICON', 'IM_WSConfig', '', JSON.serialize(req), result, '');
            new Logs.DEBUG('IM_WSConfig','API',result);
            res.responseBody = Blob.valueOf(result);
            res.statusCode = 200;
        } catch(Exception e){
            string error = e.getMessage() + '\n\n' + e.getLineNumber();
            res.responseBody = Blob.valueOf(JSON.serialize(error));
            res.statusCode = 400;
           // UtilsLogs.addLog('ICON', 'IM_WSConfig', '', JSON.serialize(req),'', error);
            new Logs.ERROR('IM_WSConfig','CALLOUT',e);

        }
    }
    global class ResponseHandler {
        public List<PickList> Picklists {get; set;} 
        public ConfigData Config_Data {get; set;}      
           
    }

    global class PickList{
        public String Id {get;set;}
        public String ObjectName {get; set;}
        public String FieldName {get;set;}
        public String ControllingFieldName {get;set;}
        public String ControllingFieldValue {get;set;}
        public String Labels {get;set;}
        public String Values {get;set;}

        public PickList(String objectName, String fieldName, String controllingFieldName, String controllingFieldValue){
            this.FieldName = fieldName != null ? fieldName : '';
            this.ObjectName = objectName;
            this.ControllingFieldName = controllingFieldName;
            this.ControllingFieldValue = controllingFieldValue;
            this.Labels = '';
            this.Values = '';
            this.Id = String.valueof(DateTime.now().getTime()) + this.FieldName + this.ObjectName + 
            (this.ControllingFieldValue != null ? this.ControllingFieldValue : '');
        }
    }

    global class ConfigData{
        public String ClientNameDisplay {get; set;}
        public Boolean Kakao {get; set;}
        public Boolean Line {get; set;}
        public Boolean Wechat {get; set;}
        public Boolean WhatsApp {get; set;}
        public Boolean Zalo {get; set;}
        public Boolean LineWorks {get; set;}
        public Boolean Viber {get; set;}
        public Boolean SecondName {get; set;}
        public String Law_SettingsNames {get; set;}
        public String Law_SettingsCodes {get; set;}
        public Boolean CannotEditClients {get;set;}
        public String UserCurrency {get; set;}
        public Boolean IsInStorePilot {get;set;}
        public String TechnicalUserIds {get;set;}

    }

    
    public static String getCustomLabel(String labelName){
        if(labelName=='Face to Face'){
            return System.Label.IC_FacetoFace;
        }else if(labelName=='Call'){
            return System.Label.IC_Call;
        }else if(labelName=='Letter'){
            return System.Label.IC_Letter;
        }else if(labelName=='Email'){
            return System.Label.IC_Email;
        }else if(labelName=='SMS'){
            return System.Label.IC_SMS;
        }else{
            return '';
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
            System.debug('ControllingField: Label:' + currControllingValue.getValue());
            controllingInfo.put(currControllingValue.getValue(), new List<MyPickListValues>());
        }

        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);

            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);

            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();

            System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);

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
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getValue());
                    mypicklistValues.Label = currDependentValue.getLabel();
                    mypicklistValues.Value = currDependentValue.getValue();
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(mypicklistValues);
                }
                if((val & 4) == 4)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getValue());
                    mypicklistValues.Label = currDependentValue.getLabel();
                    mypicklistValues.Value = currDependentValue.getValue();
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(mypicklistValues);                    
                }
                if((val & 2) == 2)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getValue());
                    mypicklistValues.Label = currDependentValue.getLabel();
                    mypicklistValues.Value = currDependentValue.getValue();
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(mypicklistValues);                    
                }
                if((val & 1) == 1)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getValue());
                    mypicklistValues.Label = currDependentValue.getLabel();
                    mypicklistValues.Value = currDependentValue.getValue();
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(mypicklistValues);                    
                }

                baseCount += 4;
            }            
        } 

        System.debug('ControllingInfo: ' + controllingInfo);

        return controllingInfo;
    }

    public class MyPickListInfo { public String validFor; }
    public class MyPickListValues {
        public String Label {get;set;}
        public String Value {get;set;}
    }
    
}