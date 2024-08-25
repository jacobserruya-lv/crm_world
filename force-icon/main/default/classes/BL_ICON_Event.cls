/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-13-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-02-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global with sharing class BL_ICON_Event  extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET, BL_WS_Interfaces.DispatchablePOST, BL_WS_Interfaces.DispatchablePATCH,BL_WS_Interfaces.DispatchablePUT, BL_WS_Interfaces.DispatchableDELETE{

    global Object executeGET(){
        List<Map<String, Object>> myTeamList = new List<Map<String, Object>>();
        String eventId = (pathParameters.get('eventId') != null ? pathParameters.get('eventId') : null);
        Integer page = (queryParams.get('page') != null ? Integer.valueOf(queryParams.get('page')) : null);
        Integer limitValue = (queryParams.get('limit') != null ? Integer.valueOf(queryParams.get('limit')) : null);
        String filters = (queryParams.get('filters') != null ? (String)queryParams.get('filters') : null);
        List<String> caIds = (queryParams.get('caIds') != null ? ((String)queryParams.get('caIds')).split(';') : new List<String>());
		Boolean myTeam = (queryParams.get('myTeam') != null && queryParams.get('myTeam') == 'true' ? true : false);
       if(myTeam){
            myTeamList = (List<Map<String, Object>>)BL_ICON_Team.getTeamMembers(true,me);
            for(Map<String, Object> teamMember : myTeamList){
                caIds.add((String) teamMember.get('id')); 
            }
        }
        if (String.isNotEmpty(eventId))
            if(resource == 'check'){
               List<String> relatedTicketsList = (queryParams.get('relatedTickets') != null ? ((String)queryParams.get('relatedTickets')).split(';') : new List<String>());
               return BL_ICON_Event_Helper.checkEventTransaction(eventId,relatedTicketsList); 
            }
        	else{
           	  return BL_ICON_Event_Helper.getEventById(eventId); 
           }
            
        else if(String.isNotEmpty(filters))
            return BL_ICON_Event_Helper.getEventsByFilter(filters, me, page, limitValue, caIds);
        else {
            return BL_ICON_Event_Helper.getAllEvents(me, page, limitValue, caIds);
        }
    }

    global Object executePATCH() { 
        List<Object> records =  new List<Object>();
        String eventId = (pathParameters.get('eventId') != null ? pathParameters.get('eventId') : null);
        String userId = (queryParams.get('userId') != null ? queryParams.get('userId') : me.basicInfos.Id);

        if(path == '/activities/events/{eventId}/assign'){
            return BL_ICON_Event_Helper.assignAppointments(userId, eventId, me.basicInfos.TECH_IsManager__c);
        }
        if(path == '/activities/events/{eventId}/attendance'){
            return BL_ICON_Event_Helper.attendanceAppointments(eventId);
        }

        if(eventId != null){
            records.add(requestBody);
            ((Map<String,Object>)records[0]).put('id', eventId);
        }
        else
            records =  getRequestRecords();

        return BL_ICON_Event_Helper.updateEvents(records); 
    }



     global Object executePUT() { 
        List<Object> records =  new List<Object>();
        String user =String.valueOf(this.requestBody.get('userId'));
        String eventId = (pathParameters.get('eventId') != null ? pathParameters.get('eventId') : null);
        String userId = queryParams.get('userId');
                  
        switch on userId {
            when  null {
                if (user != null && String.isNotEmpty(user)) {
                    userId = user ;
                }
                else  
                userId =  me.basicInfos.Id;
            }	
            when  else {
              userId = queryParams.get('userId');
            }
        } 

        if(path == '/activities/events/{eventId}/assign'){
            return BL_ICON_Event_Helper.assignAppointments(userId, eventId, me.basicInfos.TECH_IsManager__c);
        }
        if(path == '/activities/events/{eventId}/attendance'){
            return BL_ICON_Event_Helper.attendanceAppointments(eventId);
        }
        if(path == '/activities/events/{eventId}/reject'){
            return BL_ICON_Event_Helper.rejectEvent(eventId, String.valueOf(requestBody.get('rejectReason')));
        }

        if(eventId != null){
            records.add(requestBody);
            ((Map<String,Object>)records[0]).put('id', eventId);
        }
        else
            records =  getRequestRecords();

        return BL_ICON_Event_Helper.updateEvents(records); 
    }

    global Object executePOST() {
        Boolean isGolden = queryParams.get('golden') != null ? queryParams.get('golden') == 'true' ? TRUE : FALSE : FALSE;
        List<Object> managerDetails = (List<Object>)this.requestBody.get('managerDetails');
        List<Object> records = getRequestRecords();
        if(isGolden)
            return BL_ICON_Event_Helper.insertGoldenEvents(records, managerDetails);
        return BL_ICON_Event_Helper.insertEvents(records);
    }
    
    global Object executeDELETE() {
        String eventId = (pathParameters.get('eventId') != null ? pathParameters.get('eventId') : null);
        if(eventId == null){
            List<Object> records = getRequestRecords();
            return BL_ICON_Event_Helper.deleteEvents(records);
        }
        else{
            return BL_ICON_Event_Helper.deleteEvent(eventId);
        }
        
    }
}