public without sharing class TWIST_i18nCustomLabels {
    
    /**
    * Translates a list of Custom Labels
    * @param {List<String>} labels: custom label names separated by commas, then base64-encoded
    * @param {String} language
    */
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> translateLabelsList(List<String> labels, String language) {
        try {
            if (!labels.isEmpty() && language != null) {
                PageReference pageRef = Page.TWIST_i18nCustomLabels;
                pageRef.getParameters().put('language', language);
                  if(Test.isRunningTest()) {
                    return translateLabelsResultWhenTestIsRunning(labels);
                }
                pageRef.getParameters().put('customLabels', String.join(labels, ','));
                String jsonString = '{' + pageRef.getContent().toString().trim().removeEnd(',') + '}';
                System.debug('> translateLabels() result: ' + jsonString);
                return (Map<String,Object>) JSON.deserializeUntyped(jsonString);
            }
        }
        catch (VisualforceException e) {
            System.debug('> ' + e.getMessage());
        }
        catch (Exception e) {
            System.debug('> Error in method TWIST_i18nCustomLabel.translateLabelsList(): ' + e.getMessage());
        }
        return new Map<String,Object>();
    }

    /**
    * Translates a single Custom Label
    * @param {String} label
    * @param {String} language
    */
    @AuraEnabled(cacheable=true)
    public static String translateSingleLabel(String label, String language) {
        Map<String,Object> translation = translateLabelsList(new List<String> {label}, language);
        return (String) translation.get(label);
    }

    private static Map<String,Object> translateLabelsResultWhenTestIsRunning(List<String> customLabels) {
        Map<String,Object> result = new Map<String,Object>();
        for (String customLabel: customLabels) {
            result.put(customLabel, 'CUSTOM_LABEL'); // ugly hack because the Page.getContent() method isn't supported by Apex unit tests
        }
        return result;
    }

}