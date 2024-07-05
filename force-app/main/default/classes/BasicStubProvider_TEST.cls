@isTest
public with sharing class BasicStubProvider_TEST {
    
    @isTest
    public static void test_constructor() {
        // Given
        BasicStubProvider stubProvider = new BasicStubProvider();

        // Then
        System.assert(stubProvider.stubMap.isEmpty(), 'error');
    }
    
    @isTest
    public static void test_setStub() {
        // Given
        String methodName = 'myMethod';
        Integer returnValue = 123;
        BasicStubProvider stubProvider = new BasicStubProvider();

        // When
        stubProvider.setStub(methodName, returnValue);

        // Then
        System.assert(stubProvider.stubMap.containsKey(methodName), 'error');
        System.assertEquals(returnValue, Integer.valueOf(stubProvider.stubMap.get(methodName)), 'error');
    }
    
    @isTest
    public static void test_handleMethodCall() {
        // Given
        String methodNameAddedToStub = 'myMethod';
        String methodNameNotAddedToStub = 'myUnknownMethod';
        Integer returnValue = 123;
        BasicStubProvider stubProvider = new BasicStubProvider();
        stubProvider.setStub(methodNameAddedToStub, returnValue);

        // When
        Object resultForMethodAddedToStub = stubProvider.handleMethodCall(
            (Object) 'object',
            methodNameAddedToStub,
            Integer.class,
            new List<Type>(),
            new List<String>(),
            new List<Object>()
        );
        
        Object resultForMethodNotAddedToStub = stubProvider.handleMethodCall(
            (Object) 'object',
            methodNameNotAddedToStub,
            Integer.class,
            new List<Type>(),
            new List<String>(),
            new List<Object>()
        );

        // Then
        System.assertEquals(returnValue, Integer.valueOf(resultForMethodAddedToStub), 'error');
        System.assertEquals(null, Integer.valueOf(resultForMethodNotAddedToStub), 'error');
    }
    
}