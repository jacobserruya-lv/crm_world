@isTest(SeeAllData=false)
private class ThirdParty_Utils_TEST {
	
	@isTest static void test_method_one() {
		// Implement test code
		Identity_TestFactory.createSettings();
        String password = 'HDtfqawdv5435!';
        String code;
        Account acc;
        User us;
        code = String.valueOf(Math.round(Math.random() * 100000));
        acc = Identity_TestFactory.createAccount('Jean', 'Marc', code + 'test@test.com', null, null, true);
        us =  Identity_Utils.createMylvClient(acc, password); 
        Test.startTest();
        Map<String,String> result= ThirdParty_Utils.getSettings('AKAMAI_Shortner_IDENTITY'); 
        System.assertNotequals(result.get('endpoint') , null);
        System.runAs(us) {
            Map<String,String> resultIdentity= ThirdParty_Utils.getSettings('ATG');  
            System.assertNotequals(resultIdentity.get('endpoint') , null);
            //TEST ERROR CASE
            resultIdentity= ThirdParty_Utils.getSettings(null);  
            System.assertequals(resultIdentity.get('endpoint') , null);            
            
        }
           Test.stopTest(); 
    }
	
}