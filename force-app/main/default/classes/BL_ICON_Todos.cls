/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-06-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   04-21-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global with sharing class BL_ICON_Todos extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET, BL_WS_Interfaces.DispatchablePUT{

    global Object executePUT(){
        List<Object> records;
        if (this.requestBody != null && String.isNotEmpty(this.requestBody.toString())) {
            records = getRequestRecords();
        }
       return BL_ICON_Todos_Helper.updateTodos(me,records); 
    }
     

     global Object executeGET(){

       Integer pageIndex = getQueryParameter('pageIndex') != null ? Integer.valueOf(getQueryParameter('pageIndex')) :null;
       Integer pageSize = getQueryParameter('pageSize') != null  ? Integer.valueOf(getQueryParameter('pageSize')) : null;
       String status = getQueryParameter('status') != null ? getQueryParameter('status') : null;
       String filter = getQueryParameter('filter') != null ? getQueryParameter('filter') : '';
       String ownerId = getQueryParameter('caId') != null ? getQueryParameter('caId') : me.basicInfos.Id;
       
       return BL_ICON_Todos_Helper.getTodos(me,pageIndex,pageSize ,ownerId, filter);

      // return BL_ICON_Todos_Helper.getAllTodos(me,status,pageIndex,pageSize);
        
    }

}