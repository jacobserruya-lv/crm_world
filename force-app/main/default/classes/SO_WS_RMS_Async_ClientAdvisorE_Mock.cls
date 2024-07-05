public class SO_WS_RMS_Async_ClientAdvisorE_Mock implements HttpCalloutMock {
    private String response;
    
    public SO_WS_RMS_Async_ClientAdvisorE_Mock(String response) {
        this.response = response;
    }
    
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody(response);
        res.setStatusCode(200);
        return res;
    }
}