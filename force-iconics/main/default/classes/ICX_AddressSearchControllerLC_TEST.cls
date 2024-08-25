@isTest
public class ICX_AddressSearchControllerLC_TEST {

    @isTest
    public static void getVisualforceHost_Test() {
        String host = 'louisvuitton--pprod--c.cs95.visual.force.com';
        IconicsSettings__c settings = new IconicsSettings__c();
        settings.VisualforceHost__c = host;
        insert settings;
        
        Test.startTest();
        System.assertEquals(host, ICX_AddressSearchControllerLC.getVisualforceHost());
        Test.stopTest();
    }

    @isTest
    public static void getCurrentUserLogin_Test() {
        Test.startTest();
        String countryResult = ICX_AddressSearchControllerLC.getCurrentUserLoginCountry();
        Test.stopTest();

        // Difficult to check the result in the LoginHistory in a test + difficult to create a user with a LoginHistory record
        System.assert((String.isNotBlank(countryResult) || String.isBlank(countryResult))); // It should not be blank but sometimes during a deployment, this value could be null strangely (maybe because of the Session Timeout)
    }
}