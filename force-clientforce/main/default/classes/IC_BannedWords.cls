/**
*  About
*  -----
*  Author: Salesforce
*  Created for: ICON Project
*  Create date: Aug 2013
*  
*  Details
*  -----
*  Class used by trigger to reject the record if some fields contain a banned words 
*  
*  Update History
*  -----
*  05/05/17 / RMOU : Added language handling
*
*  Issues / TODOs
*  -----
**/

public class IC_BannedWords{
    
    public static List<String> checkWords(List<sObject> objList, String sObj){
        Set<String> result = new Set<String>();
        String language = languageMap.get(UserInfo.getLanguage());
        System.debug (language);
        List<Banned_Words__c> banned = [select Word__c from Banned_Words__c WHERE Language__c = :language];
        Map<String, Schema.SObjectField> fieldsMap = IC_UTILS.getTextFieldMap(sObj);
        Map<String, IconBannedWordsFieldList__c> bannedWordsFieldList = IconBannedWordsFieldList__c.getall();
        if (banned.size() > 0){
            String regex = '';
            for (Integer i = 0; i < banned.size() - 1; i++){
                regex = regex + '\\b' + banned[i].Word__c.trim() + '\\b|';
            }
            regex = regex + '\\b' + banned[banned.size() - 1].Word__c.toLowerCase() + '\\b';
            regex = regex.toLowerCase();
            System.debug(regex);
            Pattern p = Pattern.compile(regex);
            Matcher pm;
            for(sObject obj : objList){
                if(!customBypassBannedWord(obj, sObj)){
                    for (String field : fieldsMap.keySet()){
                        if (field == 'attendees') continue;
                        String fieldValue = String.valueOf(obj.get(field));
                        if (String.isNotBlank(fieldValue) && (bannedWordsFieldList.get(sObj+'.'+field)!=null || bannedWordsFieldList.get(sObj+'.*')!=null)){
                            fieldValue = fieldValue.toLowerCase();
                            System.debug('======> field value : ' +fieldValue);
                            pm = p.matcher(fieldValue);
                            if (pm.find()){
                                System.debug('======> ERROR : ' +fieldValue);
                                result.add(pm.group());
                            }
                        }
                    }
                }
            }
        }
        List<String> bannedWords = new List<String>();
        bannedWords.addAll(result);
        System.debug('**** Banned Words:' + bannedWords);
        return bannedWords;
    }
    
    
    
    public static Boolean customBypassBannedWord(sObject obj, String sObjType){
        if (sObjType == 'Event' || sObjType == 'Task') {
                    return (Boolean)obj.get('TECH_is_AutoSave__c');
        }
        return false;
    }
    
    
    public static Map<String, String> languageMap = new Map<String, String> {
        'zh_CN'  => 'Chinese (Simplified)',
        'zh_TW'  => 'Chinese (Traditional)',
        'da'     => 'Danish',
        'nl_NL'  => 'Dutch',
        'en_US'  => 'English',
        'fi'     => 'Finnish',
        'fr'     => 'French',
        'de'     => 'German',
        'it'     => 'Italian',
        'ja'     => 'Japanese',
        'ko'     => 'Korean',
        'pt_BR'  => 'Portuguese (Brazil)',
        'ru'     => 'Russian',
        'es'     => 'Spanish',
        'sv'     => 'Swedish',
        'th'     => 'Thai',
        'ar'     => 'Arabic',
        'bg'     => 'Bulgarian',
        'cs'     => 'Czech',
        'en_GB'  => 'English (UK)',
        'el'     => 'Greek',
        'es_MX'  => 'Spanish (Mexico)',
        'iw'     => 'Hebrew',
        'hu'     => 'Hungarian',
        'in'     => 'Indonesian',
        'no'     => 'Norwegian',
        'pl'     => 'Polish',
        'ro'     => 'Romanian',
        'tr'     => 'Turkish',
        'uk'     => 'Ukrainian',
        'vi'     => 'Vietnamese',
        'sq'     => 'Albanian',
        'hy'     => 'Armenian',
        'eu'     => 'Basque',
        'bs'     => 'Bosnian',
        'hr'     => 'Croatian',
        'en_AU'  => 'English (Australia)',
        'en_CA'  => 'English (Canada)',
        'en_IN'  => 'English (India)',
        'en_MY'  => 'English (Malaysia)',
        'en_PH'  => 'English (Philippines)',
        'et'     => 'Estonian',
        'fr_CA'  => 'French (Canada)',
        'ka'     => 'Georgian',
        'hi'     => 'Hindi',
        'is'     => 'Icelandic',
        'ga'     => 'Irish',
        'lv'     => 'Latvian',
        'lt'     => 'Lithuanian',
        'lb'     => 'Luxembourgish',
        'mk'     => 'Macedonian',
        'ms'     => 'Malay',
        'mt'     => 'Maltese',
        'ro_MD'  => 'Moldovan',
        'sh_ME'  => 'Montenegrin',
        'pt_PT'  => 'Portuguese (European)',
        'rm'     => 'Romansh',
        'sr'     => 'Serbian (Cyrillic)',
        'sh'     => 'Serbian (Latin)',
        'sk'     => 'Slovak',
        'sl'     => 'Slovenian',
        'tl'     => 'Tagalog',
        'ur'     => 'Urdu',
        'cy'     => 'Welsh'
    };
}