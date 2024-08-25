public with sharing class ICX_Flow_AccountController {

    @AuraEnabled(cacheable=true)
    public static User getUser() {
		return [SELECT DefaultStore__c FROM User WHERE Id =:UserInfo.getUserId()];
        //return SO_UserServiceController.getUser();
    }

    @AuraEnabled(cacheable=true)
    public static String getStoreJson() {
        List<PicklistEntry> values = User.DefaultStore__c.getDescribe().getPicklistValues();
        return JSON.serialize(values);
    }

    @AuraEnabled(cacheable=true)
    public static User getUserProfile() {
        return [SELECT Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }

    @AuraEnabled(cacheable=true)
    public static Store__c getStore(String storeCode) {
        System.debug('storeCode=' + storeCode);
        Store__c result;
        if (String.isNotBlank(storeCode)) {
            List<Store__c> storeList = [SELECT Id, Name, RetailStoreId__c, StoreCountry__c FROM Store__c WHERE RetailStoreId__c = :storeCode];
            if (!storeList.isEmpty()) {
                result = storeList[0];
            }
        }
        System.debug('getStore>result=' + result);
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Account getAccountFromRMS(String storeCode, String rmsId, String wwRmsClientCode) {//, Account sfdcClient) {
        //Account acc = SO_CreateUpdateRMSCLient_Utils.syncClient(storeCode, rmsId, sfdcClient);
        return SO_WS_POSFacade.clientSearch(storeCode, rmsId, wwRmsClientCode);
    }
    
    /*@AuraEnabled(cacheable=true)
    public static Account getAccountFromRecord(String recordId) {
        Account account;

        Id accId = ICX_CaseDataServiceControllerLC.getAccountId(recordId);
        if (String.isNotBlank(accId)) {
            // Typology__pc = Client / Prospects / ...
            List<Account> accList = [SELECT Id, FirstName, LastName, Salutation, Typology__pc, DREAMID__c FROM Account WHERE Id = :accId];
	        System.debug('accList=' + accList);
            account = (accList.isEmpty() ? null : accList.get(0));
        }
        System.debug('Account=' + account);
        return account;
    }*/

    @AuraEnabled(cacheable=true)
    public static Id getAccountId(String recordId) {
        Id accId = ICX_CaseDataServiceControllerLC.getAccountId(recordId);
        return accId;
    }

    @AuraEnabled
    public static Account insertAccount(Account account) {
        System.debug('insertAccount>' + account);
        if (account != null && String.isBlank(account.Id)) {
            account.DREAMID__c = null;
            insert account;
        }
        return account;
    }
}