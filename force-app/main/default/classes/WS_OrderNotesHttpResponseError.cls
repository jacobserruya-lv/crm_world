public with sharing class WS_OrderNotesHttpResponseError extends WS_OrderNotesHttpResponse{
    public List<Errors> errors = new List<Errors>();

    public class Errors {
        public String code;
        public String message;
    }
    public WS_OrderNotesHttpResponseError(Exception ex) {
        this.success = 'False';
        // this.data = null;
        this.codeResponse = 'ERROR';
        this.messageResponse = ex.getMessage();
        Errors er = new Errors();
        er.message = this.messageResponse;
        this.errors.add(er);
    }
}