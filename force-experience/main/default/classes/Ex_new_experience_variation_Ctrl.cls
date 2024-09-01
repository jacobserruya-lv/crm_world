public class Ex_new_experience_variation_Ctrl {
    @AuraEnabled( cacheable=true ) 
    public static String getPhysicalEventRecordTypeID (){
        Id recordTypeId = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();
        return recordTypeId;
   }

   @AuraEnabled( cacheable=true ) 
   public static String getContentRecordTypeID (){
       Id recordTypeId = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Content').getRecordTypeId();
       return recordTypeId;
  }

  @AuraEnabled( cacheable=true ) 
  public static String getExclusiveOfferRecordTypeID (){
      Id recordTypeId = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Exclusive_Offer').getRecordTypeId();
      return recordTypeId;
 }

 @AuraEnabled( cacheable=true ) 
 public static String getDigitalEventRecordTypeID (){
     Id recordTypeId = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Digital_Event_Variation').getRecordTypeId();
     return recordTypeId;
}

   @AuraEnabled( cacheable=true) 
    public static Brand_Experience__c getExperienceRecord (String experienceId){
        Brand_Experience__c ex = [select id,Name,Experience_StartDate__c,Experience_EndDate__c from Brand_Experience__c where id=:experienceId ];
        return ex;
   }

    @AuraEnabled
    public static List<RecordsData> getFilteredStores(String objectName, Id recordId, String searchString) {
        String filterField = 'Store__r.Name';
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, Store__c, Store__r.Name FROM '+objectName+' WHERE Brand_Experience__c = \''+ recordId + '\'';
            if(String.isNotBlank(searchString)) {
                query += ' AND '+filterField+
                		' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';
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