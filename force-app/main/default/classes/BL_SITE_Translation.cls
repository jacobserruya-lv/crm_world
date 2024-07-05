global  with sharing class BL_SITE_Translation  extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET
{

    global Object executeGET()
    {
        BL_WS_Router.clientPlatform = 'WEB';

        String language = (getQueryParameter('language') != null ? getQueryParameter('language') : UserInfo.getLanguage());
        String application = getQueryParameter('application');

        Map<String, Object> result = new Map<String, Object>();

        if(String.isBlank(application)){
            throw new BL_Exceptions.BL_Exception('APPLICATION_REQUIRED', 'You must specify the application in parameters');
        }

        result.put('language', language) ;
        result.put('translations', BL_ICON_Translation_Helper.getTranslationData(language , application)) ;

        return  new BL_WS_Response(result);
    }
}