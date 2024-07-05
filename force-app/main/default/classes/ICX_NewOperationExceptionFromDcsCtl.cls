public class ICX_NewOperationExceptionFromDcsCtl {
    @AuraEnabled( cacheable=true ) 
    public static String getCaseRecordTypeID (){
        Id CaseRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operation Exception').getRecordTypeId();
        return CaseRTID;
   }

   @AuraEnabled( cacheable=true ) 
    public static CareService__c getCareRecord (String careId){
        CareService__c care = [select id,Client__c,Client__r.SPO_Country_code__pc,Assigned_To__c from CareService__c where id=:careId ];
        return care;
   }
}