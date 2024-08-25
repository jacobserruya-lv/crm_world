public with sharing class TWIST_RecaptchaUtils {
    
    public static String getRecaptchaKeyId() {
        Map<String,String> settings = getRecaptchaSettings();
        return settings.get('keyId');
    }
    
    /**
    * @description determines if user is human, based on a score between 0 and 1 returned by the Google reCaptcha verify API
    *
    * @param {String} token: token issued by the reCaptcha V3 widget on the front-end side
    * @return stringified JSON object with keys 'success' (boolean, mandatory) and 'error' (string, optional)
    */
    public static Map<String,Object> verifyRecaptchaToken(String token, String language, String logDetails) {
        Boolean useGoogleRecaptcha = Boolean.valueOf(TWIST_AppSettings_UTIL.getSetting('IsRecaptchaActivated'));
        if(!useGoogleRecaptcha) {
            if(!Test.isRunningTest()){
                return TWIST_Utils.buildSuccessResponseObject();
            }
        }
        Map<String,Object> result = new Map<String,Object> { 'success' => null };
        try {
            if (String.isBlank(token)) {
                result.put('success', false);
                result.put('error', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Message_MissingParameter', language) + ' "token"');
            }
            else {
                Map<String,String> settings = getRecaptchaSettings();
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(settings.get('endpoint'));
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setBody(
                String.format(
                'secret={0}&response={1}',
                new List<String> {
                    settings.get('secretKey'),
                    token
                }));
                HttpResponse res = http.send(req);
                Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                if (Boolean.valueOf(responseBody.get('success')) == false) {
                    result.put('success', false);
                    result.put('error', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Message_RuntimeError', language));
                }
                else {
                    Double treshhold = Double.valueOf(settings.get('treshhold'));
                    Double score = Double.valueOf(responseBody.get('score'));
                    // result.put('score', score); // Uncomment for debug purposes
                    System.debug('Recaptcha Score => : ' + score);
                    if (score >= treshhold) {
                        result.put('success', true);
                    }
                    else {
                        result.put('success', false);
                        result.put('error', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Message_RecaptchaScoreTooLow', language));
                        new Logs(new Map<String,Object> {
                            'level' => 'ERROR',
                            'apexClass' => 'TWIST_RecaptchaUtils',
                            'category' => 'API',
                            'message' => 'User is probably a bot!',
                            'details' => String.format(
                            '{0}; Google score: {1}; reCAPTCHA treshhold: {2}',
                            new List<String> {
                                logDetails,
                                String.valueOf(responseBody.get('score')),
                                String.valueOf(treshhold)
                            })
                        });
                    }
                }
            }
        }
        catch (Exception e) {
            result.put('success', false);
            result.put('error', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Message_RuntimeError', language));
        }
        return result;
    }
    
    private static Map<String,String> getRecaptchaSettings() {
        return !Test.isRunningTest() ? ThirdParty_Utils.getSettings('Twist_reCaptcha') : new Map<String,String> {
            'endpoint' => 'https://dummy-api.net',
            'keyId' => 'dummy-key-id',
            'secretKey' => 'dummy-secret-key',
            'treshhold' => '0.7'
        };
    }
    
}