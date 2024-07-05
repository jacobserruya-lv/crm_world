@isTest
public class ICX_catalogSearchTEST {
    public ICX_catalogSearchTEST() {}



    @IsTest(SeeAllData=true) 
    static void getCredentialsForGastonTest () {
        MuleSoft_API_Callout__mdt listCredentials = new MuleSoft_API_Callout__mdt();
        Test.startTest();
        listCredentials = ICX_catalogSearch.getCredentialsForGaston('');
        Test.stopTest();
    
        System.debug('getCredentialsForGastonTest, listcredentials : ' + listCredentials);
    
        System.assertEquals( 'POST', listCredentials.Method__c);
    }
}