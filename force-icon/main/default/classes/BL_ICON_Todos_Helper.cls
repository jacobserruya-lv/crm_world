/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-23-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   04-22-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class BL_ICON_Todos_Helper extends BL_WS_Request{

    public static final Integer NUMBER_COMPLETED_TASK = 5 ;
    public static final Id TaskTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('To_Do_Assistant').getRecordTypeId();


    public static Object getTodos(BL_UserInfo me,Integer pageIndex,Integer pageSize ,String ownerId ,String filter){ 

        List<String> filters = String.isnotblank(filter)?  filter.split(';') : new List<String>();
        Map<String, Object> mappedTask = new  Map<String, Object>();
        
        getTaskByCondition(me, ownerId  , mappedTask , filters) ;
        
        List<AggregateResult> countBadges = [SELECT COUNT(id) cnt  FROM IconBadge__c  WHERE OwnerId = :ownerId];
        mappedTask.put('badges' ,(Integer) countBadges[0].get('cnt') )  ;

        
        List<AggregateResult> completedTask = [SELECT COUNT(id) cnt  FROM Task WHERE RecordTypeId =:TaskTypeId  AND Status='Completed' AND IsBadged__c = false AND OwnerId =:ownerId AND Assignment__c = 'CA' AND ClosedByIS__c = false] ;
        mappedTask.put('restOfTask' , NUMBER_COMPLETED_TASK - (Integer) completedTask[0].get('cnt')   )  ;

        return mappedTask;
    }

    public static void getTaskByCondition(BL_UserInfo me  ,String ownerId , Map<String, Object> mappedTask ,List<String> filters ){

        String condition = '';
        String storeId = [SELECT Id FROM Store__c WHERE RetailStoreId__c = :me.basicInfos.DefaultStore__c].Id;

        if((filters.contains('unassign') || filters.isEmpty())  && me.basicInfos.TECH_IsManager__c  ){
            String managerCondition = me.basicInfos.TECH_IsManager__c ?  ' Assignment__c = \'Reassigned\'  AND Store_Location__c= \'' +  storeId + '\'': ''  ;
            condition =  '('+ managerCondition + ' AND  Status = \'New\') AND  recordTypeId = \''+ TaskTypeId + '\' AND ClosedByIS__c = False AND CreatedDate = LAST_N_DAYS:365' ;
            mappedTask.put('unassign', getListTask( condition));  
        }  

        if(filters.contains('ongoing') || filters.isEmpty()){
            String userId = me.basicInfos.Id;
            String managerCondition = '((Assignment__c = \'Manager\'  AND Store_Location__c = \'' +  storeId + '\') OR  OwnerId = \'' + ownerId + '\' )' ;
            String ownerCondition = me.basicInfos.TECH_IsManager__c && userId.left(15) == ownerId.left(15) ?  managerCondition : ' OwnerId = \'' + ownerId + '\'' ;
            
            //condition =  ownerCondition + 'AND ((To_do_type__c IN (\'Care Service\', \'Request\', \'Voice\', \'NY Order\', \'Xstore Order\') AND CreatedDate = LAST_N_DAYS:365) OR (To_do_type__c IN (\'Client\', \'Engaged\') AND ActivityDate >= TODAY)) AND  Status =  \'New\' AND IsBadged__c = false  AND  recordTypeId = \''+ TaskTypeId + '\' AND ClosedByIS__c = False' ;
            condition =  ownerCondition + 'AND ((To_do_type__c IN (\'Care Service\', \'Request\', \'NY Order\', \'Xstore Order\', \'Voice\') AND CreatedDate = LAST_N_DAYS:365) OR (To_do_type__c IN (\'Client\', \'Engaged\') AND ActivityDate >= TODAY)) AND  Status =  \'New\' AND IsBadged__c = false  AND  recordTypeId = \''+ TaskTypeId + '\' AND ClosedByIS__c = False' ;

            mappedTask.put('ongoing', getListTask(condition)); 
            mappedTask.put('per', getPercent(ownerId, TaskTypeId, storeId));   
            mappedTask.put('unassignedTaskCount', getUnassignedTasksCount(TaskTypeId, storeId));       
        }

        if(filters.contains('completed') || filters.isEmpty()){

           // condition = ' (Status =  \'Completed\'  AND ( OwnerId = \'' + ownerId + '\' OR LastModifiedById = \'' + ownerId + '\' ))  AND  recordTypeId = \''+ TaskTypeId + '\' AND lastModifiedDate = LAST_N_DAYS:7 and To_do_type__c IN (\'Care Service\', \'Request\', \'Voice\', \'NY Order\', \'Xstore Order\', \'Client\') AND ClosedByIS__c = False' ;
              condition = ' (Status =  \'Completed\'  AND ( OwnerId = \'' + ownerId + '\' OR LastModifiedById = \'' + ownerId + '\' ))  AND  recordTypeId = \''+ TaskTypeId + '\' AND lastModifiedDate = LAST_N_DAYS:7 and To_do_type__c IN (\'Care Service\', \'Request\', \'NY Order\', \'Xstore Order\',\'Voice\', \'Client\', \'Engaged\') AND ClosedByIS__c = False' ;

            mappedTask.put('completed', getListTask(condition));        
        }

        if((filters.contains('reassigned') || filters.isEmpty()) && me.basicInfos.TECH_IsManager__c ){

            String managerCondition = me.basicInfos.TECH_IsManager__c ?  ' Assignment__c = \'Reassigned\'  AND Store_Location__c = \'' +  storeId+ '\'': ''  ;
            condition =  '('+ managerCondition + ' AND  Status = \'Completed\') AND  recordTypeId = \''+ TaskTypeId + '\' AND ClosedByIS__c = False AND lastModifiedDate = LAST_N_DAYS:7' ;

            mappedTask.put('reassigned', getListTask(condition));        
        }


    }

    public static Decimal getPercent(String ownerId, String TaskTypeId, String storeId){
        Decimal per = 0.0;

        Integer com = Database.countQuery('select COUNT() FROM Task WHERE (Status =  \'Completed\'  AND ( OwnerId = \'' + ownerId + '\' OR LastModifiedById = \'' + ownerId + '\' ))  AND  recordTypeId = \''+ TaskTypeId + '\' AND lastModifiedDate = LAST_N_DAYS:7 and To_do_type__c IN (\'Care Service\', \'Request\', \'NY Order\', \'Xstore Order\',\'Voice\', \'Client\', \'Engaged\') AND ClosedByIS__c = False' );
        Integer ong = Database.countQuery('select COUNT() FROM Task WHERE ((Assignment__c = \'Manager\'  AND Store_Location__c = \'' +  storeId + '\') OR  OwnerId = \'' + ownerId + '\' ) AND ((To_do_type__c IN (\'Care Service\', \'Request\', \'NY Order\', \'Xstore Order\', \'Voice\') AND CreatedDate = LAST_N_DAYS:365) OR (To_do_type__c IN (\'Client\', \'Engaged\') AND ActivityDate >= TODAY)) AND  Status =  \'New\' AND IsBadged__c = false  AND  recordTypeId = \''+ TaskTypeId + '\' AND ClosedByIS__c = False' );
        if(ong + com == 0){
            return 0.0;
        }
        per = (decimal) com / (ong + com);
        return per;
    }

    public static Integer getUnassignedTasksCount(String TaskTypeId, String storeId){
        Integer count = 0;
        count = Database.countQuery('select COUNT() FROM Task WHERE (Assignment__c = \'Reassigned\' AND Store_Location__c = \''+ storeId + '\'  AND Status = \'New\') AND recordTypeId = \''+ TaskTypeId + '\' AND ClosedByIS__c = False AND CreatedDate = LAST_N_DAYS:365' );
        return count;
    }


    public static List<Map<String,Object>> getListTask (String condition) {

        return  new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_TODO_ASSISTANT )  
        .condition(condition )
        .orderBy('LastModifiedDate DESC')
        .executeQuery()
        .getMappedObjects();
    }

    public  static Object updateTodos(BL_UserInfo me,List<Object> records){

        try{
            new BL_EasyQuery()
                    .useCase(BL_ICON_Constants.USE_CASE_TODO_ASSISTANT)
                    .upsertWrappersWithChilds(records, null, null);

            List<Task> completedTaskNotBadged  =  [ SELECT id  
                                                    FROM Task 
                                                    WHERE RecordTypeId =:TaskTypeId  AND Status='Completed' AND IsBadged__c = false  AND ClosedByIS__c = False  AND OwnerId =: me.basicInfos.Id AND Assignment__c = 'CA' ORDER BY LastModifiedDate DESC ] ;
            
            System.debug('naooooooo' + completedTaskNotBadged);
            Integer numberBadgeToCreate = completedTaskNotBadged.size() / NUMBER_COMPLETED_TASK ;
            if(numberBadgeToCreate > 0){
                
                updateStatusIsBadged(numberBadgeToCreate,completedTaskNotBadged);
            	createBadges(numberBadgeToCreate,me.basicInfos.Id);
            }
                
            List<AggregateResult> countBadges =  [SELECT COUNT(id) cnt  FROM IconBadge__c  WHERE OwnerId = :me.basicInfos.Id];
            Integer restOfTask = numberBadgeToCreate != 0 ? NUMBER_COMPLETED_TASK - math.mod(completedTaskNotBadged.size(),Integer.valueOf(numberBadgeToCreate)):NUMBER_COMPLETED_TASK - completedTaskNotBadged.size() ;

            Map<String,Object> record = (Map<String,Object>)records.get(0); 
            String whatId = (String)record.get('whatId');

           // if((String) record.get('status') == 'Closed' || (Boolean) record.get('isClosedByIcon')){
            if((String) record.get('status') == 'Completed'){
                closeToDoAssistant(whatId, (String) record.get('to_do_type'));    
            }
            String storeId = [SELECT Id FROM Store__c WHERE RetailStoreId__c = :me.basicInfos.DefaultStore__c].Id;
            String ownerId = (String)record.get('caId') != null ? (String)record.get('caId') : me.basicInfos.Id;
            Decimal p = getPercent(ownerId, TaskTypeId, storeId);
            Integer unassignedTaskCount = getUnassignedTasksCount(TaskTypeId, storeId);
            return new Map<String, Object>{
                'status' =>'OK',
                'badges' =>(Integer) countBadges[0].get('cnt') ,
                'restOfTask' => restOfTask,
                'per' => p,
                'unassignedTaskCount' => unassignedTaskCount
            };

        } catch(Exception ex){
			SYSTEM.DEBUG('naoooooo' + ex);
            return new Map<String,Object> {'status' =>'error ' + ex};
        }

    }

public static void closeToDoAssistant(String whatId, String toDoType){
        List<Task> tasksToClose  = new List<Task>();
        Integer count = 0;
        switch on toDoType {
            when 'Request'{
                count = [Select id FROM Case WHERE IsClosed = true and id =: whatId].size();
            }
            when 'Care Service'{
                count = [Select id FROM CareService__c WHERE IsClosed__c = true and id =: whatId].size();
            }
            when 'Xstore Order'{
                count = [Select id FROM Order__c WHERE IsClosedByIcon__c = true and id =: whatId].size();
            }
            when 'NY Order'{
                count = [Select id FROM Opportunity WHERE IsClosedByIcon__c = true and id =: whatId].size();
            }
            when 'Voice'{
                count = [Select id FROM VO_Survey__c WHERE Solved__c = true and id =: whatId].size();
            }
        }
        
            if(String.isNotEmpty(whatId) && count > 0) {
                for(Task t : [SELECT Id, Status, ClosedByIS__c, Subject FROM Task WHERE WhatId =: whatId AND IsClosed = false]){
                    t.Status = 'Completed';
                    tasksToClose.add(t);
                }
         
                if(!tasksToClose.isEmpty()){
                    update tasksToClose;
                }     
            }
    }

    public static void updateStatusIsBadged(Integer numberBadge,List<Task> tasks){
        List<Task> isBadgedToUpdate = new List<Task>();
        Integer lim  = 0;
        for(Task tsk :tasks){    
            if(lim < numberBadge*NUMBER_COMPLETED_TASK ){
            tsk.IsBadged__c = true;
            isBadgedToUpdate.add(tsk);
            lim++;
            }   
        }
        Database.update(isBadgedToUpdate ,false);
    } 

    public static void createBadges (Integer numberBadge,Id ownerId){

        List<IconBadge__c> badgeList = new List<IconBadge__c>();
        for(Integer i=0; i<numberBadge;i++){
            IconBadge__c badge = new IconBadge__c(
                Type__c  = 'Regular',
                OwnerId = ownerId
                );
            badgeList.add(badge);
        }
        Database.insert(badgeList,false);
    } 

    /*

    public static List<Task> getCompletedTask(BL_UserInfo me){
        if (me.basicInfos.TECH_IsManager__c ){
            return [SELECT id,Status,OwnerId 
                                FROM Task 
                                WHERE RecordTypeId =:TaskTypeId  AND Status='Completed' AND IsBadged__c = false AND (OwnerId =:me.basicInfos.Id  OR( Assignment__c = 'Reassigned' OR (Assignment__c ='Manager' AND Store_Location__r.RetailStoreId__c =: me.basicInfos.DefaultStore__c)))
                                ORDER BY LastModifiedDate ASC] ;
        }
    
        return [SELECT id,Status,OwnerId 
                                FROM Task 
                                WHERE RecordTypeId =:TaskTypeId  AND Status='Completed' AND IsBadged__c = false AND OwnerId =:me.basicInfos.Id  
                                ORDER BY LastModifiedDate ASC] ;
    }
    
    public  static Map<String, Object> getAllTodos(BL_UserInfo me,String status,Integer pageIndex,Integer pageSize){ 
        
        Object allTask;
        Integer countBadge;   
        Integer restOfTask;
        String filterByStatus = (String.isNotBlank(status) ? ' AND Status =  \'' + status + '\'' : ''); 
        List<Task> tasks = getCompletedTask(me);

        Integer numberBadge = tasks.size() / NUMBER_COMPLETED_TASK ;
        String condition  = ' AND recordTypeId= \''+ TaskTypeId + '\'' + filterByStatus;

        if (me.basicInfos.TECH_IsManager__c )
            condition += '(OwnerId = \'' + me.basicInfos.Id + '\'  OR ((Assignment__c = \'Reassigned\' OR Assignment__c = \'Manager\'  ) AND Store_Location__r.RetailStoreId__c = \''+  me.basicInfos.DefaultStore__c + '\')) AND recordTypeId= \''+ TaskTypeId + '\'' + filterByStatus ;
        else 
            condition += 'OwnerId = \'' + me.basicInfos.Id + '\'' ;
            
            allTask = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_TODO_ASSISTANT )  
            .condition(condition )
            .orderBy('LastModifiedDate DESC')
            .pagination(pageIndex, pageSize)
            .executeQuery()
            .getMappedObjects();
        
            countBadge =  [SELECT id FROM  IconBadge__c  WHERE OwnerId = :me.basicInfos.Id].size() ;

        restOfTask = numberBadge != 0 ? NUMBER_COMPLETED_TASK - math.mod(tasks.size(),Integer.valueOf(numberBadge)):NUMBER_COMPLETED_TASK - tasks.size() ;
        return new Map<String, Object>{
            'records' => allTask,
            'badge' => countBadge,
            'restOfTask' => restOfTask  
            };
    }

    public  static Object updateTodos(BL_UserInfo me,List<Object> taskId,Object statut){


        Integer countBadge;
        Integer restOfTask;
        List<Task> statusToUpdate = new List<Task>();
        List<Task> tasks = new List<Task>();
        try{


            for(object obj : taskId){
                statusToUpdate.add(new Task(id = String.valueOf(obj) ,Status = String.valueOf(statut)));
            }

            update statusToUpdate;
          
            tasks = getCompletedtask(me);

            Integer  toDoNumbers = tasks.size();
            Integer numberBadge = toDoNumbers / NUMBER_COMPLETED_TASK ;

            updateStatusIsBadged(numberBadge,tasks);
            createBadges(numberBadge,me.basicInfos.Id);
            countBadge =  [SELECT id FROM  IconBadge__c  WHERE OwnerId = :me.basicInfos.Id].size() ;
            restOfTask = numberBadge != 0 ? NUMBER_COMPLETED_TASK - math.mod(tasks.size(),Integer.valueOf(numberBadge)):NUMBER_COMPLETED_TASK - tasks.size() ;


            return new Map<String, Object>{
                'status' =>'OK',
                'badge' => countBadge,
                'restOfTask' => restOfTask     
                };
            }
            catch(Exception ex){
                return new Map<String,Object> {'status' =>'error ' + ex};
        }
    }

    */
             

}