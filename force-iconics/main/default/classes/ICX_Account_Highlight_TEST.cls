@isTest
public class ICX_Account_Highlight_TEST {

    @isTest
    public static void getObjectDetail_Call_Test() {
        // init test
        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        insert call;
        
        // Test
        Task result = (Task) ICX_Account_Highlight.getObjectDetail(call.Id);

        // Check
        System.assert(result != null);
        System.assert(result.Phone_Number__c != null);
    }

    @isTest
    public static void getObjectDetail_Email_Test() {
        String email = 'test@test.com';

        Case cas = ICX_TestFactory.createCase(null);
        cas.SuppliedEmail = email;
        insert cas;

        Test.startTest();
        Case result = (Case) ICX_Account_Highlight.getObjectDetail(cas.Id);
        Test.stopTest();

        System.assertEquals(cas.SuppliedEmail, result.SuppliedEmail);
    }


    @isTest
    public static void getPicklistOptions_Test() {
        // init test
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        // Test
        //ICX_Account_Highlight.getPicklistOptions(acc);
        Map<String, List<ICX_Account_Highlight.Option>> result = ICX_Account_Highlight.getPicklistOptions(acc);
		System.assert(result != null);
        System.assert(!result.isEmpty());
    }

    @isTest
    public static void getCountryOK() {
        CountryMapping__mdt result = ICX_Account_Highlight.getCountry('FRA');
        System.assert(result != null);
        System.assertEquals('FRANCE', result.Account__c);
    }
    

	@isTest
    public static void getUserInfo_Test() {
        Test.startTest();
        User currentUser = ICX_Account_Highlight.getUserInfo(UserInfo.getUserId());
        Test.stopTest();
        
        System.assertEquals(UserInfo.getUserId(), currentUser.Id, 'Expecting current user id');
    }
    @isTest
    public static void isIndentityUser_Test() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Test.startTest();
        user result= ICX_Account_Highlight.IsIdentityUser(acc.id);
        System.assert(result == null);
        Test.stopTest();
        
    }
    
     @isTest
    public static void getRegionList_Test() {
        Country__c country = ICX_TestFactory.createCountry('CN', 'CHN', 'CHINA');
        insert country;

        Region__c region = ICX_TestFactory.createRegion('CN-BJ','BJ', 'BJ', country.Id);
        Region__c region2 = ICX_TestFactory.createRegion('CN-AH','AH', 'AH', country.Id);
        //Region__c region3 = ICX_TestFactory.createRegion('FR-IDF','IDF', '', null);
        insert new List<Region__c> {region, region2};
            
		Test.startTest();
        List<ICX_Account_Highlight.Option> result = ICX_Account_Highlight.getRegionList(country.Iso3Code__c);
        Test.stopTest();
        
        System.assertEquals(2, result.size());
    }

    @isTest
    public static void sendClientToRMSTest() {
        // init test   
        
        Store__c str = ICX_TestFactory.createStore('A06','A06');
        insert str;
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Pilot_Setting__mdt result =  ICX_Account_Highlight.countriesExcludedRMS();
        ICX_Account_Highlight.getCountryFromISO2('FR');
		System.assert(result != null);



         ICX_Account_Highlight.sendClientToRMS(acc,'A06');
       // System.assert(!result.isEmpty());
    }
}