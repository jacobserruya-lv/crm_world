public without sharing class IDENTITY_Template_CTRL {
    
    public Map<String,String> paths {get; set;}

    public String lang_country {get; set;}
    public String origin {get; set;}
    public String dispatch_country {get; set;}
    public String country_local {get; set;}
    public String language {get; set;}
    public String meta_language {get; set;}
    public String customCss {get;set;}

    public final String DOMAIN = 'Louis Vuitton Domain';
    
    public IDENTITY_Template_CTRL() {
        setContext();
        setPaths();
    }

    /*
    *** DESCRIPTION Get URL parameters and define language, country, origin
    *** RETURN      
    */
    public void setContext(){
        // origin
        origin = ApexPages.currentPage().getParameters().get('origin');
        if(origin == null){
            origin = IDENTITY_Settings__c.getInstance().Default_Origin_Parameter__c;
        }

        // dispatch_country -- for multi-country website
        if(Pattern.compile('[A-Z]{2}').matcher(ApexPages.currentPage().getParameters().get('dispatchCountry') ?? '').matches()) {
            dispatch_country = ApexPages.currentPage().getParameters().get('dispatchCountry');
        }

        // lang-country        
        lang_country = ApexPages.currentPage().getParameters().get('lang-country');
        if(lang_country == null){
            lang_country = IDENTITY_Settings__c.getInstance().Default_Language_Country_Parameter__c;
        }
        country_local = lang_country.substringAfter('-');
        
        language = [
            SELECT Salesforce__c
            FROM Language_Mapping_ATG_SF__mdt
            WHERE ATG__c =: lang_country
            LIMIT 1
            ].Salesforce__c;
            
        meta_language = [
            SELECT Meta_Language__c
            FROM Language_Mapping_ATG_SF__mdt
            WHERE ATG__c =: lang_country
            LIMIT 1
            ].Meta_Language__c;
            
        // CSS        
        customCss = 'redesign-2019.css';
        if(origin == 'lvconnect'){
            customCss = 'lv-connect.css';
        }
    }

    /*
    *** DESCRIPTION Set redirection URL 
    *** RETURN      
    */
    public void setPaths(){

        System.debug(lang_country + ' ' + origin + ' ' + dispatch_country);
        
        paths = Identity_Utils.getPaths(lang_country, origin, dispatch_country);

        // DOMAIN
        String domain = ApexPages.currentPage().getParameters().get('domain');
        if(!String.isEmpty(domain)){
            paths.put(DOMAIN, domain);
        }
        
        // FOR DEBUG
        System.debug('PATHS');
        for(String key : paths.keySet()){
            System.debug(key + ' ' + paths.get(key));
        }
    }
}