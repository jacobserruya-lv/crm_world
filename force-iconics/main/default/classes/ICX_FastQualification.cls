/**
 * class for Dependent Picklists in a search bar component 
 **/
public inherited sharing class ICX_FastQualification {

    // recordTypeId : used to get Dependant Picklist depending on the record type
    // objectType: object API name
    // fieldLevelList : List of field API name (ordered by Parent > Child > sub-child > ...)
    // showParentWithChildrenList : List of boolean to show/hide parent with children (ordered by Parent > Child > sub-child > ...)
    // ICX_CaseQualificationLC.getPicklistFast('5003D0000037wz3QAA','Case', new List<String> {'Type', 'Category__c', 'Domaine__c'}, new List<Boolean> {true, false, true});
    @AuraEnabled(cacheable=true)
    public static String getPicklistFast(Id recordTypeId, String objectType, List<String> fieldLevelList, List<Boolean> showParentWithChildrenList) {
        Set<PicklistFast> picklistFastList = new Set<PicklistFast>();

        //Id recordTypeId = getRecordTypeId(objectType, recordId);
        System.debug('fieldLevelList=' + fieldLevelList);
        System.debug('objectType=' + objectType);
        try {
            ICX_PicklistValuesParser pl = callWebservice(objectType, recordTypeId);
            System.debug(JSON.serialize(pl));
            
            if (pl != null && fieldLevelList != null && showParentWithChildrenList != null) {
                Map<String, List<PicklistFast>> levelMap;

                for (Integer i=0; i < fieldLevelList.size(); i++) {
                    String fieldName = fieldLevelList.get(i);
                    Boolean showParentWithChildren = showParentWithChildrenList.get(i);

                    levelMap = generateList2(pl.picklistFieldValues.get(fieldName), i+1, levelMap, picklistFastList, showParentWithChildren, fieldName);
                }
            }

        } catch(Exception e) {
            System.debug('Exception e=' + e);
        }
        return JSON.serialize(new List<PicklistFast>(picklistFastList));
    }
    
    // Want to use it in the ICX_QualificationLookup
    @AuraEnabled(cacheable=true)
    public static ICX_PicklistValuesParser callWebservice(String objectType, Id recordTypeId) {
        ICX_PicklistValuesParser pl;
        try {
            if (String.isNotBlank(objectType) && String.isNotBlank(recordTypeId)) {
                //String instance = System.URL.getSalesforceBaseURL().toExternalForm();
                string instance = System.Url.getOrgDomainUrl().toExternalForm();

                HttpRequest httpRequest = new HttpRequest();
                httpRequest.setEndpoint(instance + '/services/data/v46.0/ui-api/object-info/' + objectType + '/picklist-values/' + recordTypeId);
                System.debug('CALL=' + instance + '/services/data/v46.0/ui-api/object-info/' + objectType + '/picklist-values/' + recordTypeId);
                httpRequest.setMethod('GET');
                httpRequest.setTimeout(120000);
                httpRequest.setHeader('Encoding', 'UTF-8');
                httpRequest.setHeader('Accept', 'application/json');
                httpRequest.setHeader('Content-Type', 'application/json');
                system.debug('BEARER=  Bearer '+ getSessionIdFromVfPage());
                httpRequest.setHeader('Authorization', 'Bearer '+ getSessionIdFromVfPage());

                Http httpProtocol = new Http();
                HttpResponse httpResponse = httpProtocol.send(httpRequest);
                //System.debug('httpResponse ' + httpResponse);
                // System.debug('response.getBody()=' + httpResponse.getBody());
    
                String bodyUnescape = httpResponse.getBody().unescapeXml(); // values from controllingValues: &quot;&lt;Black&amp;White&gt;,/green(yellow)&quot; => "<Black&White>"'
                System.debug('bodyUnescape=' + bodyUnescape);
                pl = (ICX_PicklistValuesParser) JSON.deserialize(bodyUnescape, ICX_PicklistValuesParser.class);
            }
        } catch(Exception e) {
            System.debug('Exception e=' + e);
        }
        return pl;
    }

    @AuraEnabled(cacheable=true)
    public static String getPicklistFast(ICX_PicklistValuesParser parser, List<String> fieldLevelList, List<Boolean> showParentWithChildrenList) {
        Set<PicklistFast> picklistFastList = new Set<PicklistFast>();

        System.debug('fieldLevelList/showParentWithChildrenList/parser=' + fieldLevelList + '/' + showParentWithChildrenList + '/' + parser);
        try {
            ICX_PicklistValuesParser pl = parser;
            System.debug('pl=' + JSON.serialize(pl));
            
            if (pl != null && fieldLevelList != null && showParentWithChildrenList != null) {
                Map<String, List<PicklistFast>> levelMap;

                for (Integer i=0; i < fieldLevelList.size(); i++) {
                    String fieldName = fieldLevelList.get(i);
                    Boolean showParentWithChildren = showParentWithChildrenList.get(i);
                    System.debug('fieldName/showParentWithChildren=' + fieldName + '/' + showParentWithChildren);

                    levelMap = generateList2(pl.picklistFieldValues.get(fieldName), i+1, levelMap, picklistFastList, showParentWithChildren, fieldName);
                }
            }

        } catch(Exception e) {
            System.debug('Exception e=' + e);
        }
        return JSON.serialize(new List<PicklistFast>(picklistFastList));
    }

    //Map<String, Pick> level1 = buildPick(List<level1 pick>, int level1, map controllingMap<api name, pick>, list<PicklistFast>)
	// Map<String, List<PicklistFast>> : one value can be in many controlling values
    private static Map<String, List<PicklistFast>> generateList2(ICX_PicklistValuesParser.PicklistValues values, Integer level, Map<String, List<PicklistFast>> controllingFastMap, Set<PicklistFast> picklistFastList, Boolean showParentWithChildren, String fieldName) {
        Map<String, List<PicklistFast>> fastMap = new Map<String, List<PicklistFast>>();
        System.debug('controllingFastMap=' + controllingFastMap);
        System.debug('values=' + values);
        System.debug('controllerValues=' + controllingFastMap);
        
        // convert from <String, Int> format to <Int, List<PicklistFast>> format
        Map<Integer, List<PicklistFast>> controllerMap = new Map<Integer, List<PicklistFast>>();
//        if (controllingFastMap != null && values.controllerValues != null ) {
        if (values.controllerValues != null ) {
             System.debug('values.controllerValues=' + values.controllerValues);
            Map<String, Integer> controllerValues = values.controllerValues;
            for (String controllerValue : controllerValues.keySet()) {
                //String formatValue = controllerValue;//.escapeXml();
                // values from controllingValues: &quot;&lt;Black&amp;White&gt;,/green(yellow)&quot; => "<Black&White>"'
                
                List<PicklistFast> controllingFastList = (controllingFastMap != null ? controllingFastMap.get(controllerValue) : null);
                // get existing controllingFastMap values (from the parent field)
                if (controllingFastList != null && !controllingFastList.isEmpty()) {
                    //System.debug('formatValuee=' + formatValue);
                    //System.debug('controllingFastMap.get(formatValue)=' + controllingFastMap.get(formatValue));
                    Integer index = controllerValues.get(controllerValue);
                    
                    if (controllerMap.get(index) == null) {
                        controllerMap.put(index, new List<PicklistFast>());
                    }
                    controllerMap.get(index).addAll(controllingFastList);
                    System.debug('index/controllerMap=' + index + '/' + controllerMap.get(index));
                } else {
                    // otherwise, for example, get values from a 2nd and 3rd fields (and add temporary level 1 values)
                    System.debug('ELSE GET CONTROLLING');
                    Integer index = controllerValues.get(controllerValue);
                    if (controllerMap.get(index) == null) {
                        controllerMap.put(index, new List<PicklistFast>());
                    }

                    PicklistFast fast = new PicklistFast();
                    ICX_PicklistValuesParser.PicklistValue val = new ICX_PicklistValuesParser.PicklistValue();
                    val.value = controllerValue;

                    if (level == 1) fast.level1 = val;
                    if (level == 2) fast.level2 = val;
                    if (level == 3) fast.level3 = val;

                    controllerMap.get(index).add(fast);    
                }
            }
        }
        System.debug('controllerMap=' + controllerMap);
        //System.debug('controllerMap.size()=' + controllerMap.size());

        if (values != null) {
            System.debug('values=' + values);
            for (ICX_PicklistValuesParser.PicklistValue picklist : values.values) {
                System.debug('picklist=' + picklist);
                // if this value has controlling values
                if (picklist.validFor != null && !picklist.validFor.isEmpty()) {
                    for (Integer controllingIndex : picklist.validFor) {
                        System.debug('controllingIndex=' + controllingIndex);
                        if (fastMap.get(picklist.value) == null) {
                            fastMap.put(picklist.value, new List<PicklistFast>());
                        }
                        System.debug('controllerMap.get(controllingIndex)=' + controllerMap.get(controllingIndex));
                        if (controllerMap.get(controllingIndex) != null) {
                            for (PicklistFast controllingFast : controllerMap.get(controllingIndex)) {
                                System.debug('controllingIndex=' + controllingIndex);
                                //PicklistFast item = buildPicklistFast(picklist, level, controllingFast, showParentWithChildren);
                                PicklistFast item = buildPicklistFast2(picklist, level, controllingFast, fieldName);
                                
                                fastMap.get(picklist.value).add(item);
                                
                                // Remove controlling PickFast if showParentWithChildren == false (ex: remove "Product Inforamtion" and keep "Product Information > Availability")
                                if (!showParentWithChildren && controllingFast != null) {
                                    if (//(level == 1 && controllingFast.level1 != null && controllingFast.level1.value == picklist.value)
                                        (level == 2 && controllingFast.level2 == null)
                                        || (level == 3 && controllingFast.level3 == null)) {
                                            //System.debug('REMOVE controllingFast=' + controllingFast);
                                            picklistFastList.remove(controllingFast);
                                        }
                                }
                                picklistFastList.add(item);
                                System.debug('1>fastMap.get(' + picklist.value + ')=' + item);
                            }
                        }
                    }
                } else {
                    System.debug('else');
                    //PicklistFast item = buildPicklistFast(picklist, level, null, showParentWithChildren);
                    PicklistFast item = buildPicklistFast2(picklist, level, null, fieldName);

                    if (fastMap.get(picklist.value) == null) {
                        fastMap.put(picklist.value, new List<PicklistFast>());
                    }
                    fastMap.get(picklist.value).add(item);
                    picklistFastList.add(item);
                    System.debug('2>fastMap.get(' + picklist.value + ')=' + item);
                }
            }
        }
        System.debug('fastMap=' + fastMap);
        return fastMap;
    }

    private static PicklistFast buildPicklistFast2(ICX_PicklistValuesParser.PicklistValue picklistValue, Integer level, PicklistFast controllingFast, String fieldName) {
        //System.debug('ICX_PicklistValuesParser.PicklistValue=' + picklistValue);
        //System.debug('level=' + level);
        //System.debug('PicklistFast controllingFast=' + controllingFast);
        PicklistFast item = (controllingFast != null ? controllingFast.clone() : new PicklistFast());
        if (level == 1) {
            item.level1 = picklistValue;
            item.level1FieldName = fieldName;
        } else if (level == 2) {
            item.level2 = picklistValue;
            item.level2FieldName = fieldName;
        } else if (level == 3) {
            item.level3 = picklistValue;
            item.level3FieldName = fieldName;
        }
        // Lower case to easy search
        item.label = (item.level1 != null ? item.level1.label.toLowerCase() : '') + (item.level2 != null ? ' ' + item.level2.label.toLowerCase() : '') + (item.level3 != null ? ' ' + item.level3.label.toLowerCase() : '');
        item.display = (item.level1 != null ? item.level1.label : '') + (item.level2 != null ? ' • ' + item.level2.label : '') + (item.level3 != null ? ' • ' + item.level3.label : '');
        System.debug('item=' + item);
        return item;
    }

    //Getting the session Id from the VF page to make the callouts
    private static string getSessionIdFromVfPage(){
        PageReference visualforcePage = Page.ICX_SessionIdPage;
        String content;
        try{
            content = visualforcePage.getContent().toString();
            //System.debug('content=' + content);
        }
        catch(VisualforceException e){
            content='START'+userinfo.getSessionId()+'END';
            //System.debug('content Exception=' + content);
		}
        Integer s = content.indexOf('START') + 'START'.length();
        Integer e = content.indexOf('END');
        
        String sessionId = content.substring(s, e);
        //System.debug('sessionId=' + sessionId);
        return sessionId;
    }

	public class PicklistFast {
        public ICX_PicklistValuesParser.PicklistValue level1;
        public ICX_PicklistValuesParser.PicklistValue level2;
        public ICX_PicklistValuesParser.PicklistValue level3;

        public String level1FieldName; 
        public String level2FieldName; 
        public String level3FieldName; 

        // combine labels of levels 1, 2 and 3 (helpful to search by auto-completion)
        public String label;
        public String display;
    }
}