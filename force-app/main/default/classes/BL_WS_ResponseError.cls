/**
 * 
 * @author Aliza Reishtein
 * @since March 2019
 * @description The error structure to be returned to the caller of the Custom Rest Webservice
 * @group balink Webservices General
 */
public class BL_WS_ResponseError {
    public String message {get; set;}
    public String errorCode {get; set;}
    public String logId {get; set;}
    public String errorMessage {get; set;}
    public String [] fields {get; set;}

    public BL_WS_ResponseError(String message, String errorCode, List<String> fields, String errorMessage,string logId) {
        this.message = message;
        this.errorCode = errorCode;
        this.fields = fields;
        this.errorMessage = errorMessage;
        this.logId = logId;
    }
}