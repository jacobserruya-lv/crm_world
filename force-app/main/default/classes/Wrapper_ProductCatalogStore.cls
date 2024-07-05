//Created By : Balink 2017
//Description: Wrapper contains Store Data

public with sharing class Wrapper_ProductCatalogStore {
    @AuraEnabled public String id {set; get;}
    @AuraEnabled public String name {set; get;}
    @AuraEnabled public String commercialName {set; get;}
    @AuraEnabled public String status {set; get;}
    @AuraEnabled public String country {set; get;}
	@AuraEnabled public String countryCode {set; get;}
    @AuraEnabled public Location location {set; get;}
    @AuraEnabled public String address {set; get;}
    @AuraEnabled public String currencyCoin {set; get;}
    @AuraEnabled public String retailStoreId {set; get;}
    
    @AuraEnabled public Double latitude {set; get;} 
    @AuraEnabled public Double longitude {set; get;}
    
    @AuraEnabled public Boolean isDefault {set; get;}
    @AuraEnabled public Boolean isDigital {set; get;}
    @AuraEnabled public OpeningHours openingHours {set; get;}
    
   	@AuraEnabled
   	public static List<Wrapper_ProductCatalogStore> convertToStoreWrappers(List<Store__c> storeSObjs) {
    	List<Wrapper_ProductCatalogStore> storeWrappers = null;
    	User currentUser = DAL_ProductCatalog.getUser(); 
    	
    	if(storeSObjs != null && storeSObjs.size() > 0) {
    		storeWrappers = new List<Wrapper_ProductCatalogStore>();
    		
    		for(Store__c storeSobj : storeSObjs) {
    			if(storeSobj != null) {
    				storeWrappers.add(convertToStoreWrapper(storeSobj, (storeSobj.RetailStoreId__c == currentUser.DefaultStore__c)));
    			}
    		}
    	}
    	return storeWrappers;
    }
    
    @AuraEnabled
    public static List<Store__c> convertToProductStoreAvailabilitiesSObjs(List<Wrapper_ProductCatalogStore> storeObjs) { 
    	List<Store__c> storesSobjs = new List<Store__c>(); 
    	
    	if(storeObjs != null && storeObjs.size() > 0) {
    		for(Wrapper_ProductCatalogStore storeWrapper : storeObjs) {
    			if(storeWrapper != null) {
    				storesSobjs.add(convertToStoreSObj(storeWrapper));
    			} 
    		}
    	}
    	return storesSobjs;
    }
    
    @AuraEnabled
    public static Store__c convertToStoreSObj(Wrapper_ProductCatalogStore productObj) {
    	Store__c storeSobj = new Store__c();
		return storeSobj;
    }
    
    @AuraEnabled
    public static Wrapper_ProductCatalogStore convertToStoreWrapper(Store__c storeSObj, Boolean isDefault) {
    	Wrapper_ProductCatalogStore storeWrapper = null;
    	
    	if(storeSObj != null) {
    		storeWrapper = new Wrapper_ProductCatalogStore();
    		storeWrapper.id = storeSObj.Id;
		    storeWrapper.name = storeSObj.Name;
		    storeWrapper.commercialName = storeSObj.CommercialName__c;
		    storeWrapper.status = storeSObj.Status__c; 
		    storeWrapper.isDefault = isDefault; 
		    storeWrapper.isDigital = Ctrl_ProductCatalog.DIGITAL_STORE_CODES.contains(storeSObj.RetailStoreId__c); 
		    storeWrapper.country = storeSObj.StoreCountry__c;
			storeWrapper.CountryCode = storeSObj.Store_CountryCode__c;
		    storeWrapper.retailStoreId = storeSObj.RetailStoreId__c;
		    if(storeSObj.StoreLocation__c != null) {
		    	storeWrapper.latitude = storeSObj.StoreLocation__c.getLatitude();
			    storeWrapper.longitude = storeSObj.StoreLocation__c.getLongitude();
		    }
		    storeWrapper.address = storeSObj.Address__c;
		    storeWrapper.currencyCoin = storeSObj.Currency__c;
		    if(storeSObj.OpeningHours__c != null) {
				try {
					storeWrapper.openingHours =
					(OpeningHours) Json.deserialize(storeSObj.OpeningHours__c, OpeningHours.class);
				}catch(Exception e) { Ctrl_ProductCatalog.log('convertToStoreWrapper', e);}
		    }
    	}
		
		return storeWrapper;
    }
    
    public class OpeningHours {
    	
    	public OpeningHours() {}
    	
    	@AuraEnabled public String Sunday {set; get;}
    	@AuraEnabled public String Monday {set; get;}
    	@AuraEnabled public String Tuesday {set; get;}
    	@AuraEnabled public String Wednesday {set; get;}
    	@AuraEnabled public String Thursday {set; get;}
    	@AuraEnabled public String Friday {set; get;}
    	@AuraEnabled public String Saturday {set; get;}
    	
    }
}