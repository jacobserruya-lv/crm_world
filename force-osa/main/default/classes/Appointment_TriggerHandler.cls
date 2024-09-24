public  class Appointment_TriggerHandler {

    private static final String MSG_ONLINE_APPOINTMENT_CONFIRMED =       Notification_Settings__mdt.getInstance('ONLINE_APPOINTMENT_Confirmed')?.Message_Id__c; 
    private static final String MSG_ONLINE_APPOINTMENT_REMINDER  =       Notification_Settings__mdt.getInstance('ONLINE_APPOINTMENT_Reminder')?.Message_Id__c;
    private static final String MSG_ONLINE_APPOINTMENT_CANCELLED =       Notification_Settings__mdt.getInstance('ONLINE_APPOINTMENT_Cancelled')?.Message_Id__c;
    //private static final String MSG_ONLINE_APPOINTMENT_UPDATED   =       Notification_Settings__mdt.getInstance('ONLINE_APPOINTMENT_Updated')?.Message_Id__c;
    private static final String MSG_DIAMOND_APPOINTMENT_CONFIRMED =      Notification_Settings__mdt.getInstance('WECHAT_DIAMOND_APPOINTMENT_Confirmed')?.Message_Id__c;
    private static final String MSG_DIAMOND_APPOINTMENT_REMINDER =       Notification_Settings__mdt.getInstance('WECHAT_DIAMOND_APPOINTMENT_Reminder')?.Message_Id__c;
    private static final String MSG_DIAMOND_APPOINTMENT_CANCELLED =      Notification_Settings__mdt.getInstance('WECHAT_DIAMOND_APPOINTMENT_Cancelled')?.Message_Id__c;
    private static final String MSG_WECHAT_APPOINTMENT_CONFIRMED =       Notification_Settings__mdt.getInstance('WECHAT_ONLINE_APPOINTMENT_Confirmed')?.Message_Id__c;
    private static final String MSG_WECHAT_APPOINTMENT_REMINDER  =       Notification_Settings__mdt.getInstance('WECHAT_ONLINE_APPOINTMENT_Reminder')?.Message_Id__c;
    private static final String MSG_WECHAT_APPOINTMENT_CANCELLED =       Notification_Settings__mdt.getInstance('WECHAT_ONLINE_APPOINTMENT_Cancelled')?.Message_Id__c;

    private static final String ISDEFAULT = 'ISDEFAULT';

    private static Map<String, CountryLanguage__c> localSetting = new Map<String, CountryLanguage__c>();
    private static Map<String,Map<String,String>> identityURLsByName = new Map<String,Map<String,String>>();
    private static Map<Id, Store__c> storeMap = new Map<Id, Store__c>();
    private static Boolean trustOriginApp = false;
    private static boolean run = true;

    //===================================================//
    // Here go the handler methods
    public static boolean runOnce() {  // avoid the recursion https://help.salesforce.com/articleView?id=000133752

        if (run) {
            run = false;
            return true;
        } 
        else {
            return run;
        }
    }

    public static void beforeInsert(List<Event> newEventList, Map<id, Event> newEventMap) {
        Map<String, String> appointmentsRecordTypes = OnlineAppointments_Utils.getAppointmentRecordTypesId();

        for( Event e : newEventList){
            if(e.sourceType__c.contains('WECHAT') && e.RecordTypeId == appointmentsRecordTypes.get('Online_Appointment') && e.Subject != 'Wechat Appointment'){
                e.Subject = 'Wechat Appointment';
            }        
        }
    }

    public static void afterInsert(List<Event> newEventList, Map<id, Event> newEventMap) {

        Set<Id> accountIds = new Set<Id>();
        List<Event> pushNotificationWechat = new List<Event>();
        Map<Id,Id> ownerIdEvent = new Map<Id,Id>();
        Map<String, Map<Id,Event>> eventsByMessageId = new Map<String, Map<Id,Event>>{
            MSG_ONLINE_APPOINTMENT_CONFIRMED => new Map<Id,Event>(),
            MSG_DIAMOND_APPOINTMENT_CONFIRMED  =>  new Map<Id,Event>(),
            MSG_WECHAT_APPOINTMENT_CONFIRMED  =>  new Map<Id,Event>()
        };
        Map<String, String> appointmentsRecordTypes = OnlineAppointments_Utils.getAppointmentRecordTypesId();
        Notification_Permission__mdt  notificationPermission = IC_UTILS.getNotificationPermissionByApplication('ONLINE APPOINTMENT');
        storeMap = getStores(newEventList);
        Map<Id,Set<Id>> goldenEventsAddedCas = new Map<Id,Set<Id>>();

        /************** VALIDATION ***************/
        for(Event event : newEventList){

            Boolean isOnlineAppointmentRecord = event.RecordTypeId == appointmentsRecordTypes.get('Online_Appointment');
            Boolean isGoldenRecord = event.RecordTypeId == Schema.SObjectType.Event.getRecordTypeInfosByName().get('Golden')?.getRecordTypeId();
            Boolean isStatusNotAssigned = event.Status__c == 'Not Assigned';
            Boolean isStatusAssigned = event.Status__c == 'Assigned';
            Boolean isNotificationAllowed = storeMap.containskey(event.Store_Location__c) && IC_UTILS.isNotificationsAllowed(notificationPermission, storeMap.get(event.Store_Location__c).RetailStoreId__c, null, null);
            Boolean containWechatEvent = event.sourceType__c.contains('WECHAT');
            Boolean isWechatEvent = event.sourceType__c == 'WECHAT';
            Boolean isWechatDiamonEvent = event.sourceType__c == 'WECHAT_DIAMOND';
            Boolean isCAAdded = event.CA_Ids__c != null;
            
            if(isOnlineAppointmentRecord){

                accountIds.add(event.accountId);

                if(isStatusNotAssigned && containWechatEvent) {
                    pushNotificationWechat.add(event);
                }
                
                if (isNotificationAllowed){
                    if (isStatusNotAssigned){

                        if(isWechatEvent){
                            eventsByMessageId.get(MSG_WECHAT_APPOINTMENT_CONFIRMED).put(event.accountId, event);
                        }else if(isWechatDiamonEvent){
                            eventsByMessageId.get(MSG_DIAMOND_APPOINTMENT_CONFIRMED).put(event.accountId, event);
                        }else{
                            system.debug('event' + event);
                            eventsByMessageId.get(MSG_ONLINE_APPOINTMENT_CONFIRMED).put(event.accountId, event);
                        }
                    }
                }
            }
            if(isGoldenRecord && isCAAdded){
                Set<Id> addedCas = getCAsToNotif(event.CA_Ids__c,'');
                if(addedCas.size() > 0)
                    goldenEventsAddedCas.put(event.Id, addedCas);
            }
        }

        Map<Id,Account> clients = getClienMap(accountIds);
        createNotifications(clients, eventsByMessageId);

        if(goldenEventsAddedCas.size() > 0){
            sendWecomNotifs(goldenEventsAddedCas,'Golden_Appointment_CA_Added');
        }
        // if(!pushNotificationWechat.isEmpty()) { 
        //     WechatWork_Notification_Center.WCW_OSA_notification(pushNotificationWechat, clients);
        // }
    }

    public static void beforeUpdate(List<Event> newEventList, Map<id, Event> newEventMap,
        List<Event> oldEventList, Map<id, Event> oldEventMap){
        Map<String, String> appointmentsRecordTypes = OnlineAppointments_Utils.getAppointmentRecordTypesId();

        for( Event e : newEventList){
            if(e.sourceType__c.contains('WECHAT') && e.RecordTypeId == appointmentsRecordTypes.get('Online_Appointment') && e.Subject != 'Wechat Appointment'){
                e.Subject = 'Wechat Appointment';
            }
        }
    }

    public static void afterUpdate(List<Event> newEventList, Map<id, Event> oldEventMap) {

        Set<Id> accountIds = new Set<Id>();
        List<Id> careServiceIds = new List<Id>();
        Set<Id> reminderNotiftoCancel = new Set<Id>();
        List<Event> pushNotificationAppt = new List<Event>();
        List<Event> pushNotificationWechat = new List<Event>();
        Map<Id,Id> ownerIdEvent = new Map<Id,Id>();
        Map<String, Map<Id,Event>> eventsByMessageId = new Map<String, Map<Id,Event>>{
            MSG_ONLINE_APPOINTMENT_CONFIRMED => new Map<Id,Event>(),
            MSG_ONLINE_APPOINTMENT_REMINDER => new Map<Id,Event>(),
            MSG_ONLINE_APPOINTMENT_CANCELLED => new Map<Id,Event>(),
           // MSG_ONLINE_APPOINTMENT_UPDATED => new Map<Id,Event>(),
            MSG_DIAMOND_APPOINTMENT_CONFIRMED  =>  new Map<Id,Event>(),
            MSG_DIAMOND_APPOINTMENT_REMINDER   =>  new Map<Id,Event>(),
            MSG_DIAMOND_APPOINTMENT_CANCELLED =>  new Map<Id,Event>(),
            MSG_WECHAT_APPOINTMENT_CANCELLED  =>  new Map<Id,Event>(),
            MSG_WECHAT_APPOINTMENT_CONFIRMED  =>  new Map<Id,Event>(),
            MSG_WECHAT_APPOINTMENT_REMINDER  =>  new Map<Id,Event>()
        };
        Map<String, String> appointmentsRecordTypes = OnlineAppointments_Utils.getAppointmentRecordTypesId();
        storeMap = getStores(newEventList);
        Notification_Permission__mdt  notificationPermission = IC_UTILS.getNotificationPermissionByApplication('ONLINE APPOINTMENT');
        Map<String,String> notificationTypebyEventId = new Map<String,String>();
        Id goldenRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Golden')?.getRecordTypeId();
        Map<Id,Set<Id>> goldenEvents = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> goldenEventsAddedCas = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> goldenEventsRemovedCas = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> cancelledGoldenWithCAs = new Map<Id,Set<Id>>();
        for(Event event : newEventList){

            Event oldEvent = oldEventMap.get(event.Id);

            Boolean isOnlineAppointmentRecord = event.RecordTypeId == appointmentsRecordTypes.get('Online_Appointment');
            Boolean isGoldenRecord = event.RecordTypeId == goldenRecordTypeId;
            Boolean isAttendanceChanged = event?.Attendance__c !=  oldEvent?.Attendance__c;
            Boolean isStatusChanged = event.Status__c != oldEvent.Status__c ;
            Boolean isStatusCanceled = event.Status__c == 'Cancelled';
            Boolean isStatusAssigned = event.Status__c == 'Assigned';
            Boolean isOwnerChanged = event.OwnerId != oldEvent.OwnerId;
            Boolean isChangedByOther = event.OwnerId != event.LastModifiedById;
            Boolean isNotificationAllowed = storeMap.containskey(event.Store_Location__c) && IC_UTILS.isNotificationsAllowed(notificationPermission, storeMap.get(event.Store_Location__c).RetailStoreId__c, null, null);
            Boolean oldStatusIsToBeApproved = oldEvent.Status__c == 'To Be Approved';
            Boolean isStatusPending = event.Status__c == 'Pending';
            Boolean isCAIdsChanged = event.CA_Ids__c != oldEvent.CA_Ids__c;

            if(isAttendanceChanged && String.isNotEmpty(event?.My_Repairs__c)) {
                careServiceIds.add(event?.My_Repairs__c);
            }

            if(isGoldenRecord && isStatusChanged){
                if(oldStatusIsToBeApproved && (isStatusAssigned || isStatusPending))
                    goldenEvents.put(event.Id, new Set<Id>{event.OwnerId});     
                else if(isStatusCanceled)
                { 
                    Set<Id> idsToNotif =  new Set<Id> {event.manager__c};
                    if(event.CA_Ids__c != null)
                        idsToNotif.addAll(getCAsToNotif(event.CA_Ids__c,''));
                    cancelledGoldenWithCAs.put(event.id,idsToNotif);
                }
                
            }
            
            if(isGoldenRecord && isCAIdsChanged) {
                Set<Id> addedCas = getCAsToNotif(event.CA_Ids__c,oldEvent.CA_Ids__c);
                if(addedCas.size() > 0)
                    goldenEventsAddedCas.put(event.Id ,addedCas);
                Set<Id> removedCas = getCAsToNotif(oldEvent.CA_Ids__c,event.CA_Ids__c);
                if(removedCas.size() > 0)
                    goldenEventsRemovedCas.put(event.Id ,removedCas);
            }

            if(!isOnlineAppointmentRecord) continue ;

            accountIds.add(event.accountId);
            setPushNotifForIconUser(event, oldEvent, pushNotificationAppt, notificationTypebyEventId);
            setPushNotifForWechatUser(event, oldEvent, pushNotificationWechat);

            if(isChangedByOther && ((isOwnerChanged && isStatusAssigned) || isStatusChanged)) {
                ownerIdEvent.put(event.Id, event.OwnerId);
            }

            if(isNotificationAllowed && String.isNotEmpty(event.accountId)){
                if(isStatusChanged && isStatusCanceled){
                    reminderNotiftoCancel.add(event.Id);
                }
                setEventMapByNotification(event, oldEvent, eventsByMessageId);
            }
        }

        Map<Id,Account> clients = getClienMap(accountIds);
        createNotifications(clients, eventsByMessageId);
        updateReminderNotifOnCancel(reminderNotiftoCancel);

        // NOTIF: Push Notification To Owner
        if(!pushNotificationAppt.isEmpty()) {
            IM_SendPushNotifications.AppointmentSendPush(pushNotificationAppt ,notificationTypebyEventId);
        }

        if(!goldenEvents.keySet().isEmpty()){
            sendWecomNotifs(goldenEvents,'Golden_Appointment_Approve');
        }

        if(!goldenEventsAddedCas.keySet().isEmpty()){
            sendWecomNotifs(goldenEventsAddedCas,'Golden_Appointment_CA_Added');
        }
        if(!goldenEventsRemovedCas.keySet().isEmpty()){
            sendWecomNotifs(goldenEventsRemovedCas,'Golden_Appointment_CA_Removed');
        }
        if(!cancelledGoldenWithCAs.keySet().isEmpty()){
            sendWecomNotifs(cancelledGoldenWithCAs,'Golden_Appointment_Cancelled');
        }

        // if(!pushNotificationWechat.isEmpty()) { 
        //     WechatWork_Notification_Center.WCW_OSA_notification(pushNotificationWechat, clients);
        // }
        
        // NOTIF BELL FOR ASSIGNED CA   - naomi 11/04/22
        if(!ownerIdEvent.isEmpty()) {
            sendBellNotifs(ownerIdEvent);
        }

        // NI-1507 - Keman 12/04/22
        if(!careServiceIds.isEmpty()){
            UpdateCareService(careServiceIds.get(0));
        }   
    }

    private static Set<Id> getCAsToNotif(String searchfor, String searchIn){
        Set<Id> cAToNotif = new Set<Id>();
        List<String> searchforIds = !String.isEmpty(searchfor) ? searchfor.split(';') : new List<String>();
        if(searchforIds.size() > 0){
            for(String currCA:searchforIds){
                if(String.isEmpty(searchIn) || !searchIn.contains(currCA)){
                    cAToNotif.add(Id.valueOf(currCA));
                }
            }
        }
        return cAToNotif;
    }
    
    private static Set<Id> getAllUserIds(List<Set<Id>> usersSet){
        Set<Id> userIds = new Set<Id>();
        for(Set<Id> idSet : usersSet){
            userIds.addAll(idSet);
        }
        return userIds;
    }

    private static void sendWecomNotifs(Map<Id, Set<Id>> events, String mdtName){
        Wecom_Notification__mdt mdt = Wecom_Notification__mdt.getInstance(mdtName);
        Map<Id, User> userMap = new Map<Id, User> ();
        for(User user1 : [SELECT id ,WWEmployeeNumber__c, Name FROM User WHERE Id IN: getAllUserIds(events.values())] ){
            userMap.put(user1.Id , user1);
        }
        for(Event golden : [SELECT ID, Account.FirstName, Account.LastName ,OwnerId FROM Event WHERE Id IN: events.keySet() ] ){
            String redirectPath = mdt.Path__c.replace('{eventId}',golden.Id);
            for(Id usrId:events.get(golden.Id)){
                Map<String, String> params = new Map<String, String> {
                    'key'=> mdt.Param_Key__c,
                    'value'=>  mdt.Param_Value__c.replace('{caName}',userMap.get(usrId).Name)
                };
                Map<String,String> notifDetails = new Map<String,String>{
                    'mainMessageKey' =>mdt.Main_Message_Key__c,
                    'mainMessage' => golden.Account.FirstName + ' '+ golden.Account.LastName,
                    'lvMid' => userMap.get(usrId).WWEmployeeNumber__c,
                    'path' => redirectPath,
                    'title' =>  mdt.Title__c,
                    'description' => mdt.Description__c
                };
                BL_WecomUtils.sendNotif(notifDetails, params);
            }
        }
    }

    /* HELPER METHODS */
    public static void setPushNotifForWechatUser(Event event, Event oldEvent ,  List<Event> pushNotificationWechat){

        Boolean isStatusChanged = event.Status__c != oldEvent.Status__c ;
        Boolean isStatusCanceled = event.Status__c == 'Cancelled';
        Boolean isStatusAssigned = event.Status__c == 'Assigned';
        Boolean isStatusNotAssigned = event.Status__c == 'Not Assigned';
        Boolean isOwnerChanged = event.OwnerId != oldEvent.OwnerId;
        Boolean isChangedByOther = event.OwnerId != event.LastModifiedById;
        Boolean containWechatEvent = event.sourceType__c.contains('WECHAT');

        if(((isStatusNotAssigned && isStatusChanged) ||
            (isStatusChanged && isStatusCanceled) ||
            (isOwnerChanged && isChangedByOther && isStatusAssigned)) 
            && containWechatEvent) { 

            pushNotificationWechat.add(event);
        }
    }

    public static void setPushNotifForIconUser(Event event, Event oldEvent ,  List<Event> pushNotificationAppt ,Map<String,String> notificationTypebyEventId){
        Boolean isStatusChanged = event.Status__c != oldEvent.Status__c ;
        Boolean isStatusCanceled = event.Status__c == 'Cancelled';
        Boolean isStatusAssigned = event.Status__c == 'Assigned';
        Boolean isOwnerChanged = event.OwnerId != oldEvent.OwnerId;
        Boolean isChangedByOther = event.OwnerId != event.LastModifiedById;
        Boolean containWechatEvent = event.sourceType__c.contains('WECHAT');
        Boolean isAvailabilityChanged = event.availabilityId__c != oldEvent.availabilityId__c && event?.availabilityId__c != null;
        Boolean isReasonChanged = event.Reason__c != oldEvent.Reason__c && event?.Reason__c != null;
        Boolean wasStatusAssigned = oldEvent.Status__c == 'Assigned';

        if((isOwnerChanged && isChangedByOther && isStatusAssigned) && !containWechatEvent) { 
            pushNotificationAppt.add(event);
            notificationTypebyEventId.put(event.Id, 'AppointmentAssigned__c');
        }

        if(isStatusChanged && isStatusCanceled && !containWechatEvent) {
            pushNotificationAppt.add(event);
            notificationTypebyEventId.put(event.Id, 'AppointmentCancelled__c');
        }

        // if (((isAvailabilityChanged && wasStatusAssigned) || isReasonChanged) && !containWechatEvent) {

        //     String notifType = '';
        //     Event eventToPush = new Event( 
        //         Id = event.id ,
        //         OwnerId = oldEvent.OwnerId,
        //         WhatId = event.WhatId,
        //         Reason__c = event.Reason__c,
        //         ActivityDate = event.ActivityDate
        //     );

        //     notifType = isAvailabilityChanged && wasStatusAssigned ?  'AppointmentSlotChanged__c' :  'AppointmentReasonChange__c';
        //     pushNotificationAppt.add(eventToPush); 
        //     notificationTypebyEventId.put(event.Id, notifType);
        // }
    }

    public static void setEventMapByNotification(Event event, Event oldEvent , Map<String, Map<Id,Event>> eventsByMessageId){

        Boolean isStatusChanged = event.Status__c != oldEvent.Status__c ;
        Boolean isStatusCanceled = event.Status__c == 'Cancelled';
        Boolean isStatusNotAssigned = event.Status__c == 'Not Assigned';
        Boolean containWechatEvent = event.sourceType__c.contains('WECHAT');
        Boolean isWechatEvent = event.sourceType__c == 'WECHAT';
        Boolean isWechatDiamonEvent = event.sourceType__c == 'WECHAT_DIAMOND';
        Boolean isAvailabilityChanged = event.availabilityId__c != oldEvent.availabilityId__c && event?.availabilityId__c != null;
        Boolean isReasonChanged = event.reason__c != oldEvent.reason__c && event?.reason__c != null;
        Boolean wasStatusAssigned = oldEvent.Status__c == 'Assigned';
        Boolean wasStatusPending = oldEvent.Status__c == 'Pending';
       
        if(isStatusChanged && isStatusCanceled){

            if(isWechatEvent){
                eventsByMessageId.get(MSG_WECHAT_APPOINTMENT_CANCELLED).put(event.accountId, event);
            }else if(isWechatDiamonEvent){
                eventsByMessageId.get(MSG_DIAMOND_APPOINTMENT_CANCELLED).put(event.accountId, event);
            }else{
                eventsByMessageId.get(MSG_ONLINE_APPOINTMENT_CANCELLED).put(event.accountId , event);
            }

        } else if (isStatusNotAssigned && wasStatusPending){

            if(isWechatEvent){
                eventsByMessageId.get(MSG_WECHAT_APPOINTMENT_CONFIRMED).put(event.accountId, event);
                eventsByMessageId.get(MSG_WECHAT_APPOINTMENT_REMINDER).put(event.accountId, event);
            }else if(isWechatDiamonEvent){
                eventsByMessageId.get(MSG_DIAMOND_APPOINTMENT_CONFIRMED).put(event.accountId, event);
                eventsByMessageId.get(MSG_DIAMOND_APPOINTMENT_REMINDER).put(event.accountId, event);
            }else{
                eventsByMessageId.get(MSG_ONLINE_APPOINTMENT_CONFIRMED).put(event.accountId, event);
                eventsByMessageId.get(MSG_ONLINE_APPOINTMENT_REMINDER).put(event.accountId, event);
            }
        } 
        /*
        else if ((isAvailabilityChanged && wasStatusAssigned) || isReasonChanged){
            
            if(!containWechatEvent){
                eventsByMessageId.get(MSG_ONLINE_APPOINTMENT_UPDATED).put(event.accountId, event);
            }
        }*/
    }
    
    public static void createNotifications(Map<Id,Account> clients, Map<String, Map<Id,Event>> events) {

        Map<String,Notification_Settings__mdt> settingNotifs = getListNotificationsSettingByMessageId(new List<String>{'WECHAT ONLINE APPOINTMENT','WECHAT DIAMOND APPOINTMENT','ONLINE APPOINTMENT' });
        localSetting = getLocaleSettings();
        trustOriginApp = IDENTITY_Utils.isTrustOriginApp('Online Appointment');
        identityURLsByName = getSuccessUrlForMyLVURLByName(new List<String>{'Louis Vuitton Secure Domain',
                                                                            'ONLINE_APPOINTMENT',
                                                                            'ONLINE_APPOINTMENT_CANCELLED',
                                                                            'Repairs Registration URL',
                                                                            'OSA Login-Less Cancel URL' ,
                                                                            'Louis Vuitton Domain'}
                                                          );
        
        List<Map<String,Object>> notificationsToSend = new List<Map<String,Object>>();
        Map<String,Object> notificaton = new Map<String,Object>();
        try { 
        
            system.debug('events.keySet() ' +  events.keySet());

            for(String messageId : events.keySet()){
                Map<String, Map<String,Object>> params = new Map<String,Map<String,Object>>();
                Map<Id,Event> eventsByClient = events.get(messageId) ;
              
                if(!eventsByClient.keySet().isEmpty() && settingNotifs.containsKey(messageId)){

                    params = getParams(messageId, clients, eventsByClient);
                    notificaton = new Map<String,Object>{
                        'params'  => params,
                        'clientIds' => eventsByClient.keySet(),
                        'setting'   => settingNotifs.get(messageId)
                    };
                    
                    notificationsToSend.add(notificaton);
                }
            }
            if(!notificationsToSend.isEmpty()) { 
                Notification_Sender.sendNotifications(notificationsToSend);
            }
        }  catch(Exception ex){
            System.debug(ex.getMessage() + ex.getLineNumber()) ;
        }
    }

    public static Map<String, Map<String,Object>> getParams(String messageId, Map<Id,Account> clients, Map<Id,Event> events) {

        Map<String, Map<String,Object>> params = new Map<String,Map<String,Object>>();
        Map<String,Object> settingParams =  new Map<String,Object>();
        //Enum 
        Map<String,String > customEnum = new Map<String,String>{
            MSG_ONLINE_APPOINTMENT_CONFIRMED  =>  'MSG_ONLINE_APPOINTMENT_CONFIRMED' ,
            MSG_ONLINE_APPOINTMENT_REMINDER   =>  'MSG_ONLINE_APPOINTMENT_REMINDER'  ,
            MSG_ONLINE_APPOINTMENT_CANCELLED  =>  'MSG_ONLINE_APPOINTMENT_CANCELLED' ,
           // MSG_ONLINE_APPOINTMENT_UPDATED    =>  'MSG_ONLINE_APPOINTMENT_UPDATED'   ,
            MSG_DIAMOND_APPOINTMENT_CONFIRMED =>  'MSG_DIAMOND_APPOINTMENT_CONFIRMED',
            MSG_DIAMOND_APPOINTMENT_REMINDER  =>  'MSG_DIAMOND_APPOINTMENT_REMINDER' ,
            MSG_DIAMOND_APPOINTMENT_CANCELLED =>  'MSG_DIAMOND_APPOINTMENT_CANCELLED',
            MSG_WECHAT_APPOINTMENT_CANCELLED  =>  'MSG_WECHAT_APPOINTMENT_CANCELLED' ,
            MSG_WECHAT_APPOINTMENT_CONFIRMED  =>  'MSG_WECHAT_APPOINTMENT_CONFIRMED' ,
            MSG_WECHAT_APPOINTMENT_REMINDER   =>  'MSG_WECHAT_APPOINTMENT_REMINDER'  
        };

        switch on customEnum.get(messageId) {
             
            when 'MSG_ONLINE_APPOINTMENT_CONFIRMED' {
                settingParams =  new Map<String,Object> { 
                    'CampaignId' => 'e_storeAppointmentConfirmation_mng', 
                    'successURLKey' => 'ONLINE_APPOINTMENT',
                    'isRealTime' => true
                };
                params = getDynamicParams(clients, events, settingParams);
            }
            when 'MSG_ONLINE_APPOINTMENT_REMINDER' {
                settingParams =  new Map<String,Object> { 
                    'CampaignId' => 'e_storeAppointmentReminder_mng', 
                    'successURLKey' => 'ONLINE_APPOINTMENT',
                    'isRealTime' => false,
                    'reminderMinutes' => -24*60
                };
                params = getDynamicParams(clients, events, settingParams);
            }
            when 'MSG_ONLINE_APPOINTMENT_CANCELLED' {
                settingParams =  new Map<String,Object> { 
                    'CampaignId' => 'e_storeAppointmentCancel_mng', 
                    'successURLKey' => 'ONLINE_APPOINTMENT_CANCELLED',
                    'isRealTime' => true
                };
                params = getDynamicParams(clients, events, settingParams);
            }
            // when 'MSG_ONLINE_APPOINTMENT_UPDATED' {
            //     settingParams =  new Map<String,Object> { 
            //         'CampaignId' => 'e_storeAppointmentUpdate_mng', 
            //         'successURLKey' => 'ONLINE_APPOINTMENT',
            //         'isRealTime' => true
            //     };
            //     params = getDynamicParams(clients, events, settingParams);
            // }
            when 'MSG_DIAMOND_APPOINTMENT_CANCELLED' {
               params = getWechat_diamond_DynamicParams(clients, events, new Map<String,Object> { 'CampaignId' => 'e_storeAppointmentCancel_mng'}, storeMap, true, null, true);
            }
            when 'MSG_DIAMOND_APPOINTMENT_CONFIRMED' {
                params = getWechat_diamond_DynamicParams(clients, events, new Map<String,Object> { 'CampaignId' => 'e_storeAppointmentConfirmation_mng', 'CancelCampaignId' => 'e_storeAppointmentConfirmation_cancel'}, storeMap, true, null, false);
            }
            when 'MSG_DIAMOND_APPOINTMENT_REMINDER' {
                params = getWechatDynamicParams(clients, events, new Map<String,Object> { 'CampaignId' => 'e_storeAppointmentReminder_mng', 'CancelCampaignId' => 'e_storeAppointmentReminder_cancel'}, storeMap, false, -24*60, false) ;
            }
            when 'MSG_WECHAT_APPOINTMENT_CANCELLED' {
                params = getWechatDynamicParams(clients, events, new Map<String,Object> { 'CampaignId' => 'e_storeAppointmentCancel_mng'}, storeMap, true, null, true);
            }
            when 'MSG_WECHAT_APPOINTMENT_CONFIRMED' {
                params = getWechatDynamicParams(clients, events, new Map<String,Object> { 'CampaignId' => 'e_storeAppointmentConfirmation_mng', 'CancelCampaignId' => 'e_storeAppointmentConfirmation_cancel'}, storeMap, true, null, false);
            }
            when 'MSG_WECHAT_APPOINTMENT_REMINDER' {
                params= getWechatDynamicParams(clients, events, new Map<String,Object> { 'CampaignId' => 'e_storeAppointmentReminder_mng', 'CancelCampaignId' => 'e_storeAppointmentReminder_cancel'}, storeMap, false, -24*60, false) ;
            }
        }   

        return params;
    }
  
    public static Map<String, Map<String,Object>> getDynamicParams(map<Id, Account> clients, Map<Id,Event> eventByClientId, Map<String, Object> others) {
        
        Map<String, Map<String,Object>> params = new Map<String,Map<String,Object>>();
        Map<String,Object> lvUrlParams = new Map<String,Object> { 
            'application' => 'Online Appointment', 
            'CampaignId' => others.get('CampaignId'),
            'istrustOriginApp' => trustOriginApp
        };

        Map<String, String> paths = identityURLsByName.get('Repairs Registration URL');
        Map<String, String> domains =  identityURLsByName.get('Louis Vuitton Secure Domain');

        String succesUrlKey = (String) others.get('successURLKey');
        Map<String, String> successURL =  identityURLsByName.get(succesUrlKey);


        for(Id clientId : eventByClientId.keySet()) {
            Map<String,Object> clientParams = new Map<String,Object>();
            
            Account client = clients.get(clientId);
            Event apt = eventByClientId.get(clientId);
            String storeId = apt.Store_Location__c;
            Store__c currentStore = storeMap.get(storeId);

            CountryLanguage__c countryLocaleSettings = localSetting.get(currentStore.StoreCountry__c);
            
            String countryLvComLocale = countryLocaleSettings != null ? countryLocaleSettings.ATG_Locale__c : 'eng-e1';
            String dispatchCountrySettings = countryLocaleSettings?.Dispatch_Country__c ;
            
            String ecommerce = String.isNotBlank(apt.Locale__c) ? apt.Locale__c : countryLvComLocale;
            String dispatchCountry = String.isNotBlank(apt.Dispatch_Country__c) ? apt.Dispatch_Country__c : dispatchCountrySettings;
            String domain = domains.get(ecommerce) != null ? domains.get(ecommerce) : domains.get('ISDEFAULT');


            paths = addDispatchCountryToPaths(dispatchCountry, paths);

            String pageName =  countryLocaleSettings != null ? countryLocaleSettings?.Page_Name__c  : 'appointments'; // get dedicated path according to the local

            String appointmentUrl = string.format('{0}/{1}/mylv/{2}', new string[]{domain, ecommerce , pageName});
            appointmentUrl += dispatchCountry != null ? '?dispatchCountry='+dispatchCountry : '';
            
            String utmCampaign = ((String)others.get('CampaignId')).substringBetween('e_','_mng'); 
            String analyticParams = '&utm_source=newsletter&utm_medium=email&utm_campaign=' + utmCampaign + '&utm_content=mng' +
                                    dispatchCountry != null ? '&dispatchCountry=' + dispatchCountry : '';
             
           
            
            // LOGIN-LESS CANCEL URL ON LV.com
            if(succesUrlKey == 'ONLINE_APPOINTMENT') {
                String analyticParamsCancel = '&utm_source=newsletter&utm_medium=email&utm_campaign=' + utmCampaign + '&utm_content=cancel';
                String cancelUrl = getLoginLessCancelAppointmentURL( new Map<String, String> {
                   'origin' => 'mylv', 
                   'ecommerce' => ecommerce,
                   'appointmentID' => apt.Id,
                   'accountID' => client.Id,
                   'dispatchCountry' => dispatchCountry
                })+ analyticParamsCancel;
                clientParams.put('cancel_url_osa', cancelUrl);
            }                

            String localeName = currentStore != null && String.isNotBlank(currentStore.Local_Name__c) ? currentStore.Local_Name__c : '';
            String techAddress = currentStore != null && String.isNotBlank(currentStore.tech_address__c) ? currentStore.tech_address__c : '';
            String fullSearch = localeName + ' ' + techAddress;

            clientParams.put('store_url_direction', 'https://www.google.com/maps/search/?api=1&query=' + EncodingUtil.urlEncode(fullSearch, 'UTF-8' ));
            clientParams.put('what_id', apt.Id);
            clientParams.put('account_id', apt.WhatId);
            clientParams.put('contact_id', client.PersonContactId);
            clientParams.put('dream_id', client.DreamID__c);
            clientParams.put('email', client.PersonEmail);
            clientParams.put('Civility', client.Salutation);
            clientParams.put('LastName', client.LastName);
            clientParams.put('local', ecommerce);
            clientParams.put('date_osa_gmt',apt.StartDateTime);
            clientParams.put('wechat_openId', apt.wechat_openId__c);
            clientParams.put('source_type', apt.sourceType__c);
            clientParams.put('update_url_osa',appointmentUrl);

            if (currentStore != null) {
                clientParams.put('local_name', currentStore.Local_Name__c);
                clientParams.put('store_address', currentStore.Address__c);
                clientParams.put('tech_address__c', currentStore.tech_address__c);

                if (String.isNotEmpty(currentStore.Time_Zone_Id__c)) {
                    Datetime storeLocalTme = OnlineAppointments_Utils.getStoreLocalTime(currentStore.Time_Zone_Id__c, apt.StartDateTime);
                    clientParams.put('date_osa', storeLocalTme);
                    clientParams.put('date_osa_formatted', storeLocalTme.format('yyyy-MM-dd HH:mm','GMT'));
                } 
            }

            if (dispatchCountry != null) {
                clientParams.put('dispatchCountry', dispatchCountry);
            }

            Boolean isRealTime = (Boolean) others.get('isRealTime');
            if (isRealTime) {
                clientParams.put('is_real_time', isRealTime);
            }

            Integer reminderMinutes = (Integer) others.get('reminderMinutes');
            if (reminderMinutes != null) {
                clientParams.put('relay_datetime', apt.StartDateTime.addMinutes(reminderMinutes));
            }

            String aptType = apt.appointmentType__c != null ? apt.appointmentType__c : 'inStore';
            clientParams.put('appointmentType', aptType);

            String url = getMyLVURL(client, 'mylv', ecommerce, paths, successURL, lvUrlParams)
            .replace('{OnlineAptId}', apt.Id)
            .replace('{DOMAIN}', domain) + analyticParams;

            clientParams.put('mylv_url', url);

            params.put(clientId, clientParams);


        }
    
        return params;
    }

    public static Map<String, Map<String,Object>> getWechatDynamicParams(map<Id, Account> clients, Map<Id,Event> clientIds, Map<String, Object> others,  Map<Id,Store__c> stores, Boolean isRealTime, Integer reminderMinutes, Boolean cancelled_notif){
        Map<String, Map<String,Object>> params = new Map<String,Map<String,Object>>();

       // CREATE PARAMS
        for(Id clientId : clientIds.keySet()){
            Event apt = clientIds.get(clientId);
            Account client = clients.get(clientId);
            String storeId = apt.Store_Location__c;
            Store__c currentStore = stores.get(storeId);

            Map<String, Object> data = new Map<String, Object> {
            'date1' => new Map<String, Object> {'value' => OnlineAppointments_Utils.getStoreLocalTime(currentStore.Time_Zone_Id__c, apt.StartDateTime).format('yyyy-MM-dd HH:mm','GMT')},
            'thing13' => new Map<String, Object> {'value' => currentStore.Local_Name__c.abbreviate(19)},
            'thing14' => new Map<String, Object> {'value' => '感谢您的预约，路易威登期待您的莅临。'},
            'thing10' => new Map<String, Object> {'value' => (String.isBlank(apt.appointmentType__c) || apt.appointmentType__c == 'inStore'  ? '到店服务预约' : '远程服务预约')},
            'thing9' => new Map<String, Object> {'value' => '点击查看您的预约详情或更改您的预约'},
            'wechat_openId' => apt.wechat_openId__c,
            'what_id' => apt.Id
            };

            if( cancelled_notif ){
                data = new Map<String, Object> {
                    // 'time1' => new Map<String, Object> {'value' => OnlineAppointments_Utils.getStoreLocalTime(currentStore.Time_Zone_Id__c, apt.StartDateTime).format('yyyy-MM-dd HH:mm','GMT')},
                    'thing11' => new Map<String, Object> {'value' => currentStore.Local_Name__c.abbreviate(19)},
                    'thing8' => new Map<String, Object> {'value' => (String.isBlank(apt.appointmentType__c) || apt.appointmentType__c == 'inStore'  ? '到店服务预约' : '远程服务预约')},
                    'thing2' => new Map<String, Object> {'value' => '如您想重新预约到店，点击即刻开启'},
                    'thing12' => new Map<String, Object> {'value' => '根据您的请求，已取消您的到店预约。'},
                    'time13' => new Map<String, Object> {'value' => OnlineAppointments_Utils.getStoreLocalTime(currentStore.Time_Zone_Id__c, apt.StartDateTime).format('yyyy-MM-dd HH:mm','GMT')},
                    'wechat_openId' => apt.wechat_openId__c,
                    'what_id' => apt.Id
                };
            }
            
            if(isRealTime){
                data.put('is_real_time', isRealTime);
            }

            // RELAY TIME
            if(reminderMinutes != null){
                data = new Map<String, Object> {
                    'thing2' => new Map<String, Object> {'value' => (String.isBlank(apt.appointmentType__c) || apt.appointmentType__c == 'inStore'  ? '到店服务预约' : '远程服务预约')},
                    'time3' => new Map<String, Object> {'value' => OnlineAppointments_Utils.getStoreLocalTime(currentStore.Time_Zone_Id__c, apt.StartDateTime).format('yyyy-MM-dd HH:mm','GMT')},
                    'thing10' => new Map<String, Object> {'value' => currentStore.Local_Name__c.abbreviate(19)},
                    'thing4' => new Map<String, Object> {'value' => '点击查看您的预约详情或更改您的预约'},
                    'wechat_openId' => apt.wechat_openId__c,
                    'what_id' => apt.Id
                };
                data.put('relay_datetime', apt.StartDateTime.addMinutes(reminderMinutes));
            }
            data.put('source_type', apt.sourceType__c);

            params.put(clientId, data);
        }
        return params;
    }

    public static Map<String, Map<String,Object>> getWechat_Diamond_DynamicParams(map<Id, Account> clients, Map<Id,Event> client_ids, Map<String, Object> others,  Map<Id,Store__c> stores, Boolean isRealTime, Integer reminderMinutes, Boolean cancelled_notif){
        Map<String, Map<String,Object>> params = new Map<String,Map<String,Object>>();

       // CREATE PARAMS
        for(Id client_id : client_ids.keySet()){
            Event apt = client_ids.get(client_id);
            Account client = clients.get(client_id);
            String storeId = apt.Store_Location__c;
            Store__c currentStore = stores.get(storeId);

            Map<String, Object> data = new Map<String, Object> {
            'date1' => new Map<String, Object> {'value' => OnlineAppointments_Utils.getStoreLocalTime(currentStore.Time_Zone_Id__c, apt.StartDateTime).format('yyyy-MM-dd HH:mm','GMT')},
            'thing13' => new Map<String, Object> {'value' => currentStore.Local_Name__c.abbreviate(19)},
            'thing14' => new Map<String, Object> {'value' => '感谢您的预约，路易威登期待您的莅临。'},
            'thing10' => new Map<String, Object> {'value' => 'LV Diamonds到店服务预约'},
            'thing9' => new Map<String, Object> {'value' => '点击查看您的预约详情或更改您的预约'},
            'wechat_openId' => apt.wechat_openId__c,
            'what_id' => apt.Id
        };

        if( cancelled_notif ){
            data = new Map<String, Object> {
                'thing3' => new Map<String, Object> {'value' => currentStore.Local_Name__c.abbreviate(19)},
                'thing1' => new Map<String, Object> {'value' => 'LV Diamonds到店服务预约'},
                'thing5' => new Map<String, Object> {'value' => '根据您的请求，已取消您的到店预约。'},
                'time6' => new Map<String, Object> {'value' => OnlineAppointments_Utils.getStoreLocalTime(currentStore.Time_Zone_Id__c, apt.StartDateTime).format('yyyy-MM-dd HH:mm','GMT')},
                'wechat_openId' => apt.wechat_openId__c,
                'what_id' => apt.Id
            };
        }
        
        if(isRealTime){
            data.put('is_real_time', isRealTime);
        }

        // RELAY TIME
        if(reminderMinutes != null){
            data = new Map<String, Object> {
                'thing1' => new Map<String, Object> {'value' => 'LV Diamonds到店服务预约'},
                'time7' => new Map<String, Object> {'value' => OnlineAppointments_Utils.getStoreLocalTime(currentStore.Time_Zone_Id__c, apt.StartDateTime).format('yyyy-MM-dd HH:mm','GMT')},
                'thing6' => new Map<String, Object> {'value' => currentStore.Local_Name__c.abbreviate(19)},
                'thing5' => new Map<String, Object> {'value' => '点击查看您的预约详情或更改您的预约'},
                'wechat_openId' => apt.wechat_openId__c,
                'what_id' => apt.Id
            };
            data.put('relay_datetime', apt.StartDateTime.addMinutes(reminderMinutes));
        }
        data.put('source_type', apt.sourceType__c);
        params.put(client_id, data);

       }
        return params;
    }

    public static void updateReminderNotifOnCancel(Set<Id> eventIds){
        if(!eventIds.isEmpty()){
            List<Notification__c> notifs = [SELECT Id, Status__c FROM Notification__c WHERE Status__c IN ('CREATED', 'READY TO SEND') AND WhatId__c IN :eventIds AND Real_Time__c = FALSE];
            for(Notification__c notif : notifs){
                notif.Status__c = 'CANCELLED';
            }
            update notifs;
        }
    }

    public static String getMyLVURL(Account client, String origin, String ecommerce, Map<String,String> paths, Map<String,String> successUrls, Map<String, Object> others){

        String url = paths.get(ecommerce) != null ? paths.get(ecommerce) : paths.get(ISDEFAULT);
        Boolean isTrustOrigin = others.containsKey('istrustOriginApp') ? (Boolean) others.get('istrustOriginApp') : false;
            
        url = url.replace('lang-country', ecommerce);
        url = String.isNotEmpty(origin) ? url.replace('origin', origin) : url.replace('origin', 'mylv');
        url = url.replace('AccountId', !test.isRunningTest() ? IDENTITY_UTILS.getEncryptedIdWithTrustOrigin(client.Id, isTrustOrigin): 'token');
        url = url.replace('DreamId', (client.DreamID__c != null ? client.DreamID__c : ''));

        if(others != null && !others.isEmpty() && others.get('CampaignId') != null) {
            url = url.replace('CampaignId', String.valueOf(others.get('CampaignId')));
        }
        else {
            url = url.remove('campaign=CampaignId');
        }        
        if(successUrls != null){
            String successUrl = successUrls.get(ecommerce) != null ? successUrls.get(ecommerce) : successUrls.get(ISDEFAULT);
            successUrl = successUrl.replace('lang-country', ecommerce);
            successUrl = String.isNotEmpty(origin) ? successUrl.replace('origin', origin) : successUrl.replace('origin', 'mylv');
            url = url.replace('success_url', successUrl);
        }
        else {
            url = url.remove('&successUrl=success_url');
        }
        return url;
	}

    public static String getLoginLessCancelAppointmentURL(Map<String,String> parameters){
        
        String basic_path = identityURLsByName.get('OSA Login-Less Cancel URL').get(ISDEFAULT);
        String queryEcommerce =  parameters?.get('ecommerce') == 'eng-e1' ? ISDEFAULT: parameters?.get('ecommerce');
    
        //String domain = identityURLsByName.get('Louis Vuitton Domain').get(queryEcommerce);
        String domain = identityURLsByName.get('Louis Vuitton Domain').containsKey(queryEcommerce) ? identityURLsByName.get('Louis Vuitton Domain').get(queryEcommerce) : identityURLsByName.get('Louis Vuitton Domain').get(ISDEFAULT);

      
        String url;
        url = domain + basic_path;
        url = url.replace('lang-country',  parameters?.get('ecommerce'));
        url = url.replace('origin',  parameters?.get('origin'));
        
        String token = !test.isRunningTest() ? IDENTITY_Utils.getEncryptedId(parameters?.get('accountID')+'|'+parameters?.get('appointmentID')) : 'token';
                
        url = url+'?token=' + token;
        url += parameters?.get('dispatchCountry') != null ? '&dispatchCountry=' + parameters?.get('dispatchCountry') : '';
    
        return url;

    }

    public static Map<String, CountryLanguage__c> getLocaleSettings() {

        List<CountryLanguage__c> localeSettings =  [ SELECT Country__r.Case__c	,Country__r.name, ATG_Locale__c, Dispatch_Country__c ,Salesforce_Locale__c ,Page_Name__c
                                                      FROM CountryLanguage__c  
                                                      WHERE Default__c = TRUE AND ATG_Locale__c != NULL AND ATG_Locale__c != 'eng-e1'];

        Map<String, CountryLanguage__c> localByDeveloperName = new Map<String, CountryLanguage__c>();

        for(CountryLanguage__c local : localeSettings) {
            localByDeveloperName.put(local.Country__r.Case__c, local);
        }

        return localByDeveloperName;
    }

    public static Map<String,Notification_Settings__mdt> getListNotificationsSettingByMessageId(List<String> applications) {

        Map<String,Notification_Settings__mdt> mapSetting = new Map<String,Notification_Settings__mdt>();
        List<Notification_Settings__mdt> notificationSettings = [   SELECT Id, Message_Id__c, Channel__c, Application__c, Scenario__c
                                                                    FROM Notification_Settings__mdt 
                                                                    WHERE Is_Active__c = TRUE AND Application__c IN: applications];

        for(Notification_Settings__mdt notificationSetting : notificationSettings){

            mapSetting.put(notificationSetting.Message_Id__c, notificationSetting );
        } 
        return mapSetting;                             
    }
    
    public static Map<Id,Account> getClienMap(Set<Id> clientIds) {

        return new Map<ID, Account>([SELECT Id, SPO_Country_code__pc, DreamID__c, Date_Identity__pc, PreferredLanguage__pc, PersonEmail, 
                                            LastName, Salutation, Store__pr.Local_Name__c, Store__pr.tech_address__c, FirstName, PersonContactId 
                                            FROM Account 
                                            WHERE Id IN: clientIds]);
    }

    private static Set<String> getStoreIds(List<Event> events){
        Set<String> storeIds = new Set<String>();
        for(Event ev : events){
            if(!String.isEmpty(ev.Store_Location__c)){
                storeIds.add(ev.Store_Location__c);
            }
        }
        return storeIds;
    }

    private static Map<Id,Store__c> getStores(List<Event> events){
        Set<String> storeIds = getStoreIds(events);
        return new Map<Id,Store__c>([SELECT Id, Name, Store_CountryCode__c, Address__c, Time_Zone_Id__c, StoreLocation__Latitude__s, 
                                        StoreLocation__Longitude__s, Local_Name__c, tech_address__c, 
                                        RetailStoreId__c, StoreCountry__c  
                                    FROM Store__c 
                                    WHERE Id IN :storeIds]);
    }

    public static Map<String,Map<String,String>> getSuccessUrlForMyLVURLByName(List<String> names){

        Map<String,Map<String,String>> paths = new Map<String,Map<String,String>>();

        for(IDENTITY_Paths__mdt path : [SELECT Name__c, Value__c, Context__c, Application__c 
                                        FROM IDENTITY_Paths__mdt 
                                        WHERE Name__c IN: names
                                        ORDER BY Context__c ASC NULLS FIRST]){

            if(!paths.containsKey(path.Name__c)) {
                paths.put(path.Name__c, new Map<String,String>());
            }                              

            Boolean isContainLvPass = path.Value__c.containsIgnoreCase('lvpass') ||path.Value__c.containsIgnoreCase('lvconnect')  ;
            Boolean isLvsecureDomainName = path.Name__c == 'Louis Vuitton Secure Domain';
            Boolean hasNoContext = String.isEmpty(path.Context__c);

            if((!isContainLvPass && isLvsecureDomainName) || !isLvsecureDomainName) {
                String key = hasNoContext ? ISDEFAULT : path.Context__c;
                paths.get(path.Name__c).put(key, path.Value__c);
            }
        }
        return paths;
    }

    public static Map<String,String> addDispatchCountryToPaths(String dispatchCountry, Map<String, String> paths){
        if(String.isNotBlank(dispatchCountry) ) {
            for(String k : paths.keySet()) {
                String url = paths.get(k);
                url = url.replace('successUrl=success_url','dispatchCountry='+dispatchCountry+'&successUrl=success_url');
                paths.put(k, url);    
            }
        }
        return paths;
    }

    // NOTIF BELL FOR ASSIGNED CA   - naomi 11/04/22
    public static void sendBellNotifs(Map<Id,Id> ownerIdEvent) {
        
        customNotificationType notificationType = [ SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_for_OSA'];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        for(id eventId : ownerIdEvent.keySet()){

            notification.setTitle('New Online Appointment Assigned to you');
            notification.setBody('The user ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() +' assigned to you this Online Appointment ' + eventId + '.');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(eventId);

            Set<String> recepientIds = new Set<String>();
            recepientIds.add(ownerIdEvent.get(eventId));
            try {
                notification.send(recepientIds);
            } catch (Exception e) {
                System.debug('Failed to send CA notif');
                System.debug(e);
            }
        }
    }

    // NI-1507 - Keman 12/04/22 Update Attendace_filled__c on CareService if all related Events in progress have Attendance__c filled
    @future
    public static void UpdateCareService(Id careId){
        Boolean allAttendanceFilled = false;
        List<Event> lstEvents = [select id from Event where Attendance__c = null and status__c != 'Cancelled' and My_Repairs__c =:careId]; 
        if(lstEvents.size() == 0 )
            allAttendanceFilled = true;
        List<CareService__c> care  = [select id,Attendace_filled__c from CareService__c where id=:careId];
        if(care.size() > 0){
            care[0].Attendace_filled__c = allAttendanceFilled;
            Update care[0];
        }
    }
}