public class PhoneFormatter_LC {
	
    @AuraEnabled
	public static List<CountryPhoneCode__mdt> getCountryPhoneCodes(){
    	List<CountryPhoneCode__mdt> CountryPhoneCodes = [SELECT  Label,DeveloperName,FirstDigit__c,RemoveFirstDigit__c , CountryCallingCode__c FROM CountryPhoneCode__mdt];
    	return CountryPhoneCodes;
	}
    /*@AuraEnabled
	public static CountryPhoneCode__mdt getCountryPhoneCodes(string country){
    	CountryPhoneCode__mdt cpt ; 
        List<CountryPhoneCode__mdt> CountryPhoneCodes = [SELECT Label,DeveloperName,FirstDigit__c,RemoveFirstDigit__c , CountryCallingCode__c FROM CountryPhoneCode__mdt where DeveloperName=:country limit 1];
        system.debug(CountryPhoneCodes);
    	cpt= (CountryPhoneCodes.isEmpty() ? null : CountryPhoneCodes.get(0));
		return cpt;
	}*/
}