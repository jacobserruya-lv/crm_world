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

   @AuraEnabled( cacheable=true ) 
    public static Brand_Experience__c getExperienceRecord (String experienceId){
        Brand_Experience__c ex = [select id,Name,Experience_StartDate__c,Experience_EndDate__c from Brand_Experience__c where id=:experienceId ];
        return ex;
   }
}