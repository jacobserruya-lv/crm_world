/*  
*** Balink January 2017
*** DESCRIPTION: Utlis in Order to create, update Person accounts and Users
***              Initially created to be used from Web Service(PASS_WS01_CreateUserId and PASS_WS02_UpdateUserId)
***
*** NOTE:        All unicity verification is managed by Trigger on USER
*/
global without sharing class PASS_Utils {

	String identityProfile = IC_Config__c.getInstance('Identity User').Value__c;

	public PASS_Utils() {}

	/*
	*** DESCRIPTION Check if an account (prospect/client) already exist with this mail/phone and firstName/lastName.
	***             If many accounts already exist, take the first with the most recent LastTrans__pc and ModifiedDate.
	*** 			Update the found account with the data received as parameter. 
	***             Else, if no accounnt doesn't exist, insert a new account
	*** RETURN      The account with its PersonContactId
	*/
	public Account getPersonAccount(Client client) {
		
		if( (!String.isEmpty(client.localMobilePhone) && !String.isEmpty(client.countryCode) && !String.isEmpty(client.internationalMobilePhone) ) || !String.isEmpty(client.email)) {

			Account acc = getExistingPersonAccount(client.email, client.internationalMobilePhone, client.firstName, client.lastName, client);
			if(acc == null) {
				acc = createPersonAccount(client);
			}
			
			return acc;
			
		}
		else {
			throw new CustomException(Label.EM_required_field_missing);
		}
	}

	/*
	*** DESCRIPTION The function to search existing account
	*** RETURN      The account with its PersonContactId
	*/
	public Account getExistingPersonAccount(String email, String internationalMobilePhone, String firstName, String lastName, Client client) {
		String emailCondition = !String.isEmpty(email) ? ' PersonEmail =: email ' : '';
		String phoneCondition = !String.isEmpty(internationalMobilePhone) ? 'PersonMobilePhone =:  internationalMobilePhone ' : '';
		
		String query = '' +
			' SELECT Id, PersonContactId ' +
			' FROM Account ' +
			' WHERE ( ' + emailCondition + (!String.isEmpty(email) && !String.isEmpty(internationalMobilePhone) ? ' OR ' : '') + phoneCondition + 
			' ) AND LastName =: lastName AND FirstName =: firstName ' +
			' ORDER BY LastTrans__pc, LastModifiedDate DESC ';

		List<Account> accountList = Database.query(query);

		// Matching Exsiting Client -- Update the propsect with myLV data.
		if(accountList.size() > 0) {

			updatePersonAccount(
				client.title, client.lastName, client.firstName, client.lastName2, client.firstName2, 
				client.country, client.email, client.localMobilePhone, client.countryCode, client.internationalMobilePhone, accountList[0].Id
			);

			return accountList[0];
		}

		return null;
	}

	/*
	*** DESCRIPTION The function to create a new account
	*** RETURN      The account with its PersonContactId
	*/
	public Account createPersonAccount(Client client) {
		
		Account persAcc = new Account(
			LastName = client.lastName,
			FirstName = client.firstName,
			PersonEmail = client.email,
			LocalMobilePhone__pc = client.localMobilePhone,
			MobilePhoneCountryCode__pc = client.countryCode,
			PersonMobilePhone = client.internationalMobilePhone,
			Lastname2__pc = client.lastName2,
			Firstname2__pc = client.firstName2,
			PersonTitle = client.title,
			PrimaryCountry__pc = client.country,
			IsProspect__pc = true,
			ProspectForDream__c = true
		);
		
		insert persAcc;

		persAcc = [
			SELECT Id, PersonContactId 
			FROM Account
			WHERE Id =: persAcc.Id
		];

		return persAcc;
	}

	/*
	*** DESCRIPTION Create a new user without sending email to the user and set its password
	*** RETURN      The new user
	*/
	public User createIdentity(String personContactId, Client client) {
		
		User identityUser = new User(
			ContactId = personContactId,
			Email = getUsernameFormat(client.email, client.internationalMobilePhone),
			MobilePhone = client.internationalMobilePhone,
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'fr',
			LocaleSidKey = 'fr',
			ProfileId = identityProfile,
			Username = getUsernameFormat(client.email, client.internationalMobilePhone),
			LastName = client.lastName,
			Alias = getAliasFormat(client.firstName, client.lastName),
			FirstName = client.firstName,
			TimeZoneSidKey = 'Europe/Paris',
			Title = client.title,
			Country__c = client.country
		);

		Database.DMLOptions dlo = new Database.DMLOptions();
		dlo.EmailHeader.triggerUserEmail = false;
		dlo.EmailHeader.triggerOtherEmail = false;
		identityUser.setOptions(dlo);
		
		Database.saveresult sr = Database.insert(identityUser);
		System.setPassword(identityUser.Id, client.password);

		return identityUser;
	}

	/*
	*** DESCRIPTION Set alias field (= Short name to identify the user on SF pages. Up to 8 characters are allowed in this field)
	***   			By default, the fisrt letter of the first name + three letters of the last name
	*** RETURN      Alias (String)
	*/
	public String getAliasFormat(String firstName, String lastName) {

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
	*** DESCRIPTION Set username field (= Administrative field that defines the user’s login. Up to 80 characters are allowed in this field. Email Format required)
	*** 			The email of the client if there is one. If not, used the phone number + fix domaine ("@louisvuitton.com").
	*** RETURN      Username (String)
	*/
	public String getUsernameFormat(String email, String internationalMobilePhone) {
		if(!String.isEmpty(email)) {
			return email;
		}

		return internationalMobilePhone + '@louisvuitton.com';
	}

	/*
	*** DESCRIPTION If a user already exist, throw Exception
	***             Else, check if a user exist with this id
	***             If there is no user, throw Exception
	***             Else, update the user without sending mail to the user and update the related PersonAccount	
	*** RETURN      The updated user 
	*/
	public  User updateUserIdentity(Client client) {

		if( (!String.isEmpty(client.localMobilePhone) && !String.isEmpty(client.countryCode) && !String.isEmpty(client.internationalMobilePhone) ) || !String.isEmpty(client.email)) {

			List<User> uIdentityList = [ 
				SELECT Id, Username, Contact.AccountId 
				FROM User 
				WHERE Id =: client.userId AND ProfileId =: identityProfile
			];

			if(uIdentityList.size() > 0) {
			 	User identityUser = new User(
			 		Id = uIdentityList[0].Id,
					Email = getUsernameFormat(client.email, client.internationalMobilePhone),
					MobilePhone = client.internationalMobilePhone,
					Username = getUsernameFormat(client.email, client.internationalMobilePhone),
					LastName = client.lastName,
					FirstName = client.firstName,
					Title = client.title,
					Country__c = client.country
				);

		 		Database.DMLOptions dlo = new Database.DMLOptions();
				dlo.EmailHeader.triggerUserEmail = false;
				dlo.EmailHeader.triggerOtherEmail = false;
				identityUser.setOptions(dlo);

				Database.saveresult sr = Database.update(identityUser);
				updatePersonAccount(
					client.title, client.lastName, client.firstName, client.lastName2, client.firstName2, client.country, client.email, client.localMobilePhone, 
					client.countryCode, client.internationalMobilePhone, uIdentityList[0].Contact.AccountId
				);

				return identityUser;
			}
			else {
	        	throw new CustomException(Label.EM_User_Not_Found);
	        }
		}
		else {
			throw new CustomException(Label.EM_required_field_missing);
		}
	}


	//Future method because of MIXED_DML issue => can't update user and account in same context
	@future
	public static void updatePersonAccount(String title, String lastName, String firstName, String lastName2, String firstName2, 
		String country, String email, String localMobilePhone, String countryCode, String internationalMobilePhone, String accountId) {
		try{
			Account a = new Account(
				Id = accountId,
				LastName = lastName,
				FirstName = firstName,
				Lastname2__pc = lastName2,
				Firstname2__pc = firstName2,
				PersonEmail = email,
				LocalMobilePhone__pc = localMobilePhone,
				MobilePhoneCountryCode__pc = countryCode,
				PersonMobilePhone = internationalMobilePhone,
				PersonTitle = title,
				PrimaryCountry__pc = country
			);
			update a;
		}
		catch(DmlException e) {
			System.debug('The following exception has occurred: ' + e.getMessage());
		}
	}

	/* ------------------------------------------------ WRAPPER ------------------------------------------ */

	// Custom Response Object
    global class ResponseHandler {
        public String Status {get; set;}
        public String Message {get;set;}
        public sObject Data {get;set;}

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
    }

    // Custom Client Object
    global class Client {
        public String title {get; set;}
        public String lastName {get;set;}
        public String firstName {get;set;}
        public String lastName2 {get;set;}
        public String firstName2 {get;set;}
        public String email {get;set;}
        public String localMobilePhone {get;set;}
        public String countryCode {get;set;}
        public String internationalMobilePhone {get;set;}
        public String country {get;set;}
        public String userId;
        public String password {get;set;}

        public Client() {}

        public Client(String body)  {

        	Map<String, Object> parameters = (Map<String, Object>)JSON.deserializeUntyped(body);

            this.title = (String)parameters.get('title');
            this.lastName = (String)parameters.get('lastName');
            this.firstName = (String)parameters.get('firstName');
            this.lastName2 = (String)parameters.get('lastName2');
            this.firstName2 = (String)parameters.get('firstName2');
            this.email = (String)parameters.get('email');
            this.localMobilePhone = (String)parameters.get('localMobilePhone');
            this.countryCode = (String)parameters.get('countryCode');
            this.internationalMobilePhone = (String)parameters.get('internationalMobilePhone');
            this.country = (String)parameters.get('country');
            this.userId = (String)parameters.get('userId');
            this.password = (String)parameters.get('password');
        }
    }

    // Custom Exception Object
    global class CustomException extends Exception {}
}