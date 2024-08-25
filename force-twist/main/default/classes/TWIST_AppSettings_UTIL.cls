public with sharing class TWIST_AppSettings_UTIL {
    
    public static Object getSetting(String key) {
        TWIST_App_Setting__mdt setting = getSettingRaw(key);
        return setting == null ? null : setting.Value__c;
    }
    
    /** PRIVATE METHODS ******************************************************************************************************************* */

    private static TWIST_App_Setting__mdt getSettingRaw(String key) {
        List<TWIST_App_Setting__mdt> settings = !Test.isRunningTest()
            ? [SELECT Value__c, ValueType__c FROM TWIST_App_Setting__mdt WHERE Key__c = :key]
            : getAppSetingWhenRunningTest();
        return settings.isEmpty() ? null : settings.get(0);
    }

    private static List<TWIST_App_Setting__mdt> getAppSetingWhenRunningTest() {
        return new List<TWIST_App_Setting__mdt> { new TWIST_App_Setting__mdt(
            Key__c = TWIST_AppSettings_UTIL_TEST.akamaizedCommunityUrl.get('key'),
            Value__c = TWIST_AppSettings_UTIL_TEST.akamaizedCommunityUrl.get('value')) };
    }

}