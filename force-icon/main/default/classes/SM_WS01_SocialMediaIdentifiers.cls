@RestResource(urlMapping='/SocialMediaIdentifiers/*')
global without sharing class SM_WS01_SocialMediaIdentifiers  {

    static final String ENTREPRISE_CA_BINDING_POST_BODY_KEY = 'enterprise_ca_binding';

    /*
    *** DESCRIPTION Query Social Media Identifiers and Account based on header parameters
                    Returns the first item that match - items are ordered by LastModified Date
    *** RETURN      JSON - Client and related social media identifiers 
    */
    @HttpGet
    global static void get() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        try {
            String service = RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/') + 1);
            System.debug('service'+service);
            if(RestContext.request.requestURI == '/SocialMediaIdentifiers' || RestContext.request.requestURI == '/SocialMediaIdentifiers/'){
                
                SM_WS01_SocialMediaIdentifiers_Utils.ResponseBody responseBody = new SM_WS01_SocialMediaIdentifiers_Utils.ResponseBody();

                String queryType = SM_WS01_SocialMediaIdentifiers_Utils.getQueryType(RestContext.request.params);
                Map<String,String> params = SM_WS01_SocialMediaIdentifiers_Utils.getValidParams(queryType, RestContext.request.params);
                String dynamicQuery = SM_WS01_SocialMediaIdentifiers_Utils.getDynamicQuery(queryType, params);
                // GET SOCIAL MEDIA IDENTIFIER
                if(queryType == Label.SM_Query_Type_Social_Media_Identifier) {
                    List<Social_Media_Identifier__c> socialMediaIdentifiers = Database.query(dynamicQuery);
                    if(!socialMediaIdentifiers.isEmpty()) {
                        if(RestContext.request.params.get('Social_Media_Type__c')?.toLowerCase() == 'lineworks' || RestContext.request.params.get('Social_media_type__c')?.toLowerCase() == 'lineworks'){
                            string getRelatedLineSMIQuery = SM_WS01_SocialMediaIdentifiers_Utils.getDynamicQuery(queryType, new Map<String, String> {'client__c' => socialMediaIdentifiers[0].client__c, 'Social_Media_Type__c' => 'Line'});
                            List<Social_Media_Identifier__c> relatedLineSMI = Database.query(getRelatedLineSMIQuery);
                            List<Social_Media_Identifier__c> responseList = new List <Social_Media_Identifier__c>();
                            responseList.add(socialMediaIdentifiers[0]);
                            if(!relatedLineSMI.isEmpty())
                                responseList.add(relatedLineSMI[0]);
                            responseBody = new SM_WS01_SocialMediaIdentifiers_Utils.ResponseBody(responseList);
                        }
                        else
                            responseBody =  new SM_WS01_SocialMediaIdentifiers_Utils.ResponseBody(socialMediaIdentifiers[0]);
                    }
                }
                // GET CLIENT
                else if(queryType == Label.SM_Query_Type_Client) {
                    List<Account> clients = Database.query(dynamicQuery);

                    if(!clients.isEmpty()) {

                        String dynamicQueryForIdentifiers = SM_WS01_SocialMediaIdentifiers_Utils.getDynamicQuery(Label.SM_Query_Type_Social_Media_Identifier, new Map<String,String> { 'client__c' => clients[0].Id});

                        List<Social_Media_Identifier__c> socialMediaIdentifiers = Database.query(dynamicQueryForIdentifiers);

                        responseBody = new SM_WS01_SocialMediaIdentifiers_Utils.ResponseBody(clients[0], socialMediaIdentifiers); 
                    }
                }

                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(responseBody));
            }
            else if(service == 'GetLineBindingLink'){
                List<Third_Party_Settings__mdt> settings = [select Endpoint__c, Password__c from Third_Party_Settings__mdt where DeveloperName = 'tsunagaru_line_connection'];
                RestRequest req = RestContext.request;
                res.addHeader('Content-Type','application/json');
                res.statusCode = 200;
                String encodedClientId = EncodingUtil.base64Encode(Blob.valueOf(req.params.get('client')));
                String lvmId = req.params.get('lvmId');
                List<User> u;
                if(lvmId != null)
                    u = [SELECT id, DefaultStore__c FROM user WHERE WWEmployeeNumber__c =: lvmId limit 1];
                Http http = new Http();
                if (!settings.isEmpty()) {
                    HttpRequest request = new HttpRequest();
                        string endPoint = settings[0].Endpoint__c;
                        request.setEndpoint(endPoint);
                        request.setHeader('Content-Type', 'application/json');
                        request.setHeader('api-key', settings[0].Password__c);// (published later from each provider)
                        request.setMethod('POST');
                        request.setTimeout(60000);
                        if(!u.isEmpty() && u[0].DefaultStore__c != null)
                            request.setBody('{"social_id" : "'+encodedClientId+'", "channel" : "LINEWORKS", "store" : "'+u[0].DefaultStore__c+'"}');
                        else 
                            request.setBody('{"social_id" : "'+encodedClientId+'", "channel" : "LINEWORKS"}');
                        HttpResponse response = http.send(request);
                        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        res.responseBody = Blob.valueOf(response.getBody());
                    }
            }
        }
        catch(Exception ex) {

            new Logs.ERROR('SM_WS01_SocialMediaIdentifiers', 'API', ex);

            SM_WS01_SocialMediaIdentifiers_Utils.ExceptionBody body = SM_WS01_SocialMediaIdentifiers_Utils.getQueryException(ex.getMessage(), ex.getTypeName());
            res.responseBody = Blob.valueOf(JSON.serialize(body));

            // Functional Error
            if(body.code == '505'){
                res.statusCode = 200;
            }
            // Technical Error
            else {
                res.statusCode = 400;
            }
        }
    }

    /*
    *** DESCRIPTION Upsert social media identifier and client data.
    *** RETURN      JSON - Client and related social media identifiers 
    */
    @HttpPost
    global static void post() {

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        Savepoint sp = Database.setSavepoint();

        try {

            if(RestContext.request.requestBody.size() == 0) {
                throw new CustomException(Label.SM_Missing_Data);
            }

            Map<String,Object> bodyParameters = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            Map<String,String> queryParamters = RestContext.request.params;
            Boolean isEnterpriseSaBinding = queryParamters.get('isEnterpriseSABinding') != null ? true : false;
            system.debug('isEnterpriseSaBinding');
            system.debug(isEnterpriseSaBinding);
            Account client;
            Social_Media_Identifier__c identifier;
            Boolean updateClient = false;


            // PARSING
            if(bodyParameters.get(Label.SM_Query_Type_Client) != null) {
                system.debug('just before parse client');
                client = (Account)RestResource_Utils.parseJSON(bodyParameters.get(Label.SM_Query_Type_Client), Account.class);
                system.debug('just after parse client'+client);
            }
            if(bodyParameters.get(Label.SM_Query_Type_Social_Media_Identifier) != null) {
                system.debug('just before parse identifier');
                identifier = (Social_Media_Identifier__c)RestResource_Utils.parseJSON(bodyParameters.get(Label.SM_Query_Type_Social_Media_Identifier), Social_Media_Identifier__c.class);
                system.debug('just before after identifier');
            }
            
            // UPSERT Client
            if(bodyParameters.get(Label.SM_Query_Type_Client) != null) {
                if (client.Id == null){
                    Account prospect = SM_WS01_SocialMediaIdentifiers_Utils.getProspect(client, identifier);
                    if(prospect != null) {
                        client.Id = prospect.Id;
                    }
                }
                // Salutation
                if(!String.isEmpty(client.Gender__pc)){
                    // For Japan, override the Salutation
                    if(!String.isEmpty(client.HomeAddressCountryCode__pc) && client.HomeAddressCountryCode__pc == 'JPN'){
                        client.Salutation = (client.Gender__pc == 'Female') ? 'SF' : 'SM';
                    }
                    else if(String.isEmpty(client.Salutation)){
                        client.Salutation = (client.Gender__pc == 'Female') ? '03' : '02';
                    }
                }
                client = Identity_Utils.createProspect(client);
                system.debug('client: '+client);
            }

            // UPSERT Social Media Identifier
            if(bodyParameters.get(Label.SM_Query_Type_Social_Media_Identifier) != null) {
                if(bodyParameters.get(Label.SM_Query_Type_Client) != null) {
                    identifier = SM_WS01_SocialMediaIdentifiers_Utils.upsertSocialMediaIdentifier(identifier, client.Id, isEnterpriseSaBinding);
                }
                else {
                    identifier = SM_WS01_SocialMediaIdentifiers_Utils.upsertSocialMediaIdentifier(identifier, null, false);
                }
                // if an enterprise_ca_binding entry exists, create the relationship
                if (bodyParameters.get(ENTREPRISE_CA_BINDING_POST_BODY_KEY) != null && isEnterpriseSaBinding){
                    Map<String, Object> sa_binding = (Map<String, Object>)bodyParameters.get(ENTREPRISE_CA_BINDING_POST_BODY_KEY);
                    Social_Media_Identifier_CA__c sa_smi = new Social_Media_Identifier_CA__c();
                    Map <String, String> employeeFieldMapping = new Map<String, String>{
                        'WECHAT' => 'WWEmployeeNumber__c',
                        'LINEWORKS' => 'WWEmployeeNumber__c'
                    };
                    String employeeField = employeeFieldMapping.get(identifier.Social_Media_Type__c.toUpperCase());
                    if (employeeField != null){
                        String wwEmployeeNumber = (String)sa_binding.get('employeeId');
                        String userQuery = 'SELECT Id FROM User WHERE ' + employeeField + ' = \'' + wwEmployeeNumber + '\' limit 1';
                        List<User> CA = Database.query(userQuery);
                        if(CA.isEmpty()){
                            throw new CustomException(Label.SM_No_records);
                        }
                        sa_smi.CA__c = CA[0].Id;
                        sa_smi.Client_Social_Media_Identifier__c = identifier.Id;
                        sa_smi.TECH_ExternalId__c = CA[0].id + '_' + identifier.Social_Media_Type__c + '_' + identifier.Social_id__c;
                        if (sa_binding.get('status__c') != null){
                            sa_smi.Status__c = (String)sa_binding.get('status__c');
                        }
                        Database.upsert(sa_smi, Social_Media_Identifier_CA__c.Fields.TECH_ExternalId__c);
                    }
                }
            }

            if(client != null){

                // SET CONTACTIBILITY
                // DIS-532 - disable the contactability set according to opt_in fro China (Wechat)
                if(identifier != null && identifier.Opt_In__c != null && identifier.Social_Media_Type__c.toUpperCase() != 'WECHAT'){
                    // If Opt In, update automaticcaly the Contactibility of the client
                    client.BoundToLVLine__c = (identifier.Social_Media_Type__c.toUpperCase() == 'LINE' || identifier.Social_Media_Type__c.toUpperCase() == 'LINETHAI') ? true : false;
					client.BoundToLineWorks__c = identifier.Social_Media_Type__c.toUpperCase() == 'LINEWORKS' ? true : false;
                    
                    if(identifier.Opt_In__c){
                        System.debug('Contactability - opt_in = true');
                        client.Can_Be_Contacted_By_SMS__pc = true;
                    }
                    // If Opt Out, and there is no other social media for this client in Opt In, update automaticcaly the Contactibility of the client
                    else {
                        System.debug('Contactability - opt_in = false');
                        Id clientId = client.Id;
                        Integer count = Database.countQuery('SELECT count() FROM Social_Media_Identifier__c WHERE Client__c =: clientId AND Opt_In__c = true');
                        if(count == 0){
                            client.Can_Be_Contacted_By_SMS__pc = false;
                        }
                    }
                    updateClient = true;
                }
            }


            // SET COUNTRY
            if(client != null && String.isEmpty(client.HomeAddressCountryCode__pc)){

                Tracking_Settings__mdt[] tracking_settings = [SELECT MasterLabel FROM Tracking_Settings__mdt WHERE Value__c =: UserInfo.getUserName()];
                String label = '';
                if(!tracking_settings.isEmpty()){
                    label = tracking_settings[0].MasterLabel;
                }
                if(Test.isRunningTest()){
                    label = 'WeChat';
                }
                if(label != ''){
                    switch on label {
                        when 'Line'{
                            client.HomeAddressCountryCode__pc = 'JPN';
                        }
                        when 'WeChat'{
                            client.HomeAddressCountryCode__pc = 'CHN';
                        }
                        when 'Kakao'{
                            client.HomeAddressCountryCode__pc = 'KOR';
                        }
                        when 'LineThai'{
                            client.HomeAddressCountryCode__pc = 'THA';
                        }
                        when else{
                            client.HomeAddressCountryCode__pc = 'FRA';
                        }
                    }
                    updateClient = true;
                }
            }

            if (client != null && identifier != null && String.isEmpty(client.AttachedStore__pc)){
                // set attached store
                String socialMediaType = SM_WS01_SocialMediaIdentifiers_Utils.getSocialMediaTypeCorrectCase(identifier.Social_Media_Type__c);
                List<Tracking_Settings__mdt> ts = [SELECT RMS_Default_Store__c FROM Tracking_Settings__mdt WHERE MasterLabel =: socialMediaType];
                if (!ts.isEmpty()){
                    client.AttachedStore__pc = String.isBlank(client.AttachedStore__pc) ? ts[0].RMS_Default_Store__c : client.AttachedStore__pc;
                    updateClient = true;
                }
            }
            
            if(updateClient){
                Database.update(client);
            }
            
            // GET CLIENT OBJECT FOR RESPONSE BODY
            if(bodyParameters.get(Label.SM_Query_Type_Social_Media_Identifier) != null && identifier.Client__c != null) {
                client = [SELECT Id, DREAMID__c, Can_Be_Contacted_By_SMS__pc, AttachedStore__pc, HomeAddressCountryCode__pc, BoundToLVLine__c, BoundToLineWorks__c FROM Account WHERE Id =: identifier.Client__c];
            }
            else if (bodyParameters.get(Label.SM_Query_Type_Client) != null) {
                client = [SELECT Id, DREAMID__c, Can_Be_Contacted_By_SMS__pc, AttachedStore__pc, HomeAddressCountryCode__pc, BoundToLVLine__c, BoundToLineWorks__c FROM Account WHERE Id =: client.Id];
            }

            // future function
            if (identifier != null && SM_WS01_SocialMediaIdentifiers_Utils.isSourceAuthorizedForRMSConso(identifier.Miniprogram_Source__c, identifier.Social_Media_Type__c)){
                // check the AttachedStore value
                if (!String.isEmpty(client.AttachedStore__pc)){
                    SO_CreateUpdateRMSCLient_Utils.createAccountIntoRMS_WS_v5(client.Id);
                }
            }

            

            SM_WS01_SocialMediaIdentifiers_Utils.ResponseBody responseBody = new SM_WS01_SocialMediaIdentifiers_Utils.ResponseBody(client);
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(responseBody));
        }
        catch(Exception ex) {

            Database.rollback(sp);
            system.debug(ex.getMessage());

            new Logs.ERROR('SM_WS01_SocialMediaIdentifiers', 'API', ex);

            SM_WS01_SocialMediaIdentifiers_Utils.ExceptionBody body = SM_WS01_SocialMediaIdentifiers_Utils.getUpsertException(ex.getMessage(), ex.getTypeName());
            res.responseBody = Blob.valueOf(JSON.serialize(body));

            // Functional Error
            if(body.code == '505'){
                res.statusCode = 200;
            }
            // Technical Error
            else {
                res.statusCode = 400;
            }
        }
    }

    /*
    *** DESCRIPTION Update social media identifier client field. Client must be existing and match with the values of the body
    *** RETURN      JSON - Client and related social media identifiers 
    */
    @HttpPut
    global static void put() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        Savepoint sp = Database.setSavepoint();

        try {

            if(RestContext.request.requestBody.size() == 0) {
                throw new CustomException(Label.SM_Missing_Data);
            }

            Map<String,Object> bodyParameters = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            Account client;
            Map<String,Object> body_smi;
            Map<String, String> SMI_parameters = new Map<String, String>();
            // PARSING
            if(bodyParameters.get(Label.SM_Query_Type_Client) != null) {
                client = (Account)RestResource_Utils.parseJSON(bodyParameters.get(Label.SM_Query_Type_Client), Account.class);
            }
           if(bodyParameters.get(Label.SM_Query_Type_Social_Media_Identifier) != null){
                body_smi = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(bodyParameters.get(Label.SM_Query_Type_Social_Media_Identifier)));
                for(string key: body_smi.keySet()){
                    SMI_parameters.put(key, String.valueOf(body_smi.get(key)));
                }
           }

            Account prospect = SM_WS01_SocialMediaIdentifiers_Utils.getProspect(client, null);
            system.debug('Prospect: '+ prospect);
            if(prospect == null)
            {
                throw new CustomException(Label.SM_No_records);
            }

            Map<String,String> params = SM_WS01_SocialMediaIdentifiers_Utils.getValidParams(Label.SM_Query_Type_Social_Media_Identifier, SMI_parameters);
            String dynamicQuery = SM_WS01_SocialMediaIdentifiers_Utils.getDynamicQuery(Label.SM_Query_Type_Social_Media_Identifier, params);
            List<Social_Media_Identifier__c> socialMediaIdentifiers = Database.query(dynamicQuery);
            if(socialMediaIdentifiers.size() == 0)
            {
                throw new CustomException(Label.SM_No_records);
            }
            
            socialMediaIdentifiers[0].client__c = prospect.id;
            
            Update socialMediaIdentifiers[0];
            SM_WS01_SocialMediaIdentifiers_Utils.ResponseBody responseBody = new SM_WS01_SocialMediaIdentifiers_Utils.ResponseBody(prospect,socialMediaIdentifiers);
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(responseBody));

        }
        catch(Exception ex){
            Database.rollback(sp);
            system.debug(ex.getMessage());

            new Logs.ERROR('SM_WS01_SocialMediaIdentifiers', 'API', ex);

            SM_WS01_SocialMediaIdentifiers_Utils.ExceptionBody body = SM_WS01_SocialMediaIdentifiers_Utils.getUpsertException(ex.getMessage(), ex.getTypeName());
            res.responseBody = Blob.valueOf(JSON.serialize(body));

        }
    }

    /*
        DESCRIPTION: Delete the social_media_identifier record that match with the provided social_id + social_media_type provided in the body of the request
    */
    @HttpDelete
    global static void unbind() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        try {

            Map<String,String> params = SM_WS01_SocialMediaIdentifiers_Utils.getValidParams(Label.SM_Query_Type_Social_Media_Identifier, RestContext.request.params);
            String dynamicQuery = SM_WS01_SocialMediaIdentifiers_Utils.getDynamicQuery(Label.SM_Query_Type_Social_Media_Identifier, params);
            List<Social_Media_Identifier__c> socialMediaIdentifiers = Database.query(dynamicQuery);
            if(socialMediaIdentifiers.size() == 0)
            {
                throw new CustomException(Label.SM_No_records);
            }

            Delete socialMediaIdentifiers[0];
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('Your account has been unbound');

        }
        catch(Exception ex){
            system.debug(ex.getMessage());

            new Logs.ERROR('SM_WS01_SocialMediaIdentifiers', 'API', ex);

            SM_WS01_SocialMediaIdentifiers_Utils.ExceptionBody body = SM_WS01_SocialMediaIdentifiers_Utils.getUpsertException(ex.getMessage(), ex.getTypeName());
            res.responseBody = Blob.valueOf(JSON.serialize(body));

        }
    }
    global class CustomException extends Exception {}
}