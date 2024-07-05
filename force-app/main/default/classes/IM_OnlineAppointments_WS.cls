/*
CreatedDate: June 2019
Company: Balink
Author: Jeremy Martiano
Description: Interface Web Sevice to Save ONLINE Appointments And Get ONLINE Appointments/ SLOTS
*/

@RestResource(urlMapping='/IM_OnlineAppointment/*')
global without sharing class IM_OnlineAppointments_WS {
    /*=================================================================================================================*/
    //HTTP Request POST called 

    @HttpPost
    global static void post() {
        RestRequest req = RestContext.request;
        system.debug(req.requestURI);
        String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
       
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 200;
        string response;

        Map<String,Object> body = new Map<String,Object>();
        if (req.requestBody != null) {
            body = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
        }

        try{
            if(req.requestURI == '/OnlineAppointment' || req.requestURI == '/OnlineAppointment/'){
                response = JSON.serialize(OnlineAppointments_Utils.upsertOnlineAppointment(body),true);
            } else if(service == 'Cancel'){
                String onlineAppointmentId = (String) body.get('onlineAppointmentId');
                String accountId = (String) body.get('accountId');
                response = JSON.serialize(OnlineAppointments_Utils.cancelOnlineAppointmnent(onlineAppointmentId, accountId));
            } else if( service == 'Assign'){
                String onlineAppointmentId = (String) body.get('eventId');
                String userId = (String) body.get('userId');
                Boolean reassignFromManager = (body.get('isReassign') != null? Boolean.valueOf(body.get('isReassign'))  : false);
                response = JSON.serialize(OnlineAppointments_Utils.assignAppointments(userId, onlineAppointmentId, reassignFromManager),true);
            }
            res.responseBody = Blob.valueOf(response);
            //UtilsLogs.addLog('ICON','WS_OnlineAppointments', JSON.serialize(body), JSON.serialize(req), response, '');
            // new Logs.DEBUG('WS_OnlineAppointments','API',response);
        }
        catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
            OnlineAppointments_Utils.ResponseHandler errorObject = new  OnlineAppointments_Utils.ResponseHandler(null,null,null, null);
            if(ex.getTypeName() == 'DmlException' ){
                errorObject = new OnlineAppointments_Utils.ResponseHandler(ex.getDmlType(0), ex.getMessage() + ' Line:' + ex.getLineNumber(), ex.getDmlFieldNames(0), 'DML_EXCEPTION');
            }  else  if(ex.getMessage() == 'APT_ID_NOT_EXIST'){
                    errorObject = new OnlineAppointments_Utils.ResponseHandler(null, 'The appointment is not existing' , null, 'APT_ID_NOT_EXIST');
            } else {
                errorObject = new OnlineAppointments_Utils.ResponseHandler(null, ex.getMessage() + ' Line:' + ex.getLineNumber(), null, 'GENERIC_ERROR');
            }
            
            res.responseBody = Blob.valueOf(JSON.serialize(errorObject,true));
            res.statusCode = 400;
            // new Logs.ERROR('WRDB_WS_Look','API',ex);
        }
    }
    
    /*=================================================================================================================*/
    //HTTP Request GET called From getting Appointment by Id or all Appointments of a user identity  or For Store.....
    @HttpGet
    global static void get() {
        RestRequest req = RestContext.request;
        String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
                system.debug(req.requestURI);

        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 200;
        
        string response;
        try{
            if(req.requestURI == '/OnlineAppointment' || req.requestURI == '/OnlineAppointment/'){
                response = JSON.serialize(OnlineAppointments_Utils.getClientAppointments(req.params, true),true);
            } else if( service == 'Availability'){
                String storeIds = req.params.get('storeIds');
                String datesString = req.params.get('dates');
                String startDate = req.params.get('startDate');
                String endDate = req.params.get('endDate');
                response = JSON.serialize(OnlineAppointments_Utils.getAvailabilities(storeIds, datesString, startDate, endDate),true);
            } else if( service == 'AvailableUsers' ){
                String onlineAppointmentId = (String) req.params.get('eventId');
                Boolean checkAnyway = (req.params.get('checkAnyway') != null? Boolean.valueOf(req.params.get('checkAnyway')) : false);
                response = JSON.serialize(OnlineAppointments_Utils.getAvailableUsers(onlineAppointmentId, checkAnyway),true);
            } else if( service == 'OnlineAndTeamAppointments'){
                Boolean onlyOnline = (req.params.get('onlyOnline') != null ? Boolean.valueOf(req.params.get('onlyOnline')) : false);
                Boolean onlyUnassigned = (req.params.get('onlyUnassigned') != null? Boolean.valueOf(req.params.get('onlyUnassigned')) :false);
                System.debug('BBBBBBBBB ' + onlyUnassigned);
                String datesString = req.params.get('dates');
                System.debug('onlyOnline ' + onlyOnline);
                DateTime today = Datetime.now();
                String startDate = req.params.get('startDate') != null  ?req.params.get('startDate') : today.addDays(-7).format('YYYY-MM-dd');
                System.debug('HHHHHHHHHH req.params.get '+ req.params.get('startDate'));
                System.debug('GGGGGGGGGG startDate: '+ startDate);
                String endDate = req.params.get('endDate') != null  ?req.params.get('endDate') : today.addDays(20).format('YYYY-MM-dd');
                
                response = JSON.serialize(OnlineAppointments_Utils.getOnlineAndTeamAppointments( onlyOnline,  onlyUnassigned, null, startDate, endDate, null),true);
                System.debug('response ' + response);
            } else if( service == 'Capacities'){
                String availabilityId = (String) req.params.get('availabilityId');
                response = JSON.serialize(OnlineAppointments_Utils.getFreeCapacityByAvailabilityId(availabilityId, null),true);
            }
            System.debug('response2 ' + response);
            res.responseBody = Blob.valueOf(response);

            // new Logs.DEBUG('WS_OnlineAppointments','API',response);
        }
        catch(Exception ex){
            res.statusCode = 500;
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
            OnlineAppointments_Utils.ResponseHandler errorObject = new  OnlineAppointments_Utils.ResponseHandler(null,null,null, null);
            if(ex.getTypeName() == 'DmlException' ){
                errorObject = new OnlineAppointments_Utils.ResponseHandler(ex.getDmlType(0), ex.getMessage() + ' Line:' + ex.getLineNumber(), ex.getDmlFieldNames(0), 'DML_EXCEPTION');
            } else {
                errorObject = new OnlineAppointments_Utils.ResponseHandler(null, ex.getMessage() + ' Line:' + ex.getLineNumber(), null, 'GENERIC_ERROR');
            }
            res.responseBody = Blob.valueOf(JSON.serialize(errorObject,true));

            // new Logs.ERROR('WS_OnlineAppointments','API',ex);
        }
    }
}