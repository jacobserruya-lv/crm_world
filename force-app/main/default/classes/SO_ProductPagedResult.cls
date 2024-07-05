public class SO_ProductPagedResult {

    @AuraEnabled
    public Integer pageSize { get;set; }
    
    @AuraEnabled
    public Integer page { get;set; }
    
    @AuraEnabled
    public Integer total { get;set; }
    
    @AuraEnabled
    public List<ProductReferential__c> products { get;set; }
    
    //@AuraEnabled
    //public List<SO_ProductStoreAvailability_Wrapper> productsStoreAvailabilities { get;set; } 

    @AuraEnabled
    public List<ProductCatalogue__c> productPro { get;set; }

    @AuraEnabled
    public List<sObject> sobjects { get;set; }

    // need to serialize List<SO_WS_RMS_DoClientSearch.ResultLine> in JSON to pass List<Apex Type> in Lightning controller
    @AuraEnabled
    public String clientRmsList { get;set; }
//    public List<SO_WS_RMS_DoClientSearch.ResultLine> clientRmsList { get;set; }
}