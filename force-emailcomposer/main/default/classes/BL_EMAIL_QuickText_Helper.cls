public with sharing class BL_EMAIL_QuickText_Helper {

    static final String channel = 'email';
    static final String type = 'QuickText';

    public static Object searchQuickText(String searchTerm, Integer nbLimit, Integer offsets) {
        List<Object> response = new List<Object>(); 
        searchTerm += '*';

        String searchQuery = ' FIND :searchTerm IN ALL FIELDS RETURNING ' +
                             ' Folder (id, Name, Type, DeveloperName ,ParentId WHERE Type =:type LIMIT :nbLimit OFFSET :offsets), ' +
                             ' QuickText(tolabel(Language__c), Name, Channel, Category, Message, FolderId WHERE  Channel INCLUDES (:channel) LIMIT :nbLimit OFFSET :offsets)  ' +
                             ' WITH HIGHLIGHT';

        BL_WS_Log.addLogQuery(searchQuery, 'USE CASE SEARCH');
        List<List<Object>> searchResults =  Search.query(searchQuery);

        response.addAll(setFolders((List<Folder>) searchResults[0], new Map<String,List<QuickText>>(), new Map<String,Decimal>()));
        response.addAll(setQuickText((List<QuickText>) searchResults[1]));

        return response;
    }

    public static Object getQuickText(Id parentId, Integer pageSize, Integer pageIndex) {
        List<Object> response = new List<Object>(); 
        Map<Id, Folder> folders = getFolders(type, parentId);
        List<Id> folderIds = new List<Id>(folders.keyset());  
        Map<String,Decimal> foldersByParent = getCountFolders(folders.keyset()); 
        folderIds.add(parentId);            
        List<QuickText> quickTexts = getQuickTexts(folderIds, channel);
        Map<String,List<QuickText>> quickTextByFolder = getQuickTextsByFolder(quickTexts) ;    
        List<QuickText> quickTextByParentId = quickTextByFolder.containskey(parentId) ? quickTextByFolder?.get(parentId) : new List<QuickText>();

        response.addAll(setFolders(folders.values(), quickTextByFolder, foldersByParent));
        response.addAll(setQuickText(quickTextByParentId));
        
        return response;
    }
    
    public static Map<String,List<QuickText>> getQuickTextsByFolder(List<QuickText> quickTexts) {
        Map<String,List<QuickText>> quickTextByFolder = new  Map<String,List<QuickText>> ();    

        for(QuickText quickText : quickTexts){
            if(!quickTextByFolder.containskey(quickText.folderId))
                quickTextByFolder.put(quickText.folderId, new List<QuickText>());
            quickTextByFolder.get(quickText.folderId).add(quickText);
        } 
        return quickTextByFolder;
    }

    public static Object getRecentQuickText(Integer pageSize) {
        List<Object> response = new List<Object>(); 
        Set<Id> recentIds =  getRecentRecentlyViewedIds(type, pageSize);
        List<QuickText> quickTexts = getQuickTextByIds(recentIds);

        response.addAll(setQuickText(quickTexts));
        return response;
    }

    public static Map<String,Decimal> getCountFolders(Set<Id> folderIds) {   
        Map<String,Decimal> childRecordsCount = new  Map<String,Decimal> ();   
        List<AggregateResult> aggregateResults = [ 
                                                    SELECT COUNT(ID) cnt, ParentId
                                                    FROM Folder 
                                                    WHERE ParentId IN :folderIds
                                                    GROUP BY ParentId 
                                                ];

        for(AggregateResult ar : aggregateResults){
            Decimal folderNumber = (Decimal) ar.get('cnt');
            childRecordsCount.put(String.valueOf(ar.get('ParentId')), folderNumber == null ? 0 : folderNumber);
        }  
        return childRecordsCount;
    }

    public static Set<Id> getRecentRecentlyViewedIds(String type, Integer pageSize){
        Map<Id,RecentlyViewed> recent = new Map<Id,RecentlyViewed>([
            SELECT Id, Name 
            FROM RecentlyViewed  
            WHERE Type =:type
            LIMIT :pageSize
        ]);
        return recent.keyset();
    }

    public static Map<Id, Folder> getFolders(String type, Id parentId) {    
        return new Map<Id, Folder>([ SELECT id, DeveloperName, Name, ParentId
                                     FROM Folder 
                                     WHERE Type =: type AND ParentId =: parentId 
                                     ORDER BY Name ASC
                                    ]);
    }


    public static List<QuickText> getQuickTexts(List<Id> folderIds, String channel) {
        return [ SELECT ID, tolabel(Language__c), Name, Channel, Category, Message, FolderId 
                 FROM QuickText 
                 WHERE Channel INCLUDES (:channel) AND folderId IN:folderIds
                 ORDER BY Language__c
              ];
    }


    public static List<QuickText> getQuickTextByIds(Set<Id> Ids) {
        return [ SELECT ID, tolabel(Language__c), Name, Channel, Category, Message, FolderId , Folder.DeveloperName
                 FROM QuickText 
                 WHERE ID IN:Ids
                 ORDER BY Language__c
              ];
    }

    public static Map<String, Object> getQuickTextById(Id qickTextId, Id recordId) {
        Map<String,Object> record =  new BL_EasyQuery()
        .useCase(BL_EMAIL_Constants.USE_CASE_QUICK_TEXT)
        .condition('Id = \'' + qickTextId + '\'')
        .usage(BL_EasyQuery.Usage.FOR_VIEW)
        .executeQuery()
        .getMappedObject();
        
        record.put('sObject', 'QuickText');
        if(recordId != null) {
            record.put('message', getMergeFields(String.valueOf(record.get('message')), recordId));
        }

        return record;
    }

    private static List<Object> setFolders(List<Folder> folders, Map<String,List<QuickText>> quickTexts, Map<String,Decimal> foldersByParent) { 
        List<Object> response = new List<Object>(); 

        for(Folder folder : folders) {   
            List<QuickText> quickTxt = quickTexts.containskey(folder.id) ? quickTexts?.get(folder.id) : new List<QuickText>();  
            Decimal nbfolder = foldersByParent?.containskey(folder.ID) ? foldersByParent?.get(folder.ID) : 0;

            Map<String,Object> result  = new BL_EasyQuery()
                                                .useCase(BL_EMAIL_Constants.USE_CASE_FOLDER)
                                                .convertSObjectToWrapper(folder);

            result.put('folderCount', nbfolder);
            result.put('quickTextCount', quickTxt.size());
            result.put('sObject', 'Folder');

            response.add(result);
        } 
        return response; 
    }

    private static List<Object> setQuickText(List<QuickText> quickTexts){
        List<Object> response = new List<Object>(); 
        
        for(QuickText quickText : quickTexts) {
            
            Map<String,Object> result  = new BL_EasyQuery()
            .useCase(BL_EMAIL_Constants.USE_CASE_QUICK_TEXT)
            .convertSObjectToWrapper(quickText);

            result.put('sObject', 'QuickText');
            result.remove('attributes');

            response.add(result);
        } 
        return response;
    }

     public static Set<String> mergeFields(String quickText) {
        Set<String> resultList = new Set<String>();
        if (String.isNotBlank(quickText)) {
            Pattern MyPattern = Pattern.compile('\\{[!\\?]([^}]*)\\}');
            Matcher m = MyPattern.matcher(quickText);
            while (m.find()) {
                resultList.add(m.group(1).trim());
            }
        }
		return resultList;
    }

    private static Map<String, String> getMapping(Set<String> selectQuery, String objectApiName, Boolean addObjectName, Id recordId) {
        Map<String, String> mapResult = new Map<String, String>();

        if (!selectQuery.isEmpty()) {
            String fieldString = String.join(new List<String>(selectQuery), ', ');
            String finalSelectQuery = 'SELECT ' + fieldString + ' FROM ' + objectApiName + (String.isNotBlank(recordId) ? ' WHERE Id = :recordId' : '') + ' WITH SECURITY_ENFORCED';    
            
            SObject s = Database.query(String.escapeSingleQuotes(finalSelectQuery));
            if (s != null) {
                for (String field : selectQuery) {
                    List<String> cutField = field.split('\\.');
                    if (cutField.size() == 2) {
                        SObject objectType = s.getSObject(cutField[0]);
                        if (objectType != null) { 
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
        System.debug('BL_EMAIL_QuickText_Helper getMapping mapResult=' + mapResult);
		return mapResult;
    }

    public static String getMergeFields(  String quickText, Id recordId) {
        Set<String> mergeFieldList = mergeFields(quickText);
        System.debug('BL_EMAIL_QuickText_Helper getMergeFields quickText=' + quickText + ', recordId=' + recordId + ', mergeFieldList=' + mergeFieldList);

        Schema.DescribeSObjectResult sObjectType = recordId.getSObjectType().getDescribe();
        String objectApiName = sObjectType.getName();

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
        }
        System.debug('BL_EMAIL_QuickText_Helper getMergeFields relatedFieldMap: ' + relatedFieldMap);
        
        // get Map<field, merge field>
        Map<String, String> fieldMergeMap = new Map<String, String>();
        for (String mergeField : mergeFieldList) {
            List<String> cutField = mergeField.split('\\.');
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
                System.debug('BL_EMAIL_QuickText_Helper getMergeFields merge fields not linked to the record: ' + mergeField);
                
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
        Map<String, String> mapResult = getMapping(selectQuery, objectApiName, false, recordId);
        mapResult.putAll(getMapping(selectUserQuery, 'User', true, UserInfo.getUserId()));
        for (String customSettingName : selectCustomSettingsQueryMap.keySet()) {
            mapResult.putAll(getMapping(selectCustomSettingsQueryMap.get(customSettingName), customSettingName, true, null));
        }
        for (String value : fieldMergeMap.keySet()) {            
            // Manage special caracters : "$Setup"
            String formatFieldMerge = fieldMergeMap.get(value).replace('$', '\\$');
            String existingMergeField = '(?i)\\{[!\\?]' + formatFieldMerge + '\\}';
            quickText = quickText.replaceAll(existingMergeField, (mapResult.get(value) == null ? '' : mapResult.get(value)));
        }
        quickText = quickText.replaceAll('\n', '<br/>');
        return quickText;
    }
}