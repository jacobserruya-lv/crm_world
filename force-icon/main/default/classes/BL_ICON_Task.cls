global with sharing class BL_ICON_Task  extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET, BL_WS_Interfaces.DispatchablePOST,BL_WS_Interfaces.DispatchablePUT, BL_WS_Interfaces.DispatchablePATCH, BL_WS_Interfaces.DispatchableDELETE{

    global Object executeGET(){
        
        String taskId = (getPathParameter('taskId') != null ? getPathParameter('taskId') : null);
        Integer page = (getQueryParameter('page') != null ? Integer.valueOf(getQueryParameter('page')) : null);
        Integer limitValue = (getQueryParameter('limit') != null ? Integer.valueOf(getQueryParameter('limit')) : null);

        if (String.isNotEmpty(taskId))
            return BL_ICON_Task_Helper.getTaskById(taskId);
        else {
            return BL_ICON_Task_Helper.getAllTasks(me, page, limitValue);
        }
    }

    global Object executePATCH() {
        List<Object> records =  new List<Object>();
        String taskId = (getPathParameter('taskId') != null ? getPathParameter('taskId') : null);

        if(taskId != null){
            records.add(requestBody);
            ((Map<String,Object>)records[0]).put('id', taskId);
        }
        else
            records =  getRequestRecords();

        return BL_ICON_Task_Helper.updateTasks(records);
        
        
    }
    global Object executePUT(){
        List<Object> records = new List<Object>();
         String taskId = (getPathParameter('taskId') != null ? getPathParameter('taskId') : null);
 
         if(taskId != null){
             records.add(requestBody);
            ((Map<String,Object>)records[0]).put('id', taskId);
         }
        else{
           records =  getRequestRecords();
        }
  		return BL_ICON_Task_Helper.updateTasks(records);
     }

    global Object executePOST() {
        List<Object> records = getRequestRecords();
        return BL_ICON_Task_Helper.insertTasks(records);
    
    }
    global Object executeDELETE() {
        String taskId = (getPathParameter('taskId') != null ? getPathParameter('taskId') : null);
        if(taskId == null){
            List<Object> records = getRequestRecords();
            return BL_ICON_Task_Helper.deleteTasks(records);
        }
        else{
            return BL_ICON_Task_Helper.deleteTask(taskId);
        }
        
    }
}