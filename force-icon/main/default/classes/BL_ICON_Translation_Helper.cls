/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 04-12-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   02-25-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class BL_ICON_Translation_Helper {
    public static Object getTranslationData(string language ,string application)  {
        String target = BL_WS_Router.clientPlatform;
        if(String.isBlank(target)){
            target = 'IOS';
        }

        List<Translation__c> trans =  new BL_EasyQuery()
            .objectName('Translation__c')
            .addFields(new  list<String>{'Value__c', 'Key__c' ,'Long_Value__c'})
            .condition('Language__c = \'' + language + '\' AND (Target__c = \''+ target +'\' OR Target__c = NULL)  AND Application__c = \'' + application+ '\'' )
            .executeQuery()
            .getSObjects();

        if(trans.isEmpty() && BL_AppSettings.customParams != null && BL_AppSettings.customParams.get('language') != null){
            trans = new BL_EasyQuery()
                .objectName('Translation__c')
                .addFields(new  list<String>{'Value__c','Key__c' ,'Long_Value__c'})
                .condition('Language__c = \''+ (String)BL_AppSettings.customParams.get('language') + '\' AND (Target__c = \''+ target +'\' OR Target__c = NULL)  AND Application__c = \''+application+ '\'' )                
                .executeQuery()
                .getSObjects();
        }

        Map<String, String> translationsMap = new Map<String, String>(); 
        
    
        for (Translation__c translation : (List<Translation__c>)trans){
            
            String value = String.isNotEmpty(translation.Long_Value__c) ? translation.Long_Value__c : translation.Value__c;

            translationsMap.put(translation.Key__c,value);
        }

        return translationsMap;
    }
}