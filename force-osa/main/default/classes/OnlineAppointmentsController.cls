global with sharing class OnlineAppointmentsController {
 
    public String accountName { get; set; }
    public static Object accountList{ get; set; }
     
    //Remote Function
    @RemoteAction
    global static Object getAvailabilities(String params) {        
                           
        Map<String, Object> paramsList = (Map<String, Object>) JSON.deserializeUntyped(params);     

        User currentUser = getUserInfos();
        
        String storeCode =  paramsList.get('storeCode') != null ? (String) paramsList.get('storeCode'):   currentUser.DefaultStore__c;
        
        String startDate = (String) paramsList.get('startDate');
        String endDate = (String) paramsList.get('endDate'); 

        return OnlineAppointments_Utils.getAvailabilities(storeCode, null, startDate, endDate);          
    }
    
    
    @RemoteAction
    global static Object createAvailabilities(String params) {
       
        List<Object> paramsList =  (List<Object>) JSON.deserializeUntyped(params);
        
        Map<String, Object> availabilitiesJSON = new Map<String, Object>();
        List<DateTime> myList = new List<DateTime>();
        
        for(Object obj : paramsList){
            Map<String, Object> evObj = (Map<String, Object>) obj;
            Long longtime = (long) evObj.get('RecurrenceStartDateTime');
            myList.add(DateTime.newInstance(longtime));
        }

        Map<String, Object> evObj = (Map<String,Object>) paramsList[0];
        
        availabilitiesJSON.put('startTimes', myList);
        availabilitiesJSON.put('StoreCode', evObj.get('storeCode'));
        availabilitiesJSON.put('capacities', integer.valueof(evObj.get('capacities')));
        availabilitiesJSON.put('DurationInMinutes', 60);
        availabilitiesJSON.put('IsRecurrence', evObj.get('IsRecurrence'));
        
        Long RecurrenceStartDateTimeL = (Long) evObj.get('RecurrenceStartDateTime');
        availabilitiesJSON.put('RecurrenceStartDateTime', DateTime.newInstance(RecurrenceStartDateTimeL));
        Long RecurrenceEndDateOnlyL = (Long) evObj.get('RecurrenceEndDateOnly');
        
        DateTime RecurrenceEndDateOnlyDT = null; 
        if(RecurrenceEndDateOnlyL != null){
            RecurrenceEndDateOnlyDT = DateTime.newInstance(RecurrenceEndDateOnlyL);    
        }
        
        if(RecurrenceEndDateOnlyL != null && RecurrenceEndDateOnlyL != 0){
            availabilitiesJSON.put('RecurrenceEndDateOnly', date.newinstance(RecurrenceEndDateOnlyDT.year(), RecurrenceEndDateOnlyDT.month(), RecurrenceEndDateOnlyDT.day()));    
        }
        
        // DateTime.newInstance(RecurrenceEndDateOnlyL).Date());
        availabilitiesJSON.put('RecurrenceType', evObj.get('RecurrenceType'));
        availabilitiesJSON.put('RecurrenceInterval', integer.valueof(evObj.get('RecurrenceInterval')));
        availabilitiesJSON.put('RecurrenceDayofWeekMask', integer.valueof(evObj.get('RecurrenceDayofWeekMask')));
        //availabilitiesJSON.put('RecurrenceTimeZoneSidKey', evObj.get('RecurrenceTimeZoneSidKey'));
        availabilitiesJSON.put('RecurrenceDayOfMonth', integer.valueof(evObj.get('RecurrenceDayOfMonth')));
        

        // evRef.IsRecurrence = (Boolean) availabilitiesJSON.get('IsRecurrence');
        // evRef.RecurrenceStartDateTime = (dateTime) availabilitiesJSON.get('RecurrenceStartDateTime');
        // evRef.RecurrenceEndDateOnly = (Date) availabilitiesJSON.get('RecurrenceEndDateOnly');
        // evRef.RecurrenceType = (String) availabilitiesJSON.get('RecurrenceType');
        // evRef.RecurrenceInterval = (Integer) availabilitiesJSON.get('RecurrenceInterval');
        // evRef.RecurrenceDayofWeekMask = (Integer) availabilitiesJSON.get('RecurrenceDayofWeekMask');
        // evRef.RecurrenceTimeZoneSidKey = (String) availabilitiesJSON.get('RecurrenceTimeZoneSidKey');
               
        
        return OnlineAppointments_Utils.createAvailabilities(availabilitiesJSON);
    }

    //getOnlineAndTeamAppointments (Boolean onlyOnline, Boolean onlyUnassigned, String datesString, String startDate, String endDate)
    @RemoteAction
    global static Object upsertOnlineAppointmentDesktop(String params) {
            
        Map<String, Object> paramsList = (Map<String, Object>) JSON.deserializeUntyped(params);
        return OnlineAppointments_Utils.upsertOnlineAppointmentDesktop(paramsList);
               
    }

    //getOnlineAndTeamAppointments (Boolean onlyOnline, Boolean onlyUnassigned, String datesString, String startDate, String endDate)
    @RemoteAction
    global static Object getOnlineAndTeamAppointments(String params) {
            
        Map<String, Object> paramsList = (Map<String, Object>) JSON.deserializeUntyped(params);
        
        Boolean onlyOnline = (Boolean) paramsList.get('onlyOnline'); 
        Boolean onlyUnassigned = (Boolean) paramsList.get('onlyUnassigned');
        String datesString = (String) paramsList.get('datesString');
        String startDate = (String) paramsList.get('startDate');
        String endDate = (String) paramsList.get('endDate');
        String storeId = (String) paramsList.get('storeCode');
        return OnlineAppointments_Utils.getOnlineAndTeamAppointmentWrappers(onlyOnline, onlyUnassigned, datesString, startDate, endDate, storeId);
    }

    //cancel OSA 
    @RemoteAction
    global static Object cancelOnlineAppointmnent(String params) {
            
        Map<String, Object> paramsList = (Map<String, Object>) JSON.deserializeUntyped(params);

        String onlineAppointmentId = (String) paramsList.get('onlineAppointmentId');
        String accountId = (String) paramsList.get('accountId');

        return OnlineAppointments_Utils.cancelOnlineAppointmnent( onlineAppointmentId, accountId);
    }
     
    
    @RemoteAction
    global static User getUserInfos(){
        User u = [Select Id, DefaultStore__c, TECH_IsManager__c, FirstName, LastName, FullPhotoUrl, ProfileId, toLabel(MANAGEMENT_ZONE_LEVEL__c), toLabel(MGMT_ZONE_SUB_LEVEL1__c),toLabel(MGMT_ZONE_SUB_LEVEL3__c) From User Where ID = :UserInfo.getUserId()];
      return u;
    }

    @RemoteAction
    global static List<String> getAppointmentReasons(){

        List<String> reason = new List<String>();
        String objectName = 'Event';
        String fieldName = 'Reason__c';
        String recordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();

        Map<String, Object> response = getPicklistInfoByRecordType(objectName, recordTypeId, fieldName);  

        if(response.containsKey('values')){

            for(Object value : (List<Object>) response.get('values')){
                Map<String, Object> picklist = (Map<String, Object>) value;
                reason.add((String) picklist.get('value'));
            }
        }
        return reason;
    } 


    @RemoteAction
    global static List<Map<String,String>> getAppointmentReason(){

        List<Map<String,String>> options = new List<Map<String,String>>();
        String objectName = 'Event';
        String fieldName = 'Reason__c';
        String recordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();

        Map<String, Object> response = getPicklistInfoByRecordType(objectName, recordTypeId, fieldName);  

        if(response.containsKey('values')){

            for(Object value : (List<Object>) response.get('values')){
                Map<String, Object> picklist = (Map<String, Object>) value;

                Map<String, String> option  =  new Map<String, String>{
                    'label'=>((String) picklist.get('label')).unescapeHtml4(),
                    'value'=> (String) picklist.get('value') 
                }; 

                options.add(option);
            }
        }
        return options;
    }


    public static Map<String, Object> getPicklistInfoByRecordType( String objectName, String recordTypeId, String fieldName ){ 

        String baseUrl = '/services/data/v46.0/ui-api/object-info/';

        baseUrl += objectName + '/picklist-values/' + recordTypeId + '/' + fieldName;

        BL_HTTP_Utils request = new BL_HTTP_Utils()
        .get(URL.getSalesforceBaseUrl().toExternalForm() + baseUrl)
        .header('Authorization', 'Bearer ' + UserInfo.getSessionId())
        .header('Content-Type', 'application/json')
        .timeout(60000)
        .call();

        return request.statusCode() == 200 ? (Map<String, Object>) JSON.deserializeUntyped(request.responseBody()) : new Map<String, Object>() ;
    }
    
    
    @RemoteAction
    global static User getOneUserInfos(String id){
      User u = [Select Id, DefaultStore__c, TECH_IsManager__c, FirstName, LastName, FullPhotoUrl, ProfileId From User Where ID = :id];
        
      return u;
    }

    @RemoteAction
    global static List<Profile> getProfiles(){
        List<Profile> p = [Select Id, Name From Profile]; 
        // List<Profile> p = [Select Id, Name From Profile where Name IN ('ICON_Corporate', 'ICONiCS_Corporate', 'ICONiCS_SA_Manager', 'ICONiCS_SA', 'ICON_SA', 'System Administrator', 'ICON_SA Manager', 'ICON_SA_EVERYWHERE', 'ICON_SAManager_EVERYWHERE', 'ICON_Corporate_EVERYWHERE','ICONiCS_Care_Expert')];
        return p;
    }
    
    @RemoteAction
    global static Store__c getStoreInfos(){
      User currentUser = getUserInfos();
      if(String.isBlank(currentUser.DefaultStore__c)) {throw new OnlineAppointments_Utils.OnlineAppointmentException('USER_HAS_NO_DEFAULT_STORE');}
      Store__c s = [Select Id, Name, Time_Zone_Id__c, RetailStoreId__c, MANAGEMENT_ZONE_LEVEL_TECH__c,StoreCountry__c, AppointmentType__c From Store__c Where RetailStoreId__c =  :currentUser.DefaultStore__c]; 
      return s;
    }
    
    //getAvailableTeamUsers (Datetime startRange, Datetime endRange)
    @RemoteAction
    global static Object getAvailableTeamUsers(String params) {
        
        Map<String, Object> paramsList = (Map<String, Object>) JSON.deserializeUntyped(params);
        
        String storeCode = (String) paramsList.get('storeCode');
        String tempStart = (String) paramsList.get('startRange');
        List<String> startDateString = tempStart.split('-');
        String tempEnd = (String) paramsList.get('endRange');
        List<String> endDateString = tempEnd.split('-');
        
        Datetime startRange = DateTime.newInstance(Integer.valueOf(startDateString[0]), Integer.valueOf(startDateString[1]), Integer.valueOf(startDateString[2]), 0, 0, 0);
        Datetime endRange = DateTime.newInstance(Integer.valueOf(endDateString[0]), Integer.valueOf(endDateString[1]), Integer.valueOf(endDateString[2]), 0, 0, 0);
            
        return OnlineAppointments_Utils.getUsersByIds(OnlineAppointments_Utils.getAvailableTeamUsers(startRange, endRange, storeCode));
    }
    
    @RemoteAction
    global static List<User> getStoreUsers(String params) {
        Map<String, Object> paramsList = (Map<String, Object>) JSON.deserializeUntyped(params);
        String storeCode = (String) paramsList.get('storeCode');
        List<User> userList = OnlineAppointments_Utils.getStoreUsers(storeCode);
        return userList;
    }


    @RemoteAction
    global static List<Account> searchClients(String text){
        String searchText = text+'*';
        List<List<SObject>> searchList = [FIND :searchText IN ALL FIELDS 
        RETURNING Account(Id, toLabel(Salutation), FirstName, LastName, Name, DREAMID__c, PersonEmail, Can_Be_Contacted_By_Email__pc,
        Can_Be_Contacted_By_SMS__pc, PersonMobilePhone, PersonOtherPhone, PersonHomePhone) LIMIT 10];
        return (Account[])searchList[0];
    }

    @RemoteAction
    global static Object upsertOnlineAppointment(String params) {
            
        Map<String, Object> paramsList = (Map<String, Object>) JSON.deserializeUntyped(params);
        
        return OnlineAppointments_Utils.upsertOnlineAppointment(paramsList);
    }


    @RemoteAction
    global static Object assignAppointments(String params){
        Map<String, Object> paramsList = (Map<String, Object>) JSON.deserializeUntyped(params);
        
        return OnlineAppointments_Utils.assignAppointments((String) paramsList.get('userId'), (String) paramsList.get('onlineAppointmentId'), Boolean.valueOf(paramsList.get('reassignFromManager')));
    }


    @RemoteAction
    global static Object upsertAvailability(String params) {
            
        List<Object> availabilities =  (List<Object>) JSON.deserializeUntyped(params);
        
        Event evRef = new Event();
        if(availabilities[0] != null){
            Map<String, Object> availability = (Map<String, Object>) availabilities[0];

            //PARSE PARAMS            
            evRef.Capacity__c = integer.valueof(availability.get('definedCapacities'));
            evRef.id = String.valueOf(availability.get('id'));

            update evRef;
        }
        
        return evRef;
    }

    @RemoteAction
    global static Object updateAvailability(String params) {
        Map<String, Object> paramsMap = (Map<String, Object>) JSON.deserializeUntyped(params);
        
        //PARSE PARAMS
        String storeCode =  (paramsMap.get('storeCode')!= null ? (String) paramsMap.get('storeCode') : getUserInfos().DefaultStore__c);

        Boolean isRecurrence = (Boolean) paramsMap.get('IsRecurrence');
        String RecurrenceActivityId =  (String) paramsMap.get('RecurrenceActivityId');

        Event evRef = new Event();
        evRef.Id = (String) paramsMap.get('id');
        evRef.Capacity__c = (Integer) paramsMap.get('capacities');
        // evRef.IsRecurrence = (Boolean) paramsMap.get('IsRecurrence');
        evRef.RecurrenceStartDateTime = DateTime.newInstance((Long) paramsMap.get('RecurrenceStartDateTime'));
        evRef.StartDateTime =  DateTime.newInstance((Long) paramsMap.get('RecurrenceStartDateTime'));
        evRef.RecurrenceEndDateOnly = DateTime.newInstance((Long) paramsMap.get('RecurrenceEndDateOnly')).dateGmt();
        evRef.RecurrenceType = (String) paramsMap.get('RecurrenceType');
        evRef.RecurrenceInterval = (Integer) paramsMap.get('RecurrenceInterval');
        evRef.RecurrenceDayofWeekMask = (Integer) paramsMap.get('RecurrenceDayofWeekMask');
        evRef.RecurrenceTimeZoneSidKey = (String) paramsMap.get('RecurrenceTimeZoneSidKey');
        evRef.DurationInMinutes = (Integer) paramsMap.get('DurationInMinutes');
        evRef.Store_Location__r = new Store__c(RetailStoreId__c = storeCode);
        evRef.RecordTypeId = getAppointmentRecordTypesId().get('Availability');
        if(paramsMap.get('mode') != null && RecurrenceActivityId != null) {
            OnlineAppointments_Utils.RecurringEditMode mode;
            switch on ((String) paramsMap.get('mode')) {
                when 'CURRENT' {
                    mode = OnlineAppointments_Utils.RecurringEditMode.CURRENT;
                }
                when 'CURRENT_AND_MORE' {
                    mode = OnlineAppointments_Utils.RecurringEditMode.CURRENT_AND_MORE;
                }
                when else {
                    mode = OnlineAppointments_Utils.RecurringEditMode.ALL;
                }
            }
            return  OnlineAppointments_Utils.updateRecurringAvailability(evRef,mode);
        } else if (isRecurrence && RecurrenceActivityId == null ){
            return OnlineAppointments_Utils.deleteAndCreateRecurringSlot(evRef);
        }
        return OnlineAppointments_Utils.updateAvailability(evRef, null);
    }
    
    @RemoteAction
    global static Object getRecurrenceRefSlot(String recurrenceActivityId) {
        Event recurrenceRef = [Select Id, Capacity__c, RecurrenceActivityId, IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceType,
        RecurrenceInterval, RecurrenceDayofWeekMask, RecurrenceTimeZoneSidKey, DurationInMinutes, Store_Location__c, Store_Location__r.RetailStoreId__c,
        EndDateTime, StartDateTime
        FROM Event WHERE Id = :recurrenceActivityId LIMIT 1];
        return recurrenceRef;
    }
    
    @RemoteAction
    global static Object deleteAvailability(String params) {
        
        Map<String, Object> paramsMap = (Map<String, Object>) JSON.deserializeUntyped(params);
        
        //PARSE PARAMS
        String availabilityId  = (String) paramsMap.get('availabilityId');
        if(paramsMap.get('mode') != null) {
            
            OnlineAppointments_Utils.RecurringEditMode mode;
            switch on ((String) paramsMap.get('mode')) {
                when 'CURRENT' {
                    mode = OnlineAppointments_Utils.RecurringEditMode.CURRENT;
                }
                when 'CURRENT_AND_MORE' {
                    mode = OnlineAppointments_Utils.RecurringEditMode.CURRENT_AND_MORE;
                }
                when else {
                    mode = OnlineAppointments_Utils.RecurringEditMode.ALL;
                }
            }

            return OnlineAppointments_Utils.deleteRecurringAvailability(availabilityId, mode);
        }

        return OnlineAppointments_Utils.deleteAvailability(availabilityId);
        
    }

    global static Map<String, String> getAppointmentRecordTypesId (){
        List<RecordType> recordTypes = [Select Id, DeveloperName From RecordType where DeveloperName IN ('Appointments', 'Online_Appointment', 'Availability')];
        Map<String, String> appRecordTypeIdsMap = new Map<String, String>();
        for( RecordType record : recordTypes){
            appRecordTypeIdsMap.put(record.DeveloperName, record.Id);
        }
        return appRecordTypeIdsMap;
    }

    @RemoteAction
    global static Object getStoreHierarchy(){
        List<store__c> stores = [select management_zone_level_tech__c, storecountry__c, retailstoreid__c ,storetype__c, Time_Zone_Id__c, name, AppointmentType__c 
            FROM store__c
            WHERE (status__c = 'Open' OR status__c = 'Opening soon') AND management_zone_level_tech__c  != null AND storecountry__c != null];
        return stores;
    }

    @RemoteAction
    global static Void updateStoreSettings(String params){
        
        Map<String, Object> paramsMap = (Map<String, Object>) JSON.deserializeUntyped(params);

        Store__c st = new Store__c(Id = (String)paramsMap.get('storeId'), AppointmentType__c = (String) paramsMap.get('appointmentType'));
        update st;
    }
    
    @RemoteAction
    global static Boolean isInPilotStores(){

        
       Boolean temp = IC_UTILS.isInPilotBeta('OSA');
       return temp;
    }


    @RemoteAction
    global static Boolean isInPilotVirtual(){
    //    return IC_UTILS.isInPilotVirtual();
    return IC_UTILS.isInPilotBeta('OSA');
    }
	@RemoteAction
    global static Object getAuthorizedProfiles(){
        List<OSA_Authorized_profiles__c> prof = [Select user_action__c, store_change__c, appointment_type_change__c,CSC_user__c, CSC_user_PS__c, user_action_PS__c,store_change_PS__c,appointment_type_change_PS__c from OSA_Authorized_profiles__c limit 1];
        return prof[0];
    }
    @RemoteAction
    global static List<String> getUserPermissionSet(){
        List<String> psList = new List<String>();
        for(PermissionSetAssignment ps: [SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId()])
        {
            psList.add(ps.PermissionSet.Name);
        }
        
      return psList;
    }

    // @RemoteAction
    // global static Object deleteAvailability(String availabilityId){
    //     List<Event> avails = [Select Id, Status__c, WhatId  
    //     From Event 
    //     Where RecordType.DeveloperName = 'Availability'
    //     AND Id = :availabilityId ];

    //     if(avails.size() > 0){
    //         //IF PENDING SO DELETE THE ONLINE APPT
    //         delete avails[0];
    //         return new ResponseHandler(true, null, null, null, null, null);
    //     }

    //     throw  new OnlineAppointmentException('DELETE_AVAILABILITY_ID_NOT_EXIST');
    // }

        // upsertOnlineAppointment(Map<String,Object> bodyMap){
        // String onlineAppointmentId = (String) bodyMap.get('onlineAppointmentId');
        // String availabilityId = (String) bodyMap.get('availabilityId');
        // String accountId = (String) bodyMap.get('accountId');
        // String userId = (String) bodyMap.get('userId');
        // Map<String,Object> accountInfos = (Map<String,Object>) bodyMap.get('accountInfos');
        // String message = (String) bodyMap.get('message');
        // String language = (String) bodyMap.get('language');
        // String specialRequest = (String) bodyMap.get('specialRequest');
        // String service = (String) bodyMap.get('service');
        // String status = (String) bodyMap.get('status');
        // String reason = (String) bodyMap.get('reason');
        // String locale = (String) bodyMap.get('locale');
        // String dispatchCountry = (String) bodyMap.get('dispatchCountry');
}