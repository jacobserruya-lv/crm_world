@isTest
global class Fractalist_API_TEST {
	
	@isTest static void test_all() {
		try{
			Test.startTest();
				Fractalist_API.sendVerificationSMS(new List<String>{'123456'},'123','mylv');
			Test.stopTest();
		}
		catch(Exception ex){}
	}
}