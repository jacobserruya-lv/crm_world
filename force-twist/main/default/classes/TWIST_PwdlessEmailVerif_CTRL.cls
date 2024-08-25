public without sharing class TWIST_PwdlessEmailVerif_CTRL {
    
    public final static String LV_DOMAIN = 'Louis Vuitton Domain';
    public final static String VERIFY_GHOST_PATH = 'Passwordless Verify Ghost Path';
    
    
    public PageReference redirect() {
      
        try {
            TWIST_Settings__c twist_settings = TWIST_Settings__c.getInstance();
            
            String identifier = ApexPages.currentPage().getParameters().get('identifier');
            String redirectUrl = ApexPages.currentPage().getParameters().get('redirect-uri');
            String username = ApexPages.currentPage().getParameters().get('username');
            String locale = ApexPages.currentPage().getParameters().get('locale') != null ? ApexPages.currentPage().getParameters().get('locale') : twist_settings.Default_Language_Country_Parameter__c;

            Map<String,String> paths = TWIST_Utils.getPaths(locale, 'mylv', '');

            return new PageReference(paths.get(LV_DOMAIN) + paths.get(VERIFY_GHOST_PATH) + '&code=' + identifier + '&redirect-url=' + redirectUrl+'&username='+EncodingUtil.urlEncode(username, 'UTF-8'));   
        }
        catch(Exception e) {
            new Logs.ERROR('TWIST_PwdlessEmailVerif_CTRL', 'APEX CODE', e.getMessage(), 'url: ' + ApexPages.currentPage().getUrl() + '\n' + e.getStackTraceString());
            System.debug('An error occured: ' + e.getMessage() + e.getStackTraceString());
        }
        return null;
    }

}