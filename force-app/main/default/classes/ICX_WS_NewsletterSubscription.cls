/*
CreatedDate: Nov 2022
Company: Balink
Author: Naomi Baroghel
Description: Interface Web Sevice to subscribe or unsubscribe client to newsletter
*/
@RestResource(urlMapping='/newsletter/*')
global  with sharing class ICX_WS_NewsletterSubscription {
    // public ICX_WS_NewsletterSubscription() {

    // }

    @HttpPost
    global static void subscribeToNewsletter() {
        try{
                RestRequest req = RestContext.request;
                RestResponse res = RestContext.response;
                String resMessage='';
                String exceptionMessage='';


                String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

    
            switch on service {
                when 'subscribe' {		

                   
                    JSONParser parser = JSON.createParser(req.requestBody.toString());
                    ICX_WS_NewsletterSubscription_Helper.requestBodySubscription reqBody = (ICX_WS_NewsletterSubscription_Helper.requestBodySubscription) parser.readValueAs(ICX_WS_NewsletterSubscription_Helper.requestBodySubscription.class);
    

                    if((String.isNotBlank(reqBody.clientEmail)|| String.isNotBlank(reqBody.clientPhone)))
                    {
                        if(((String.isNotBlank(reqBody.firstName) && String.isNotBlank(reqBody.lastName))||(String.isNotBlank(reqBody.firstName2) && String.isNotBlank(reqBody.lastName2))))
                        {
                            if(String.isNotBlank(reqBody.title))
                            {
                                if(String.isNotBlank(reqBody.countryCode))
                                {
                                    if(String.isNotBlank(reqBody.nationalityCode))
                                    {
                                        if(String.isNotBlank(reqBody.local))
                                        {

                                            
                                            List<Account> clientToUpdate = new List<Account>();
                                            clientToUpdate = getClient(reqBody.rmsId,reqBody.clientEmail, reqBody.clientPhone, reqBody.firstName, reqBody.lastName, reqBody.firstName2, reqBody.lastName2);
                                            String countryCodeIso2 = [SELECT Iso2Code__c FROM CountryMapping__mdt WHERE Iso3Code__c =:reqBody.countryCode AND HasOtherValue__c =:false LIMIT 1]?.Iso2Code__c;//convert iso3 to iso2
                                            Boolean Can_Be_Contacted_By_Email_Old_Value;
                                            Boolean Newsletter_Old_Value; 
                                            if(String.isBlank(countryCodeIso2))
                                            {
                                                countryCodeIso2='US';
                                            }
                                            if(clientToUpdate!= null && clientToUpdate.size()>=1)
                                            {
                                                Can_Be_Contacted_By_Email_Old_Value = clientToUpdate[0].Can_Be_Contacted_By_Email__pc;
                                                Newsletter_Old_Value = clientToUpdate[0].Newsletter__c;
                                                
                                                //update existing client(s)
                                                for (Account currentClient : clientToUpdate) {

                                                    currentClient.Newsletter__c = true;
                                                    currentClient.Can_Be_Contacted_By_Email__pc = true;
                                                currentClient.PersonHasOptedOutOfEmail = false;
                                                
                                            }
                                            update clientToUpdate;
                                            if(Can_Be_Contacted_By_Email_Old_Value != true && (String.isNotBlank(reqBody.clientEmail)))
                                            {
                                                //call marketing cloud to fire an event, then marketing cloud will send an confirmation email to the client
                                                    
                                                String preferredLanguage = String.isNotBlank( clientToUpdate[0].PreferredLanguage__pc)?[SELECT Iso2Code__c FROM CountryMapping__mdt WHERE Iso3Code__c =: clientToUpdate[0].PreferredLanguage__pc AND HasOtherValue__c =:false LIMIT 1]?.Iso2Code__c :'EN';
                                                if(String.isBlank(preferredLanguage))
                                                {
                                                    preferredLanguage = [SELECT Language_Iso2__c FROM Language_Mapping_ATG_SF__mdt WHERE ATG__c =:reqBody.local LIMIT 1]?.Language_Iso2__c;

                                                }
                                                if(String.isBlank(preferredLanguage))
                                                {
                                                    preferredLanguage = 'EN';
                                                }  
                                                MarketingCloudFireEvent(clientToUpdate[0].Id,clientToUpdate[0].PersonContactId, reqBody.clientEmail, reqBody.lastName, reqBody.firstName, reqBody.title, 'NewsLetter', countryCodeIso2, reqBody.local, preferredLanguage, 'false', 'Email', reqBody.clientPhone, IconicsSettings__c.getInstance().Newsletter_URL__c +'/'+ reqBody.local+'/mylv/registration', String.valueOf(Newsletter_Old_Value));
                                                    
                                                    
                                                }
                                                resMessage= 'Successfully updated client(s) and subcribed him(them) to the newsletter' ;

                                                
                                            }            
                                            else if (clientToUpdate!=null && clientToUpdate.size()==0){
                                                //create new client because no matching
                                                Account newClient = createClient(reqBody.rmsId, reqBody.clientEmail,reqBody.clientPhone, reqBody.firstName, reqBody.lastName, reqBody.firstName2, reqBody.lastName2, reqBody.title,reqBody.countryCode,reqBody.nationalityCode, reqBody.local);
                                                
                                                //call marketing cloud
                                                String preferredLanguage = [SELECT Language_Iso2__c FROM Language_Mapping_ATG_SF__mdt WHERE ATG__c =:reqBody.local LIMIT 1]?.Language_Iso2__c;
                                                preferredLanguage = String.isNotBlank(preferredLanguage) ? preferredLanguage :'EN';
                                                
                                                
                                                MarketingCloudFireEvent(newClient.Id,newclient.PersonContactId, reqBody.clientEmail, reqBody.lastName,reqBody.firstName, reqBody.title, 'NewsLetter', countryCodeIso2, reqBody.local, preferredLanguage, 'false', 'Email', reqBody.clientPhone, IconicsSettings__c.getInstance().Newsletter_URL__c +'/'+ reqBody.local+'/mylv/registration', 'false');
                                                
                                                resMessage= 'Successfully create client and subcribed him to the newsletter' ;
                                                res.statusCode = 201;
                                                
                                            }
                                            else{
                                                resMessage='Found 1 or more clients with the same email but not fistName and lastName. No update performed. Client(s) not susbcribed to newsletter.';
                                            } 
                        
                                        }
                                        else 
                                        {

                                            exceptionMessage = 'Missing field \'local\' in request body';
                                            res.addHeader('Content-Type', 'application/json');
                                            res.statusCode = 400;
                                            res.responseBody = Blob.valueOf(JSON.serialize(handleResponse(400,false, 'Bad Request',exceptionMessage)));    
                                            createLog('/subscription', exceptionMessage , req.requestBody.toString(), 'ERROR','400');
                                            
                                            return;
                                        }
                                            
                                        }
                                        else {

                                            exceptionMessage = 'Missing field \'nationalityCode\' in request body';
                                            res.addHeader('Content-Type', 'application/json');
                                            res.statusCode = 400;
                                            res.responseBody = Blob.valueOf(JSON.serialize(handleResponse(400,false, 'Bad Request',exceptionMessage)));    
                                            createLog('/subscription', exceptionMessage , req.requestBody.toString(), 'ERROR','400');
                                            
                                            return;
                                        }
                                    }
                                    else {

                                        exceptionMessage = 'Missing field \'countryCode\' in request body';
                                        res.addHeader('Content-Type', 'application/json');
                                        res.statusCode = 400;
                                        res.responseBody = Blob.valueOf(JSON.serialize(handleResponse(400,false, 'Bad Request',exceptionMessage)));    
                                        createLog('/subscription', exceptionMessage , req.requestBody.toString(), 'ERROR','400');
                                        
                                        return;
                                    }
                                }
                                else {

                                    exceptionMessage = 'Missing field \'title\' in request body';
                                    res.addHeader('Content-Type', 'application/json');
                                    res.statusCode = 400;
                                    res.responseBody = Blob.valueOf(JSON.serialize(handleResponse(400,false, 'Bad Request',exceptionMessage)));    
                                    createLog('/subscription', exceptionMessage , req.requestBody.toString(), 'ERROR','400');
                                    
                                    return;
                                }

                            }
                            else {

                                exceptionMessage = 'Missing fields \'firstName\',\'lastName\' OR \'firstName2\',\'lastName2\' in request body';
                                res.addHeader('Content-Type', 'application/json');
                                res.statusCode = 400;
                                res.responseBody = Blob.valueOf(JSON.serialize(handleResponse(400,false, 'Bad Request',exceptionMessage)));    
                                createLog('/subscription', exceptionMessage , req.requestBody.toString(), 'ERROR','400');
                                
                                return;
                            }
                        }
                    else{
 
            
                      
            
                        exceptionMessage = 'Missing fields \'clientEmail\' OR \'clientPhone\' in request body';
                        res.addHeader('Content-Type', 'application/json');
                        res.statusCode = 400;
                        res.responseBody = Blob.valueOf(JSON.serialize(handleResponse(400,false, 'Bad Request',exceptionMessage)));    
                        createLog('/subscription', exceptionMessage , req.requestBody.toString(), 'ERROR','400');

                        return;               
                    }
                }	
                when else {		  
                  
            
                    exceptionMessage = 'Wrong Endpoint. Did you mean "/subscribe" ?';
                        res.addHeader('Content-Type', 'application/json');
                        res.statusCode = 405;
                        res.responseBody = Blob.valueOf(JSON.serialize(handleResponse(405,false, 'Method Not Allowed',exceptionMessage)));
                        createLog('/subscription', exceptionMessage , req.requestBody.toString(), 'ERROR','405');

                        return;
                    }
            }
    
          
    

            res.addHeader('Content-Type', 'application/json');
            res.statusCode = res.statusCode!=null?res.statusCode:200;
            res.responseBody = Blob.valueOf(JSON.serialize(handleResponse(res.statusCode,true, resMessage,null)));
            createLog('/subscription', resMessage , req.requestBody.toString(), 'INFO',String.valueOf(res.statusCode));


        }
        catch(Exception ex)
        {

           
          
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(handleResponse(400,false, 'Bad Request',ex.getMessage())));
            createLog('/subscription', ex.getMessage() , req.requestBody.toString(), 'ERROR', '400');

        }
      
    }

    @HttpPatch
    global static void unsubscribeFromNewsletter() {

        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String resMessage='';
            String exceptionMessage='';

            String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            switch on service {
                when 'unsubscribe' {	

                    JSONParser parser = JSON.createParser(req.requestBody.toString());
                    ICX_WS_NewsletterSubscription_Helper.requestBodyUnsubscription reqBody = (ICX_WS_NewsletterSubscription_Helper.requestBodyUnsubscription) parser.readValueAs(ICX_WS_NewsletterSubscription_Helper.requestBodyUnsubscription.class);
    
                    if((String.isNotBlank(reqBody.clientEmail) || String.isNotBlank(reqBody.clientPhone)) && String.isNotBlank(reqBody.local))
                    {
                        List<Account> clientToUpdate = new List<Account>();
                        clientToUpdate = getClientEmail(reqBody.clientEmail,reqBody.clientPhone);
                        Boolean Newsletter_Old_Value;
                        if(clientToUpdate.size()>0)
                        {
                            Newsletter_Old_Value = clientToUpdate[0].Newsletter__c; // for future use
                            for (Account currentClient : clientToUpdate) {
                                //update existing client

                            //no need for PersonHasOptedOutOfEmail to be updated
                            currentClient.Newsletter__c = false;
                            currentClient.Can_Be_Contacted_By_Email__pc = false;
                            currentClient.Unsubscribe__pc = true;
                            currentClient.UnsubscribeDate__pc = Date.today();
                            
                        }
                            
                        update clientToUpdate;
                            //for future use
                            // String localLanguageIso2 = [SELECT Language_Iso2__c FROM Language_Mapping_ATG_SF__mdt WHERE ATG__c =:reqBody.local LIMIT 1]?.Language_Iso2__c;
                            // //call marketing cloud for unsubscribe korea
                            // if(localLanguageIso2=='KR' && (String.isNotBlank(reqBody.clientEmail))
                            // {
                                //     String preferedLanguage = String.isNotBlank(clientToUpdate[0].PreferredLanguage__pc)?[SELECT Iso2Code__c FROM CountryMapping__mdt WHERE Iso3Code__c =:clientToUpdate[0].PreferredLanguage__pc LIMIT 1]?.Iso2Code__c :localLanguageIso2;
                                
                                //     MarketingCloudFireEvent(clientToUpdate[0].Id, reqBody.clientEmail, clientToUpdate[0].LastName, clientToUpdate[0].FirstName, clientToUpdate[0].Title__pc, 'NewsLetter_Unsubscribe', 'KR', reqBody.local, preferedLanguage, 'false', 'Email', reqBody.clientPhone, IconicsSettings__c.getInstance().Newsletter_URL__c +'/'+ reqBody.local+'/mylv/registration', String.valueOf(Newsletter_Old_Value));
                                
                                
                                // }
                                resMessage= 'Successfully updated client(s) and unsubcribed him(them) from the newsletter' ;


                        }   
                        else if(clientToUpdate.size()==0)
                        {
                            resMessage='No matching client for this email.';

                        }
                    }
                    else{
 
            
                
                        exceptionMessage= 'Missing clientEmail in request body';
                        res.addHeader('Content-Type', 'application/json');
                        res.statusCode = 400;
                        res.responseBody = Blob.valueOf(JSON.serialize(handleResponse(400,false, 'Bad Request',exceptionMessage)));
                        createLog('/unsubscribe', exceptionMessage , req.requestBody.toString(), 'ERROR', '400');

                        return;               
                    }
                }
                when else {		  
         
        
                    exceptionMessage ='Wrong Endpoint. Did you mean "/unsubscribe" ?';
                    res.addHeader('Content-Type', 'application/json');
                    res.statusCode = 405;
                    res.responseBody = Blob.valueOf(JSON.serialize(handleResponse(405,false, 'Method Not Allowed',exceptionMessage)));
                    createLog('/unsubscribe', exceptionMessage , req.requestBody.toString(), 'ERROR', '405');

                    return;
                }

      
        }
                  


        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(handleResponse(200,true, resMessage,null)));
        createLog('/unsubscribe', resMessage , req.requestBody.toString(), 'INFO', '200');

    }
        catch(Exception ex)
        {

           
          
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(handleResponse(400,false,  'Bad Request', ex.getMessage())));
            createLog('/unsubscribe', ex.getMessage() , req.requestBody.toString(), 'ERROR', '400');

        }


    }

 
 //helper functions


    public static List<Account> getClient(String rmsId, String clientEmail, String clientPhone, String firstName, String lastName, String firstName2, String lastName2) //evol to be done for china with phone
    {
        List<Account> ClientRMS = getClientRMSID(rmsId); // exact matching
        if(ClientRMS.size()>0 && ClientRMS[0]!=null)
        {
            return ClientRMS;
        }
        else{
            List<Account> clientEmailMatching = new List<Account>();
            clientEmailMatching = getClientEmail(clientEmail,clientPhone);
            // clientEmailMatching = [SELECT Id,PersonEmail,FirstName,LastName,Firstname2__pc,Lastname2__pc,Can_Be_Contacted_By_Email__pc,PreferredLanguage__pc,Title__pc,Newsletter__c,HomeAddressCountryCode__pc FROM Account WHERE  PersonEmail =:clientEmail OR PersonMobilePhone=:clientPhone];
            List<Account> clientNameMatching = new List<Account>();
        List<Account> clientName2Matching = new List<Account>();
        if(clientEmailMatching.size()>=1)
        {
            if(String.isNotBlank(firstName) && String.isNotBlank(lastName)) 
            {
                for(Account currentClient : clientEmailMatching)
                {
                    
                  
                    if(currentClient.FirstName == firstName && currentClient.LastName == lastName)
                    {
                        clientNameMatching.add(currentClient);
                    }
                }
                if(clientNameMatching.size()>=1)
                {
                    return clientNameMatching;
                }
            }

            else if(String.isNotBlank(firstName2) && String.isNotBlank(lastName2))
            {
                for(Account currentClient : clientEmailMatching)
                {
                    if(currentClient.FirstName2__pc == firstName2 && currentClient.LastName2__pc == lastName2 && currentclient.HomeAddressCountryCode__pc== 'JPN')
                    {
                        clientName2Matching.add(currentClient);
                    }
                }
                if(clientName2Matching.size()>=1)
                {
                    return clientName2Matching;
                }
            }
            
            return null; //email matching but not first   or last name
        }
        
        
        // return  clientEmailMatching;
        return  new List<Account>(); // no email matching --> create client
    }

        
    }

    public static List<Account> getClientRMSID(String rmsId)
    {
        if(String.isNotBlank(rmsId))
        return [SELECT  Id,PersonContactId,PersonEmail,FirstName,LastName,Firstname2__pc,Lastname2__pc,Can_Be_Contacted_By_Email__pc,PreferredLanguage__pc,Title__pc,Newsletter__c,HomeAddressCountryCode__pc  FROM Account WHERE WW_RMSId__c=: rmsId];
        return new List<Account>();//no rmsId provided
    }

    public static List<Account> getClientEmail(String clientEmail, String clientPhone) //evol to be done for china with phone
    {
        List<Account> clientEmailMatching = new List<Account>();
        if(String.isNotBlank(clientEmail))
        {

            clientEmailMatching = [SELECT Id,PersonContactId,PersonEmail,FirstName,LastName,Firstname2__pc,Lastname2__pc,Can_Be_Contacted_By_Email__pc,PreferredLanguage__pc,Title__pc,Newsletter__c,HomeAddressCountryCode__pc FROM Account WHERE  PersonEmail =:clientEmail];
        }
        else if(String.isNotBlank(clientPhone))
        {
            if (clientPhone.startsWith('00')) {
                clientPhone = '+' + clientPhone.removeStart('00');
            }
            clientEmailMatching = [SELECT Id,PersonContactId,PersonEmail,FirstName,LastName,Firstname2__pc,Lastname2__pc,Can_Be_Contacted_By_Email__pc,PreferredLanguage__pc,Title__pc,Newsletter__c,HomeAddressCountryCode__pc FROM Account WHERE  PersonMobilePhone = :clientPhone OR PersonHomePhone = :clientPhone OR Phone = :clientPhone OR LocalMobilePhone__pc = :clientPhone OR LocalWorkPhone__pc = :clientPhone OR LocalHomePhone__pc = :clientPhone];

        }
        return clientEmailMatching;

    }


    public static Account createClient(String rmsId, String clientEmail,String clientPhone, String firstName, String lastName, String firstName2, String lastName2, String title,String countryCode, String nationalityCode, String local) //evol to be made for phone
    {
          
     


        String countryName;
        String nationalityName;
        String preferredLanguageIso3;

        if(String.isNotBlank(countryCode))
        {
            countryName =  [SELECT Account__c FROM CountryMapping__mdt WHERE Iso3Code__c =:countryCode AND HasOtherValue__c =:false LIMIT 1]?.Account__c;

        }
        if(String.isNotBlank(nationalityCode))
        {
            nationalityName =  [SELECT Nationality__c FROM CountryMapping__mdt WHERE Iso3Code__c =:nationalityCode AND HasOtherValue__c =:false LIMIT 1]?.Nationality__c;

        }
        if(String.isNotBlank(local))
        {
            preferredLanguageIso3= [SELECT Language_Iso3__c FROM Language_Mapping_ATG_SF__mdt WHERE ATG__c =:local LIMIT 1]?.Language_Iso3__c;
        }
        preferredLanguageIso3 = String.isNotBlank(preferredLanguageIso3) ?  preferredLanguageIso3 : 'ENG'; //default
    

        Account newClient = new Account();
        newClient.WW_RMSId__c = rmsId;
        newClient.PersonEmail = clientEmail;
        newClient.FirstName = firstName; 
        newClient.LastName = lastName; 
        newClient.FirstName2__pc = firstName2!=null?firstName2:''; 
        newClient.LastName2__pc = lastName2!=null?lastName2:''; 
        newClient.Salutation = title;
        newClient.HomeAddressCountryCode__pc = countryCode;
        newClient.NationalityCountryCode__pc = nationalityCode;
        newClient.PrimaryCountry__pc=countryName;
        newClient.Nationality__pc = nationalityName;
        newClient.Local__c = local;
        newClient.PreferredLanguage__pc = preferredLanguageIso3;

        if(String.isNotBlank(clientPhone))
        {
            CountryMapping__mdt countryMapping =  [SELECT Calling_Code__c,Iso2Code__c FROM CountryMapping__mdt WHERE Iso3Code__c =:countryCode AND HasOtherValue__c =:false LIMIT 1];

            String localPhone;
            String personPhone;
            if (clientPhone.startsWith('00')) {
                clientPhone = '+' + clientPhone.removeStart('00');
            }
            if(clientPhone.startsWith('+'))
            {
                String currentCountryCode= '+'+String.valueOf(Integer.valueOf(countryMapping.Calling_Code__c));
                localPhone = '0'+clientPhone.removeStart(currentCountryCode);
                personPhone = clientPhone;
            }
            else{

                localPhone = clientPhone;
                personPhone = '+'+String.valueOf(Integer.valueOf(countryMapping.Calling_Code__c))+ clientPhone.removeStart('0');
            }
            newClient.LocalMobilePhone__pc = localPhone;
            newClient.PersonMobilePhone=personPhone;
            newClient.MobilePhoneCountryCallingCode__pc = String.valueOf(Integer.valueOf(countryMapping.Calling_Code__c));  
            newClient.MobilePhoneCountryCode__pc =  countryMapping.Iso2Code__c;
        }

        



        newClient.Source__c = 'Newsletter';
        newClient.Newsletter__c = true;
        newClient.Can_Be_Contacted_By_Email__pc = true;
        newClient.PersonHasOptedOutOfEmail = false;
      

        insert newClient;

        // return newClient;
        List<Account> newClientInserted =[SELECT Id,PersonContactId,PersonEmail,FirstName,LastName,Firstname2__pc,Lastname2__pc,Can_Be_Contacted_By_Email__pc,PreferredLanguage__pc,Title__pc,Newsletter__c,HomeAddressCountryCode__pc FROM Account WHERE  Id =:newClient.Id];
        return      newClientInserted[0]; 




    }

    public static ICX_WS_NewsletterSubscription_Helper.responseClass handleResponse(Integer statusCode, Boolean success, String message, string exceptionMessage)
    {
        ICX_WS_NewsletterSubscription_Helper.responseClass resBody = new ICX_WS_NewsletterSubscription_Helper.responseClass();
        resBody.statusCode = statusCode;
        resBody.success = success;
        resBody.message= message;
        resBody.exceptionMessage = exceptionMessage;
        return resBody;
    }
    
 
    

    public static void MarketingCloudFireEvent(String clientId,String contactId, String clientEmail, String clientLastName, String clientFirstName, String civility, String MessageType, String countryCodeIso2, String local, String preferredLanguageIso2, String hasMyLV, String channel, String clientMobilePhone, String URL, String NewsletterOptIn)
    {
        ICX_WS_NewsletterSubscription_Helper.MarketingCloudRequestBody MarketingCloudRequestBody = new ICX_WS_NewsletterSubscription_Helper.MarketingCloudRequestBody();
        // MarketingCloudRequestBody.contactKey =  clientId;
        MarketingCloudRequestBody.contactKey =  contactId;

        MarketingCloudRequestBody.eventDefinitionKey = IconicsSettings__c.getInstance().MarketingCloudEventDefinitionKey__c;//Newsletter_URL__c
        MarketingCloudRequestBody.data = new ICX_WS_NewsletterSubscription_Helper.data();
        MarketingCloudRequestBody.data.Email = clientEmail;
        MarketingCloudRequestBody.data.SubscriberKey =  contactId;
        MarketingCloudRequestBody.data.Lastname = clientLastName;
        MarketingCloudRequestBody.data.FirstName = clientFirstName;
        MarketingCloudRequestBody.data.Civility = civility;
        MarketingCloudRequestBody.data.MessageType = MessageType;
        MarketingCloudRequestBody.data.CountryCode =countryCodeIso2;
        MarketingCloudRequestBody.data.Language = local;
        MarketingCloudRequestBody.data.PreferredLanguage = preferredLanguageIso2; 
        MarketingCloudRequestBody.data.Channel = channel;
        MarketingCloudRequestBody.data.HasMyLVAccount = hasMyLV;
        MarketingCloudRequestBody.data.TriggeredDate = String.valueOf(Datetime.now().format('yyyy-MM-dd')); 
        MarketingCloudRequestBody.data.EmailAddress = clientEmail;
        MarketingCloudRequestBody.data.MobilePhoneInternational =clientMobilePhone;
        MarketingCloudRequestBody.data.URL=URL;
        MarketingCloudRequestBody.data.NewsLetterOptin=NewsletterOptIn;
        
        MarketingCloudCallOutFireEvent(JSON.serialize(MarketingCloudRequestBody));
    }

    @Future(callout=true)    
    public static void MarketingCloudCallOutFireEvent(String reqBody)
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endPoint = '/cst-eu/services-sfmc/v1/interaction/events';
         request.setEndpoint('callout:MULESOFT_MARKETING_CLOUD' + endPoint);

        request.setMethod('POST');
        request.setTimeout(60000);
        request.setHeader('Encoding','UTF-8');
        request.setHeader('Accept','application/json');
        request.setHeader('Content-Type','application/json');
        
        request.setHeader('client_id', '{!$Credential.UserName}');
        request.setHeader('client_secret', '{!$Credential.Password}');

        request.setBody(reqBody);
        system.debug(' mkt cloud request : ' + request.getBody());
         HttpResponse response = Http.send(request);
         system.debug(' mkt cloud response : ' + response.getBody());

         createLogMarketing(endPoint,response.getBody(),request.getBody(),'INFO',response.getStatus());

    }

    @future
    public static void createLog(String endpoint, String responseBody, String requestBody, String level,String statusCode)
    {

            Logs log  = new Logs(new Map<String,Object> {
            'level' => level, 
            'apexClass' => 'ICX_WS_NewsletterSubscription', 
            'endpoint' => endpoint,
            'request' => requestBody,
            'isFuture' => false, // to insert the log right after the creation
            'response' => responseBody,
            'status_code' => statusCode,
            'details' => responseBody,
            'application' => 'TWIST - ICONICS'
        });


    }

    //need a creation log not in future since the marketing callout is already in future

    public static void createLogMarketing(String endpoint, String responseBody, String requestBody, String level,String statusCode)
    {

            Logs log  = new Logs(new Map<String,Object> {
            'level' => level, 
            'apexClass' => 'ICX_WS_NewsletterSubscription', 
            'endpoint' => endpoint,
            'request' => requestBody,
            'isFuture' => false, // to insert the log right after the creation
            'response' => responseBody,
            'status_code' => statusCode,
            'details' => responseBody,
            'application' => 'TWIST - ICONICS'
        });


    }


}