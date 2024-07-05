@isTest
public with sharing class StubHelper_TEST {

    @isTest
    public static void test_forClass() {
        // When
        Object stub = StubHelper.forClass(DummyClass.class);

        // Then
        System.assert(stub instanceof StubHelper, 'error');
    }

    @isTest
    public static void test_stubMethod() {
        // When
        Object stub = StubHelper.forClass(DummyClass.class).stubMethod('methodName', 'returnValue');

        // Then
        System.assert(stub instanceof StubHelper, 'error');
    }

    @isTest
    public static void test_getStub() {
        // When
        Object stub = StubHelper.forClass(DummyClass.class).stubMethod('methodName', 'returnValue').getStub();

        // Then
        System.assertEquals(null, stub, 'error');
    }
    
    private class DummyClass {}
}