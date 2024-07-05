/**
 * File         HTTP_Utils.cls
 * Date         Oct 2018
 * Description  chainable httpRequest Util class.
 **********************************************************
 * History
 **********************************************************
 * Date:                ModifiedBy:             Description:
 *
 */
public with sharing class HTTP_Utils {

    public String url;
    public String method;
    public HttpRequest request;
    public HttpResponse response;
    public Map<String,String> responseJsonParsed;
    public Map<String, Object> responseJsonBody;
    public Map<String,String> headers;
    public Map<String,String> urlParams;
    public static final Http http;

    private static Boolean useMockWhenTestIsRunning = false;
    
    static{
        http = new Http();
    }

    //Initialize the HttpReqest and headers
    public HTTP_Utils(){
        this.request = new HttpRequest();
        this.headers = new Map<String,String>();
    }

    // Set body
    public HTTP_Utils body(String body){
        request.setBody(body);
        return this;
    }

    // Set the url for a get request.
    public HTTP_Utils get(String url){
        setMethodAndUrl('GET', url);
        return this;
    }

    //set the url for put request
    public HTTP_Utils put(String url){
       setMethodAndUrl('PUT', url);
       return this;
    }

    //set the url for post request
    public HTTP_Utils post(String url){
       setMethodAndUrl('POST', url);
       return this;
    }

    /*This is special header for DWOCAPI*/
    public HTTP_Utils patch(String url){
       setMethodAndUrl('PUT', url);
       return this;
    }

    // Set the url for delete request
    public HTTP_Utils del(String url){
       setMethodAndUrl('DELETE',url);
       return this;
    }

    // Set the request headers as value - key pair
    public HTTP_Utils header(String key, String value){
        headers.put(key,value);
        return this;
    }

    // add all request headers as map<String,String> value-key
    public HTTP_Utils addHeaders(Map<String,String> allHeaders){
        if (allHeaders == null || allHeaders.isEmpty()) {
            return this;
        }
        headers.putAll(allHeaders);
        return this;
    }

    // Set timeout
    public HTTP_Utils timeout(Integer timeout){
        request.setTimeout(timeout);
        return this;
    }

    // Set Set Client Certificate
    public HTTP_Utils certificate(String certDevName){
        request.setClientCertificateName(certDevName);
        return this;
    }

    //Sends the request to the endpoint.
    public HTTP_Utils call(){
        if(!headers.isEmpty()){
            for(String key : this.headers.keyset()) {
                request.setHeader(key,headers.get(key));
            }
        }
        if (!Test.isRunningTest()){
            System.debug('REQUEST: ' + request);
            response = http.send(request);
            System.debug('RESPONSE: ' + response);
            System.debug('RESPONSE BODY:' + response.getBody());
        }
        else{
            response = useMockWhenTestIsRunning ? http.send(request) : new HttpResponse();
        }

        return this;
    }

    public HttpRequest getRequest() {
        return this.request;
    }

    //Returns the response
    public HttpResponse getResponse(){
        return this.response;
    }

    // Returns request body
    public String responseBody(){
        return this.response.getBody();
    }

    // Returns the headers.
    public Map<String,String> getHeaders(){
        return this.headers;
    }

    //Returns the status of the response
    public String status(){
        return response.getStatus();
    }

    //Returns the statuscode of the response.
    public Integer statusCode(){
        return response.getStatusCode();
    }
    
    //Private method sets the method and url to the HttpRequest object
    private void setMethodAndUrl(String method, String url){
        request.setMethod(method);
        request.setEndpoint(url);
    }

    public Map<String,String> getParameters() {
        try{
            if (this.responseJsonParsed == null){
                String body = this.responseBody();
                Map<String,String> resultMap = new Map<String,String>();
                JSONParser parser = JSON.createParser(body);
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                        String key = parser.getText();
                        parser.nextToken();
                        String value = parser.getText();
    
                        resultMap.put( key, value);
                    }
                }
                this.responseJsonParsed = resultMap;
            }
            
            return this.responseJsonParsed;
        } catch(Exception ex){
            system.debug(ex.getMessage());
            return new Map<String,String>();
        }
        
    }

    public Map<String, Object> getBodyResponse(){
        if(this.responseJsonBody == null){
            try{
                this.responseJsonBody = (Map < String, Object > ) JSON.deserializeUntyped(this.responseBody());
            } catch (Exception e){
                try{
                    this.responseJsonBody = new Map<String, Object>();
                    this.responseJsonBody.put('results', (List < Object > ) JSON.deserializeUntyped(this.responseBody()));
                }catch(Exception e2){
                    System.debug(e2.getMessage());
                }
            }
            
        }
        return this.responseJsonBody;
    }

    public static String getBasicAuthentication(String username, String password){
        String payload = username + ':' + password;
        return EncodingUtil.base64Encode(Blob.valueOf(payload));
    }

    public static void setUseMockWhenTestIsRunning(Boolean b) {
        useMockWhenTestIsRunning = b;
    }

    public class Custom_Exception extends Exception { }
}