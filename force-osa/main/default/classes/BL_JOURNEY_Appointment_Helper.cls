public with sharing class BL_JOURNEY_Appointment_Helper {

    
    public static Object getAppointments(Map<String, String> params){

        String onlineRecordType = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
        String appointmentRecordType = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Appointments').getRecordTypeId();
        String goldenRecordType = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Golden').getRecordTypeId();

        List<String> listOfAppointmentRecordTypesId= new list<String>{
            '\''+ onlineRecordType +'\'',
            '\''+appointmentRecordType+'\'' 
        };
        
        String storeCode = params.get('storeCode');
        Long startDatetime = Long.valueOf(params.get('from'));
        Long endDatetime = Long.valueOf(params.get('to'));
        String format = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        String userId = getUserIdByEmployeeNumber(params.get('caUniqueId'));
        Integer pageIndex = params.containsKey('pageIndex') ? Integer.valueOf(params.get('pageIndex')) : null;
        Integer pageSize = params.containsKey('pageSize') ? Integer.valueOf(params.get('pageSize')) : null;

        List<Store__C> stores = [SELECT RetailStoreId__c, ISO3_Code__c FROM Store__c WHERE RetailStoreId__c =: storeCode LIMIT 1];
        if(stores.isEmpty()) throw new BL_Exceptions.RouterException('Store not found');
        String userCondition = String.isNotEmpty(userId) ?  'OwnerId = \'' + userId + '\'' : '';
        
        if(stores.get(0).ISO3_Code__c == 'CHN') {
            listOfAppointmentRecordTypesId.add( '\''+ goldenRecordType + '\'' );
            userCondition = String.isNotEmpty(userId) ?  '(OwnerId = \'' + userId + '\'' + ' OR CA_Ids__c LIKE \'%' + userId + '%\' ) ' : '';
        }

        Object appointments = new BL_EasyQuery()
        .useCase(BL_JOURNEY_Constants.USE_CASE_APPOINTMENT_JOURNEY)
        .addFields( new List<String>{'TYPEOF Owner WHEN User THEN WWEmployeeNumber__c  END'})
        .addCondition('RecordTypeId IN ' + listOfAppointmentRecordTypesId)
        .addCondition('Status__c IN (\'Assigned\', \'Not Assigned\', \'\', null)')
        .addCondition('Store_Location__r.RetailStoreId__c = \''+  params.get('storeCode') + '\'')
        .addCondition('StartDateTime <=' +  DateTime.newInstance(endDatetime).format(format))
        .addCondition('StartDateTime >=' +  DateTime.newInstance(startDatetime).format(format))
        .addCondition(userCondition)
        .orderBy('StartDateTime DESC')
        .pagination(pageIndex, pageSize)
        .executeQuery()
        .getSObjects();

        return appointments;
    }

    public static String getUserIdByEmployeeNumber(String employeeNumber ){
        String userId;
        if(!String.isEmpty(employeeNumber)) {

            userId =  [SELECT id FROM User WHERE WWEmployeeNumber__c =: employeeNumber LIMIT 1]?.Id;
            
            if(String.isEmpty(userId)) throw new BL_Exceptions.RouterException('caUniqueId not exists');
        } 
        
        return userId;
    }

}