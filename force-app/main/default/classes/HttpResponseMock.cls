public class HttpResponseMock {
    
    private Map<String,String> headers;
    private Integer statusCode;
    private String status;
    private String body;

    public HttpResponseMock() {
        this.headers = new Map<String,String>();
        this.setHeaderContentType('application/json');
        this.statusCode = 200;
        this.status = 'OK';
        this.body = '';
    }

    public HttpResponseMock(Map<String,String> headers, Integer statusCode, String status, String body) {
        this.headers = headers;
        this.statusCode = statusCode;
        this.status = status;
        this.body = body;
    }

    public HttpResponseMock addHeader(String headerKey, String headerValue) {
        this.headers.put(headerKey, headerValue);
        return this;
    }

    public HttpResponseMock setHeaderContentType(String contentType) { // for convenience
        this.addHeader('Content-Type', contentType);
        return this;
    }

    public HttpResponseMock setStatusCode(Integer statusCode) {
        this.statusCode = statusCode;
        return this;
    }

    public HttpResponseMock setStatus(String status) {
        this.status = status;
        return this;
    }

    public HttpResponseMock setBody(String body) {
        this.body = body;
        return this;
    }

    public HttpResponseMock setBody(Map<String,Object> body) {
        this.setBody(JSON.serialize(body));
        return this;
    }

    public HTTPResponse getResponse() {
		HttpResponse response = new HttpResponse();
        this.buildHeaders(response);
		response.setStatusCode(this.statusCode);
        response.setStatus(this.status);
        response.setBody(this.body);
		return response;
	}

    /***************************************************************************************************************************/

    private void buildHeaders(HttpResponse response) {
        for (String key : this.headers.keySet()) {
            response.setHeader(key, this.headers.get(key));
        }
    }
}