/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-29-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ICX_WS_Manual_Merge {

    // TECH_IntegrationManager__c IntegrationManagerManualMerge;
    // String requestBody;

    public ICX_WS_Manual_Merge() {

    }


    class clientToMergeObj {
        public String dreamId;	
        public String salesforceId;	
        public String userIdentitySalesforceId;	
    }

    // @AuraEnabled(cacheable=true)
    @AuraEnabled
    @future(callout=true)
    public static void Merge_TECH_IntegrationManager_Creation(String clientToMerge) {
        System.debug('clientToMerge: ' + clientToMerge);
        
        // Create a new record of type TECH_IntegrationManager__c
        TECH_IntegrationManager__c record = new TECH_IntegrationManager__c();
        record.ApexMethod__c = 'ManualMergeAPI';
        record.Object_Name__c = 'Manual_Merge';
        record.Other_Details__c = clientToMerge;
        record.Retry__c = 0; // TODO - check if needed
        record.Trigger_Event__c = 'CREATION';
        record.OwnerId = UserInfo.getUserId();

        System.debug('before insert record: ' + record);
        
        insert record;
        System.debug('after insert record: ' + record);
    }

    public static void ManualMerge(String IntegrationManagerId) {
        try {
            List<TECH_IntegrationManager__c> IntegrationManagerList = [SELECT id, Other_Details__c, Done__c, Retry__c, Error__c, Error_Status__c FROM TECH_IntegrationManager__c WHERE Id = :IntegrationManagerId];
            System.debug('IntegrationManagerList: ' + IntegrationManagerList);
            TECH_IntegrationManager__c IntegrationManager = IntegrationManagerList[0];
            System.debug('IntegrationManager: ' + IntegrationManager);
            ManualMerge_Setting__c ManualMergeSetting = ManualMerge_Setting__c.getOrgDefaults();
            System.debug('ManualMergeSetting: ' + ManualMergeSetting);
            List<String> errorCodes = ManualMergeSetting.codeErrorToRetry__c.split(';');
            System.debug('errorCodes: ' + errorCodes);


          
            


            if (IntegrationManagerList.size() > 0 && IntegrationManager != null && IntegrationManager.Other_Details__c != null && ManualMergeSetting != null 
                && errorCodes != null && errorCodes.size() > 0) {
                
                System.debug('IntegrationManager.Done__c: ' + IntegrationManager.Done__c);
                
                Boolean needToCall = false;
                if(IntegrationManager.Done__c == false) {
                    if(IntegrationManager.Error__c == true && IntegrationManager.Retry__c < Integer.valueOF(ManualMergeSetting.Retry__c) && errorCodes.contains(String.valueOf(IntegrationManager.Error_Status__c))) {
                        IntegrationManager.Retry__c = IntegrationManager.Retry__c + 1;
                        needToCall = true;
                    } else if (IntegrationManager.Error__c == false) {
                        needToCall = true;
                    }
                }
                
                if(needToCall) {
                    String jsonBody = generateRequestBody(IntegrationManager.Other_Details__c);
                    
                    if(jsonBody != null && jsonBody != '') {
                        Queueable job = new QueueableManualMergeAPI(IntegrationManager, jsonBody); //cannot enqueue more than 5 jobs due to SF limitation --> cannot do more than 4 retry
                        System.enqueueJob(job);
                        // ManualMergeAPI(IntegrationManager, jsonBody);
                    }
                }
            }                
        }
        catch(Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }

    public static String generateRequestBody(String clientToMerge) {
        User currentUser = [SELECT id, Name, FirstName, LastName, RMS_ID__c, UserName, DefaultStore__c, Country__c, WWEmployeeNumber__c
                            FROM User 
                            WHERE Id = :UserInfo.getUserId()];
        
        // Construct the JSON request body
        Map<String, Object> jsonBody = new Map<String, Object>();

        jsonBody.put('auditTrail', getAuditTrailMap(currentUser));
  
        List<clientToMergeObj> clientToMergeJSON = (List<clientToMergeObj>) JSON.deserialize(clientToMerge, List<clientToMergeObj>.class);
        System.debug('nao clientToMergeJSON '+clientToMergeJSON);
        jsonBody.put('clients', clientToMergeJSON);
        System.debug('nao clients serilize '+JSON.serialize(jsonBody));
        
        jsonBody.put('mergingContext', getMergingContextMap(currentUser));
    
        String jsonString = JSON.serialize(jsonBody);
        System.debug('jsonStringRequest: ' + jsonString);
        
        return jsonString;
    }

    private static Map<String, Object> getAuditTrailMap(User currentUser) {
        Map<String, Object> auditTrailMap = new Map<String, Object>();
        auditTrailMap.put('sourceApplicationCode', TR_Constants.SOURCEAPPCODE);
        auditTrailMap.put('touchApplicationCode', TR_Constants.APP_CODE);
        auditTrailMap.put('touchApplicationLabel', TR_Constants.APP_NAME);
        auditTrailMap.put('userLogin', currentUser.Username);
        auditTrailMap.put('userName', currentUser.Name);
        auditTrailMap.put('clientTimestamp', Datetime.now());
        auditTrailMap.put('storeCode', currentUser.DefaultStore__c);
        auditTrailMap.put('countryCodeIso', currentUser.Country__c);
        auditTrailMap.put('clientServiceCenterCode', '');
        auditTrailMap.put('deviceNumber', ''); // TODO - should be UserDevice.DeviceNativeUid
        return auditTrailMap;
    }  

    // private Map<String, Object> getMergingContextMap(String requestDate, String firstName, String lastName, String rmsId, String salesforceId, String worldwideEmployeeNumber) {
    private static Map<String, Object> getMergingContextMap(User currentUser) {
        
        Map<String, Object> mergingContextMap = new Map<String, Object>();
        
        // requestDate
        // String requestDate = String.valueOf(Datetime.now());
        Datetime requestDate = Datetime.now();
        mergingContextMap.put('requestDate', requestDate);
        
        // user
        Map<String, Object> userMap = new Map<String, String>();
        userMap.put('firstName', currentUser.FirstName);
        userMap.put('lastName', currentUser.LastName);

        // String rmsId = currentUser.RMS_ID__c != null ? currentUser.RMS_ID__c : '';
        // userMap.put('rmsId', rmsId);
        userMap.put('rmsId', currentUser.RMS_ID__c != null ? currentUser.RMS_ID__c : '');
        userMap.put('salesforceId', currentUser.Id);
        userMap.put('worldwideEmployeeNumber', currentUser.WWEmployeeNumber__c != null ? currentUser.WWEmployeeNumber__c : '');
        
        mergingContextMap.put('user', userMap);
        
        // device
        // List<UserDevice> currentUserDeviceList = [SELECT id, BrowserType, DeviceNativeUid, DeviceType, Name, PlatformType, PlatformVersion, Status, UserId
        //                                           FROM UserDevice 
        //                                           WHERE UserId = :currentUser.id];

        Map<String, Object> deviceMap = new Map<String, Object>();
        // if (currentUserDeviceList.size() > 0 && currentUserDeviceList[0] != null) {
        //     UserDevice currentUserDevice = currentUserDeviceList[0];
        //     deviceMap.put('browserType', currentUserDevice.BrowserType);
        //     deviceMap.put('nativeUid', currentUserDevice.DeviceNativeUid);
        //     deviceMap.put('type', currentUserDevice.DeviceType);
        //     deviceMap.put('name', currentUserDevice.Name);
            
        //     Map<String, String> platformMap = new Map<String, String>();
        //     platformMap.put('name', ''); // TODO - Not available yet --> need a setting enable from SF side
        //     platformMap.put('type', currentUserDevice.PlatformType);
        //     platformMap.put('version', currentUserDevice.PlatformVersion);
            
        //     deviceMap.put('platform', platformMap);
            
        //     deviceMap.put('status', currentUserDevice.Status);
        //     deviceMap.put('userId', currentUserDevice.UserId);
        // } else {
            deviceMap.put('browserType', ''); // TODO - Empty for testing --> Not for deployment ! ! !
            deviceMap.put('nativeUid', '');
            deviceMap.put('type', '');
            deviceMap.put('name', '');
    
            Map<String, String> platformMap = new Map<String, String>();
            platformMap.put('name', ''); // TODO - Not available yet --> need a setting enable from SF side
            platformMap.put('type', '');
            platformMap.put('version', '');
    
            deviceMap.put('platform', platformMap);
    
            deviceMap.put('status', '');
            deviceMap.put('userId', '');
    
            mergingContextMap.put('device', deviceMap);
        // }
        

        return mergingContextMap;
    }  

    public static void ManualMergeAPI(TECH_IntegrationManager__c IntegrationManager, String jsonBody) { // TECH_IntegrationManager__c record

        // Initialize a new http object
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Set the endpoint URL using the Named Credential
        String callout = 'callout:MULESOFT_CLIENT_360';
        String endpoint = '/cst-eu/sfdc-client-eapi/v1/clients/merge/manual-merging-demands';
        String url = callout + endpoint;
        
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Encoding', 'UTF-8');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('client_id', '{!$Credential.UserName}');
        request.setHeader('client_secret', '{!$Credential.Password}');
        
        try {
            // Set the body of the request
            request.setBody(jsonBody);

            // Make the HTTP request
            HttpResponse response = http.send(request);

            // Handle the response 
            handleResponse(response, IntegrationManager, url, jsonBody);


        } catch(Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }
    
    public static void handleResponse(HttpResponse response, TECH_IntegrationManager__c IntegrationManager, String endPoint, String jsonBody) {
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            IntegrationManager.Done__c = true;
            IntegrationManager.Error__c = false;
            IntegrationManager.Error_Status__c = '';

             ICX_Utils.createIconicsLogs('ICONICS - C360', 'ICX_WS_Manual_Merge' , endPoint, response.getBody(),jsonBody, 'INFO', String.valueOf(response.getStatusCode()));
          //  Queueable job = new QueueableIconicsLogs(endPoint, jsonBody, response.getBody(), 'INFO', String.valueOf(response.getStatusCode()));
            //System.enqueueJob(job);
            
            // Deserialize the JSON string into collections of primitive data types.
            // Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        }
        
        // If the request returned an error code 502 or 504 retry ManualMerge.
        else {
            IntegrationManager.Done__c = false;
            IntegrationManager.Error__c = true;
            IntegrationManager.Error_Status__c = String.valueOf(response.getStatusCode());
             ICX_Utils.createIconicsLogs('ICONICS - C360', 'ICX_WS_Manual_Merge' , endPoint, response.getBody(),jsonBody, 'ERROR', String.valueOf(response.getStatusCode()));
            //Queueable job = new QueueableIconicsLogs(endPoint, jsonBody, response.getBody(), 'ERROR', String.valueOf(response.getStatusCode());
            //System.enqueueJob(job);
        }

        update IntegrationManager;
    }
}