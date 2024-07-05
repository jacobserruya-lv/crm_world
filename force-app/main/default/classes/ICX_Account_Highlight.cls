public with sharing class ICX_Account_Highlight {

	@AuraEnabled(cacheable=true)
	public static Map<String, List<Option>> getPicklistOptions(Account account){
		Map<String, List<Option>> ret = new Map<String, List<Option>>();
		Set<String> fields = account.getPopulatedFieldsAsMap().keySet();
		System.debug(fields);
		Schema.DescribeSObjectResult objectResult = SObjectType.Account;
		Map<String, Schema.SObjectField> fieldsMap = objectResult.fields.getMap();
		for(String field : fields){
			if(fieldsMap.containsKey(field)){
				Schema.DescribeFieldResult f = fieldsMap.get(field).getDescribe();
				if(f.getType() == Schema.DisplayType.PICKLIST) {
					ret.put(field, getOptions(f));
				}
			}
		}
		return ret;
	}

	private static List<Option> getOptions(Schema.DescribeFieldResult field){
		List<Option> ret = new List<Option>();
		for(Schema.PicklistEntry pe : field.getPicklistValues()){
			if(pe.isActive()) {
				ret.add(new Option(pe));
			}
		}
		return ret;
	}

	public class Option{
		@AuraEnabled public string label;
		@AuraEnabled public string value;

		public Option(Schema.PicklistEntry pe){
            this.label = (pe != null ? pe.getlabel() : null);
            this.value =  (pe != null ? pe.getValue() : null);
		}
	}

	/*@AuraEnabled
    public static Task getTaskCallDetail(Id taskId) {
        System.debug('getTaskCallDetail taskId=' + taskId);
        Task tsk;
        if (String.isNotBlank(taskId)) {
            List<Task> result = [SELECT Id, Phone_Number__c FROM Task WHERE Id = :taskId];
            tsk = (result.isEmpty() ? null : result.get(0));
        }
        return tsk;
    }*/
    
	@AuraEnabled(cacheable=true)
    public static sObject getObjectDetail(Id recordId) {
        sObject result;
        if (String.isNotBlank(recordId)) {
            try {
                String objectType = recordId.getSObjectType().getDescribe().getName();
                if ('Case'.equalsIgnoreCase(objectType)) {
                    result = [SELECT Id, SuppliedEmail FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED];   
                } else if ('Task'.equalsIgnoreCase(objectType)) {
                    List<Task> resultList = [SELECT Id, Phone_Number__c FROM Task WHERE Id = :recordId WITH SECURITY_ENFORCED];
                    result = (resultList.isEmpty() ? null : resultList.get(0));
                }
            } catch (Exception e) {
                // CODE SCAN ANALYZE 2019
                System.debug('thrown standard DML exception '+e);
            }
        }
        return result;
    }

    // Get Country
	@AuraEnabled(cacheable=true)
    public static CountryMapping__mdt getCountry(String iso3Code) {
        CountryMapping__mdt result;
        System.debug('iso3Code=' + iso3Code);
        if (String.isNotBlank(iso3Code)) {
           result = [SELECT id, Account__c, PicklistValueSet__c FROM CountryMapping__mdt WHERE Iso3Code__c = :iso3Code AND HasOtherValue__c = false LIMIT 1 ]; // Not available for Custom Metadata Type: WITH SECURITY_ENFORCED
        }
        return result;
    }

    // Get Country
	@AuraEnabled(cacheable=true)
    public static CountryMapping__mdt getCountryFromISO2(String iso2Code) {
        CountryMapping__mdt result;
        System.debug('iso2Code=' + iso2Code);
        if (String.isNotBlank(iso2Code)) {
           result = [SELECT id, Account__c, PicklistValueSet__c, Iso3Code__c FROM CountryMapping__mdt WHERE Iso2Code__c = :iso2Code LIMIT 1];  // Not available for Custom Metadata Type: WITH SECURITY_ENFORCED
        }
        return result;
    }
    @AuraEnabled(cacheable=true)
    public static User IsIdentityUser(string recordId) {
		User IdentityUser;
        system.debug(recordId);
        if (String.isNotBlank(recordId)) {
          list<user> ListIdentityUser = [select Id,IsActive, LastLoginDate ,TECH_Email__c, TECH_MobilePhone__c from User where AccountId = : recordId LIMIT 1];
          IdentityUser= (ListIdentityUser.isEmpty() ? null : ListIdentityUser.get(0));
        }
        return IdentityUser;
        
    }
   

    @AuraEnabled(cacheable=true)
    public static User getUserInfo(String userId) {
        return [SELECT id, Profile.Name , DefaultStore__c From User WHERE Id = :userId LIMIT 1];
    }

    // Get Regions
	@AuraEnabled(cacheable=true)
    public static List<Option> getRegionList(String iso3Country) {
        List<Option> optList = new List<Option>();

        System.debug('iso3Country=' + iso3Country);
        if (String.isNotBlank(iso3Country)) {
            for (Region__c region : [SELECT regional_code__c,Name, toLabel(Label__c) Label__c FROM Region__c WHERE Country__r.Iso3Code__c = :iso3Country WITH SECURITY_ENFORCED]) {
                Option opt = new Option(null);
                opt.label = region.Name;
                opt.value = region.regional_code__c;
                optList.add(opt);
            }
        }
        System.debug('optList.size=' + optList.size());

        return optList;
    }

    @AuraEnabled(cacheable=true)
    public static Pilot_Setting__mdt countriesExcludedRMS() {
        Pilot_Setting__mdt result;
      
        result = [ SELECT Excluded_Countries__c FROM Pilot_Setting__mdt WHERE MasterLabel ='Identity_RMS_FLOW']; 
        return result;
    }

    @AuraEnabled
    public static void  sendClientToRMS(Account acc, String userStoreCode) {
        try {
            String storeCode = String.isEmpty(acc.AttachedStore__pc) ? userStoreCode : acc.AttachedStore__pc;
            List <Store__c> StoreList = [SELECT id,RetailStoreId__c, StoreType__c  FROM Store__c WHERE RetailStoreId__c =: storeCode LIMIT 1];
            String StoreType = (StoreList.isEmpty() ? null : StoreList.get(0).StoreType__c);


            Account accountForRMS = new Account (Id = acc.id);
            if(StoreType != 'WEB' && acc.RMSID__pc == null){

                if( String.isEmpty(acc.AttachedStore__pc) ){
                    accountForRMS.AttachedStore__pc = storeCode ;
                    accountForRMS.AttachedStoreCode__pc = storeCode ;
                    accountForRMS.Store__pc = StoreList.get(0).id ;
                    Database.update(accountForRMS);
                }
                
                SO_CreateUpdateRMSClient_Utils.createAccountIntoRMS_WS_v5(accountForRMS.Id);

            }else {
                String m = 'Client cannot be sent to RMS Please check the default store';
                AuraHandledException e = new AuraHandledException(m);
                e.setMessage(m);
                throw e;
            }
        } catch (Exception e) {
            throw new AuraHandledException (e.getMessage());
        }
        


       
    }

}