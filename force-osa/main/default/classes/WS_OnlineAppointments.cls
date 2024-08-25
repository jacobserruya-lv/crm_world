/*
CreatedDate: June 2019
Company: Balink
Author: Jeremy Martiano
Description: Interface Web Sevice to Save ONLINE Appointments And Get ONLINE Appointments/ SLOTS
*/

@RestResource(urlMapping='/OnlineAppointment/*')
global without sharing class WS_OnlineAppointments {
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
                String socialId = (String) body.get('socialId');
                String sourceType = (String) body.get('sourceType');
                if(String.isNotBlank(socialId) && String.isNotBlank(sourceType) ){
                    accountId = OnlineAppointments_Utils.getAccountBySocialId(socialId, sourceType);
                } 
                response = JSON.serialize(OnlineAppointments_Utils.cancelOnlineAppointmnent(onlineAppointmentId, accountId),true);
            } 
            res.responseBody = Blob.valueOf(response);
            //UtilsLogs.addLog('ICON','WS_OnlineAppointments', JSON.serialize(body), JSON.serialize(req), response, '');
            // new Logs.DEBUG('WS_OnlineAppointments','API',response);
        }
        catch(Exception ex){
            res.statusCode = 500;
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
            OnlineAppointments_Utils.ResponseHandler errorObject = new  OnlineAppointments_Utils.ResponseHandler(null, null, null, null);
            if(ex.getTypeName() == 'DmlException' ){
                errorObject = new OnlineAppointments_Utils.ResponseHandler(ex.getDmlType(0), ex.getMessage() + ' Line: ' + ex.getLineNumber(), ex.getDmlFieldNames(0), 'DML_EXCEPTION');
            } else {
                if(ex.getMessage() == 'TIMESLOT_NOT_AVAILABLE'){    errorObject = new OnlineAppointments_Utils.ResponseHandler(null, 'The timeslot is no more available' , null, 'TIMESLOT_NOT_AVAILABLE');
                    res.statusCode = 200;
                } else if(ex.getMessage() == 'TIMESLOT_NOT_EXIST'){ errorObject = new OnlineAppointments_Utils.ResponseHandler(null, 'The timeslot is not existing' , null, 'TIMESLOT_NOT_EXIST');
                    res.statusCode = 200;
                } else  if(ex.getMessage() == 'APT_ID_NOT_EXIST'){  errorObject = new OnlineAppointments_Utils.ResponseHandler(null, 'The appointment is not existing' , null, 'APT_ID_NOT_EXIST');
                    res.statusCode = 200;
                } else  if(ex.getMessage() == 'CANCEL_APT_ID_NOT_EXIST'){ errorObject = new OnlineAppointments_Utils.ResponseHandler(null, 'We can not canceled your appointment. Please contact the customer service team.' , null, 'CANCEL_APT_ID_NOT_EXIST');
                    res.statusCode = 200;
                } else  if(ex.getMessage() == 'CANCELATION_NOT_AUTHORIZED'){ errorObject = new OnlineAppointments_Utils.ResponseHandler(null, 'We are not authorized to cancel this appointment.' , null, 'CANCELATION_NOT_AUTHORIZED');
                    res.statusCode = 200;
                } else  if(ex.getMessage() == 'CANNOT_ASSIGN_APT_WITHOUT_ACCOUNT'){ errorObject = new OnlineAppointments_Utils.ResponseHandler(null, 'We cannot assign the appointment without client infos.' , null, 'CANNOT_ASSIGN_APT_WITHOUT_ACCOUNT');
                    res.statusCode = 200;
                } else  if(ex.getMessage() == 'UPDATE_NOT_AUTHORIZED'){ errorObject = new OnlineAppointments_Utils.ResponseHandler(null, 'You are not authorized to modify this appointment.' , null, 'UPDATE_NOT_AUTHORIZED');
                    res.statusCode = 200;
                } else  if(ex.getMessage() == 'APPOINTMENT_TYPE_NOT_AVAILABLE'){ errorObject = new OnlineAppointments_Utils.ResponseHandler(null, 'The appointment type is not available for this store.' , null, 'APPOINTMENT_TYPE_NOT_AVAILABLE');
                    res.statusCode = 200;
                }else{
                    errorObject = new OnlineAppointments_Utils.ResponseHandler(null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null,'GENERIC_ERROR');
                }
            }
            
            res.responseBody = Blob.valueOf(JSON.serialize(errorObject,true));
            new Logs.ERROR('WS_OnlineAppointments','API',ex);
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
                response = JSON.serialize(OnlineAppointments_Utils.getClientAppointments(req.params,false),true);
            } else if( service == 'Availability'){
                String storeIds = req.params.get('storeIds');
                String datesString = req.params.get('dates');
                String startDate = req.params.get('startDate');
                String endDate = req.params.get('endDate');
                response = JSON.serialize(OnlineAppointments_Utils.getFreeAvailabilities(storeIds, datesString, startDate, endDate),true);
            } else if(service == 'AvailableStores') {
                String country = req.params.get('country');
                String storeIds = req.params.get('storeIds');

                response = JSON.serialize(OnlineAppointments_Utils.getAvalaibleStoresByCountry(country, storeIds), true);
            }
            res.responseBody = Blob.valueOf(response);
            // new Logs.DEBUG('WS_OnlineAppointments','API',response);
        }
        catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
            OnlineAppointments_Utils.ResponseHandler errorObject = new  OnlineAppointments_Utils.ResponseHandler(null, null, null, null);
            res.statusCode = 500;
            if(ex.getTypeName() == 'DmlException' ){
                errorObject = new OnlineAppointments_Utils.ResponseHandler(ex.getDmlType(0), ex.getMessage() + ' Line:' + ex.getLineNumber(), ex.getDmlFieldNames(0), 'DML_EXCEPTION');
            } else if(ex.getMessage() == 'AVAILABILITIES_EMPTY_LIST'){
                res.statusCode = 200;
                errorObject = new OnlineAppointments_Utils.ResponseHandler(null, 'We do not find any timeslots for your location.' , null, 'EMPTY_LIST');
            }else {
                errorObject = new OnlineAppointments_Utils.ResponseHandler(null, ex.getMessage() + ' Line:' + ex.getLineNumber(), null, 'GENERIC_ERROR');
            }
            res.responseBody = Blob.valueOf(JSON.serialize(errorObject,true));

            // new Logs.ERROR('WS_OnlineAppointments','API',ex);
        }
    }
}