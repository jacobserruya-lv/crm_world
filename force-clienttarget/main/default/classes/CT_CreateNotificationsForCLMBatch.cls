global class CT_CreateNotificationsForCLMBatch implements Database.Batchable<sObject> {
    List<Id> clmIDs = new List<Id>();
    List<String> alreadyNotifiedIds = new List<String>();

    public CT_CreateNotificationsForCLMBatch(List<String> membersIdsList, List<String> alreadyNotified) {
        clmIDs = membersIdsList;
        alreadyNotifiedIds = alreadyNotified;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('clmIDs size: ' + clmIDs.size());
        System.debug('alreadyNotifiedIds size: ' + alreadyNotifiedIds.size());
        string query = 'SELECT ClientList__r.Offer_Code__c, ClientList__r.Typology__c, Client__r.AccountId FROM CLM_CliListMember__c WHERE Id IN :clmIDs AND Client__r.Id NOT IN :alreadyNotifiedIds';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<CLM_CliListMember__c> membersList) {
        System.debug('membersList notif excute: ' + membersList.size());
        Map<Id,CLM_CliListMember__c> clientsListMembers = new Map<Id,CLM_CliListMember__c>();

        for (CLM_CliListMember__c member : membersList) {
            clientsListMembers.put(member.Client__r.AccountId, member);
        }

        try{
            if(!clientsListMembers.isEmpty()){
                Map<Id,Account> clientsIdAccount = new Map<Id,Account>([ SELECT Id, SPO_Country_code__pc, AttachedStoreCountry__pc, HomeAddressCountryCode__pc, DreamID__c, Date_Identity__pc, PreferredLanguage__pc, Can_Be_Contacted_By_Email__pc 
                                                                         FROM Account WHERE Id IN: clientsListMembers.keySet()]);

                                                                         System.debug('clientsIdAccount' + clientsIdAccount);
                Map<String, Map<String,Object>> params = new Map<String, Map<String,Object>>();

                // Get helper data
                Set<String> languages = getLanguages(clientsIdAccount.values());
                Set<String> countries = getCountries(clientsIdAccount.values());
                Map<String,Map<String,CountryLanguage__c>> countryLanguage = getCountryLanguages(clientsIdAccount.values(), countries, languages);

                // Create Notif
                if(!clientsListMembers.isEmpty()){
                    
                    params = getDynamicParams(clientsIdAccount, clientsListMembers, countryLanguage);
                    Notification_Sender.send(
                        new Map<String,Object> {
                            'channel' => 'EMAIL MARKETING CLOUD',
                            'application' => 'EXCLUSIVE EXPERIENCE',
                            'scenario' => 1
                        },
                        clientsListMembers.keySet(),
                        params
                    );
                }                                           
                for(CLM_CliListMember__c member : membersList) {
                    member.MyLV_url__c = (String)params.get(member.Client__r.AccountId).get('mylv_url');
                }                                                                
                update membersList;
                System.debug('memberToUpdate size: ' + membersList.size());
            }
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
        }
    }   
     
    global void finish(Database.BatchableContext BC) {
    }

    public static Map<String, Map<String,Object>> getDynamicParams(Map<Id,Account> clientsAccount, Map<Id,CLM_CliListMember__c> clientsMembers, Map<String,Map<String,CountryLanguage__c>> countryLanguage){

        Map<String, Map<String,Object>> params = new Map<String,Map<String,Object>>();
        Map<String, String> paths = IDENTITY_Utils.getPathsForMyLvURL();

        // CREATE PARAMS
        for(String clientId : clientsMembers.keySet()){
            Account client = clientsAccount.get(clientId);
            String clientMemberId = client.Id;
            CLM_CliListMember__c member = clientsMembers.get(clientMemberId);

            if(clientMemberId != null) {
                params.put(clientMemberId, new Map<String,Object>());            
                String mylv_url;
                Map<String, String> ecommerce = getClientEcommerce(client, countryLanguage); // locale + dispatch country

                String type = member.ClientList__r.Typology__c;
                if(type == 'NBA MSG Experience') {
                    mylv_url = 'https://lvnba.louisvuitton.com/' + ecommerce.get('ecommerce') + '/?cid=' + IDENTITY_UTILS.getEncryptedId(client.Id);
                }
                else{
                    Map<String, Object> others = new Map<String, Object> {'null' => 'null'};
                    Map<String, String> successUrl = new Map<String, String> {'null' => 'null'};
                    String ecommerceStr = ecommerce.get('ecommerce') != null ? ecommerce.get('ecommerce') : '';
                    mylv_url = getMyLVURL(client, 'mylv', ecommerceStr, paths, successUrl, others);
                    String analyticParams = '&utm_source=newsletter&utm_medium=email&utm_campaign='+member.ClientList__r.Offer_Code__c;
                    mylv_url += analyticParams;
                }  
                
                String dispatchCountry = ecommerce != null ? ecommerce.get('dispatchCountry') : '';
                if(!String.isEmpty(dispatchCountry)){
                    mylv_url = mylv_url + '&dispatchCountry=' + dispatchCountry;
                }
                
                params.get(clientMemberId).put('mylv_url', mylv_url);
                params.get(clientMemberId).put('message_id', member.ClientList__r.Offer_Code__c);
               
            }
        }

        return params;
    }
    
    private static Set<String> getLanguages(List<Account> clients){
        Set<String> languagesISO3 = new Set<String>{'ENG'};
        for(Account acc : clients){
            if(!String.isEmpty(acc.PreferredLanguage__pc)){
                languagesISO3.add(acc.PreferredLanguage__pc);
            }
        }
        return languagesISO3;
    }

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

        if(!String.isEmpty(client.PreferredLanguage__pc) && countryLanguage != null && countryLanguage.get(searchCountryISO3) != null && countryLanguage.get(searchCountryISO3).get(client.PreferredLanguage__pc) != null ){
            ecommerce = countryLanguage.get(searchCountryISO3).get(client.PreferredLanguage__pc).ATG_Locale__c;
            dispatchCountry = countryLanguage.get(searchCountryISO3).get(client.PreferredLanguage__pc).Dispatch_Country__c; 
        }
        else if(countryLanguage != null && countryLanguage.get(searchCountryISO3) != null && countryLanguage.get(searchCountryISO3).get('ISDEFAULT') != null){
            ecommerce = countryLanguage.get(searchCountryISO3).get('ISDEFAULT').ATG_Locale__c;
            dispatchCountry = countryLanguage.get(searchCountryISO3).get('ISDEFAULT').Dispatch_Country__c;
        }

        return new Map<String,String> {
            'ecommerce' => ecommerce,
            'dispatchCountry' => dispatchCountry
        };
    }

    public static String getMyLVURL(Account client, String origin, String ecommerce, Map<String, String> paths, Map<String, String> successUrls, Map<String, Object> others) {
        String url = paths.get(ecommerce) != null ? paths.get(ecommerce) : paths.get('ISDEFAULT');
        Boolean isTrustOrigin;
        if (others.get('application') != null) {
            isTrustOrigin = IDENTITY_Utils.isTrustOriginApp(String.valueOf(others.get('application')));
        }

        String encryptedIdWithTrustOrigin;
        try { // Try catch for test class
            encryptedIdWithTrustOrigin = IDENTITY_UTILS.getEncryptedIdWithTrustOrigin(client.Id, isTrustOrigin);
        } catch(Exception e) {
            encryptedIdWithTrustOrigin = '';
        }
        
        url = url.replace('lang-country', ecommerce);
        url = String.isNotEmpty(origin) ? url.replace('origin', origin) : url.replace('origin', 'mylv');
        url = url.replace('AccountId', encryptedIdWithTrustOrigin);
        url = url.replace('DreamId', (client.DreamID__c != null ? client.DreamID__c : ''));

        if (others != null && !others.isEmpty() && others.get('CampaignId') != null ) {
            url = url.replace('CampaignId', String.valueOf(others.get('CampaignId')));
        } else {
            url = url.remove('campaign=CampaignId');
        }
        if (successUrls != null && successUrls.get(ecommerce) != null) {
            String successUrl = successUrls.get(ecommerce) != null ? successUrls.get(ecommerce) : successUrls.get('ISDEFAULT');
            successUrl = successUrl.replace('lang-country', ecommerce);
            successUrl = String.isNotEmpty(origin) ? successUrl.replace('origin', origin) : successUrl.replace('origin', 'mylv');
            url = url.replace('success_url', successUrl);
        } else {
            url = url.remove('&successUrl=success_url');
        }

        return url;
    }
}