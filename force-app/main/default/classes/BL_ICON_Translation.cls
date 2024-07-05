/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-08-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   02-21-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global  with sharing class BL_ICON_Translation  extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET
{

     
    global Object executeGET()
    {        
        String language = (getPathParameter('language') != null ? getPathParameter('language') : UserInfo.getLanguage());
        String application = (getPathParameter('application') != null ? getPathParameter('application') : 'ICON');

        Map<String, Object> result = new Map<String, Object>();    

        result.put('language', language) ;      
        result.put('translations', BL_ICON_Translation_Helper.getTranslationData(language , String.isnotblank(application)?application:'ICON' )) ;  
        if(BL_AppSettings.customParams != null && BL_AppSettings.customParams.get('language') != null){       
            result.put('default_language', (String) BL_AppSettings.customParams.get('language')) ;  
            result.put('default_translations', BL_ICON_Translation_Helper.getTranslationData((String) BL_AppSettings.customParams.get('language'),String.isnotblank(application)?application:'ICON')) ;  
        }       
        return  new BL_WS_Response(result);
      
     }

      
        

}