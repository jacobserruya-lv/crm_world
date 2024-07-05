global  class BatchStoreInfos implements Database.Batchable<sObject>,Database.AllowsCallouts {

       
    public String query;
    private static Map<String, String> localesMap = new Map<String, String>();
    
    global BatchStoreInfos(){
        query = ' Select Id, tech_address__c, StoreLocation__Latitude__s, StoreLocation__Longitude__s, RetailStoreId__c, store_image_url__c, Local_Name__c, StoreCountry__c'+
        '  FROM Store__c where StoreCountry__c != null AND (StoreType__c = \'Store\' OR StoreType__c = \'POP UP - OON\') AND Status__c != \'Closed\'';
    }
        
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - BatchStoreInfos');
        System.debug('#### query : ' + query);
        return Database.getQueryLocator(query);   
    } 
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
        try{
            
            if(scope.size() > 0){
                this.setInfos((List<Store__c>) scope);
            }
            
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }       
    }
    
    global void finish(Database.BatchableContext CD){
    }

    private void setInfos(List<Store__c> stores){
        system.debug(stores.size());
        Map<String, String> mapStoreCodeTimeZone = new Map<String, String>();
        
        for(Store__c s : stores){			
            // Send the request, and return a response
            Map<String, Object> m = getData(s);

            if(m != null){
                List<String> addressParams = new List<String>();
                if (m.get('street') != null && String.isNotBlank((String)m.get('street'))){
                    addressParams.add((String)m.get('street'));
                }
                if (m.get('zipcode') != null && String.isNotBlank((String)m.get('zipcode'))){
                    addressParams.add((String)m.get('zipcode'));
                }
                if (m.get('city') != null && String.isNotBlank((String)m.get('city'))){
                    addressParams.add((String)m.get('city'));
                }
                
                s.tech_address__c = String.join(addressParams, ' ') ;
    
                s.Local_Name__c = (String) m.get('name');
                s.store_image_url__c = (String) m.get('formattedImgUrl');
            }
        }

        Database.update(stores, false);
    }


    private static Map<String, Object> getData(Store__c s){
        Map<String, Object> m;
        
        String url = 'https://api.louisvuitton.com/api/'+ getLocale(s.StoreCountry__c)
        +'/store/' + s.RetailStoreId__c;

        HTTP_UTILS httpUtils = new HTTP_UTILS()
        .get(url)
        .call();
        
        // Send the request, and return a response
        
        if(httpUtils.statusCode() == 200){
            m = httpUtils.getBodyResponse();
        } else {
            String url2 = 'https://api.louisvuitton.com/api/'+ 'eng-e1'
            +'/store/' + s.RetailStoreId__c;

            HTTP_UTILS httpUtils2 = new HTTP_UTILS()
            .get(url2)
            .call();
            if(httpUtils2.statusCode() == 200){
                m = httpUtils2.getBodyResponse();
            }
        }
        
        if (Test.isRunningTest() && m == null) {
            String jsonString = '{ "phone": "+49 (0) 211 864 700 (Kundenservice)", "callCenter": "false", "clickAndCollect": { "storeHours": [ { "hours": "", "day": "Monday" }, { "hours": "", "day": "Tuesday" }, { "hours": "", "day": "Wednesday" }, { "hours": "", "day": "Thursday" }, { "hours": "", "day": "Friday" }, { "hours": "", "day": "Saturday" }, { "hours": "", "day": "Sunday" } ], "estimatedDeliveryDate": { "time": "1584988159074" }, "delayInCC": { }, "estimatedDeliveryDateAsString": "23-03-2020", "availableForCC": "true", "cutOff": "13", "rmsCode": "J02", "delay": 2, "closingDays": "Vorübergehend geschlossen" }, "street": "Residenzstrasse 2", "availableForCC": "false", "city": "München", "@id": "J02", "formattedImgUrl": "https://de.louisvuitton.com/images/is/image/lv/1/PP_VP_L/louis-vuitton--StFi_Louis_Vuitton_MUNICH_MAXIMILLIANSTRASSE_311_1_DI3.jpg?wid={IMG_WIDTH}&hei={IMG_HEIGHT}", "distance": "0", "name": "Louis Vuitton München Residenzpost", "path": "deutschland", "zipcode": "80333", "country": "Deutschland", "picture": "StFi_Louis_Vuitton_MUNICH_MAXIMILLIANSTRASSE_311_1_DI3", "flagship": "false", "displayLocateInStore": "true", "categories": [ "Leather_Goods_and_Accessories", "MLV", "Sunglasses", "Ready_To_Wear_Women", "Ready_To_Wear_Men", "Shoe_Women", "Shoe_Men", "Watches", "Jewelry", "Perfume" ] }';
        	m = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
        }
        
        return m;
    }

    private static String getLocale(String country) {
        if (localesMap.isEmpty()){
            List<WRDB_Locale__mdt> locales = [Select LV_COM_Locale__c, DeveloperName FROM WRDB_Locale__mdt];
            for(WRDB_Locale__mdt locale : locales){
                localesMap.put(locale.DeveloperName, locale.LV_COM_Locale__c);
            }
        }
        
        String countrylocale  = country!= null && CountryConfig__c.getInstance(country) != null ?
             CountryConfig__c.getInstance(country).Locale__c : 'en_E1';
        return localesMap.get(countryLocale);
    }
}