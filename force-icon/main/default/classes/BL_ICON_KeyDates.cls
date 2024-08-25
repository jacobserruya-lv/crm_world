global with sharing class BL_ICON_KeyDates extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET, BL_WS_Interfaces.DispatchablePUT, BL_WS_Interfaces.DispatchableDELETE{
    static String KeyDatesRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Key_Dates').getRecordTypeId();
    
    global Object executeGET(){
        String clientId = (getQueryParameter('clientId') != null ? getQueryParameter('clientId') : null);

        String eventId = (getPathParameter('eventId') != null ? getQueryParameter('eventId') : null);
        if (String.isNotEmpty(eventId)){
            return BL_ICON_Event_Helper.getEventById(eventId); 

        }

        Integer page = (queryParams.get('page') != null ? Integer.valueOf(queryParams.get('page')) : null);
        Integer limitValue = (queryParams.get('limit') != null ? Integer.valueOf(queryParams.get('limit')) : null);
        Date minDate =  date.today().addDays(-30);
        String conditionDate = 'ActivityDate > ' +  string.valueof(minDate);
        String condtionUserAppointment = ' (RecordTypeId =\'' + KeyDatesRecordTypeId  + '\' AND ownerId = \'' + me.basicInfos.Id + '\' ) ';
        BL_EasyQuery easyQuuery = new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                .condition( conditionDate + ' AND ' + condtionUserAppointment  )
                .orderBy('ActivityDateTime ASC')
                .pagination(page, limitValue);
                

        if(String.isNotBlank(clientId)){
            List<Map<String, Object>> res = (List<Map<String, Object>>)easyQuuery
                .addCondition(' WhatId=\''+clientId+'\' ')
                .executeQuery()
                .getMappedObjects();

                List<BL_ICON_Client_Helper.Timeline> timelines = new List<BL_ICON_Client_Helper.Timeline>();
                timelines.addAll(BL_ICON_Client_Helper.toList(res, 'Event'));
                return new BL_WS_Response(timelines);
        }

        return new BL_WS_Response(easyQuuery
        .executeQuery()
        .getSObjects());
    }

    global Object executePUT(){
        Object record = getRequestRecord();
        return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                .upsertWrappersWithChilds(new List<Object>{record}, null, null);
    }

    global Object executeDELETE(){
        String eventId = (getPathParameter('eventId') != null ? getPathParameter('eventId') : null);
        Event event = new Event(Id=eventId);
        delete event;
        return true;
    }
}