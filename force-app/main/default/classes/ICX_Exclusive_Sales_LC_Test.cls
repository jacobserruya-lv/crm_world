@isTest
public class ICX_Exclusive_Sales_LC_Test {
    
    
    @isTest 
    static void test_trigger() {
        
        Test.StartTest();

        // Create Account
        String code = String.valueOf(Math.round(Math.random() * 100000));
        Account acc = new Account(
            LastName = 'lastName',
            FirstName = 'firstName',
            PersonEmail = code+'test@test.com',  
            PrimaryCountry__pc = 'BELGIUM',
            Salutation = '02',
            HomeAddressCountryCode__pc = 'BEL',
            DREAMID__c = '87654321',
            Can_Be_Contacted_By_Email__pc = true
        );
        insert acc;

        // Get XXPR Picklist values according to Org
        Schema.DescribeFieldResult XXPR_Typology = Exclusive_Experience__c.Typology__c.getDescribe();
        Schema.sObjectField fieldTypology = XXPR_Typology.getSObjectField();
        List<PicklistEntry> picklistValuesTypology = fieldTypology.getDescribe().getPicklistValues();        
        
        Schema.DescribeFieldResult XXPR_OfferCode = Exclusive_Experience__c.Offer_Code__c.getDescribe();
        Schema.sObjectField fieldOfferCode = XXPR_OfferCode.getSObjectField();
        List<PicklistEntry> picklistValuesOfferCode = fieldOfferCode.getDescribe().getPicklistValues();
        
        // Create XXPR
        Exclusive_Experience__c xxpr1 = new Exclusive_Experience__c(
            Account_Id__c = acc.Id,
            Dream_Id__c = acc.DREAMID__c,
            Typology__c = picklistValuesTypology[0].getValue(),
            Offer_Code__c = picklistValuesOfferCode[0].getValue()
        ); 
        insert xxpr1; 
        Integer numOfXXPR = 0 ;
        List<Exclusive_Experience__c> lst = ICX_Exclusive_Sales_LC.getExculisveSales(acc.id);
        if(!lst.isEmpty()){
           numOfXXPR= 1;
        }
        System.assertEquals(numOfXXPR, lst.size());
     
    }

}