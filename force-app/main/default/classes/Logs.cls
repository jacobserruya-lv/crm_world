/**
    About
    -----
    Description: Utils to create log 
    Created for: Louis Vuitton Projects
    Create date: January 2019

    Details
    -------
    Create record of Logs__c object
*/
public virtual without sharing class Logs {

    @testVisible private String level {get;set;}
    @testVisible private String apexClass;
    @testVisible private String category;
    @testVisible private String application;

    @testVisible private String message;
    @testVisible private String status_code;
    @testVisible private String type;
    @testVisible private String details;
    @testVisible private String recordId;

    @testVisible private String endpoint;
    @testVisible private String request;
    @testVisible private String headers;
    @testVisible private String parameters;
    @testVisible private String response;
    @testVisible private String addressIp;

    @testVisible private Boolean needSalesforceIp;
    @testVisible private Boolean isFuture;

    @testVisible private HTTP_Utils http;
    @testVisible private Logs__c log;
    @testVisible private Exception exception_case;
    
    public Logs (Map<String, Object> logMap) {

        this.level = (String) logMap.get('level');
        this.apexClass = (String) logMap.get('apexClass');
        this.category = (String) logMap.get('category');
        this.application = (String) logMap.get('application');
        
        this.message = (String) logMap.get('message');
        this.status_code = (String) logMap.get('status_code');
        this.type = (String) logMap.get('type');  
        this.details = (String) logMap.get('details');
        this.recordId = (String) logMap.get('recordId');

        this.endpoint = (String) logMap.get('endpoint');
        this.request = (String) logMap.get('request');
        this.headers = (String) logMap.get('headers');
        this.parameters = (String) logMap.get('parameters');
        this.response = (String) logMap.get('response');
        this.addressIp = (String) logMap.get('addressIp');   

        this.exception_case = (Exception) logMap.get('exception_case');
        this.http = (HTTP_Utils) logMap.get('http');

        if(logMap.get('isFuture') != null ) {
            this.isFuture = (Boolean) logMap.get('isFuture');
        } else {
            this.isFuture = false;
        }

        if(logMap.get('needSalesforceIp') != null) {
            this.needSalesforceIp = (Boolean) logMap.get('needSalesforceIp');
        } else {
            this.needSalesforceIp = false;
        }

        write();
    }

    // DEFAULT CONSTRUCTOR
    private Logs (String level, String apexClass, String category) {
        this.level = level;
        this.apexClass = apexClass;
        this.category = category;
        this.isFuture = false;
        this.needSalesforceIp = false;
    }

    //CONSTRUCTOR 1
    private Logs (String level, String apexClass, String category, Exception exception_case) {
        this(level, apexClass, category);
        this.exception_case = exception_case;
    }

    // CONSTRUCTOR 2
    private Logs (String level, String apexClass, String category, Exception exception_case, String details) {
        this(level, apexClass, category, exception_case);
        this.details = details;
    }

    // CONSTRUCTOR 3
    private Logs (String level, String apexClass, String category, Exception exception_case, String details, String recordId) {
        this(level, apexClass, category, exception_case, details);
        this.recordId = recordId;
    }

    // CONSTRUCTOR 4
    private Logs (String level, String apexClass, String category, String message) {
        this(level, apexClass, category);
        this.message = message;
    }

    // CONSTRUCTOR 5
    private Logs (String level, String apexClass, String category, String message, String details) {
        this(level, apexClass, category);
        this.message = message;
        this.details = details;
    }

    // CONSTRUCTOR 6
    private Logs (String level, String apexClass, String category, String endpoint, String request, String response) {
        this(level, apexClass, category);
        this.endpoint = endpoint;
        this.request = request;
        this.response = response;
    }

    // CONSTRUCTOR 7 -- ALL
    private Logs (String level, String apexClass, String category, String endpoint, String request, String response, 
        Exception exception_case, String details, String recordId, String message, String addressIp, Boolean needSalesforceIp) {
        
        this.level = level;
        this.apexClass = apexClass;
        this.category = category;

        this.exception_case = exception_case;
        this.details = details;
        this.recordId = recordId;
        this.message = message;

        this.response = response;
        this.endpoint = endpoint;
        this.request = request;
        this.addressIp = addressIp;
        this.needSalesforceIp = needSalesforceIp;

        this.isFuture = false;
    }

    // CONSTRUCTOR 8
    private Logs (String level, String apexClass, String category, String message, String details, String recordId, String status_code) {
        this(level, apexClass, category, message, details);
        this.recordId = recordId;
        this.status_code = status_code;
    }

    private Boolean isAuthorized(){

        // GET MODE
        LogsSetting__mdt settings = getSettings(apexClass, level);

        // PER-USER MODE
        if(settings.Mode__c == 'Per-User'){
            return [SELECT Id, Is_Tracked_Logs__c FROM User WHERE Id = : UserInfo.getUserId()].Is_Tracked_Logs__c;
        }

        // ALWAYS RUN MODE 
        return true;
        
    }

    private LogsSetting__mdt getSettings(String apexClass, String level){

        List<LogsSetting__mdt> settings = [
            SELECT Mode__c, Level__c, Clean_Up_Every__c
            FROM LogsSetting__mdt 
            WHERE Apex_Class__c =: apexClass AND (Level__c = null OR Level__c = 'ALL' OR Level__c =: level) AND IsActive__c = true
        ];

        if(settings.isEmpty() || String.isEmpty(apexClass)){
            String message = 'The Apex_Class__c has not a correct value.\n' + 
                             'If you want to log this class, please add it to the LogsSetting__mdt and to Logs__c picklist values. ' +
                             'And assure you that the settings are activated.';

            throw new CustomLogException(message);
        }

        LogsSetting__mdt global_settings;
        for(LogsSetting__mdt setting : settings){
            if(String.isEmpty(setting.Level__c) || setting.Level__c == 'ALL'){
                global_settings = setting;
            }
            else if(!String.isEmpty(setting.Level__c)){
                 return setting;
            }
        }

        return global_settings;
    }

    private void write() {
        try{

            if(isAuthorized()){
                Logs__c log = new Logs__c(
                    Level__c = level,
                    Apex_Class__c = apexClass,
                    Category__c = category,
                    Message__c = message,
                    Status_Code__c = status_code,
                    Type__c = type,

                    // API 
                    API_Endpoint__c = endpoint,
                    API_Headers__c = headers,
                    API_Parameters__c = parameters,
                    API_Request__c = request,
                    API_Response__c = (!String.isEmpty(response) ? response.left(50000) : null),

                    // OTHER DETAILS
                    Other_Details__c = details, 
                    Application__c = application,  
                    Record_Id__c = recordId
                );

                // EXCEPTION
                if(exception_case != null){
                    log.Type__c = exception_case.getTypeName();
                    log.Trace__c = exception_case.getStackTraceString();
                    log.Message__c = exception_case.getMessage();

                    if(exception_case.getTypeName() == 'System.DmlException' || exception_case.getTypeName() == 'DmlException' ||
                        exception_case.getTypeName() == 'System.EmailException' || exception_case.getTypeName() == 'EmailException'){
                        log.Status_Code__c = String.valueOf(((System.DmlException)exception_case).getDmlType(0));
                    }
                }

                // HTTP CONTEXT
                if(http != null){
                    log.API_Request__c = http.request.getBody();
                    log.API_Endpoint__c = http.request.toString();
                    log.API_Headers__c = JSON.serialize(http.headers);
                    log.API_Response__c = http.response.getBody();

                    if(String.isEmpty(message)){
                        log.Message__c = log.API_Response__c;
                    }
                }

                // REST CONTEXT
                if(String.isEmpty(endpoint) && RestContext.request != null){
                    log.API_Request__c = RestContext.request.requestBody.toString();
                    log.API_Endpoint__c = RestContext.request.requestURI;
                    log.API_Parameters__c = RestContext.request.params.size() > 0 ? String.valueOf(RestContext.request.params) : '';
                    log.API_Headers__c = JSON.serialize(RestContext.request.headers);
                    log.Remote_Address__c = RestContext.request.remoteAddress;
                }

                // REMOTE ADDRESS
                if(String.isEmpty(log.Remote_Address__c) && needSalesforceIp) {
                    log.Remote_Address__c = getSalesforceIp();
                }

                if(String.isEmpty(log.Status_Code__c)){
                    log.Status_Code__c = String.isEmpty(log.Message__c) ? null : log.Message__c.left(255);
                }

                if(isFuture){
                    this.log = log;
                }
                else {
                    insert log;
                }
            }

        }
        catch(Exception ex){
            System.debug('An error occured: ' + ex.getMessage());
            System.debug(ex.getStackTraceString());
        }
    }

    private String getSalesforceIp(){
        try{
            HTTP_Utils resp = new HTTP_Utils()
                .get('http://icanhazip.com/')
                .call();
            return resp.responseBody();
        }
        catch(Exception ex){ 
            return null;
        }
    }

    public void insertLog(){
        try{
            insert log;
        }
        catch(Exception ex){
            System.debug('An error occured: ' + ex.getMessage());
            System.debug(ex.getStackTraceString());
        }
    }

    /*
    *** DESCRIPTION Update a prospect account
    */
    @future
    public static void willWrite(String jsonData) {
        try{
            Logs__c log = (Logs__c)JSON.deserialize(jsonData, Logs__c.Class);
            insert log;
        }
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }

    /*
        ERROR LEVEL
    */
    public class ERROR extends Logs {

        // CONSTRUCTOR 1
        public ERROR (String apexClass, String category, Exception exception_case) {
            super('ERROR', apexClass, category, exception_case);
            write();
        }

        // CONSTRUCTOR 2
        public ERROR (String apexClass, String category, Exception exception_case, String details) {
            super('ERROR', apexClass, category, exception_case, details);
            write();
        }

        // CONSTRUCTOR 3
        public ERROR (String apexClass, String category, Exception exception_case, String details, String recordId) {
            super('ERROR', apexClass, category, exception_case, details, recordId);
            write();
        }

        // CONSTRUCTOR 4
        public ERROR (String apexClass, String category, String message) {
            super('ERROR', apexClass, category, message);
            write();
        }

        // CONSTRUCTOR 5
        public ERROR (String apexClass, String category, String message, String details) {
            super('ERROR', apexClass, category, message, details);
            write();
        }

        // CONSTRUCTOR 6
        public ERROR (String apexClass, String category, String endpoint, String request, String response) {
            super('ERROR', apexClass, category, endpoint, request, response);
            write();
        }
    }

    /*
        INFO LEVEL
    */
    public class INFO extends Logs {

        // CONSTRUCTOR 4
        public INFO (String apexClass, String category, String message) {
            super('INFO', apexClass, category, message);
            write();
        }

        // CONSTRUCTOR 5
        public INFO (String apexClass, String category, String message, String details) {
            super('INFO', apexClass, category, message, details);
            write();
        }

        // CONSTRUCTOR 8
        public INFO (String apexClass, String category, String message, String details, String recordId, String status_code) {
            super('INFO', apexClass, category, message, details, recordId, status_code);
            write();
        }
    }

    /*
        WARN LEVEL
    */
    public class WARN extends Logs {

        // CONSTRUCTOR 4
        public WARN (String apexClass, String category, String message) {
            super('WARN', apexClass, category, message);
            write();
        }
    }

    /*
        DEBUG LEVEL
    */
    public class DEBUG extends Logs {

        // CONSTRUCTOR 4
        public DEBUG (String apexClass, String category, String message) {
            super('DEBUG', apexClass, category, message);
            write();
        }
    }

    /*
        FUTURE
    */
    public class FUTURE extends Logs {

        // CONSTRUCTOR 7
        public FUTURE (String level, String apexClass, String category, String endpoint, String request, String response, 
            Exception exception_case, String details, String recordId, String message, String addressIp, Boolean needSalesforceIp) {
            super(level, apexClass, category, endpoint, request, response, exception_case, details, recordId, message, addressIp, needSalesforceIp);
            this.isFuture = true;
            write();
        }
    }

    public class CustomLogException extends Exception {}
}