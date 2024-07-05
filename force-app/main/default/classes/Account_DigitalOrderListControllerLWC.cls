public without sharing class Account_DigitalOrderListControllerLWC {
    
    @AuraEnabled(cacheable=true)
    public static Object getDigitalOrder(Id accountId){
        try {
            String parameter ;
            Account acc= [SELECT Id,PersonEmail,PersonMobilePhone ,SPO_Country_code__pc FROM Account WHERE id =: accountId LIMIT 1 ];
           
            if(String.isnotBlank(acc.PersonEmail)){
                parameter = 'userName='+acc.PersonEmail;
                return  WS_DigitalOrders.getOrderDetails(parameter);
            } 
            return null; 
            
            /*
            String userName = String.isnotBlank(acc.PersonEmail) ? acc.PersonEmail :'';
            String userNameChina =  acc.SPO_Country_code__pc=='CHN' && String.isnotBlank(acc.PersonMobilePhone)? acc.PersonMobilePhone :'';
            
            if(String.isnotBlank(userName) || String.isnotBlank(userNameChina)){
                parameter = 'userName='+(String.isnotBlank(userNameChina)? userNameChina :userName);
            }else{
                parameter = 'salesForceId='+ AccountId;
            }
            */
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Id> getProductMap(List<String> SKUList){
        Map<String, Id> productMap = new Map<String, Id>();
        for (ProductCatalogue__c p : [SELECT id, SKU__c FROM ProductCatalogue__c where SKU__c in:SKUList ]) {
            productMap.put(p.SKU__c, p.id);
        }
        return productMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getStoreCountry(Id storeId){
        string country = [SELECT StoreCountry__c FROM Store__c WHERE id =: storeId].StoreCountry__c;
        return country;
    }
    @AuraEnabled        
    public static Id getCaseRecordTypeID() {
        Id CaseRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Operation_Exception').getRecordTypeId();
        return CaseRTID;
    } 

    @AuraEnabled(cacheable=true)
    public static DigitalOrdersDisplay__c getZoneCountryToDisplay(){
        return DigitalOrdersDisplay__c.getOrgDefaults();
    }


}