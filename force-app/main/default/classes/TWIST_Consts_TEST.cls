/**
* This class is intented to artificially cover any "CONST" class
*/

@isTest
public with sharing class TWIST_Consts_TEST {
    
    @isTest
    static void test_ConstClasses() {
        System.assert(!TWIST_PageUrl_CONST.getConstants().isEmpty());
        System.assert(!TWIST_IdentityPathsMdt_CONST.getConstants().isEmpty());
        System.assert(!TWIST_Mode_CONST.getConstants().isEmpty());
        System.assert(!TWIST_QueryParamKey_CONST.getConstants().isEmpty());
        System.assert(!TWIST_QueryParamValue_CONST.getConstants().isEmpty());
    }

}