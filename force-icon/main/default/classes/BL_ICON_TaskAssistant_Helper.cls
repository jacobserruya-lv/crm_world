public with sharing class BL_ICON_TaskAssistant_Helper extends BL_WS_Request{

    public static Object getTasksAssistant(BL_UserInfo me, Integer pageIndex, Integer pageSize, String ownerId, String status, Map<String, Object> filter){

        Map<String, Object> mappedTask = new  Map<String, Object>();
        List<String> filtersList = new List<String>();
		String addCondition = '';
        String condition = '';
        String storeId = [SELECT Id FROM Store__c WHERE RetailStoreId__c = :me.basicInfos.DefaultStore__c]?.Id;
        String dateToCheck = DateTime.now().addDays(-5).format('yyyy-MM-dd');

        if((status != null && status.contains('ongoing')) || String.isEmpty(status)){  
            String conditionToDisplay = '';
            
            // if(filter != null && !filter.isEmpty()){
            //     addCondition = parseFilters(filter);
            //     if(!String.isBlank(addCondition)){
            //         conditionToDisplay = ' and ' + addCondition;
            //     }
            // }
            condition = 'DueDate__c >= today  AND IsArchieved__c = false AND IsCompleted__c = false AND OwnerId = \'' + ownerId + '\'' +  conditionToDisplay;
            mappedTask.put('ongoing', getListTask(condition, pageSize, pageIndex)); 
        }
        if((status != null && status.contains('archieved')) || String.isEmpty(status)){  


            condition = 'IsArchieved__c = TRUE AND IsCompleted__c = FALSE AND (DueDate__c > TODAY OR DueDate__c >= ' + dateToCheck +') AND OwnerId = \'' + ownerId + '\'';
            mappedTask.put('archieved',  getListTask(condition, pageSize, pageIndex));          
        }
        if((status != null && status.contains('completed')) || String.isEmpty(status)){    
            condition = 'IsCompleted__c = TRUE AND (DueDate__c > TODAY OR DueDate__c >= ' + dateToCheck +') AND OwnerId = \'' + ownerId + '\'';
            mappedTask.put('completed',  getListTask(condition, pageSize, pageIndex));           
        }

        return mappedTask;
    }

    public static List<Map<String,Object>> getListTask(String condition, Integer pageSize, Integer pageIndex) {

        return  new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_TASK_ASSISTANT)  
        .condition(condition )
        .orderBy('PriorityRank__c NULLS LAST, DueDate__c DESC')
        .pagination(pageIndex, pageSize)
        .executeQuery()
        .getMappedObjects();
    }

    public  static Object updateTasksAssistant(BL_UserInfo me,List<Object> records){
        try {
            return new BL_EasyQuery()
                    .useCase(BL_ICON_Constants.USE_CASE_TASK_ASSISTANT)
                    .upsertWrappersWithChilds(records, null, null);
        }
        catch(Exception ex){
            return new Map<String,Object> {'status' =>'error ' + ex};
        }
    }

    // private static String parseFilters(Map<String, Object> filter) {
    //     List<String> condition = new List<String>();
    //     String clientType = (String)(filter.get('clientType'));
    //     String timeLine = (String)(filter.get('timeLine'));
    //     Boolean isLocal = (Boolean)(filter.get('isLocal'));
    //     List<Object> type = (List<Object>)(filter.get('type'));

    //     if(!String.isEmpty(clientType)){
    //         String clientTypeCondition = '';
    //         switch on clientType {
    //             when '10k' {
    //                 clientTypeCondition += 'TECH_SubSegment__c IN (\'Prestige\' , \'VVIC\', \'VIC\')';
    //                 condition.add(clientTypeCondition);
    //             }
    //             when 'aspiring' {
    //                 clientTypeCondition += 'TECH_SubSegment__c IN (\'Aspiring Repeater\' , \'Repeater\')';
    //                 condition.add(clientTypeCondition);
    //             }
    //         }
    //     }
    //     if(!String.isEmpty(timeLine)){
    //         String timeLineCondition = '';
    //         switch on timeLine {
    //             when 'today' {
    //                 timeLineCondition += 'DueDate__c = Today';
    //                 condition.add(timeLineCondition);
    //             }
    //             when 'urgent' {
    //                 timeLineCondition += 'PriorityRank__c = 0';
    //                 condition.add(timeLineCondition);
    //             }
    //         }
    //     }
    //     if(isLocal != null && isLocal){
    //         String isLocalCondition = '';
    //         isLocalCondition += 'TECH_IsLocal__c = true';
    //         condition.add(isLocalCondition);
    //     }

    //     if(type != null && !type.isEmpty()){
    //         String typeCondition = '';
    //         String taskType = '\'' + String.join((type), '\',\'') + '\'';

    //         typeCondition = 'ToDoType__c IN (' + taskType + ')';
    //         condition.add(typeCondition);
    //     }
    //     return String.join(condition, ' and ');
    // }
}