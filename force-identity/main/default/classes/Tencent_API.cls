public with sharing class Tencent_API {
	/*
    *** DESCRIPTION Verify captcha
    *** RETURN     
    */
	public static String verifyCaptcha(String ticket, String randstr){
		try{

			String timestamp = String.valueOf(DateTime.now().getTime()/1000);
			String nonce = String.valueOf(Math.round(Math.random() * 100000));

			Map<String,String> args = new Map<string,String>{
				'Action' => 'DescribeCaptchaResult',
                'AppSecretKey' => SETTINGS.get(APPSECRET),
                'CaptchaAppId' => SETTINGS.get(APPID),
                'CaptchaType' => '9',
				'Nonce' => nonce,
                'Randstr' => randstr,
				'SecretId' => SETTINGS.get(SECRETID),
                'Ticket' => ticket,
				'Timestamp' => timestamp,
				'UserIp' => '127.0.0.1',
				'Version' => '2019-07-22'
			};

			// ADD SIGNATURE
			Map<String,String> sorted_args = sortMap(args);
			String body_to_signature = String.format('{0}{1}?{2}', new List<String>{ 'GET', SETTINGS.get(ENDPOINT).remove('https://'), joinMap(sorted_args, null) });
			Blob hash = Crypto.generateMac('HmacSHA1', Blob.valueOf(body_to_signature), Blob.valueOf(SETTINGS.get(SIGNATURE)));
			String signature_encoded = EncodingUtil.base64Encode(hash);
			args.put('Signature', signature_encoded);
            //System.debug('signature_encoded: ' + signature_encoded);
			//System.debug('trequest:'+SETTINGS.get(ENDPOINT) + '?' + joinMap(args, 'UTF-8'));
			HTTP_Utils response = new HTTP_Utils()
	            .get(SETTINGS.get(ENDPOINT) + '?' + joinMap(args, 'UTF-8'))
	            .call();
           
	        System.debug('RESPONSE: ' + response.responseBody());

	        if(response.statusCode() == 200){
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody());
                Map<String, Object> result = (Map<String, Object>) body.get('Response');
	         	System.debug('RESPONSE: ' + body);
	         	if(result.get('CaptchaMsg') != null && result.get('CaptchaMsg') == 'OK'){
                    return 'OK';
	         	}
	        }
		}
		catch(Exception ex){
			System.debug('REQUEST ERROR: '+ ex );
		}

		return null;
	}


	private static Map<String,String> sortMap(Map<String,String> args) {
		Map<String,String> sorted_args = new Map<string,String>();
		List<String> keys = new List<String> (args.keySet());
		keys.sort();

		for(String key : keys){
			sorted_args.put(key, args.get(key));
		}

		return sorted_args;
	}

	private static String joinMap(Map<String,String> args, String format) {
		String str = '';

		for(String key : args.keySet()){
			str += (key + '=' + (format != null ? EncodingUtil.urlEncode(args.get(key), format) : args.get(key)) + '&');
		}

		str = str.removeEnd('&');

		return str;
	}

	public static Map<String,String> SETTINGS;
	public final static String ENDPOINT;
    public final static String SECRETID;
    public final static String SIGNATURE;
	public final static String SCRIPTJS;
	public final static String APPID;
	public final static String APPSECRET;

	static {
		SETTINGS = ThirdParty_Utils.getSettings('Tencent');
        
        ENDPOINT = 'endpoint';
        SECRETID = 'username';
        SIGNATURE = 'password';
		SCRIPTJS = 'scriptJS';
		APPID = 'CaptchaAppId';
		APPSECRET = 'AppSecretKey';
	}
}