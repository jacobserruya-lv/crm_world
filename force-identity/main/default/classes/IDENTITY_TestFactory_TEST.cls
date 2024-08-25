@isTest
public with sharing class IDENTITY_TestFactory_TEST {

    @TestSetup
    static void makeData(){
        Identity_TestFactory.createSettings();
    }
    
    @isTest
    public static void test_createAccount() {
        IDENTITY_TestFactory.createAccount('firstName', 'lastName', 'test@test.com', '0541234567', '972', false);
    }

    @isTest
    public static void test_createUser() {
        IDENTITY_TestFactory.createUser('firstName', 'lastName', 'email@fafa.com', '0541234567', '972');
    }

    @isTest
    public static void test_createSimpleUser() {
        IDENTITY_TestFactory.createSimpleUser('firstName', 'lastName', 'email@fafa.com', '0541234567');
    }
    
    @isTest
    public static void test_createCountryLanguageSettings() {
        IDENTITY_TestFactory.createCountryLanguageSettings();
    }
    @isTest
    public static void test_createCountryLanguageMiddleEastSettings() {
        IDENTITY_TestFactory.createCountryLanguageMiddleEastSettings();
    }
    @isTest
    public static void test_createCustomEmailLogs() {
        IDENTITY_TestFactory.createCustomEmailLogs();
    }

}