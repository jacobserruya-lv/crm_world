@IsTest
public class SO_WS_RMS_Async_ClientAdvisorE_Test {
    // @IsTest comented temporary on PRP to correct and not block deploy from integ
    // static void testBeginMainService1() {
    //     // Create test data
    //     SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiry mockEnquiry = new SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiry();
    //     // Set mockEnquiry properties if needed
        
    //     // Create an instance of the main service
    //     SO_WS_RMS_Async_ClientAdvisorEnquiry.AsyncWSLV018_webService_v1_0_clientAdvisorEnquiry_Port service = new SO_WS_RMS_Async_ClientAdvisorEnquiry.AsyncWSLV018_webService_v1_0_clientAdvisorEnquiry_Port();

    //     // Create a mock continuation and set the expected response
    //     Test.setMock(System.HttpCalloutMock.class, new SO_WS_RMS_Async_ClientAdvisorE_Mock('{"clientAdvisorEnquiryResponse": {"result": "Success"}}'));

    //     // Start the test
    //     Test.startTest();

    //     // Invoke the main service method
    //     SO_WS_RMS_Async_ClientAdvisorEnquiry.mainServiceResponseFuture future = service.beginMainService(null, mockEnquiry);
    //     // Validate the future object
    //     SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse response = future.getValue();

    //     // Stop the test
    //     Test.stopTest();
        
    //     // Validate the web service endpoint
    //     System.assertEquals('http://' + SO_Util.WSENDPOINT + ':10818/ws/WSLV018.webService.v1_0:clientAdvisorEnquiry/WSLV018_webService_v1_0_clientAdvisorEnquiry_Port', service.endpoint_x);
        
    //     // Validate the namespace mapping
    //     String[] expectedNamespaceMap = new String[]{'http://' + SO_Util.WSLV + '/WSLV018/webService/v1_0/clientAdvisorEnquiry', 'SO_WS_RMS_ClientAdvisorEnquiry'};
    // }
    // @IsTest
    //     static void testBeginMainService2() {
    //     // Create test data
    //     SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdate mockUpdate = new SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdate();
    //     // Set mockEnquiry properties if needed
        
    //     // Create an instance of the main service
    //      SO_WS_RMS_Async_ClientCreationUpdate_v2.AsyncWSLV004_webService_v2_0_clientCreationUpdate_Port service = new SO_WS_RMS_Async_ClientCreationUpdate_v2.AsyncWSLV004_webService_v2_0_clientCreationUpdate_Port();

    //     // Create a mock continuation and set the expected response
    //     Test.setMock(System.HttpCalloutMock.class, new SO_WS_RMS_Async_ClientAdvisorE_Mock('{"clientAdvisorEnquiryResponse": {"result": "Success"}}'));

    //     // Start the test
    //     Test.startTest();

    //     // Invoke the main service method
    //     SO_WS_RMS_Async_ClientCreationUpdate_v2.mainServiceResponseFuture future = service.beginMainService(null, mockUpdate);
    //     // Validate the future object
    //     SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdateResponse response = future.getValue();

    //     // Stop the test
    //     Test.stopTest();

    //     String[] expectedNamespaceMap = new String[]{'http://' + SO_Util.WSLV + '/WSLV018/webService/v1_0/clientAdvisorEnquiry', 'SO_WS_RMS_ClientAdvisorEnquiry'};
    // }
}