@isTest
public with sharing class TWIST_LoginService_TEST {

    @isTest
    static void test_doSalesforceLogin_wrongPassword() {
        String state = 'dummy-state';
        String codeChallenge = 'dummy-code-challenge';
        String clientId = 'dummy-client-id';
        String redirectUri = 'https://dummy-redirect.uri';
        Pagereference result = TWIST_LoginService.doSalesforceLogin('myUserName', 'password', state, codeChallenge, clientId, redirectUri);
        System.assertEquals(null, result);
    }

    @isTest
    static void test_doSalesforceLogin_WhenStateIsEmpty() {
        String state1 = '';
        String state2 = null;
        String codeChallenge = 'dummy-code-challenge';
        String clientId = 'dummy-client-id';
        String redirectUri = 'https://dummy-redirect.uri';
        Pagereference result1 = TWIST_LoginService.doSalesforceLogin('myUserName', 'password', state1, codeChallenge, clientId, redirectUri);
        Pagereference result2 = TWIST_LoginService.doSalesforceLogin('myUserName', 'password', state2, codeChallenge, clientId, redirectUri);
        System.assertEquals(null, result1);
        System.assertEquals(null, result2);
    }

    @isTest
    static void test_doSalesforceLogin_WhenCodeChallengeIsEmpty() {
        String state = 'dummy-state';
        String codeChallenge1 = '';
        String codeChallenge2 = null;
        String clientId = 'dummy-client-id';
        String redirectUri = 'https://dummy-redirect.uri';
        Pagereference result1 = TWIST_LoginService.doSalesforceLogin('myUserName', 'password', state, codeChallenge1, clientId, redirectUri);
        Pagereference result2 = TWIST_LoginService.doSalesforceLogin('myUserName', 'password', state, codeChallenge2, clientId, redirectUri);
        System.assertEquals(null, result1);
        System.assertEquals(null, result2);
    }
    
    @isTest
    static void test_doSalesforceLogin_WhenClientIdIsEmpty() {
        String state = 'dummy-state';
        String codeChallenge = 'dummy-code-challenge';
        String clientId1 = '';
        String clientId2 = '';
        String redirectUri = 'https://dummy-redirect.uri';
        Pagereference result1 = TWIST_LoginService.doSalesforceLogin('myUserName', 'password', state, codeChallenge, clientId1, redirectUri);
        Pagereference result2 = TWIST_LoginService.doSalesforceLogin('myUserName', 'password', state, codeChallenge, clientId2, redirectUri);
        System.assertEquals(null, result1);
        System.assertEquals(null, result2);
    }

    @isTest
    static void test_doSalesforceLogin_WhenRedirectUriIsEmpty() {
        String state = 'dummy-state';
        String codeChallenge = 'dummy-code-challenge';
        String clientId = 'dummy-client-id';
        String redirectUri1 = '';
        String redirectUri2 = null;
        Pagereference result1 = TWIST_LoginService.doSalesforceLogin('myUserName', 'password', state, codeChallenge, clientId, redirectUri1);
        Pagereference result2 = TWIST_LoginService.doSalesforceLogin('myUserName', 'password', state, codeChallenge, clientId, redirectUri2);
        System.assertEquals(null, result1);
        System.assertEquals(null, result2);
    }
}