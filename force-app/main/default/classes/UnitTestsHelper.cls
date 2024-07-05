public class UnitTestsHelper {

    /*public static HttpCalloutMockUtil enableHttpMock() {
        HttpCalloutMockUtil mockUtil = new HttpCalloutMockUtil();
        Test.setMock(HttpCalloutMock.class, mockUtil);
        HTTP_Utils.setUseMockWhenTestIsRunning(true);
        return mockUtil;
    }*/

    /** Mock helpers ********************************************************************************************************* */

    public static void setSingleHttpMock(HttpResponseMock mock) {
        HttpCalloutMockUtil mockUtil = new HttpCalloutMockUtil();
        mockUtil.setMock(mock);
        Test.setMock(HttpCalloutMock.class, mockUtil);
        HTTP_Utils.setUseMockWhenTestIsRunning(true);
    }

    public static void setMultipleHttpMocks(Map<String,HttpResponseMock> mocks) {
        HttpCalloutMockUtil mockUtil = new HttpCalloutMockUtil();
        for(String requestEndpoint: mocks.keySet()){
            mockUtil.addMock(requestEndpoint, mocks.get(requestEndpoint ));
        }
        Test.setMock(HttpCalloutMock.class, mockUtil);
        HTTP_Utils.setUseMockWhenTestIsRunning(true);
    }

    /** Assertion helpers ********************************************************************************************************* */

    public static void assertNull(Object o, String msg) {
        System.assertEquals(null, o, msg);
    }

    public static void assertNull(Object o) {
        assertNull(o, 'ERROR');
    }

    public static void assertNotNull(Object o, String msg) {
        System.assertNotEquals(null, o, msg);
    }

    public static void assertNotNull(Object o) {
        assertNotNull(o, 'ERROR');
    }

    public static void assertTrue(Boolean o, String msg) {
        System.assert(o, msg);
    }

    public static void assertTrue(Boolean o) {
        assertTrue(o, 'ERROR');
    }

    public static void assertFalse(Boolean o, String msg) {
        System.assertEquals(false, o, msg);
    }

    public static void assertFalse(Boolean o) {
        assertFalse(o, 'ERROR');
    }

}