public with sharing class ICX_Utils {
    public ICX_Utils() {}

    public static String getUUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        system.debug(guid);
        return guid;
    }

    public static Logs createLogsObject(Boolean isFuture, String application, String apexClass, String endpoint, String responseBody, String requestBody, String level, String statusCode) {

        Logs log  = new Logs(new Map<String,Object> {
            'level' => level, 
            'apexClass' => apexClass, 
            'endpoint' => endpoint,
            'request' => requestBody,
            'isFuture' => isFuture,
            'response' => responseBody,
            'status_code' => statusCode,
            'details' => responseBody,
            'application' => application
        });

        system.debug('ICX_Utils createLogsObject : ' + log);
        return log;
    }



    @future
    public static void createIconicsLogsWithInsert(String application, String apexClass, String endpoint, String responseBody, String requestBody, String level, String statusCode) {

        Logs log = createLogsObject(true, application, apexClass, endpoint, responseBody, requestBody, level, statusCode);

        system.debug('ICX_Utils createIconicsLogsWithInsert : ' + log);
        log.insertLog();
    }

    
    public static void createIconicsLogs(String application, String apexClass, String endpoint, String responseBody, String requestBody, String level, String statusCode) {

        Logs log  = createLogsObject(false, application, apexClass, endpoint, responseBody, requestBody, level, statusCode);

        system.debug('ICX_Utils createIconicsLogs : ' + log);
    }
}