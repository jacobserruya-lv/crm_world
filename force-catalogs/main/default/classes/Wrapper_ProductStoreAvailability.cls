//Created by: Balink 2017
//Description: Wrapper contains products  store availabilities & price data for component "Product Availability"

public with sharing class Wrapper_ProductStoreAvailability {
    
    @AuraEnabled public String id {set; get;}
    @AuraEnabled public String productCatalogId {set; get;}
    @AuraEnabled public String storeId {set; get;}
    //@AuraEnabled public String name {set; get;}
    @AuraEnabled public String storeName {set; get;}
    @AuraEnabled public String currencyCoin {set; get;}
    @AuraEnabled public String googleMapLink {set; get;}
    //@AuraEnabled public Location storeLocation {set; get;}
    @AuraEnabled public Double locationLatitude {set; get;}
    @AuraEnabled public Double locationLongitude {set; get;}
    
    @AuraEnabled public Boolean isNearby { set; get; }
    @AuraEnabled public Boolean isDefault { set; get; }
    @AuraEnabled public Boolean isDigital { set; get; }
    @AuraEnabled public Boolean haveInTransit { set; get; }
    @AuraEnabled public Boolean csc {set; get;}
    @AuraEnabled public Boolean online {set; get;}
    @AuraEnabled public Boolean haveAvailabilities {set; get;}
    @AuraEnabled public Decimal inTransit {set; get;}
    @AuraEnabled public Decimal inStock {set; get;} 
    @AuraEnabled public Double price {set; get;}
    @AuraEnabled public Wrapper_ProductCatalogStore store {set; get;}
    @AuraEnabled public Store__c storeData {set;get;}
    @AuraEnabled public String errorCode{set;get;}
    
    public Wrapper_ProductStoreAvailability() {
        csc = false;
        online = false; 
    }
    
    @AuraEnabled
    public static Map<String, List<Wrapper_ProductStoreAvailability>> fillDataToProductStoreAvailabilitiesWrappers(Map<String, List<Wrapper_ProductStoreAvailability>> ProductStoreAvailabilities, Map<String, Store__c> storeCodemap, Store__c defaultStore){
     
        for(String SKU: ProductStoreAvailabilities.keySet()){
            //for(Wrapper_ProductStoreAvailability productWrapper: ProductStoreAvailabilities.get(SKU)){
            List<Wrapper_ProductStoreAvailability> ListProducatAvailability =  ProductStoreAvailabilities.get(SKU);
            for(Integer i=0;i<ListProducatAvailability.size(); i++){
                Wrapper_ProductStoreAvailability ProductWrapper = ListProducatAvailability[i];
                
                //system.debug('productWrapper.storeData' + productWrapper.storeData);
                //system.debug('defaultStore' + defaultStore);
            	if(productWrapper.storeData != null ) {
                    productWrapper.store = Wrapper_ProductCatalogStore.convertToStoreWrapper(productWrapper.storeData, productWrapper.storeData.RetailStoreId__c == defaultStore.RetailStoreId__c);
                    productWrapper.isDigital = productWrapper.store.isDigital;
                    productWrapper.storeName = productWrapper.storeData.Name;
                    productWrapper.currencyCoin = Ctrl_ProductCatalog.getCurrencySymbolFromIso(productWrapper.currencyCoin);
                    productWrapper.isDefault = (productWrapper.store.retailStoreId == defaultStore.RetailStoreId__c);
                    productWrapper.haveInTransit = (productWrapper.storeData.StoreCountry__c != 'USA' && productWrapper.storeData.StoreCountry__c != 'CHINA'?true:false);
                    Double rangeInKm = 30; 
                    Double distance = -1;
                    
                    system.debug('location ' + productWrapper.storeData.StoreLocation__c);
                    if(productWrapper.storeData.StoreLocation__c != null) {
                        
                        productWrapper.locationLatitude = productWrapper.storeData.StoreLocation__c.getLatitude();
                        productWrapper.locationLongitude = productWrapper.storeData.StoreLocation__c.getLongitude();
                        
                        if(storeCodemap.values()[0].StoreLocation__c != null) {
                            distance = Location.getDistance(storeCodemap.values()[0].StoreLocation__c, productWrapper.storeData.StoreLocation__c, 'km');  
                        }
                        
                        if (productWrapper.storeData.Address__c != null && productWrapper.storeData.StoreCountry__c !=null)
                            productWrapper.googleMapLink = 'https://maps.google.com/?q=' + productWrapper.storeData.Address__c + ',' + productWrapper.storeData.StoreCountry__c;
                        else
                            productWrapper.googleMapLink = 'https://maps.google.com/?q=' + String.valueOf(productWrapper.locationLatitude) + ',' + String.valueOf(productWrapper.locationLongitude);
                        
                        
                        productWrapper.isNearby = (distance > 0) ? (distance <= rangeInKm) : false;
                    }
                    else {
                        productWrapper.isNearby = false;
                    }
                }
                else {
                    productWrapper.isNearby = false;
                }
               	productWrapper.storeData=null;
                ListProducatAvailability.set(i,productWrapper);   
                //system.debug('my list ' + ListProducatAvailability[i]);
            }
            //system.debug('ListProducatAvailability ' + ListProducatAvailability);
            ProductStoreAvailabilities.put(SKU,ListProducatAvailability);
        }
        return ProductStoreAvailabilities;
    }
    
}