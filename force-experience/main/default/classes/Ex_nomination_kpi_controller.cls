public with sharing class Ex_nomination_kpi_controller {
    @AuraEnabled ( cacheable=true ) 
        public static Map<String,Integer> getKPIValues (Id recordId, String objectApiName, List<String> fields) {
        try {
            Map<String, String> ALL_KPI_query = new Map<String, String> {
                'NOMINATED_CLIENT' => 'SELECT COUNT(Id) FROM Brand_Experience_Variation_Member__c WHERE NominationStatus__c =\'Approved\' AND Brand_Experience_Variation__c = \''+recordId+'\'',
                'CONFIRMED_CLIENT' => 'SELECT COUNT(Id) FROM Brand_Experience_Variation_Member__c WHERE rsvpState__c =\'Registered\' AND Brand_Experience_Variation__c = \''+recordId+'\'',
                'APPOINTMENTS_FIELD' => 'SELECT SUM(Nb_Appointment__c) FROM Brand_Experience_Variation_Member__c WHERE Brand_Experience_Variation__c = \''+recordId+'\'',
                'GUESTS_FIELD' => 'SELECT SUM(GuestNumber__c) FROM Brand_Experience_Variation_Member__c WHERE Brand_Experience_Variation__c = \''+recordId+'\'',


                'GLOBAL_TARGET_CLIENT' => 'SELECT SUM(Nb_Target_Clients__c) FROM Brand_Experience_Variation__c WHERE Brand_Experience__c = \''+recordId+'\'',
                'GLOBAL_NOMINATED_CLIENT' => 'SELECT COUNT(Id) FROM Brand_Experience_Variation_Member__c WHERE NominationStatus__c =\'Approved\' AND Brand_Experience_Variation__r.Brand_Experience__c = \''+recordId+'\'',
                'GLOBAL_CONFIRMED_CLIENT' => 'SELECT COUNT(Id) FROM Brand_Experience_Variation_Member__c WHERE rsvpState__c =\'Registered\' AND Brand_Experience_Variation__r.Brand_Experience__c = \''+recordId+'\'',
                'GLOBAL_APPOINTMENTS' => 'SELECT SUM(Nb_Appointment__c) FROM Brand_Experience_Variation_Member__c WHERE Brand_Experience_Variation__r.Brand_Experience__c = \''+recordId+'\'',
                'GLOBAL_GUESTS' => 'SELECT SUM(GuestNumber__c) FROM Brand_Experience_Variation_Member__c WHERE Brand_Experience_Variation__r.Brand_Experience__c = \''+recordId+'\''
            };

            String recordtypeQuery = 'SELECT id, recordtype.DeveloperName FROM '+objectApiName+' WHERE Id = \''+recordId+'\'';
            SObject record = Database.query(recordtypeQuery);
            String recordtypeName;
            switch on objectApiName {
                when 'Brand_Experience__c' {
                    Brand_Experience__c experienceRecord = (Brand_Experience__c) record;
                    recordtypeName = experienceRecord.recordtype.DeveloperName;
                }
                when 'Brand_Experience_Variation__c' {
                    Brand_Experience_Variation__c experienceRecord = (Brand_Experience_Variation__c) record;
                    recordtypeName = experienceRecord.recordtype.DeveloperName;
                }
            }

            Map<String,Integer> KPIs = new Map<String,Integer>();
            
            for (String kpiName : fields) {
                String query = ALL_KPI_query.get(kpiName);
                if (query != null) {

                    User runningUser = EX_Store_Hierarchy_Utils.getUserHierarchies();
                    if(EX_Store_Hierarchy_Utils.needStoreHierarchyCondition(runningUser))
                    {
                        if(kpiName == 'GLOBAL_TARGET_CLIENT'){
                            if(objectApiName == 'Brand_Experience__c' && recordtypeName == 'Experience'){
                                query += EX_Store_Hierarchy_Utils.getStoreHierarchyCond_variationLevel(runningUser);
                            }
                        }
                        else{
                            if(objectApiName == 'Brand_Experience__c' && recordtypeName == 'Experience'){
                                query += EX_Store_Hierarchy_Utils.getStoreHierarchyCond_memberLevel(runningUser);
                            }
                            else if((objectApiName == 'Brand_Experience__c' && recordtypeName == 'Out_of_Store_Event') || (objectApiName == 'Brand_Experience_Variation__c' && recordTypeName == 'Out_of_Store_Event')){
                                query += EX_Store_Hierarchy_Utils.getCAHierarchyCond_memberLevel(runningUser);
                            }
                        }
                        
                    }
                    System.debug('>> query '+query);
                    SObject result = Database.query(query);//it is a loop of max 2 items
                    KPIs.put(kpiName, Integer.valueOf(result.get('expr0')));
                }
                
            }
            System.debug('>> KPI map'+KPIs);
            return KPIs;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}