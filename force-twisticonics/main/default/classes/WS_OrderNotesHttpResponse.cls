global with sharing virtual class WS_OrderNotesHttpResponse {

	
    // private static final String STATUS_ERROR = 'Error';
    // private static final String STATUS_SUCCESS = 'Success';
    // private static final String STATUS_NOT_FOUND = 'Not Found';

    //public httpResultInterface data;
    public String success;
    public String codeResponse;
    public String messageResponse;
    
    // public WS_OrderNotesHttpResponse(httpResultInterface data) {
    public WS_OrderNotesHttpResponse() {
        this.success = 'True';
        // this.data = data;
        this.codeResponse = 'SUCCESS';
        this.messageResponse = null;
    }
    
}