public with sharing class ex_Event_ListView_Controller {
    public static final String EX_PCR_PERMISSION_SET = 'Events_Experiences_PCR';

    @AuraEnabled(cacheable=true)
    public static List<Brand_Experience__c> getStoreHierarchiesEvents() {
        
        Id ClubExperienceRecordType = BL_Experience_Variation_Utils.getRecordTypeExperience('Club');
        String query = 'SELECT Id, Name, Experience_StartDate__c, Experience_EndDate__c, Type__c, Sub_Type__c, Size_Of_Variations__c, Status__c FROM Brand_Experience__c WHERE recordTypeId != \'' + ClubExperienceRecordType + '\'';
        String condition = '';
        User runningUser = EX_Store_Hierarchy_Utils.getUserHierarchies();
        if(!hasPCRPermissionSet()){ //display Records Based On Hierarchy:
            if (runningUser.DefaultStore__c!=null && !String.isBlank(runningUser.DefaultStore__c)) {
                condition+=' Store__r.RetailStoreId__c = \'' + String.escapeSingleQuotes(runningUser.DefaultStore__c) + '\'';
            }
            else if (runningUser.MGMT_ZONE_SUB_LEVEL3__c!=null && !String.isBlank(runningUser.MGMT_ZONE_SUB_LEVEL3__c)) {
                condition+=' Store__r.MGMT_ZONE_SUB_LEVEL3__c  = \'' + String.escapeSingleQuotes(runningUser.MGMT_ZONE_SUB_LEVEL3__c) + '\'';
            }
            else if (runningUser.MGMT_ZONE_SUB_LEVEL2__c!=null && !String.isBlank(runningUser.MGMT_ZONE_SUB_LEVEL2__c)) {
                condition+=' Store__r.MGMT_ZONE_SUB_LEVEL2__c = \''+ String.escapeSingleQuotes(runningUser.MGMT_ZONE_SUB_LEVEL2__c) + '\'';
            }
            else if (runningUser.MGMT_ZONE_SUB_LEVEL1__c!=null && !String.isBlank(runningUser.MGMT_ZONE_SUB_LEVEL1__c)) {
                condition+=' Store__r.MGMT_ZONE_SUB_LEVEL1__c = \''+ String.escapeSingleQuotes(runningUser.MGMT_ZONE_SUB_LEVEL1__c) + '\'';
            }
            else if (runningUser.MANAGEMENT_ZONE_LEVEL__c!=null && !String.isBlank(runningUser.MANAGEMENT_ZONE_LEVEL__c)) {
                condition+=' Store__r.MANAGEMENT_ZONE_LEVEL__c  = \'' + String.escapeSingleQuotes(runningUser.MANAGEMENT_ZONE_LEVEL__c) + '\'';
            }
            if(condition==''){
                return null;
            }
            query += ' AND Id IN (SELECT Brand_Experience__c FROM Brand_Experience_Store_Hierarchy__c WHERE ' +condition+')';
        }
        System.debug('**condition '+condition);
        System.debug('**query '+query);
        return Database.query(query);  
    }
    @AuraEnabled(cacheable=true)
    public static Boolean hasPCRPermissionSet() {
        List<String> userPermissionSet = EX_Store_Hierarchy_Utils.getUserPermissionSet();
        return (userPermissionSet.contains(EX_PCR_PERMISSION_SET));          
    }
}