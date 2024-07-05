public without sharing class TWIST_QueryParametersFormatUtils {

    private Static Boolean doesMatchRegex(string param, string regex){
        return Pattern.compile(regex).matcher(param ?? '').matches();
    }
 
    public static Boolean isDispatchCountryFormatValid(string dispatchCountry){
        return doesMatchRegex(dispatchCountry, '^[A-Z]{2}$');
    }

    public static Boolean isLangCountryFormatValid(string langCountry){
        return doesMatchRegex(langCountry, '^([a-z]{3}-[a-z]{2})|eng-e1$');
    }
    
}