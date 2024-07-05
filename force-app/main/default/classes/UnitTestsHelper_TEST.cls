/**
 * Dummy test class, created for code coverage purposes only
 */

@isTest
public with sharing class UnitTestsHelper_TEST {
    
    @isTest
    static void test_setSingleHttpMock() {
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock());
    }

    @isTest
    static void test_setMultipleHttpMocks() {
        UnitTestsHelper.setMultipleHttpMocks(new Map<String,HttpResponseMock> {
            'url1' => new HttpResponseMock(),
            'url2' => new HttpResponseMock()
        });
    }

    @isTest
    static void test_assertNull() {
        UnitTestsHelper.assertNull(null, 'msg');
        UnitTestsHelper.assertNull(null);
    }

    @isTest
    static void test_assertNotNull() {
        UnitTestsHelper.assertNotNull('fafa', 'msg');
        UnitTestsHelper.assertNotNull('fafa');
    }

    @isTest
    static void test_assertTrue() {
        UnitTestsHelper.assertTrue(true, 'msg');
        UnitTestsHelper.assertTrue(true);
    }

    @isTest
    static void test_assertFalse() {
        UnitTestsHelper.assertFalse(false, 'msg');
        UnitTestsHelper.assertFalse(false);
    }

}