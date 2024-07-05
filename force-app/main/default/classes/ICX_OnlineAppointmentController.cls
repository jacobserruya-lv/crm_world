/*	 * @author Keman WU
* @date creation 22/10/2021
* @description Update OnlineAppointment
*/
public without sharing class ICX_OnlineAppointmentController {
    @AuraEnabled (Cacheable=false)  
    public static void changeOnlineAppointmentOwner(Id careServiceId,Id UserId) {
        List <Event> lstAppointmentsToUpdate = new List<Event> ();
        List <Event> lstAppointments = [select id,OwnerId,Status__c,StartDateTime  from event where RecordType.DeveloperName = 'Online_Appointment' and My_Repairs__c =:careServiceId];
       if(lstAppointments.size()>0){
        for(Event appointment :lstAppointments){
            if(appointment.StartDateTime > System.now() && appointment.Status__c != 'Cancelled'){
                 appointment.OwnerId = UserId;
                 appointment.Status__c = 'Assigned';
                 lstAppointmentsToUpdate.add(appointment);
                }
        }
        
        Update lstAppointmentsToUpdate;
    }    
       
    }

    public static void massChangeOnlineAppointmentOwner(Set<Id> careIds,Id UserId) {
        List <Event> lstAppointmentsToUpdate = new List<Event> ();
        List <Event> lstAppointments = [select id,OwnerId,Status__c,StartDateTime  from event where RecordType.DeveloperName = 'Online_Appointment' and My_Repairs__c in:careIds];
       if(lstAppointments.size()>0){
        for(Event appointment :lstAppointments){
            if(appointment.StartDateTime > System.now() && appointment.Status__c != 'Cancelled'){
                if(UserId != null){
                    appointment.OwnerId = UserId;
                    appointment.Status__c = 'Assigned';
                }else{
                    User u = [SELECT Id FROM User WHERE Name ='Identity Integration' and IsActive = true];
                    appointment.OwnerId = u.Id;
                    appointment.Status__c = 'Not Assigned';  
                }
                 lstAppointmentsToUpdate.add(appointment);
                }
        }
        
        Update lstAppointmentsToUpdate;
    }    
       
    }

    public static void cancelOnlineAppointment(Set <Id> careIds) {
        
        List <Event> lstAppointments = [select id,StartDateTime,Status__c from Event where My_Repairs__c in: careIds];  
        List <Event> lstAppointmentsToUpdate = new List<Event> ();
        if(lstAppointments.size()>0){
         for(Event appointment :lstAppointments){            
            if(appointment.StartDateTime > system.now() && appointment.Status__c != 'Cancelled' ){ 
                appointment.Status__c = 'Cancelled';                                         
                 lstAppointmentsToUpdate.add(appointment);
                }
        }
    }
        Update lstAppointmentsToUpdate;
        
       
    }

    @AuraEnabled( cacheable=true ) 
    public static RelatedListWrapper fetchRecords( String listValues )  { 

        system.debug( 'values are ' + listValues ); 
        List < String > strList = listValues.split( '-' ); 
        system.debug( 'values are ' + strList ); 
        RelatedListWrapper objWrap = new RelatedListWrapper();
         
        if ( strList.size() == 8 ) { 
         
            String recordId = strList.get( 0 ); 
            String objectName = strList.get( 1 ); 
            String parentFieldAPIName = strList.get( 2 ); 
            String fieldName = strList.get( 3 ); 
            String fieldValue = strList.get( 4 ); 
            String filterType = strList.get( 5 ); 
            String operator = strList.get( 6 ); 
            String fieldsList = strList.get( 7 ); 
             
            String strSOQL = 'SELECT Id';
            strSOQL += ', ' + fieldsList;
            String filter = ' FROM ' + objectName + ' WHERE ' + parentFieldAPIName + ' = \'' + recordId + '\' AND '; 
            if ( filterType == 'String' )     
                filter += fieldName + ' = \'' + fieldValue + '\''; 
            else if ( filterType == 'Boolean' )     
                filter += fieldName + ' = ' + fieldValue; 
            else 
                filter += fieldName + ' ' + operator + ' ' + fieldValue; 
            String strCountSOQL = ' SELECT COUNT() ' + filter;
            objWrap.recordCount = Database.countQuery( strCountSOQL );
            strSOQL += filter + ' LIMIT 3';     
            system.debug('strSOQL' +strSOQL);
            objWrap.listRecords = Database.query( strSOQL ); 
            system.debug('objWrap.listRecords' +objWrap.listRecords);
             
        }   
        return objWrap; 
         
    } 

    public class RelatedListWrapper {

        @AuraEnabled
        public List < SObject > listRecords;
        @AuraEnabled
        public Integer recordCount;

    }

    @AuraEnabled (Cacheable=false)  
    public static void updateAppointment(Id eventId,String straAttendance) {             
       Event app = [select id,Attendance__c,Status__c from event where Id=:eventId];
       if(app != null && straAttendance != 'Cancelled' ) 
                 app.Attendance__c = straAttendance; 
       if (app != null && straAttendance == 'Cancelled') {   
                 app.Status__c = 'Cancelled';     
                 app.Attendance__c = 'None';                 
       }      
       
        update app;
       
    }    
       
    
}