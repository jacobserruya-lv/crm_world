public without sharing class TWIST_i18nTranslations {

    @testVisible private static Boolean forceThrowException = false;

    /**
    * @param {List<String>} labels: custom label names separated by commas, then base64-encoded
    * @param {String} language
    */
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> translateLabelsList(List<String> labels, String language) {
        Map<String,Object> result = new Map<String,Object>();
        try {
            if (!labels.isEmpty() && language != null) {
                if(Test.isRunningTest()) {// JSSI remove + declare mock in test class
                    if (forceThrowException) {
                        throw new CustomException();
                    }
                    return translateLabelsResultWhenTestIsRunning(labels);
                }
                result = vfpContentToMap('TWIST_i18nCustomLabels', new Map<String,Object> {
                        'customLabels' => String.join(labels, ','),
                        'language' => language
                    }
                );
            }
        }
        catch (Exception e) {
            System.debug('> Error in method TWIST_i18nTranslations.translateLabelsList()');
            System.debug('> labels: ' + JSON.serialize(labels));
            System.debug('> language: ' + language);
            System.debug('> Error message: ' + e.getMessage());
            result = translateLabelsListKnowingThatSomeDontExist(labels, language);
        }
        return result;
    }
    
    /**
    * @param {String} label
    * @param {String} language
    */
    @AuraEnabled(cacheable=true)
    public static String translateSingleLabel(String label, String language) {
        Map<String,Object> translation = translateLabelsList(new List<String> {label}, language);
        return (String) translation.get(label);
    }

    /**
    * @param {String} picklistObject
    * @param {String} language
    */
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> translatePicklist(String picklist, String language) {
        try {
            if (picklist != null && language != null) {
                if(Test.isRunningTest()) {// JSSI remove + declare mock in test class
                    if (forceThrowException) {
                        throw new CustomException();
                    }
                    return translatePicklistResultWhenTestIsRunning();
                }
                return vfpContentToMap('TWIST_i18nPicklist', new Map<String,Object> {
                        'picklist' => picklist,
                        'language' => language
                    }
                );
            }
        }
        catch (Exception e) {
            System.debug('> Error in method TWIST_i18nTranslations.translatePicklist(): ' + e.getMessage());
        }
        return new Map<String,Object>();
    }

    /** ********************************************************************************************************************************* **/

    private static Map<String,Object> translateLabelsResultWhenTestIsRunning(List<String> customLabels) {
        Map<String,Object> result = new Map<String,Object>();
        for (String customLabel: customLabels) {
            result.put(customLabel, 'CUSTOM_LABEL'); // ugly hack because the Page.getContent() method isn't supported by Apex unit tests
        }
        return result;
    }

    private static Map<String,Object> translatePicklistResultWhenTestIsRunning() {
        Map<String,Object> result = new Map<String,Object>();
        result.put('FRANCE', 'FRANCE'); // ugly hack because the Page.getContent() method isn't supported by Apex unit tests
        result.put('USA', 'USA');
        result.put('NETHERLANDS', 'NETHERLANDS');
        result.put('SAUDI ARABIA', 'SAUDI ARABIA');
        result.put('UNITED ARAB EMIRATES', 'UNITED ARAB EMIRATES');
        return result;
    }

    @TestVisible
    private static Map<String,Object> vfpContentToMap(String visualforcePageName, Map<String,Object> visualforcePageParams) {
        String calloutUrl = TWIST_UrlUtils.buildVisualforcePageUrl(visualforcePageName, visualforcePageParams);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(calloutUrl);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        
        HttpResponse response = http.send(req);
        String jsonString = response.getBody().removeEnd(',');
        return (Map<String,Object>) JSON.deserializeUntyped('{' + jsonString + '}');
    }

    @testVisible
    private static Map<String,Object> translateLabelsListKnowingThatSomeDontExist(List<String> labels, String language) {
        List<String> foundLabels = new List<String>();
        Map<String,Object> result = new Map<String,Object>();
        for (String labelName : labels) {
            try {
                if (forceThrowException) {
                    throw new CustomException();
                }
                Label.get('', labelName); // will throw an exception if this label does not exist
                foundLabels.add(labelName);
            }
            catch (Exception e) {
                result.put(labelName, 'N/A');
            }
        }

        if(Test.isRunningTest()) {
            return translateLabelsResultWhenTestIsRunning(labels);
        }
        result.putAll(
            vfpContentToMap(
                'TWIST_i18nCustomLabels',
                new Map<String,Object> {
                    'customLabels' => String.join(foundLabels, ','),
                    'language' => language
                }
            )
        );
        return result;
    }

    private class CustomException extends Exception {}

}
