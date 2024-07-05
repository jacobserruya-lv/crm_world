public class BasicStubProvider implements StubProvider {
    @testVisible
    private Map<String,Object> stubMap;

    public BasicStubProvider() {
        this.stubMap = new Map<String,Object> {};
    }
    
    public void setStub(String methodName, Object returnValue) {
        this.stubMap.put(methodName, returnValue);
    }
    
    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
        return this.stubMap.containsKey(stubbedMethodName)? this.stubMap.get(stubbedMethodName) : null;
    }
}