public with sharing class BL_Experience_Variation_Helper {


    public static Object getAllVariation(String experienceType, String startAfter, String endBefore, Integer pageSize, Integer pageIndex, String storeId, BL_UserInfo me) {
       
        experienceType = 'Experience';
        String startDateQuery = String.isNotEmpty(startAfter) ? 'StartDateTime__c >= ' + startAfter : '';
        String endDateQuery = String.isNotEmpty(endBefore) ? 'EndDateTime__c <= ' + endBefore : '';
        String inStoreEvent = '(Store__r.RetailStoreId__c = \'' +  me.basicInfos.DefaultStore__c + '\' AND RecordTypeId = \'' +  BL_Experience_Variation_Utils.getRecordTypeExperienceVariation('InStore') + '\' AND' +' Brand_Experience__r.RecordTypeId = \'' + BL_Experience_Variation_Utils.getRecordTypeExperience(experienceType) + '\')'; 
      
        List<String> expIds = getBrandExperienceOutOfStoreInMyScope(me.basicInfos, startDateQuery, endDateQuery);
        String outOfStore = !expIds.isEmpty() ? ' ID IN '+ BL_Utils.convertToString(expIds) : '';

        List<Map<String, Object>> experienceVariations = new BL_EasyQuery()
            .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION)
            .condition(' ( ' + inStoreEvent + ( !expIds.isEmpty() ? ' OR ' + outOfStore : '') +  ' ) ')
            .addCondition('Status__c IN' +  BL_Utils.convertToString(new List<String> {'Ready','Ended' ,'Participation Opened'}))
            .addCondition(startDateQuery)
            .addCondition(endDateQuery)
            .orderBy('StartDateTime__c DESC')
            .pagination(pageIndex, pageSize)
            .executeQuery()
            .getMappedObjects();
        
        if(!me.basicInfos.TECH_IsManager__c){

            Map<String,Decimal> mapAggregateResultNominated = getMapAggregateResult(getAggregateResult(new List<String>(), me.basicInfos.Id, SummaryResult.NOMINATED )) ;
            Map<String,Decimal> mapAggregateResultConfirmed = getMapAggregateResult(getAggregateResult(new List<String>(), me.basicInfos.Id, SummaryResult.CONFIRM )) ;
            Map<String,Decimal> mapAggregateResultParticipated = getMapAggregateResult(getAggregateResult(new List<String>(), me.basicInfos.Id, SummaryResult.PARTICIPATED )) ;
            Map<String,Decimal> mapAggregateResultFillAttendance = getMapAggregateResult(getAggregateResult(new List<String> (), me.basicInfos.Id, SummaryResult.FILL_ATTENDANCE )) ; 

            for(Map<String, Object> variation : experienceVariations){
    
                String recordId = (String) variation.get('id');

                Decimal clientsNominatedNumber = mapAggregateResultNominated.containsKey(recordId) ? mapAggregateResultNominated.get(recordId) : 0 ;
                Decimal clientsConfirmedNumber = mapAggregateResultConfirmed.containsKey(recordId) ? mapAggregateResultConfirmed.get(recordId) : 0 ;
                Decimal clientsParticipatedNumber = mapAggregateResultParticipated.containsKey(recordId) ? mapAggregateResultParticipated.get(recordId) : 0 ;
                Decimal clientsFillAttendanceNumber = mapAggregateResultFillAttendance.containsKey(recordId) ? mapAggregateResultFillAttendance.get(recordId) : 0 ;

                variation.put(BL_Experiences_Constants.JSONRoot_clientsNominatedNumber, clientsNominatedNumber);
                variation.put(BL_Experiences_Constants.JSONRoot_clientsConfirmedNumber, clientsConfirmedNumber);
                variation.put(BL_Experiences_Constants.JSONRoot_clientsParticipatedNumber, clientsParticipatedNumber);
                variation.put(BL_Experiences_Constants.JSONRoot_clientsFillAttendanceNumber, clientsFillAttendanceNumber);
            }
        }   

        return experienceVariations;
    }

    public static Object getVariationeById(String experienceId, BL_UserInfo me) {

        Map<String,Object>  variation =  new BL_EasyQuery()
			.useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION)
			.condition('Store__r.RetailStoreId__c = \'' +  me.basicInfos.DefaultStore__c + '\'')
			.addCondition('Id = \'' + experienceId + '\'')
			.executeQuery()
            .getMappedObject();
        
        if(!me.basicInfos.TECH_IsManager__c){

            Map<String,Decimal> mapAggregateResultNominated = getMapAggregateResult(getAggregateResult(new List<String> {experienceId}, me.basicInfos.Id, SummaryResult.NOMINATED )) ;
            Map<String,Decimal> mapAggregateResultConfirmed = getMapAggregateResult(getAggregateResult(new List<String> {experienceId}, me.basicInfos.Id, SummaryResult.CONFIRM )) ;
            Map<String,Decimal> mapAggregateResultParticipated = getMapAggregateResult(getAggregateResult(new List<String> {experienceId}, me.basicInfos.Id, SummaryResult.PARTICIPATED )) ;
            Map<String,Decimal> mapAggregateResultFillAttendance = getMapAggregateResult(getAggregateResult(new List<String> {experienceId}, me.basicInfos.Id, SummaryResult.FILL_ATTENDANCE )) ; 

            String recordId = (String) variation.get('id');

            Decimal clientsNominatedNumber = mapAggregateResultNominated.containsKey(recordId) ? mapAggregateResultNominated.get(recordId) : 0 ;
            Decimal clientsConfirmedNumber = mapAggregateResultConfirmed.containsKey(recordId) ? mapAggregateResultConfirmed.get(recordId) : 0 ;
            Decimal clientsParticipatedNumber = mapAggregateResultParticipated.containsKey(recordId) ? mapAggregateResultParticipated.get(recordId) : 0 ;
            Decimal clientsFillAttendanceNumber = mapAggregateResultFillAttendance.containsKey(recordId) ? mapAggregateResultFillAttendance.get(recordId) : 0 ;

            variation.put(BL_Experiences_Constants.JSONRoot_clientsNominatedNumber, clientsNominatedNumber);
            variation.put(BL_Experiences_Constants.JSONRoot_clientsConfirmedNumber, clientsConfirmedNumber);
            variation.put(BL_Experiences_Constants.JSONRoot_clientsParticipatedNumber, clientsParticipatedNumber);
            variation.put(BL_Experiences_Constants.JSONRoot_clientsFillAttendanceNumber, clientsFillAttendanceNumber);
        }    
        return variation;  
    }

    public static Object getEvitesByVariation(String experienceVarId, BL_UserInfo me) {
    
        return new BL_EasyQuery()
        .useCase(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_EVITE)
        .condition('Experience_Variation__c = \'' +  experienceVarId + '\'')
        .orderBy('Createddate DESC')
        .executeQuery()
        .getMappedObjects();
    }

    public static Object getKPIsByVariation(String experienceVarId, BL_UserInfo me, List<String> features) {

        Map<String,Object> kpi = new Map<String,Object>();

        if(features.isEmpty()) features = new List<String> {'REGISTRATION','PARTICIPATION'};

        for(String  feature : features){

            switch on feature {
                when 'REGISTRATION' {

                    Map<String,Decimal> mapAggregateResultNotRegistered = getMapAggregateResult(getAggregateResult(new List<String> {experienceVarId},null, SummaryResult.NOT_REGISTERED )) ;
                    Map<String,Decimal> mapAggregateResultConfirmed = getMapAggregateResult(getAggregateResult(new List<String> {experienceVarId},null, SummaryResult.CONFIRM )) ;
                    Map<String,Decimal> mapAggregateResultDeclined = getMapAggregateResult(getAggregateResult(new List<String> {experienceVarId},null, SummaryResult.DECLINE )) ;
                
                    Decimal clientsNotRegisteredNumber = mapAggregateResultNotRegistered.containsKey(experienceVarId) ? mapAggregateResultNotRegistered.get(experienceVarId) : 0 ;
                    Decimal clientsConfirmedNumber = mapAggregateResultConfirmed.containsKey(experienceVarId) ? mapAggregateResultConfirmed.get(experienceVarId) : 0 ;
                    Decimal clientsDeclinedNumber = mapAggregateResultDeclined.containsKey(experienceVarId) ? mapAggregateResultDeclined.get(experienceVarId) : 0 ;

                    kpi.put(BL_Experiences_Constants.JSONRoot_clientsNotRegisteredNumber, clientsNotRegisteredNumber);
                    kpi.put(BL_Experiences_Constants.JSONRoot_clientsConfirmedNumber, clientsConfirmedNumber);
                    kpi.put(BL_Experiences_Constants.JSONRoot_clientsDeclinedNumber, clientsDeclinedNumber);
                }
                when 'PARTICIPATION' {
  
                    Map<String,Decimal> mapAggregateResultFillAttendance = getMapAggregateResult(getAggregateResult(new List<String> {experienceVarId}, null, SummaryResult.FILL_ATTENDANCE )) ; 
                    Map<String,Decimal> mapAggregateResultParticipated = getMapAggregateResult(getAggregateResult(new List<String> {experienceVarId}, null, SummaryResult.PARTICIPATED )) ;
                    Map<String,Decimal> mapAggregateResultNotParticipated = getMapAggregateResult(getAggregateResult(new List<String> {experienceVarId},null, SummaryResult.NOT_PARTICIPATED )) ;

                    Decimal clientsFillAttendanceNumber = mapAggregateResultFillAttendance.containsKey(experienceVarId) ? mapAggregateResultFillAttendance.get(experienceVarId) : 0 ;
                    Decimal clientsParticipatedNumber = mapAggregateResultParticipated.containsKey(experienceVarId) ? mapAggregateResultParticipated.get(experienceVarId) : 0 ;
                    Decimal clientsNotParticipatedNumber = mapAggregateResultNotParticipated.containsKey(experienceVarId) ? mapAggregateResultNotParticipated.get(experienceVarId) : 0 ;
            
                    kpi.put(BL_Experiences_Constants.JSONRoot_clientsFillAttendanceNumber, clientsFillAttendanceNumber);
                    kpi.put(BL_Experiences_Constants.JSONRoot_clientsParticipatedNumber, clientsParticipatedNumber);
                    kpi.put(BL_Experiences_Constants.JSONRoot_clientsNotParticipatedNumber, clientsNotParticipatedNumber);
                }
            } 
        } 
        return kpi;
    }

    public static List<AggregateResult> getAggregateResult(List<String> experienceIds, Id userId , SummaryResult field ) {

        String aggerate = getUseCaseAgregate(field);
        String experiencesId = !experienceIds.isEmpty() ? ' AND Brand_Experience_Variation__c IN: experienceIds ' : '';
        String user = String.isNotEmpty(userId) ? ' AND Assigned_CA__c =: userId ' : '';

        String soql = 'SELECT COUNT(id) result, Brand_Experience_Variation__c ' + 
        'FROM Brand_Experience_Variation_Member__c '+
        'WHERE ' + aggerate + user + experiencesId + 
        'GROUP BY Brand_Experience_Variation__c' ;

        BL_WS_Log.addLogQuery(soql, 'Aggregate on'+ field.name());
        List<AggregateResult> registeredClients = Database.query(soql);     
        
        return registeredClients;
    }

    public static Map<String,Decimal> getMapAggregateResult(List<AggregateResult> registeredClients){

        Map<String,Decimal> registeredClientsMap = new Map<String,Decimal>();

        for(AggregateResult aggResult : registeredClients){
    
            registeredClientsMap.put((String) aggResult.get('Brand_Experience_Variation__c'), (Decimal) aggResult.get('result'));
        }    
        return registeredClientsMap;
    }

    enum SummaryResult { NOMINATED, NOT_REGISTERED, CONFIRM, DECLINE, FILL_ATTENDANCE, PARTICIPATED, NOT_PARTICIPATED  }
    public static String getUseCaseAgregate(SummaryResult useCaseAgregate){
        
        switch on useCaseAgregate {
        
            when NOMINATED {
                return  'NominationStatus__c = \'Approved\'' ;            
            }
            when NOT_REGISTERED {
                return  'rsvpState__c = \'Not Registered\'' ;            
            }
            when CONFIRM {
                return  'rsvpState__c = \'Registered\'' ;            
            }
            when DECLINE {
                return  'rsvpState__c = \'Declined\'' ;            
            }
            when FILL_ATTENDANCE {
                return  'Attendance__c = \'none\'' ;
            }
            when PARTICIPATED {
                return  'Attendance__c = \'Yes\'' ;
            }
            when NOT_PARTICIPATED {
                return  'Attendance__c = \'No\'' ;
            }
        }
        return null;
    }



    public static List<String> getBrandExperienceOutOfStoreInMyScope(User currentUser, String startAfter, String endBefore ){
        String startDateQuery = String.isNotEmpty(startAfter) ? 'Brand_Experience_Variation__r.StartDateTime__c >= ' + startAfter : '';
        String endDateQuery = String.isNotEmpty(endBefore) ? 'Brand_Experience_Variation__r.EndDateTime__c <= ' + endBefore : '';
        String assignedCaCondition =  'Assigned_CA__c = \'' + currentUser.Id + '\'' ;
        String storeCondition = 'Assigned_CA__r.DefaultStore__c = \'' + currentUser.DefaultStore__c + '\'';
        String ownerCondition = currentUser.TECH_IsManager__c ? storeCondition :  assignedCaCondition ;

        List<String> experienceIds = new List<String>();
        List<AggregateResult> expaggregatExperiences = new BL_EasyQuery()
            .objectname('Brand_Experience_Variation_Member__c')
            .fields(new List<String> {'Brand_Experience_Variation__c'})
            .condition('Brand_Experience_Variation__r.RecordTypeId = \'' + BL_Experience_Variation_Utils.getRecordTypeExperienceVariation('OutOfStore')+ '\'' )
            .addCondition(startDateQuery)
            .addCondition(endDateQuery )
            .addCondition('Brand_Experience_Variation__r.Status__c IN' +  BL_Utils.convertToString(new List<String> {'Ready','Ended' ,'Participation Opened'}))
            .addCondition(ownerCondition + ' GROUP BY  Brand_Experience_Variation__c')
            .executeQuery()
            .getSObjects();

        for(AggregateResult agg : expaggregatExperiences){
            experienceIds.add( (String) agg.get('Brand_Experience_Variation__c'));
        }

        return experienceIds;
    }
    
}