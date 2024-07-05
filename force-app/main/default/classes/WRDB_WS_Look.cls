/*
CreatedDate: May 2018
Company: Balink
Author: Jeremy Martiano
Description: Interface Web Sevice to Save Looks And Get Looks
*/

@RestResource(urlMapping='/Look/*')
global without sharing class WRDB_WS_Look {
    /*=================================================================================================================*/
    //HTTP Request POST called From MyRepair
    
    @HttpPost
    global static void post() {
        RestRequest req = RestContext.request;
        String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 200;
        string response;
        
        Map<String,Object> body = new Map<String,Object>();
        if (req.requestBody != null) {
            body = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
        }
        
        try{
            if(service == '' || service == 'Look'){
                response = JSON.serialize(saveLook(body));
            }else if(service == 'Share'){
                response = JSON.serialize(shareLook(body));
            } else if (service == 'Archive'){
                response = JSON.serialize(archiveLook(body));
            }
            res.responseBody = Blob.valueOf(response);
            //UtilsLogs.addLog('ICON','IM_WS_CareService', JSON.serialize(body), JSON.serialize(req), response, '');
            // new Logs.DEBUG('WRDB_WS_Look','API',response);
        }
        catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
            ResponseHandler errorObject = new  ResponseHandler(null,null,null);
            if(ex.getTypeName() == 'DmlException' ){
                errorObject = new ResponseHandler(ex.getDmlType(0), ex.getMessage() + ' ' + ex.getLineNumber(), ex.getDmlFieldNames(0));
            } else {
                errorObject = new ResponseHandler(null, ex.getMessage() + ' ' + ex.getLineNumber(), null);
            }
            
            res.responseBody = Blob.valueOf(JSON.serialize(errorObject));
            res.statusCode = 400;
            // new Logs.ERROR('WRDB_WS_Look','API',ex);
        }
    }
    
    /*=================================================================================================================*/
    //HTTP Request GET called From getting look by Id or all looks of a user identity 
    @HttpGet
    global static void get() {
        RestRequest req = RestContext.request;
        String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 200;
        
        string response;
        try{
            if(service == '' || service == 'Look'){
                response = JSON.serialize(getLooks(req.params),true);
            }
            res.responseBody = Blob.valueOf(response);
            // new Logs.DEBUG('WRDB_WS_Look','API',response);
        }
        catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
            ResponseHandler errorObject = new  ResponseHandler(null,null,null);
            errorObject = new ResponseHandler(null, ex.getMessage() + ' ' + ex.getLineNumber(), null);
            res.responseBody = Blob.valueOf(JSON.serialize(errorObject));
            res.statusCode = 400;
            // new Logs.ERROR('WRDB_WS_Look','API',ex);
        }
    }   
    
    /*=================================================================================================================*/
    //HTTP Request DELETE called in order to delete a draft look 
    @HttpDelete
    global static void doDelete() {
        RestRequest req = RestContext.request;
        String lookId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 204;
        try{
            if( lookId != '' && lookId != 'Look'){
                List<Look__c> looks = [SELECT Id, is_draft__c FROM Look__c Where Id =:lookId AND is_draft__c = TRUE];
                if(looks.size() > 0){
                    delete looks[0];
                } else{
                    throw new LookException('THE LOOK IS NOT A DRAFT OR NOT FOUND');
                }
                
            }
            // new Logs.DEBUG('WRDB_WS_Look','API',response);
        }
        catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
            ResponseHandler errorObject = new  ResponseHandler(null,null,null);
            errorObject = new ResponseHandler(null, ex.getMessage() + ' ' + ex.getLineNumber(), null);
            res.responseBody = Blob.valueOf(JSON.serialize(errorObject));
            res.statusCode = 400;
            // new Logs.ERROR('WRDB_WS_Look','API',ex);
        }
    } 
    /*=================================================================================================================*/
    //Function to getLooks:
    global static Object getLooks(Map<String, String> paramsMap){
        String userId = paramsMap.get('userId');
        String clientId = paramsMap.get('clientId');
        String lookId = paramsMap.get('lookId') != null ? getDecryptedId(paramsMap.get('lookId')): null;
        Map<string,object> responseData = new Map<string, object>();
        
        Look_Share__c[] looks;
        String accountId = '';
        String getLooksbyAccountIdQuery = 'Select Look__r.Id, Look__r.Reference_Id__c, Look__r.SKUS__c, Look__r.MasterSKU__c, Look__r.Picture_URL__c,Look__r.SHORT_LV_URL_Sharing__c,'+
            ' Look__r.Picture_URL_Mobile__c, Look__r.lv_url_sharing__c, createdDate,Look__r.TECH_EnCrypted_LookId__c, '+
            '  toLabel(CreatedBy.DefaultStore__c),CreatedBy.TECH_DefaultStoreName__c, Look__r.Store__r.Name, Look__r.Store__r.RetailStoreId__c, Look__r.Validity_Date__c, Look__r.Owner.Name, Client__c,Look__r.Fake_Owner_Name__c '+
            ' From Look_Share__c Where  Client__c =:accountId ORDER BY CreatedDate DESC';
        
        String currentUserLookLVURL = getCurrentUserLookLVURL(null);
        
        if (!String.isEmpty(lookId)){
            List<Look__c> lookRecords = [Select id, Reference_Id__c, Picture_URL__c, Picture_URL_Mobile__c,  lv_url_sharing__c, SKUs__c, MasterSKU__c,Owner.Name,Fake_Owner_Name__c,
                                         CreatedDate, validity_date__c, is_draft__c, is_inspiration__c,share_with_store__c, Store__r.RetailStoreId__c, Store__r.Name,SHORT_LV_URL_Sharing__c,TECH_EnCrypted_LookId__c,
                                         (Select Store__r.RetailStoreId__c, Store__r.Name From LookStore__r)
                                         From Look__c Where Id = :lookId ];
            if (lookRecords.size() > 0 ){
                if(String.isEmpty(lookRecords[0].SHORT_LV_URL_Sharing__c)){
                    lookRecords[0].SHORT_LV_URL_Sharing__c = getShortenedLookLVURL(lookRecords[0].lv_url_sharing__c);
                    upsert lookRecords[0];
                }
                return new LookWrapper(lookRecords[0],false, currentUserLookLVURL);
            }
        } else{
            if (!String.isEmpty(userId)){
                User user_identity = [SELECT Id, AccountId from User WHERE Id =:userId LIMIT 1];
                if(user_identity != null){
                    accountId = user_identity.AccountId;
                }
            } else if (!String.isEmpty(clientId)){
                accountId = clientId;
            }
            
            if(!String.isEmpty(accountId)) {
                looks = Database.query(getLooksbyAccountIdQuery);
                List<LookWrapper> looksW = new List<LookWrapper>();
                for(Look_Share__c lookshare: looks){
                    looksW.add(new LookWrapper(lookshare, currentUserLookLVURL));
                }
                responseData.put('totalSize', (looksW!=null) ? looksW.size() : 0);
                looksW = getProductsLooks(looksW);
                responseData.put('records', looksW);
            }
        }
        
        return responseData;
    } 
    /*=================================================================================================================*/
    //Set productLooks
    
    global static List<LookWrapper> getProductsLooks(List<LookWrapper> looks){
        Set<String> skus = new Set<String>();
        for (LookWrapper look : looks){
            skus.addAll(look.skus.split(';'));
        }
        List<ProductCatalogue__c> products = [SELECT Name, Sku__c, Tech_Wardrobing_ImageUrl__c FROM ProductCatalogue__c WHERE SKU__c IN :skus];
        Map<String, ProductCatalogue__c> productsMap = new Map<String, ProductCatalogue__c>();
        for(ProductCatalogue__c prd : products){
            productsMap.put(prd.SKU__c, prd);
        }
        for (LookWrapper look : looks){
            look.products = new List<ProductWrapper>();
            for (String sku : look.skus.split(';')){
                if(productsMap.get(sku) != null){
                    look.products.add(new ProductWrapper(productsMap.get(sku)));
                }
            }
        }
        
        return looks;
    }
    
    /*=================================================================================================================*/
    //SAVE LOOK
    
    global static Object saveLook(Map<String,Object> bodyMap){
        System.debug('#########TEST '+ bodyMap);
        List<Object> skuList = (List<Object>) bodyMap.get('skus');
        String master_sku = (String) bodyMap.get('master_sku');
        String user_identifier = (String) bodyMap.get('user_identifier');
        Boolean share_with_store = (Boolean) bodyMap.get('share_with_store');
        Boolean is_draft = (Boolean) bodyMap.get('is_draft');
        Boolean is_inspiration = (Boolean) bodyMap.get('is_inspiration');
        List<Object> zones = (List<Object>) bodyMap.get('zones');
        List<Object> countries = (List<Object>) bodyMap.get('countries');
        List<Object> store_codes = (List<Object>) bodyMap.get('store_codes');
        String locale = (String) bodyMap.get('locale');
        String name = (String) bodyMap.get('name');
        String layoutId = (String) bodyMap.get('layout_id');
        String lookId = (String) bodyMap.get('lookId');
        String layoutUrlMobile = (String) bodyMap.get('layoutUrlMobile');
        String layoutUrlWeb = (String) bodyMap.get('layoutUrlWeb');
        String fake_owner_name = (String) bodyMap.get('fake_owner_name');
        Date validity_date = (String)bodyMap.get('validity_date') != null ? date.valueOf((String)bodyMap.get('validity_date')) : null;
        Boolean is_active = (Boolean) bodyMap.get('is_active');
        String prd_sources = JSON.serialize(( List<Object>) bodyMap.get('prd_sources'));
        String skus = '';
        system.debug(prd_sources);
        system.debug(bodyMap);
        for(Object sku : skuList){
            skus = skus + (String)sku +';';
        }
        
        Look__c look = new Look__c(
            MasterSku__c  = master_sku, skus__c = skus,
            is_Active__c = is_active == null ? true : is_active,
            share_with_store__c = share_with_store,
            layoutId__c = layoutId, 
            is_draft__c = is_draft,
            is_inspiration__c = is_inspiration, 
            locale__c = locale, 
            name = ( String.isNotBlank(name) ? name : getLookName(master_sku)),
            Picture_URL_Mobile__c = layoutUrlMobile,
            Picture_URL__c = layoutUrlWeb,
            Fake_Owner_Name__c = fake_owner_name,
            Source_JSON__c = prd_sources
        );
        if(String.isNotEmpty(look.name) && look.name.length() > 79 ){
            look.name = look.name.substring(0, 79);
        }
        if(String.isNotEmpty(lookId)){
            List<Look__c> refLook = [select Id, Reference_Id__c From Look__c where Id =: lookId];
            if(refLook.size() > 0){
                look.Id = refLook[0].Id;
                // Look.TECH_EnCrypted_LookId__c = EncodingUtil.urlEncode(getEncryptedId(refLook[0].Id), 'UTF-8');
                Look.TECH_EnCrypted_LookId__c = getEncryptedId(refLook[0].Id);
            }
        }
        
        if (validity_date != null){
            look.validity_date__c = validity_date;
        }
        
        User u = getUserInfos(user_identifier);
        if (u!= null){
            look.OwnerId = u.id;
        }
        
        try{
            look.Master_Product__r = new ProductCatalogue__c(SKU__c = master_sku);
        } catch(Exception e){
            system.debug(e.getMessage());
        }
        if(store_codes != null && store_codes.size() == 1){
            try{
                look.Store__r = new Store__c(RetailStoreId__c = ((String) store_codes[0]).toUpperCase());
            } catch(Exception e){
                system.debug(e.getMessage());
            }
        }
        
        
        upsert look;
        
        List<Zone__c> zoneList = [Select Id, Name, ZoneId__c From Zone__c];
        Map<String, Id> zonesMap = new Map<String, String>();
        for(Zone__c z : zoneList){
            zonesMap.put(z.Name, z.Id);
        }
        
        List<LookStore__c> lookStores = new List<LookStore__c>();
        List<LookCountry__c> lookCountries = new List<LookCountry__c>();
        List<LookZone__c> lookZones = new List<LookZone__c>();
        
        if(store_codes != null && store_codes.size() > 0){
            List<String> storeCodeIds = new List<String>();
            for(Object store_code : store_codes ){
                try{
                    storeCodeIds.add((String) store_code);
                    LookStore__c lookStore = new LookStore__c(
                        Look__c = look.Id,
                        Store__r = new Store__c (RetailStoreId__c = ((String) store_code).toUpperCase()),
                        ExternalId__c = look.Id + ((String) store_code).toUpperCase()
                    );
                    lookStores.add(lookStore);
                } catch(Exception e){
                    system.debug(e.getMessage());
                }
            }
            try{
                List<Store__c> storeList = [Select Id, RetailStoreId__c, Zone__c, StoreCountry__c From Store__c Where RetailStoreId__c IN :storeCodeIds];
                if(countries != null && countries.size() > 0 || storeList[0].StoreCountry__c != null){
                    LookCountry__c lookCountry = new LookCountry__c(
                        Look__c = look.Id,
                        Country__r = countries != null && countries.size() > 0 ? new Country__c(tech_duplicate__c = ((String) countries[0]).replaceAll('\\s', '_')) : 
                        new Country__c(tech_duplicate__c = storeList[0].StoreCountry__c.replaceAll('\\s', '_')),
                        ExternalId__c = look.Id + (String) countries[0]
                    );
                    lookCountries.add(lookCountry);
                }
                if(zones != null && zones.size() > 0 && zonesMap.get((String) zones[0]) != null || storeList[0].Zone__c != null){
                    LookZone__c lookZone = new LookZone__c(
                        Look__c = look.Id,
                        Zone__c = zones != null && zones.size() > 0 && zonesMap.get((String) zones[0]) != null ? zonesMap.get((String) zones[0]):
                        storeList[0].Zone__c,
                        ExternalId__c = look.Id + (String) zones[0]
                    );
                    lookZones.add(lookZone);
                }
            } catch(Exception e){
                system.debug(e.getMessage());
            }
        } else if(countries != null && countries.size() > 0){
            for(Object country : countries ){
                try{
                    LookCountry__c lookCountry = new LookCountry__c(
                        Look__c = look.Id,
                        Country__r = new Country__c(tech_duplicate__c = ((String) country).replaceAll('\\s', '_')),
                        ExternalId__c =look.Id + (String) country
                    );
                    lookCountries.add(lookCountry);
                } catch(Exception e){
                    system.debug(e.getMessage());
                }
            }
            try{
                if(zones != null && zones.size() > 0 && zonesMap.get((String) zones[0]) != null){
                    LookZone__c lookZone = new LookZone__c(
                        Look__c = look.Id,
                        Zone__c = zonesMap.get((String) zones[0]),
                        ExternalId__c = look.Id + (String) zones[0]
                    );
                    lookZones.add(lookZone);
                }
            } catch(Exception e){
                system.debug(e.getMessage());
            }
        } else if(zones != null && zones.size() > 0 && zonesMap.get((String) zones[0]) != null){
            for(Object zone : zones ){
                try{
                    LookZone__c lookZone = new LookZone__c(
                        Look__c = look.Id,
                        Zone__c = zonesMap.get((String) zone),
                        ExternalId__c = look.Id + (String) zone
                    );
                    lookZones.add(lookZone);
                } catch(Exception e){
                    system.debug(e.getMessage());
                }
            }
        }
        system.debug(lookStores);
        if(lookStores.size()>0){
            Database.upsert(lookStores,false);
            lookStores = [Select Id, Look__c, Store__c, ExternalId__c From LookStore__c where Id IN : lookStores];
        }
        if(lookCountries.size()>0){
            Database.upsert(lookCountries,false);
            lookCountries = [Select Id, Look__c, Country__c, ExternalId__c From LookCountry__c where Id IN : lookCountries];
        }
        if(lookZones.size()>0){
            Database.upsert(lookZones,false);
            lookZones = [Select Id, Look__c, Zone__c, ExternalId__c From LookZone__c where Id IN : lookZones];
        }
        //For Encrypt Look Id
        if(look.TECH_EnCrypted_LookId__c == null){
        // look.TECH_EnCrypted_LookId__c = EncodingUtil.urlEncode(getEncryptedId(look.Id), 'UTF-8');
        look.TECH_EnCrypted_LookId__c = getEncryptedId(look.Id);
        update look;
        }
        Look__c lookUpserted = [Select id,Reference_Id__c, Name, Picture_URL__c,Picture_URL_Mobile__c, lv_url_sharing__c, SKUs__c, MasterSKU__c, CreatedDate,SHORT_LV_URL_Sharing__c,
                                validity_date__c, is_draft__c, is_inspiration__c, share_with_store__c, Owner.Name, Fake_Owner_Name__c, locale__c, layoutId__c,Store__r.RetailStoreId__c, Store__r.Name ,TECH_EnCrypted_LookId__c,
                                is_active__c, (Select Store__r.RetailStoreId__c, Store__r.Name From LookStore__r)
                                from look__c where id = :look.Id ORDER BY CreatedDate DESC ];
        
        
        //Shortened link
        if(String.isEmpty(lookUpserted.SHORT_LV_URL_Sharing__c) && String.isNotEmpty(lookUpserted.lv_url_sharing__c)){
            setFutureShortenedLookLVURL(lookUpserted.Id);
        }
        
        Map<String, Object> results = new Map<String, Object>();
        results.put('look', getProductsLooks( new List<LookWrapper>{new LookWrapper(lookUpserted,true, null)})[0]);
        results.put('lookToUpsert',lookUpserted) ;
        results.put('lookStores',lookStores) ;
        results.put('lookCountries',lookCountries) ;
        results.put('lookZones',lookZones) ;
        return results;
    }
    /*=================================================================================================================*/
    //GET COMPO NAME
    
    global static String getLookName(String master_sku){
        String nameLook = 'My '+ master_sku +' Look';
        List<ProductCatalogue__c> prdList = [
            Select Name from ProductCatalogue__c Where SKU__c = : master_sku
        ];
        if(prdList.size() > 0){
            nameLook =  'My '+ prdList[0].Name +' Look';
        }
        return nameLook;
    }
    
    
    /*=================================================================================================================*/
    //SHARE LOOK
    
    global static Object shareLook(Map<String,Object> bodyMap){
        String look_id = (String) bodyMap.get('lookId');
        String client_id = (String) bodyMap.get('clientId');
        String channel = (String) bodyMap.get('channel');
        String ownerId = (String) bodyMap.get('ownerId');
        Boolean noTaskCreation = bodyMap.get('noTaskCreation') != null ? (Boolean) bodyMap.get('noTaskCreation') : false;
        String currentUserLookLVURL = getCurrentUserLookLVURL(ownerId);
        Look_Share__c  lookshare = new Look_Share__c(
            Client__c = client_id,
            Look__c = look_id,
            Channel__c = channel,
            ExternalId__c = look_id+client_id+channel
        );
        if(String.isNotEmpty(ownerId)){
            lookshare.CreatedById =  ownerId;
            
            if(noTaskCreation != true){
                Task t = new Task(
                    Look__c = look_id,
                    whatId = client_id,
                    Subject = channel.toUpperCase() + ' message sent',
                    Priority = 'Normal',
                    activityDate = system.Date.today(),
                    isWardrobing__c = true,
                    ActionType__c = 'Mobile Chat',
                    Status = 'Completed',
                    OwnerId =  ownerId
                );
                upsert t;
            }
        }
        system.debug(lookshare);
        Database.upsert(lookshare, Look_Share__c.Fields.ExternalId__c, false);
        List<Look_Share__c> lookRecords = [
            SELECT Look__r.Id,Look__r.Reference_Id__c, Look__r.SKUS__c, Look__r.MasterSKU__c, Look__r.Picture_URL__c, Look__r.SHORT_LV_URL_Sharing__c,
            Look__r.Picture_URL_Mobile__c, Look__r.lv_url_sharing__c, createdDate, toLabel(CreatedBy.DefaultStore__c), CreatedBy.TECH_DefaultStoreName__c,
            Look__r.Store__r.RetailStoreId__c, Look__r.Store__r.name, Look__r.Validity_Date__c, Look__r.Owner.Name, Look__r.Fake_Owner_Name__c, Client__c
            FROM Look_Share__c 
            WHERE ExternalId__c = :lookshare.ExternalId__c
        ];
        if(lookRecords.size() > 0) {
            List<LookWrapper> lookW = new List<LookWrapper>{new LookWrapper(lookRecords[0], currentUserLookLVURL)};
                return getProductsLooks(lookW)[0];
        }
        throw new LookException('LOOK NOT FOUND');
    }
    
    /*=================================================================================================================*/
    //ARCHIVE LOOK
    
    global static Object archiveLook(Map<String,Object> bodyMap){
        String look_id = (String) bodyMap.get('lookId');
        List<Look__c> looksToUpdate = new List<Look__c>();
        List<Look__c> lookRef = [Select Id, Reference_Id__c, is_active__c From Look__c Where Id =: look_id];
        if(lookRef.size() > 0 && lookRef[0].Reference_Id__c != null){
            looksToUpdate = [Select Id, Reference_Id__c, is_active__c From Look__c Where Reference_Id__c = :lookRef[0].Reference_Id__c OR Id =: lookRef[0].Id];
        } else{
            looksToUpdate = lookRef;
        }
        
        if(looksToUpdate.size() > 0){
            for(Look__c l : looksToUpdate){
                l.Is_Active__c = false;
            }
            update looksToUpdate;
            return looksToUpdate[0];
        }
        
        throw new LookException('LOOK NOT FOUND');
        
    }
    
    /*=================================================================================================================*/
    //GET USERINFOS
    global static User getUserInfos(string user_identifier){
        List<User> users = [Select Id, DefaultStore__c From User Where Is_Identity_User__c = false AND (FederationIdentifier = :user_identifier OR (FederationIdentifier = null AND username = :user_identifier))];
        if(users.size() > 0){
            return users[0];
        }
        return null;
    }
    
    /*=================================================================================================================*/
    //GET USER LOOK URL
    global static String getCurrentUserLookLVURL(String ownerId){
        Profile wrdb_tech_profile = [Select Id From Profile Where Name='LV Wardrobing'];
        if(String.isNotEmpty(ownerId)){
            List<User> users = [select id, profileId from User where Id = :ownerId];
            if(users.size() > 0 && users[0].ProfileId == wrdb_tech_profile.Id ){
                return null;
            }
        } else if(UserInfo.getProfileId() == wrdb_tech_profile.Id){
            return null;
        }
        String userId  = String.isNotEmpty(ownerId) ? ownerId : UserInfo.getUserId();
        List<User> users = [Select Id, DefaultStore__c From User Where Id =: userId];
        if(users.size() > 0){
            List<Store__c> store = [Select Id, Zone__c, StoreCountry__c, RetailStoreId__c From Store__c Where RetailStoreId__c = : users[0].DefaultStore__c];
            String countrylocale  = store.size() > 0 && store[0].StoreCountry__c!= null && CountryConfig__c.getInstance(store[0].StoreCountry__c) != null ?
                CountryConfig__c.getInstance(store[0].StoreCountry__c).Locale__c : 'en_E1';
            List<WRDB_Locale__mdt> localeSettings = [SELECT LV_COM_Locale__c, DeveloperName, Page_Name__c,DispatchCountry__c FROM WRDB_Locale__mdt Where DeveloperName = :countrylocale];
            List<WRDB_LVCOM_URL__mdt> lvcom_urls = [Select DeveloperName, Path__c From WRDB_LVCOM_URL__mdt];
            Map<String, String> lvcom_urlsMap = new Map<String, String>();
            for(WRDB_LVCOM_URL__mdt lvurl : lvcom_urls){
                lvcom_urlsMap.put(lvurl.DeveloperName, lvurl.Path__c);
            }
            String lvLocale = localeSettings.size() > 0 ? localeSettings[0].LV_COM_Locale__c : 'eng-e1';
            String pageName = localeSettings.size() > 0 ? localeSettings[0].Page_Name__c : 'recommendations';
            String dispatchCountry = localeSettings.size() > 0 ? localeSettings[0].DispatchCountry__c : null;
            String lvHost = lvLocale.contains('zhs-cn') ? lvcom_urlsMap.get('LVCOM_HOST_URL_CHINA') : lvcom_urlsMap.get('LVCOM_HOST_URL_WW');
            String lvPath = lvcom_urlsMap.get('LVCOM_PATH');
            String lookLUrl = lvHost + '/' + lvLocale + '/' + lvPath + '/' + pageName + '/{lookId}' + (dispatchCountry != null ?  '?dispatchCountry='+dispatchCountry : '')+
                '&campaign=look_{lookId}&A=DreamId';
            return lookLUrl;
        }
        return null;
    }
    
    /*=================================================================================================================*/
    //GET SHORTENED LOOK URL
    public static String getShortenedLookLVURL(String lookUrl){
        // List<WRDB_LVCOM_URL__mdt> lvcom_urls = [Select DeveloperName, Path__c From WRDB_LVCOM_URL__mdt];
        // Map<String, String> lvcom_urlsMap = new Map<String, String>();
        // for(WRDB_LVCOM_URL__mdt lvurl : lvcom_urls){
        //     lvcom_urlsMap.put(lvurl.DeveloperName, lvurl.Path__c);
        // }
        // String lvLocale = lookRecord.TECH_LV_LOCALE__c;
        // String pageName = lookRecord.TECH_LV_PAGE_NAME__c;
        // String dispatchCountry = lookRecord.TECH_LV_DISPATCH_COUNTRY__c;
        // String lvHost = lvLocale.contains('zhs-cn') ? lvcom_urlsMap.get('LVCOM_HOST_URL_CHINA') : lvcom_urlsMap.get('LVCOM_HOST_URL_WW');
        // String lvPath = lvcom_urlsMap.get('LVCOM_PATH');
        
        // String lookLUrl = lvHost + '/' + lvLocale + '/' + lvPath + '/' + pageName + '/' + lookRecord.Id + (dispatchCountry != null ?  '?dispatchCountry='+dispatchCountry : '');
        
        Map<String,String> SETTINGS = ThirdParty_Utils.getSettings('AKAMAI_Shortner');
        String endpoint = lookUrl.contains('louisvuitton.cn') ? SETTINGS.get('endpoint_china') : SETTINGS.get('endpoint');
        Map<String, Object> body = new Map<String, Object>{'url' => lookUrl , 'base' => endpoint};
            HTTP_Utils request = new HTTP_Utils()
            .post(endpoint)
            .header('Authorization', 'Basic ' + getBasicAuthentication(SETTINGS.get('username'), SETTINGS.get('password')))
            .header('Content-Type', 'application/json')
            .body(JSON.serialize(body))
            .call();
        
        system.debug(request);
        Map<String,String> response = request.getParameters();
        return response.get('short');
    }
    
    public static String getBasicAuthentication(String username, String password){
        String payload = username + ':' + password;
        return EncodingUtil.base64Encode(Blob.valueOf(payload));
    }
    
    /*=================================================================================================================*/
    //GET SHORTENED LOOK URL
    @future(callout=true)
    public static Void setFutureShortenedLookLVURL(String lookId){
        List<Look__c> lookRecords = [Select lv_url_sharing__c, SHORT_LV_URL_Sharing__c from Look__c Where Id = : lookId];
        Look__c lookRecord = lookRecords.size() > 0 ? lookRecords[0] : null;
        if(lookRecord != null && String.isEmpty(lookRecord.SHORT_LV_URL_Sharing__c) && String.isNotEmpty(lookRecord.lv_url_sharing__c)){
            lookRecord.SHORT_LV_URL_Sharing__c = getShortenedLookLVURL(lookRecord.lv_url_sharing__c);
            upsert lookRecord;
        }
    }
    /*=================================================================================================================*/
    //DESCRIPTION Encrypted Look Id
    public static String getEncryptedId(String lookId){
        if( String.IsNotBlank(IDENTITY_Settings__c.getOrgDefaults().AES_Key__c)){
            Blob key = EncodingUtil.base64Decode(IDENTITY_Settings__c.getOrgDefaults().AES_Key__c);
            if(String.isNotBlank(lookId)){
                Blob lookBlob = Blob.valueOf(lookId);          
                Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, lookBlob);
                system.debug(encrypted);
                String base64Encoded = EncodingUtil.base64Encode(encrypted);
                String urlenCoded64 = EncodingUtil.urlEncode(base64Encoded, 'UTF-8');
                String urlenCoded642 = EncodingUtil.urlEncode(urlenCoded64, 'UTF-8');
                return urlenCoded642;
            }
        }
        
        return null;
    }
    /*=================================================================================================================*/
    //DESCRIPTION Decrypted Look Id
    public static String getDecryptedId(String EncryptedlookId){
        if( String.IsNotBlank(IDENTITY_Settings__c.getOrgDefaults().AES_Key__c)){
            Blob key = EncodingUtil.base64Decode(IDENTITY_Settings__c.getOrgDefaults().AES_Key__c);
            if(String.isNotBlank(EncryptedlookId)){
                System.debug('##### IS NOT ID');
                // String urlDeCoded64 = EncodingUtil.urlDecode(EncryptedlookId, 'UTF-8');
                Blob base64Decoded = EncodingUtil.base64Decode(EncryptedlookId);
                Blob decrypted = Crypto.decryptWithManagedIV('AES128', key,base64Decoded);
                String decryptedLookId = decrypted.toString();
                return decryptedLookId;   
            }
        }
        return null;
    }
    /*=================================================================================================================*/
    //ResponseWrapper
    
    global class LookException extends Exception {}
    
    
    global class ResponseHandler {
        public Boolean success {get; set;}
        public List<ErrorWrapper> errors {get;set;}
        public Boolean created {get;set;}
        
        public ResponseHandler(System.StatusCode statusCode, String message, List<String> fields){
            this.success = false;
            this.errors = new List<ErrorWrapper>{ new ErrorWrapper(statusCode, message, fields)};
                this.created = false;
        }
        
    } 
    
    global class ErrorWrapper {
        public System.StatusCode statusCode {get; set;}
        public String message {get;set;}
        public List<String> fields {get;set;}
        public ErrorWrapper(System.StatusCode statusCode, String message, List<String> fields){
            this.fields = new List<String>();
            this.statusCode = statusCode;
            this.message = message;
            this.fields = fields;
        }
    }
    
    global class LookWrapper{
        public String id {get; set;}
        public String picture_url {get; set;}
        public String picture_url_mobile {get; set;}
        public String lv_sharing_url {get; set;}
        public String short_lv_sharing_url {get; set;}
        public String currentUser_lv_sharing_url {get; set;}
        public String skus {get; set;}
        public String master_sku {get; set;}
        public String store_id {get; set;}
        public String store_name {get; set;}
        public DateTime created_date {get; set;}
        public Date validity_date {get; set;}
        public Boolean is_draft {get; set;}
        public Boolean is_inspiration {get; set;}
        public Boolean share_with_store {get; set;}
        public String name {get; set;}
        public String ca_name {get; set;}
        public String account_id {get; set;}
        public String fake_owner_name {get;set;}
        public String refId {get;set;}
        public List<ProductWrapper> products {get; set;}
        
        
        public LookWrapper(Look__c look, Boolean is_public, String currentUserLookLVURL){
            this.id = look.id;
            this.picture_url = look.Picture_URL__c;
            this.picture_url_mobile = look.Picture_URL_Mobile__c;
            this.lv_sharing_url = String.isNotEmpty(look.SHORT_LV_URL_Sharing__c) ? look.SHORT_LV_URL_Sharing__c : look.lv_url_sharing__c;
            this.skus = look.skus__c;
            this.master_sku = look.masterSku__c;
            this.created_date = look.createdDate;
            this.validity_date = look.validity_date__c;
            this.ca_name = look.Owner.name;
            this.fake_owner_name = look.Fake_Owner_Name__c;
            this.refId = look.Reference_Id__c;
            this.store_name = look.LookStore__r != null && look.LookStore__r.size() > 0 ? look.LookStore__r[0].Store__r.Name: look.Store__r.Name;
            this.store_id = look.LookStore__r != null && look.LookStore__r.size() > 0 ? look.LookStore__r[0].Store__r.RetailStoreId__c: look.Store__r.RetailStoreId__c;
            this.currentUser_lv_sharing_url = currentUserLookLVURL != null ? currentUserLookLVURL.replace('{lookId}',look.TECH_EnCrypted_LookId__c) : null;
            this.short_lv_sharing_url = look.SHORT_LV_URL_Sharing__c;
            
            if(is_public){
                this.is_draft = look.is_draft__c;
                this.is_inspiration = look.is_inspiration__c;
                this.share_with_store = look.share_with_store__c;
                this.name = look.name;
            }
            
        }
        
        public LookWrapper(Look_Share__c lookShare, String currentUserLookLVURL){
            this.id = lookShare.Look__r.id;
            this.picture_url = lookShare.Look__r.Picture_URL__c;
            this.picture_url_mobile = lookShare.Look__r.Picture_URL_Mobile__c;
            this.lv_sharing_url = String.isNotEmpty(lookShare.Look__r.SHORT_LV_URL_Sharing__c) ? lookShare.Look__r.SHORT_LV_URL_Sharing__c : lookShare.Look__r.lv_url_sharing__c;
            this.skus = lookShare.Look__r.skus__c;
            this.master_sku = lookShare.Look__r.masterSku__c;
            this.ca_name = lookShare.Look__r.Owner.name;
            this.created_date = lookShare.createdDate;
            this.validity_date = lookShare.Look__r.validity_date__c;
            this.account_id = lookShare.client__c;
            this.fake_owner_name = lookShare.Look__r.Fake_Owner_Name__c;
            this.refId = lookShare.Look__r.Reference_Id__c; 
            this.store_id = lookShare.CreatedBy.TECH_DefaultStoreName__c != null  ? lookShare.CreatedBy.TECH_DefaultStoreName__c : lookShare.Look__r.Store__r.RetailStoreId__c;
            this.store_name = lookShare.CreatedBy.DefaultStore__c != null  ? lookShare.CreatedBy.DefaultStore__c :lookShare.Look__r.Store__r.Name;
            this.currentUser_lv_sharing_url = currentUserLookLVURL != null ? currentUserLookLVURL.replace('{lookId}',lookShare.Look__r.TECH_EnCrypted_LookId__c) : null;
            this.short_lv_sharing_url = lookShare.Look__r.SHORT_LV_URL_Sharing__c;
            
        }
    }
    
    global class ProductWrapper{
        public String name {get; set;}
        public String sku {get; set;}
        public String image_url {get; set;}
        
        public ProductWrapper(ProductCatalogue__c product){
            this.name = product.name;
            this.sku = product.sku__c;
            this.image_url = product.Tech_Wardrobing_ImageUrl__c;
        }
    }
    
}