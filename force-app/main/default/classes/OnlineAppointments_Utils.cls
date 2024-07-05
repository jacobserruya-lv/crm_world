public without sharing class OnlineAppointments_Utils {

    public static  Map<String, String> appointmentRecordTypesId;

    /*=================================================================================================================*/
    //getFreeAvailabilities

    public static Object getFreeAvailabilities(String storeIds, String datesString, String startDate, String endDate){
               
        Map<Id, Event> availabilitiesMap = getAvailabilitiesMap( storeIds,  datesString,  startDate,  endDate, true);
        if(availabilitiesMap.size() == 0){
            throw new OnlineAppointmentException('AVAILABILITIES_EMPTY_LIST');
        }

        //GET CURRENT ONLINE APPT
        Map<String, List<Event>> currentOnlineAppointmentsMap = getCurrentOnlineAppointmentsMap(availabilitiesMap);

        //BUILD MAP <STOREID , LIST<AVAILABILITIES>>
        Map<String, List<Event>> storeAvailabilitiesMap = new Map<String, List<Event>>();
        for(Event av : availabilitiesMap.values()){
            if(currentOnlineAppointmentsMap.get(av.Id) == null || currentOnlineAppointmentsMap.get(av.Id) != null && av.Capacity__c > currentOnlineAppointmentsMap.get(av.Id).size() ){
                if(storeAvailabilitiesMap.get(av.Store_Location__r.RetailStoreId__c) == null){
                    storeAvailabilitiesMap.put(av.Store_Location__r.RetailStoreId__c, new List<Event>());
                }
                storeAvailabilitiesMap.get(av.Store_Location__r.RetailStoreId__c).add(av);
            }
        }
        //BUILD RESPONSE FORMAT MAP <STOREID,MAP<DATE,LIST<AVAIBILITIES>>>
        List<StoreAvailabilities> response = new  List<StoreAvailabilities>();
        for(String storeId : storeAvailabilitiesMap.keySet()){
            response.add( new StoreAvailabilities(storeId, storeAvailabilitiesMap.get(storeId)));
        }

        if(response.size() == 0){
            throw new OnlineAppointmentException('AVAILABILITIES_EMPTY_LIST');
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('records',response);
        return result;
    }

    /*=================================================================================================================*/
    //Get Free Capacities for Availability

    public static Object getFreeCapacityByAvailabilityId(String availabilityId, String onlineAppointmentId){
        //GET AVAILABILITY BY ID
        List<Event> availabilities = [
            SELECT Id, Capacity__c, IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceType, My_Repairs__r.Client__r.Name, My_Repairs__c, 
            RecurrenceInterval, RecurrenceDayofWeekMask, RecurrenceTimeZoneSidKey, DurationInMinutes, Store_Location__r.Name, 
            Store_Location__r.Time_Zone_Id__c, StartDateTime,RecordTypeId,recordType.DeveloperName,
            Store_Location__r.RetailStoreId__c, EndDateTime,Reason__c, Service__c,OwnerId, Owner.Name, owner.FirstName, owner.LastName,
            Language__c, Locale__c, Status__c, Store_Location__c, availabilityId__c,Subject,
            Store_Location__r.appointmentType__c
            FROM Event 
            WHERE RecordType.DeveloperName = 'Availability' AND IsRecurrence = false
            AND Id = :availabilityId
        ];

        if(availabilities.isEmpty()){
            throw new OnlineAppointmentException('TIMESLOT_NOT_EXIST');
        }
        List<IconSetting__mdt> settings = [Select Number__c From IconSetting__mdt WHERE QualifiedApiName ='OsaPendingValidity'];
        Integer osaPendingValidity = settings != null && settings.size() > 0 && settings[0].Number__c != null ? settings[0].Number__c.intValue() : 0;
        Datetime limitPendingTime = Datetime.now().addMinutes(-osaPendingValidity);

        //GET CURRENT ACTIVE ONLINE APPOINTMENTS FOR THE AVAILABILITY ID
        String query = 'Select Id, Status__c  '+
            ' From Event ' +
            ' Where RecordType.DeveloperName = \'Online_Appointment\' '+
            ' AND availabilityId__c = :availabilityId ' +
            (String.isNotEmpty(onlineAppointmentId) ? ' AND Id != :onlineAppointmentId ' : ' ') +
            ' AND (Status__c = \'Assigned\' OR Status__c = \'Not Assigned\' OR  (Status__c = \'Pending\' AND CreatedDate > :limitPendingTime))';

        List<Event> currentOnlineAppointments = Database.query(query);

        Map<String, Object> results = new Map<String, Object>();
        results.put('availability', availabilities[0]);
        results.put('availabilityId', availabilityId);
        results.put('startDateTime', availabilities[0].startDateTime);
        results.put('storeCode', availabilities[0].Store_Location__r.RetailStoreId__c);
        results.put('definedCapacities', availabilities[0].Capacity__c);
        results.put('freeCapacities', availabilities[0].Capacity__c - currentOnlineAppointments.size() );
        return results;
    }

    /*=================================================================================================================*/
    //Get Availabilities Capacities
    @RemoteAction
    public static Object getAvailabilities(String storeIds, String datesString, String startDate, String endDate){

        Map<Id, Event> availabilitiesMap = getAvailabilitiesMap( storeIds,  datesString,  startDate,  endDate,  false);

        //GET CURRENT ONLINE APPT
        Map<String, List<Event>> currentOnlineAppointmentsMap = getCurrentOnlineAppointmentsMap(availabilitiesMap);

        //BUILD MAP <STOREID , LIST<AVAILABILITIES>>
        List<AvailabilityWrapper> availabilities = new List<AvailabilityWrapper>();
        for(Event av : availabilitiesMap.values()){
            availabilities.add(new AvailabilityWrapper(av,(currentOnlineAppointmentsMap.get(av.Id) != null ? currentOnlineAppointmentsMap.get(av.Id).size() : 0)));
        }

        return availabilities;
    }

    /*=================================================================================================================*/
    //getAvailabilitiesMap

    public static Map<Id, Event> getAvailabilitiesMap(String storeIds, String datesString, String startDate, String endDate, Boolean fromTomorrow){
        
        //PARSE PARAMS
        List<String> storeCodeList = String.isNotEmpty(storeIds) ? storeIds.split(';') : new List<String>();
        if(storeCodeList.isEmpty()){
            throw new OnlineAppointmentException('STORE_CODE_PARAM_IS_MISSING');
        }
        List<Date> dates = new List<Date>();
        String dateCondition = ' AND activityDate = NEXT_N_DAYS:30 ';
        if(String.isNotEmpty(datesString)){
            List<String> dateList = datesString.split(';');
            for(String d : dateList){
                dates.add(Date.valueOf(d));
            }
        } 
        if( dates.size() > 0 ){
            dateCondition =  ' AND activityDate IN :dates ' ;
        }else if(String.isNotEmpty(startDate) && String.isNotEmpty(endDate)){
            dateCondition = '  AND activityDate >= '+ startDate + ' AND activityDate <= '+ endDate +' ';
        }

        if(fromTomorrow){
            Datetime next24H = Datetime.now().addHours(24);
            dateCondition +=  ' AND startdateTime >= :next24H ';
        }

        if(storeCodeList.size() > 10){
            List<String> newList = new List<String>();  
            for(Integer i = 0; i< 10;i++){
                newList.add(storeCodeList[i]);
            }
            storeCodeList = newList;
        }
        
        //GET AVAILABILITIES BY STOREIDS AND BY DATES
        String query = 'select Id, startdateTime, activityDate, Store_Location__r.RetailStoreId__c ,EndDatetime, Capacity__c, Store_Location__r.Time_Zone_Id__c, Store_Location__r.StoreCountry__c,'+
        'IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceType, Store_Location__r.Name, RecordType.DeveloperName, My_Repairs__r.Client__r.Name, My_Repairs__c, '+
        'RecurrenceInterval, RecurrenceDayofWeekMask, RecurrenceTimeZoneSidKey, DurationInMinutes, RecurrenceActivityId, Store_Location__r.AppointmentType__c '+
        'From Event Where RecordType.DeveloperName = \'Availability\'  AND IsRecurrence = false ' + 
        dateCondition +
        (storeCodeList.size() > 0 ? ' AND Store_Location__r.RetailStoreId__c IN :storeCodeList ' : '')+
        ' ORDER BY startdateTime ASC';
        Map<Id, Event> availabilitiesMap = new Map<ID, Event>((List<Event>)Database.query(query));

        return availabilitiesMap;
    }

    /*=================================================================================================================*/
    //Get CurrentOnline Appointments for availabilities

    public static Map<String, List<Event>> getCurrentOnlineAppointmentsMap(Map<Id, Event> availabilitiesMap){
        //GET CURRENT ONLINE APPT
        List<IconSetting__mdt> settings = [Select Number__c From IconSetting__mdt WHERE QualifiedApiName ='OsaPendingValidity'];
        Integer osaPendingValidity = settings != null && settings.size() > 0 && settings[0].Number__c != null ? settings[0].Number__c.intValue() : 0;
        Map<String, List<Event>> currentOnlineAppointmentsMap = new Map<String, List<Event>>();
        Datetime limitPendingTime = Datetime.now().addMinutes(-osaPendingValidity);
        List<Event> currentOnlineAppointments = [Select Id, Status__c, availabilityId__c
        From Event 
        Where RecordType.DeveloperName = 'Online_Appointment' 
        AND availabilityId__c IN :availabilitiesMap.keySet()
        AND (Status__c = 'Assigned' OR Status__c = 'Not Assigned' OR  (Status__c = 'Pending' AND CreatedDate > :limitPendingTime)) ];

        for( Event oppt : currentOnlineAppointments){
            if(currentOnlineAppointmentsMap.get(oppt.AvailabilityId__c) == null){
                    currentOnlineAppointmentsMap.put(oppt.AvailabilityId__c, new List<Event>());
            }
            currentOnlineAppointmentsMap.get(oppt.AvailabilityId__c).add(oppt);
        }

        return currentOnlineAppointmentsMap;
    }

    /*=================================================================================================================*/
    //Create Availabilities

    public static Object createAvailabilities(Map<String, Object> availabilitiesJSON){
        
        //PARSE PARAMS
       
        String storeCode =  (availabilitiesJSON.get('StoreCode')!= null ? (String) availabilitiesJSON.get('StoreCode') : getUserInfos().DefaultStore__c);
        
        List<Object> startTimes = (List<Object>) availabilitiesJSON.get('startTimes');
        Event evRef = new Event();
        evRef.Capacity__c = (Integer) availabilitiesJSON.get('capacities');
        evRef.IsRecurrence = (Boolean) availabilitiesJSON.get('IsRecurrence');
        evRef.RecurrenceStartDateTime = (dateTime) availabilitiesJSON.get('RecurrenceStartDateTime');
        evRef.RecurrenceEndDateOnly = (Date) availabilitiesJSON.get('RecurrenceEndDateOnly');
        evRef.RecurrenceType = (String) availabilitiesJSON.get('RecurrenceType');
        evRef.RecurrenceInterval = (Integer) availabilitiesJSON.get('RecurrenceInterval');
        evRef.RecurrenceDayofWeekMask = (Integer) availabilitiesJSON.get('RecurrenceDayofWeekMask');
        evRef.RecurrenceTimeZoneSidKey = (String) availabilitiesJSON.get('RecurrenceTimeZoneSidKey');
        evRef.DurationInMinutes = (Integer) availabilitiesJSON.get('DurationInMinutes');
        evRef.Store_Location__r = new Store__c(RetailStoreId__c = storeCode);
        evRef.RecordTypeId = getAppointmentRecordTypesId().get('Availability');
        

        List<Datetime> startDatetimes = new List<Datetime>();
        for(Object sd : startTimes){
            startDatetimes.add((Datetime) sd);
        }

        return createAvailabilities(evRef, startDatetimes, storeCode);
    }

    public static Object createAvailabilities(Event evRef, List<Datetime> startDatetimes, String storeCode){
        List<Event> availabilities = new List<Event>();
        Set<Datetime> existingStartimes = new Set<Datetime>();

        List<Event> existingAppointments = [Select Id, StartDateTime 
        FROM Event 
        WHERE 
        Store_Location__r.RetailStoreId__c = : storeCode 
        AND recordTypeId = :evRef.RecordTypeId AND IsRecurrence = false
        AND StartDateTime IN : startDatetimes];
        
        for(Event ev : existingAppointments){
            existingStartimes.add(ev.StartDateTime);
        }
            
        for(Datetime startTime : startDatetimes){
            Event newEvent = evRef.clone(false, true);
            newEvent.StartDateTime = startTime;
            if(evRef.IsRecurrence){
                newEvent.RecurrenceStartDateTime = startTime;
            }
            if(!existingStartimes.contains(newEvent.StartDateTime)){
                availabilities.add(newEvent);
            }
        }

        if(!evRef.IsRecurrence){
            insert availabilities;
            return new Map<String,Object>{
                'createdAvailabilities' => availabilities,
                'existingSlots' => existingStartimes
            };
        } else {
           return  createRecurrenceAvailabilities(evRef, availabilities, existingStartimes, storeCode);
        }
    }

    /*=================================================================================================================*/
    //Create Recurrence Slots
    private static Object createRecurrenceAvailabilities(Event evRef, List<Event> availabilities, Set<Datetime> existingStartimes, String storeCode){
        for(Event slot : availabilities){
            system.debug(slot);
            system.debug('*****slot******');
            insert slot;
            system.debug(slot);

        }

        List<Event> availabilitiesRec = [Select Id, Capacity__c, IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceType,
        RecurrenceInterval, RecurrenceDayofWeekMask, RecurrenceTimeZoneSidKey, DurationInMinutes, Store_Location__r.Name, Store_Location__r.Time_Zone_Id__c, Store_Location__r.StoreCountry__c,
        Store_Location__r.RetailStoreId__c, EndDateTime, StartDateTime
        FROM Event 
        WHERE 
        RecordType.DeveloperName = 'Availability' AND IsRecurrence = false AND 
        (Id IN :availabilities OR RecurrenceActivityId IN : availabilities)];

        List<Datetime> startDatetimesRec = new List<Datetime>();
        for(Event avrec : availabilitiesRec){
            startDatetimesRec.add(avrec.StartDateTime);
        }
        List<Event> existingAppointments2 = [Select Id, StartDateTime 
        FROM Event 
        WHERE 
        Store_Location__r.RetailStoreId__c = : storeCode 
        AND recordTypeId = :evRef.RecordTypeId AND IsRecurrence = false
        AND StartDateTime IN : startDatetimesRec 
        AND Id NOT IN : availabilitiesRec AND Id NOT IN : availabilities];
        list<Event> toDelete = new List<Event>();
        for(Event ev : existingAppointments2){
            existingStartimes.add(ev.StartDateTime);
        }

        for(Event ev : availabilitiesRec) {
            if(existingStartimes.contains(ev.StartDateTime)) {
                toDelete.add(ev);
            }
        }
        

        if(toDelete.size() > 0){
            delete toDelete;
        }
        
        return new Map<String,Object>{
            'createdAvailabilities' => availabilities,
            'existingSlots' => existingStartimes
        };
        
    }

    /*=================================================================================================================*/
    //update availability

    public static Object updateAvailability(Event newEv, Event evRef) {
        newEv.RecurrenceEndDateOnly = null;
        newEv.RecurrenceType = null;
        newEv.RecurrenceInterval = null;
        newEv.RecurrenceDayofWeekMask = null;
        newEv.RecurrenceTimeZoneSidKey = null;
        newEv.RecurrenceStartDateTime = null;

        if(evRef == null) {
            evRef = [Select Id, StartDateTime, Capacity__c From Event WHERE Id = :newEv.Id LIMIT 1 ];
        }
        Map<String, List<Event>> osaMap = getCurrentOnlineAppointmentsMap(new Map<Id, Event>{evRef.Id => evRef});
        Integer osaCount = 0;
        if (osaMap.get(evRef.Id) != null) {
            osaCount = osaMap.get(evRef.Id).size();
        }
        if(osaCount > 0 && (evRef.StartDateTime != newEv.StartDateTime || newEv.Capacity__c < osaCount )) {
            throw new OnlineAppointmentException('CANT_UPDATE_SLOT_ALREADY_USED');
        }

        update newEv;

        return newEv;
    }

    /*=================================================================================================================*/
    //update Recurring availability

    public static Object updateRecurringAvailability(Event newEv, RecurringEditMode mode) {
        
        Event evRef = [SELECT Id, StartDateTime, Capacity__c, RecurrenceActivityId, IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceType,
        RecurrenceInterval, RecurrenceDayofWeekMask, RecurrenceTimeZoneSidKey, DurationInMinutes, Store_Location__c, Store_Location__r.RetailStoreId__c,
        EndDateTime, ActivityDate
        FROM Event WHERE Id = :newEv.Id LIMIT 1 ];
        String recREFID = evRef.RecurrenceActivityId;
        Date currentEvDate = evRef.ActivityDate;

        Event recurrenceRef = [SELECT Id, Capacity__c, RecurrenceActivityId, IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceType,
        RecurrenceInterval, RecurrenceDayofWeekMask, RecurrenceTimeZoneSidKey, DurationInMinutes, Store_Location__c, Store_Location__r.RetailStoreId__c,
        EndDateTime, StartDateTime,ActivityDate
        FROM Event WHERE Id = :evRef.RecurrenceActivityId LIMIT 1];

        if(mode == RecurringEditMode.CURRENT) {
            return updateAvailability(newEv, evRef);
        }
        Set<DateTime> excludedSlots = new Set<DateTime>();
        String queryRecurringEvs = 'Select Id, Capacity__c, ActivityDate, IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceType, '+
        'RecurrenceInterval, RecurrenceDayofWeekMask, RecurrenceTimeZoneSidKey, DurationInMinutes, Store_Location__r.Name, Store_Location__r.Time_Zone_Id__c, Store_Location__r.StoreCountry__c, '+
        'Store_Location__r.RetailStoreId__c, EndDateTime, StartDateTime '+ 
        'FROM Event '+
        'WHERE ' +
        'RecordType.DeveloperName = \'Availability\' AND IsRecurrence = false '+
        'AND RecurrenceActivityId = :recREFID ' +
        (mode == RecurringEditMode.CURRENT_AND_MORE ? 'AND ActivityDate >= :currentEvDate ' : ' AND ActivityDate >= TODAY ');

        Map<Id, Event> recurringEvsMap = new Map<Id, Event>((List<Event>)Database.query(queryRecurringEvs));
        Map<String, List<Event>> osaMap = getCurrentOnlineAppointmentsMap(recurringEvsMap);
        Boolean isCapacityUpdateOnly = isCapacityUpdateOnly(newEv, evRef, recurrenceRef);
        if(isCapacityUpdateOnly) {
            List<Event> availabilitiesToUpdate = new List<Event>();
           
            for(Id avId : recurringEvsMap.keySet()) {
                if(osaMap.get(avId) != null && newEv.Capacity__c >= osaMap.get(avId).size() || osaMap.get(avId) == null || osaMap.get(avId).isEmpty()) {
                    Event ev = recurringEvsMap.get(avId);
                    ev.Capacity__c = newEv.Capacity__c;
                    availabilitiesToUpdate.add(ev);
                } else {
                    excludedSlots.add(recurringEvsMap.get(avId).StartDateTime);
                }
            }

            if(availabilitiesToUpdate.size() > 0) {
                update availabilitiesToUpdate;
                
            }
            return new Map<String, Object> { 'excludedSlots' => excludedSlots,  'updatedAvailabilities' => availabilitiesToUpdate};
        } else {
            List<Event> availabilitiesToDelete = new List<Event>();
            for(Id avId : recurringEvsMap.keySet()) {
                if(osaMap.get(avId) == null || osaMap.get(avId).isEmpty() ) {
                    availabilitiesToDelete.add(recurringEvsMap.get(avId));
                } else {
                    excludedSlots.add(recurringEvsMap.get(avId).StartDateTime);
                }
            }

            if(availabilitiesToDelete.size() > 0) {
                delete availabilitiesToDelete;
                newEv.Id = null;
                newEv.IsRecurrence = true;
                if(mode == RecurringEditMode.ALL) {
                    Integer diffDays = recurrenceRef.RecurrenceStartDateTime.dateGmt().daysBetween(newEv.RecurrenceStartDateTime.dateGmt());
                    newEv.StartDatetime = newEv.RecurrenceStartDateTime.addDays(-diffDays);
                    newEv.RecurrenceStartDateTime =newEv.RecurrenceStartDateTime.addDays(-diffDays);
                    
                    // if(newEv.RecurrenceEndDateOnly > recurrenceRef.RecurrenceEndDateOnly) {
                    //     newEv.RecurrenceEndDateOnly = newEv.RecurrenceEndDateOnly.addDays( - recurrenceRef.RecurrenceStartDateTime.dateGmt().daysBetween(evRef.StartDatetime.dateGmt()));
                    // }

                }
                Map<String, Object> result = (Map<String, Object>) createAvailabilities(newEv, new List<DateTime> {newEv.StartDatetime}, evRef.Store_Location__r.RetailStoreId__c);
                excludedSlots.addAll((Set<DateTime>) result.get('existingSlots'));
                return new Map<String, Object> { 'excludedSlots' => excludedSlots,  'updatedAvailabilities' => (List<Event>) result.get('createdAvailabilities')};
                
            }

            return new Map<String, Object> { 'excludedSlots' => excludedSlots};
        }
    }

    private static Boolean isCapacityUpdateOnly(Event newEv, Event evRef, Event recurrenceRef) {
        if(newEv.Capacity__c != evRef.Capacity__c) {
            if(newEv.StartDateTime != evRef.StartDateTime || newEv.RecurrenceStartDateTime != evRef.StartDateTime || recurrenceRef.RecurrenceEndDateOnly != newEv.RecurrenceEndDateOnly ||
            recurrenceRef.RecurrenceType != newEv.RecurrenceType || recurrenceRef.RecurrenceInterval != newEv.RecurrenceInterval ||
            recurrenceRef.RecurrenceDayofWeekMask != newEv.RecurrenceDayofWeekMask  ) {
                return false;
            }
            return true;
        } else {
            return false;
        }
    }

    public enum RecurringEditMode {
        CURRENT,
        CURRENT_AND_MORE,
        ALL
    }

    /*=================================================================================================================*/
    //Delete Availability

    public static Object deleteAvailability(String availabilityId){
        List<IconSetting__mdt> settings = [Select Number__c From IconSetting__mdt WHERE QualifiedApiName ='OsaPendingValidity'];
        Integer osaPendingValidity = settings != null && settings.size() > 0 && settings[0].Number__c != null ? settings[0].Number__c.intValue() : 0;
        Datetime limitPendingTime = Datetime.now().addMinutes(-osaPendingValidity);

        //GET CURRENT ACTIVE ONLINE APPOINTMENTS FOR THE AVAILABILITY ID
        String query = 'Select Id, Status__c  '+
            ' From Event ' +
            ' Where RecordType.DeveloperName = \'Online_Appointment\' '+
            ' AND availabilityId__c = :availabilityId ' +
            ' AND (Status__c = \'Assigned\' OR Status__c = \'Not Assigned\' OR  (Status__c = \'Pending\' AND CreatedDate > :limitPendingTime))';

        List<Event> currentOnlineAppointments = Database.query(query);

        if(currentOnlineAppointments.size() > 0){
            throw  new OnlineAppointmentException('Your slot was not deleted because you already have appointments booked by clients');
        } else{
            Event evRef = new Event();
            evRef.Id = availabilityId;
            delete evRef;
            return evRef;
        }
    }

    /*=================================================================================================================*/
    //Delete Recurring Availability
    public static Object deleteRecurringAvailability(String availabilityId,RecurringEditMode  mode){
        if(mode == RecurringEditMode.CURRENT) {
            return deleteAvailability(availabilityId);
        }

        Event evRef = [Select Id, StartDateTime, Capacity__c, RecurrenceActivityId, IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceType,
        RecurrenceInterval, RecurrenceDayofWeekMask, RecurrenceTimeZoneSidKey, DurationInMinutes, Store_Location__c, Store_Location__r.RetailStoreId__c,
        EndDateTime, ActivityDate
        FROM Event WHERE Id = :availabilityId LIMIT 1 ];

        Set<DateTime> excludedSlots = new Set<DateTime>();
        Date currentEvDate = evRef.ActivityDate;
        String recREFID = evRef.RecurrenceActivityId;
        String queryRecurringEvs = 'Select Id, Capacity__c, ActivityDate, IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceType, '+
        'RecurrenceInterval, RecurrenceDayofWeekMask, RecurrenceTimeZoneSidKey, DurationInMinutes, Store_Location__r.Name, Store_Location__r.Time_Zone_Id__c, Store_Location__r.StoreCountry__c, '+
        'Store_Location__r.RetailStoreId__c, EndDateTime, StartDateTime '+ 
        'FROM Event '+
        'WHERE ' +
        'RecordType.DeveloperName = \'Availability\' AND IsRecurrence = false '+
        'AND RecurrenceActivityId = :recREFID ' +
        (mode == RecurringEditMode.CURRENT_AND_MORE ? 'AND ActivityDate >= :currentEvDate ' : ' AND ActivityDate >= TODAY ');

        Map<Id, Event> recurringEvsMap = new Map<Id, Event>((List<Event>)Database.query(queryRecurringEvs));
        Map<String, List<Event>> osaMap = getCurrentOnlineAppointmentsMap(recurringEvsMap);

        List<Event> availabilitiesToDelete = new List<Event>();
        for(Id avId : recurringEvsMap.keySet()) {
            if(osaMap.get(avId) == null || osaMap.get(avId).isEmpty() ) {
                availabilitiesToDelete.add(recurringEvsMap.get(avId));
            } else {
                excludedSlots.add(recurringEvsMap.get(avId).StartDateTime);
            }
        }

        if(availabilitiesToDelete.size() > 0) {
            delete availabilitiesToDelete;
            return new Map<String, Object> { 'excludedSlots' => excludedSlots,  'deletedAvailabilities' => (new Map<id, event>(availabilitiesToDelete)).keySet()};
            
        }

        return new Map<String, Object> { 'excludedSlots' => excludedSlots};
    }

    /*=================================================================================================================*/
    //update availability

    public static Object deleteAndCreateRecurringSlot(Event newEv) {

        Event evRef = [Select Id, StartDateTime, Capacity__c, Store_Location__r.RetailStoreId__c From Event WHERE Id = :newEv.Id LIMIT 1 ];
        Map<String, List<Event>> osaMap = getCurrentOnlineAppointmentsMap(new Map<Id, Event>{evRef.Id => evRef});
        Integer osaCount = 0;
        if (osaMap.get(evRef.Id) != null) {
            osaCount = osaMap.get(evRef.Id).size();
        }
        if(osaCount > 0 && (evRef.StartDateTime != newEv.StartDateTime || newEv.Capacity__c < osaCount )) {
            throw new OnlineAppointmentException('CANT_UPDATE_SLOT_ALREADY_USED');
        }

        delete newEv;
        newEv.Id = null;
        newEv.IsRecurrence = true;

        Map<String, Object> result = (Map<String, Object>) createAvailabilities(newEv, new List<DateTime> {newEv.StartDatetime}, evRef.Store_Location__r.RetailStoreId__c);
        return new Map<String, Object> { 'excludedSlots' => (Set<DateTime>) result.get('existingSlots'),  'updatedAvailabilities' => (List<Event>) result.get('createdAvailabilities')};

    }

    /*=================================================================================================================*/
    //upsert Online Appointment from LV.com

    public static Object upsertOnlineAppointment(Map<String,Object> bodyMap){

        //PARSE PARAMS
        String onlineAppointmentId = (String) bodyMap.get('onlineAppointmentId');
        String availabilityId = (String) bodyMap.get('availabilityId');
        String accountId = (String) bodyMap.get('accountId');
        String socialId = (String) bodyMap.get('socialId');
        String openId = (String) bodyMap.get('openId');
        String sourceType = (String) bodyMap.get('sourceType');
        String userId = (String) bodyMap.get('userId');
        Map<String,Object> accountInfos = (Map<String,Object>) bodyMap.get('accountInfos');
        String message = (String) bodyMap.get('message');
        String language = (String) bodyMap.get('language');
        //String specialRequest = (String) bodyMap.get('specialRequest');
        String service = (String) bodyMap.get('service');
        String status = (String) bodyMap.get('status');
        String reason = (String) bodyMap.get('reason');
        String locale = (String) bodyMap.get('locale');
        String dispatchCountry = (String) bodyMap.get('dispatchCountry');
        String onlineAppointmentType = (String) bodyMap.get('appointmentType');
        Map<String, String> appRecordTypeIdsMap = getAppointmentRecordTypesId ();
        String careServiceId =  (String) bodyMap.get('careservice');


        //GET AVAILABILITY AND CAPACITIES BY ID
        Map<String, Object> availabilityObj = (Map<String, Object>) getFreeCapacityByAvailabilityId(availabilityId, onlineAppointmentId);

        //CHECK FREE CAPACITY
        if (((Decimal) availabilityObj.get('freeCapacities')) <= 0){
                throw new OnlineAppointmentException('TIMESLOT_NOT_AVAILABLE');
        } 

        Event onlineAppointment = new Event();
        if(String.isNotEmpty(onlineAppointmentId)){

            List<Event> onlineAppList = [
                SELECT 
                    Id, RecordTypeId, RecordType.DeveloperName,Status__c, Store_Location__c, Store_Location__r.RetailStoreId__c,  WhatId, My_Repairs__c, My_Repairs__r.Client__r.Name, 
                    Store_Location__r.Time_Zone_Id__c,Store_Location__r.StoreCountry__c, Store_Location__r.Name, availabilityId__c,Subject,
                    startDateTime, endDateTime, Reason__c, Service__c,OwnerId, Owner.Name, owner.FirstName, owner.LastName,
                    Language__c, Locale__c, Dispatch_Country__c, appointmentType__c, sourceType__c, wechat_openId__c, Store_Location__r.Address__c, Store_Location__r.tech_address__c, Store_Location__r.Local_Name__c, Store_Location__r.PhoneForClient__c
                FROM Event
                WHERE Id = :onlineAppointmentId
            ];

            if(onlineAppList.size() > 0){
                onlineAppointment = onlineAppList[0];
                if(onlineAppointment.Status__c == 'Assigned' || onlineAppointment.Status__c == 'Cancelled'){
                    throw new OnlineAppointmentException('UPDATE_NOT_AUTHORIZED');
                }
            }
                
        }
        Event availability = (Event) availabilityObj.get('availability');
        onlineAppointment.RecordTypeId = appRecordTypeIdsMap.get('Online_Appointment');
        onlineAppointment.Status__c = (String.isEmpty(status) ? (String.isEmpty(onlineAppointmentId) ? 'Pending' : 'Not Assigned') : status);
        onlineAppointment.Store_Location__c = availability.Store_Location__c;
        onlineAppointment.availabilityId__c = availability.Id;
        //onlineAppointment.Special_Request__c = (String.isNotEmpty(specialRequest) ? specialRequest:  onlineAppointment.Special_Request__c);
        onlineAppointment.startDateTime = availability.StartDateTime;
        onlineAppointment.endDateTime = availability.EndDateTime;
        onlineAppointment.Reason__c = (String.isNotEmpty(reason) ? reason:  onlineAppointment.Reason__c);
        onlineAppointment.Service__c = (String.isNotEmpty(service) ? service:  onlineAppointment.Service__c);
        onlineAppointment.Language__c = (String.isNotEmpty(language) ? language:  onlineAppointment.Language__c);
        onlineAppointment.Locale__c = (String.isNotEmpty(locale) ? locale:  onlineAppointment.Locale__c);
        onlineAppointment.Dispatch_Country__c = (String.isNotEmpty(dispatchCountry) ? dispatchCountry:  onlineAppointment.Dispatch_Country__c);
        onlineAppointment.appointmentType__c = (String.isNotBlank(onlineAppointmentType) ? onlineAppointmentType : ((String.isNotBlank(onlineAppointment.appointmentType__c) ? onlineAppointment.appointmentType__c : null)));
        onlineAppointment.sourceType__c = (String.isNotBlank(sourceType) ? sourceType : ((String.isNotBlank(onlineAppointment.sourceType__c) ? onlineAppointment.sourceType__c : 'LV_COM')));
        onlineAppointment.wechat_openId__c = (String.isNotBlank(openId) ? openId : ((String.isNotBlank(onlineAppointment.wechat_openId__c) ? onlineAppointment.wechat_openId__c : null)));
        onlineAppointment.My_Repairs__c = (String.isNotEmpty(careServiceId) ? careServiceId:  onlineAppointment.My_Repairs__c);
        
        //CREATE ONLINEAPPOINTMENT INSTANCE

        if ((String.isBlank(availability.Store_Location__r.appointmentType__c)
         && onlineAppointment.appointmentType__c == 'distant') 
         || 
         (String.isNotBlank(availability.Store_Location__r.appointmentType__c)
          && (String.isBlank(onlineAppointment.appointmentType__c) || !availability.Store_Location__r.appointmentType__c.containsIgnoreCase(onlineAppointment.appointmentType__c)))) {
            throw new OnlineAppointmentException('APPOINTMENT_TYPE_NOT_AVAILABLE');
        }
        
        if(accountInfos != null){
            Account acc = (Account) JSON.deserialize(JSON.serialize(accountInfos, true), Account.class);
            
            if(String.isNotEmpty(accountId)){
                acc.Id = accountId;
                upsert acc;

            } else if(String.isNotEmpty(userId)){
                List<User> userIdentity = [SELECT Id, AccountId from User WHERE Id =:userId LIMIT 1 ];
                if( userIdentity != null && userIdentity.size() > 0){
                    accountId = userIdentity[0].AccountId;
                }
                acc.Id = accountId;

                upsert acc;    
                
            } else {
                Account prospect = getProspect(acc);
                if(prospect != null && acc.Id == null) {
                    acc.Id = prospect.Id;
                }
                prospect = createProspect(acc, availability.Store_Location__r.RetailStoreId__c,locale);
              
                accountId = prospect.Id;
            }
            NewsLetterMarketingEmail(accountId,locale,acc.Newsletter__c);

            //createProspect and assign appt to new prospect
        } else if(String.isNotEmpty(userId)){
            
            List<User> userIdentity = [SELECT Id, AccountId from User WHERE Id =:userId LIMIT 1];
            if( userIdentity != null && userIdentity.size() > 0)
                accountId = userIdentity[0].AccountId;
        } else if(String.isNotBlank(socialId) && String.isNotBlank(sourceType) ){
            accountId = getAccountBySocialId(socialId, sourceType);
        }

        if(String.isNotEmpty(onlineAppointmentId) && String.isEmpty(accountId) &&
         String.isNotEmpty(availabilityId) &&
         (String.isEmpty(status) || status != 'Pending') || (status == 'Not Assigned' && String.isEmpty(accountId) && String.isNotBlank(onlineAppointment.sourceType__c) && onlineAppointment.sourceType__c.containsIgnoreCase('WECHAT') )){
            throw new OnlineAppointmentException('CANNOT_ASSIGN_APT_WITHOUT_ACCOUNT');
        } 
        system.debug(String.isNotBlank(onlineAppointmentId) && String.isNotBlank(onlineAppointment.WhatId) && onlineAppointment.WhatId != accountId && status == 'Not Assigned');
        system.debug(onlineAppointmentId );
        system.debug(onlineAppointment.WhatId );
        system.debug(status);
        if(String.isNotBlank(onlineAppointmentId) && String.isNotBlank(onlineAppointment.WhatId) && onlineAppointment.WhatId != accountId && onlineAppointment.Status__c == 'Not Assigned') {	
            throw new OnlineAppointmentException('UPDATE_NOT_AUTHORIZED');
        }
        onlineAppointment.WhatId = String.isNotEmpty(accountId) ? accountId : null;
        sendToRms(accountId, availability.Store_Location__r.RetailStoreId__c, availability.Store_Location__c);
        
        system.debug(onlineAppointment);
        system.debug(onlineAppointment.RecordtypeId);
        if(String.isBlank(onlineAppointment.Id)) {
            insert onlineAppointment;
        } else{
            update onlineAppointment;
        }
        // Database.upsert(onlineAppointment);
        system.debug(onlineAppointment);
        if(onlineAppointment.Status__c == 'Not Assigned' && String.isEmpty(onlineAppointmentId)){
            List<Event> onlineAppList = [
                SELECT 
                    Id, RecordTypeId, RecordType.DeveloperName,Status__c, Store_Location__c, Store_Location__r.RetailStoreId__c, My_Repairs__c, My_Repairs__r.Client__r.Name,
                    Store_Location__r.Time_Zone_Id__c, Store_Location__r.StoreCountry__c, Store_Location__r.Name, availabilityId__c,Subject,
                    startDateTime, endDateTime, Reason__c, Service__c,OwnerId, Owner.Name, owner.FirstName, owner.LastName,
                    Language__c, Locale__c, Dispatch_Country__c, appointmentType__c, WhatId, sourceType__c, Store_Location__r.Address__c, Store_Location__r.tech_address__c, Store_Location__r.Local_Name__c, Store_Location__r.PhoneForClient__c
                FROM Event
                WHERE Id = :onlineAppointment.Id
            ];
            if(onlineAppList.size() > 0){
                onlineAppointment = onlineAppList[0];
            }
                
        }
        return new AppointmentWrapper(onlineAppointment, true, false);
    }



    /*=================================================================================================================*/
    //Get Available Users By appointment

    public static Object getAvailableUsers(String onlineAppointmentId, Boolean checkAnyway){

        List<Event> onlineApptList = [
            SELECT Id, Status__c, startDateTime, endDateTime
            FROM Event 
            WHERE RecordType.DeveloperName = 'Online_Appointment'
            AND Id = :onlineAppointmentId
        ];
        Map<String, Object> response = new Map<String, Object>();
        if(onlineApptList.size() > 0){
            Event onlineAppt = onlineApptList[0];
            if(onlineAppt.Status__c == 'Assigned' && !checkAnyway){
                response.put('online_appointment', onlineAppt);
                return response;
            }
            response.put('userIds', getAvailableTeamUsers(onlineAppt.startDateTime, onlineAppt.endDateTime, null));
            return response;
        }
        throw new OnlineAppointmentException('APT_ID_NOT_EXIST');
    }

    /*=================================================================================================================*/
    //Cancel Appointment from LV.com Client Profile (maybe will be used by CSC)

    public static Object cancelOnlineAppointmnent(String onlineAppointmentId, String accountId){
        system.debug('cancelOnlineAppointmnent');
        List<Event> onlineAppt = [Select Id, Status__c, WhatId  
        From Event 
        Where RecordType.DeveloperName = 'Online_Appointment'
        AND Id = :onlineAppointmentId ];

        if(onlineAppt.size() > 0){
            //IF PENDING SO DELETE THE ONLINE APPT
            if(String.isBlank(accountId) || onlineAppt[0].WhatId != accountId){
                throw  new OnlineAppointmentException('CANCELATION_NOT_AUTHORIZED');
            }
            if(onlineAppt[0].Status__c == 'Pending'){
                delete onlineAppt[0];
            } else{
                onlineAppt[0].Status__c = 'Cancelled';
                update onlineAppt[0];
            }
            return new ResponseHandler(true, null, null, null, null, null);
        }

        throw  new OnlineAppointmentException('CANCEL_APT_ID_NOT_EXIST');

        
    }

    /*=================================================================================================================*/
    //Assign Appointment to CA

    public static Object assignAppointments(String userId, String onlineAppointmentId, Boolean reassignFromManager){
        Map<String, Object> response = new Map<String, Object>();
        response.put('isAssigned', false);
        List<Event> onlineApptList = [SELECT Id, Status__c, OwnerId From Event WHERE RecordType.DeveloperName = 'Online_Appointment' AND Id = :onlineAppointmentId];
        Event onlineAppt;
        if(onlineApptList.size() > 0){
            onlineAppt = onlineApptList[0];
            if(onlineAppt.Status__c == 'Not Assigned'){
                onlineAppt.OwnerId = userId != null ? userId : UserInfo.getUserId();
                onlineAppt.Status__c = 'Assigned';
                upsert onlineAppt;
                response.put('isAssigned', true);
            } else if(onlineAppt.Status__c == 'Assigned' && reassignFromManager == true){
                onlineAppt.OwnerId = userId != null ? userId : UserInfo.getUserId();
                upsert onlineAppt;
                response.put('isAssigned', true);
            }
            onlineApptList = [SELECT Id, Status__c, OwnerId, Owner.FirstName, Owner.LastName From Event WHERE RecordType.DeveloperName = 'Online_Appointment' AND Id = :onlineAppointmentId];
            onlineAppt = onlineApptList.size() > 0 ? onlineApptList[0] : onlineAppt;
            response.put('appointment', onlineAppt);
            return response;
        }

        throw  new OnlineAppointmentException('APT_ID_NOT_EXIST');
        

    }


    /*=================================================================================================================*/
    //Get User Identity Appointments

    public static Object getClientAppointments(Map<String, String> paramsMap, Boolean forICON){

        String userId = paramsMap.get('userId');
        String accountId = paramsMap.get('accountId');
        String onlineAppointmentId = paramsMap.get('onlineAppointmentId');
        String socialId = paramsMap.get('socialId');
        String sourceType = paramsMap.get('sourceType');
        Integer filter = paramsMap.get('filter')  != null ? Integer.valueOf(paramsMap.get('filter')) : 0;
        Integer limitQuery = paramsMap.get('Limit') != null ? Integer.valueOf(paramsMap.get('Limit')) : 0;
        Integer offset = paramsMap.get('Offset') != null ? Integer.valueOf(paramsMap.get('Offset')) : 0;

        
        if(String.isNotEmpty(userId)){
            List<User> userIdentity = [SELECT Id, AccountId from User WHERE Id =:userId LIMIT 1];
            if( userIdentity != null && userIdentity.size() > 0)
                accountId = userIdentity[0].AccountId;
        } else if(String.isNotBlank(socialId) && String.isNotBlank(sourceType) ){
            accountId = getAccountBySocialId(socialId, sourceType);
        }

        DateTime currentTime = System.now();
        String filterCondition = '';

        switch on filter {  
                when 1 {        
                    filterCondition = ' AND startDateTime >= :currentTime AND Status__c != \'Cancelled\' ';
                }
                when 2 {        
                    filterCondition = ' AND startDateTime < :currentTime ';
                }
                when else {
                    filterCondition = '';
                }
            }
            String specificApptCondition = '';
        if(String.isNotEmpty(onlineAppointmentId)){
            specificApptCondition = ' AND Id = :onlineAppointmentId ';
        }
        if(String.isNotEmpty(accountId)){
            String query = 'Select Id, Status__c, Subject, StartDateTime, owner.name, owner.FirstName, owner.LastName, ownerId, availabilityId__c, WhatId,What.Name, Account.TECHPreferredCA__c, Account.OwnerId, Account.Name, Account.Salutation,  '+
            ' EndDateTime, reason__c, Service__c, Language__c, Store_Location__r.RetailStoreId__c, Store_Location__r.Name, RecordType.DeveloperName, Store_Location__r.Time_Zone_Id__c,Store_Location__r.StoreCountry__c, Locale__c, Dispatch_Country__c, appointmentType__c, sourceType__c, Store_Location__r.Address__c, Store_Location__r.tech_address__c, Store_Location__r.Local_Name__c, Store_Location__r.PhoneForClient__c, My_Repairs__c, My_Repairs__r.Client__r.Name '+
            ' From Event ' +
            ' Where '+
            ' WhatId = :accountId '+
            ' AND Status__c != \'Pending\' '+
            filterCondition +
            specificApptCondition +
            ' ORDER BY startDateTime DESC ' +
            ( limitQuery > 0 ? ' LIMIT :limitQuery ': '' ) +
            ( offset > 0 ? ' OFFSET :offset ' : '' );

            List<Event> onlineAppt =  Database.query(query);
            List<AppointmentWrapper> oApptWrappers = new List<AppointmentWrapper>();
            for(Event ev : onlineAppt){
                oApptWrappers.add(new AppointmentWrapper(ev, false, forICON));
            }
            Map<String, Object> result = new Map<String, Object>();
            result.put('records',oApptWrappers);
            return result;
        }
        
        return new List<Event>();
    }

    /*=================================================================================================================*/
    //getTeamUsers Appointments ICON

    public static Object getOnlineAndTeamAppointments (Boolean onlyOnline, Boolean onlyUnassigned, String datesString, String startDate, String endDate, String storeCode){
        List<Event> appointments = getOnlineAndTeamAppointmentsList(onlyOnline,  onlyUnassigned,  datesString,  startDate,  endDate, storeCode);
        Map<String, Object> result = new Map<String, Object>();
        result.put('records',appointments);
        return result;
 
    }
    /*=================================================================================================================*/
    //getTeamUsers Appointments DESKTOP

    public static Object getOnlineAndTeamAppointmentWrappers (Boolean onlyOnline, Boolean onlyUnassigned, String datesString, String startDate, String endDate, String storeCode){
        List<Event> apts =  getOnlineAndTeamAppointmentsList(onlyOnline,  onlyUnassigned,  datesString,  startDate,  endDate, storeCode);
        List<AppointmentWrapper> aptW = new List<AppointmentWrapper>();

        for(Event apt : apts){
            aptw.add(new AppointmentWrapper(apt, false, true));
        }
        return aptw;
    }

    /*=================================================================================================================*/
    //getTeamUsers Appointments  List

    public static List<Event> getOnlineAndTeamAppointmentsList (Boolean onlyOnline, Boolean onlyUnassigned, String datesString, String startDate, String endDate, String storeId){
        User currentUser = getUserInfos();
        String storeCode = storeId != null ? storeId : currentUser.DefaultStore__c;
        if(String.isBlank(storeCode) || storeCode == 'null' || storeCode == 'undefined'){
            throw new OnlineAppointmentException('NO_STORE_CODE');
        }
        List<Event> appointments = new List<Event>();

        List<Date> dates = new List<Date>();
        String dateCondition = ' AND activityDate = NEXT_N_DAYS:30 ';
        if(String.isNotEmpty(datesString)){
            List<String> dateList = datesString.split(';');
            for(String d : dateList){
                dates.add(Date.valueOf(d));
            }
        } 
        if( dates.size() > 0 ){
            dateCondition =  ' AND activityDate IN :dates ' ;
        }else if(String.isNotEmpty(startDate) && String.isNotEmpty(endDate)){
            dateCondition = '  AND activityDate >= '+ startDate + ' AND activityDate <= '+ endDate +' ';
        }


        if(onlyUnassigned == true){
            String query = appointmentQueryFields() + ' RecordType.DeveloperName = \'Online_Appointment\' '+
                'AND Store_Location__r.RetailStoreId__c = :storeCode AND Status__c = \'Not Assigned\' AND activityDate >= LAST_N_DAYS:7 '+ 
                'ORDER BY ActivityDate ASC ';
            system.debug(query);
            appointments = Database.query(query);
        } else {
            String query = appointmentQueryFields() + ' RecordType.DeveloperName = \'Online_Appointment\' '+
                'AND Store_Location__r.RetailStoreId__c = :storeCode AND (' +
                    '((Status__c = \'Assigned\' '+dateCondition + ') '+
                    'OR (Status__c = \'Not Assigned\' AND activityDate >= LAST_N_DAYS:7 AND  activityDate <= NEXT_N_DAYS:60)) ' +
                ') ' +
                'ORDER BY ActivityDate ASC ';
           
            appointments = Database.query(query);
            if(!onlyOnline){
                appointments.addAll(getTeamUsersAppointments(dateCondition, storeCode));
            }
        }
        return appointments;
    }

    /*=================================================================================================================*/
    //GET TeamUsersAppointments

    public static List<Event> getTeamUsersAppointments(String dateCondition, String storeCode){
                List<User> tmList = [SELECT Id
            From User
            Where  DefaultStore__c =: storeCode AND  isActive = TRUE AND Is_Identity_User__c = FALSE];

            String query = appointmentQueryFields() +
                ' OwnerId IN : tmList '+
                ' AND  RecordType.DeveloperName = \'Appointments\' '+
                dateCondition +
                ' ORDER BY ActivityDate ASC ';
            return Database.query(query);
    }

    /*=================================================================================================================*/
    //upsert Online Appointment from Desktop

    public static Object upsertOnlineAppointmentDesktop(Map<String,Object> bodyMap){

        //PARSE PARAMS
        String onlineAppointmentId = (String) bodyMap.get('onlineAppointmentId');
        String availabilityId = (String) bodyMap.get('availabilityId');
        String accountId = (String) bodyMap.get('accountId');
        if(String.isEmpty(accountId)){
            throw new OnlineAppointmentException('CANNOT_ASSIGN_APT_WITHOUT_ACCOUNT');
        }
        String message = (String) bodyMap.get('message');
        String language = (String) bodyMap.get('language');
        //String specialRequest = (String) bodyMap.get('specialRequest');
        String service = (String) bodyMap.get('service');
        String status = (String) bodyMap.get('status');
        String reason = (String) bodyMap.get('reason');
        String locale = (String) bodyMap.get('locale');
        String dispatchCountry = (String) bodyMap.get('dispatchCountry');
        String onlineAppointmentType = (String) bodyMap.get('appointmentType');
        Map<String, String> appRecordTypeIdsMap = getAppointmentRecordTypesId ();

        //GET AVAILABILITY AND CAPACITIES BY ID
        Map<String, Object> availabilityObj = (Map<String, Object>) getFreeCapacityByAvailabilityId(availabilityId, onlineAppointmentId);
        

        //CHECK FREE CAPACITY
        if (((Decimal) availabilityObj.get('freeCapacities')) <= 0){
                throw new OnlineAppointmentException('TIMESLOT_NOT_AVAILABLE');
        } 

        Event onlineAppointment = new Event();
        if(String.isNotEmpty(onlineAppointmentId)){
            List<Event> onlineAppList = [
                SELECT 
                    Id, RecordTypeId, RecordType.DeveloperName,Status__c, Store_Location__c, Store_Location__r.RetailStoreId__c,My_Repairs__c, My_Repairs__r.Client__r.Name,
                    Store_Location__r.Time_Zone_Id__c, Store_Location__r.StoreCountry__c, Store_Location__r.Name, availabilityId__c,Subject,
                    startDateTime, endDateTime, Reason__c, Service__c,OwnerId, Owner.Name, owner.FirstName, owner.LastName,
                    Language__c, Locale__c, Dispatch_Country__c, appointmentType__c,sourceType__c, Store_Location__r.Address__c, Store_Location__r.tech_address__c, Store_Location__r.Local_Name__c, Store_Location__r.PhoneForClient__c
                FROM Event
                WHERE Id = :onlineAppointmentId
            ];
            if(onlineAppList.size() > 0){
                onlineAppointment = onlineAppList[0];
            }
        }
        Event availability = (Event) availabilityObj.get('availability');
        onlineAppointment.RecordTypeId = appRecordTypeIdsMap.get('Online_Appointment');
        onlineAppointment.Status__c = (String.isEmpty(status) ? 'Not Assigned' : status);
        onlineAppointment.Store_Location__c = availability.Store_Location__c;
        onlineAppointment.availabilityId__c = availability.Id;
        //onlineAppointment.Special_Request__c = (String.isNotEmpty(specialRequest) ? specialRequest:  onlineAppointment.Special_Request__c);
        onlineAppointment.startDateTime = availability.StartDateTime;
        onlineAppointment.endDateTime = availability.EndDateTime;
        onlineAppointment.Reason__c = (String.isNotEmpty(reason) ? reason:  onlineAppointment.Reason__c);
        onlineAppointment.Service__c = (String.isNotEmpty(service) ? service:  onlineAppointment.Service__c);
        onlineAppointment.Language__c = (String.isNotEmpty(language) ? language:  onlineAppointment.Language__c);
        onlineAppointment.Locale__c = (String.isNotEmpty(locale) ? locale:  onlineAppointment.Locale__c);
        onlineAppointment.Dispatch_Country__c = (String.isNotEmpty(dispatchCountry) ? dispatchCountry:  onlineAppointment.Dispatch_Country__c);
        onlineAppointment.appointmentType__c = (String.isNotEmpty(onlineAppointmentType) ? onlineAppointmentType : ((String.isNotEmpty(onlineAppointment.appointmentType__c) ? onlineAppointment.appointmentType__c : null)));
        onlineAppointment.sourceType__c = (String.isNotEmpty(onlineAppointment.sourceType__c) ? onlineAppointment.sourceType__c : 'CSC');

        if ((String.isBlank(availability.Store_Location__r.appointmentType__c)
         && onlineAppointment.appointmentType__c == 'distant') 
         || 
         (String.isNotBlank(availability.Store_Location__r.appointmentType__c)
          && (String.isBlank(onlineAppointment.appointmentType__c) || !availability.Store_Location__r.appointmentType__c.containsIgnoreCase(onlineAppointment.appointmentType__c)))) {
            throw new OnlineAppointmentException('APPOINTMENT_TYPE_NOT_AVAILABLE');
        }
        //CREATE ONLINEAPPOINTMENT INSTANCE 

        onlineAppointment.WhatId = accountId ;
        sendToRms(accountId, availability.Store_Location__r.RetailStoreId__c, availability.Store_Location__c);
        

        Database.upsert(onlineAppointment);
        if(String.isNotBlank(accountId)) {
            Account acc = [SELECT Id, DREAMID__c, AttachedStore__pc, Date_Identity__pc,HomeAddressCountryCode__pc FROM account WHERE Id =: accountId];
            if(String.isBlank(acc.DREAMID__c) && acc.Date_Identity__pc == null) {
                createProspect(acc, availability.Store_Location__r.RetailStoreId__c,locale);
            }
        }

        return new AppointmentWrapper(onlineAppointment, true, false);
    }

    /*=================================================================================================================*/
    //GET Appointment Query Fields

    public static String appointmentQueryFields(){
        return 'SELECT Id, Subject, StartDateTime, owner.name, owner.FirstName, owner.LastName, ownerId, EndDateTime, Store_Location__r.RetailStoreId__c, Store_Location__r.Name, My_Repairs__c, My_Repairs__r.Client__r.Name,' +
            ' AccountId, Account.name, Account.Salutation,  Account.FirstName, Account.LastName, Account.TECHPreferredCA__c, Account.OwnerId, SaleAmount__c, '+
            ' reason__c, Service__c, Language__c,  Store_Location__r.Time_Zone_Id__c, Store_Location__r.StoreCountry__c,  availabilityId__c, '+
            ' Purchased_Product__c,No_Transaction__c, Purchased_Product__r.PurchasedDate__c, ClientNoShow__c, '+
            ' Purchased_Product__r.CurrencyCode__c, Purchased_Product__r.Store__c, RelatedTicketNumber__c, Description, WhatId , What.Name,  '+
            ' What.FirstName , What.LastName, Sale__c, Notes__c, TECH_Appointment_subject_picklist__c , Status__c, RecordTypeId, RecordType.DeveloperName, Locale__c, Dispatch_Country__c, appointmentType__c, sourceType__c, '+
            ' Store_Location__r.Address__c, Store_Location__r.tech_address__c, Store_Location__r.Local_Name__c, Store_Location__r.PhoneForClient__c ' +
            ' FROM EVENT  WHERE  ';
    }

    /*=================================================================================================================*/
    //GET USERINFOS

    public static User getUserInfos(){
        User u = [Select WWEmployeeNumber__c, RMS_ID__c, Email, Id, DefaultStore__c, TECH_IsManager__c, FirstName, LastName, FullPhotoUrl, ProfileId,
        Profile.Name From User Where ID = :UserInfo.getUserId()];
        return u;
    }

    /*=================================================================================================================*/
    //GET PROSPECT

    public static Account getProspect(Account client) {

        // MISSING IDENTIFIER
        if(String.isEmpty(client.PersonMobilePhone) && String.isEmpty(client.PersonHomePhone) && String.isEmpty(client.PersonOtherPhone) && String.isEmpty(client.PersonEmail) && String.isEmpty(client.LastName) && String.isEmpty(client.FirstName)){
            return null;
        }

        List<Account> clients;

        String condition_name = '';
        String condition_identifier = '';
        String clientPhone = (String.isEmpty(client.PersonMobilePhone) ? (String.isEmpty(client.PersonHomePhone) ? client.PersonOtherPhone : client.PersonHomePhone) : client.PersonMobilePhone);
        String clientPhoneField = (String.isEmpty(client.PersonMobilePhone) ? (String.isEmpty(client.PersonHomePhone) ? 'PersonOtherPhone' : 'PersonHomePhone') : 'PersonMobilePhone');
        
        // IDENTIFIER
        if(!String.isEmpty(client.PersonEmail) && !String.isEmpty(clientPhone)){
            condition_identifier = ' AND (PersonEmail = \'' + client.PersonEmail + '\' OR ' + clientPhoneField + ' = \'' + clientPhone + '\') ';
        }
        else if(!String.isEmpty(client.PersonEmail)){
            condition_identifier = ' AND PersonEmail = \'' + client.PersonEmail + '\'';
        }
        else if(!String.isEmpty(clientPhone)){
            condition_identifier = ' AND ' + clientPhoneField + ' = \'' + clientPhone + '\'';
        }
        

        // NAME
        condition_name = ' LastName = \'' + String.escapeSingleQuotes(client.LastName) + '\' AND FirstName = \'' + String.escapeSingleQuotes(client.FirstName) + '\' ';

        String query = 'SELECT Id, PersonContactId, PersonMobilePhone, LocalMobilePhone__pc ' +
                        'FROM Account ' + 
                        'WHERE ' + condition_name + condition_identifier +
                        'ORDER BY LastTrans__pc, LastModifiedDate DESC ';

        clients = Database.query(query);           

        if(!clients.isEmpty()){
            return [SELECT Id, PersonContactId, PersonMobilePhone, LocalMobilePhone__pc FROM Account WHERE ID =:clients[0].Id Limit 1 FOR UPDATE];
        }
        
        return null;
    }

    /*=================================================================================================================*/
    //createProspect
    public static Account createProspect(Account client, String attachedStore, String local) {

        client.IsProspect__pc = true;
        client.ProspectForDream__c = true;

        Language_Mapping_ATG_SF__mdt localPreferredLanguage;
        if(String.isNotBlank(local))
        {
            localPreferredLanguage = getLocalAndPreferredLanguage(null,local);    
        }
        else if(String.isNotBlank(client.HomeAddressCountryCode__pc))
        {
            localPreferredLanguage = getLocalAndPreferredLanguage(client.HomeAddressCountryCode__pc,null);
        }

        if(localPreferredLanguage!=null)
        {
            client.Local__c = String.isNotBlank(localPreferredLanguage.ATG__c) ? localPreferredLanguage.ATG__c : 'eng-us';
            client.PreferredLanguage__pc = String.isNotBlank(localPreferredLanguage.Language_Iso3__c) ? localPreferredLanguage.Language_Iso3__c : 'ENG';
        }


        if(client.DREAMID__c != null){
            Database.upsert(client, Account.Fields.DREAMID__c, false);
        }
        else {
            client.source__c = 'On App';
            client.Typology__pc = 'Prospect';
            client.AttachedStore__pc = attachedStore;
            Database.upsert(client);
        }

        return client;
    }
    /*=================================================================================================================*/
    //Send To RMS
    public static Void sendToRms(String clientId, String storeCode, String storeId) {
        try {
            if(String.isNotBlank(clientId)){
                List<Account> clients = [Select id, AttachedStore__pc, Store__pc, AttachedStoreCode__pc from Account where Id =: clientId and RMSId__pc = null];
                if(clients.size() > 0){
                    Account client = clients[0];
                    if(String.isBlank(client.AttachedStore__pc)){
                        client.AttachedStore__pc = storeCode;
                        client.AttachedStoreCode__pc = storeCode;
                        client.Store__pc = storeId;
                        update client;
                    }
                    if(IDENTITY_Utils.isStoreTypeValidForRMS(client)){
                        SO_CreateUpdateRMSCLient_Utils.createAccountIntoRMS_WS_v5(clientId);
                    }
                    
                }
            }
        } catch(Exception  e) {
            system.debug(e.getMessage());
        }
    }

    /*=================================================================================================================*/
    //getAppointment recordTypes

    public static Map<String, String> getAppointmentRecordTypesId (){
        if(appointmentRecordTypesId != null) {
            return appointmentRecordTypesId;
        }
        List<RecordType> recordTypes = [Select Id, DeveloperName From RecordType where DeveloperName IN ('Appointments', 'Online_Appointment', 'Availability')];
        Map<String, String> appRecordTypeIdsMap = new Map<String, String>();
        for( RecordType record : recordTypes){
            appRecordTypeIdsMap.put(record.DeveloperName, record.Id);
        }
        appointmentRecordTypesId = appRecordTypeIdsMap;
        return appointmentRecordTypesId;
    }

    /*=================================================================================================================*/
    //getTeamUsers

    public static Set<Id> getAvailableTeamUsers (Datetime startRange, Datetime endRange, String storeCode){
        User currentUser = getUserInfos();
        Set<Id> userIds = new Set<Id>();
        if(currentUser.Profile.Name.containsIgnoreCase('ICON_SA')) {
            List<TeamMember__c> tmList = [SELECT User__c FROM TeamMember__c WHERE Manager__c = :UserInfo.getUserId() AND User__r.isActive = TRUE];
            for(TeamMember__c tm : tmList){
                userIds.add(tm.User__c);
            }
            
        } else {
            userIds = (new Map<Id, User>(getStoreUsers((String.isNotBlank(storeCode) ? storeCode :  currentUser.DefaultStore__c )))).keyset();
        }
        

        List<AggregateResult> ar = [
            SELECT OwnerId 
            FROM Event
            WHERE OwnerID IN : userIds AND 
            ((startDateTime <= :startRange  AND endDateTime >= :startRange) OR startDateTime <= :endRange.addMinutes(30))
            GROUP BY OwnerId
        ];

        for(AggregateResult arr:ar){ 
            Id userId=(Id)arr.get('OwnerId');
            userIds.remove(userId);    
        }

        return userIds;
    }

    /*=================================================================================================================*/ 
    public static List<User> getStoreUsers(String storeCode){

        return [Select WWEmployeeNumber__c, RMS_ID__c, Email, Id, DefaultStore__c, TECH_IsManager__c, FirstName, LastName, FullPhotoUrl, ProfileId, Profile.Name
        FROM User
        WHERE DefaultStore__c = :(String.isNotBlank(storeCode) ? storeCode :  getUserInfos().DefaultStore__c )  AND
        DefaultStore__c != null  AND 
        DefaultStore__c != '' AND
        isActive = true AND
        IsTechnicalUser__c = false AND
        (NOT Email like 'store_%')
        Limit 500];
    }

    /*=================================================================================================================*/ 
    public static List<User> getUsersByIds(Set<Id> userIds){

        return [Select WWEmployeeNumber__c, RMS_ID__c, Email, Id, DefaultStore__c, TECH_IsManager__c, FirstName, LastName, FullPhotoUrl, ProfileId, Profile.Name
        FROM User
        WHERE Id In: userIds];
    }

    /*=================================================================================================================*/ 
    public static String getAccountBySocialId(String socialId, String sourceType){

        String externalId = sourceType.containsIgnoreCase('WECHAT') ? 'WECHAT_'+socialId : sourceType+ '_' + socialId;
        List<Social_Media_Identifier__c> identifiersByExternalId = [
            SELECT Client__c
            FROM Social_Media_Identifier__c
            WHERE Social_SF_External_Id__c =: externalId
        ];
        if(!identifiersByExternalId.isEmpty()){
            return identifiersByExternalId[0].Client__c;
        }
        return null;
    }

    /*=================================================================================================================*/
    //getStoreLocalTime 

    public static Datetime getStoreLocalTime (String timeZoneId , Datetime d){
        if(String.isNotEmpty(timeZoneId) && d != null){
            Timezone tz = Timezone.getTimeZone(timeZoneId);
            return d.addSeconds(tz.getOffset(d)/1000);
        }
        return null;
    }

    public static String getStoreTimezone (String storeCountry, String timezone){
        return (String.isNotBlank(timezone) ? timezone : (storeCountry == 'CHINA' ? 'Asia/Shanghai' : 'GMT') );
    }

    /*=================================================================================================================*/
    //getStoreLocalTime 

    public static Object  getAvalaibleStoresByCountry (String country, String storeIds){
        List<string> storeList;
        String ownerCondition = 'Store_Location__r.StoreCountry__c = :country';
        if(String.isNotBlank(storeIds)) {
            storeList = storeIds.split(';');
            ownerCondition = 'Store_Location__r.RetailStoreId__c IN : storeList';
        } else if (String.isBlank(country)) {
            throw new OnlineAppointmentException('MISSING_PARAMS');
        }
        List<AggregateResult> res = Database.query('select  Count(Id) total, Sum(Capacity__c) capacities, Store_Location__r.RetailStoreId__c, recordtype.developername'+
        ' from event where  '+ownerCondition+
        ' and recordtype.developerName IN (\'Availability\', \'Online_Appointment\') and startDateTime = NEXT_N_DAYS:30 AND Status__c != \'Cancelled\' AND Status__c != \'Pending\' AND isRecurrence = false Group By Store_Location__r.RetailStoreId__c, recordtype.developername Order by store_Location__r.RetailStoreId__c, recordtype.developerName asc');
        Map<String, Decimal> resMap = new Map<String, Decimal>();
        Map<String, Boolean> resultMap = new Map<String, Boolean>();
        for (AggregateResult r: res){
            if(r.get('RetailStoreId__c') != null) {
                if( ((String)r.get('DeveloperName')) == 'Availability'){
                    resMap.put((String)r.get('RetailStoreId__c'), (Decimal)r.get('capacities'));
                }
    
                if( ((String)r.get('DeveloperName')) == 'Online_Appointment'){

                    resMap.put((String)r.get('RetailStoreId__c'), resMap.get((String)r.get('RetailStoreId__c')) - ((Decimal)r.get('total')));
                }

                resultMap.put((String)r.get('RetailStoreId__c'), resMap.get((String)r.get('RetailStoreId__c')) > 0);
            }
            
            
        }

        return resultMap;

    }
 

    /*=================================================================================================================*/

    public class OnlineAppointmentException extends Exception {}


    public class ResponseHandler {
        public Boolean success {get; set;}
        public List<ErrorWrapper> errors {get;set;}
        public Boolean created {get;set;}

        public ResponseHandler(System.StatusCode statusCode, String message, List<String> fields, String action){
            this.success = false;
            this.errors = new List<ErrorWrapper>{ new ErrorWrapper(statusCode, message, fields, action)};
            this.created = false;
        }
        public ResponseHandler(Boolean success, Boolean created, System.StatusCode statusCode, String message, List<String> fields, String action){
            this.success = success;
            this.errors = success == true ? null : new List<ErrorWrapper>{ new ErrorWrapper(statusCode, message, fields, action)};
            this.created = created;
        }
        
    } 

    public class ErrorWrapper {
        public String action {get; set;}
        public System.StatusCode sfCode {get; set;}
        public String message {get;set;}
        public List<String> fields {get;set;}
        public ErrorWrapper(System.StatusCode statusCode, String message, List<String> fields, String action){
            this.fields = new List<String>();
            this.sfCode = statusCode;
            this.message = message;
            this.fields = fields;
            this.action = action;
        }
    }

    public class StoreAvailabilities{
        public String storeId {get; set;}
        public String storeTimeZone {get; set;}
        public String appointmentType {get; set;}
        public List<DateSlots> dates {get; set;}

        public StoreAvailabilities(String storeId, List<Event> availabilities){
            this.storeId = storeId;
            this.storeTimeZone = availabilities.size() > 0 && availabilities[0].Store_Location__r != null ? getStoreTimezone(availabilities[0].Store_Location__r.StoreCountry__c, availabilities[0].Store_Location__r.Time_Zone_Id__c) : null;
            List<DateSlots> dates = new List<DateSlots>();
            Map<Date, List<Event>> dateSlotMap = new Map<Date, List<Event>>();
            for(Event av : availabilities){
                this.appointmentType = av.Store_Location__r.AppointmentType__c;
                Date localDate =  av.Store_Location__r != null ? getStoreLocalTime(getStoreTimezone(av.Store_Location__r.StoreCountry__c, av.Store_Location__r.Time_Zone_Id__c), av.StartDateTime).date() : null;
                if(dateSlotMap.get(localDate) == null){
                    dateSlotMap.put(localDate, new List<Event>());
                }
                dateSlotMap.get(localDate).add(av);
            }
            for(Date activityDate : dateSlotMap.keySet()){
                dates.add(new DateSlots(activityDate, dateSlotMap.get(activityDate)));
            }
            this.dates = dates;
            if(String.isBlank(this.appointmentType)){
                this.appointmentType = null;
            }
        }
    }

    public class DateSlots{
        public Date gmtAppointmentDate {get; set;}
        public Date localStoreAppointmentDate {get; set;}
        public List<Slot> slots {get; set;}

        public DateSlots(Date localeActivityDate, List<Event> availabilities){
            this.localStoreAppointmentDate = localeActivityDate;
            List<Slot> slots = new List<Slot>();
            for(Event av : availabilities){
                slots.add(new Slot(av));
            }
            this.slots = slots;
        }
    }

    public class Slot{
        public String id {get; set;}
        public Datetime gmtStartDateTime {get; set;}
        public Datetime localStoreStartDateTime {get; set;}
        public Datetime gmtEndDateTime {get; set;}
        public Datetime localStoreEndDateTime {get; set;}

        public Slot(Event slot){
            this.id = slot.Id;
            this.gmtStartDateTime = slot.startDateTime;
            this.localStoreStartDateTime = slot.Store_Location__r != null ? getStoreLocalTime(getStoreTimezone(slot.Store_Location__r.StoreCountry__c, slot.Store_Location__r.Time_Zone_Id__c), slot.startDateTime) : null;
            this.gmtEndDateTime = slot.endDateTime;
            this.localStoreEndDateTime = slot.Store_Location__r != null ? getStoreLocalTime(getStoreTimezone(slot.Store_Location__r.StoreCountry__c, slot.Store_Location__r.Time_Zone_Id__c), slot.endDateTime) : null;
        }
    }

    public class AppointmentWrapper{
        public String id {get; set;}
        public Datetime gmtStartDateTime {get; set;}
        public Datetime localStoreStartDateTime {get; set;}
        public Datetime gmtEndDateTime {get; set;}
        public Datetime localStoreEndDateTime {get; set;}
        public String availableSlotId {get;set;}
        public String subject {get;set;}
        public String status {get;set;}
        public String ownerId {get;set;}
        public String ownerName {get;set;}
        public String ownerFirstName {get;set;}
        public String ownerLastName {get;set;}
        public String reason {get;set;}
        public String storeCode {get;set;}
        public String storeName {get;set;}
        public String recordType {get;set;}
        public String timeZone {get;set;}
        public String specialRequest {get;set;}
        public String service {get;set;}
        public String language {get;set;}
        public String accountId {get;set;}
        public String accountName {get;set;}
        public String accountSalutation {get;set;}
        public String local {get;set;}
        public String dispatchCountry {get;set;}
        public String clientPreferredCAId {get;set;}
        public String clientPreferredCAName {get;set;}
        public String appointmentType {get; set;}
        public String sourceType {get; set;}
        public String storeLocalAdress {get;set;}
        public String storeAdress {get;set;}
        public String storeLocalName {get;set;}
        public String storeLocalPhone {get;set;}
        public String careservice {get;set;}

        public AppointmentWrapper(Event ev, Boolean encryptAccountId, Boolean forICON){
            this.id = ev.Id;
            this.gmtStartDateTime = ev.startDateTime;
            this.localStoreStartDateTime = ev.Store_Location__r != null ? getStoreLocalTime(getStoreTimezone(ev.Store_Location__r.StoreCountry__c, ev.Store_Location__r.Time_Zone_Id__c), ev.startDateTime) : null;
            this.gmtEndDateTime = ev.endDateTime;
            this.localStoreEndDateTime = ev.Store_Location__r != null ? getStoreLocalTime(getStoreTimezone(ev.Store_Location__r.StoreCountry__c, ev.Store_Location__r.Time_Zone_Id__c), ev.endDateTime) : null;
            this.subject = ev.Subject;
            this.status = ev.Status__c;
            this.ownerFirstName = ev.owner.FirstName;
            this.ownerLastName = ev.owner.LastName;
            this.ownerName = ev.owner.name;
            this.ownerId = ev.ownerId;
            this.reason = ev.reason__c;
            this.storeCode =  ev.Store_Location__r != null ? ev.Store_Location__r.RetailStoreId__c : null;
            this.storeName =  ev.Store_Location__r != null ? ev.Store_Location__r.Name : null;
            this.recordType = ev.recordType.DeveloperName;
            this.timeZone =  ev.Store_Location__r != null ? getStoreTimezone(ev.Store_Location__r.StoreCountry__c, ev.Store_Location__r.Time_Zone_Id__c) : null;
            this.availableSlotId = ev.AvailabilityId__c;
            //this.specialRequest = ev.Special_Request__c;
            this.service = ev.Service__c;
            this.language = ev.Language__c;
            this.accountId =  encryptAccountId && ev.WhatId != null ? IDENTITY_Utils.getEncryptedId(ev.WhatId) : ev.WhatId;
            this.local = ev.Locale__c;
            this.dispatchCountry = ev.Dispatch_Country__c;
            this.appointmentType = String.isBlank(ev.AppointmentType__c) ? null :ev.AppointmentType__c;
            this.sourceType = ev.sourceType__c;
            if(forICON == true ){
                this.clientPreferredCAId = ev.Account.OwnerId;
                this.clientPreferredCAName = ev.Account.TECHPreferredCA__c;
                this.accountName = ev.My_Repairs__c  != null ? ev.My_Repairs__r.Client__r.Name : ev.What.Name;
                this.accountSalutation = ev.Account.Salutation;
            }
            this.storeLocalAdress =  ev.Store_Location__r != null ? ev.Store_Location__r.tech_address__c : null;
            this.storeAdress =  ev.Store_Location__r != null ? ev.Store_Location__r.Address__c : null;
            this.storeLocalName =  ev.Store_Location__r != null ? ev.Store_Location__r.Local_Name__c : null;
            this.storeLocalPhone =  ev.Store_Location__r != null ? ev.Store_Location__r.PhoneForClient__c : null;
            
            this.careservice = ev.My_Repairs__c  != null ? ev.My_Repairs__c  : null;
        }
    }

    public class AvailabilityWrapper{
        public String id {get; set;}
        public Datetime gmtStartDateTime {get; set;}
        public Datetime localStoreStartDateTime {get; set;}
        public Datetime gmtEndDateTime {get; set;}
        public Datetime localStoreEndDateTime {get; set;}
        public String storeCode {get;set;}
        public String storeName {get;set;}
        public String recordType {get;set;}
        public String timeZone {get;set;}
        public Integer definedCapacities {get;set;}
        public Integer freeCapacities {get;set;}
        public Boolean IsRecurrence {get;set;}
        public Datetime RecurrenceStartDateTime {get;set;}
        public Date RecurrenceEndDateOnly {get;set;}
        public String RecurrenceType {get;set;}
        public Integer RecurrenceInterval {get;set;}
        public Integer RecurrenceDayofWeekMask {get;set;}
        public String RecurrenceTimeZoneSidKey {get;set;}
        public String RecurrenceActivityId {get;set;}
        public Integer DurationInMinutes {get;set;}

        public AvailabilityWrapper(Event ev, Integer currentOnlineAppointmentsCount ){
            this.id = ev.Id;
            this.gmtStartDateTime = ev.startDateTime;
            this.localStoreStartDateTime = ev.Store_Location__r != null ? getStoreLocalTime(getStoreTimezone(ev.Store_Location__r.StoreCountry__c, ev.Store_Location__r.Time_Zone_Id__c), ev.startDateTime) : null;
            this.gmtEndDateTime = ev.endDateTime;
            this.localStoreEndDateTime = ev.Store_Location__r != null ? getStoreLocalTime(getStoreTimezone(ev.Store_Location__r.StoreCountry__c, ev.Store_Location__r.Time_Zone_Id__c), ev.endDateTime) : null;
            this.storeCode =  ev.Store_Location__r != null ? ev.Store_Location__r.RetailStoreId__c : null;
            this.storeName =  ev.Store_Location__r != null ? ev.Store_Location__r.Name : null;
            this.recordType = ev.recordType.DeveloperName;
            this.timeZone =  ev.Store_Location__r != null ? getStoreTimezone(ev.Store_Location__r.StoreCountry__c, ev.Store_Location__r.Time_Zone_Id__c) : null;
            this.definedCapacities = ev.Capacity__c != null ? ev.Capacity__c.intValue() : null;
            this.freeCapacities = ev.Capacity__c != null ? ev.Capacity__c.intValue() - currentOnlineAppointmentsCount : null;
            this.IsRecurrence = ev.IsRecurrence;
            this.RecurrenceStartDateTime = ev.RecurrenceStartDateTime;
            this.RecurrenceEndDateOnly = ev.RecurrenceEndDateOnly;
            this.RecurrenceType = ev.RecurrenceType;
            this.RecurrenceInterval = ev.RecurrenceInterval;
            this.RecurrenceDayofWeekMask = ev.RecurrenceDayofWeekMask;
            this.RecurrenceTimeZoneSidKey = ev.RecurrenceTimeZoneSidKey;
            this.RecurrenceActivityId = ev.RecurrenceActivityId;
            this.DurationInMinutes = ev.DurationInMinutes;
        }
    }



    ///Newsletter Update and Callout to marketing cloud -- naomi Jan. 2023
    public static void NewsLetterMarketingEmail(String accId,String local,Boolean SubscribeToNewsletter){
        if(accId!=null && SubscribeToNewsletter==true)
        {
        
            Account acc = [SELECT Id,Local__c,Newsletter__c, PersonContactId,PersonEmail,LastName,FirstName,Salutation,PersonMobilePhone,HomeAddressCountryCode__pc FROM Account WHERE Id =: accId LIMIT 1];

            String preferredLanguageIso2 = 'EN';
            String MarketingCloudLocal = 'eng-us';
            String countryCodeIso2 = 'US';
            
            Language_Mapping_ATG_SF__mdt localPreferredLanguage;
            String sLocal = String.isNotBlank(local) ? local : acc.Local__c ;
            
            localPreferredLanguage = getLocalAndPreferredLanguage(acc.HomeAddressCountryCode__pc,null);  
            countryCodeIso2 = String.isNotBlank(localPreferredLanguage.Country_Iso2__c) ? localPreferredLanguage.Country_Iso2__c: countryCodeIso2;
            
            if(String.isNotBlank(sLocal)){
                localPreferredLanguage = getLocalAndPreferredLanguage(null,sLocal);
            } 

            if(localPreferredLanguage!=null){
                MarketingCloudLocal =  String.isNotBlank(localPreferredLanguage.ATG__c) ? localPreferredLanguage.ATG__c : MarketingCloudLocal;
                preferredLanguageIso2 = String.isNotBlank(localPreferredLanguage.Language_Iso2__c) ? localPreferredLanguage.Language_Iso2__c: preferredLanguageIso2;
            }

            ICX_WS_NewsletterSubscription.MarketingCloudFireEvent(acc.Id,acc.PersonContactId, acc.PersonEmail, acc.LastName, acc.FirstName, acc.Salutation, 'NewsLetter', countryCodeIso2,MarketingCloudLocal, preferredLanguageIso2, 'false', 'Email', acc.PersonMobilePhone, IconicsSettings__c.getInstance().Newsletter_URL__c +'/'+ local+'/mylv/registration', 'false');

        }
    }

    public static Language_Mapping_ATG_SF__mdt getLocalAndPreferredLanguage(String CountryCodeIso3, String local){
        
        Language_Mapping_ATG_SF__mdt languageLocal = new Language_Mapping_ATG_SF__mdt();
        languageLocal.Language_Iso2__c = 'eng-us'; //local
        languageLocal.Language_Iso2__c = 'EN';
        languageLocal.Language_Iso3__c = 'ENG';
        languageLocal.Country_Iso2__c ='US';
        List<Language_Mapping_ATG_SF__mdt> currentLanguageLocalList = new list<Language_Mapping_ATG_SF__mdt>();

        if(String.isNotBlank(CountryCodeIso3) && CountryCodeIso3 !='USA')  {

            currentLanguageLocalList = [SELECT ATG__c,Language_Iso2__c,Language_Iso3__c,Country_Iso2__c FROM Language_Mapping_ATG_SF__mdt WHERE Country_Iso3__c =: CountryCodeIso3];
        }
        else if(String.isNotBlank(local) && local !='eng-us')
        {
            currentLanguageLocalList = [SELECT ATG__c,Language_Iso2__c,Language_Iso3__c,Country_Iso2__c FROM Language_Mapping_ATG_SF__mdt WHERE ATG__c =: local];

        }
        
        if(!currentLanguageLocalList.isEmpty())
        {   
            for(Language_Mapping_ATG_SF__mdt currentLanguageLocal : currentLanguageLocalList){
                if(currentLanguageLocal.Language_Iso2__c != 'EN') {
                    
                    languageLocal.ATG__c = currentLanguageLocal.ATG__c;
                    languageLocal.Language_Iso2__c = currentLanguageLocal.Language_Iso2__c;
                    languageLocal.Language_Iso3__c = currentLanguageLocal.Language_Iso3__c;
                    languageLocal.Country_Iso2__c = currentLanguageLocal.Country_Iso2__c;
                    break;
                }
            }
        }
        

        return languageLocal;
    }




}