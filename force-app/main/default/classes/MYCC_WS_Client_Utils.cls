/*
    *** CREATED DATE December 2018
    *** COMPANY      Balink
    *** AUTHOR       Elchanan Rottman
    *** DESCRIPTION  Utils for Web Service MyCC (MYCC_WS_Client)
    */
    global class MYCC_WS_Client_Utils {
        
        /*
    *** DESCRIPTION Upsert account
    *** RETURN      String   Account Id
    */
        
        global static String upsertAccount(String jsonString){
            
            MYCC_ClientWR ClientWR = new MYCC_ClientWR();
            if(!String.isEmpty(jsonString)){
                if  (System.Label.JsonMYCC_WS_Client=='true'){
                    system.debug('Json RECEIVED: '+jsonString);
                }
                String employeeNumber = ClientWR.parse(jsonString).WWEmployeeNumber;
                System.debug('###### '+ employeeNumber);
                Account acc = (Account)JSON.deserialize(jsonString, Account.class);
                // REQUIRED FIELDS
                if(String.isEmpty(acc.Firstname) || String.isEmpty(acc.Lastname) || (
                    // At least one contactibility field - EMAIL
                    String.isEmpty(acc.PersonEmail)
                    // At least one contactibility field - PHONE
                    && String.isEmpty(acc.LocalMobilePhone__pc) && String.isEmpty(acc.LocalHomePhone__pc) && String.isEmpty(acc.LocalWorkPhone__pc)
                    // At least one contactibility field - ADDRESS
                    && String.isEmpty(acc.PrimaryAddressLine1__pc) && String.isEmpty(acc.PrimaryCity__pc))){
                        
                        throw new CustomException(Label.MyCC_Required_Fields);
                    }
                
                // SET PersonMobilePhone if we have the calling code and the local phone
                if(String.isEmpty(acc.PersonMobilePhone) && !String.isEmpty(acc.MobilePhoneCountryCallingCode__pc) && !String.isEmpty(acc.LocalMobilePhone__pc)){
                    acc.PersonMobilePhone = Identity_Utils.getMobilePhone(acc.MobilePhoneCountryCallingCode__pc, acc.LocalMobilePhone__pc);
                }
                Database.UpsertResult result;
                
                // Update account according Dream Id
                if(acc.DREAMID__c != null && String.isNotBlank(acc.DREAMID__c)){
                    System.debug('UPSERT BY DREAM ID');
                    result = Database.upsert(acc, Account.Fields.DREAMID__c, false);
                }
                else {
                    String accountId = acc.Id != null ? acc.Id : getProspect(acc);
                    // Update account according Salesforce Id
                    if(String.isNotBlank(accountId)){
                        System.debug('UPSERT BY SF ID');
                        acc.Id = accountId;
                    }
                    // Create Client
                    else {
                // SET ownerId if we have the WWEmployeeNumber
                if(String.isNotBlank(employeeNumber)){
                    String owrId = getOwnerId(employeeNumber);
                    if(owrId != null){
                        acc.OwnerId = owrId;   
                    }else{
                        String userId = getOwnerByCountryId(acc.HomeAddressCountryCode__pc); 
                        if(userId != null){
                            acc.OwnerId =  userId; 
                        }
                    }
                }else{
                    String userId = getOwnerByCountryId(acc.HomeAddressCountryCode__pc); 
                    if(userId != null){
                        acc.OwnerId =  userId; 
                    }
                }
                        System.debug('UPSERT NEW ACCOUNT');
                        acc.IsProspect__pc = true;
                        acc.ProspectForDream__c = true;
                        acc.Source__c = 'MyCC';
                    }
                    result = Database.upsert(acc);
                }
                
                if(result.isSuccess()){
                    System.debug('UPSERT Successed');
                    return result.getId();
                }
                else {
                    System.debug('UPSERT Failed');
                    throw new CustomException(result.getErrors()[0].getMessage());
                }
            }
            
            return null;
        }
        
        /*
    *** DESCRIPTION Return Id and Dream Id of the account
    */
        global static String getResponseData(Id accId){
            System.debug('in getResponseData Method');
            Account acc = [SELECT Id, DREAMID__c FROM Account WHERE Id =: accId];
            
            // GET ALL SOCIAL MEDIA IDENTIFIERS
            String query = SM_WS01_SocialMediaIdentifiers_Utils.getDynamicQuery(Label.SM_Query_Type_Social_Media_Identifier, new Map<String,String> { 'client__c' => acc.Id});
            List<Social_Media_Identifier__c> socialMediaIdentifiers = Database.query(query);
            SM_WS01_SocialMediaIdentifiers_Utils.ResponseBody responseBody = new SM_WS01_SocialMediaIdentifiers_Utils.ResponseBody(acc, socialMediaIdentifiers);
            
            return JSON.serialize(responseBody);
        }
        
        /*
    *** DESCRIPTION Get account (prospect/client) according mail/phone and firstName/lastName.
    ***             If many accounts already exist, take the first with the most recent LastTrans__pc and ModifiedDate.
    *** RETURN      The Id of the account
    */
        global static Id getProspect(Account acc){
            System.debug('in getProspect Method');
            List<Account> accounts = [
                SELECT Firstname,  Lastname,  NationalityCountryCode__pc, PersonMobilePhone, MobilePhoneCountryCallingCode__pc, LocalMobilePhone__pc
                FROM Account
                WHERE (FirstName =: acc.Firstname AND 
                       LastName =: acc.Lastname) AND 
                ((PersonEmail != null AND PersonEmail =:acc.PersonEmail)
                 OR (PersonMobilePhone != null AND PersonMobilePhone =:acc.PersonMobilePhone))
                ORDER BY LastTrans__pc, LastModifiedDate DESC
            ];
            
            if(!accounts.isEmpty()){
                return accounts[0].Id;
            } 
            
            return null;
        }
        
        global class CustomException extends Exception {}
        
        //
        //Generated by AdminBooster
        //
        /*
    *** DESCRIPTION Get OwnerId  from WWEmployeeNumber.
    ***  If WWEmployeeNumber is received in the call then retrieve the corresponding user and update the Owner on the account.
    *** RETURN      The Id of the User
    */
        public static String getOwnerId(String wwEmNu){  
            System.debug('Start Retrive the user id');
            List<User> users = [
                SELECT Id
                FROM User
                WHERE isActive = true AND
                WWEmployeeNumber__c =: wwEmNu
                LIMIT 1
            ];
            System.debug('Start Retrive the user id1');
            if(!users.isEmpty()){
                return users[0].Id;
            }
            return null;
        }  
        public static String getOwnerByCountryId(String codeCountry){
            if(String.isNotBlank(codeCountry) && codeCountry != 'null'){
                // RMS Flow control
                List<World_Wide_Technical_User__mdt> ccSettings =[
                    SELECT Country__c ,Country_Iso3Code__c , User_Id__c 
                    FROM World_Wide_Technical_User__mdt  
                ];
                String userId = null;
                String UserOthersId = null;
                System.debug('Start Retrive the user id'+ccSettings.size());
                if(ccSettings.size()>0){
                    for(World_Wide_Technical_User__mdt mt : ccSettings){
                        if(mt.Country__c == 'Others'){
                            UserOthersId = mt.User_Id__c;
                        }else{
                            if(String.isNotBlank(mt.Country_Iso3Code__c) && mt.Country_Iso3Code__c.containsIgnoreCase(codeCountry)){
                                userId = mt.User_Id__c;     
                            }   
                        }
                    }
                    if(userId != null){
                        return userId;  
                    }else{
                        return UserOthersId;
                    }
                }  
            }   
            return null;
        }
        
        public class MYCC_ClientWR {
            
            public String WWEmployeeNumber {get;set;} 
            public MYCC_ClientWR(){}
            
            public MYCC_ClientWR(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'WWEmployeeNumber') {
                                WWEmployeeNumber = parser.getText();
                            } else {
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
            
            public MYCC_ClientWR parse(String json) {
                System.JSONParser parser = System.JSON.createParser(json);
                return new MYCC_ClientWR(parser);
            }
            
            public void consumeObject(System.JSONParser parser) {
                Integer depth = 0;
                do {
                    System.JSONToken curr = parser.getCurrentToken();
                    if (curr == System.JSONToken.START_OBJECT || 
                        curr == System.JSONToken.START_ARRAY) {
                            depth++;
                        } else if (curr == System.JSONToken.END_OBJECT ||
                                   curr == System.JSONToken.END_ARRAY) {
                                       depth--;
                                   }
                } while (depth > 0 && parser.nextToken() != null);
            }
            
        }
    }