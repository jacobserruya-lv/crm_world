public with sharing class Client {
        public String id {get;set;}
        public String owner_id {get;set;}
 
        // LOGIN
        public String login_email {get; set;}
        public String login_email_confirmation {get; set;}
        public String login_mobile_phone {get; set;}
        public String login_calling_code {get; set;}
        public String login_international_mobile_phone {get; set;}
        public String password {get; set;}

        // PERSONAL
        public String title {get; set;}
        public String firstname {get; set;}
        public String lastname {get; set;}
        public String firstname2 {get; set;}
        public String lastname2 {get; set;}
        public String country {get; set;}
        public String primary_country {get; set;}
        public String currency_code {get; set;}

        public String email {get; set;}
        public String mobile_phone {get; set;}
        public String calling_code {get; set;}
        public String international_mobile_phone {get; set;}

        public String privacy_agreement {get; set;}
        public String newsletter_agreement {get; set;}

        public String attached_store {get; set;}
        public String attached_store_code {get; set;}
        public String attached_store_country {get; set;}
        public String store {get; set;}
        public String tech_attached_store_country {get; set;}

        public Client(){}

        /*
        *** DESCRIPTION By default, keep value from Custom Metadata
                        For social mode, fill value according the endoded social_id param
                        For my repairs, use existing account values
        *** RETURN      Bollean
        */
        public Client(Map<String,Map<String,IDENTITY_Registration_Form__mdt>> fields, Map<String,String> social_params, String dispatch_country, Account acc){

            // DEFAULT VALUE 
            password = '';
            title = fields.get('Personal').get('title').Value__c;
            privacy_agreement = fields.get('Personal').get('privacy_agreement').Value__c;
            newsletter_agreement = fields.get('Personal').get('newsletter_agreement').Value__c;
            currency_code = fields.get('Personal').get('currency_code').Value__c;
            country = fields.get('Personal').get('country').Value__c;
            calling_code = fields.get('Personal').get('mobile_phone').Value__c;
            login_calling_code = fields.get('Login').get('mobile_phone').Value__c; 
            

            // DISPATCH COUNTRY CONTEXT
            if(!String.isEmpty(dispatch_country)){
                country = dispatch_country;
                calling_code = dispatch_country;
                login_calling_code = dispatch_country; 
            }

            // SOCIAL LOGIN CONTEXT
            if(social_params != null){
                login_email = social_params.get('email');
                login_email_confirmation = social_params.get('email');
                
                firstname = social_params.get('firstname');
                lastname = social_params.get('lastname');

                email = social_params.get('email');
            }

            // ACTIVATION CONTEXT
            if(acc != null){

                id = acc.Id;

                if(!String.isEmpty(acc.Salutation)) {
                    title = acc.Salutation;
                }
                if(!String.isEmpty(acc.Firstname)) {
                    firstname = acc.Firstname;
                }
                if(!String.isEmpty(acc.Lastname)) { 
                    lastname = acc.Lastname;
                }
                if(!String.isEmpty(acc.FirstName2__pc)) {
                    firstname2 = acc.FirstName2__pc;
                }
                if(!String.isEmpty(acc.LastName2__pc)) {
                    lastname2 = acc.LastName2__pc;
                }
                if(!String.isEmpty(acc.SPO_Country_code__pc)) {
                    List<CountryMapping__mdt> iso2 = [SELECT Iso2Code__c FROM CountryMapping__mdt WHERE Iso3Code__c =: acc.SPO_Country_code__pc];

                    if(!iso2.isEmpty()){
                        country = iso2[0].Iso2Code__c;
                    }
                }
                if(!String.isEmpty(acc.PrimaryCountry__pc)){
                    primary_country = acc.PrimaryCountry__pc;
                }
                if(!String.isEmpty(acc.PersonEmail)) {
                    login_email = acc.PersonEmail;
                    email = acc.PersonEmail; 
                }

                // MOBILE PHONE - If no login phone use the contactability as login phone
                if(String.isEmpty(acc.LoginPhone__pc) && !String.isEmpty(acc.PersonMobilePhone)){
                    acc.LocalLoginPhone__pc = acc.LocalMobilePhone__pc;
                    acc.LoginPhoneCountryCode__pc = acc.MobilePhoneCountryCode__pc;
                    acc.LoginPhone__pc = acc.PersonMobilePhone;
                }

                if(!String.isEmpty(acc.LocalMobilePhone__pc)) {
                    mobile_phone = acc.LocalMobilePhone__pc;
                }
                if(!String.isEmpty(acc.LocalLoginPhone__pc)) {
                    login_mobile_phone = acc.LocalLoginPhone__pc;
                }
                if(!String.isEmpty(acc.MobilePhoneCountryCode__pc)) {
                    calling_code = acc.MobilePhoneCountryCode__pc;
                }  
                if(!String.isEmpty(acc.LoginPhoneCountryCode__pc)) {
                    login_calling_code = acc.LoginPhoneCountryCode__pc;
                } 
                else if(!String.isEmpty(acc.MobilePhoneCountryCode__pc)){
                    login_calling_code = acc.MobilePhoneCountryCode__pc;
                }              
                if(!String.isEmpty(acc.PersonMobilePhone)) {
                    international_mobile_phone = acc.PersonMobilePhone;
                }
                if(!String.isEmpty(acc.LoginPhone__pc)) {
                    login_international_mobile_phone = acc.LoginPhone__pc;
                }

                if(!String.isEmpty(acc.OwnerId)) {
                    owner_id = acc.OwnerId;
                }

                if(!String.isEmpty(acc.AttachedStore__pc)) {
                    attached_store = acc.AttachedStore__pc;
                }
                if(!String.isEmpty(acc.AttachedStoreCode__pc)) {
                    attached_store_code = acc.AttachedStoreCode__pc;
                }
                if(!String.isEmpty(acc.AttachedStoreCountry__pc)) {
                    attached_store_country = acc.AttachedStoreCountry__pc;
                }
                if(!String.isEmpty(acc.Store__pc)) {
                    store = acc.Store__pc;
                }
                if(!String.isEmpty(acc.TECH_AttachedStoreCountry__c)) {
                    tech_attached_store_country = acc.TECH_AttachedStoreCountry__c;
                }

                System.debug('ACCOUNT ACTIVATION: ' + JSON.serialize(acc));
            }
        }        
    }