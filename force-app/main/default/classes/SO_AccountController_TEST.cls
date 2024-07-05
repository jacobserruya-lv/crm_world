@isTest

public class SO_AccountController_TEST {
    
    
    @isTest static void Test_getSalutationJson(){

        List<PicklistEntry> expectedValues = Account.Salutation.getDescribe().getPicklistValues();
        String values = SO_AccountController.getSalutationJson();
        

        System.assertEquals(JSON.serialize(expectedValues), values); 
    }
    
    @isTest static void Test_getCountryCodeJson(){

        List<PicklistEntry> expectedValues = Account.SPO_Country_code__pc.getDescribe().getPicklistValues();
        String values = SO_AccountController.getCountryJson();
        

        System.assertEquals(JSON.serialize(expectedValues), values);        
    }
}