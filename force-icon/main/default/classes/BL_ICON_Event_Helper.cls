public with sharing class BL_ICON_Event_Helper {

    static String OnlineAppointmentRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
    static String AppointmentsRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Appointments').getRecordTypeId();
    static String GoldenRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Golden').getRecordTypeId();
    static String EventAppointmentRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Event_Appointment')?.getRecordTypeId();

    public static Map<String, Object> getEventsByFilter(String filters, BL_UserInfo me, Integer page, Integer limitValue, List<String> caIds){
        Map<String, Object> result = new Map<String, Object>();
        List<String> filtersList = filters.split(';');
        for(String f : filtersList){
            switch on f{
                when 'me'{
                    result.put('me', getUserEvents(me, page, limitValue, false));
                } 
                when 'myStore'{
                    if(me.basicInfos.DefaultStore__c != null && me.basicInfos.DefaultStore__c != '')
                        result.put('myStore', getStoreEvents(me, page, limitValue));
                    else
                      result.put('myStore',new bl_ws_response(null));  
                }
                when 'unassigned'{ 
                    if(me.basicInfos.DefaultStore__c != null && me.basicInfos.DefaultStore__c != '')
                        result.put('unassigned', getUnassignedEvents(me, page, limitValue));
                    else
                      result.put('unassigned',new bl_ws_response(null));   
                }
                when 'teamMembers'{ 
                   if(me.basicInfos.DefaultStore__c != null && me.basicInfos.DefaultStore__c != '')
                    result.put('teamMembers', getTeamEvents(me, page, limitValue, caIds));
                    else
                      result.put('teamMembers',new bl_ws_response(null)); 
                } 
                when 'widget'{
                    result.put('me', getUserEvents(me, page, 3, true));
                } 
                when else {
                    throw new BL_Exceptions.RouterException('unknown filter');
                }
            }
        }
        return result;
    }


    public static Object getEventById(string id){
        BL_EasyQuery query = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_EVENT)    
            .condition('id = \'' + id + '\'')
            .executeQuery();
            
            if(BL_WS_Router.clientPlatform != 'WECHAT'){
                return query.getSObject();
            } 
            return getMappedWithCAs(query.getMappedObjects(),new List<Sobject>{query.getSObject()});
    } 

    public static List<Map<String, Object>> getMappedWithCAs(List<Map<String, Object>> mappedEvents, List<SObject> events){
        Map<Id,Object> caJsonByEventId = getCaJsonByEventId(events);
        system.debug('caJsonByEventId '+ caJsonByEventId);
        for(Map<String, Object> eventMap:mappedEvents){
            if(String.valueOf(eventMap.get('recordTypeName')) == 'Golden'){
                Id eventId = (Id)eventMap.get('id');
                eventMap.put('Facilitators',caJsonByEventId.get(eventId));
            }
        }
        return mappedEvents;
    }

    private static Map<Id,Object> getCaJsonByEventId(List<SObject> events){
        Map<Id,List<Id>> caIdsByEventIds = new Map<Id,List<Id>>();
        Set<Id> allCaIds = new Set<Id>();
        for(SObject obj:events){
            Event app = (Event)obj;
            List<Id> caIds = String.isNotEmpty(app.CA_Ids__c) ? app.CA_Ids__c.split(';') : new List<Id>();
            caIdsByEventIds.put(obj.Id, caIds);
            allCaIds.addAll(caIds);
        }
        Map<Id,Object> caJsonByEventId = new Map<Id,Object>();
        if(allCaIds.size() > 0){
            Map<Id,User> cas = new Map<id,User>([SELECT Id, FirstName, LastName, Name, WWEmployeeNumber__c FROM USER WHERE Id IN:allCaIds]);
            
            for(Id eventId:caIdsByEventIds.keySet()){
                caJsonByEventId.put(eventId,getCasJson(caIdsByEventIds.get(eventId),cas));
            }
        }
        return caJsonByEventId;
    }

    private static List<CADetails> getCasJson(List<Id> caIds, Map<Id,User> cas){
        List<CADetails> caDetails = new List<CADetails>();
        for(Id caId:caIds){
            User ca = cas.get(caId);
            caDetails.add(new CADetails(ca));
        }
        return caDetails;
    }

    public static Object checkEventTransaction(string id,list<String> relatedTickets){
        return new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_EVENT)     
            .condition('id != \'' + id + '\' AND (' + getQueryOr(relatedTickets)+')')
            .executeQuery()
            .getMappedObjects();
    }

    static public String getQueryOr (list<String> relatedTickets){
        String  queryId = '';
        Integer i = 0;
        for(String item :relatedTickets){
            if(i == 0){
                i++;
                queryId += ' RelatedTicketNumber__c  like \'%' + item + '%\'';
            }
            else
                queryId += ' OR RelatedTicketNumber__c like \'%' + item + '%\'';
        }
        return queryId;
    }

    public static Object getAllEvents(BL_UserInfo me, Integer page, Integer limitValue,List<String> caIds){
    
            /*
                Date minDate =  date.today().addDays(-7);
                Date maxDate = date.today().addDays(30);
                String conditionDate = 'ActivityDate > ' +  string.valueof(minDate) + ' AND ActivityDate < ' + string.valueof(maxDate);
                String condtionUserAppointment = ' ((RecordTypeId =\'' + OnlineAppointmentRecordTypeId + '\' OR RecordTypeId =\'' + AppointmentsRecordTypeId + '\') AND ownerId = \'' + me.basicInfos.Id + '\' AND Status__c = \'Assigned\') ';
                String storeCode = me.basicInfos.DefaultStore__c;
                List<Store__c> store = [SELECT ID FROM Store__c WHERE RetailStoreId__c =: storeCode];
                String conditionStoreAppointment;
                String conditionStoreAppointmentForManager;
                if(store.isEmpty()){
                    conditionStoreAppointment = '';
                    conditionStoreAppointmentForManager = '';
                }
                else{
                    conditionStoreAppointment = ' OR ((RecordTypeId =\'' + OnlineAppointmentRecordTypeId + '\' OR RecordTypeId =\'' + AppointmentsRecordTypeId + '\') AND Status__c = \'Not Assigned\' AND Store_Location__c = \'' + store[0].Id + '\'';
                    conditionStoreAppointmentForManager = ' OR ((RecordTypeId =\'' + OnlineAppointmentRecordTypeId + '\' OR RecordTypeId =\'' + AppointmentsRecordTypeId + '\') AND Status__c != \'Pending\' AND Status__c != \'Cancelled\' AND Store_Location__c = \'' + store[0].Id + '\'';
                }
                
                    if(me.basicInfos.TECH_IsManager__c == false){
                        return new BL_WS_Response( new BL_EasyQuery()
                        .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                        .condition( conditionDate + ' AND (' + condtionUserAppointment + conditionStoreAppointment + '))')
                        .orderBy('ActivityDate ASC')
                        .pagination(page, limitValue)
                        .executeQuery()
                        .getMappedObjects());     
                    }
                    else{
                        return new BL_WS_Response (new BL_EasyQuery()
                        .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                        .condition( conditionDate + ' AND (' + condtionUserAppointment + conditionStoreAppointmentForManager + '))')
                        .orderBy('ActivityDate ASC')
                        .pagination(page, limitValue)
                        .executeQuery()
                        .getMappedObjects()); 
                    }
            */

        Map<String, Object> result = new Map<String, Object>();
        result.put('me', getUserEvents(me, page, limitValue, false));
        if(me.basicInfos.DefaultStore__c != null && me.basicInfos.DefaultStore__c != ''){
            result.put('myStore', getStoreEvents(me, page, limitValue));
            result.put('unassigned', getUnassignedEvents(me, page, limitValue));
            result.put('teamMembers', getTeamEvents(me, page, limitValue, caIds));
        } else{
            result.put('myStore', new bl_ws_response(null));
            result.put('unassigned',new bl_ws_response(null));
            result.put('teamMembers', new bl_ws_response(null));   
        }

        return result;
    }

    public static Object getUserEvents(BL_UserInfo me, Integer page, Integer limitValue, Boolean isWidget){
        
        List<String> listOfRecordTypesId= new list<String>{
            '\''+OnlineAppointmentRecordTypeId +'\'',
            '\''+AppointmentsRecordTypeId+'\'' ,
            '\''+GoldenRecordTypeId+'\'',
            '\''+EventAppointmentRecordTypeId+'\''
            };

        Date minDate = isWidget ? date.today() : date.today().addDays(-30);
        String conditionDate =  isWidget ? 'ActivityDate = ' +  string.valueof(minDate) : 'ActivityDate > ' +  string.valueof(minDate);
        String condtionUserAppointment = ' (RecordTypeId IN ' + listOfRecordTypesId + ' AND ownerId = \'' + me.basicInfos.Id + '\' ) ';
        String conditionGolden = '(RecordTypeId =\'' + GoldenRecordTypeId + '\' AND (CA_Ids__c LIKE \'%' + me.basicInfos.Id + '%\' OR ownerId = \'' + me.basicInfos.Id + '\' OR Manager__c = \'' + me.basicInfos.Id + '\'))';
        return new BL_WS_Response (new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                .condition( conditionDate + ' AND (' + condtionUserAppointment + ' OR ' + conditionGolden + ')')
                .orderBy('ActivityDateTime ASC')
                .pagination(page, limitValue)
                .executeQuery()
                .getSObjects()); 
    }

    public static Object getTeamEvents(BL_UserInfo me, Integer page, Integer limitValue, List<String> caIds){
        Date minDate =  date.today().addDays(-7);
        Date maxDate = date.today().addDays(30);
        String conditionDate = 'ActivityDate > ' +  string.valueof(minDate) + ' AND ActivityDate < ' + string.valueof(maxDate);
        String conditionCa =  ' OwnerId IN ' + BL_Utils.convertToString(caIds);
        List<String> listOfRecordTypes = new list<String>{
            '\''+AppointmentsRecordTypeId+'\'' ,
            '\''+EventAppointmentRecordTypeId+'\''
        };
        if(conditionCa == '' || caIds.isEmpty()){
            return new BL_WS_Response (new List<Map<String,Object>>());
        } else {
            String condtionUserAppointment = ' (((RecordTypeId =\'' + OnlineAppointmentRecordTypeId  + '\' '+ ' AND Status__c = \'Assigned\') ' + ' OR RecordTypeId IN ' + listOfRecordTypes +' ) AND ' + conditionCa +')';
            return new BL_WS_Response (new BL_EasyQuery()
                    .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                    .condition( conditionDate + ' AND (' + condtionUserAppointment + ' OR ' + getGoldenCondition(caIds) + ')')
                    .orderBy('ActivityDateTime ASC')
                    .pagination(page, limitValue)
                    .executeQuery()
                    .getSObjects());
        }
          
    }

    private static String getGoldenCondition(List<String> caIds){
        String ret = '(RecordTypeId = \'' + GoldenRecordTypeId + '\' AND (';
        String caCond = '';
        for(String ca:caIds){
            if(caCond != '')
                caCond = caCond + ' OR ';
            caCond = caCond + 'CA_Ids__c LIKE \'%' + ca + '%\''; 
        }
        ret = ret + caCond + '))';
        return ret;
    }

    public static Object getUnassignedEvents(BL_UserInfo me, Integer page, Integer limitValue){
        Date minDate =  date.today().addDays(-7);
       // Date maxDate = date.today().addDays(30);
        String conditionDate = 'ActivityDate > ' +  string.valueof(minDate) /*+ ' AND ActivityDate < ' + string.valueof(maxDate)*/;
        String storeCode = me.basicInfos.DefaultStore__c;
        List<Store__c> store = [SELECT ID FROM Store__c WHERE RetailStoreId__c =: storeCode];

        String conditionStoreUnassignedAppointment = ' RecordTypeId =\'' + OnlineAppointmentRecordTypeId + '\'  AND Status__c = \'Not Assigned\' AND Store_Location__c = \'' + store[0].Id + '\'';
        return new BL_WS_Response (new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                .condition( conditionDate + ' AND ' + conditionStoreUnassignedAppointment )
                .orderBy('ActivityDateTime ASC')
                .pagination(page, limitValue)
                .executeQuery()
                .getSObjects()); 
    }

    public static Object getStoreEvents(BL_UserInfo me, Integer page, Integer limitValue){

        List<String> listOfRecordTypes = new list<String>{
            '\''+AppointmentsRecordTypeId+'\'' ,
            '\''+GoldenRecordTypeId+'\'',
            '\''+EventAppointmentRecordTypeId+'\''
        };
        Date minDate =  date.today().addDays(-7);
        Date maxDate = date.today().addDays(30);
        String conditionDate = 'ActivityDate > ' +  string.valueof(minDate) + ' AND ActivityDate < ' + string.valueof(maxDate);
        String storeCode = me.basicInfos.DefaultStore__c;
        List<Store__c> store = [SELECT ID FROM Store__c WHERE RetailStoreId__c =: storeCode];
        Map<String,User> users  =  new Map<String,User>([Select Id from USer where defaultStore__c =: storeCode AND DefaultStore__c != null AND   IsActive = true AND IsTechnicalUser__c = false AND (NOT Email LIKE 'store_%') ]);
        String conditionStoreAppointment;
        if(store.isEmpty()){
            conditionStoreAppointment = '';
        } else {

            conditionStoreAppointment = ' AND ((RecordTypeId =\'' + OnlineAppointmentRecordTypeId  + '\' '+ ' AND Status__c = \'Assigned\') ' + ' OR RecordTypeId IN ' + listOfRecordTypes + ' )  AND (Store_Location__c = \'' + store[0].Id + '\' OR OwnerId IN ' + BL_Utils.convertToString(users.keySet())+')';
        }

        if(me.basicInfos.TECH_IsManager__c == true){
            return new BL_WS_Response (new BL_EasyQuery()
                    .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                    .condition( conditionDate + conditionStoreAppointment )
                    .orderBy('ActivityDateTime ASC')
                    .pagination(page, limitValue)
                    .executeQuery()
                    .getSObjects()); 
        } else {
            throw new BL_Exceptions.RouterException('You are not able to see this data');
        }
    }

    public static Object insertGoldenEvents(List<Object> wrapperItemMaps, List<Object> managerDtls) {
        List<Event> events = (List<Event>) new BL_EasyQuery()
                                        .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                                        .convertWrapperToSObject(wrapperItemMaps);
        Set<Id> clientIds = new Set<Id>();
        Map<Id,String> lvMidById = getLvMidById(managerDtls);
        for(Event evnt:events){
            evnt.recordTypeId = GoldenRecordTypeId;
            //evnt.DurationInMinutes = 0;
            //evnt.activityDateTime = (Datetime)evnt.activityDate;
            clientIds.add(events[0].WhatId);
            if(evnt.Manager__c == null){
                evnt.Manager__c = userInfo.getUserId();
            } else {
                if(lvMidById.get(evnt.Manager__c) == null){
                    return new Map<String,Object> {'status' =>'error mangerDetails is required when CA is creating golden appointment.'};
                }  
            }
        }
        
        insert events;

        Map<Id,Account> clientDetailsById = getClientsDetailsById(clientIds);
        Wecom_Notification__mdt mdt = Wecom_Notification__mdt.getInstance('Golden_Appointment_Approval_Request');
        for(Event evt:events){
            Account client = clientDetailsById.get(evt.whatId);
            Boolean isNotif = lvMidById.get(evt.Manager__c) == null ? false : true;
            if(isNotif && client != null){
                String redirectPath = mdt.Path__c.replace('{eventId}',evt.Id);
                Map<String, String> params = new Map<String, String> {
                    'key'=> mdt.Param_Key__c,
                    'value'=>  UserInfo.getName() + mdt.Param_Value__c
                };
                Map<String,String> notifDetails= new Map<String,String>{
                    'mainMessageKey' => mdt.Main_Message_Key__c,
                    'mainMessage' => client.FirstName + ' '+ client.LastName,
                    'lvMid' =>lvMidById.get(evt.Manager__c),
                    'path' => redirectPath,
                    'title' =>  mdt.Title__c,
                    'description' => mdt.Description__c
                };
                BL_WecomUtils.sendNotif(notifDetails, params);
            }
        }
        BL_EasyQuery query = new BL_EasyQuery().useCase(BL_ICON_Constants.USE_CASE_EVENT).condition(getQueryIdCondition(events)).executeQuery();
        return query.getSObjects();
    }

    public static Object insertEvents(List<Object> wrapperItemMaps) {
        List<Event> events = (List<Event>) new BL_EasyQuery()
                                        .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                                        .convertWrapperToSObject(wrapperItemMaps);
        insert events;
        return new BL_EasyQuery().useCase(BL_ICON_Constants.USE_CASE_EVENT).condition(getQueryIdCondition(events)).executeQuery().getSObjects();//.getResponseMappedObjects().get('records');
    }  

    public static Object updateEvents(List<Object> wrapperItemMaps) {

        List<Event> events = (List<Event>) new BL_EasyQuery()
                                        .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                                        .convertWrapperToSObject(wrapperItemMaps);
        update events;
        return new BL_EasyQuery().useCase(BL_ICON_Constants.USE_CASE_EVENT).condition(getQueryIdCondition(events)).executeQuery().getSobjects();//.getResponseMappedObjects().get('records'); 
    }

    public static Object deleteEvents(List<Object> wrapperItemMaps) {
        try{
            List<Event> events = (List<Event>) new BL_EasyQuery()
                                            .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                                            .convertWrapperToSObject(wrapperItemMaps);
            delete events;
            return new Map<String,String> {'status' =>'OK'};
        }
        catch(Exception ex){
            return new Map<String,String> {'status' =>'error'};
        }
    }

    public static Object deleteEvent(String eventId) {
        try{
            Event events = (Event) new BL_EasyQuery()
                    .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                    .condition('Id = \'' + eventId + '\'')
                    .executeQuery().getSObject();
            delete events;
            return new Map<String,String> {'status' =>'OK'};
        } catch(Exception ex){
            return new Map<String,String> {'status' =>'error'};
        }
    }

    public static String getQueryIdCondition(List<SObject> objList) {
        Integer i = 0;
        String queryCondition = '';
        for(SObject obj : objList){
            if(i == 0){
                queryCondition += 'Id = \'' + obj.Id + '\'';
                i++;
            }
            else 
                queryCondition += 'OR Id = \'' + obj.Id + '\'';
        }
        return queryCondition;
    }

    public static Object rejectEvent(String eventId, String rejectReason){
        Wecom_Notification__mdt mdt = Wecom_Notification__mdt.getInstance('Golden_Appointment_Reject');
        if(eventId != null){
            BL_EasyQuery query = new BL_EasyQuery()
                                .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                                .condition('Id = \'' + eventId + '\'');
            List<Event> apptList = query.executeQuery().getSObjects();
            if(!apptList.isEmpty()){
                apptList[0].Status__c = 'Rejected';
                upsert apptList[0];
                User owner = getUserDetails(apptList[0].OwnerId);
                Account client = getClientsDetailsById(new Set<Id>{apptList[0].AccountId}).get(apptList[0].AccountId);
                String redirectPath = mdt.Path__c.replace('{eventId}',apptList[0].Id).replace('{rejectReason}',rejectReason);
                if(owner != null && client != null){
                    Map<String,String> notifDetails= new Map<String,String>{
                        'mainMessageKey' => mdt.Main_Message_Key__c,
                        'mainMessage' => client.FirstName + ' '+ client.LastName,
                        'lvMid' => owner.WWEmployeeNumber__c,
                        'path' => redirectPath,
                        'title' =>  mdt.Title__c,
                        'description' => mdt.Description__c
                    };
                    Map<String, String> params = new Map<String, String> {
                        'key'=> mdt.Param_Key__c,
                        'value'=> mdt.Param_Value__c
                    };
                    BL_WecomUtils.sendNotif(notifDetails, params);
                }
                return query.executeQuery().getMappedObjects();
            }
        }
        return 'Appointment with Id ' + eventId + ' doesn\'t exist';
    }

    private static User getUserDetails(Id userId){
        List<User> users = [SELECT FirstName, LastName, WWEmployeeNumber__c FROM User WHERE Id = :userId LIMIT 1];
        if(users.size() > 0)   
            return users[0];
        return null;
    }
    
    private static Map<Id,Account> getClientsDetailsById(Set<Id> clientIds){
        return new Map<Id,Account>([SELECT FirstName, LastName FROM Account WHERE Id IN :clientIds]);
    }

    private static Map<Id,String> getLvMidById(List<Object> managerDetails){
        Map<Id,String> lvMidById = new Map<Id,String>();
        if(managerDetails != null){
            for(Object details:managerDetails){
                Map<String,Object> detailsMap = (Map<String,Object>)details;
                lvMidById.put((String)detailsMap.get('id'),(String)detailsMap.get('lvMid'));
            }
        }
        return lvMidById;
    }

    public static Object assignAppointments(String userId, String onlineAppointmentId, Boolean reassignFromManager){
        List<Event> onlineApptList = (List<Event>)new BL_EasyQuery()
                                    .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                                    .condition('RecordType.DeveloperName IN (\'Online_Appointment\') AND Id = \'' + onlineAppointmentId + '\'')
                                    .executeQuery()
                                    .getSObjects();

        if(!onlineApptList.isEmpty()){
            if(onlineApptList[0].Status__c == 'Not Assigned'){
                onlineApptList[0].OwnerId = userId;
                onlineApptList[0].Status__c = 'Assigned';
                upsert onlineApptList[0];
            } else if(onlineApptList[0].Status__c == 'Assigned' && reassignFromManager == true){
                onlineApptList[0].OwnerId = userId;
                upsert onlineApptList[0];
            }

            return new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_EVENT)
            .condition('Id = \'' + onlineAppointmentId + '\'')
            .executeQuery()
            .getSObjects();
            //.getResponseMappedObjects()
            //.get('records'); 
        }
        throw new BL_Exceptions.QueryException('400', 'APT_ID_NOT_EXIST', 'APT_ID_NOT_EXIST');
    }

    public static Object attendanceAppointments(String onlineAppointmentId){
        List<Event> onlineApptList = (List<Event>)new BL_EasyQuery()
                                    .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                                    .condition('RecordType.DeveloperName IN (\'Online_Appointment\', \'Appointments\') AND Id = \'' + onlineAppointmentId + '\'')
                                    .executeQuery()
                                    .getSObjects();
                                    
        if(!onlineApptList.isEmpty()){
                onlineApptList[0].Attendance__c = 'Yes';
                upsert onlineApptList[0];
        

            return new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_EVENT)
            .condition('Id = \'' + onlineAppointmentId + '\'')
            .executeQuery()
            .getSObjects();
            //.getResponseMappedObjects()
           // .get('records'); 
        }
        throw new BL_Exceptions.QueryException('400', 'APT_ID_NOT_EXIST', 'APT_ID_NOT_EXIST');
    }

    public class CADetails{
        public String firstName;
        public String lastName;
        public String fullName;
        public String lvMid;
        public String id;
        public CADetails(User ca){
            this.firstName = ca.FirstName; 
            this.lastName = ca.LastName;
            this.fullName = ca.Name;
            this.lvMid = ca.WWEmployeeNumber__c;
            this.id = ca.Id;
        }
    }
}