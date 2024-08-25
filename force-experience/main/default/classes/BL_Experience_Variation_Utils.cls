public with sharing class BL_Experience_Variation_Utils {
  
    public static Map<String, String> getLanguagePerStore(List<String> isoCodes){
		Map<String, String> languagePerCountry = new Map<String, String>();
        List<CountryLanguage__c> languages = [
            SELECT Country__r.Iso3Code__c, Salesforce_Language__c 
            FROM CountryLanguage__c 
            WHERE Default__c = TRUE AND Country__r.Iso3Code__c IN: isoCodes
        ];

        for(CountryLanguage__c language : languages ){

           String iSOCode = language.Country__r.Iso3Code__c;
           languagePerCountry.put(iSOCode, language.Salesforce_Language__c);
        }
        return languagePerCountry;
    }

    public static Map<String, List<Id>> getUsersByStore(Set<String> storeCodes,String profile){

        Map<String, List<Id>> usersPerStore = new Map<String, List<Id>>();
        String query = 'SELECT Id, DefaultStore__c ' +
                        'FROM User ' + 
                        'WHERE DefaultStore__c IN: storeCodes AND IsActive = true' + (String.isNotEmpty(profile) ? ' AND ProfileId =: profile' : '');
       
        List<User> users = new List<User>();
        users = Database.query(query);
       
        for(User user : users ){

            if(!usersPerStore.containsKey(user.DefaultStore__c)) {
                usersPerStore.put(user.DefaultStore__c , new List<Id>());
            }
            usersPerStore.get(user.DefaultStore__c).add(user.id);
        }

        return usersPerStore;
    }


    public static Id getRecordTypeExperience(String experienceType){
        
        switch on experienceType {
            when 'Experience' {
                return Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Experience').getRecordTypeId();
            }
            when 'Club' {
                return Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Club_Experience').getRecordTypeId();
            }
        }
        return null;
    }


    public static List<Account> getRelatedClients(Set<Id> clientIds ) {

        return [SELECT Id , OwnerId FROM Account WHERE ID IN:clientIds];
    }


    public static Map<Id,Id> getPreferredCAByClient(List<Account> clients ) {

        Map<Id,Id> ownerPerCLient = new Map<Id,Id>(); 
        for (Account client : clients) {
            ownerPerCLient.put(client.id,client.OwnerId);
        }
        return ownerPerCLient;
    }

    public static List<Brand_Experience_Variation__c> getVariatonsById(Set<Id> experienceVariationIds ) {

        return [
                SELECT Id, Brand_Experience__r.RecordTypeId , Status__c,RequiredClientRegistration__c, ClientSelection__c, Registration_by_CA__c 
                FROM Brand_Experience_Variation__c  
                WHERE Id IN:experienceVariationIds
                ];
    } 

    public static Map<Id,Id> getrecordTypeByVariation(List<Brand_Experience_Variation__c> experienceVariations){

        Map<Id,Id> recordTypeByVariation = new  Map<Id,Id> ();
        for(Brand_Experience_Variation__c variation : experienceVariations) {

            recordTypeByVariation.put(variation.id, variation.Brand_Experience__r.RecordTypeId);
        }
        return recordTypeByVariation;
    }

    public static  Map<Id,Brand_Experience_Variation__c>  getMapVariationById(Set<Id> experienceVariationIds ){

        List<Brand_Experience_Variation__c> variations = getVariatonsById(experienceVariationIds);
        Map<Id,Brand_Experience_Variation__c> variationById = new  Map<Id,Brand_Experience_Variation__c> ();

        for(Brand_Experience_Variation__c variation : variations) {

            variationById.put(variation.id, variation);
        }
        return variationById;
    }
}