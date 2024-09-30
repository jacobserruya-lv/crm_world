/* @author Naomi Baroghel
* @date creation fev 2022
* @description controller for oob button
*/
public with sharing class ICX_TWIST_OOB {
    
    // ref in : icx_oob_button.js
    @AuraEnabled(cacheable=true)
    public static Boolean OOBVisibleByCountry(){
        return String.isNotEmpty(getUserCountryIsoCode2ToUse());
    }
    
    // ref in : icx_oob_utils.js
    @AuraEnabled(cacheable=true)
    public static User IsIdentityUser(String recordId) {
        User IdentityUser;
        system.debug(recordId);
        if (String.isNotBlank(recordId)) {
            list<user> ListIdentityUser = [SELECT Id,IsActive, LastLoginDate ,TECH_Email__c, TECH_MobilePhone__c,Username FROM User WHERE AccountId = : recordId LIMIT 1];
            IdentityUser= (ListIdentityUser.isEmpty() ? null : ListIdentityUser.get(0));
        }
        return IdentityUser;
        
    }
    
    // ref in : icx_oob_utils.js
    @AuraEnabled
    public static User activateIdentityUser(String recordId){
        User IdentityUser;
        try {
            IdentityUser = IsIdentityUser(recordId);
            if(IdentityUser!=null)
            {
                
                IdentityUser.IsActive=true;
                update IdentityUser;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return IdentityUser;
    }
    
    // ref in : icx_oob_utils.js
    @AuraEnabled(cacheable=true)
    public static String getPayloadLocal()
    {
        String payloadLocal ='LV-MEA';
        
        CountryLanguage__c countryLang= getCountryLanguage();
        payloadLocal = countryLang?.OOB_payloadLocal__c;
        return payloadLocal;
        
    }
    
    // ref in : n/a
    @AuraEnabled(cacheable=true)
    public static String getUserCountryIsoCode2ToUse()
    {
        String usrCountryIsoCode2 = getUserCountryIsoCode2();
        String usrZoneManagementCountryIsoCode2 = getZoneManagementDefaultCountryIsoCode2();
        
        // Retrieve the list of TWIST countries
        List<String> visibleCountry = new List<String>();
        OOB_Setting__c oobSetting =  OOB_Setting__c.getOrgDefaults();
        visibleCountry = oobSetting?.VisibilityCountryIso2__c?.split(';');
        
        // Is the isocode2 country in the list of countries declared as TWIST ?
        if(visibleCountry.contains(usrCountryIsoCode2)) {
            return usrCountryIsoCode2;
        }
        else if(visibleCountry.contains(usrZoneManagementCountryIsoCode2)) {
            return usrZoneManagementCountryIsoCode2;
        }
        else {
            return null;
        }
        
    }
    
    // ref in : n/a
    // ---------------------------------------------------------------------------------------
    // Return the isocode2 country of the default country defined for the user zone management    
    // ---------------------------------------------------------------------------------------
    public static String getZoneManagementDefaultCountryIsoCode2()
    {
        String defaultCountry;
        String userManagementLevel  = [SELECT Id, MANAGEMENT_ZONE_LEVEL__c FROM User WHERE Id =: UserInfo.getUserId()]?.MANAGEMENT_ZONE_LEVEL__c;
        OOB_Setting__c oobSetting =  OOB_Setting__c.getOrgDefaults();
        
        // EMAE
        if (userManagementLevel == '15') {
            return oobSetting.ZoneManagement_EMEA__c;
        }
        // ASIA NORTH == 13
        else if (userManagementLevel == '13'){
            return oobSetting.ZoneManagement_NORTH_ASIA__c;
        }
        // ASIA SOUTH == 14
        else if (userManagementLevel == '14'){
            return oobSetting.ZoneManagement_SOUTH_ASIA__c;
        }
        // AMERICAS == 3
        else if (userManagementLevel == '3'){
            return oobSetting.ZoneManagement_AMERICA__c;
        }
        else return null;
    }
    
    // ref in : n/a
    public static String getUserCountry()
    {
        String userCountry = [SELECT Id, Country__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1]?.Country__c;
        
        //if country is not in the metadata, we need to map it
        Map<String,String> countryMap = new Map<String,String> {
            'MACAU' => 'MACAO'
                };
                    if(countryMap.get(userCountry) != null) {
                        userCountry = countryMap.get(userCountry);
                    } 
        return userCountry;
    }
    
    // ref in : n/a
    public static CountryLanguage__c getCountryLanguage()
    {
        return getCountryLanguage(null);
    }
    
    // ref in : n/a
    public static CountryLanguage__c getCountryLanguage(String countryIso2Code)
    {
        List<CountryLanguage__c> countryLang;
        String userCountryIsoCode2 = countryIso2Code;
        
        if(userCountryIsoCode2==null){
            userCountryIsoCode2 = getUserCountryIsoCode2ToUse();
        }
        
        if(userCountryIsoCode2!=null){
            countryLang = [SELECT ATG_Locale__c, Dispatch_Country__c,OOB_Local__c,OOB_payloadLocal__c,Mulesoft_Local__c,Country__r.Iso2Code__c, Cart_Translation__c FROM CountryLanguage__c WHERE Default__c =: TRUE AND ATG_Locale__c != NULL AND Country__r.Iso2Code__c=:userCountryIsoCode2];
            
        }
        
        if(countryLang?.size() > 0)
        {
            return countryLang[0];
        }   
        else {
            return null;
        }
    }
    
    // ref in : n/a
    @AuraEnabled(cacheable=true)
    public static String getRedirectionLocal(String countryIso2Code)
    {
        CountryLanguage__c countryLang= getCountryLanguage(countryIso2Code);
        if(countryLang!=null)
        {
            return countryLang.ATG_Locale__c;
        }
        return 'eng-e1';
    }
    
    // ref in : icx_oob_utils.js
    @AuraEnabled(cacheable=true)
    public static String getUserCountryIsoCode2()
    {
        String currentCountryIso2;
        String userCountry = getUserCountry();
        
        if (userCountry != null) {
            currentCountryIso2 = [SELECT Id, Iso2Code__c FROM Country__c WHERE Name =: userCountry LIMIT 1].Iso2Code__c;
        }
        return currentCountryIso2;
    }
    
    // ref in : icx_oob_utils.js
    // ref in : icx_orderActions.js
    @AuraEnabled(cacheable=true)
    public static String getUserLocal(String countryIso2Code)
    {
        system.debug('getUserLocal-countryIso2Code:'+countryIso2Code);
        String local ='eng-e1';
        
        CountryLanguage__c countryLang= getCountryLanguage(countryIso2Code);
        local = countryLang?.OOB_Local__c!=null? countryLang.OOB_Local__c:countryLang?.ATG_Locale__c;
        return local;
        
    }
    
    // ref in : icx_oob_utils.js
    // ref in : icx_orderActions.js
    @AuraEnabled(cacheable=true)
    public static String getRedirectionEndpoint(String landingPage, String countryIso2Code)
    {
        String localURL;
        CountryLanguage__c countryLang= getCountryLanguage(countryIso2Code);
        if(countryLang!=null)
        {
            localURL = getRedirectionLocal(countryIso2Code) + landingPage;
            if(countryLang.Dispatch_Country__c!=null)
            {
                localURL+='?dispatchCountry='+countryLang.Dispatch_Country__c;
            }
        }
        return localURL;
    }
    
    
    // ref in : icx_oob_utils.js
    // ref in : WS_OrderActions.cls
    @AuraEnabled(cacheable=true)
    public static String getSFAgentAccessToken() {
        return UserInfo.getSessionId();
    }
    
    // ref in : icx_oobButton.js
    // ref in : icx_orderActions.js
    // ref in : icx_orderShippingCard
    @AuraEnabled(cacheable=true)
    public static String getRedirectionURL()
    {
        if(hasOOBPreviewPermission())
        {
            return OOB_Setting__c.getOrgDefaults().TwistOOB_RedirectionURL_Preview__c;
            
        }
        return OOB_Setting__c.getOrgDefaults().TwistOOB_RedirectionURL__c;
        
    }
    
    // ref in : icx_oob_utils.js
    // ref in : WS_OrderActions.cls
    @AuraEnabled(cacheable=true)
    public static MuleSoft_API_Callout__mdt getOOBEndpoint(String countryIso2Code)
    {
        if(hasOOBPreviewPermission())
        {
            return getMuleSoftAPICallout('OOB_Preview_Endpoint', countryIso2Code);
            
        }
        return getMuleSoftAPICallout('OOB_Endpoint', countryIso2Code);
        
    }
    
    public static MuleSoft_API_Callout__mdt getOOBEndpoint() {
        return getOOBEndpoint(null);
        
    }
    
    public static MuleSoft_API_Callout__mdt getOOBInitCartEndpoint(){
        return getOOBInitCartEndpoint(null);
    }
    
    // ref in : icx_orderActions.js
    @AuraEnabled(cacheable=true)
    public static MuleSoft_API_Callout__mdt getOOBInitCartEndpoint(String countryIso2Code)
    {
        return getMuleSoftAPICallout('OOB_InitCart_Endpoint', countryIso2Code);
    }
    
    // ref in : n/a
    
    
    public static MuleSoft_API_Callout__mdt getMuleSoftAPICallout(String endPointName, String countryIso2Code) {
        system.debug('getMuleSoftAPICallout-countryIso2Code:'+countryIso2Code);
        CountryLanguage__c countryLang= getCountryLanguage(countryIso2Code);
        String mulesoftLocal = countryLang?.Mulesoft_Local__c!=null ? countryLang.Mulesoft_Local__c : 'eco-eu';        
        system.debug('getMuleSoftAPICallout-mulesoftLocal:'+mulesoftLocal);
        MuleSoft_API_Callout__mdt calloutConfig = [SELECT Id,ClientId__c,ClientSecret__c,Endpoint__c FROM MuleSoft_API_Callout__mdt WHERE DeveloperName=:endPointName ];
        calloutConfig.Endpoint__c = calloutConfig.Endpoint__c!=null? calloutConfig.Endpoint__c.replace('{mulesoftLocal}',mulesoftLocal): calloutConfig.Endpoint__c;
        return calloutConfig;
    }
    
    public static Boolean hasOOBPreviewPermission()
    {
        return FeatureManagement.checkPermission('ICX_OOB_Preview');
    }
    
    //CSC-717 TWIST Exchange "/cart" translation for FR, DE, ES, MX, BR & IT
    // ref in : icx_orderActions.js
    @AuraEnabled(cacheable=true)
    public static String getCartTranslation(String countryIso2Code)
    {
        String translation ='cart';
        
        CountryLanguage__c countryLang= getCountryLanguage(countryIso2Code);
        if(countryLang?.Cart_Translation__c!=null)
            translation = countryLang?.Cart_Translation__c;
        
        return translation;
        
    }
    
}