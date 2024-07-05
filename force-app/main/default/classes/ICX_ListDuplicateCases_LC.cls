public class ICX_ListDuplicateCases_LC {
    
    
    @AuraEnabled
    public static List<Case> getDuplicateCases(String ShippingGroup,String OrderShipping, string AccId,string CaseId){
        id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Operation_Exception').getRecordTypeId();
        list<Case> casesList = new list <Case>();
        string Query = 'Select id,CaseNumber,Order_Shipping__r.ShippingNumber__c,Shipping_group__c,AccountId,Account.Name,Issue_Category__c ,CreatedDate,Status From Case';
        Query += ' Where RecordTypeId= \''+ CaseRecordTypeId + '\' AND Status != \'Closed\'';
        system.debug(AccId);
        if(!string.isBlank(CaseId)){
             Query += ' AND id!=\''+CaseId+'\'';
        }
        if(!string.isBlank(AccId)){
            Query += ' AND ((Order_Shipping__r.ShippingNumber__c = \''+OrderShipping+'\' AND Order_Shipping__r.ShippingNumber__c!=null) OR (Shipping_group__c= \''+ ShippingGroup + '\' AND Shipping_group__c!=null) OR AccountId= \'' + AccId +'\' ) order by Shipping_group__c,Order_Shipping__r.ShippingNumber__c, AccountId';
            
        }else{
            Query += ' AND ((Order_Shipping__r.ShippingNumber__c = \''+OrderShipping+'\' AND Order_Shipping__r.ShippingNumber__c!=null) OR (Shipping_group__c= \''+ ShippingGroup + '\' AND Shipping_group__c!=null))';
        }
        return Database.query(Query);
    }
    @AuraEnabled
    public static Case getCase(Id CaseId){
        list<Case> casesList = new list <Case>();
        Case c=[select id,Order_Shipping__r.ShippingNumber__c, Shipping_group__c,AccountId From Case where id=:CaseId ];
        return c;
        
    }
    
    
}