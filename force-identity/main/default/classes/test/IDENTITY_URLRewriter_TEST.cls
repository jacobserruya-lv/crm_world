@isTest
private class IDENTITY_URLRewriter_TEST {
	
	@isTest static void test_mapRequestUrl() {
		Identity_TestFactory.createSettings();

		Test.StartTest();

			IDENTITY_URLRewriter rewriter = new IDENTITY_URLRewriter();

			// REGISTRATION
			rewriter.mapRequestUrl(new PageReference('/eng-us/mylv/registration'));

			//REPAIRS
			//IDENTITY_Settings__c setting = IDENTITY_Settings__c.getOrgDefaults();
			//Blob cryptoKey = EncodingUtil.base64Decode(setting.AES_Key__c);
			//Blob data = Blob.valueOf('001n000000VGH98');
			//System.debug(EncodingUtil.urlEncode (encryptedDataStr, 'UTF-8'));
			rewriter.mapRequestUrl(new PageReference('/eng-us/mylv/registration?A=11223344'));
			rewriter.mapRequestUrl(new PageReference('/eng-us/mylv/registration?cid=001n000000VGH98'));
            //encrypted
            Account myAccount= IDENTITY_TestFactory.createAccount('test', 'test2','email@gmail.com','0598987676', '+972',false);
            myAccount.LoginPhone__pc = '+972598987676';
            insert myAccount;
            string encrytedid = IDENTITY_Utils.getEncryptedId(myAccount.Id);
			rewriter.mapRequestUrl(new PageReference('/eng-us/mylv/registration?cid='+encrytedid)); 
            string encrytedid2 = IDENTITY_Utils.getEncryptedId(myAccount.id+'|true');
			rewriter.mapRequestUrl(new PageReference('/eng-us/mylv/registration?cid='+encrytedid2)); 
			string encrytedid3 = EncodingUtil.urlEncode(EncryptUtils.getEncryptedMetadata(new Map<String,Object>{'accountId' => myAccount.id, 'isTrustOrigin' => 'true'}), 'UTF-8');
			rewriter.mapRequestUrl(new PageReference('/eng-us/mylv/registration?cid='+encrytedid3));
			
			// SOCIAL REGISTRATION
			rewriter.mapRequestUrl(new PageReference('/eng-us/mylv/line'));

			// LOGIN
			rewriter.mapRequestUrl(new PageReference('/eng-us/mylv/login'));

			// ERROR
			rewriter.mapRequestUrl(new PageReference('/eng-us/mylv/test'));
        
            // pagekey empty
        	rewriter.mapRequestUrl(new PageReference('/eng-us/mylv/'));


			// NO MATCH AT ALL
			rewriter.mapRequestUrl(new PageReference('/testnomatch'));

			// PARAMETERS
			PageReference page = new PageReference('/fra-gh/mylv/registration');
			page.getParameters().put('dev','true');
			page.getParameters().put('step','1');
			rewriter.mapRequestUrl(page);

		Test.StopTest();
	}

	@isTest static void test_generateUrlFor() {
		Identity_TestFactory.createSettings();

		Test.StartTest();

			IDENTITY_URLRewriter rewriter = new IDENTITY_URLRewriter();
			rewriter.generateUrlFor(new List<PageReference>());

		Test.StopTest();
	}
	    
    @isTest
    static void testIsContextGhostRedirectionn() {
        // Test when utm_campaign is present and isTwist is not present
        Map<String, String> params1 = new Map<String, String>{'utm_campaign' => 'campaign123'};
        System.assert(IDENTITY_URLRewriter.isContextGhostRedirection(params1));

        // Test when campaign is present and isTwist is not present
        Map<String, String> params2 = new Map<String, String>{'campaign' => 'campaign456'};
        System.assert(IDENTITY_URLRewriter.isContextGhostRedirection(params2));

        // Test when isTwist is present
        Map<String, String> params3 = new Map<String, String>{'isTwist' => 'true'};
        System.assert(!IDENTITY_URLRewriter.isContextGhostRedirection(params3));

        // Test when neither utm_campaign nor campaign is present
        Map<String, String> params4 = new Map<String, String>{};
        System.assert(!IDENTITY_URLRewriter.isContextGhostRedirection(params4));
    }
    
}