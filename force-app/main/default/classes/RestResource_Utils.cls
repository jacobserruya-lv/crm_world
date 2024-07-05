global without sharing class RestResource_Utils {
    
    /*
*** DESCRIPTION Get request type
*** RETURN      String   Request name
*/
    global static String getRequestType(RestRequest req){
        String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        return service;
    }
    
    /*
*** DESCRIPTION Serialize sObject with only specific fields 
*** 			By default: all fields (whitout "attributes")
*** RETURN      Pretty JSON 
*/
    global static Map<String,Object> prettyJSON(sObject obj, List<String> fields)  {
        
        Map<String,Object> jsonObj = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
        
        return removeAttributes(jsonObj, fields);
    }
    
    global static Map<String,Object> prettyJSON(sObject obj)  {
        
        Map<String,Object> jsonObj = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
        
        return removeAttributes(jsonObj, new List<String> ());
    }
    
    global static List<Map<String,Object>> prettyJSON(List<sObject> objs, List<String> fields)  {
        
        List<Map<String,Object>> jsonList = new List<Map<String,Object>>();
        
        for(sObject obj : objs) {
            Map<String,Object> jsonObj = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
            jsonList.add(removeAttributes(jsonObj, fields));
        }
        
        return jsonList;
    }
    
    global static Map<String,Object> removeAttributes(Map<String,Object> jsonObj, List<String> fields)  {
        
        if(jsonObj != null) {
            
            for(String key : jsonObj.keySet()) {
                if( (fields.isEmpty() && key == 'attributes') || (!fields.isEmpty() && !fields.contains(key)) ) {
                    jsonObj.remove(key);
                } else {
                    if(jsonObj.get(key) instanceof Map<String,Object>) {
                        removeAttributes((Map<String,Object>)jsonObj.get(key), fields);
                    }
                    if(jsonObj.get(key) instanceof List<Object>) {
                        for(Object listItem : (List<Object>)jsonObj.get(key)) {
                            if(listItem instanceof Map<String,Object>)  {
                                removeAttributes((Map<String,Object>)listItem, fields);
                            }
                        }
                    }
                }
            }
        }
        
        return jsonObj;
    }
    
    global static Object parseJSON(Object objectJSON, System.Type apexType) {
        
        return JSON.deserialize(JSON.serialize(objectJSON), apexType);
        
    }
    
    global static Schema.DisplayType getFieldType(String fieldName, String objectName){
        Schema.DescribeSObjectResult result = Schema.getGlobalDescribe().get(objectName).getDescribe();
        
        if (result.fields.getMap().get(fieldName) == null){
            return null;
        }
        
        return result.fields.getMap().get(fieldName).getDescribe().getType();
    }
    
    global static SObject createObject(Map<String,Object> jsonMap, String objectName, SObject sObj){
        
        for(String key : jsonMap.keySet()){
            
            Schema.DescribeSObjectResult result = Schema.getGlobalDescribe().get(objectName).getDescribe();
            Set<String> fields = result.fields.getMap().keySet();
            
            if (fields.contains(key.toLowerCase())){
                Schema.DisplayType fieldType = getFieldType(key, objectName);
                String value = String.valueOf(jsonMap.get(key));
                
                if (fieldType == Schema.DisplayType.Date){
                    sObj.put(key, String.isEmpty(value) ? null : Date.valueOf(value));
                }
                else if(fieldType == Schema.DisplayType.DateTime){
                    sObj.put(key, String.isEmpty(value) ? null : (DateTime)JSON.deserialize('"' + value + '"', DateTime.class));
                }
                else if (fieldType == Schema.DisplayType.Percent || fieldType == Schema.DisplayType.Currency){
                    sObj.put(key, String.isEmpty(value) ? null : Decimal.valueOf(value));
                }
                else if (fieldType == Schema.DisplayType.Double){
                    sObj.put(key, Double.valueOf(value));
                }
                else if (fieldType == Schema.DisplayType.Integer){
                    sObj.put(key, Integer.valueOf(value));
                }
                else if (fieldType == Schema.DisplayType.Base64){
                    sObj.put(key, Blob.valueOf(value));
                }
                else if (fieldType == Schema.DisplayType.Boolean){
                    sObj.put(key, Boolean.valueOf(value));
                }
                else{
                    sObj.put(key, value);
                }
            }
            
        }
        
        return sObj;
    }
    
    global static String removeNulls(String jsonString) {
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        for (String k : m.keySet()) {
            if (m.get(k) == null) {
                m.remove(k);
            }
        }
        
        return JSON.serialize(m);
    }
    global static String getMyccBody() {
        String str = '{';
        str += '  "FirstName": "TEST MYCC03",';
        str += '  "LastName": "POSTMAN03",';
        str += '  "LocalMobilePhone__pc": 15677382799,';
        str += '  "MobilePhoneCountryCallingCode__pc": 86,';
        str += '  "MobilePhoneCountryCode__pc" : "CN",';
        str += '  "PersonMobilePhone": "+8615677382799",';
        str += '  "PersonEmail": "",';
        str += '  "Can_Be_Contacted_By_Email__pc": true,';
        str += '  "Can_Be_Contacted_By_Mail__pc": false,';
        str += '  "Can_Be_Contacted_By_Phone__pc": false,';
        str += '  "Can_Be_Contacted_By_SMS__pc": false,';
        str += '  "DreamID__c": "",';
        str += '  "AttachedStoreCode__pc": "",';
        str += '  "Salutation": "02",';
        str += '  "Id": null,';
        str += '  "Gender__pc": "",';
        str += '  "Source__c": "Identity",';
        str += '  "BirthdateDay__pc": "",';
        str += '  "BirthdateMonth__pc": "",';
        str += '  "BirthdateYear__pc": "",';
        str += '  "PrimaryAddressLine1__pc" : "",';
        str += '  "PrimaryAddressLine2__pc" : "",';
        str += '  "PrimaryAddressLine3__pc": "",';
        str += '  "PrimaryZipCode__pc" :"",';
        str += '  "PrimaryCity__pc" :"",';
        str += '  "PrimaryStateProvince__pc" :"",';
        str += '  "HomeAddressCountryCode__pc" : "ATA",';
        str += '  "WWEmployeeNumber": "JPE21641899"';
        str += ' }'; 
        return str;
    }
    
    /*********   HELPER WRAPPER   *********/
    global class Response {
        
        Boolean done;
        Object[] records;
        Integer totalSize;
        
        global Response(Object[] records){
            this.totalSize = records.size();
            this.records = records;
            this.done = true;
        }
    }
    
    global class Error {
        
        Boolean done;
        String message;
        String code;
        
        global Error(String message, String code){
            this.message = message;
            this.code = code;
            this.done = false;
        }
    }
}