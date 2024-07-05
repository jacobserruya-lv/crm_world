trigger ExclusiveExperienceTrigger on Exclusive_Experience__c (before insert, after insert) {
    
    // BEFORE INSERT
    if(Trigger.isBefore && Trigger.isInsert){
        
        // ----- CHECK DUPLICATE ----- //

        // Extract 
        Map<String,String> dreamIdsOfferCodes = new Map<String,String>();
        for(Exclusive_Experience__c xxpr : Trigger.new){
            dreamIdsOfferCodes.put(xxpr.Dream_Id__c, xxpr.Offer_Code__c);
        }
        Map<String,String> masterChildDreamMap = new Map<String,String>();
        for(MergedClients__c mc : [ SELECT MasterClient__c, Absorbed_DreamId__c 
                                    FROM MergedClients__c 
                                    WHERE Absorbed_DreamId__c IN :dreamIdsOfferCodes.keySet()]){
            masterChildDreamMap.put(mc.Absorbed_DreamId__c, mc.MasterClient__c);
        }
        
        for(Exclusive_Experience__c xxpr : Trigger.new){            
            if(xxpr.Dream_Id__c != NULL)
            {
                // 1. If DreamId is a merged one (= absorbed), insert XXPR with main DreamId (= master)
                if(masterChildDreamMap.keySet().contains(xxpr.Dream_Id__c))
                {
                    xxpr.Dream_Id__c = masterChildDreamMap.get(xxpr.Dream_Id__c);
                }

                // 2. update external id to prevent Insert of XXPR record with existing combination of DreamID/Offer Code
                xxpr.TECH_UniqueKey__c = xxpr.Dream_Id__c + '-' + xxpr.Offer_Code__c;
            }

            // ----- TEMP WORKAROUND ----- //
            if(xxpr.Offer_Code__c == 'exclu_nba_1_2020.'){
                xxpr.Offer_Code__c = 'exclu_nba_1_2020';
            }            
        }
    }

    // AFTER INSERT
    if(Trigger.isAfter && Trigger.isInsert){

        // ----- CREATE NOTIFICATION ----- // 

        // Extract 
        Map<Id,Exclusive_Experience__c> clientsIdXXPR = new Map<Id,Exclusive_Experience__c>();
        Map<Id,Exclusive_Experience__c> clientsIdXXPR_Email = new Map<Id,Exclusive_Experience__c>();
        Map<Id,Exclusive_Experience__c> clientsIdXXPR_SMS = new Map<Id,Exclusive_Experience__c>();
        List<Id> xxprIDs = new List<Id>();

        for(Exclusive_Experience__c xxpr : Trigger.new){
            clientsIdXXPR.put(xxpr.Account_Id__c, xxpr);
            xxprIDs.add(xxpr.Id);
        }
        List<Exclusive_Experience__c> XXPR_Email_SMS = [SELECT  Id, Account_Id__c, Dream_Id__c, Typology__c, Offer_Code__c, Account_Id__r.HomeAddressCountryCode__pc, Account_Id__r.PersonEmail, Account_Id__r.PersonMobilePhone 
                                                        FROM    Exclusive_Experience__c 
                                                        WHERE   Id IN : xxprIDs
                                                        AND     (Account_Id__r.PersonEmail != null OR (Account_Id__r.PersonMobilePhone != null AND Account_Id__r.HomeAddressCountryCode__pc != null) )];
        for(Exclusive_Experience__c xxpr : XXPR_Email_SMS){
            if(xxpr.Account_Id__r.PersonMobilePhone != null && xxpr.Account_Id__r.HomeAddressCountryCode__pc == 'CHN'){
                clientsIdXXPR_SMS.put(xxpr.Account_Id__c, xxpr);
            }
            else if(xxpr.Account_Id__r.PersonEmail != null){
                clientsIdXXPR_Email.put(xxpr.Account_Id__c, xxpr);
            }
        }
        System.debug('XXPR for EMAILS: '+clientsIdXXPR_Email);
        System.debug('XXPR for SMS: '+clientsIdXXPR_SMS);

        try{
            if(!clientsIdXXPR.isEmpty()){
                
                Map<Id,Account> clientsIdAccount = new Map<Id,Account>([    SELECT Id, SPO_Country_code__pc, AttachedStoreCountry__pc, HomeAddressCountryCode__pc, DreamID__c, Date_Identity__pc, PreferredLanguage__pc, Can_Be_Contacted_By_Email__pc 
                                                                            FROM   Account 
                                                                            WHERE  Id IN: clientsIdXXPR.keySet() 
                                                                            ]);
                Map<String, Map<String,Object>> params = new Map<String, Map<String,Object>>();

                // Get helper data
                Set<String> languages = getLanguages(clientsIdAccount.values());
                System.debug('LANGUAGES: '+languages);
                Set<String> countries = getCountries(clientsIdAccount.values());
                System.debug('COUNTRIES: '+countries);
                Map<String,Map<String,CountryLanguage__c>> countryLanguage = getCountryLanguages(clientsIdAccount.values(), countries, languages);
                System.debug('COUNTRY LANGUAGE: '+countryLanguage);

                // Create EMAIL Notifs
                if(!clientsIdXXPR_Email.isEmpty()){
                    params = getDynamicParams(clientsIdAccount, clientsIdXXPR_Email, countryLanguage);
                    Notification_Sender.send(
                        new Map<String,Object> {
                            'channel' => 'EMAIL MARKETING CLOUD',
                            'application' => 'EXCLUSIVE EXPERIENCE',
                            'scenario' => 1
                        },
                        clientsIdXXPR_Email.keySet(), 
                        params
                    );
                }

                // Create SMS Notifs (only for Chinese Clients)
                /*
                if(!clientsIdXXPR_SMS.isEmpty()){
                    params = getDynamicParams(clientsIdAccount, clientsIdXXPR_SMS, countryLanguage);
                    Notification_Sender.send(
                        new Map<String,Object> {
                            'channel' => 'SMS MARKETING CLOUD',
                            'application' => 'EXCLUSIVE EXPERIENCE',
                            'scenario' => 1
                        },
                        clientsIdXXPR_SMS.keySet(), 
                        params
                    );
                }
                */

                // Update XXPR Record with Long MyLV url
                List<Exclusive_Experience__c> xxprToUpdate = [  SELECT Id, Account_Id__c, Account_Id__r.HomeAddressCountryCode__pc, Account_Id__r.PersonEmail, Account_Id__r.PersonMobilePhone
                                                                FROM Exclusive_Experience__c 
                                                                WHERE Id IN : xxprIDs
                                                                AND     (Account_Id__r.PersonEmail != null OR (Account_Id__r.PersonMobilePhone != null AND Account_Id__r.HomeAddressCountryCode__pc != null) )];                                                      
                for(Exclusive_Experience__c xxpr : xxprToUpdate){
                    String mylv_url_one_to_one = (String)params.get(xxpr.Account_Id__c).get('mylv_url');
                    mylv_url_one_to_one = mylv_url_one_to_one.replace('sender=sfmc', 'sender=ca');
                    xxpr.Mylv_Url_Short__c = mylv_url_one_to_one;

                    /*
                    if(xxpr.Account_Id__r.PersonMobilePhone != null && xxpr.Account_Id__r.HomeAddressCountryCode__pc == 'CHN'){
                        xxpr.Notification__c = 'SMS MARKETING CLOUD';                        
                    }
                    else*/ if(xxpr.Account_Id__r.PersonEmail != null){
                        xxpr.Notification__c = 'EMAIL MARKETING CLOUD';
                    }
                }                                                                
                update xxprToUpdate;                  
            }
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
        }  
    }

    /*******************************************/
    /************** HELPER METHODS *************/
    /*******************************************/

    // GET DYNAMIC PARAMS
    public static Map<String, Map<String,Object>> getDynamicParams(Map<Id,Account> clientsAccount, Map<Id,Exclusive_Experience__c> clientsXXPR, Map<String,Map<String,CountryLanguage__c>> countryLanguage){

        Map<String, Map<String,Object>> params = new Map<String,Map<String,Object>>();
        Map<String, String> paths = IDENTITY_Utils.getPathsForMyLvURL();

        // CREATE PARAMS
        for(String clientId : clientsXXPR.keySet()){

            Account client = clientsAccount.get(clientId);
            params.put(client.Id, new Map<String,Object>());

            if(clientsXXPR.get(client.Id) != null) {
                Exclusive_Experience__c xxpr = clientsXXPR.get(client.Id);

                // MYLV URL                
                String mylv_url;
                Map<String, String> ecommerce = getClientEcommerce(client, countryLanguage); // locale + dispatch country
                System.debug('ECOMMERCE: '+ecommerce);
                if(xxpr.Typology__c == 'NBA MSG Experience'){
                    // TEMP HARD-CODED NBA URL
                    mylv_url = 'https://lvnba.louisvuitton.com/' + ecommerce.get('ecommerce') + '/?cid=' + IDENTITY_UTILS.getEncryptedId(client.Id);
                }
                else{
                    mylv_url = IDENTITY_Utils.getMyLVURL(client, 'mylv', ecommerce.get('ecommerce'), paths, null, new Map<String,String> {'application' => 'Exclusive Experience'});
                    String analyticParams = '&utm_source=newsletter&utm_medium=email&utm_campaign='+xxpr.Offer_Code__c;
                    mylv_url += analyticParams;
                }            
                String dispatchCountry = ecommerce.get('dispatchCountry');
                if(!String.isEmpty(dispatchCountry)){
                    mylv_url = mylv_url+'&dispatchCountry='+dispatchCountry;
                }
                // tracking info
                mylv_url = mylv_url+'&sender=sfmc';

                System.debug('MyLV URL: '+mylv_url);
                params.get(client.Id).put('mylv_url', mylv_url);

                // WHAT ID
                params.get(client.Id).put('what_id', xxpr.Id);

                // MESSAGE ID
                params.get(client.Id).put('message_id',xxpr.Offer_Code__c);

                // DREAM ID
                params.get(client.Id).put('dream_id',xxpr.Dream_Id__c);

                // APPLICATION
                params.get(client.Id).put('application','EXCLUSIVE EXPERIENCE');
            }
        }

        return params;
    }
    
    // GET LANGUAGES
    private static Set<String> getLanguages(List<Account> clients){
        Set<String> languagesISO3 = new Set<String>();
        for(Account acc : clients){
            if(!String.isEmpty(acc.PreferredLanguage__pc)){
                languagesISO3.add(acc.PreferredLanguage__pc);
            }
        }
        return languagesISO3;
    }

    // GET COUNTRIES
    private static Set<String> getCountries(List<Account> clients){
        Set<String> countriesISO3 = new Set<String>();
        for(Account acc : clients){
            // client related store country
            if(!String.isEmpty(acc.AttachedStoreCountry__pc)){
                countriesISO3.add(acc.AttachedStoreCountry__pc);
            }
            // client address country
            else if(!String.isEmpty(acc.HomeAddressCountryCode__pc)){
                countriesISO3.add(acc.HomeAddressCountryCode__pc);
            }
        }
        return countriesISO3;
    }
    
    // GET COUNTRY LANGUAGES
    private static Map<String,Map<String,CountryLanguage__c>> getCountryLanguages(List<Account> clients, Set<String> countriesISO3, Set<String> languagesISO3){

        // Get locale by client preferred language and store country, or default language if no records
        Map<String,Map<String,CountryLanguage__c>> countryLanguage = new Map<String,Map<String,CountryLanguage__c>>();
        for(CountryLanguage__c cl : [   SELECT  ATG_Locale__c, Language__r.Iso3Code__c, Country__r.Iso3Code__c, Default__c, Dispatch_Country__c
                                        FROM    CountryLanguage__c 
                                        WHERE   Country__r.Iso3Code__c IN :countriesISO3
                                        AND     (Language__r.Iso3Code__c IN :languagesISO3 OR Default__c = true)]){
            
            if(countryLanguage.get(cl.Country__r.Iso3Code__c) == null){
                countryLanguage.put(cl.Country__r.Iso3Code__c, new Map<String,CountryLanguage__c>());
            }
            
            if(cl.Default__c){
                System.debug('DEFAULT COUNTRY LANGUAGE: ' + cl);
                countryLanguage.get(cl.Country__r.Iso3Code__c).put('ISDEFAULT', cl);
            }
            else {
                System.debug('COUNTRY LANGUAGE: ' + cl);
                countryLanguage.get(cl.Country__r.Iso3Code__c).put(cl.Language__r.Iso3Code__c.toUpperCase(), cl);
            }
        }
        return countryLanguage;
    }

    // GET ECOMMERCE + DISPATCH COUNTRY
    private static Map<String, String> getClientEcommerce(Account client, Map<String,Map<String,CountryLanguage__c>> countryLanguage){
        
        // by default "eng-e1"
        String ecommerce = IDENTITY_Settings__c.getInstance().Default_Language_Country_Parameter__c;
        String dispatchCountry;
        
        if (countryLanguage != null && !countryLanguage.isEmpty()) {
            String storeCountryISO3   = client.AttachedStoreCountry__pc;
            String clientCountryISO3  = client.HomeAddressCountryCode__pc;
            String searchCountryISO3;

            // if client has a related store => get ecommerce according to store country
            if(storeCountryISO3 != null){
                searchCountryISO3 = storeCountryISO3;    
            }
            // else => get ecommerce according to client country
            else if(storeCountryISO3 == null || (storeCountryISO3 != clientCountryISO3) ){
                searchCountryISO3 = clientCountryISO3;
            }

            if(!String.isEmpty(client.PreferredLanguage__pc) && countryLanguage.get(searchCountryISO3).get(client.PreferredLanguage__pc) != null ){
                ecommerce = countryLanguage.get(searchCountryISO3).get(client.PreferredLanguage__pc).ATG_Locale__c;
                dispatchCountry = countryLanguage.get(searchCountryISO3).get(client.PreferredLanguage__pc).Dispatch_Country__c; 
            }
            else if(countryLanguage.get(searchCountryISO3).get('ISDEFAULT') != null){
                ecommerce = countryLanguage.get(searchCountryISO3).get('ISDEFAULT').ATG_Locale__c;
                dispatchCountry = countryLanguage.get(searchCountryISO3).get('ISDEFAULT').Dispatch_Country__c;
            }
        }        

        return new Map<String,String> {
            'ecommerce' => ecommerce,
            'dispatchCountry' => dispatchCountry
        };
    }
}