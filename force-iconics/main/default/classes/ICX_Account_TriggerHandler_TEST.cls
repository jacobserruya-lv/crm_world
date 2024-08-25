/*	 * @author Keman WU
* @date creation 08/11/2021
* @description test class for ICX_Account_TriggerHandler
*/
@isTest
public with sharing class ICX_Account_TriggerHandler_TEST {
    @isTest static void myTestMethod() {
        test.startTest();
        Account acc = ICX_TestFactory.createAccount();
        acc.PersonMobilePhone  = '+33624556643';
        acc.PersonHomePhone  = '+33724556643';
        acc.Phone  = '+33124556643'; 
        insert acc;
        acc.PersonMobilePhone  = '+34624556643';
        acc.PersonHomePhone  = '+34724556643';
        acc.Phone  = '+34124556643'; 
        update acc;
        test.stopTest();
    }
}