/**
    About
    -----
    Description: URL Rewriter for Identity Community
    Created for: Identity project
    Create date: Oct 2018

    Details
    -------
    Keep Louis Vuitton standard url format: lang-country/origin/pagekey
    When Exception is sent from SF, the login page is loaded => redirect to Louis Vuitton
*/
global class IDENTITY_URLRewriter implements Site.UrlRewriter {

	private static final String REGISTRATION_URL;
	private static final String ACTIVATION_URL;
	private static final String LOGIN_URL;
	private static final String SOCIAL_LOGIN_URL;
	private static final String REDIRECTION_URL;
	private static final String EXCEPTION_URL;
	private static final String GHOST_REDIRECTION_URL;

	private static final String LANG_COUNTRY_KEY;
	private static final String ORIGIN_KEY;
	private static final String RET_URL_KEY;
	private static final String SOCIAL_MEDIA_KEY;
	private static final String ACCOUNT_KEY;
	private static final String TRUST_ORIGIN;
	private static final String UPDATED_TO_DEFAULT_LANG_COUNTRY;
	private static final String ERROR_404;
	private static final String FRIENDLY_URL;
	

	class CustomException extends Exception {}

	static {
		REGISTRATION_URL = 'IDENTITY_Registration';
		ACTIVATION_URL = 'IDENTITY_Registration';
		LOGIN_URL = 'IDENTITY_Login';
		REDIRECTION_URL = 'IDENTITY_Redirection';
		EXCEPTION_URL = 'FileNotFound';
		SOCIAL_LOGIN_URL = 'IDENTITY_Redirection';
		GHOST_REDIRECTION_URL = 'IDENTITY_GhostRedirection';

		LANG_COUNTRY_KEY = 'lang-country';
		ORIGIN_KEY = 'origin';
		RET_URL_KEY = 'redirectURL';
		SOCIAL_MEDIA_KEY = 'social_media';
		ACCOUNT_KEY = 'accountId';
		TRUST_ORIGIN = 'isTrustOrigin';
		UPDATED_TO_DEFAULT_LANG_COUNTRY = 'defaultCountryLangLog';
		ERROR_404 = '404Log';
		FRIENDLY_URL = 'friendlyUrl';
	}

	/*
	 *** DESCRIPTION Redirect to Salesforce link according rules
	 *** RETURN      New PageReference 
	 */
	global PageReference mapRequestUrl(PageReference friendlyURL) {

		// GET SETTINGS
		IDENTITY_Registration_Form_Settings__c registration_settings = IDENTITY_Registration_Form_Settings__c.getInstance();
		IDENTITY_Settings__c identity_settings = IDENTITY_Settings__c.getInstance();

		// GET COUNTRY VALUES
		Set < String > language_country_values = new Set < String > (identity_settings.Language_Country_Values__c.split(' / '));
        Set < String > language_country_values_2 = new Set < String > (identity_settings.Language_Country_Values_2__c.split(' / '));
        if(!language_country_values_2.isEmpty()){
        	language_country_values.addAll(language_country_values_2);
        }

		// GET REGISTRATION PAGE KEY VALUES
		Set < String > registration_page_key_values = new Set < String > ();
        for(IDENTITY_Paths__mdt path : [SELECT Name__c, Value__c, Context__c, Application__c FROM IDENTITY_Paths__mdt WHERE Name__c = 'Registration Form Path']){
            registration_page_key_values.add(path.Value__c.split('/')[3]);
        }

		// GET LOGIN PAGE KEY VALUES
		Set < String > login_page_key_values = new Set < String > ();
        for(IDENTITY_Paths__mdt path : [SELECT Name__c, Value__c, Context__c, Application__c FROM IDENTITY_Paths__mdt WHERE Name__c = 'Login Form Path']){
            login_page_key_values.add(path.Value__c.split('/')[3]);
        }

		// GET SOCIAL LOGIN KEY VALUES
		Map < String, String > social_page_key_values = new Map < String, String > ();
		List < AuthProvider > providers = [SELECT Id, DeveloperName, FriendlyName FROM AuthProvider];
		for (AuthProvider provider: providers) {
			social_page_key_values.put(provider.DeveloperName.toLowerCase(), provider.DeveloperName);
		}
		
		// GET URL
		String url = friendlyURL.getUrl();
		System.debug('Friendly URL: ' + url);

		// REGISTRATION PATTERN: /lang-country/origin/pagekey?params
		// REGISTRATION PATTERN: /lang-country/origin/pagekey?params
		/* 
	 	** Update of the pattern on 09/13/22 to take into account the Google Anal parameters
	 	*/
		Pattern pattern_registration = Pattern.compile('/([a-zA-Z0-9]+-[a-zA-Z0-9]+)/([a-zA-Z]+)/(([a-zA-Z0-9]+)*)([#a-zA-Z0-9=+_?.%&*-]+)*');
		Matcher matcher_registration = pattern_registration.matcher(url);

		if (matcher_registration.matches()) {

			System.debug('LOUIS VUITTON PATTERN MATCHES');

			PageReference new_url;

			String lang_country = matcher_registration.group(1).toLowerCase();
			String origin = matcher_registration.group(2);
			String pagekey = matcher_registration.group(3).toLowerCase();

			Boolean to404Log;
			String toDefaultParamLog;

			// DEFAULT LANG-COUNTRY
			if (!language_country_values.contains(lang_country)) {
				toDefaultParamLog = lang_country;
				lang_country = identity_settings.Default_Language_Country_Parameter__c;
			}

			// EMPTY PAGE KEY
			if (String.isEmpty(pagekey)) {
				System.debug('EMPTY PAGE KEY');
				new_url = new PageReference(EXCEPTION_URL);
				to404Log = true;
			}
			// REGISTRATION KEY
			else if (registration_page_key_values.contains(pagekey)) {
				System.debug('REGISTRATION KEY');
				if(isContextGhostRedirection(friendlyURL.getParameters())){
					new_url = new PageReference(GHOST_REDIRECTION_URL);
				}
				else{
					String mode = 'REGISTRATION';

					// MYREPAIRS / OSA / EXCLUSIVE EXPERIENCE / CHECKOUT activation flows
					List<String> accountIdWithTrustOrigin = new List<String>();
					String accountId;
					String isTrustOrigin;
					String encrypted_accountId = friendlyURL.getParameters().get('cid');
					if (!String.isEmpty(encrypted_accountId)) {
						try {
							List < Account > accounts;
	
							Map<String,Object> cidMap = EncryptUtils.getDecryptedMetadata(encrypted_accountId);
							if(cidMap != null){
								accountId = cidMap.containsKey('accountId') ? cidMap.get('accountId').toString() : null ;
								if(cidMap.containsKey('isTrustOrigin')){
									System.debug('PARAM CONTAINS TRUST ORIGIN');
									isTrustOrigin = cidMap.get('isTrustOrigin').toString();
								}
								else{
									System.debug('NO TRUST ORIGIN IN PARAM');
									isTrustOrigin = 'false';
								}
							}
							else {
								Blob key = EncodingUtil.base64Decode(IDENTITY_Settings__c.getOrgDefaults().AES_Key__c);
								accountId = Crypto.decryptWithManagedIV('AES128', key, EncodingUtil.base64Decode(encrypted_accountId)).toString();
								System.debug('ACCOUNT ID BEFORE SPLIT: '+accountId);
								if(accountId.contains('|')){
									System.debug('PARAM CONTAINS TRUST ORIGIN');
									accountIdWithTrustOrigin = accountId.split('\\|'); // escape special character pipe
									accountId = accountIdWithTrustOrigin[0];
									isTrustOrigin = accountIdWithTrustOrigin[1];
								}
								else{
									System.debug('NO TRUST ORIGIN IN PARAM');
									isTrustOrigin = 'false';
								}
							}
							System.debug('ACCOUNT ID: '+accountId);
							System.debug('TRUST ORIGIN: '+isTrustOrigin);
	
							accounts = [SELECT Id, PersonEmail, LoginPhone__pc FROM Account WHERE Id =: accountId];
							System.debug('ACTIVATION MATCH BY SF ID');
							
							if (!accounts.isEmpty()) {
								accountId = accounts[0].Id;
								List < User > users = IDENTITY_Utils.getUsers(accounts[0]);
								if (!users.isEmpty()) {
									mode = 'LOGIN';
									accountId = users[0].AccountId;
								} else {
									mode = 'ACTIVATION';
								}
							}
						} catch (Exception ex) {
							System.debug(ex.getMessage());
						}
					}
	
					if (mode == 'ACTIVATION') {
						new_url = new PageReference(ACTIVATION_URL);
						new_url.getParameters().put(ACCOUNT_KEY, accountId);
						new_url.getParameters().put(TRUST_ORIGIN, isTrustOrigin);
					} else if (mode == 'LOGIN') {
						new_url = new PageReference(LOGIN_URL);
						new_url.getParameters().put(ACCOUNT_KEY, accountId);
					} else {
						new_url = new PageReference(REGISTRATION_URL);
					}
				}	
			}
			// SOCIAL LOGIN KEY
			else if (social_page_key_values.keySet().contains(pagekey)) {
				System.debug('SOCIAL LOGIN KEY');
				
				new_url = new PageReference(SOCIAL_LOGIN_URL);
				new_url.getParameters().put(SOCIAL_MEDIA_KEY, social_page_key_values.get(pagekey));
			}
			// LOGIN KEY
			else if (login_page_key_values.contains(pagekey)) {
				System.debug(' LOGIN KEY');
				
				new_url = new PageReference(LOGIN_URL);
			}
			// ERROR IF NO PAGEKEY
			else {
				System.debug('ERROR PAGE KEY');
				new_url = new PageReference(EXCEPTION_URL);
				to404Log = true;
			}

			// ADD CONTEXT PARAMS
			new_url.getParameters().put(LANG_COUNTRY_KEY, lang_country);
			new_url.getParameters().put(ORIGIN_KEY, origin);

			// ADD FLAGS (NEED TO CREATE A LOG IN VF PAGE)
			new_url.getParameters().put(UPDATED_TO_DEFAULT_LANG_COUNTRY, toDefaultParamLog);
			new_url.getParameters().put(ERROR_404, String.valueOf(to404Log));
			new_url.getParameters().put(FRIENDLY_URL, friendlyURL.getUrl());

			// ADD CURRENT PARAMETERS
			for (String key: friendlyURL.getParameters().keyset()) {
				new_url.getParameters().put(key, friendlyURL.getParameters().get(key));
			}

			System.debug('NEW URL: ' + new_url.geturl());
			System.debug('PARAMS');
			for(String key : new_url.getParameters().keySet()){
				System.debug(key + ' ' + new_url.getParameters().get(key));
			}

			return new_url;
		}

		return friendlyURL;
	}

	global List < PageReference > generateUrlFor(List < PageReference > yourSalesforceUrls) {
		return null;
	}
	public static Boolean isContextGhostRedirection(Map<String,String> params){
		return (params.containsKey('utm_campaign') || params.containsKey('campaign')) && !params.containsKey('isTwist');
	}
}