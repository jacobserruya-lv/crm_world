@isTest
	private class ATG_API_TEST {public with sharing class ErrorList {
		public List<Map<String, String>> errors;
	} 

	@isTest static void test_method_1() {
		Identity_TestFactory.createSettings();

		Test.startTest();
			try{
				Account account = Identity_TestFactory.createAccount('amiram', 'test', 'test@test.com', '123456789', '972', true);
				ATG_API.createMyLVClient(account, 'fra-fr', '005tydfhDS15');
			}
			catch(Exception e){}
		Test.stopTest();
	}
	@isTest static void test_method_2() {
		Identity_TestFactory.createSettings();

		Test.startTest();
			try{
				Account account = Identity_TestFactory.createAccount('amiram', 'test', 'test@test.com', '123456789', '972', true);
                User user = Identity_Utils.createMylvClient(account, 'HDtfqawdv5435!');
				ATG_API.createMyLVClient(account, 'fra-fr', user.Id);
			}
			catch(Exception e){}
		Test.stopTest();
	}
    @isTest static void test_method_3() {
		Identity_TestFactory.createSettings();

		Test.startTest();
			try{
				ATG_API.getBasicAuthentication('fra-fr');
				ATG_API.getBasicAuthentication('zhs-cn');
                
                ErrorList errorList = new ErrorList();
                ErrorList.errors = new List<Map<String, String>>();
                ErrorList.errors.add(new Map<String, String> {'E1'=>'30', 'errorCode'=>'30'});
                ErrorList.errors.add(new Map<String, String> {'E1'=>'60', 'errorCode'=>'60'});
                ErrorList.errors.add(new Map<String, String> {'E1'=>'120', 'errorCode'=>'120'});
                
                String body = 'body';
                ATG_API.getErrorCode(body, errorList.errors);
			}
			catch(Exception e){}
		Test.stopTest();
	}

	@isTest static void test_method_4() {
		Test.startTest();
			try{
				 Map<String,Object> parameters= ATG_API.getSessionId('fra-fr');
			}
			catch(Exception e){}
		Test.stopTest();
	}
}