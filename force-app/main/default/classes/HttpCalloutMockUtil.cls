public class HttpCalloutMockUtil implements HttpCalloutMock {

    private class CustomException extends Exception {}

    private Map<String,HttpResponseMock> mocks;
    private String dummyUrl = 'dummy/url/';

    public HttpCalloutMockUtil() {
        this.setMock(new HttpResponseMock());
    }

    public HTTPResponse respond(HTTPRequest req) {
        if (this.mocks == null || this.mocks.isEmpty()) {
            throw new CustomException('No mock has been defined');
        }
        else {
            return this.buildResponseMock(req);
        }
    }
    
    public void setMock(HttpResponseMock mock) { // set single mock
        this.mocks = new Map<String,HttpResponseMock> { dummyUrl => mock };
    }

    public void addMock(String requestEndpoint, HttpResponseMock mock) {
        if (this.isSingleMockDefined()) {
            this.mocks = new Map<String,HttpResponseMock>();
        }
        this.mocks.put(requestEndpoint, mock);
    }

    /************************************************************************************************ */

    private HTTPResponse buildResponseMock(HTTPRequest req) {
        String key = (this.isSingleMockDefined() ? dummyUrl : req.getEndpoint());
        return this.mocks.get(key).getResponse();
    }

    private Boolean isSingleMockDefined() {
        return (this.mocks.size() == 1 && this.mocks.containsKey(dummyUrl)) ? true : false;
    }

}