public with sharing class Fractalist_API {

    private static Integer timeoutMilliseconds = 25000;

	/*
    *** DESCRIPTION Send Verification Code SMS
    *** RETURN     
    */
	public static void sendVerificationSMS(List<String> phones, String code, String origin){

		String content = Label.IDENTITY_Registration_Verification_SMS_MEssage;
		content = content.replace('XXX', code);

		sendSMS(phones, content, origin);
	}

	/*
    *** DESCRIPTION Send SMS with API
    *** RETURN     
    */
	public static void sendSMS(List<String> phones, String content, String origin){
		try{

			List<String> correct_phones = new List<String>();
			for(String phone : phones){
				correct_phones.add(phone.remove('+86').remove('+').removeStart('86'));
			}

			String payLoad = 'Username=' + SETTINGS.get(USERNAME) 
				+ '&Password='  + SETTINGS.get(PASSWORD) 
				+ '&ProductId=' + SETTINGS.get(PRODUCT)
				+ '&Phones=' + joinList(correct_phones)
				+ '&Content=' + EncodingUtil.urlEncode(content, 'UTF-8');

			HTTP_Utils response = new HTTP_Utils()
	            .post(SETTINGS.get(ENDPOINT))
	            .body(payLoad)
                .timeout(timeoutMilliseconds)
	            .call();

	        if(response.statusCode() == 200 && !ERROR_CODES.contains(response.responseBody().substringBefore('|'))){
	            System.debug('SUCCESS: ' + response.responseBody());
	            System.debug('PAYLOAD: ' + payLoad);
	        }
	        else {
            	new Logs(new Map<String,Object> {
                    'level' => 'ERROR', 
                    'apexClass' => 'Fractalist_API', 
                    'category' => 'CALLOUT',
                    'endpoint' => SETTINGS.get(ENDPOINT),
                    'request' => payLoad,
                    'response' => response.responseBody(),
                    'application' => origin
                });
	        	throw new CustomException('Fractalist_API failed to send SMS');
	        }
	    }
		catch(Exception ex){
			if(!ex.getTypeName().contains('CustomException')){
                new Logs(new Map<String,Object> {
                    'level' => 'ERROR',
                    'apexClass' => 'Fractalist_API',
                    'category' => 'CALLOUT',
                    'exception_case' => ex,
                    'message' => ex.getTypeName().contains('CalloutException') ? 'SF callout timeout: ' + timeoutMilliseconds + 'ms' : '',
                    'application' => origin
                });
            }
			
			throw new CustomException('Fractalist_API failed to send SMS');
		}
	}

	/*
    *** DESCRIPTION Join list element by coma
    *** RETURN     
    */
	public static String joinList(List<String> lst){
        String result = '';
        for(String str : lst){
            result += str + ',';
        }
        result = result.removeEnd(',');
        return result;
    }

    public class CustomException extends Exception {}

	public static Map<String,String> SETTINGS;
	public final static String ENDPOINT;
    public final static String USERNAME;
    public final static String PASSWORD;
    public final static String PRODUCT;
    public final static Set<String> ERROR_CODES;

	static {
		SETTINGS = ThirdParty_Utils.getSettings('Fractalist');

        ENDPOINT = 'endpoint';
        USERNAME = 'username';
        PASSWORD = 'password';
        PRODUCT = 'productId';

        ERROR_CODES = new Set<String>();
        if(SETTINGS.get('error_codes') != null){
        	ERROR_CODES.addAll(SETTINGS.get('error_codes').split(','));
        }
	}
}