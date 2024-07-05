global without sharing class IDENTITY_Utils {

    /*
    *** DESCRIPTION Create MyLV Account (user and account)
    *** RETURN      User
    */
    global static User createMylvClient(Account client, String password){

        return createMylvClient(client, password, true);
    }

    /*
    *** DESCRIPTION Create MyLV Account (user and account)
    *** RETURN      User
    */
    global static User createMylvClient(Account client, String password, Boolean isPasswordRequired){

         // Required Fields: [FirstName, LastName, Email/Mobile/CallingCode+LocalMobilePhone]
        if( ( (!String.isEmpty(client.LocalLoginPhone__pc) && !String.isEmpty(client.LoginPhoneCallingCode__pc) )  || !String.isEmpty(client.PersonEmail) || !String.isEmpty(client.LoginPhone__pc)) && 
            !String.isEmpty(client.FirstName) && !String.isEmpty(client.LastName)){

            // We don't need password when customer signs up from Kakao
            // TODO: check if this condition doesn't break the login flow
            if(isPasswordRequired == true) {
                // Password Rules
                if(invalidPasswordClientName(client, password)){ // JSI bloc not coverd by unit tests
                    String details = 'REGISTRATION ' + client;
                    
                    new Logs( new Map<String,Object> {
                        'level' => 'INFO', 
                        'apexClass' => 'IDENTITY_Utils',
                        'category' => 'EVENT',
                        'message' => Label.EM_password_too_easy_contains_name,
                        'details' => details,
                        'status_code' => Label.EM_password_too_easy_contains_name
                    });
                }

                if(invalidPassword(client, password)){
                    throw new CustomException(Label.EM_password_too_easy);
                }

                if(passwordTooLong(password)){
                    throw new CustomException(Label.EM_password_too_long);
                }
            }

            // Setup
            client = setupAccount(client);
            
            // Upsert Person Account
            Account prospect = createProspect(client);
            prospect = [
                SELECT Id, PersonContactId
                FROM Account
                WHERE Id =: prospect.Id
            ];

            return createExternalIdentity(client, prospect.PersonContactId, password);
        }
        else {
            throw new CustomException(Label.EM_required_field_missing);
        }
    }

    /*
    *** DESCRIPTION Update MyLV Account (user and account)
    *** RETURN      User
    */
    global static User updateMylvClient(Account client, String userId){

        // Get user
        List<User> identityUser = [
            SELECT Id, Email, MobilePhone, Contact.AccountId, Username
            FROM User 
            WHERE Id =: userId
        ];

        if(identityUser.isEmpty()){
            throw new CustomException(Label.EM_User_Not_Found);
        }
            
        // Set Mobile Phone
        if(!String.isEmpty(client.LocalMobilePhone__pc) && !String.isEmpty(client.MobilePhoneCountryCallingCode__pc)){
            client.PersonMobilePhone = getMobilePhone(client.MobilePhoneCountryCallingCode__pc, client.LocalMobilePhone__pc);
        }

        // Set Login Phone
        if(String.isEmpty(client.LoginPhone__pc) && !String.isEmpty(client.LocalLoginPhone__pc) && !String.isEmpty(client.LoginPhoneCallingCode__pc)){
            client.LoginPhone__pc = getMobilePhone(client.LoginPhoneCallingCode__pc, client.LocalLoginPhone__pc);
        }

        // Set Salutation
        if(!String.isEmpty(client.Salutation)){
            if(!isPickListValue(client.Salutation)){
                client.PersonTitle = client.Salutation;
                client.Salutation = null;
            }
        }

        // Set Country
        if(!String.isEmpty(client.SPO_Country_code__pc)){
            String country = getCountry(client.SPO_Country_code__pc);
            if(!String.isEmpty(country)){
                client.PrimaryCountry__pc = country;
            }
            if(String.isEmpty(client.HomeAddressCountryCode__pc)){
                client.HomeAddressCountryCode__pc = client.SPO_Country_code__pc;
            }
        }

        // Get Account Id
        client.Id = identityUser[0].Contact.AccountId;

        // Update External Identity
        User u = updateExternalIdentity(toUser(client), identityUser[0]);

        // Update Identity Contact 
        willUpdateProspect(JSON.serialize(client));

        return u;
    }
     /*
    *** DESCRIPTION Update Collectible_Wallet__c
    *** RETURN      List of Collectible_Wallet__c
    */
    global static void updateCollectibleWallet(Object walletsOfClient, String clientId){
     
        Set<String> walletToDelete = new Set<String>();
        Set<String> walletToInsert = new Set<String>();
        Set<String> allWallet = new Set<String>();
        List<Collectible_Wallet__c> walletToCollectList = new List<Collectible_Wallet__c>();
        List<Collectible_Wallet__c> walletToDeleteList = new List<Collectible_Wallet__c>();
        List<Collectible_Wallet__c> walletToUpdateList = new List<Collectible_Wallet__c>();
        List<Collectible_Wallet__c> walletToInsertList = new List<Collectible_Wallet__c>();


        Map<String,String> walletMapToUpdate = new Map<String,String>();
        try{
            List<Object> wallets  = (List<Object>) walletsOfClient;
            for(Object wa : wallets){

                Map<String,Object> wallet = (Map<String,Object>) wa;
                String currentValue = String.valueOf(wallet.get('old'));
                String newValue = String.valueOf(wallet.get('new'));
                
                if(String.isnotEmpty(currentValue) && String.isnotEmpty(newValue)){
                    walletMapToUpdate.put(currentValue,newValue);
                }
                else if(String.isnotEmpty(currentValue) && String.isEmpty(newValue) ){
                    walletToDelete.add(currentValue);
                }
                else if(String.isEmpty(currentValue) && String.isnotEmpty(newValue) ){
                    walletToInsert.add(newValue);
                }
            }

            allWallet.addAll(walletMapToUpdate.keySet());
            allWallet.addAll(walletToDelete);
            if(!allWallet.isEmpty()){
                walletToCollectList = [Select Id, Wallet_Id__c FROM Collectible_Wallet__c WHERE Wallet_Id__c IN: allWallet AND Client__c =: clientId];
                for(Collectible_Wallet__c wa : walletToCollectList){
                    if(walletMapToUpdate.containsKey(wa.Wallet_Id__c)){
                        wa.Wallet_Id__c = walletMapToUpdate.get(wa.Wallet_Id__c);
                        walletToUpdateList.add(wa); 
                    }
                    else if(walletToDelete.contains(wa.Wallet_Id__c)){
                        walletToDeleteList.add(wa);
                    }
                } 
            }

            for(String walletId: walletToInsert){
                walletToInsertList.add(new Collectible_Wallet__c(Wallet_Id__c = walletId , Client__c = clientId));
            }
            
            if(!walletToDeleteList.isEmpty()) Database.Delete(walletToDeleteList,false);
            if(!walletToUpdateList.isEmpty()) Database.Update (walletToUpdateList,false);
            if(!walletToInsertList.isEmpty()) Database.Insert (walletToInsertList,false) ;
        }
        catch(Exception e) {
        	System.debug(e.getMessage());
            throw new CustomException(e.getMessage());
        }
    }


    /*
    *** DESCRIPTION Setup Account
    *** RETURN      User
    */
    global static Account setupAccount(Account client){
        // Set Mobile Phone
        if(String.isEmpty(client.PersonMobilePhone) && !String.isEmpty(client.LocalMobilePhone__pc) && !String.isEmpty(client.MobilePhoneCountryCallingCode__pc)){ // TODO bloc not coverd by unit tests
            client.PersonMobilePhone = getMobilePhone(client.MobilePhoneCountryCallingCode__pc, client.LocalMobilePhone__pc);
        }
        
        // Set Login Phone
        if(String.isEmpty(client.LoginPhone__pc) && !String.isEmpty(client.LocalLoginPhone__pc) && !String.isEmpty(client.LoginPhoneCallingCode__pc)){
            client.LoginPhone__pc = getMobilePhone(client.LoginPhoneCallingCode__pc, client.LocalLoginPhone__pc);
        }

        // Set Salutation
        if(!String.isEmpty(client.Salutation)){
            if(!isPickListValue(client.Salutation)){
                client.PersonTitle = client.Salutation;
                client.Salutation = null;
            }
        }

        // Set Country
        if(!String.isEmpty(client.SPO_Country_code__pc)){
            String country = getCountry(client.SPO_Country_code__pc);
            if(!String.isEmpty(country)){
                client.PrimaryCountry__pc = country;
            }
            if(String.isEmpty(client.HomeAddressCountryCode__pc)){
                client.HomeAddressCountryCode__pc = client.SPO_Country_code__pc;
            }
        }

        // Get Person Account
        Account prospect = getProspect(client, false);
        if(prospect != null && client.Id == null) {
            client.Id = prospect.Id;
            
            if(prospect.Can_Be_Contacted_By_Mail__pc){ // TODO bloc not coverd by unit tests
                client.Can_Be_Contacted_By_Mail__pc = prospect.Can_Be_Contacted_By_Mail__pc;
            }
            if(prospect.Can_Be_Contacted_By_Email__pc){ // TODO bloc not coverd by unit tests
                client.Can_Be_Contacted_By_Email__pc = prospect.Can_Be_Contacted_By_Email__pc;
            }
            if(prospect.Can_Be_Contacted_By_Phone__pc){ // TODO bloc not coverd by unit tests
                client.Can_Be_Contacted_By_Phone__pc = prospect.Can_Be_Contacted_By_Phone__pc;
            }
            if(prospect.Can_Be_Contacted_By_SMS__pc){ // TODO bloc not coverd by unit tests
                client.Can_Be_Contacted_By_SMS__pc = prospect.Can_Be_Contacted_By_SMS__pc;
            }
            if(String.isNotBlank(prospect.DreamID__c)){ // TODO bloc not coverd by unit tests
                client.DreamID__c = prospect.DreamID__c;
            }
            if(String.isNotBlank(prospect.OwnerId)){
                client.OwnerId = prospect.OwnerId;
            }
            if(String.isNotBlank(prospect.AttachedStore__pc)){ // TODO bloc not coverd by unit tests
                client.AttachedStore__pc = prospect.AttachedStore__pc;
            }
            if(String.isNotBlank(prospect.AttachedStoreCode__pc)){ // TODO bloc not coverd by unit tests
                client.AttachedStoreCode__pc = prospect.AttachedStoreCode__pc;
            }
            if(String.isNotBlank(prospect.AttachedStoreCountry__pc)){ // TODO bloc not coverd by unit tests
                client.AttachedStoreCountry__pc = prospect.AttachedStoreCountry__pc;
            }
            if(String.isNotBlank(prospect.Store__pc)){ // TODO bloc not coverd by unit tests
                client.Store__pc = prospect.Store__pc;
            }
            if(String.isNotBlank(prospect.TECH_AttachedStoreCountry__c)){ // TODO bloc not coverd by unit tests
                client.TECH_AttachedStoreCountry__c = prospect.TECH_AttachedStoreCountry__c;
            }
            if(String.isNotBlank(prospect.PrimaryCountry__pc)){
                client.PrimaryCountry__pc = prospect.PrimaryCountry__pc;
            }
            if(String.isNotBlank(prospect.SPO_Country_code__pc)){
                client.SPO_Country_code__pc = prospect.SPO_Country_code__pc;
            }
        }

        // For CHINA, auto populate the contactibility phone with login phone as default value
        // Note: if the account already exists and has already a contactibility phone, don't update it
        if( (String.isEmpty(client.PersonMobilePhone) && !String.isEmpty(client.LoginPhone__pc)) &&
            ( (prospect != null && String.isEmpty(prospect.LocalMobilePhone__pc) && String.isEmpty(prospect.PersonMobilePhone))
                || 
                prospect == null) )
        {
                client.PersonMobilePhone = client.LoginPhone__pc;
                client.LocalMobilePhone__pc = client.LocalLoginPhone__pc;
                client.MobilePhoneCountryCallingCode__pc = client.LoginPhoneCallingCode__pc;
                client.MobilePhoneCountryCode__pc = client.LoginPhoneCountryCode__pc;
        }

        return client;
    }

    /*
    *** DESCRIPTION Get account (prospect/client) according mail/phone and firstName/lastName.
    ***             If many accounts already exist, take the first with the most recent LastTrans__pc and ModifiedDate.
    *** RETURN      The account with its PersonContactId
    */
    global static Account getProspect(Account client, Boolean includeIdentity) {

        // MISSING IDENTIFIER
        if(String.isEmpty(client.LoginPhone__pc) && String.isEmpty(client.PersonEmail) && String.isEmpty(client.LastName) && String.isEmpty(client.FirstName)){
            return null;
        }

        List<Account> clients;

        String condition_name = '';
        String condition_identifier = '';
        String condition_identity = '';
        
        // IDENTIFIER
        if(!String.isEmpty(client.PersonEmail) && !String.isEmpty(client.LoginPhone__pc)){
            condition_identifier = ' AND (PersonEmail = \'' +  String.escapeSingleQuotes(client.PersonEmail) + '\' OR LoginPhone__pc = \'' +  String.escapeSingleQuotes(client.LoginPhone__pc) + '\') ';
        }
        else if(!String.isEmpty(client.PersonEmail)){
            condition_identifier = ' AND PersonEmail = \'' +  String.escapeSingleQuotes(client.PersonEmail) + '\'';
        }
        else if(!String.isEmpty(client.LoginPhone__pc)){
            condition_identifier = ' AND LoginPhone__pc = \'' +  String.escapeSingleQuotes(client.LoginPhone__pc)+ '\'';
        }

        // IDENTITY
        if(!includeIdentity){
            condition_identity = ' AND Date_Identity__pc = null ';
        }

        // NAME
        condition_name = ' LastName = \'' + String.escapeSingleQuotes(client.LastName) + '\' AND FirstName = \'' + String.escapeSingleQuotes(client.FirstName) + '\' ';

        String query =  'SELECT Id, PersonContactId, PersonMobilePhone, LocalMobilePhone__pc,' +
                        'PrimaryCountry__pc, SPO_Country_code__pc,' +
                        'Can_Be_Contacted_By_Mail__pc, Can_Be_Contacted_By_Email__pc, Can_Be_Contacted_By_Phone__pc, Can_Be_Contacted_By_SMS__pc, DreamID__c, OwnerId,' +
                        'AttachedStore__pc, AttachedStoreCode__pc, AttachedStoreCountry__pc, Store__pc, TECH_AttachedStoreCountry__c ' +
                        'FROM Account ' +
                        'WHERE ' + condition_name + condition_identifier + condition_identity +
                        'ORDER BY LastTrans__pc, LastModifiedDate DESC';

        System.debug('QUERY: ' + query);
        clients = Database.query(query);

        if(!clients.isEmpty()){
            return clients[0];
        }
        
        return null;
    }
    
    /*
    *** DESCRIPTION Create a new prospect account
    *** RETURN      Account
    */
    global static Account createProspect(Account client) {

        // International mobile phone number
        if(String.isEmpty(client.PersonMobilePhone) && !String.isEmpty(client.MobilePhoneCountryCallingCode__pc) && !String.isEmpty(client.LocalMobilePhone__pc)){
            client.PersonMobilePhone = getMobilePhone(client.MobilePhoneCountryCallingCode__pc, client.LocalMobilePhone__pc);
        }

        // International login phone number
       if(String.isEmpty(client.LoginPhone__pc) && !String.isEmpty(client.LocalLoginPhone__pc) && !String.isEmpty(client.LoginPhoneCallingCode__pc)){ // TODO bloc not coverd by unit tests
            client.LoginPhone__pc = getMobilePhone(client.LoginPhoneCallingCode__pc, client.LocalLoginPhone__pc);
        }

        client.IsProspect__pc = true;
        client.ProspectForDream__c = true;

        if(String.isEmpty(client.OwnerId)){
            // Owner of portal account must have Role - fix it in the case of GUEST USER
            if(UserInfo.getUserId() == IDENTITY_Settings__c.getInstance().Guest_User_Id__c){ // TODO bloc not coverd by unit tests
                client.OwnerId = IDENTITY_Settings__c.getInstance().Integration_User_Id__c;
            }
        }        

        if(client.DREAMID__c != null){ // TODO bloc not coverd by unit tests
            Database.upsert(client, Account.Fields.DREAMID__c, false);
        }
        else {
            Database.upsert(client);
        }
        
        return client;
    }

    /*
    *** DESCRIPTION Update a prospect account
    */
    @future
    global static void willUpdateProspect(String jsonData) {
        try{
            Account acc = (Account)JSON.deserialize(jsonData, Account.Class);
            update acc;
        }
        catch(Exception e) { // TODO bloc not coverd by unit tests
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }

    /*
    *** DESCRIPTION Create a new user without sending email to the user and set its password
    *** RETURN      External User Identity
    */
    global static User createExternalIdentity(Account client, String contactId, String password) {

        CountryLanguage__c locales = getLocales(client.SPO_Country_Code__pc);
        
        User identityUser = new User(

            // Identity Fields
            ProfileId = IDENTITY_Settings__c.getInstance().ProfileId__c,
            ContactId = contactId,

            // Identifier Fields
            Username = getUsername(client.PersonEmail, client.LoginPhone__pc),
            Email = getUsername(client.PersonEmail, client.LoginPhone__pc),
            MobilePhone = client.LoginPhone__pc,
            
            // Contact Fields
            Title = client.PersonTitle,
            LastName = client.LastName,
            FirstName = client.FirstName,
            Alias = getAlias(client.FirstName, client.LastName),

            // Local Fields
            Country__c = client.PrimaryCountry__pc,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = locales.Salesforce_Language__c,
            LocaleSidKey = locales.Salesforce_Locale__c,
            TimeZoneSidKey = 'Europe/Paris'
        );

        // Don't send any welcome email
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = false;
        dlo.EmailHeader.triggerOtherEmail = false;
        identityUser.setOptions(dlo);

        Database.insert(identityUser);
        // Set Password
        if(String.isNotBlank(password)) {
            System.setPassword(identityUser.Id, password);
        }

        return identityUser;
    }

    /*
    *** DESCRIPTION Create a new user without sending email to the user and set its password
    *** RETURN      External User Identity
    */
    global static User updateExternalIdentity(User client, User current_user) {

        client.Id = current_user.Id;

        // Remove Email
        if(client.Email == '' && !String.isEmpty(current_user.MobilePhone)){ // TODO bloc not coverd by unit tests
            client.Email = getUsername(null, current_user.MobilePhone);
            client.Username = getUsername(null, current_user.MobilePhone);
        }
        // Update Email
        else if(client.Email != null) {
            client.Username = client.Email;
        }
        // If the client updates its mobile and doesnt have registered email - its email shoulb be mobile with suffix
        // In this case, update also its email and its username
        else if(!String.isEmpty(client.MobilePhone) && current_user.Email.endsWith(IDENTITY_Settings__c.getInstance().Username_Suffix__c)){
            client.Email = getUsername(null, client.MobilePhone);
            client.Username = getUsername(null, client.MobilePhone);
        }

        //Activate user - added for reset password scenario
        client.IsActive = true;

        Database.update(client);

        return client;
    }

    /*
    *** DESCRIPTION Update password
    *** RETURN true/false
    */
    global static Boolean updatePassword(String userId, String password) {

        if(passwordTooLong(password)){
            throw new CustomException(Label.EM_password_too_long);
         }

        System.setPassword(userId, password);
        return true;
    }    

    /*
    *** DESCRIPTION Create a new account in ATG
    *** RETURN      
    */
    global static void createATGClient(Account client, String lang_country, String userId) {
        ATG_API.createMyLVClient(client, lang_country, userId);
    }

    /*
    *** DESCRIPTION Create a new account in Russian Server
    *** RETURN callout response      
    */
    global static Map<String, String> createRussianClient(Account client) { // TODO method not coverd by unit tests
        
        Map<String, String> russianClient = new Map<String, String>();
        russianClient = toRussianClient(client);
        string body = JSON.serialize(russianClient);

        System.debug('CREATE RUSSIAN CLIENT');
        System.debug('ACCOUNT: '+client);
        System.debug('RUSSIAN MAP: '+russianClient);
        System.debug('JSON BODY: '+body);
        
        Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:EAI/ws/RussiaCompliance_API/1.0/rdc/account');
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		// Set the body as a JSON object
		request.setBody(body);
		HttpResponse response = http.send(request);
		System.debug('response');
		// Parse the JSON response
		if (response.getStatusCode() != 200) {
			System.debug('The status code returned was not expected: ' +
				response.getStatusCode() + ' ' + response.getStatus());
		} else {
			System.debug(response.getBody());
		}

		return new Map<String,String> {
            'StatusCode' 	=> String.valueOf(response.getStatusCode()),
			'Status' 		=> response.getStatus(),
			'Body' 			=> response.getBody()
        };
    }

    /*
    *** DESCRIPTION Map SF Account fields to Russian Account fields
    *** RETURN      Map      
    */
    global static Map<String, String> toRussianClient(Account client) {
        
        return new Map<String,String> {
            'email' 	                => client.PersonEmail,
			'lastName' 		            => client.Lastname,
			'firstName' 			    => client.Firstname,
            'title'                     => client.Salutation,
            'country'                   => 'RU',
            'subscribedInNewsletter'    => client.Can_Be_Contacted_By_Email__pc != null ? 'true' : 'false',
            'isActive'                  => 'true',
            'contactableByMail'         => client.Can_Be_Contacted_By_Email__pc != null ? 'true' : 'false',
            'contactableByPhone'        => 'false',
            'contactableBySms'          => 'false'
        };
    }


    /*
    *** DESCRIPTION Return TRUE if password doesn't respect password policies
    *** RETURN      Boolean 
    */
    global static Boolean invalidPassword(Account client, String password) {
        
        // VALID PASSWORD
        if(hasEightOrMoreCharacters(password) && hasUpperCharacter(password) && hasLowerCharacter(password) && hasNumberCharacter(password) && hasSpecialCharacter(password)){
           return false;
        }

        return true;
    }

    /*
    *** DESCRIPTION Return TRUE if password too long
    *** RETURN      Boolean 
    */
    global static Boolean passwordTooLong(String password) {
        
        if(password.length() > Integer.valueOf(IDENTITY_Settings__c.getInstance().Password_Maxlength__c)){
            return true;
        }
        return false;
    }
    
    /*
    *** DESCRIPTION Return TRUE if password contains Client name
    *** RETURN      Boolean 
    */
    global static Boolean invalidPasswordClientName(Account client, String password) {
        
        // NOT INCLUDE FIRSTNAME
        if(!string.isEmpty(client.FirstName) && password.contains(client.FirstName)){
            return true;
        }
        
        // NOT INCLUDE LASTNAME
        if(password.contains(client.Lastname)){
            return true;
        }

        // NOT INCLUDE MOBILE PHONE
        if(!string.isEmpty(client.LoginPhone__pc) && password.contains(client.LoginPhone__pc)){
            return true;
        }
       
        // NOT INCLUDE EMAIL
        if(!string.isEmpty(client.PersonEmail) && (password.contains(client.PersonEmail) || containsPrefixEmail(client.PersonEmail, password))){
            return true;
        }
        
        return false;
    }

    /*
    *** DESCRIPTION RULE 1
    *** RETURN      Boolean
    */
    private static Boolean containsPrefixEmail(String email,string password) {
        if(password.contains(email.split('@')[0])) {
            return true;
        }
        return false;
    }

    /*
    *** DESCRIPTION RULE 2
    *** RETURN      Boolean
    */
    private static Boolean hasEightOrMoreCharacters(String password) {
        if(password.length() >= 8){
            return true;
        }
        return false;
    }

    /*
    *** DESCRIPTION RULE 3
    *** RETURN      Boolean 
    */
    private static Boolean hasUpperCharacter(String password) {
        Matcher matcher = Pattern.compile('(?=.*[A-Z])').matcher(password);
        return matcher.find();
    }

    /*
    *** DESCRIPTION RULE 4
    *** RETURN      Boolean 
    */
    private static Boolean hasLowerCharacter(String password) {
        Matcher matcher = Pattern.compile('(?=.*[a-z])').matcher(password);
        return matcher.find();
    }

    /*
    *** DESCRIPTION RULE 5
    *** RETURN      Boolean 
    */
    private static Boolean hasNumberCharacter(String password) {
        Matcher matcher = Pattern.compile('(?=.*[0-9])').matcher(password);
        return matcher.find();
    }

    /*
    *** DESCRIPTION RULE 6
    *** RETURN      Boolean 
    */
    private static Boolean hasSpecialCharacter(String password) {
        Matcher matcher = Pattern.compile('(?=.*[!#$&()*+,\\-.:;<=>?@\\[\\]^_{|}~])').matcher(password);
        return matcher.find();
    }

    /*
    *** DESCRIPTION Set username field (= Administrative field that defines the user's login. Up to 80 characters are allowed in this field. Email Format required)
    ***             The email of the client if there is one. If not, used the phone number + fix domaine ("@louisvuitton.com").
    *** RETURN      Username (String)
    */
    public static String getUsername(String email, String mobile) {
        if(!String.isEmpty(email)) {
            return email;
        }

        return mobile + IDENTITY_Settings__c.getInstance().Username_Suffix__c;
    }

    /*
    *** DESCRIPTION Get User by username (or mobile or email)
    *** RETURN      User
    */
    public static User getUserByUsername(String username) {

        System.debug('Username:' + username);

        List<User> users = new List<User>();
        if(!String.isEmpty(username)){
            users = [SELECT Id, Username, AccountId, IsActive 
                    FROM User 
                    WHERE (TECH_MobilePHone__c =: username OR Username =: username OR TECH_Email__c =: username) AND (IsActive = true OR IsActive = false) AND Is_Identity_User__c = true ];
                }

        if(!users.isEmpty()){
            User user = users[0];
            if(!user.IsActive){ // TODO bloc not coverd by unit tests
                IDENTITY_UTILS.activeUser(user.Id);
            }
            return user;
        }

        return null;
    }

    /*
    *** DESCRIPTION Set alias field (= Short name to identify the user on SF pages. Up to 8 characters are allowed in this field)
    ***             By default, the fisrt letter of the first name + three letters of the last name
    *** RETURN      Alias (String)
    */
    public static String getAlias(String firstName, String lastName) {

        String alias = '';

        if(firstName != null) {
            alias += firstName.substring(0,1);
        }
        if(lastName != null) {
            if(lastName.length() > 3) {
                alias += lastName.substring(0,3);
            }
            else {
                alias += lastName;
            }
        }

        return alias;
    }

    /*
    *** DESCRIPTION Set alias field (= Short name to identify the user on SF pages. Up to 8 characters are allowed in this field)
    ***             By default, the fisrt letter of the first name + three letters of the last name
    *** RETURN      Alias (String)
    */
    public static String getCountry(String iso3) {

        List<CountryMapping__mdt> country_format = [SELECT Account__c
            FROM CountryMapping__mdt
            WHERE Account__c != null AND Iso3Code__c =: iso3];

        if(!country_format.isEmpty()){
            return country_format[0].Account__c;
        }

        return null; // TODO line not coverd by unit tests
    }

    /*
    *** DESCRIPTION Set alias field (= Short name to identify the user on SF pages. Up to 8 characters are allowed in this field)
    ***             By default, the fisrt letter of the first name + three letters of the last name
    *** RETURN      Alias (String)
    */
    public static CountryLanguage__c getLocales(String iso3) {

        if(String.isNotEmpty(iso3)){
            List<CountryLanguage__c> countries = [SELECT Salesforce_Locale__c, Salesforce_Language__c
                                                    FROM CountryLanguage__c
                                                    WHERE Country__r.ISO3Code__c = :iso3 AND Default__c = true 
                                                            AND Salesforce_Locale__c != null AND Salesforce_Language__c != null];

            if(!countries.isEmpty()){ // TODO bloc not coverd by unit tests
                return countries[0];
            }
        }
    

        // DEFAULT VALUE
        return new CountryLanguage__c(Salesforce_Locale__c = 'fr', Salesforce_Language__c = 'fr');
    }

    /*
    *** DESCRIPTION Set internaional mobile phone field.
    *** RETURN      Mobile Phone (String)
    */
    public static String getMobilePhone(String countryCode, String phone) {
        String mobile = System.UserManagement.formatPhoneNumber(countryCode, phone);
        mobile = mobile.deleteWhitespace();
        return mobile;
    }

    /*
    *** DESCRIPTION Check if Salutation Value is a correct value from the picklist
                    If not, don't populate it, but PersonTitle instead
    *** RETURN      Mobile Phone (String)
    */
    public static Boolean isPickListValue(String value){
        Set<String> values = new Set<String>();
        for(Schema.PicklistEntry pickListVal : Account.Salutation.getDescribe().getPicklistValues()){
            values.add(pickListVal.getValue());
        }
        return values.contains(value);
    }

    /*
    *** DESCRIPTION Convert account fields to user fields
    *** RETURN      User
    */
    public static User toUser(Account acc) {

        Map<String,Object> account_data = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(acc));
        User new_user = (User)Schema.getGlobalDescribe().get('User').newSObject() ;

        for(String field : account_data.keySet()){
            if(mappingProspectUser.get(field) != null && account_data.get(field) != null){
                new_user.put(mappingProspectUser.get(field), account_data.get(field));
                if(field == 'PrimaryCountry__pc'){
                    CountryLanguage__c locales = getLocales(acc.SPO_Country_Code__pc);
                    new_user.put('LocaleSidKey', locales.Salesforce_Locale__c);
                    new_user.put('LanguageLocaleKey', locales.Salesforce_Language__c);
                }
            }
        }

        return new_user;
    }

    /*
    *** DESCRIPTION Convert ATG parameters to Account 
    *** RETURN      Account
    */
    public static Account toAccount(Map<string,Object> params) {

        Account new_account = (Account)Schema.getGlobalDescribe().get('Account').newSObject();
        Set<String> account_fields = Schema.SObjectType.Account.fields.getMap().keySet();

        // Create Account thanks to ATG MAPPING
        for(String field : params.keySet()){
            if(mappingATGAccount.get(field) != null){
                new_account.put(mappingATGAccount.get(field), (String)params.get(field));
            }
        }
    
        // Create Account thanks to STANDARD MAPPING
        Account new_account_2 =  (Account)RestResource_Utils.createObject(params, 'Account', new_account);

        return new_account_2;
    }

        /*
    *** DESCRIPTION Convert Account to ATG parameters 
    *** RETURN      Account
    */
    public static Map<String,Object> toATGParameters(SObject account) {
        Map<String,Object> params = new Map<String,Object>();
        String iso2;

        // GET ISO2 COUNTRY BASED ON ISO 3
        if(account.get('SPO_Country_code__pc') != null){
            String country = (String)account.get('SPO_Country_code__pc');
            List<CountryMapping__mdt> countries = [SELECT Iso2Code__c FROM CountryMapping__mdt WHERE Iso3Code__c =: country AND Iso2Code__c != null];
            if(!countries.isEmpty()){
                iso2 = countries[0].Iso2Code__c;
            }
        }
        // GET ISO2 COUNTRY BASED ON COUNTRY LABEL
        if(String.isEmpty(iso2) && account.get(mappingATGAccount.get('country')) != null){ // TODO: bloc not covered by unit tests
            String country = (String)account.get(mappingATGAccount.get('country'));
            List<CountryMapping__mdt> countries = [SELECT Iso2Code__c FROM CountryMapping__mdt WHERE Account__c =: country AND Iso2Code__c != null];
            if(!countries.isEmpty()){
                iso2 = countries[0].Iso2Code__c;
            }
        } 

        for(String field : mappingATGAccount.keySet()){
            if(field == 'country'){
                if(iso2 != null){
                    params.put(field, iso2);
                }
            }
            else if(account.get(mappingATGAccount.get(field)) != null){
                params.put(field, account.get(mappingATGAccount.get(field)));
            }
        }

        if(isAllFieldsFilled(mappingBirthdateATGAccount, account)){
            for(String field : mappingBirthdateATGAccount.keySet()){
                params.put(field, account.get(mappingBirthdateATGAccount.get(field)));
            }
        }

        if(isAllFieldsFilled(mappingAddressPhoneATGAccount, account)){
            for(String field : mappingAddressPhoneATGAccount.keySet()){
                params.put(field, account.get(mappingAddressPhoneATGAccount.get(field)));
            }
        }

        // GET SOCIAL MEDIA STATUS
        if(String.isNotEmpty(account.Id)){
            List<Social_Media_Identifier__c> smis = [SELECT Opt_In__c, Social_Media_Type__c 
                                                        FROM Social_Media_Identifier__c 
                                                        WHERE Client__c =: account.Id AND Social_Media_Type__c IN: SOCIAL_TYPE];
            for(Social_Media_Identifier__c smi : smis){ // TODO bloc not coverd by unit tests
                params.put('socialOptIn' + smi.Social_Media_Type__c, smi.Opt_In__c);
            }    
        }
        

        // DEFAULT TITLE
        if(params.get('title') == null){ // TODO bloc not coverd by unit tests
            params.put('title', '02');
        }

        return params;
    }


    global static Boolean isAllFieldsFilled(Map<String,String> mapFields, SObject account){
        for(String field : mapFields.keySet()){
            if(account.get(mapFields.get(field)) == null){
                return false;
            }
        }
        return true;
    }

    /*
    *** DESCRIPTION Get Paths 
    *** RETURN      
    */
    public static Map<String,String> getPaths(String lang_country, String origin, String dispatch_country){
        Map<String,String> paths = new Map<String,String>();

        // GET ALL PATHS
        for(IDENTITY_Paths__mdt path : [SELECT Name__c, Value__c, Context__c, Application__c 
                                        FROM IDENTITY_Paths__mdt 
                                        WHERE (Context__c =: lang_country OR Context__c = null) AND 
                                            (Application__c =: origin OR Application__c = null) 
                                        ORDER BY Application__c, Context__c ASC NULLS FIRST]){

            String value = path.Value__c;
            value = value.replace('lang_country', lang_country);
            value = value.replace('origin', origin);

            if(!String.isEmpty(dispatch_country)){
                value = value.replaceAll('\\[dispatchCountry=dispatch_country\\]', 'dispatchCountry=dispatch_country');
                value = value.replace('dispatch_country', dispatch_country);
            }
            else {
                value = value.replaceAll('&\\[dispatchCountry=dispatch_country\\]', '');
                value = value.replaceAll('\\[dispatchCountry=dispatch_country\\]', '');
            }

            paths.put(path.Name__c, value);
        }

        return paths;
    }

    /*
    *** DESCRIPTION Login with JWT method
    *** RETURN      PageReference   To redirect_uri with access token as param 
    */
    public static PageReference loginJWTMethod(String username, String redirect_uri, Map<String,String> params) { // TODO: method not covered by unit tests
        
        // checkout process
        redirect_uri = redirect_uri.replace('checkout/overview', 'mylv/overview');

        String token = IDENTITY_Utils.getJWTAccessToken(username);
        
        PageReference redirectPage = new PageReference(redirect_uri);
        redirectPage.getParameters().put('access_token', token);

        for(String key : params.keySet()){
            redirectPage.getParameters().put(key, params.get(key));
        }

        System.debug('loginJWTMethod() - redirect URL: ' + redirectPage);

        return redirectPage;
    }

    /*
    *** DESCRIPTION Get Access Token from JWT 
    *** RETURN      Access token
    */
    public static String getJWTAccessToken(String username) {

        Auth.JWT jwt = new Auth.JWT();
        jwt.setIss(IDENTITY_Settings__c.getInstance().Client_Id__c);
        jwt.setSub(username);
        jwt.setAud(IDENTITY_Settings__c.getInstance().Community_URL__c);
        
        Auth.JWS jws = new Auth.JWS(jwt, 'Identity');

        String token = IDENTITY_Settings__c.getInstance().Community_URL__c + '/services/oauth2/token';

        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(token, jws);

        String accessToken = bearer.getAccessToken();
        
        return accessToken;
    }

    /*
    *** DESCRIPTION Login with Oauth User Agent 
    *** RETURN      PageReference   To redirect_uri with access token as param 
    */
    public static PageReference loginOauthUserAgentMethod(String username, String password, String redirect_uri, String origin) {
        
        // checkout process
        redirect_uri = redirect_uri.replace('checkout/overview', 'lvapp/overview');

        System.debug('loginOauthUserAgentMethod() - redirect URL: ' + getOauthUserAgentUrl(redirect_uri, origin));

        return Site.login(
            username, 
            password, 
            getOauthUserAgentUrl(redirect_uri, origin)
        );
    }

    /*
    *** DESCRIPTION Get Oauth User Agent URL
    *** RETURN      PageReference   To redirect_uri with access token as param 
    */
    public static String getOauthUserAgentUrl(String redirect_uri, String origin) {

        String scope;
        if(origin == 'lvapp' || origin == 'lvconnect'){
            scope = 'full refresh_token';
        }
        
        return '/services/oauth2/authorize?response_type=token' +
            '&client_id=' + IDENTITY_Settings__c.getInstance().Client_Id__c + 
            '&redirect_uri=' + EncodingUtil.urlEncode(redirect_uri,'UTF-8') + 
            ( !String.isEmpty(scope) ? '&scope=' + EncodingUtil.urlEncode(scope,'UTF-8') : '');
    }

    /*
    *** DESCRIPTION Create LookShare that binds the look to the account 
    *** RETURN   FALSE, if lookId do no exist on registration process / 
    ***                    lookId already link to the existing user /
    ***                    the linked failed.
    ***          LOOKID, if the link success.   
    */
    public static String shareLook(String lookId, String accountId, String application) { // TODO: method not covered by unit tests

        try{
            // LOOK DOESN'T EXIST
            List<Look__c> looks = [SELECT Id FROM Look__c WHERE Id =: lookId];
            if(looks.isEmpty()){
                new Logs( new Map<String,Object> {
                    'level' => 'DEBUG', 
                    'apexClass' => 'IDENTITY_Utils',
                    'category' => 'DATABASE',
                    'message' => 'LOOK DOESN\'T EXIST',
                    'recordId' => lookId,
                    'application' => application
                });
                return 'false';
            }

            // LOOK IS ALREADY LINKED
            Look__c look = looks[0];
            List<Look_Share__c> lookShares = [SELECT Id FROM Look_Share__c WHERE Look__c =: lookId AND Client__c =: accountId];
            if(!lookShares.isEmpty()) {
                new Logs( new Map<String,Object> {
                    'level' => 'DEBUG', 
                    'apexClass' => 'IDENTITY_Utils',
                    'category' => 'DATABASE',
                    'message' => 'LOOK IS ALREADY LINKED',
                    'recordId' => lookId,
                    'details' => lookShares[0].Id,
                    'application' => application
                });
                return String.valueOf(false);
            }

            return lookId;
        }
        catch(Exception ex){
            new Logs( new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'IDENTITY_Utils',
                'category' => 'API',
                'exception_case' => ex,
                'application' => application
            });
            return String.valueOf(false);
        }
    }

    /*
    *** DESCRIPTION Enable a user
    */
    public static void activeUser(Id userId){
       System.debug('IDENTITY UTILS - activeUser() - userID = '+userId);
       update new User(Id = userId, IsActive = true);
    }

    /*
    *** DESCRIPTION Encrypted Account Id
    */
    public static String getEncryptedId(String accountId){
        Blob key = EncodingUtil.base64Decode(IDENTITY_Settings__c.getOrgDefaults().AES_Key__c);
        Blob accountBlob = Blob.valueOf(accountId);          
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, accountBlob);
        String base64Encoded = EncodingUtil.base64Encode(encrypted);
        return EncodingUtil.urlEncode(base64Encoded, 'UTF-8');
    }

    /*
    *** DESCRIPTION Encrypted Account Id With hash trustOrigin
    */
    public static String getEncryptedIdWithTrustOrigin(String accountId, Boolean isTrustOrigin){
        Blob key = EncodingUtil.base64Decode(IDENTITY_Settings__c.getOrgDefaults().AES_Key__c);
        Blob accountBlob = Blob.valueOf(accountId + '|' + String.valueOf(isTrustOrigin));          
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, accountBlob);
        String base64Encoded = EncodingUtil.base64Encode(encrypted);
        String EncodedIdWithTrustOrigin = EncodingUtil.urlEncode(base64Encoded, 'UTF-8');
        System.debug('ENCRYPTED ID WITH TRUST ORIGIN: '+EncodedIdWithTrustOrigin);
        return EncodedIdWithTrustOrigin;
    }

    /*
    *** DESCRIPTION get trustOrigin by App, according to Config
    *** for MyRepairs / Online Appt / Exclusive Experience / Checkout
    */
    public static Boolean isTrustOriginApp(String app){
        Boolean isTrustOrigin = false;
        if(!String.isEmpty(app)){
            List<IDENTITY_Activation_Form_Settings__mdt> activationSettings = [     SELECT  isTrustOrigin__c 
                                                                                    FROM    IDENTITY_Activation_Form_Settings__mdt
                                                                                    WHERE   Label =: app
                                                                                    LIMIT   1 
                                                                            ];
            if(activationSettings.size()>0){
                isTrustOrigin = activationSettings[0].isTrustOrigin__c;
            }    
        }        
        System.debug('IS TRUST ORIGIN APP: '+isTrustOrigin);
        return isTrustOrigin;
    }

    /*
    *** DESCRIPTION Get User according AccountId or its login identifier (PersonEmail or LoginPhone__c)
    *** RETURN      User
    */
    public static User[] getUsers(Account acc){

		User[] users = new List<User>();

        if (!Test.isRunningTest()){
            users = [
                SELECT Id, Username, TECH_Email__c, TECH_MobilePhone__c, AccountId 
                FROM User 
                WHERE Is_Identity_User__c = true AND AccountId =: acc.Id
            ];
        }
        else {
            users = [
                SELECT Id, Username, TECH_Email__c, TECH_MobilePhone__c, AccountId 
                FROM User
                WHERE Is_Identity_User__c = true AND AccountId =: acc.Id
                LIMIT 1000
            ];
        }

		if(users.isEmpty()){
         	// GET USER ACCORDING EMAIL OR LOGIN PHONE
            if(!String.isEmpty(acc.PersonEmail) || !String.isEmpty(acc.LoginPhone__pc)){
                users = [ 
                    SELECT Id, Username, TECH_Email__c, TECH_MobilePhone__c, AccountId
                    FROM User 
                    WHERE Is_Identity_User__c = true AND 
                        (	( TECH_Email__c =: acc.PersonEmail AND TECH_Email__c != null ) OR
                            ( TECH_MobilePhone__c =: acc.LoginPhone__pc AND TECH_MobilePhone__c != null ) 
                        )
                    ORDER BY TECH_Email__c ASC NULLS LAST
                ];
                System.debug('MATCHING EMAIL ON USER');
            }
		}
		else {
			System.debug('MATCHING ACCOUNT ID ON USER');
		}

		return users;
	}

    /*
    *** DESCRIPTION Get mylv url according the status of the account (identity or not)
    *** RETURN      String
    */
    public static Map<String,String> getPathsForMyLvURL(){

        Map<String,String> paths = new Map<String,String>();
        for(IDENTITY_Paths__mdt path : [SELECT Name__c, Value__c, Context__c, Application__c 
                                        FROM IDENTITY_Paths__mdt 
                                        WHERE Name__c = 'Repairs Registration URL' 
                                        ORDER BY Context__c ASC NULLS FIRST]){

            if(String.isEmpty(path.Context__c)){
                paths.put(ISDEFAULT, path.Value__c);
            }
            else{
                paths.put(path.Context__c, path.Value__c);
            }
        }

        return paths;
    }

    /*
    *** DESCRIPTION Get mylv url according the status of the account (identity or not)
    *** RETURN      String
    */
    public static Map<String,String> getSuccessUrlForMyLVURL(String name){

        Map<String,String> paths = new Map<String,String>();
        for(IDENTITY_Paths__mdt path : [SELECT Name__c, Value__c, Context__c, Application__c 
                                        FROM IDENTITY_Paths__mdt 
                                        WHERE Name__c =: name
                                        ORDER BY Context__c ASC NULLS FIRST]){

            if(String.isEmpty(path.Context__c)){
                paths.put(ISDEFAULT, path.Value__c);
            }
            else{ // TODO bloc not coverd by unit tests
                paths.put(path.Context__c, path.Value__c);
            }
        }

        return paths;
    }

    /*
    *** DESCRIPTION Get mylv url according the status of the account (identity or not)
    *** RETURN      String
    */
    public static String getMyLVURL(Account client, String origin, String ecommerce, Map<String,String> paths, Map<String,String> successUrls, Map<String, Object> others){

        String url = paths.get(ecommerce) != null ? paths.get(ecommerce) : paths.get(ISDEFAULT);
        Boolean isTrustOrigin;
        if(others.get('application') != null){
            isTrustOrigin = IDENTITY_Utils.isTrustOriginApp(String.valueOf(others.get('application')));
        }
        
        System.debug('GET MYLV URL');
        System.debug('PATHS: ' + paths);
        System.debug('ECOMMERCE: ' + ecommerce);
        System.debug('IS TRUST ORIGIN: ' + isTrustOrigin);
        
        url = url.replace('lang-country', ecommerce);
        url = String.isNotEmpty(origin) ? url.replace('origin', origin) : url.replace('origin', 'mylv');
        url = url.replace('AccountId', IDENTITY_UTILS.getEncryptedIdWithTrustOrigin(client.Id, isTrustOrigin));
        url = url.replace('DreamId', (client.DreamID__c != null ? client.DreamID__c : ''));
        if(others != null && !others.isEmpty() && others.get('CampaignId') != null) {
            url = url.replace('CampaignId', String.valueOf(others.get('CampaignId')));
        }
        else { // TODO bloc not coverd by unit tests
            url = url.remove('campaign=CampaignId');
        }
        if(successUrls != null){
            String successUrl = successUrls.get(ecommerce) != null ? successUrls.get(ecommerce) : successUrls.get(ISDEFAULT);
            successUrl = successUrl.replace('lang-country', ecommerce);
            successUrl = String.isNotEmpty(origin) ? successUrl.replace('origin', origin) : successUrl.replace('origin', 'mylv');
            url = url.replace('success_url', successUrl);

            System.debug('SUCCESS URL: ' + successUrl);
        }
        else { // TODO bloc not coverd by unit tests
            url = url.remove('&successUrl=success_url');
        }

        System.debug('URL: ' + url);
        return url;
	}

    /*
    *** DESCRIPTION Get login-less cancel OSA url
    *** RETURN      String
    */
    public static String getLoginLessCancelAppointmentURL(String origin, String ecommerce, String accountID, String appointmentID){
        
        String basic_path = [  SELECT Value__c
                        FROM IDENTITY_Paths__mdt 
                        WHERE Name__c = 'OSA Login-Less Cancel URL'
                        LIMIT 1].Value__c;
        
        String queryEcommerce = ecommerce;
        if(ecommerce == 'eng-e1')
            queryEcommerce = '';
        String domain = [  SELECT Value__c
                    FROM IDENTITY_Paths__mdt 
                    WHERE Name__c = 'Louis Vuitton Domain'
                    AND Context__c =: queryEcommerce
                    LIMIT 1].Value__c;
        
        String url;
        url = domain + basic_path;
        url = url.replace('lang-country', ecommerce);
        url = url.replace('origin', origin);
        
        String token = getEncryptedId(accountID+'|'+appointmentID);
        url = url+'?token='+token;

        System.debug('ORIGIN: '+origin);
        System.debug('ECOMMERCE: '+ecommerce);
        System.debug('ACC ID: '+accountID);
        System.debug('APT ID: '+appointmentID);
        System.debug('BASIC PATH: '+basic_path);
        System.debug('DOMAIN: '+domain);
        System.debug('FINAL URL: '+url);

        return url;

    }

    // Used only for old API, use instead the RestResource_Utils Handler
    global class ResponseHandler {
        public String Status {get; set;}
        public String Message {get;set;}
        public sObject Data {get;set;}
        public String AccountId {get;set;}

        public ResponseHandler() {}

        public ResponseHandler(String status, String message) {
            this.status = status;
            this.message = message;
        }

        public ResponseHandler(String status, String message, SObject data) {
            this.status = status;
            this.message = message;
            this.data = data;
        }

        public ResponseHandler(String status, String message, SObject data, String accountId) {
            this.status = status;
            this.message = message;
            this.data = data;
            this.accountId = accountId;
        }
    }

    global class CustomException extends Exception {}

    public static Map<String,String> mappingProspectUser;
    public static Map<String,String> mappingATGAccount;
    public static Map<String,String> mappingAddressPhoneATGAccount;
    public static Map<String,String> mappingBirthdateATGAccount;

    public static List<String> SOCIAL_TYPE;
    
    private static final String ISDEFAULT;
    private static final String REGISTRATION;
    private static final String SUCCESS;
    
    static {
        mappingProspectUser = new Map<String,String>{
            'PrimaryCountry__pc' => 'Country__c',
            'Salutation' => 'Title',
            'PersonTitle' => 'Title',
            'LoginPhone__pc' => 'MobilePhone',
            'PersonEmail' => 'Email',
            'FirstName' => 'FirstName',
            'LastName' => 'LastName'
        };

        mappingATGAccount = new Map<String,String>{
            'title' => 'Salutation',
            'lastName' => 'LastName',
            'firstName' => 'FirstName',
            'lastName2' => 'Lastname2__pc',
            'firstName2' => 'Firstname2__pc',
            'email' => 'PersonEmail',
            'country' => 'PrimaryCountry__pc',
            'internationalMobilePhone' => 'LoginPhone__pc',
            'localMobilePhone' => 'LocalLoginPhone__pc',
            'callingCodeMobilePhone' => 'LoginPhoneCallingCode__pc',
            'countryCodeMobilePhone' => 'LoginPhoneCountryCode__pc',
            'suscribedInNewsletter' => 'Can_Be_Contacted_By_Email__pc',
            'contactableByMail' => 'Can_Be_Contacted_By_Mail__pc',
            'contactableByPhone' => 'Can_Be_Contacted_By_Phone__pc',
            'contactableBySms' => 'Can_Be_Contacted_By_SMS__pc',
            'accountIdSF' => 'Id'
        };

        mappingAddressPhoneATGAccount = new Map<String,String>{
            'postalCode' => 'PrimaryZipCode__pc',
            'address1' => 'PrimaryAddressLine1__pc',
            'address2' => 'PrimaryAddressLine2__pc',
            'address3' => 'PrimaryAddressLine3__pc',
            'city' => 'PrimaryCity__pc',
            'state' => 'PrimaryStateProvince__pc',
            'phoneNumber' => 'PersonMobilePhone',
            'phoneNumberCountry' => 'MobilePhoneCountryCode__pc'  
        };

        mappingBirthdateATGAccount = new Map<String,String>{
            'birthdateDay' => 'BirthdateDay__pc',
            'birthdateMonth' => 'BirthdateMonth__pc',
            'birthdateYear' => 'BirthdateYear__pc'  
        };


        SOCIAL_TYPE = new List<String>{'Line', 'WeChat'};

        ISDEFAULT = 'ISDEFAULT';
        REGISTRATION = 'REGISTRATION';
        SUCCESS = 'SUCCESS';
    }

    /*
    *** DESCRIPTION Generate random Cid for GG Analytics
    */
    public static String getRandomClientId() {
        String random9Digits = String.valueOf(Math.random()).replaceFirst('0.(0)?', '').substring(0, 9);
        return random9Digits + '.' + random9Digits;
    }

    /*
    *** DESCRIPTION Check if login/registration redirecting url is allowed (according to LV domains)
    */
    public static Boolean isAllowedUrl(String url, Map<String,String> paths, String origin){
        
        String  domain;
        String  protocol;
        List<String> allowedDomains = New List<String>();
        
        if(!String.isEmpty(url)){
            try
            {
                URL urlToValidate = new URL(url);
                domain   = urlToValidate.getHost();
                protocol = urlToValidate.getProtocol(); // for LVApp and LVConnect

                for(String key : paths.keySet()){
                    if(key.contains('Domain')){
                        allowedDomains.add(paths.get(key));
                    }
                }

                for(String pathDomain : allowedDomains){
                    if( (origin != 'lvapp' && origin != 'lvconnect' && pathDomain.contains(domain)) || ( (origin == 'lvapp' || origin == 'lvconnect') && pathDomain.contains(protocol)) ){
                        return true;
                    }
                }

                return false;
            }
            catch(System.StringException e)
            {
                return false;
            }
        }
        
        return false;
    }
      
    /*
    *** DESCRIPTION Get RMS Fields from Account for MyLV-To-RMS flow
    */
    public static Account getAccountForRMS(Account accountForRMS){

        if(accountForRMS != null){

            List<Account> acc = [   SELECT  Id, RMSId__pc, 
                                            AttachedStore__pc, AttachedStoreCode__pc, AttachedStoreCountry__pc, Store__pc, TECH_AttachedStoreCountry__c
                                    FROM    Account 
                                    WHERE   Id =: accountForRMS.Id
                                    LIMIT   1];
            System.debug('in getAccountForRMS ' + acc);
            
            if(acc.size()>0){
                accountForRMS.RMSId__pc                     = acc[0].RMSId__pc;
                accountForRMS.AttachedStoreCode__pc         = acc[0].AttachedStoreCode__pc;
                accountForRMS.AttachedStore__pc             = acc[0].AttachedStore__pc;
                accountForRMS.AttachedStoreCountry__pc      = acc[0].AttachedStoreCountry__pc;
                accountForRMS.Store__pc                     = acc[0].Store__pc;
                accountForRMS.TECH_AttachedStoreCountry__c  = acc[0].TECH_AttachedStoreCountry__c;

                return accountForRMS;
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
    }

    /*
    *** DESCRIPTION Get Default Store value from ContryLanguage__c for MyLV-To-RMS flow
    */    
    public static Account getDefaultStoreValuesForRMS(Account accountForRMS, String dispatchCountry, String atgLocale){

        System.debug('dispatch country: '+dispatchCountry);
        System.debug('locale: '+atgLocale);

        if(accountForRMS != null && !String.isEmpty(atgLocale)){
            List<CountryLanguage__c> defStore = [   SELECT  defaultStore__c, defaultStore__r.retailStoreID__c
                                                    FROM    CountryLanguage__c
                                                    WHERE   Dispatch_Country__c =: dispatchCountry
                                                    AND     ATG_Locale__c =: atgLocale 
                                                    AND     defaultStore__c != null
                                                    LIMIT   1 
                                                    ];
            if(defStore.size()>0){
                // FYI, no need to assign TECH_AttachedStoreCountry__c and AttachedStoreCountry__pc fields, 
                // they will be updated retroactively by Dream Syncronisation
                accountForRMS.AttachedStore__pc      = defStore[0].defaultStore__r.retailStoreID__c;
                accountForRMS.AttachedStoreCode__pc  = defStore[0].defaultStore__r.retailStoreID__c;
                accountForRMS.Store__pc              = defStore[0].defaultStore__c;

                return accountForRMS;
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
    }

    /*
    *** DESCRIPTION Check if Default Store value exists in ContryLanguage__c for a specific locale for MyLV-To-RMS flow
    */
    public static Boolean isExistDefaultStoreForRMS(String dispatchCountry , String atgLocale){

        System.debug('dispatch country: '+dispatchCountry);
        System.debug('locale: '+atgLocale);

        List<CountryLanguage__c> defStore = [   SELECT  defaultStore__r.retailStoreID__c
                                                FROM    CountryLanguage__c
                                                WHERE   Dispatch_Country__c =: dispatchCountry
                                                AND     ATG_Locale__c =: atgLocale 
                                                AND     defaultStore__c != null
                                                LIMIT   1 
                                                ]; 
        if(defStore.size()>0){
            return true;
        }
        else{
            return false;
        }
    } 

    /*
    *** DESCRIPTION Check if Store value is WEB or not for MyLV-To-RMS flow
    */
    public static Boolean isStoreTypeValidForRMS(Account acct){ 
        
        String retailStoreId = acct.AttachedStoreCode__pc != null ? acct.AttachedStoreCode__pc : acct.AttachedStore__pc;
        List<store__c> strList = [  SELECT StoreType__c
                                    FROM store__c 
                                    WHERE RetailStoreId__c =:retailStoreId ];
        if(!strList.isEmpty()){
            store__c str = strList[0];
            if(str.StoreType__c != 'WEB'){
                return true;
            }
            else{ // TODO bloc not coverd by unit tests
                return false;
            }
        }

        return false; // TODO line not coverd by unit tests
    }

    public static String getClientServicePhoneNumber(String languageAndCountry, String dispatchCountry) {
        String phoneNumber = 'N/A';
        try {
            languageAndCountry = String.escapeSingleQuotes(languageAndCountry);
            String andClause = '';
            if (!String.isEmpty(dispatchCountry)) {
                dispatchCountry = String.escapeSingleQuotes(dispatchCountry);
                andClause = 'AND Dispatch_Country__c = :dispatchCountry ';
            }
            String query = '' +
                'SELECT LVConnect_CS_PhoneNumber__c ' +
                'FROM CountryLanguage__c ' +
                'WHERE ATG_Locale__c = :languageAndCountry ' +
                andClause +
                'LIMIT 1';
            sObject record = Database.query(query);
            phoneNumber = String.valueOf(record.get('LVConnect_CS_PhoneNumber__c'));
        }
        catch(Exception e) {
            System.debug('Error in IDENTITY_getClientServicePhoneNumber(): ' + e.getMessage());
        }
        return phoneNumber;
    }
    
    public static String truncateUsername(String username) {
        return username.substring(0,3)+'***';
    }
    
    public static String getIso2CodeForCallingCode(Integer callingCode){
        List<CountryMapping__mdt> countryMappingList = [SELECT Iso2Code__c FROM CountryMapping__mdt WHERE Calling_Code__c = : callingCode];
        if(!countryMappingList.isEmpty()){
            CountryMapping__mdt countryMapping = countryMappingList[0];
            return countryMapping.Iso2Code__c;
        }
        return null;
    }

    public static Map<String, String> getSplittedPhoneFromFullPhone(String fullPhone) {
        List<String> splittedPhoneNumber = fullPhone.replaceAll('[+-]','').split(' ');
        if(splittedPhoneNumber.size()>1){
            String prefix = splittedPhoneNumber[0];
            splittedPhoneNumber.remove(0);
            String phone = String.join(splittedPhoneNumber, ' ');
            return new Map<String,String> {
                'callingCode' 	            => prefix,
                'iso2Code' 	                => getIso2CodeForCallingCode(Integer.valueOf(prefix)),
                'internationalMobilePhone'  => '+' + prefix + phone,
                'mobilePhone' 			    => '0' + phone
            };
        }
        return null;
    }
    
    public static String genderToSalutation(String gender){
        Map<String, String> genderToSalutation = new Map<String, String> {
            'male' => '02',
            'female' => '04',
            'other' => '02'
        };
        gender = gender.toLowerCase();
        return genderToSalutation.containsKey(gender) ? genderToSalutation.get(gender) : null ;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}