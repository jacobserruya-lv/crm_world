global with sharing class  BL_ICON_TaskAssistant extends BL_WS_Request implements BL_WS_Interfaces.DispatchablePOST, BL_WS_Interfaces.DispatchablePUT{
    global Object executePUT(){
        List<Object> records;
        if (this.requestBody != null && String.isNotEmpty(this.requestBody.toString())) {
            records = getRequestRecords();
        }
       return BL_ICON_TaskAssistant_Helper.updateTasksAssistant(me,records); 
    }
     


    global Object executePOST(){
       Object record = getRequestRecord();
       Map<String, Object> body  = (Map<String, Object>) record;

       Integer pageIndex = (body.get('pageIndex') != null ? (Integer)body.get('pageIndex') : 0);
       Integer pageSize =  (body.get('pageSize') != null ? (Integer)body.get('pageSize') : 50);
       String status = (body.get('status') != null ? (String)body.get('status') : null);
       Map<String, Object> filter =  (body.containsKey('filter') && body.get('filter') != null ? (Map<String, Object>)body.get('filter') : null);
       
       String ownerId = (body.get('caId') != null ? (String)body.get('caId') : me.basicInfos.Id);
       
       return BL_ICON_TaskAssistant_Helper.getTasksAssistant(me,pageIndex,pageSize ,ownerId, status, filter);        
    }
}