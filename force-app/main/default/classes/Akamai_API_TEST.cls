@isTest
global class Akamai_API_TEST {
	
	@isTest static void test_all() {
		try{
			Test.startTest();
            // normal
            Akamai_API.getShortUrl('https://account.louisvuitton.com/eng-gb/mylv/registration?campaign=e_careServiceCreation_content&cid=WZuJWQyDOfPpu7WfcE0Zd09Fmd1SAyHyOO0fWWUjPBxeNOxv81NWJp8qiwGdAIJU&A=50135931', 'IDENTITY');
            // china
            Akamai_API.getShortUrl('https://account.louisvuitton.cn/eng-gb/mylv/registration?campaign=e_careServiceCreation_content&cid=WZuJWQyDOfPpu7WfcE0Zd09Fmd1SAyHyOO0fWWUjPBxeNOxv81NWJp8qiwGdAIJU&A=50135931', 'IDENTITY');
			Test.stopTest();
		}
		catch(Exception ex){}
	}
}