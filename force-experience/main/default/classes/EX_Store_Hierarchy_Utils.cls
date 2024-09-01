public with sharing class EX_Store_Hierarchy_Utils {

    public static final String SYSTEM_ADMIN_PROFILE = 'System Administrator';
    public static final String ADMIN_CORPORATE_PROFILE = 'System Admin_Corporate';
    public static final String LV_CLUB_PROFILE = 'LV_Club';
    public static final String ICON_SA_PROFILE = 'ICON_SA';
    public static final String ICON_SA_MANAGER_PROFILE = 'ICON_SA Manager';
    public static final String ICON_CORPORATE_PROFILE = 'ICON_Corporate';
    public static final String EX_PCR_PERMISSION_SET = 'Events_Experiences_PCR';
    public static final String EX_ZONES_PERMISSION_SET = 'Events_Experiences_Zones_Regions';

    public static final String EXPERIENCE_RECORD_TYPE = 'Experience';
    public static final String EXPERIENCE_OUT_STORE_RECORD_TYPE = 'Out_of_Store_Event';
    public static final String VARIATION_OUT_STORE_RECORD_TYPE = 'Out_of_Store_Event';

    public static List<string>  getUserPermissionSet (){
        List<String> permissionSetNames = new List<String>();
        for (PermissionSetAssignment psa : [SELECT PermissionSetId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()]) {
            permissionSetNames.add(psa.PermissionSet.Name);
        }
        return permissionSetNames;
    }

    public static Set<Id> getStoreIds (String experienceId, User runningUser){
        String query = 'SELECT Store__c FROM  Brand_Experience_Store_Hierarchy__c  WHERE Brand_Experience__c = \''+experienceId+ '\'' + getStoreHierarchyCond_variationLevel(runningUser) ;
        System.debug('>> query '+query);
        Set<Id> storeIds = new Set<Id>();
        for(Brand_Experience_Store_Hierarchy__c hierarchy : Database.query(query)){
            storeIds.add(hierarchy.Store__c);
        }
        return storeIds;
    }

    public static String getStoreHierarchyCond_variationLevel(User runningUser) {
        String condition = '';
        if (!String.isBlank(runningUser.DefaultStore__c)) {
            condition+=' AND Store__r.RetailStoreId__c = \'' + String.escapeSingleQuotes(runningUser.DefaultStore__c) + '\'';
        }
        else if (!String.isBlank(runningUser.MGMT_ZONE_SUB_LEVEL3__c)) {
            condition+=' AND Store__r.MGMT_ZONE_SUB_LEVEL3__c  = \'' + String.escapeSingleQuotes(runningUser.MGMT_ZONE_SUB_LEVEL3__c) + '\'';
        }
        else if (!String.isBlank(runningUser.MGMT_ZONE_SUB_LEVEL2__c)) {
            condition+=' AND Store__r.MGMT_ZONE_SUB_LEVEL2__c = \''+ String.escapeSingleQuotes(runningUser.MGMT_ZONE_SUB_LEVEL2__c) + '\'';
        }
        else if (!String.isBlank(runningUser.MGMT_ZONE_SUB_LEVEL1__c)) {
            condition+=' AND Store__r.MGMT_ZONE_SUB_LEVEL1__c = \''+ String.escapeSingleQuotes(runningUser.MGMT_ZONE_SUB_LEVEL1__c) + '\'';
        }
        else if (!String.isBlank(runningUser.MANAGEMENT_ZONE_LEVEL__c)) {
            condition+=' AND Store__r.MANAGEMENT_ZONE_LEVEL__c  = \'' + String.escapeSingleQuotes(runningUser.MANAGEMENT_ZONE_LEVEL__c) + '\'';
        }
        return condition;
    }
    public static User getUserHierarchies() {
        return [SELECT Profile.Name, MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL3__c, DefaultStore__c FROM User Where Id = :UserInfo.getUserId()];    
    }

    public static Boolean needStoreHierarchyCondition(User runningUser) {
        List<string> userPermissionSet = getUserPermissionSet();
        system.debug('userPermissionSet'+userPermissionSet);
        if(runningUser.Profile.Name == SYSTEM_ADMIN_PROFILE || runningUser.Profile.Name == ADMIN_CORPORATE_PROFILE || runningUser.Profile.Name == LV_CLUB_PROFILE || userPermissionSet.contains(EX_PCR_PERMISSION_SET))
            return false;
        return true;

    }  
    
    public static String getCAHierarchyCond_memberLevel(User runningUser) {
        String condition = '';
        if (!String.isBlank(runningUser.DefaultStore__c)) {
            condition+=' AND Assigned_CA__r.DefaultStore__c = \'' + String.escapeSingleQuotes(runningUser.DefaultStore__c) + '\'';
        }
        else if (!String.isBlank(runningUser.MGMT_ZONE_SUB_LEVEL3__c)) {
            condition+=' AND Assigned_CA__r.MGMT_ZONE_SUB_LEVEL3__c  = \'' + String.escapeSingleQuotes(runningUser.MGMT_ZONE_SUB_LEVEL3__c) + '\'';
        }
        else if (!String.isBlank(runningUser.MGMT_ZONE_SUB_LEVEL2__c)) {
            condition+=' AND Assigned_CA__r.MGMT_ZONE_SUB_LEVEL2__c = \''+ String.escapeSingleQuotes(runningUser.MGMT_ZONE_SUB_LEVEL2__c) + '\'';
        }
        else if (!String.isBlank(runningUser.MGMT_ZONE_SUB_LEVEL1__c)) {
            condition+=' AND Assigned_CA__r.MGMT_ZONE_SUB_LEVEL1__c = \''+ String.escapeSingleQuotes(runningUser.MGMT_ZONE_SUB_LEVEL1__c) + '\'';
        }
        else if (!String.isBlank(runningUser.MANAGEMENT_ZONE_LEVEL__c)) {
            condition+=' AND Assigned_CA__r.MANAGEMENT_ZONE_LEVEL__c  = \'' + String.escapeSingleQuotes(runningUser.MANAGEMENT_ZONE_LEVEL__c) + '\'';
        }
        return condition;
    }
    public static String getStoreHierarchyCond_memberLevel(User runningUser) {
        String condition = '';
        if (!String.isBlank(runningUser.DefaultStore__c)) {
            condition+=' AND Brand_Experience_Variation__r.Store__r.RetailStoreId__c = \'' + String.escapeSingleQuotes(runningUser.DefaultStore__c) + '\'';
        }
        else if (!String.isBlank(runningUser.MGMT_ZONE_SUB_LEVEL3__c)) {
            condition+=' AND Brand_Experience_Variation__r.Store__r.MGMT_ZONE_SUB_LEVEL3__c  = \'' + String.escapeSingleQuotes(runningUser.MGMT_ZONE_SUB_LEVEL3__c) + '\'';
        }
        else if (!String.isBlank(runningUser.MGMT_ZONE_SUB_LEVEL2__c)) {
            condition+=' AND Brand_Experience_Variation__r.Store__r.MGMT_ZONE_SUB_LEVEL2__c = \''+ String.escapeSingleQuotes(runningUser.MGMT_ZONE_SUB_LEVEL2__c) + '\'';
        }
        else if (!String.isBlank(runningUser.MGMT_ZONE_SUB_LEVEL1__c)) {
            condition+=' AND Brand_Experience_Variation__r.Store__r.MGMT_ZONE_SUB_LEVEL1__c = \''+ String.escapeSingleQuotes(runningUser.MGMT_ZONE_SUB_LEVEL1__c) + '\'';
        }
        else if (!String.isBlank(runningUser.MANAGEMENT_ZONE_LEVEL__c)) {
            condition+=' AND Brand_Experience_Variation__r.Store__r.MANAGEMENT_ZONE_LEVEL__c  = \'' + String.escapeSingleQuotes(runningUser.MANAGEMENT_ZONE_LEVEL__c) + '\'';
        }
        return condition;
    }


}