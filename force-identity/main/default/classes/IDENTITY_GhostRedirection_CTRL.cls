/**
    About
    -----
    Description: Controller for IDENTITY_Redirection Visualforce Page
    Created for: Identity project
    Create date: Oct 2018

    Details
    -------
    ** SSO - Social lofin: redirect to auth provider sso url
    ** LOGIN: redirect to success url with access token
    ** SOCIAL LOGIN: redirect to registration page with friendly URL parameters
    ** EXCEPTION: redirect to Louis Vuitton
*/
public without sharing class IDENTITY_GhostRedirection_CTRL {

    public String lang_country {get; set;}
    public String dispatch_country {get; set;}
    public String origin {get; set;}

    public Map<String,String> paths {get; set;}

    // STATIC VALUES
    public final String DOMAIN = 'Louis Vuitton Domain';
    public final String LANG_COUNTRY_KEY = 'lang-country';
    public final String ORIGIN_KEY = 'origin';
    public final String REDIRECTION_PAGE_GHOST = 'Twist Context Ghost Page URL';

    public IDENTITY_GhostRedirection_CTRL() {

        // FOR DEBUG
        System.debug('PARAMS');
        for(String key : ApexPages.currentPage().getParameters().keySet()){
            System.debug(key + ' ' + ApexPages.currentPage().getParameters().get(key));
        }
        setContext();
        setPaths();
    }

    /*
    *** DESCRIPTION Get URL parameters and define language, country, origin
    *** RETURN
    */
    public void setContext(){
        System.debug('>>> setContext() - datetime: ' + String.valueOf(Datetime.now().getTime()));
        // origin
        if(ApexPages.currentPage().getParameters().get(ORIGIN_KEY) != null){
            origin = ApexPages.currentPage().getParameters().get(ORIGIN_KEY);
        }
        else if(ApexPages.currentPage().getCookies().get(ORIGIN_KEY) != null){
            origin = ApexPages.currentPage().getCookies().get(ORIGIN_KEY).getValue();
        }
        else{
            origin = IDENTITY_Settings__c.getInstance().Default_Origin_Parameter__c;
        }
        if(ApexPages.currentPage().getParameters().get(LANG_COUNTRY_KEY) != null){
            lang_country = ApexPages.currentPage().getParameters().get(LANG_COUNTRY_KEY);
        }
        else if(ApexPages.currentPage().getCookies().get(LANG_COUNTRY_KEY) != null){
            lang_country = ApexPages.currentPage().getCookies().get(LANG_COUNTRY_KEY).getValue();
        }
        else{
            lang_country = IDENTITY_Settings__c.getInstance().Default_Language_Country_Parameter__c;
        }

        // dispatch_country -- for multi-country website
        if(Pattern.compile('[A-Z]{2}').matcher(ApexPages.currentPage().getParameters().get('dispatchCountry') ?? '').matches()) {
            dispatch_country = ApexPages.currentPage().getParameters().get('dispatchCountry');
        }
    }

    /*
    *** DESCRIPTION Set redirection URL 
    *** RETURN      
    */
    public void setPaths(){
        paths = Identity_Utils.getPaths(lang_country, origin, dispatch_country);
         //GHOST REDIRECTION
         paths.put(REDIRECTION_PAGE_GHOST, paths.get(DOMAIN) + paths.get('Twist Context Ghost Page Path') + ApexPages.currentPage().getParameters().get('friendlyUrl')?.substringAfter('?'));

        // FOR DEBUG
        System.debug('PATHS');
        for(String key : paths.keySet()){
            System.debug(key + ' ' + paths.get(key));
        }
    }
    /*
    *** DESCRIPTION Redirect to Salesforce link according rules
    *** RETURN      New PageReference 
    */
    public PageReference redirect() {
        PageReference ghostSite =  new PageReference(paths.get(REDIRECTION_PAGE_GHOST));
        ghostSite.setRedirect(true);
        return ghostSite;
    }
}