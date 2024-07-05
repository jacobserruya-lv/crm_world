public without sharing class CountryLanguageManager {

    public static String getMulesoftApisPrefix(String langCountry) {
        List<CountryLanguage__c> items = [SELECT Mulesoft_Local__c FROM CountryLanguage__c WHERE ATG_Locale__c = :langCountry AND Mulesoft_Local__c != null LIMIT 1];
        if (items.size() == 0) {
            String message = String.format('LangCountry "{0}" is unknown', new List<String> { langCountry });
            throw new CountryLanguageManagerException(message);
        }

        return items.get(0).Mulesoft_Local__c;
    }

    private class CountryLanguageManagerException extends Exception {}
    
}