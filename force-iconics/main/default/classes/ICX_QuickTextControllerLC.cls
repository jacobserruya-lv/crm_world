public with sharing class ICX_QuickTextControllerLC {

    // Channel = 'Email'
    @auraEnabled(cacheable=true)
    public static List<QuickText> getQuickTextList(String channel) {
        List<QuickText> quickList = new List<QuickText>();
        for (QuickText quick : [SELECT Language__c, Name, Channel, Message, Category, FolderId, FolderName, Folder.AccessType, Folder.ParentId FROM QuickText WHERE Channel INCLUDES (:channel) ORDER BY Language__c]) {
            quickList.add(quick);
        }
        return quickList;
    }

    // folderType = 'QuickText'
    @auraEnabled(cacheable=true)
    public static List<Folder> getFolderList(String folderType) {
        List<Folder> folderList = new List<Folder>();
        for (Folder folder : [SELECT id,AccessType, DeveloperName, IsReadonly, Name, Type, ParentId FROM Folder WHERE Type = :folderType ORDER BY Name ASC]) {
            folderList.add(folder);
        }
        return folderList;
    }

    // Recent quick text for the current user
    @auraEnabled(cacheable=true)
    public static List<QuickText> getRecentQuickTextList(String channel) {
        List<QuickText> quickResultList = new List<QuickText>();

        Map<Id, RecentlyViewed> recentMap = new Map<Id,RecentlyViewed>([SELECT Id, Name FROM RecentlyViewed WHERE Type = 'QuickText' ORDER BY LastViewedDate DESC LIMIT 10]);
        Set<Id> recentIdList = recentMap.keySet();
        System.debug('recentIdList=' + recentIdList );
        
        Map<Id, QuickText> quickMap = new Map<Id, QuickText>([SELECT Language__c, Name, Channel, Message, Category, FolderId, FolderName, Folder.AccessType, Folder.ParentId FROM QuickText WHERE Channel = :channel AND Id IN :recentIdList LIMIT 200]);
        System.debug('quickMap=' + quickMap);
        
        // Keep the order of the last viewed
        for (Id recentId : recentMap.keySet()) {
            if (quickMap.get(recentId) != null) {
                quickResultList.add(quickMap.get(recentId));
            }
        }
		return quickResultList;
    }

	@auraEnabled
    public static QuickText addRecentlyViewed(Id quickTextId) {
        // onclick on a quick text, add it in the RecentlyViewed objet with SOQL "FOR VIEW" : https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_mark_records_as_recently_viewed.htm
        return [SELECT Id FROM QuickText WHERE Id = :quickTextId FOR VIEW];
    }

    @auraEnabled
    public static String getMergeFields(String quickText, Id recordId, List<String> mergeFieldList) {
        System.debug('getMergeFields> quickText=' + quickText + ', recordId=' + recordId + ', mergeFieldList=' + mergeFieldList);

        if (String.isBlank(quickText)) {
            return null;
        }

        System.debug('quickText=' + quickText);

        Schema.DescribeSObjectResult sObjectType = recordId.getSObjectType().getDescribe();
        String objectApiName = sObjectType.getName();
        System.debug('objectApiName=' + objectApiName);
        
        Map<String, Schema.SObjectField> fieldMap = sObjectType.fields.getMap();
        
        Set<String> selectQuery = new Set<String>();
        Set<String> selectUserQuery = new Set<String>();
        Map<String, Set<String>> selectCustomSettingsQueryMap = new Map<String, Set<String>>();
        
        // get related field mapping
        Map<String, String> relatedFieldMap = new Map<String, String>();
        for (Schema.SObjectField objField : fieldMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = objField.getDescribe();
            
            // filter on Related field with only one reference (not Owner with User, Group objects for example)
            if (!fieldDescribe.getReferenceTo().isEmpty() && fieldDescribe.getReferenceTo().size() == 1) {
                String relatedObjectApiName = fieldDescribe.getReferenceTo().get(0).getDescribe().getName();
                relatedFieldMap.put(relatedObjectApiName, fieldDescribe.getRelationshipName());
            }
            // TODO later : Custom Settings and Custom Metadata type    
        }
        System.debug('relatedFieldMap=' + relatedFieldMap);
        
        // get Map<field, merge field>
        Map<String, String> fieldMergeMap = new Map<String, String>();
        for (String mergeField : mergeFieldList) {
            System.debug('mergeField=' + mergeField);
            List<String> cutField = mergeField.split('\\.');
            //System.debug('cutField=' + cutField);

			// Remove possible space in the merge fields
            String objectItem = cutField[0].trim();
            String fieldItem = cutField[1].trim();

            if (objectItem.equalsIgnoreCase(objectApiName)) {
                selectQuery.add(fieldItem);
                fieldMergeMap.put(fieldItem, mergeField);
            } else if (objectItem.equalsIgnoreCase('User')) { // Current user should be separated
                selectUserQuery.add(fieldItem);
                fieldMergeMap.put('User.' + fieldItem, mergeField);
            } else if (String.isNotBlank(relatedFieldMap.get(objectItem))) { // convert the related merge field with the related object
                String val = relatedFieldMap.get(objectItem) + '.' + fieldItem;
                System.debug('val=' + val);
                selectQuery.add(val);
                fieldMergeMap.put(val, mergeField);
            } else if (objectItem.equalsIgnoreCase('$Setup')) { // Custom Settings
                objectItem = cutField[1].trim();
                fieldItem = cutField[2].trim();
                
                if (selectCustomSettingsQueryMap.get(objectItem) == null) {
                    selectCustomSettingsQueryMap.put(objectItem, new Set<String>());
                }
                selectCustomSettingsQueryMap.get(objectItem).add(fieldItem);
                fieldMergeMap.put(objectItem + '.' + fieldItem, mergeField);
            } else { // merge fields not linked to the record
                System.debug('merge fields not linked to the record=' + mergeField);
                
                Schema.SObjectType sObjetType = Schema.getGlobalDescribe().get(objectItem);
                if (sObjetType != null) {
                    DescribeSObjectResult objectDescribe = sObjetType.getDescribe();
                    if (objectDescribe.isCustomSetting()) {
                        if (selectCustomSettingsQueryMap.get(objectItem) == null) {
                            selectCustomSettingsQueryMap.put(objectItem, new Set<String>());
                        }
                        selectCustomSettingsQueryMap.get(objectItem).add(fieldItem);
                        fieldMergeMap.put(objectItem + '.' + fieldItem, mergeField);
                    } else {
                        // Maybe a Custom Metadata type "objectItem finishes by __mdt"
                        fieldMergeMap.put(mergeField, mergeField);
                    }
                } else {
                    fieldMergeMap.put(mergeField, mergeField);
                }
            }
        }
        System.debug('fieldMergeMap=' + fieldMergeMap);
        System.debug('selectQuery=' + selectQuery);
        Map<String, String> mapResult = getMapping(selectQuery, objectApiName, false, recordId);

        System.debug('selectUserQuery=' + selectUserQuery);
        mapResult.putAll(getMapping(selectUserQuery, 'User', true, UserInfo.getUserId()));

        System.debug('selectCustomSettingsQueryMap=' + selectCustomSettingsQueryMap);
        for (String customSettingName : selectCustomSettingsQueryMap.keySet()) {
            mapResult.putAll(getMapping(selectCustomSettingsQueryMap.get(customSettingName), customSettingName, true, null));
        }

        for (String value : fieldMergeMap.keySet()) {
            System.debug('value=' + value);
            System.debug('fieldMergeMap.get(value)=' + fieldMergeMap.get(value));
            System.debug('mapResult.get(value)=' + mapResult.get(value));
            
            // Manage special caracters : "$Setup"
            String formatFieldMerge = fieldMergeMap.get(value).replace('$', '\\$');

            // Note: if the merge field has whitespace, the code should remove it but how to do this? Ex: {! User.Username }
            // String existingMergeField = '(?i)\\{!' + formatFieldMerge + '\\}'; // insensitive (?i) + with or without whitespace \\s*$
            String existingMergeField = '(?i)\\{[!\\?]' + formatFieldMerge + '\\}'; // insensitive (?i) + with or without whitespace \\s*$
            System.debug('existingMergeField=' + existingMergeField);
            quickText = quickText.replaceAll(existingMergeField, (mapResult.get(value) == null ? '' : mapResult.get(value)));
        }
        System.debug('quickText=' + quickText);
        return quickText;
    }

    // Find all merge fields from a text
    public static Set<String> mergeFields(String message) {
        Set<String> resultList = new Set<String>();

        if (String.isNotBlank(message)) {
            //Pattern MyPattern = Pattern.compile('\\{!([^}]*)\\}');
            Pattern MyPattern = Pattern.compile('\\{[!\\?]([^}]*)\\}');
            Matcher m = MyPattern.matcher(message);
            System.debug(m);
            while (m.find()) {
                System.debug(m.group(1));
                resultList.add(m.group(1).trim());
                System.debug(m.start() + ': ' + m.group());
            }
        }
        System.debug(resultList);
		return resultList;
    }

    public static Set<String> mergeFieldsFile(String message) {
        Set<String> resultList = new Set<String>();

        if (String.isNotBlank(message)) {
            //Pattern MyPattern = Pattern.compile('\\{!([^}]*)\\}'); 
            Pattern MyPattern = Pattern.compile('\\{[!\\?]([^}]*)\\}');
            Matcher m = MyPattern.matcher(message);
            System.debug(m);
            while (m.find()) {
                System.debug(m.group(1));
                resultList.add(m.group(1).trim());
                System.debug(m.start() + ': ' + m.group());
            }
        }
        System.debug(resultList);
		return resultList;
    }

    
    private static Map<String, String> getMapping(Set<String> selectQuery, String objectApiName, Boolean addObjectName, Id recordId) {
        System.debug('selectQuery=' + selectQuery + '/objectApiName=' + objectApiName + '/addObjectName=' + addObjectName);
        System.debug('getMapping recordId '+ recordId);

        Map<String, String> mapResult = new Map<String, String>();

        if (!selectQuery.isEmpty()) {
            String fieldString = String.join(new List<String>(selectQuery), ', ');
            String finalSelectQuery = 'SELECT ' + fieldString + ' FROM ' + objectApiName + (String.isNotBlank(recordId) ? ' WHERE Id = :recordId' : '') + ' WITH SECURITY_ENFORCED';    
            System.debug('finalSelectQuery=' + finalSelectQuery);
            
            SObject s = Database.query(String.escapeSingleQuotes(finalSelectQuery));
            if (s != null) {
                for (String field : selectQuery) {
                    List<String> cutField = field.split('\\.');
                    System.debug('cutField=' + cutField);
                    if (cutField.size() == 2) {
                        SObject objectType = s.getSObject(cutField[0]);
                        System.debug('objectType=' + objectType);
                        if (objectType != null) { // Problem with Person Account field (ex: Account.Store__pr). https://success.salesforce.com/issues_view?id=a1p30000000SvzXAAS
                            String val = (String) objectType.get(cutField[1]);
                            mapResult.put(field, val);
                        }
                    } else {
                        String val = String.valueOf(s.get(field));
                        mapResult.put((addObjectName ? objectApiName + '.' + field : field), val);
                    }
                }
            }
        }
        System.debug('mapResult=' + mapResult);
		return mapResult;
    }
}