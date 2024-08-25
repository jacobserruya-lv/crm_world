/**
 * Transform Email-2-Case from the Contact Us of louisvuitton.com website
 * No Salesforce standard Web-2-Case, because of frequently attacks in louisvuitton.com website. 
 * Otherwise the website needs an authentificated user to create a Case in Salesforce
**/
public class ICX_Case_Web2Case {

    /**
     * @description Map webform fields with Case fields
     * @parameters caseList: cases with Description field containing all values from webform 
    **/
    /*public static Map<Id, WebToCaseWrapper> webformMap(List<Case> caseList) {
        List<Case> caseToUpdateList = new List<Case>();

        Map<Id, WebToCaseWrapper> wrapperMap = new Map<Id, WebToCaseWrapper>();

        if (caseList != null || !caseList.isEmpty()) {
            
            Map<String, String> languageMap = new Map<String, String>();
            for (Language__mdt lang : [SELECT DeveloperName, Code3__c FROM Language__mdt]) {
                languageMap.put(lang.DeveloperName, lang.Code3__c.toUpperCase());
            }
            System.debug('languageMap.size()=' + languageMap.size());

            Map<String, Map<String, String>> transcoMetadataMap = new Map<String, Map<String, String>>();
            for (ICX_WebFormTransco__mdt transco : [SELECT Type__c, AtgCode__c, SalesforceCode__c FROM ICX_WebFormTransco__mdt]) {
                if (transcoMetadataMap.get(transco.Type__c) == null) {
                    transcoMetadataMap.put(transco.Type__c, new Map<String, String>());
                }
                transcoMetadataMap.get(transco.Type__c).put(transco.AtgCode__c, transco.SalesforceCode__c);
            }

            for (Case cas : caseList) {
                WebToCaseWrapper wrapper = buildWrapper(cas.Description);
                // Transco to Salesforce values
                if (wrapper != null) {
                    if (String.isNotBlank(wrapper.type)) {
                        if (transcoMetadataMap != null && transcoMetadataMap.get('civility') != null && String.isNotBlank(transcoMetadataMap.get('civility').get(wrapper.type))) {
                            wrapper.type = transcoMetadataMap.get('civility').get(wrapper.type);
                        }
                    }
                    //wrapper.type = (String.isNotBlank(wrapper.type) && transcoMetadataMap != null && transcoMetadataMap.get('civility') != null ? transcoMetadataMap.get('civility').get(wrapper.type) : '');
                    wrapper.language = (String.isNotBlank(wrapper.language) ? languageMap.get(wrapper.language) : '');

                    wrapperMap.put(cas.Id, wrapper);

                    //cas.Country__c = wrapper.country;
                    //cas.Language__c = (String.isNotBlank(wrapper.language) ? languageMap.get(wrapper.language) : '');
                    //cas.Description = wrapper.message;
                    //cas.Type = wrapper.natureId;
                    //cas.Category__c = wrapper.categoryId;

                    //caseToUpdateList.add(cas);
                }
            }

            //if (!caseToUpdateList.isEmpty()) {
            //    update caseToUpdateList;
            //}
        }
        System.debug('wrapperMap=' + wrapperMap);
        return wrapperMap;
    }

    public static WebToCaseWrapper buildWrapper(String description) {
        WebToCaseWrapper wrapper;

        if (isWebform(description)) {
            //String description = cas.description;

            try {
                wrapper = new WebToCaseWrapper();
                
                wrapper.type = description.substringBetween('type:','first_name:').trim();
                wrapper.firstname = description.substringBetween('first_name:','last_name:').trim();
                wrapper.lastname = description.substringBetween('last_name:','email address:').trim();
                wrapper.email = description.substringBetween('email address:','address1:').trim().toLowercase();
                wrapper.address = description.substringBetween('address1:','city:').trim();
                wrapper.city = description.substringBetween('city:','zip_code:').trim();
                wrapper.postalCode = description.substringBetween('zip_code:','country:').trim();
                
                wrapper.country = description.substringBetween('country:','responseLanguage:').trim();
                wrapper.language = description.substringBetween('responseLanguage:','message:').trim();
                wrapper.message = description.substringBetween('message:','kanaform:').trim();
                //wrapper.kanaform = description.substringBetween('kanaform:','contactNatureKanaId:').trim();
                wrapper.natureId = description.substringBetween('contactNatureKanaId:','repositoryKey:').trim();
                //wrapper.repositoryKey = description.substringBetween('repositoryKey:','contactCategoryKanaId:');
                //wrapper.categoryId = description.substringBetween('contactCategoryKanaId:','\n');
                
                List<String> catSplit =  description.split('contactCategoryKanaId:');
                if (catSplit.size() > 1) {
                    wrapper.categoryId = catSplit.get(1).trim();
                }
            } catch (Exception e) {
                // let the case to be created even with Webform template problem (the exception should not be occured but it's a precaution)
                System.debug('Exception: ' + e);
            }

            System.debug('wrapper=' + wrapper);
        }
        return wrapper;
    }

    public static Boolean isWebform(String description) {
        System.debug('description=' + description);
        if (String.isNotBlank(description) && description.startsWithIgnoreCase('type:')) {
            return true;
        }

        return false;
    }
*/
    // @future used as AccountId is empty if the method is directly called (AccountId is filled by the 'Email To Case Prospect Creation' visual flow)
    @future
    public static void updateCaseList(Set<Id> caseIdList) {
/*
        List<Case> caseWebformList = new List<Case>();
        Map<Id, Id> caseAccountIdMap = new Map<Id, Id>();
        
        // new SOQL to get AccountId updated by the Visual Flow
        for (Case ca : [SELECT Id, AccountId, Description, SourceId FROM Case WHERE ID IN :caseIdList]) {
            if (ICX_Case_Web2Case.isWebform(ca.Description)) {
                caseWebformList.add(ca);
                //caseAccountIdMap.put(ca.Id, accountId);
                if (String.isNotBlank(ca.AccountId)) {
                    caseAccountIdMap.put(ca.Id, ca.AccountId);
                }
            }
        }
        System.debug('caseWebformList=' + caseWebformList);
        System.debug('caseAccountIdMap=' + caseAccountIdMap);
        //System.debug('accIdSet=' + accIdSet);
        
        if (!caseWebformList.isEmpty()) {

            // only Prospect created just after the Case creation can be updated
            Map<Id, Account> caseAccountMap =  new Map<Id, Account>([SELECT Id, Lastname, Firstname, Salutation, PreferredLanguage__pc, PrimaryCountry__pc
                                                                     FROM Account WHERE Id IN :caseAccountIdMap.values() AND DREAMID__c = '' AND isProspect__pc = true AND CreatedDate = TODAY]); 
            // TODO: only filter for DREAMId__c = ' or isDreamProspect__c = true ? But when the Account is created with Dream Id, the webform can't changed the account data
            System.debug('caseAccountMap=' + caseAccountMap);
            
            // Transform webform data from ATG to Salesforce values
            Map<Id, ICX_Case_Web2Case.WebToCaseWrapper> webformMap = ICX_Case_Web2Case.webformMap(caseWebformList);
            
            // update webform case and eventually the prospect
            List<Case> caseToUpdateList = new List<Case>();
            List<Account> accountToUpdateList = new List<Account>();
            for (Case cas : caseWebformList) {
                ICX_Case_Web2Case.WebToCaseWrapper wrapper = webformMap.get(cas.Id);
                
                // workaround of "execution of AfterInsert caused by: System.FinalException: Record is read-only"
                Case newCase = new Case(Id = cas.Id);
                //newCase.Description = wrapper.message;
                
                // TODO transco nature+category: for LV.com > Contact Us : Web-2-Case is Email-2-Case. Don't need to transco
                //newCase.Type = wrapper.natureId;
                //newCase.Category__c = wrapper.categoryId;
                newCase.Origin = 'Web';
                if (wrapper != null && String.isNotBlank(wrapper.email)) {
                    newCase.SuppliedEmail = wrapper.email;
                }
                
                System.debug('newCas=' + newCase);
                caseToUpdateList.add(newCase);
                
                Id accId = caseAccountIdMap.get(cas.Id);//caseAccountIdMap.get(cas.Id);
                //System.debug('accId=' + accId);
                if (String.isNotBlank(accId) && wrapper != null) {
                    Account acc = caseAccountMap.get(accId);
                    System.debug('acc=' + acc);
                    if (acc != null) {
                        acc.Salutation = wrapper.type;
                        acc.Firstname = wrapper.firstname;
                        acc.Lastname = wrapper.lastname;
                        acc.PersonEmail = wrapper.email;
                        acc.PreferredLanguage__pc = wrapper.language;
                        acc.PrimaryZipCode__pc = wrapper.postalCode;
                        acc.PrimaryCity__pc = wrapper.city;
                        acc.PrimaryAddressLine1__pc = wrapper.address;
                        acc.PrimaryCountry__pc = wrapper.country;
                        accountToUpdateList.add(acc);
                    }
                }
                // don't know why but cas.AccountId returns empty
                //Account acc = caseAccountMap.get(cas.AccountId);
                //System.debug('acc=' + acc);
                //System.debug('cas.AccountId=' + cas.AccountId);
                //System.debug('cas.ContactId=' + cas.ContactId);
            }
            
            if (!accountToUpdateList.isEmpty()) {
                System.debug('accountToUpdateList=' + accountToUpdateList);
                update accountToUpdateList;
            }
            update caseToUpdateList;
        }*/
    }
    /*
    public class WebToCaseWrapper {
        public String type;
        public String firstname;
        public String lastname;

        public String email;
        public String address;
        public String city;
        public String postalCode;

        public String country;
        public String language;
        public String message;
        public String kanaform;
        public String natureId;
        public String repositoryKey;
        public String categoryId;
    }*/
}