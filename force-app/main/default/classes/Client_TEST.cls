@isTest
private class Client_TEST {

    static testMethod void testClientConstructor() {

        // Create test metadata records
        Map<String,Map<String,IDENTITY_Registration_Form__mdt>> fields = new Map<String,Map<String,IDENTITY_Registration_Form__mdt>>();
        Map<String,IDENTITY_Registration_Form__mdt> personalFields = new Map<String,IDENTITY_Registration_Form__mdt>();
        Map<String,IDENTITY_Registration_Form__mdt> loginFields = new Map<String,IDENTITY_Registration_Form__mdt>();
        personalFields.put('title', new IDENTITY_Registration_Form__mdt(Value__c='Mr'));
        personalFields.put('privacy_agreement', new IDENTITY_Registration_Form__mdt(Value__c='true'));
        personalFields.put('newsletter_agreement', new IDENTITY_Registration_Form__mdt(Value__c='false'));
        personalFields.put('currency_code', new IDENTITY_Registration_Form__mdt(Value__c='EURO'));
        personalFields.put('country', new IDENTITY_Registration_Form__mdt(Value__c='FR'));
        personalFields.put('mobile_phone', new IDENTITY_Registration_Form__mdt(Value__c='1234567890'));
        fields.put('Personal', personalFields);
        loginFields.put('mobile_phone',personalFields.get('mobile_phone'));
        fields.put('Login',loginFields);

        Map<String,String> socialParams = new Map<String,String>();
        socialParams.put('email', 'test@twistvuitton.com');
        socialParams.put('firstname', 'Damixen');
        socialParams.put('lastname', 'TWIST');

        // Create test account record
        Account testAcc = new Account(
            Salutation = 'Mr',
            Firstname = 'Damixen',
            Lastname = 'TWIST',
            FirstName2__pc = 'Dami',
            LastName2__pc = 'TWIST',
            SPO_Country_code__pc = 'FRA',
            PrimaryCountry__pc = 'FRA',
            PersonEmail = 'test@twistvuitton.com',
            LocalMobilePhone__pc = '1234567890',
            LocalLoginPhone__pc = '1234567890',
            MobilePhoneCountryCode__pc = 'FR',
            LoginPhoneCountryCode__pc = 'FR',
            LoginPhone__pc = '1234567890',
            OwnerId = UserInfo.getUserId()
        );
        insert testAcc;

        // Create a new Client object using the constructor with arguments
        Client client = new Client(fields, socialParams, 'US', testAcc);

        // Verify the object was created with the correct field values
        System.assertEquals(client.title, 'Mr');
        System.assertEquals(client.privacy_agreement, 'true');
        System.assertEquals(client.newsletter_agreement, 'false');
        System.assertEquals(client.currency_code, 'EURO');
        System.assertEquals(client.country, 'FR');
        System.assertEquals(client.calling_code, 'FR');
        System.assertEquals(client.login_calling_code, 'FR');
        System.assertEquals(client.login_email, 'test@twistvuitton.com');
        System.assertEquals(client.login_email_confirmation, 'test@twistvuitton.com');
        System.assertEquals(client.firstname, 'Damixen');
        System.assertEquals(client.lastname, 'TWIST');
        System.assertEquals(client.email, 'test@twistvuitton.com');
        System.assertEquals(client.mobile_phone, '1234567890');
        System.assertEquals(client.login_mobile_phone, '1234567890');
        System.assertEquals(client.attached_store, null);
        System.assertEquals(client.attached_store_code, null);
        System.assertEquals(client.attached_store_country, null);
        System.assertEquals(client.store, null);
        System.assertEquals(client.tech_attached_store_country, null);
        System.assertEquals(client.id, testAcc.Id);
        System.assertEquals(client.owner_id, UserInfo.getUserId());

    }
}