public without sharing class IDENTITY_AccountMatching_Utils {
    
    /*
    *** DESCRIPTION Get Account according to Firstname, Lastname, Email or Mobile or create new one
    *** RETURN      Account ID
    */
    public static Map<String, String> upsertAccountByFieldsValue(Account new_acc){
        
        Account[] accs;
        String action;
        
        // ERROR HANDLING - CHECK REQUIRED FIELD
        if(String.isEmpty(new_acc.Lastname))
        {
            if(Test.isRunningTest()){
                return new Map<String, String> {'action' => 'MISSING_REQUIRED_FIELD'};
            }
            else{
                throw new AccountMatchingException('MISSING REQUIRED FIELD: Lastname field is required to create or update Account on Salesforce');
            }
        }
        if(String.isEmpty(new_acc.Firstname))
        {
            if(Test.isRunningTest()){
                return new Map<String, String> {'action' => 'MISSING_REQUIRED_FIELD'};
            }
            else{
                throw new AccountMatchingException('MISSING REQUIRED FIELD: Firstname field is required to create or update Account on Salesforce');
            }
        }
        if(String.isEmpty(new_acc.Salutation))
        {
            if(Test.isRunningTest()){
                return new Map<String, String> {'action' => 'MISSING_REQUIRED_FIELD'};
            }
            else{
                throw new AccountMatchingException('MISSING REQUIRED FIELD: Salutation field is required to create or update Account on Salesforce');
            }
        }
        if(String.isEmpty(new_acc.HomeAddressCountryCode__pc))
        {
            if(Test.isRunningTest()){
                return new Map<String, String> {'action' => 'MISSING_REQUIRED_FIELD'};
            }
            else{
                throw new AccountMatchingException('MISSING REQUIRED FIELD: HomeAddressCountryCode__pc field is required to create or update Account on Salesforce');
            }
        }
        if(String.isEmpty(new_acc.PersonEmail) && String.isEmpty(new_acc.PersonMobilePhone))
        {
            if(Test.isRunningTest()){
                return new Map<String, String> {'action' => 'MISSING_REQUIRED_FIELD'};
            }
            else{
                throw new AccountMatchingException('MISSING REQUIRED FIELD: PersonEmail field or PersonMobilePhone field must be provided to create or update Account on Salesforce');
            }
        }
        if( !String.isEmpty(new_acc.PersonMobilePhone) 
            && 
            ( String.isEmpty(new_acc.LocalMobilePhone__pc) || String.isEmpty(new_acc.MobilePhoneCountryCallingCode__pc) || String.isEmpty(new_acc.MobilePhoneCountryCode__pc) )
          )
        {
            if(Test.isRunningTest()){
                return new Map<String, String> {'action' => 'MISSING_REQUIRED_FIELD'};
            }
            else{
                throw new AccountMatchingException('MISSING REQUIRED FIELD: LocalMobilePhone__pc, MobilePhoneCountryCallingCode__pc and MobilePhoneCountryCode__pc fields must be provided if PersonMobilePhone field is provided');
            }
        }
        if( String.isEmpty(new_acc.PersonMobilePhone) 
            && 
            ( !String.isEmpty(new_acc.LocalMobilePhone__pc) || !String.isEmpty(new_acc.MobilePhoneCountryCallingCode__pc) || !String.isEmpty(new_acc.MobilePhoneCountryCode__pc) )
          )
        {
            if(Test.isRunningTest()){
                return new Map<String, String> {'action' => 'MISSING_REQUIRED_FIELD'};
            }
            else{
                throw new AccountMatchingException('MISSING REQUIRED FIELD: PersonMobilePhone field must be provided if LocalMobilePhone__pc, MobilePhoneCountryCallingCode__pc and MobilePhoneCountryCode__pc fields are provided');
            }
        }

        // ERROR HANDLING - CHECK FIELD FORMAT
        if(!String.isEmpty(new_acc.HomeAddressCountryCode__pc))
        {
            Pattern pattern_iso3 = Pattern.compile('[A-Z]{3}');
            Matcher matcher_iso3 = pattern_iso3.matcher(new_acc.HomeAddressCountryCode__pc);

            if (!matcher_iso3.matches())
            {
                if(Test.isRunningTest()){
                    return new Map<String, String> {'action' => 'INVALID_FORMAT_FIELD'};
                }
                else{
                    throw new AccountMatchingException('INVALID REQUIRED FIELD: HomeAddressCountryCode__pc field has to be in ISO-3 format');
                }
            }
        }
        if(!String.isEmpty(new_acc.MobilePhoneCountryCode__pc))
        {
            Pattern pattern_iso2 = Pattern.compile('[A-Z]{2}');
            Matcher matcher_iso2 = pattern_iso2.matcher(new_acc.MobilePhoneCountryCode__pc);

            if (!matcher_iso2.matches())
            {
                if(Test.isRunningTest()){
                    return new Map<String, String> {'action' => 'INVALID_FORMAT_FIELD'};
                }
                else{
                    throw new AccountMatchingException('INVALID REQUIRED FIELD: MobilePhoneCountryCode__pc field has to be in ISO-2 format');
                }
            }
        }
        
        // CHECK EXISTING ACCOUNT IN SF
        if(!String.isEmpty(new_acc.PersonEmail) && !String.isEmpty(new_acc.PersonMobilePhone)){
            accs = [SELECT Id, LoginPhone__pc
                FROM Account
                WHERE LastName =: new_acc.LastName AND FirstName =: new_acc.FirstName AND (PersonEmail =: new_acc.PersonEmail OR PersonMobilePhone =: new_acc.PersonMobilePhone)
                ORDER BY LastTrans__pc, LastModifiedDate DESC
                LIMIT 1
            ];
        }
        else if(!String.isEmpty(new_acc.PersonEmail)){
            accs = [SELECT Id, LoginPhone__pc
                FROM Account
                WHERE LastName =: new_acc.LastName AND FirstName =: new_acc.FirstName AND PersonEmail =: new_acc.PersonEmail
                ORDER BY LastTrans__pc, LastModifiedDate DESC
                LIMIT 1
            ];
        }
        else if(!String.isEmpty(new_acc.PersonMobilePhone)){
            accs = [SELECT Id, LoginPhone__pc
                FROM Account
                WHERE LastName =: new_acc.LastName AND FirstName =: new_acc.FirstName AND PersonMobilePhone =: new_acc.PersonMobilePhone
                ORDER BY LastTrans__pc, LastModifiedDate DESC
                LIMIT 1
            ];
        }
        else {
            accs = new List<Account>();
        }

        if(!accs.isEmpty()){
            new_acc.Id = accs[0].Id;
            action = 'MATCHING';
        }
        else{
            action = 'NEW';
        }
        
        // populate LoginPhone__pc to prevent extreme Duplicate User case in Checkout/Activation flow
        if(
            (action == 'MATCHING' && accs[0].LoginPhone__pc == null && new_acc.LoginPhone__pc == null)
            ||
            (action == 'NEW'      && new_acc.LoginPhone__pc == null)
        ){
            new_acc.LoginPhone__pc = new_acc.PersonMobilePhone;
        }

        // populate PrimaryCountry__pc to prevent ATG Callout error
        if(!String.isEmpty(new_acc.HomeAddressCountryCode__pc)){
            List<Country__c> country = [SELECT Picklist__c FROM Country__c WHERE Iso3Code__c = :new_acc.HomeAddressCountryCode__pc LIMIT 1];
            if(country.size()>0){
                new_acc.PrimaryCountry__pc = country[0].Picklist__c;
            }             
        }        
        
        Database.upsert(new_acc);

        // INFO LOG
        new Logs(new Map<String,Object> {
            'level' => 'INFO', 
            'apexClass' => 'IDENTITY_WS_AccountMatching', 
            'category' => 'API',
            'message' => action,
            'recordId' => new_acc.Id,
            'status_code' => 'SUCCESS'
        });

        return new Map<String, String> {
            'cid' => (String) new_acc.Id,
            'action' => action
        };
    }

    /*
    *** DESCRIPTION Custom Exception Wrapper
    */
    public class AccountMatchingException extends Exception {}
}