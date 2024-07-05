public with sharing class TWIST_LWCWrapper_CTRL {

    public String utagDataStringified {get; set;}
    public String utagDataScript {get; set;}
    public String redirectionLinkToLVapp {get; set;}

    public PageReference init() {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        utagDataStringified = TWIST_GoogleAnalytics_Utils.buildUtagDataObjectFromCurrentPageParams(
            params.get(TWIST_QueryParamKey_CONST.ORIGIN),
            params.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY),
            params.get(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY),
            params.get(TWIST_QueryParamKey_CONST.PAGE)
        );
        utagDataScript = TWIST_Settings__c.getInstance().Utag__c;
        redirectionLinkToLVapp = checkRedirectToLvAppAccordingExclusiveOffer();
        return null;
    }

       private static String checkRedirectToLvAppAccordingExclusiveOffer(){
        Map<String,String> params = ApexPages.currentPage().getParameters();
        String userAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
        Boolean isUtmCampaignValid = TWIST_Utils.isUtmCampaignValid(params.get('utm_campaign'));
        Boolean isCareService =  params.get('campaign') != null && params.get('campaign').contains('careService');
        String redirectionDeeplinkValue = isUtmCampaignValid ? 'myexclusive' : isCareService ? 'mycareservice' : '';
    
        if(TWIST_Utils.doRedirectionToLVapp(userAgent, params, isUtmCampaignValid)){
           return getLVappRedirectionLink(params.get('cid'), redirectionDeeplinkValue);
        }

        return '';
    }

    @testVisible
    private static String getLVappRedirectionLink(String cid, String redirectionDeeplinkValue) {
        // CARE SERVICE + EXCLUSIVE EXPERIENCE FLOWS HAS TO BE REDIRECTED TO LV APP
        TWIST_IDENTITY_Paths__mdt path = [SELECT Name__c, Value__c FROM TWIST_IDENTITY_Paths__mdt WHERE Name__c =: TWIST_IdentityPathsMdt_CONST.LVAPP_URL_SCHEME LIMIT 1];
        String lvappPath = path.Value__c;
        return String.format('{0}{1}/{2}/{3}', new List<String> {
            lvappPath,
            TWIST_QueryParamKey_CONST.ACCOUNT_ACTIVATION,
            (cid != null ? EncodingUtil.urlEncode(cid, 'UTF-8') : ''),
            redirectionDeeplinkValue
        });
    }   
}