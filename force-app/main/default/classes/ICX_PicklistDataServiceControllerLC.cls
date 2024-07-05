public with sharing class ICX_PicklistDataServiceControllerLC {

    @AuraEnabled(cacheable=true)
    public static ICX_PicklistValuesParser getPicklist(Id recordTypeId, String sObjectType) {
        ICX_PicklistValuesParser result;
        System.debug('recordTypeId / sObjectType=' + recordTypeId + '/' + sObjectType);
        if (String.isNotBlank(recordTypeId) && String.isNotBlank(sObjectType)) {
            result = ICX_FastQualification.callWebservice(sObjectType, recordTypeId);
        }
        return result;
    }

    // fieldLevelList : as a String as the cache doesn't keep List<String> of different values
    @AuraEnabled(cacheable=true)
    public static String getFieldList(String parser, String fieldLevelList, String showParentWithChildrenList, List<String> hierarchyDependantFieldList) {

        String result;
        if (String.isNotBlank(parser) && String.isNotBlank(fieldLevelList) && String.isNotBlank(showParentWithChildrenList)) {
            List<String> fieldLevelList2 = (List<String>) JSON.deserialize(fieldLevelList, List<String>.class);
            ICX_PicklistValuesParser parse = (ICX_PicklistValuesParser) JSON.deserialize(parser, ICX_PicklistValuesParser.class);
            List<Boolean> showParentWithChildrenList2 =  (List<Boolean>) JSON.deserialize(showParentWithChildrenList, List<Boolean>.class);
            System.debug('fieldLevelList/showParentWithChildrenList/parse=' + fieldLevelList + '/' + showParentWithChildrenList + '/' + parse);
            //result = ICX_FastQualification.getPicklistFast(parse, fieldLevelList2, showParentWithChildrenList2);
            result = ICX_FastQualification.getPicklistFast(parse, fieldLevelList2, showParentWithChildrenList2);
        }
        System.debug('getFieldList > result=' + result);
        return result;
    }

/*    private static String filterPicklist(String picklistList, List<String> fieldLevelList) {
        List<ICX_FastQualification.PicklistFast> result = (List<ICX_FastQualification.PicklistFast>) JSON.deserialize(picklistList, List<ICX_FastQualification.PicklistFast>.class);
        if (result != null) {

            Integer currentLevel;
            String firstLevel;
            if (fieldLevelList != null && !fieldLevelList.isEmpty()) {
                firstLevel = fieldLevelList.get(0);
            }
            
            if (String.isNotBlank(firstLevel)) {
                for (ICX_FastQualification.PicklistFast item : result) {
                    if (firstLevel.equalsIgnoreCase(item.level1FieldName)) {
                        currentLevel = 1;
                        break;
                    }
                    if (firstLevel.equalsIgnoreCase(item.level2FieldName)) {
                        currentLevel = 2;
                        break;
                    }
                    if (firstLevel.equalsIgnoreCase(item.level3FieldName)) {
                        currentLevel = 3;
                        break;
                    }
                }
                if (currentLevel != null) {
                    for (ICX_FastQualification.PicklistFast item : result) {
                        if (currentLevel == 1) {
                            if (String.isNotBlank(item.level1.value) && String.isNotBlank(fieldLevelList.get(1))) {
                                // TODO
                            }
                        }
                    }
                }
            }
            
        }
        return null;
    }*/
}