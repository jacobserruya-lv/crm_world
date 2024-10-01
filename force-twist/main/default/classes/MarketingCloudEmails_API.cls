public with sharing class MarketingCloudEmails_API { //TWIST-4340

    //Debug the error
    public static void logResponse(HTTP_Utils request, String level) {
        new Logs( new Map<String,Object> {
                'level' => level, 
                'apexClass' => 'MarketingCloudEmails_API', 
                'category' => 'CALLOUT',
                'http' => request
            });
    }

    /**
     * @return today's date in MM-DD-YYYY format
     */
    private static String getTriggeredDate() {
        DateTime today = Datetime.NOW();
        return today.month() + '-' + today.day() + '-' + today.year();
    }

    //concate the data received to "body"
    public static String getBody(String url, String email, String definitionKey, String lastName, String firstName, String civility, String countryCode, String language, String mobilePhoneInternational, String preferredLanguage) {
        String attributesFormat = '"Lastname":"{0}","FirstName":"{1}","Civility":"{2}","TriggeredDate":"{3}","MessageType":"Reset Password","CountryCode":"{4}","Language":"{5}","Channel":"Email","HasMyLVAccount":"True","EmailAddress":"{6}","Email":"{6}","MobilePhoneInternational":"{7}","PreferredLanguage":"{8}","URL":"{9}"';
        return '{' +
            '"definitionKey": "' + definitionKey + '",' +
            '"recipients": [' +
                '{  "contactKey": "' + email + '",' +
                    '"to": "' + email + '",' +
                    '"attributes": {' +
                    String.format(attributesFormat, new String[]{lastName, firstName, civility, getTriggeredDate(), countryCode, language, email, mobilePhoneInternational, preferredLanguage, url}) +
                    '}}]}';
    }

    //Main function - send the email
    public static Map<String,Object> sendEmailMC(String langCountry, String dispatchCountry, String origin, String token, String email, String lastName, String firstName, String civility, String countryCode, String mobilePhoneInternational) {
        Map<String,String> settings = TWIST_Utils.getResetPasswordEmailSettings();
        String url = TWIST_Utils.getResetPasswordUrl(langCountry, dispatchCountry, origin, token);
        List <String> splitLangCountry = langCountry.split('-');
        String preferredLanguage = splitLangCountry[0].substring(0,2).toUpperCase();
       
       if (!String.isEmpty(dispatchCountry)){
            countryCode = dispatchCountry.toUppercase();
        }
        String body = getBody(
            url,
            email,
            settings.get('definitionKey'),
            lastName,
            firstName,
            civility,
            countryCode.toUpperCase(),
            langCountry,
            mobilePhoneInternational,
        	preferredLanguage);
        
        HTTP_Utils request = new HTTP_Utils()
            .post(settings.get('endpoint'))
            .header('Content-Type', 'application/json')
            .header('client_id', settings.get('client_id'))
            .header('client_secret', settings.get('client_secret'))
            .body(body)
            .call();

        Map<String,Object> response = request.getParameters();
        if(request.statusCode() == 202) {
            logResponse( request, 'INFO');
            return TWIST_Utils.buildSuccessResponseObject('message', 'status: ' + request.status() + ', statusCode: ' + request.statusCode() + ', responseId: ' + response.get('responseId'));
        }
        logResponse( request, 'ERROR');
        return TWIST_Utils.buildFailureResponseObject('form', 'errorCode: ' + response.get('errorCode') + ', errorDescription: ' + response.get('errorDescription') + ', responseId: ' + response.get('responseId') + ', status: ' + response.get('status') );
    }

}