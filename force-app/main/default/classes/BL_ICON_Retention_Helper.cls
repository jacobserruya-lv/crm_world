public with sharing class BL_ICON_Retention_Helper extends BL_WS_Request{

    public static Object getRetentionDashboard (String filter, String storeCode, String lvmId){

        String segregationCond = filter == 'store' ? 'segregation_type__c=\'store\' AND Store_code__c = \''+ storecode+'\'' : 'segregation_type__c=\'ca\' AND LVM_Id__c = \''+ lvmId+'\'';
        Integer prevYear = Date.today().year()-1;
        String prevYearDate = String.valueOf(Date.newInstance(prevYear, 1, 1));
        String prevWeekDate  = String.valueOf(Date.today().addDays(-21));
        List<Object> records = (List<Object>)new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_RETENTION)
            .condition('(type__c = \'Dashboard\' AND '+segregationCond+' AND ( (Refresh_type__c =\'Monthly\' AND Date__c >= '+prevYearDate+') OR (Refresh_type__c =\'Weekly\' AND Date__c >= '+prevWeekDate+')) )')
            .orderBy('Date__c DESC')
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');
        
        Map <Integer, List<Object>> year_retentions = new Map <Integer, List<Object>>();
        Object weekly_current, weekly_previous;

        for(Object ret : records){
            Map<String, Object> retention = (Map<String, Object>) ret;

            if(retention.get('refresh_type') == 'Monthly'){
                Date d = (Date)retention.get('date');

                if(!year_retentions.containsKey(d.year()))
                    year_retentions.put(d.year(), new List<Object>());
                year_retentions.get(d.year()).add(retention);
            }

            if((String)retention.get('refresh_type') == 'Weekly'){
                if(weekly_current == null)
                    weekly_current = retention;
                else if(weekly_previous == null)
                    weekly_previous = retention;
            }
        }
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();

        gen.writeObjectField('Monthly', year_retentions);

        gen.writeFieldName('Weekly');
        gen.writeStartObject();
        if(weekly_current != null) gen.writeObjectField('current', weekly_current) ;
        if(weekly_previous != null) gen.writeObjectField('previous', weekly_previous);
        gen.writeEndObject();

        gen.writeEndObject();

        return JSON.deserializeUntyped(gen.getAsString());

    }

    public static Object getRetentionPyramid (String filter, String storeCode, String lvmId){

        String segregationCond = filter == 'store' ? 'segregation_type__c=\'store\' AND Store_code__c = \''+ storecode+'\'' : 'segregation_type__c=\'ca\' AND LVM_Id__c = \''+ lvmId+'\'';

        List<Object> records = (List<Object>)new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_RETENTION)
            .condition('type__c = \'Pyramid\' AND '+ segregationCond)
            .orderBy('Date__c DESC')
            .executeQuery()
            .getResponseMappedObjects()
            .get('records');

        List<Object> byVisitList = new List<Object>();
        List<Object> byR12MSpendingList = new List<Object>();

        for(Object ret : records){
            Map<String, Object> retention = (Map<String, Object>) ret;

            if(retention.get('pyramid_type') == 'byVisit'){
                byVisitList.add(retention);
            }
            else if((String)retention.get('pyramid_type') == 'byR12MSpending'){
                byR12MSpendingList.add(retention);
            }
        }
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();

        gen.writeObjectField('byVisit', byVisitList);
        gen.writeObjectField('byR12MSpending', byR12MSpendingList);

        gen.writeEndObject();

        return JSON.deserializeUntyped(gen.getAsString());
    }
    
    public static Object getStoreRanking(string userId, String defaultStore){

        Map<String, Map<String, Object>> userMap = new Map<String, Map<String, Object>>();
        List<Map<String,Object>> sorteredListMap = new List<Map<String,Object>>();
        String tempUserId;
        Date prevWeekDate  = Date.today().addDays(-16);
        //All the users under the store
        List<Map<String, Object>> membersMap  = new BL_EasyQuery()
                                                .useCase(BL_ICON_Constants.USE_CASE_TEAM)
                                                .conditionValues( new Map<String, String> {'userId' => userId})
                                                .condition('DefaultStore__c = \'' + defaultStore +  '\' AND IsActive = true AND IsTechnicalUser__c = false AND (NOT Email LIKE \'store_%\')')
                                                .executeQuery()
                                                .getMappedObjects();

        for(Map<String, Object> item: membersMap){
            userMap.put((String)item.get('wwEmployeeNumber'), item);
        }
        for(Retention__c ret : [SELECT LVM_Id__c,  Date__c, CANewRetentionRate__c, RetainedClient__c, R12MTotClient__c FROM Retention__c WHERE segregation_type__c='ca' AND LVM_Id__c IN:userMap.keySet() AND Date__c >=: prevWeekDate AND type__c='Dashboard' AND Refresh_type__c='weekly' ORDER BY Date__c DESC]){
            if(userMap.get(ret.LVM_Id__c)?.get('retentionRate') == null || (Date)userMap.get(ret.LVM_Id__c)?.get('Date__c') < ret.Date__c){
                userMap.get(ret.LVM_Id__c).putAll(new Map<String,Object>{'Date__c'=> ret.Date__c ,'retentionRate'=> ret.CANewRetentionRate__c, 'retainedClient'=> ret.RetainedClient__c, 'totalClient'=> ret.R12MTotClient__c});
            }
        }
        

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();

        gen.writeObjectField('userList', userMap.values());

        gen.writeEndObject();

        return JSON.deserializeUntyped(gen.getAsString());
    }

}