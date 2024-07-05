/**
 * Usage:
 *
 * StubHelper
 *   .forClass(StubbedClass.class)
 *   .stubMethod('method_name_1', return_value_1)
 *   ...
 *   .stubMethod('methodName_n', return_value_n)
 *   .getStub();
 */

 public class StubHelper {

    private static StubHelper instance;
    private static Type stubbedClass;
    private static BasicStubProvider stubProvider;
    
    public static StubHelper forClass(Type aType) {
        stubbedClass = aType;
        return getInstance();
    }
    
    public StubHelper stubMethod(String methodName, Object returnValue) {
        stubProvider.setStub(methodName, returnValue);
        return this;
    }
    
    public Object getStub() {
        if (Test.isRunningTest()) { // since Test.createStub() canot be applied to an inner class (i.e. StubHelper_TEST.DummyClass) => https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_stub_api.htm
            return null;
        }
        return Test.createStub(stubbedClass, stubProvider);
    }
    
    /** ******************************************************************************************************************** */

    // Private constructor prevents an (external) instantiation of the class
    private StubHelper() {
        stubProvider = new BasicStubProvider();
    }

    private static StubHelper getInstance() {
        if (instance == null) {
            instance = new StubHelper(); // call to the private constructor from inside the class
        }
        return instance;
    }
    
}