public with sharing class BL_ICON_Tags_Helper {
    public static Object getAllMyClientTags(String clientId, BL_UserInfo me){
        return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_TAG)
                .addCondition('Client__c = \'' +clientId+ '\' AND OwnerId = \'' + me.basicInfos.Id +'\'')
                .executeQuery()
                .getResponseMappedObjects();
    }

    public static Object getMyClientTagsByFeatures(String clientId, String features, BL_UserInfo me){
        List<String> featuresList = features.split(';');
        return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_TAG)
                .addCondition('Client__c = \'' +clientId+ '\' AND OwnerId = \'' + me.basicInfos.Id +'\' AND Type__c ' + BL_ICON_Utils.buildMultiChoiceFilterFromList(featuresList))
                .executeQuery()
                .getResponseMappedObjects();
    }

    public static Object getMyTagsByFeatures(String features, BL_UserInfo me){
        List<String> featuresList = features.split(';');
        return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_TAG)
                .addCondition('OwnerId = \'' + me.basicInfos.Id +'\' AND Type__c ' + BL_ICON_Utils.buildMultiChoiceFilterFromList(featuresList))
                .executeQuery()
                .getResponseMappedObjects();
    }

    public static Object getAllMyTags(BL_UserInfo me){
        return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_TAG)
                .addCondition('OwnerId = \'' + me.basicInfos.Id +'\' ' )
                .executeQuery()
                .getResponseMappedObjects();
    }
}