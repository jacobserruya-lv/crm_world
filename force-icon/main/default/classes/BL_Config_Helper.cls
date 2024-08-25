/**
 * @group Clienteling/Helper
 */
public with sharing class BL_Config_Helper {
    
    static final string JSONRoot_Picklist              = 'picklists'; 
    static final string JSONRoot_AppSettings           = 'app-settings';
    static final string JSONRoot_EmailTemplateFields   = 'emailTemplatesFields';
    static final string JSONRoot_Dashboards            = 'dashboards';
    static final string JSONRoot_Translations          = 'translations';
    static final string JSONRoot_Mapping               = 'mapping';
    static final string JSONRoot_StoreHierarchy        = 'storeHierarchy';
    static final string JSONRoot_SharingChannels        = 'sharingChannel';
    static final string JSONRoot_Locals        = 'locals';

  
    public static Object getAllConfig(string applicationName){
        
        string language = UserInfo.getLanguage();
       
        return new Map<String,Object>
        {
           JSONRoot_AppSettings         => getAppSettings(),
           JSONRoot_Picklist            => getPicklists(applicationName),
           JSONRoot_EmailTemplateFields => getEmailTemplatesFields(),
           JSONRoot_Translations        => BL_ICON_Translation_Helper.getTranslationData(language ,'ICON'),
           JSONRoot_Mapping             => getMapping()
        };

    }

    public static Object getMapping(){
        return new  Map<String,Object>{
            'event' => getMapping(BL_ICON_Constants.USE_CASE_EVENT),
            'account'=>getMapping(BL_ICON_Constants.USE_CASE_CLIENTMEMBERS_SERVICE)};
         //   'storeHierarchy'=> getStoreHierarchy()};
    }

    public static Object getMapping(String useCaseLabel){
        return new BL_EasyQuery()
        .useCase(useCaseLabel)
        .getFiedsMapping();
    }

   
    public static Map<String, Object> getConfigByFeatures(String features, String applicationName){
        Map<String, Object> result = new Map<String, Object>();
        List<String> featuresList = features.split(';');
        for(String f : featuresList){
            switch on f{
                when 'mapping'{
                     result.put(JSONRoot_Mapping, getMapping());
                }
                when 'picklists'{
                    result.put(JSONRoot_Picklist, getPicklists(applicationName));
                } 
                when 'translations'{
                    string language = UserInfo.getLanguage();
                    result.put(JSONRoot_Translations ,BL_ICON_Translation_Helper.getTranslationData(language ,'ICON')) ;
                }
                when 'app-settings'{ 
                    result.put(JSONRoot_AppSettings, getAppSettings());
                }
                when 'emailTemplatesFields'{ 
                    result.put(JSONRoot_EmailTemplateFields, getEmailTemplatesFields());
                }
                when 'storeHierarchy'{ 
                    result.put(JSONRoot_StoreHierarchy, getStoreHierarchy());
                }
                when 'sharing-channels'{ 
                    result.put(JSONRoot_SharingChannels, getSharingChannels());
                }
                when 'locals' {
                    result.put(JSONRoot_Locals, getLocals());
                }
            }
        }

        return result;
    }

    public static Object getPicklists(string applicationName){  
        return BL_Picklist.getPicklistValues(applicationName);
    }

    public static Object getAppSettings(){
        Map<String,Object>  result = new BL_EasyQuery()
             .useCase(BL_ICON_Constants.USE_CASE_APP_SETTING)
             .executeQuery()
             .getMappedObject();
 
         if (BL_AppSettings.customParams != null) {
            result.putAll(BL_AppSettings.customParams);
         }
         return result;     
     }

    public static List<Map<String,Object>> getEmailTemplatesFields(){
        return new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_EMAIL_TEMPLATE_FIELDS)
            .condition('BL_Active__c = TRUE')
            .executeQuery()
            .getMappedObjects();
    } 

    // interactive Wardrobing for Corporate 
    public static Object getStoreHierarchy(){

        Map<String,String> zoneCountry = new Map<String,String>();
        Map<String,List<Object>> countryStore = new Map<String,List<Object>>();
        Map<String,List<Object>> zoneCountries = new Map<String,List<Object>>();

        for(Store__c store : [ SELECT management_zone_level_tech__c, storecountry__c, retailstoreid__c ,storetype__c, Time_Zone_Id__c, name 
                               FROM store__c
                               WHERE status__c IN ('Open','Opening soon') AND management_zone_level_tech__c  != null AND storecountry__c != null]){

            if(!countryStore.containsKey(store.storecountry__c)){

                countryStore.put(store.storecountry__c , new List<Object>());
            }
            Map<String,String> storeCode = new Map<String,String> { store.name => store.retailstoreid__c};
                                   
            countryStore.get(store.storecountry__c).add(storeCode);
                        
            zoneCountry.put(store.storecountry__c ,store.management_zone_level_tech__c);
         }

        for(String countryKey : zoneCountry.keySet()){
            
            String zone = zoneCountry.get(countryKey);
            
			if(!zoneCountries.containsKey(zone)){

                zoneCountries.put(zone , new List<Object>());
            }
            Map<String,Object> countries = new Map<String,Object>{countryKey => countryStore.get(countryKey)};
                
            zoneCountries.get(zone).add(countries);
        }

        return zoneCountries;

    }    
    
    public static Object getSharingChannels(){
       
        List<Map<String, Object>> countries =  new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_COUNTRY_INFO)
        .condition('HasOtherValue__c = FALSE')
        .executeQuery()
        .getMappedObjects();

        Map<String, Object> channelByCountry = new Map<String, Object>();
        Map<String, Object> channelInfos = new Map<String, Object>();
		
      
        for (WRDB_ChannelInfo__mdt channel : [SELECT MasterLabel,Deeplink__c ,Params__c,SentPreviewType__c,logoUrl__c FROM WRDB_ChannelInfo__mdt]) {
        	channelInfos.put(channel.MasterLabel,channel);
        }
        
        for(Map<String, Object> country : countries ){

            String countryCode = (String) country.get('iso3Code') ;
            if( String.isNotEmpty(countryCode))
                channelByCountry.put(countryCode ,country);
        }
		Map< String,Object> channels = new Map<String, Object>();
        channels.put('channelInfos',channelInfos);
        channels.put('channelByCountry',channelByCountry);
		
        return channels;
    }    

    public static List<Map<String, String>> getLocals() {
        List<Map<String, String>> locals = new List<Map<String, String>>();              
        List<CountryLanguage__c> countries = [ SELECT Country__r.name, ATG_Locale__c, Dispatch_Country__c FROM CountryLanguage__c  WHERE Default__c = TRUE AND ATG_Locale__c != NULL AND ATG_Locale__c != 'eng-e1' ];
        
        locals.add(
            new Map<String, String>  {
                'country' => 'INTERNATIONAL',
                'local' => 'eng-e1'
            }
        );

        for (CountryLanguage__c country : countries) {
            locals.add(
                new Map<String, String>  {
                    'country' => country.Country__r.name,
                    'local' => country.ATG_Locale__c,
                    'dispatchCountry' => country.Dispatch_Country__c
                }
            );
        }

        return locals;
    }  
}