global with sharing class SO_ClientController {

    @AuraEnabled(cacheable=true)
    public static SO_ProductPagedResult findAll(String clientJson, Decimal pageSize, Decimal pageNumber, Boolean callRms) {

        System.debug('clientJson=' + clientJson);
        SO_Util.SearchClientData clientData = (SO_Util.SearchClientData) JSON.deserializeStrict(clientJson, SO_Util.SearchClientData.class);

        Integer pSize = (Integer)pageSize;
        Integer offset = ((Integer)pageNumber - 1) * pSize;

        SO_ProductPagedResult r = new SO_ProductPagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;

        /*if (!callRms) {
            // search in Salesforce
            String lastnameKey = '%' + clientData.lastname + '%';

            // build query
            String query = 'SELECT Id, Name, Lastname, Firstname, PrimaryAddressLine1__pc, PersonEmail, PersonHomePhone, PersonMobilePhone, PersonBirthdate, Phone, DREAMID__c, PrimaryCity__pc, SPO_Country_code__pc, PrimaryZipCode__pc';
            query += ' FROM Account WHERE (LastName LIKE :lastnameKey OR Lastname2__pc LIKE :lastnameKey) ';
            if (String.isNotBlank(clientData.firstname)) {
                String firstnameKey = '%' + clientData.firstname + '%';
                query += ' AND firstname LIKE :firstnameKey';
            }
            if (String.isNotBlank(clientData.email)) {
                query += ' AND PersonEmail = :clientData.email';
            }
            if (String.isNotBlank(clientData.phoneNumber)) {
                String phoneKey = '%' + clientData.phoneNumber + '%';
                query += ' AND (Phone LIKE :phoneKey OR LocalMobilePhone__pc LIKE :phoneKey OR LocalHomePhone__pc LIKE :phoneKey OR PersonHomePhone LIKE :phoneKey OR PersonMobilePhone LIKE :phoneKey)';
            }
            if (String.isNotBlank(clientData.passportNumber)) {
                String passportKey = '%' + clientData.passportNumber + '%';
                query += ' AND PassportNumber__pc LIKE :passportKey';
            }
            if (String.isNotBlank(clientData.zipCode)) {
                String postalcodeKey = '%' + clientData.zipCode + '%';
                query += ' AND PrimaryZipCode__pc LIKE :postalcodeKey';
            }
            if (String.isNotBlank(clientData.country)) {
                String countryKey = '%' + clientData.country + '%';
                query += ' AND SPO_Country__pc LIKE :countryKey';
            }

            // execute a query to count the result
            r.total = Database.query(query).size();
    
            // limit the result to the number of items by page
            query += ' ORDER BY LastName LIMIT :pSize OFFSET :offset';     
            r.sobjects = Database.query(query);
        } else {*/

            // TODO what storeId use when not the user is not a Client Advisor?
            if (String.isBlank(clientData.storeCode)) {
                clientData.storeCode = getUser().DefaultStore__c;
            }

            // search in RMS by webservice - 2 option (using Mulesoft or not)
            
          //  if (SO_Settings__c.getValues('now-yours_mulesoft-active').value__c == 'true'  ) {  // MIY-2154
            SO_WS_RMS_DoClientSearchMulesoft.Result result = new SO_WS_RMS_DoClientSearchMulesoft.Result ();
            
            if (callRms){
               
                result = SO_WS_POSFacade.clientSearchMulesoft(clientData);
            }

            r.total = (SO_UTIL.isNotEmpty(result.resultList) ? result.resultList.size() : 0);
            r.clientRmsList = JSON.serialize(result.resultList); // serialize for Javascript controller
        
        	List<Account> accList = new List<Account>();
       	 	if (result.resultList != null) {
                for (SO_WS_RMS_DoClientSearchMulesoft.ResultLine accountRms : result.resultList) {
                    Account acc = SO_WS_RMS_DoClientSearchMulesoft.MapRmsClientIntoSfdcClient(accountRms, new Account());
                    accList.add(acc);
                }
            }
        	r.sobjects = accList;
            System.debug('result = ' +  result);
        // } else {  // MIY-2154
        //     SO_WS_RMS_DoClientSearch.Result result = new SO_WS_RMS_DoClientSearch.Result ();
           
        //     if (callRms){
            
        //         result = SO_WS_POSFacade.clientSearch(clientData);
        //     }

        //     r.total = (SO_UTIL.isNotEmpty(result.resultList) ? result.resultList.size() : 0);
        //     r.clientRmsList = JSON.serialize(result.resultList); // serialize for Javascript controller
        
        // 	List<Account> accList = new List<Account>();
       	//  	if (result.resultList != null) {
        //         for (SO_WS_RMS_DoClientSearch.ResultLine accountRms : result.resultList) {
        //             Account acc = SO_WS_RMS_DoClientSearch.MapRmsClientIntoSfdcClient(accountRms, new Account());
        //             accList.add(acc);
        //         }
        //     }
        // 	r.sobjects = accList;
        //     System.debug('result = ' +  result);
            
        // }
    

        //            r.clientRmsList = result.resultList;
          
        //}

        System.debug(r);
        return r;
    }

    @AuraEnabled(cacheable=true)
    public static SO_ProductPagedResult findAllInSalesforce(String clientJson, Decimal pageSize, Decimal pageNumber) {

        System.debug('clientJson=' + clientJson);
        SO_Util.SearchClientData clientData = (SO_Util.SearchClientData) JSON.deserializeStrict(clientJson, SO_Util.SearchClientData.class);
        System.debug('clientData=' + clientData);

        Integer pSize = (Integer)pageSize;
        Integer offset = ((Integer)pageNumber - 1) * pSize;

        SO_ProductPagedResult r = new SO_ProductPagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;

        //if (!callRms) {
            // search in Salesforce

            // build query
            String query = 'SELECT Id, Salutation, Name, Lastname, Firstname, PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryAddressLine3__pc, PrimaryCity__pc, SPO_Country_code__pc, PrimaryZipCode__pc, PrimaryStateProvince__pc, PassportNumber__pc, '
                + ' PersonEmail, LocalHomePhone__pc, LocalMobilePhone__pc, LocalWorkPhone__pc, PersonHomePhone, PersonMobilePhone, Phone, PersonBirthdate, DREAMID__c';
            //query += ' FROM Account WHERE (LastName LIKE :lastnameKey OR Lastname2__pc LIKE :lastnameKey) ';
            query += ' FROM Account ';

        	Boolean isFirstCondition = true;
            if (String.isNotBlank(clientData.lastname)) {
                String lastnameKey = clientData.lastname;
                // LIKE is slow. Equal is faster in a 20M client database
                //String lastnameKey = '%' + clientData.lastname + '%';
                query += (isFirstCondition ? ' WHERE ' : ' AND ') + ' (LastName = :lastnameKey OR Lastname2__pc = :lastnameKey) ';
                isFirstCondition = false;
            }
        	if (String.isNotBlank(clientData.firstname)) {
                // LIKE is slow. Equal is faster in a 20M client database
                //String firstnameKey = '%' + clientData.firstname + '%';
                String firstnameKey = clientData.firstname;

                query += (isFirstCondition ? ' WHERE ' : ' AND ') + ' (firstname = :firstnameKey OR Firstname2__pc = :firstnameKey) ';
                isFirstCondition = false;
            }
            if (String.isNotBlank(clientData.email)) {
                String email = clientData.email;
                query += (isFirstCondition ? ' WHERE ' : ' AND ') + ' PersonEmail = :email';
                isFirstCondition = false;
            }
            if (String.isNotBlank(clientData.phoneNumber)) {
                // LIKE is slow. Equal is faster in a 20M client database
                //String phoneKey = '%' + clientData.phoneNumber + '%';
                String phoneKey = clientData.phoneNumber;
                query += (isFirstCondition ? ' WHERE ' : ' AND ') + ' (Phone = :phoneKey OR LocalMobilePhone__pc = :phoneKey OR LocalWorkPhone__pc = :phoneKey OR LocalHomePhone__pc = :phoneKey OR PersonHomePhone = :phoneKey OR PersonMobilePhone = :phoneKey)';
                isFirstCondition = false;
            }
            //if (String.isNotBlank(clientData.passportNumber)) {
            //    String passportKey = '%' + clientData.passportNumber + '%';
            //    query += (isFirstCondition ? ' WHERE ' : ' AND ') + ' PassportNumber__pc LIKE :passportKey';
            //}
            if (String.isNotBlank(clientData.zipCode)) {
                // LIKE is slow. Equal is faster in a 20M client database
                //String postalcodeKey = '%' + clientData.zipCode + '%';
                String postalcodeKey = clientData.zipCode;
                query += (isFirstCondition ? ' WHERE ' : ' AND ') + ' PrimaryZipCode__pc = :postalcodeKey';
                isFirstCondition = false;
            }
            if (String.isNotBlank(clientData.country)) {
                String countryKey =  clientData.country;//'%' + clientData.country + '%';
                query += (isFirstCondition ? ' WHERE ' : ' AND ') + ' SPO_Country__pc = :countryKey';
                isFirstCondition = false;
            }
            if (String.isNotBlank(clientData.dreamId)) {
                String dreamId =  clientData.dreamId;
                query += (isFirstCondition ? ' WHERE ' : ' AND ') + ' DREAMID__c = :dreamId';
                isFirstCondition = false;
            }

            // execute a query to count the result
            r.total = Database.query(query).size();
    
            // limit the result to the number of items by page
            query += ' ORDER BY LastName LIMIT :pSize OFFSET :offset';
        	System.debug('query=' + query);
            r.sobjects = Database.query(query);
        //}

        System.debug(r);
        return r;
    }

    /*private static SO_WS_RMS_DoClientSearch.Result callRms(SO_Util.SearchClientData clientData) { // // MIY-2154
        SO_WS_RMS_DoClientSearch ws = new SO_WS_RMS_DoClientSearch();
        SO_WS_RMS_DoClientSearch.Result wsResult;

        // TODO what storeId use when not the user is not a Client Advisor?
        if (String.isBlank(clientData.storeCode)) {
            clientData.storeCode = getUser().DefaultStore__c;
        }
        try {
            wsResult = ws.doClientSearch(clientData);
            //System.debug('SFDC wsResult: ' + wsResult);
        } catch(Exception exp) {
            AuraHandledException e = new AuraHandledException(exp.getMessage());
            throw e;
        }

        if (String.isNotBlank(wsResult.error)) {
            AuraHandledException e = new AuraHandledException(wsResult.error);
            //e.setMessage(wsResult.error);
            throw e;
        }

        return wsResult;
    }*/

    @AuraEnabled(cacheable=true)
    public static Account findById(Id accountId) {
        return [SELECT id, name
                FROM Account
                WHERE Id = :accountId];
    }

    private static User getUser() {
        return SO_UserServiceController.getUser();
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCountryMap() {
        return SO_UTIL.COUNTRY_CODE_BY_STORE_COUNTRY_MAP;
    }
}