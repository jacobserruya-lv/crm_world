/**
    Description: Batch to check Distant Care Service status, and send a reminder notification if neccesary
    Created for: ICONICS project
    Create date: 18/08/2021
*/
global class ICX_BatchCareServiceNotifRemainder implements Database.Batchable<sObject>, Schedulable{ 
    //Schedulable method
    global void execute (SchedulableContext SC)
    {
        ICX_BatchCareServiceNotifRemainder bscl = new ICX_BatchCareServiceNotifRemainder();

        Database.executeBatch(bscl, 1000);
    }

    // EMAIL MARKETING CLOUD
    Map<Id,List<CareService__c>> clientRemindValQuatationEmail = new Map<Id,List<CareService__c>>(); 
    Map<Id,List<CareService__c>> clientLastRemindValQuatationEmail = new Map<Id,List<CareService__c>>(); 
    Map<Id,List<CareService__c>> clientRemindSendProdEmail = new Map<Id,List<CareService__c>>(); 
    Map<Id,List<CareService__c>> clientWaitingPaymentReminder1 = new Map<Id,List<CareService__c>>(); 
    Map<Id,List<CareService__c>> clientWaitingPaymentReminder2 = new Map<Id,List<CareService__c>>(); 
    Map<Id,List<CareService__c>> clientWaitingPaymentReminder3 = new Map<Id,List<CareService__c>>(); 
    
    List<CareService__c> careServiceList = new List<CareService__c>();
    Id distantCareRTId;

    global ICX_BatchCareServiceNotifRemainder(){
        distantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByName().get('Distant Care Service').getRecordTypeId();
    }
    
    global database.querylocator start(Database.BatchableContext CD){
        String query = 'SELECT id,RecordTypeId,StoreRetailCode__c,Client__c,Store__c,TransactionId__c,ICONiCS_Status_Detail__c,Current_Status_Age__c, Quotation_sent_date__c, Quotation_expiration_date__c, Shipping_Label_creation_date__c,Shipping_label_expiration_date__c, Shipping_Label_filename__c, Shipping_Label_Base64_code__c,Shipping_Label_Base64_code_suite__c,Shipping_delivery_date__c, Receipt_filename__c,LanguageLocaleKey__c, Receipt_Base64_code__c'+
        ' FROM CareService__c WHERE recordTypeId =: distantCareRTId AND (ICONiCS_Status_Detail__c = \'Preliminary Quote Pending Validation\' OR ICONiCS_Status_Detail__c = \'Preliminary Quote Validated\' OR ICONiCS_Status_Detail__c = \'Waiting for Payment\' OR ICONiCS_Status_Detail__c = \'Payment Initiated\')';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext CD, List<sObject> scope){
        try{
            for(CareService__c cs:(List<CareService__c>)scope){
                system.debug(cs.ICONiCS_Status_Detail__c);
                if(cs.ICONiCS_Status_Detail__c == 'Preliminary Quote Pending Validation' && cs.Quotation_sent_date__c ==Date.today().addDays(-7) ){
                    if(!clientRemindValQuatationEmail.containsKey(cs.Client__c)){
                        clientRemindValQuatationEmail.put(cs.client__c, new List<CareService__c>());
                    }
                    clientRemindValQuatationEmail.get(cs.Client__c).add(cs);
                    careServiceList.add(cs);
                }
                if(cs.ICONiCS_Status_Detail__c == 'Preliminary Quote Pending Validation' && cs.Quotation_sent_date__c ==Date.today().addDays(-21) ){
                    if(!clientLastRemindValQuatationEmail.containsKey(cs.Client__c)){
                        clientLastRemindValQuatationEmail.put(cs.client__c, new List<CareService__c>());
                    }
                    clientLastRemindValQuatationEmail.get(cs.Client__c).add(cs);
                    careServiceList.add(cs);
                }
                if(cs.ICONiCS_Status_Detail__c == 'Preliminary Quote Validated' && cs.Shipping_Label_creation_date__c == Date.today().addDays(-21) ){
                    if(!clientRemindSendProdEmail.containsKey(cs.Client__c)){
                        clientRemindSendProdEmail.put(cs.client__c, new List<CareService__c>());
                    }
                    clientRemindSendProdEmail.get(cs.Client__c).add(cs);
                    careServiceList.add(cs);
                }
                ICX_Repair_Store__mdt repairStore = ICX_Repair_Store__mdt.getInstance(String.valueOf(cs.StoreRetailCode__c));
                if(repairStore != null && repairStore.Integrated_PBL__c){
                    if((cs.ICONiCS_Status_Detail__c == 'Waiting for Payment' || cs.ICONiCS_Status_Detail__c == 'Payment Initiated') && cs.Current_Status_Age__c == 3 ){
                    if(!clientWaitingPaymentReminder1.containsKey(cs.Client__c)){
                        clientWaitingPaymentReminder1.put(cs.client__c, new List<CareService__c>());
                    }
                    clientWaitingPaymentReminder1.get(cs.Client__c).add(cs);
                    careServiceList.add(cs);
                }
                if((cs.ICONiCS_Status_Detail__c == 'Waiting for Payment' || cs.ICONiCS_Status_Detail__c == 'Payment Initiated') && cs.Current_Status_Age__c == 18  ){
                    if(!clientWaitingPaymentReminder2.containsKey(cs.Client__c)){
                        clientWaitingPaymentReminder2.put(cs.client__c, new List<CareService__c>());
                    }
                    clientWaitingPaymentReminder2.get(cs.Client__c).add(cs);
                    careServiceList.add(cs);
                }
                if((cs.ICONiCS_Status_Detail__c == 'Waiting for Payment' || cs.ICONiCS_Status_Detail__c == 'Payment Initiated') && cs.Current_Status_Age__c == 90  ){
                    if(!clientWaitingPaymentReminder3.containsKey(cs.Client__c)){
                        clientWaitingPaymentReminder3.put(cs.client__c, new List<CareService__c>());
                    }
                    clientWaitingPaymentReminder3.get(cs.Client__c).add(cs);
                    careServiceList.add(cs);
                }
              }  
            }

            // GET CLIENTS
            Map<Id,Account> clients = new Map<Id,Account>([SELECT Id, SPO_Country_code__pc, HomeAddressCountryCode__pc, DreamID__c, Date_Identity__pc, PreferredLanguage__pc 
                FROM Account 
                WHERE Id IN: clientRemindValQuatationEmail.keySet()  OR Id IN: clientLastRemindValQuatationEmail.keySet() OR Id IN: clientRemindSendProdEmail.keySet() OR Id IN: clientWaitingPaymentReminder1.keySet()  OR Id IN: clientWaitingPaymentReminder2.keySet()  OR Id IN: clientWaitingPaymentReminder3.keySet()  
            ]);

            // GET COUNTRY DATA
            Map<Id,Store__c> stores = CareService_TriggerHandler.getStores(careServiceList);
            Map<String,String> countriesISO2 = CareService_TriggerHandler.getStoreCountries(stores.values());
            Map<String,Map<String,CountryLanguage__c>> countryLanguage = CareService_TriggerHandler.getCountryLanguages(clients.values(), countriesISO2);
            
            if(!clientRemindValQuatationEmail.isEmpty()){
                Map<String, List<Map<String,Object>>> params = getDynamicParams(clients, clientRemindValQuatationEmail, new Map<String,Object> { 'CampaignId' => 'e_careServiceCreation_content' }, countryLanguage, countriesISO2, stores);
                Notification_Sender.send2(
                    new Map<String,Object> {
                        'application' => 'DISTANT CARE SERVICE',
                        'scenario' => 6,
                        'channel' => 'EMAIL MARKETING CLOUD'
                    },
                    clientRemindValQuatationEmail.keySet(), 
                    params
                );
            }
            if(!clientLastRemindValQuatationEmail.isEmpty()){
                Map<String, List<Map<String,Object>>> params = getDynamicParams(clients, clientLastRemindValQuatationEmail, new Map<String,Object> { 'CampaignId' => 'e_careServiceCreation_content' }, countryLanguage, countriesISO2, stores);
                Notification_Sender.send2(
                    new Map<String,Object> {
                        'application' => 'DISTANT CARE SERVICE',
                        'scenario' => 7,
                        'channel' => 'EMAIL MARKETING CLOUD'
                    },
                    clientLastRemindValQuatationEmail.keySet(), 
                    params
                );
            }
            if(!clientRemindSendProdEmail.isEmpty()){
                Map<String, List<Map<String,Object>>> params = getDynamicParams(clients, clientRemindSendProdEmail, new Map<String,Object> { 'CampaignId' => 'e_careServiceCreation_content' }, countryLanguage, countriesISO2, stores);
                Notification_Sender.send2(
                    new Map<String,Object> {
                        'application' => 'DISTANT CARE SERVICE',
                        'scenario' => 9,
                        'channel' => 'EMAIL MARKETING CLOUD'
                    },
                    clientRemindSendProdEmail.keySet(), 
                    params
                );
            }
            if(!clientWaitingPaymentReminder1.isEmpty()){
                Map<String, List<Map<String,Object>>> params = getDynamicParams(clients, clientWaitingPaymentReminder1, new Map<String,Object> { 'CampaignId' => 'e_careServiceCreation_content' }, countryLanguage, countriesISO2, stores);
                Notification_Sender.send2(	
                    new Map<String,Object> {	
                        'application' => 'DISTANT CARE SERVICE',	
                            'scenario' => 13,	
                            'channel' => 'EMAIL MARKETING CLOUD'	
                            },	
                            clientWaitingPaymentReminder1.keySet(), 	
                    params	
                );
            }
            
            
            if(!clientWaitingPaymentReminder2.isEmpty()){
                Map<String, List<Map<String,Object>>> params = getDynamicParams(clients, clientWaitingPaymentReminder2, new Map<String,Object> { 'CampaignId' => 'e_careServiceCreation_content' }, countryLanguage, countriesISO2, stores);
                Notification_Sender.send2(	
                    new Map<String,Object> {	
                        'application' => 'DISTANT CARE SERVICE',	
                            'scenario' => 14,	
                            'channel' => 'EMAIL MARKETING CLOUD'	
                            },	
                            clientWaitingPaymentReminder2.keySet(), 	
                    params	
                );
            } 

            
            if(!clientWaitingPaymentReminder3.isEmpty()){
                Map<String, List<Map<String,Object>>> params = getDynamicParams(clients, clientWaitingPaymentReminder3, new Map<String,Object> { 'CampaignId' => 'e_careServiceCreation_content' }, countryLanguage, countriesISO2, stores);
                Notification_Sender.send2(	
                    new Map<String,Object> {	
                        'application' => 'DISTANT CARE SERVICE',	
                            'scenario' => 15,	
                            'channel' => 'EMAIL MARKETING CLOUD'	
                            },	
                            clientWaitingPaymentReminder3.keySet(), 	
                    params	
                );
            } 

            
            
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        } 
    }
    global void finish(Database.BatchableContext CD){
    }

    /* HELPER METHODS */

    public static Map<String, List<Map<String,Object>>> getDynamicParams(Map<Id,Account> clients, Map<Id,List<CareService__c>> clientsId, Map<String, Object> others,  Map<String,Map<String,CountryLanguage__c>> countryLanguage, Map<String,String> countriesISO2, Map<Id,Store__c> stores){

        Map<String, List<Map<String,Object>>> params = new Map<String,List<Map<String,Object>>>();
        Map<String, String> paths = IDENTITY_Utils.getPathsForMyLvURL();
        Map<String, Object> paramsMap;

        Set<String> clientLanguageLocalKey = new Set<String>();
        Map<String, String> languageMap = new Map<String, String>();

        List<IDENTITY_Paths__mdt> repairURL = [select value__c FROM IDENTITY_Paths__mdt WHERE DeveloperName = 'LVAPP_URL_Repair'];
        List<IDENTITY_Paths__mdt> repairURLEmail = [select value__c FROM IDENTITY_Paths__mdt WHERE DeveloperName = 'LVAPP_URL_Repair_Email'];
        List<IDENTITY_Paths__mdt> repairURLShort = [select value__c FROM IDENTITY_Paths__mdt WHERE DeveloperName = 'LVAPP_URL_Repair_Short'];

        //get languageLocalKey  - naomi 20/06/2022
        for(String clientId : clientsId.keySet()){
            for(CareService__c care : clientsId.get(clientId)){
                    clientLanguageLocalKey.add(care.LanguageLocaleKey__c);
            }
        }

        for(Language_Mapping_ATG_SF__mdt currentLanguageMap : [SELECT Salesforce__c,ATG__c FROM Language_Mapping_ATG_SF__mdt WHERE Salesforce__c IN:  clientLanguageLocalKey]){
            languageMap.put(currentLanguageMap.Salesforce__c ,currentLanguageMap.ATG__c);
         }


        // CREATE PARAMS
        for(String clientId : clientsId.keySet()){

            Account client = clients.get(clientId);
            params.put(client.Id, new List<Map<String,Object>>());

            if(clientsId.get(client.Id) != null) {
                for(CareService__c care : clientsId.get(client.Id)){
                    System.debug('CARE BATCH:'+care);
                    paramsMap = new Map<String, Object>();
                    // MYLV URL
                    String ecommerce = CareService_TriggerHandler.getATGLocal(client, care.Store__c, countriesISO2, countryLanguage);
                  //  String url = IDENTITY_Utils.getMyLVURL(client, 'mylv', ecommerce, paths, null, others);
                  //  paramsMap.put('mylv_url', url);
                    if(!repairURLEmail.isEmpty()){
                        String email_url = repairURLEmail[0].value__c;
                       // email_url = email_url.replace('lang-country', ecommerce);
                       // email_url = email_url.replace('lang-country', care.LanguageLocaleKey__c);
                        email_url = email_url.replace('lang-country', languageMap.get(care.LanguageLocaleKey__c));

                        paramsMap.put('mylv_url', email_url);
                    }
                    if(!repairURLShort.isEmpty()){
                        paramsMap.put('mylv_url_short', repairURLShort[0].value__c);
                    }
                    

                    // STORE NAME
                    String storeId = care.Store__c;
                    
                    if(storeId!=null){
                    paramsMap.put('store_name', stores.get(storeId).Name);
                    }

                    // WHAT ID
                    paramsMap.put('what_id', care.Id);

                    // CARE NUMBER
                    if(care.TransactionId__c != null && care.ICONiCS_Status_Detail__c != 'Delivered to Client')
                        paramsMap.put('care_number',care.TransactionId__c);

                    Id distantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByName().get('Distant Care Service').getRecordTypeId();
                    if(care.recordTypeId == distantCareRTId){
                        if(storeId!=null){

                        paramsMap.put('store_code',stores.get(storeId).RetailStoreId__c);
                        }
                        paramsMap.put('local', ecommerce);
                        if(!repairURLEmail.isEmpty()){
                            String email_url = repairURLEmail[0].value__c;
                            //email_url = email_url.replace('lang-country', ecommerce);
                           // email_url = email_url.replace('lang-country', care.LanguageLocaleKey__c);
                            email_url = email_url.replace('lang-country', languageMap.get(care.LanguageLocaleKey__c));

                            paramsMap.put('mylv_url', email_url);
                         }
                         if(!repairURLShort.isEmpty()){
                            paramsMap.put('mylv_url_short', repairURLShort[0].value__c);
                        }
                        paramsMap.put('application', 'DISTANT CARE SERVICE');
                    }
                    //QUATATION DATE
                    if(care.ICONiCS_Status_Detail__c == 'Preliminary Quote Pending Validation' && care.Quotation_sent_date__c != null)
                        paramsMap.put('quotation_creationdate',care.Quotation_sent_date__c);
                    
                    //don't need this param anymore for 7    
                    // if(care.ICONiCS_Status_Detail__c == 'Preliminary Quote Pending Validation' && care.Quotation_expiration_date__c != null)
                    //     paramsMap.put('quotation_expirationdate',care.Quotation_expiration_date__c);
                    

                    //PUSH OR EMAIL NOTIFICATION
                    //ORE06 & ORE07
                    if(care.ICONiCS_Status_Detail__c == 'Preliminary Quote Pending Validation'){
                        if(!repairURL.isEmpty()){
                            paramsMap.put('mylv_url_push', repairURL[0].value__c);

                        }
                    }
                    //SHIPPING 
                    if(care.ICONiCS_Status_Detail__c == 'Preliminary Quote Validated'){
                        if(care.Shipping_Label_filename__c != null)
                            paramsMap.put('shipping_label_filename',care.Shipping_Label_filename__c);
                        if(care.Shipping_Label_creation_date__c != null)
                            paramsMap.put('shipping_label_creationdate',care.Shipping_Label_creation_date__c);
                        if(care.Shipping_Label_Base64_code__c != null){                           
                            String fullBase64Code = care.Shipping_Label_Base64_code__c;
                        if(care.Shipping_Label_Base64_code_suite__c != null)
                            fullBase64Code = fullBase64Code + care.Shipping_Label_Base64_code_suite__c;
                            paramsMap.put('shipping_label_base64',fullBase64Code);} 
                        if(care.Receipt_filename__c != null)
                            paramsMap.put('receipt_filename',care.Receipt_filename__c);
                        if(care.Receipt_Base64_code__c != null)
                            paramsMap.put('receipt_base_base64',care.Receipt_Base64_code__c);
                        paramsMap.put('shipping_label_expirationdate',  care.Shipping_Label_creation_date__c + 28);
                    }
                    params.get(client.Id).add(paramsMap);
                }    
            }
        }


        return params;
    }

}