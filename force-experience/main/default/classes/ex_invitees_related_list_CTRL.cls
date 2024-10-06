public with sharing class ex_invitees_related_list_CTRL {
    @AuraEnabled ( cacheable=true ) 
    public static Map<String,Object> initComponentConfig(String variationId){
        try {
            Brand_Experience_Variation__c variation = [SELECT RecordType.developerName, Brand_Experience__r.RecordType.DeveloperName FROM Brand_Experience_Variation__c WHERE Id =: variationId];
            String experienceRT = variation.Brand_Experience__r.RecordType.DeveloperName;
            Map<String,Object> componentConfig = new Map<String,Object>();
            componentConfig.put('invitees', getInvitees(variationId, experienceRT));

            return componentConfig;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    private static List<Brand_Experience_Variation_Member__c> getInvitees (String variationId, String experienceRT){
        try{
            User runningUser = EX_Store_Hierarchy_Utils.getUserHierarchies(); 
            String query = 'SELECT Id, Client__c, Client__r.Name, Client__r.OwnerId, Client__r.Owner.Name, toLabel(Status__c), Assigned_CA__c, Assigned_CA__r.Name, GuestNumber__c, Appointment_Start__c, Appointment_End__c '
                            + ' FROM Brand_Experience_Variation_Member__c'
                            + ' WHERE Brand_Experience_Variation__c = \''+variationId+'\'';
            
            List<string> userPermissionSet =  EX_Store_Hierarchy_Utils.getUserPermissionSet();
            system.debug('userPermissionSet'+userPermissionSet);
            
            if( experienceRT == EX_Store_Hierarchy_Utils.EXPERIENCE_OUT_STORE_RECORD_TYPE && 
            !(runningUser.Profile.Name == EX_Store_Hierarchy_Utils.SYSTEM_ADMIN_PROFILE || runningUser.Profile.Name == EX_Store_Hierarchy_Utils.ADMIN_CORPORATE_PROFILE || runningUser.Profile.Name == EX_Store_Hierarchy_Utils.LV_CLUB_PROFILE || userPermissionSet.contains(EX_Store_Hierarchy_Utils.EX_PCR_PERMISSION_SET))){

                query += EX_Store_Hierarchy_Utils.getCAHierarchyCond_memberLevel(runningUser);
            }
            query += ' ORDER BY CreatedDate DESC';
            system.debug('>> query'+query);
            List<Brand_Experience_Variation_Member__c> invitees = Database.query(query);
    
            return invitees;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
   }
}