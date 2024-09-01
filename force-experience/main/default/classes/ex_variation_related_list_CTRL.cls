public with sharing class ex_variation_related_list_CTRL {


    public static final String SYSTEM_ADMIN_PROFILE = 'System Administrator';
    public static final String ADMIN_CORPORATE_PROFILE = 'System Admin_Corporate';
    public static final String LV_CLUB_PROFILE = 'LV_Club';
    public static final String EX_PCR_PERMISSION_SET = 'Events_Experiences_PCR';
    public static final String EX_ZONES_PERMISSION_SET = 'Events_Experiences_Zones_Regions';
    public static final String EXPERIENCE_IN_STORE_RECORD_TYPE = 'Experience';
    public static final String EXPERIENCE_OUT_STORE_RECORD_TYPE = 'Out_of_Store_Event';
    public static final String VARIATION_IN_STORE_RECORD_TYPE = 'Physical_Event';
    public static final String VARIATION_OUT_STORE_RECORD_TYPE = 'Out_of_Store_Event';
    public static Map<string, String> experience_variation_RT_map = new Map<string, String>{ EXPERIENCE_IN_STORE_RECORD_TYPE => VARIATION_IN_STORE_RECORD_TYPE,  
                                                                                             EXPERIENCE_OUT_STORE_RECORD_TYPE => VARIATION_OUT_STORE_RECORD_TYPE };


    @AuraEnabled ( cacheable=true ) 
    public static Map<String,Object> initComponentConfig(String experienceId){
        try {
            Brand_Experience__c experience = [SELECT RecordType.developerName FROM Brand_Experience__c WHERE Id =: experienceId];
            String experienceRT = experience.RecordType.developerName;
            Map<String,Object> componentConfig = new Map<String,Object>();
            componentConfig.put('variations', getVariations(experienceId, experienceRT));
            componentConfig.put('displayNewBtn', displayNewBtn(experienceRT));

            String variationRTName = experience_variation_RT_map.get(experience.RecordType.developerName);
            RecordType variationRT = [SELECT Id  FROM RecordType WHERE SobjectType = 'Brand_Experience_Variation__c' AND developerName =: variationRTName limit 1];
            componentConfig.put('variationRTId', variationRT.Id);
            componentConfig.put('variationRTName',variationRTName);
            componentConfig.put('experienceRTName',experienceRT);



            return componentConfig;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<Brand_Experience_Variation__c> getVariations (String experienceId, String experienceRT){
        try{
            User runningUser = EX_Store_Hierarchy_Utils.getUserHierarchies();
            String query = 'SELECT Id, Name, StartDateTime__c, EndDateTime__c, Store__r.name, Store__r.StoreCountry__c, Store__r.Zone__r.Name, toLabel(Status__c), inStoreEventFormat__c, Nb_Target_Clients__c, Target_Sales__c, formatedAddress__c, Nb_Nominated_Clients__c '
                            + ' FROM Brand_Experience_Variation__c'
                            + ' WHERE Type__c = \'Event\' AND SubType__c = \'Physical\' AND Brand_Experience__c = \''+experienceId+'\'';
            
            List<string> userPermissionSet =  EX_Store_Hierarchy_Utils.getUserPermissionSet();
            system.debug('userPermissionSet'+userPermissionSet);
            if( experienceRT == EXPERIENCE_IN_STORE_RECORD_TYPE && !(runningUser.Profile.Name == SYSTEM_ADMIN_PROFILE || runningUser.Profile.Name == ADMIN_CORPORATE_PROFILE || runningUser.Profile.Name == LV_CLUB_PROFILE || userPermissionSet.contains(EX_PCR_PERMISSION_SET))){
                Set<Id> storeIds = EX_Store_Hierarchy_Utils.getStoreIds(experienceId, runningUser);
                System.debug('>> storeIds '+storeIds);
                query += ' AND Store__c IN (\''+ String.join(storeIds, '\' , \'') +'\')';
            }
            query += 'ORDER BY CreatedDate DESC';
            system.debug('>> query'+query);
            List<Brand_Experience_Variation__c> variations = Database.query(query);
    
            return variations;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
   }

    private static Boolean displayNewBtn(String RTdeveloperName){
        try {
            User runningUser = EX_Store_Hierarchy_Utils.getUserHierarchies();
            List<string> userPermissionSet = EX_Store_Hierarchy_Utils.getUserPermissionSet();
            if( (RTdeveloperName == EXPERIENCE_IN_STORE_RECORD_TYPE && (runningUser.Profile.Name == SYSTEM_ADMIN_PROFILE || runningUser.Profile.Name == ADMIN_CORPORATE_PROFILE || runningUser.Profile.Name == LV_CLUB_PROFILE || userPermissionSet.contains(EX_ZONES_PERMISSION_SET))) ||
                (RTdeveloperName == EXPERIENCE_OUT_STORE_RECORD_TYPE && (runningUser.Profile.Name == SYSTEM_ADMIN_PROFILE || runningUser.Profile.Name == ADMIN_CORPORATE_PROFILE || runningUser.Profile.Name == LV_CLUB_PROFILE || userPermissionSet.contains(EX_ZONES_PERMISSION_SET) || userPermissionSet.contains(EX_PCR_PERMISSION_SET))))
            {
                return true;
            }
            else{
                return false;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<RecordsData> getFilteredStores(String objectApiName, Id recordId, String searchString) {
        String filterField = 'Store__r.Name';
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, Store__c, Store__r.Name FROM '+objectApiName+' WHERE Brand_Experience__c = \''+ recordId + '\'';
            if(String.isNotBlank(searchString)) {
                query += ' AND '+filterField+
                		' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' ';
            }
            System.debug('**query: '+query);
	        for(SObject s : Database.query(query)) {
                String storeName = (String) s.getSobject('Store__r').get('Name');
                recordsDataList.add(new RecordsData(storeName, (String)s.get('Store__c')) );	       
            }
            System.debug('**recordsDataList: '+recordsDataList);
            return recordsDataList;
	    } catch (Exception err) {
	    	if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
	    }
    }
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

}