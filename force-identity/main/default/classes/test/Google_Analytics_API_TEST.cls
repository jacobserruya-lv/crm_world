@isTest
global class Google_Analytics_API_TEST {
	
	@isTest static void test_all() {
		try{
			Test.startTest();
				Google_Analytics_API.sendUserTrackingEvent(new Map<String,String>{
                    'origin'                => 'mylv',
                    'eventCategory'         => 'mylv',
                    'eventAction'           => 'i_already_have_an_account',
                    'eventLabel'            => 'sign_in_succeeded',
                    'currentUrl'            => EncodingUtil.urlEncode('/fra-fr/mylv/registration', 'UTF-8'),
                    'connexionStatus '      => 'logged_user',
                    'environmentVersion'    => 'fr',
                    'environmentLanguage'   => 'fra-fr',
                    'pageName'              => 'mylv/identification',
                    'pageType'              => 'connexion_module'    
                });

                Google_Analytics_API.sendUserTrackingEvent(new Map<String,String>{
                    'origin'                => 'mylv',
                    'eventCategory'         => 'mylv',
                    'eventAction'           => 'create_an_account_form_sf',
                    'eventLabel'            => 'sign_in_succeeded',
                    'currentUrl'            => EncodingUtil.urlEncode('/fra-fr/mylv/registration', 'UTF-8'),
                    'connexionStatus '      => 'logged_user',
                    'environmentVersion'    => 'fr',
                    'environmentLanguage'   => 'fra-fr',
                    'pageName'              => 'mylv/account_creation',
                    'pageType'              => 'account_creation'    
                });
			Test.stopTest();
		}
		catch(Exception ex){}
	}
}