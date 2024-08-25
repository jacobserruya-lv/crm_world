public with sharing class BL_ICON_Badges_Helper extends BL_WS_Request{

    public static Object getBadges (string userId, String defaultStore){

        Map<Id, Map<String, Object>> userMap = new Map<Id, Map<String, Object>>();
        Set<Id> orderedUserIds = new Set<Id>();
        List<Map<String,Object>> sorteredListMap = new List<Map<String,Object>>();

        List<Map<String, Object>> membersMap  = new BL_EasyQuery()
                                                .useCase(BL_ICON_Constants.USE_CASE_TEAM)
                                                .conditionValues( new Map<String, String> {'userId' => userId})
                                                .condition('DefaultStore__c = \'' + defaultStore +  '\' AND DefaultStore__c != null AND DefaultStore__c != \'\' AND IsActive = true AND IsTechnicalUser__c = false AND (NOT Email LIKE \'store_%\')')
                                                .executeQuery()
                                                .getMappedObjects();

        for(Map<String, Object> item: membersMap){
            userMap.put((Id)item.get('id'), item);
        }
        List<AggregateResult> countBadge = [SELECT count(Id)ctn, ownerId FROM IconBadge__c WHERE ownerId IN: userMap.keySet() GROUP BY ownerId ORDER BY count(Id) DESC];
        for (AggregateResult badge : countBadge) {
                userMap.get((Id)badge.get('ownerId')).put('numOfBadges', badge.get('ctn'));
                orderedUserIds.add((Id)badge.get('ownerId'));
        }
        // for adding also the CAs that dont have badges
        orderedUserIds.addAll(userMap.keySet());
        for (Id user : orderedUserIds) {
            sorteredListMap.add(userMap.get(user));
        }

        return sorteredListMap;
    }

}