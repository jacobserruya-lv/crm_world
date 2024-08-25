public with sharing class BL_ICON_Onboarding_Helper {

    public static object getOnboardings() {
        String language = UserInfo.getLanguage();
        return new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_ONBOARDING)     
            .condition('IsActive__c = true AND Language__c = \'' + language + '\' AND Application__c = \'ICON\'')
            .executeQuery()
            .getMappedObjects();
    }

}