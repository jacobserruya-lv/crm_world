public with sharing class BL_ICON_Task_Helper {

    public static Object getTaskById(string id){
        return new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_TASK)     
            .condition('id = \'' + id + '\'')
            .executeQuery()
            .getMappedObjects();
    }

    public static Object getAllTasks(BL_UserInfo me, Integer page, Integer limitValue){
        Date minDate =  date.today().addDays(-7);
        Date maxDate = date.today().addDays(30);
        return new BL_WS_Response( new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_TASK)
            .condition( ' ownerId = \'' + me.basicInfos.Id + '\' AND ActivityDate > ' +  string.valueof(minDate) + ' AND ActivityDate < ' + string.valueof(maxDate) )
            .pagination(page, limitValue)
            .executeQuery()
            .getMappedObjects());     
    }

    public static Object insertTasks(List<Object> wrapperItemMaps) {
        
        List<Task> tasks = (List<Task>) new BL_EasyQuery()
                                        .useCase(BL_ICON_Constants.USE_CASE_TASK)
                                        .convertWrapperToSObject(wrapperItemMaps);          
                                        
                                        
                       
        for(Task t : tasks){
            t.ownerId = String.isnotBlank(t.ownerId) ? t.ownerId : Userinfo.getUserId();
        }
        insert tasks;

        return (List<Map<String, Object>>) new BL_EasyQuery().useCase(BL_ICON_Constants.USE_CASE_TASK).condition(getQueryIdCondition(tasks)).executeQuery().getResponseMappedObjects().get('records'); 

    }

    public static Object updateTasks(List<Object> wrapperItemMaps) {
        List<Task> tasks = (List<Task>) new BL_EasyQuery()
                                        .useCase(BL_ICON_Constants.USE_CASE_TASK)
                                        .convertWrapperToSObject(wrapperItemMaps);
       
        update tasks;
        return (List<Map<String, Object>>) new BL_EasyQuery().useCase(BL_ICON_Constants.USE_CASE_TASK).condition(getQueryIdCondition(tasks)).executeQuery().getResponseMappedObjects().get('records'); 

    }

    public static Object deleteTasks(List<Object> wrapperItemMaps) {
        try{
            List<Task> tasks = (List<Task>) new BL_EasyQuery()
                                            .useCase(BL_ICON_Constants.USE_CASE_TASK)
                                            .convertWrapperToSObject(wrapperItemMaps);
            delete tasks;
            return new Map<String,String> {'status' =>'OK'};
        }
        catch(Exception ex){
            return new Map<String,String> {'status' =>'error'};
        }
    }

    public static Object deleteTask(String taskId) {
        try{
            Task tasks = (Task) new BL_EasyQuery()
                    .useCase(BL_ICON_Constants.USE_CASE_TASK)
                    .condition('Id = \'' + taskId + '\'')
                    .executeQuery().getSObject();
            delete tasks;
            return new Map<String,String> {'status' =>'OK'};
        }
        catch(Exception ex){
            return new Map<String,String> {'status' =>'error'};
        }
        
    }


    public static String getQueryIdCondition(List<SObject> objList) {
        Integer i = 0;
        String queryCondition = '';
        for(SObject obj : objList){
            if(i == 0){
                queryCondition += 'Id = \'' + obj.Id + '\'';
                i++;
            }
            else 
                queryCondition += 'OR Id = \'' + obj.Id + '\'';
        }
        return queryCondition;
    }
}