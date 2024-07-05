@isTest
private class IDENTITY_AccountMatching_Utils_TEST {
    
    @isTest static void test_upsertAccount(){

        
        String code;
        Account acc;
        Account new_acc;
        Map<String, String> result;
        String action;
        
        // UPDATE ACCOUNT BY EMAIL
        code = String.valueOf(Math.round(Math.random() * 100000));
        acc = IDENTITY_TestFactory.createAccount('Jean', 'Marc', code + 'test@test.com', null, null, true);
        result = IDENTITY_AccountMatching_Utils.upsertAccountByFieldsValue(acc);
        action = result.get('action');
        System.assertEquals(action, 'MATCHING');

        // UPDATE ACCOUNT BY MOBILE
        code = String.valueOf(Math.round(Math.random() * 10000));
        acc = Identity_TestFactory.createAccount('Jean', 'Michel', null, code + '5588','33', true);
        result = IDENTITY_AccountMatching_Utils.upsertAccountByFieldsValue(acc);
        action = result.get('action');
        System.assertEquals(action, 'MATCHING');

        // UPDATE ACCOUNT BY EMAIL AND MOBILE
        code = String.valueOf(Math.round(Math.random() * 10000));
        acc = Identity_TestFactory.createAccount('Jean', 'Claude', code + 'test@test.com', code + '5588','33', true);
        result = IDENTITY_AccountMatching_Utils.upsertAccountByFieldsValue(acc);
        action = result.get('action');
        System.assertEquals(action, 'MATCHING');

        // CREATE ACCOUNT
        code = String.valueOf(Math.round(Math.random() * 100000));
        new_acc = new Account(
            Lastname = 'Jean',
            Firstname = 'Jacques',
            Salutation = '02',
            HomeAddressCountryCode__pc = 'FRA',
            PersonEmail = code + 'test@test.com'
        );

        Test.StartTest();

            result = IDENTITY_AccountMatching_Utils.upsertAccountByFieldsValue(new_acc);
            action = result.get('action');
            System.assertEquals(action, 'NEW');

            // ERROR - missing Lastname
            new_acc = new Account(
                Lastname = '',
                Firstname = 'Jean',
                Salutation = '02',
                HomeAddressCountryCode__pc = 'FRA',
                PersonEmail = code + 'test@test.com'
            );
            result = IDENTITY_AccountMatching_Utils.upsertAccountByFieldsValue(new_acc);
            action = result.get('action');
            System.assertEquals(action, 'MISSING_REQUIRED_FIELD');        

            // ERROR - missing Firstname
            new_acc = new Account(
                Lastname = 'Marc',
                Firstname = '',
                Salutation = '02',
                HomeAddressCountryCode__pc = 'FRA',
                PersonEmail = code + 'test@test.com'
            );
            result = IDENTITY_AccountMatching_Utils.upsertAccountByFieldsValue(new_acc);  
            action = result.get('action');
            System.assertEquals(action, 'MISSING_REQUIRED_FIELD');      

            // ERROR - missing Salutation
            code = String.valueOf(Math.round(Math.random() * 100000));
            acc = IDENTITY_TestFactory.createAccount('Jean', 'Marc', code + 'test@test.com', null, null, true);
            acc.Salutation = '';
            result = IDENTITY_AccountMatching_Utils.upsertAccountByFieldsValue(acc);
            action = result.get('action');
            System.assertEquals(action, 'MISSING_REQUIRED_FIELD');

            // ERROR - missing HomeAddressCountryCode__pc
            code = String.valueOf(Math.round(Math.random() * 100000));
            acc = IDENTITY_TestFactory.createAccount('Jean', 'Marc', code + 'test@test.com', null, null, true);
            acc.HomeAddressCountryCode__pc = '';
            result = IDENTITY_AccountMatching_Utils.upsertAccountByFieldsValue(acc);
            action = result.get('action');
            System.assertEquals(action, 'MISSING_REQUIRED_FIELD');

            // ERROR - invalid HomeAddressCountryCode__pc - has to be ISO3 format
            code = String.valueOf(Math.round(Math.random() * 100000));
            acc = IDENTITY_TestFactory.createAccount('Jean', 'Marc', code + 'test@test.com', null, null, true);
            acc.HomeAddressCountryCode__pc = 'FR';
            result = IDENTITY_AccountMatching_Utils.upsertAccountByFieldsValue(acc);
            action = result.get('action');
            System.assertEquals(action, 'INVALID_FORMAT_FIELD');
            
            // ERROR - missing PersonEmail and PersonMobilePhone
            new_acc = new Account(
                Lastname = 'Jean',
                Firstname = 'Jacques',
                Salutation = '02',
                HomeAddressCountryCode__pc = 'FRA'
            );
            result = IDENTITY_AccountMatching_Utils.upsertAccountByFieldsValue(new_acc);
            action = result.get('action');
            System.assertEquals(action, 'MISSING_REQUIRED_FIELD');

        Test.StopTest();
    }
}