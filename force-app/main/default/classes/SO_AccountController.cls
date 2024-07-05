public class SO_AccountController {

    @AuraEnabled
    public static String getSalutationJson() {
        List<PicklistEntry> values = Account.Salutation.getDescribe().getPicklistValues();
        return JSON.serialize(values);
    }
    
    /*@AuraEnabled
    public static String getClientTypeJson() {
        List<PicklistEntry> values = Account.TypologyCode__pc.getDescribe().getPicklistValues();
        return JSON.serialize(values);
    }

    @AuraEnabled
    public static String getNationalityJson() {
        List<PicklistEntry> values = Account.NationalityCountryCode__pc.getDescribe().getPicklistValues();
        return JSON.serialize(values);
    }*/

    @AuraEnabled
    public static String getCountryJson() {
        List<PicklistEntry> values = Account.SPO_Country_code__pc.getDescribe().getPicklistValues();
        return JSON.serialize(values);
 
    }

    /*@AuraEnabled
    public static String getPhoneCountryJson() {
        List<PicklistEntry> values = Contact.TECH_PhoneCountryCode__c.getDescribe().getPicklistValues();
        return JSON.serialize(values);
    }*/


}