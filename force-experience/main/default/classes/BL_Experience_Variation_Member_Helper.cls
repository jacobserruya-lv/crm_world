public with sharing class BL_Experience_Variation_Member_Helper {

    public static Object getVariationMember(String variationId, List<String> status, Integer pageSize, Integer pageIndex,  BL_UserInfo me,String storeCode, List<String> caIds) {

        String ownerQuery = getOwnerCondition(me,storeCode, caIds);
       
        String statusQuery = '';
        Brand_Experience_Variation__c  experienceVariation = [ 
                                                                SELECT Id , EndDateTime__c, Guests_Authorized__c
                                                                FROM Brand_Experience_Variation__c
                                                                WHERE Id =: variationId
                                                            ];

        if(experienceVariation.EndDateTime__c < System.now()) {
            status = new List<String> {'Registered','Participated','Not Participated'};
        }

        if(!status.isEmpty()){
            String listStatus = BL_Utils.convertToString(status) ;
            statusQuery = 'Status__c IN' + listStatus;
        }   
      
		List<Brand_Experience_Variation_Member__c> members = (List<Brand_Experience_Variation_Member__c>) new BL_EasyQuery()
            .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_MEMBER)
            .condition(ownerQuery)
            .addCondition('Brand_Experience_Variation__c = \'' +  variationId + '\'')
            .addCondition(statusQuery)
            .pagination(pageIndex, pageSize)
			.executeQuery()
            .getSObjects();
  
        List<String> memberIdsList = new List<String>();    
        for (Brand_Experience_Variation_Member__c member : members) {
            memberIdsList.add(member.id);
        }
        String memberIds = BL_Utils.convertToString(memberIdsList);

        List<Event> appointmentList  = new  List<Event> ();
        if(!memberIdsList.isEmpty()){
            appointmentList = (List<Event>)new BL_EasyQuery()
            .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_APPOINTMENT)
            .condition('Event__c IN ' + memberIds )
            .executeQuery()
            .getSObjects();
        }

        Map<Id, List<Event>> appointmentsToMember = new Map<Id, List<Event>>();
        if(!appointmentList.isEmpty()){
            for (Event evnt : appointmentList) {
                if(!appointmentsToMember.containsKey(evnt.Event__c)){     
                    appointmentsToMember.put(evnt.Event__c, new List<Event>());
                }
                appointmentsToMember.get(evnt.Event__c).add(evnt);
            }
        }
        
        List<Object>records = new List<Object>();
        
        for(Brand_Experience_Variation_Member__c member : members){
            Map<String,Object> record = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(member));
            String recordId = String.valueOf(member.id);
            if (appointmentsToMember.containsKey(recordId)) {
                record.put('Activities__r', appointmentsToMember.get(recordId));
            }
            records.add(record);
        }
        return records;
    }

    public static Object getVariationMemberById(String memberId, BL_UserInfo me) {
        

        String ownerQuery = !me.basicInfos.TECH_IsManager__c ? 'Assigned_CA__c = \'' + me.basicInfos.Id + '\'' : '';
        Object member = new BL_EasyQuery()
                    .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_MEMBER)
                    .condition('Id = \'' +  memberId + '\'')
                    .addCondition(ownerQuery)
                    .executeQuery()
                    .getSObject();

        List<SObject> guests = (List<SObject>) new BL_EasyQuery()
        .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_GUEST)
        .condition('Brand_Experience_Variation_Member__c = \'' +  memberId + '\'')
        .executeQuery()
        .getSObjects();

        List<SObject> appointment = (List<SObject>) new BL_EasyQuery()
        .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_APPOINTMENT)
        .condition('Event__c = \'' +  memberId + '\'')
        .executeQuery()
        .getSObjects();

        Map<String, Object> memberMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(member));
        memberMap.put('guests', guests);
        memberMap.put('Activities__r', appointment);  
        return memberMap;      
    }

    public static Object createVariationMembers(List<Object> records, String experienceVarId ) {

        // remove Clients that are already existing as members 

        Set<String> clientIds = new Set<String>();
        Set<String> existingclientIds = new Set<String>();
        List<Object> recordsToInsert = new List<Object>();

        for (Object record : records) {
            Map<String, Object> recordmapped = (Map<String, Object>) record;
            clientIds.add((String) recordmapped.get('client'));
        }

        List<Object> existingMembers = getExistingVariationMembers(experienceVarId, clientIds);

        for (Object record : existingMembers) {
            Map<String, Object> recordmapped = (Map<String, Object>) record;
            existingclientIds.add( (String) recordmapped.get('client'));
        }
                                         
        for (Object record : records) {

            Map<String, Object> recordmapped = (Map<String, Object>) record;
            String clientId = (String) recordmapped.get('client');
            
            if(!existingclientIds.contains(clientId)){
                recordmapped.put('experienceVariation', experienceVarId);
                recordsToInsert.add(recordmapped);
            }
        }
          
        // Map<String,Object>  members =  (Map<String,Object>) new BL_EasyQuery()
        //                                                     .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_MEMBER)
        //                                                     .upsertWrappersWithChilds(recordsToInsert , null, null);
        List<SObject> members = new BL_EasyQuery()
                                .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_MEMBER)
                                .convertWrapperToSObject(recordsToInsert);
        upsert members;

        if(!existingMembers.isEmpty()){
            return existingMembers;
        }                                                    
        return members;
	}

    public static List<Object> getExistingVariationMembers(String experienceVarId, Set<String> clientIds) {

        return new BL_EasyQuery()
                .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_MEMBER_STATUS)
                .condition('Brand_Experience_Variation__c = \'' +  experienceVarId + '\'')
                .addCondition('Client__c IN' + + BL_Utils.convertToString(clientIds))
                .executeQuery()
                .getMappedObjects();
    }

    public static Object updateVariationMembers(Object recordBody, String memberId, BL_UserInfo me) {
        
        Map<String,Object> record = (Map<String,Object>) recordBody;
        record.put('id',memberId);

        Map<String,Object> members = (Map<String,Object>) new BL_EasyQuery()
                                                            .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_MEMBER)
                                                            .upsertWrappersWithChilds(new List<Object>{record} , null, null);
        
        return getVariationMemberById(memberId,me);
	}
    public static Object saveMemberandRelated(Object recordBody, String memberId, BL_UserInfo me) {
        Map<String,Object> bodyMap = (Map<String,Object>) recordBody;
        List<Object> guestsBody = bodyMap.containsKey('guests') ? (List<Object>) bodyMap.get('guests') : new List<Object>();
        List<Object> appointmentBody = bodyMap.containsKey('appointment') ? (List<Object>) bodyMap.get('appointment') : new List<Object>();
        bodyMap.remove('guests');
        bodyMap.remove('appointment');
        updateVariationMember(bodyMap,memberId); 
        upsertGuests(guestsBody);      
        upsertAppointment(appointmentBody);
        
        return getVariationMemberById(memberId,me);
	}
    public static void updateVariationMember(Object recordBody, String memberId) {
        
        Map<String,Object> record = (Map<String,Object>) recordBody;
        record.put('id',memberId);

        List<SObject> members = new BL_EasyQuery()
                                .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_MEMBER)
                                .convertWrapperToSObject(new List<Object>{record});
        update members;
    }

    public static void upsertGuests(List<Object> items) {   
        List<SObject> guests = new BL_EasyQuery()
                                    .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_GUEST)
                                    .convertWrapperToSObject(items);
        if (guests!=null&&!guests.isEmpty()) {
            upsert guests;  
        }
	}
    
    public static Object upsertGuestsPerMember(Object recordBody, String memberId, BL_UserInfo me) {
        Map<String,Object> bodyMap = (Map<String,Object>) recordBody;
        List<Object> items = (List<Object>) bodyMap.get('guests');
              
        List<SObject> guests = new BL_EasyQuery()
                                    .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_GUEST)
                                    .convertWrapperToSObject(items);
       
        upsert guests;
        return guests;
	}
    public static void upsertAppointment(List<Object> items) {          
        
        Id recordType = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Event_Appointment')?.getRecordTypeId();
        List<Object> appointmentList = new List<Object>();
        for(Object item :items){
            Map<String,Object> appointment = (Map<String,Object>) item;
            appointment.put('recordTypeId',recordType);

            appointmentList.add(appointment);
        }

        List<SObject> appointments = new BL_EasyQuery()
                                    .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_APPOINTMENT)
                                    .convertWrapperToSObject(appointmentList);

        if (appointments!=null&&!appointments.isEmpty()) {
            upsert appointments;
        }
	}

    public static Object deleteGuests(Object recordBody) {
        Map<String,Object> bodyMap = (Map<String,Object>) recordBody;
        List<Object> items = (List<Object>) bodyMap.get('guests');       
        List<Id> gstIdsList = getListOfGuestIds(items);
        Database.delete(gstIdsList, true);
        return 'deleted';
    }

    private static List<Id> getListOfGuestIds(List<Object> guestsIds){
        List<Id> gstList = new List<Id>();
        for(Object item: guestsIds){
            gstList.add(String.valueOf((item)));
        }
        return gstList;
    }


    private static String getOwnerCondition(BL_UserInfo me, String storeCode, List<String> caIdsList) {
        String ownerCondition = 'Assigned_CA__c = \'' + me.basicInfos.Id + '\'';
       
        if(String.isNotEmpty(storeCode) && me.basicInfos.TECH_IsManager__c ){
            ownerCondition =  'Brand_Experience_Variation__r.Store__r.RetailStoreId__c = \'' + storeCode + '\'';
        }
        if (!caIdsList.isEmpty() && me.basicInfos.TECH_IsManager__c){

            String caIds =  BL_Utils.convertToString(caIdsList);
            ownerCondition = 'Assigned_CA__c IN ' + caIds ;
        }
        return ownerCondition;
    }
}