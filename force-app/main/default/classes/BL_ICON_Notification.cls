global with sharing class BL_ICON_Notification extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET, BL_WS_Interfaces.DispatchablePATCH{ 

    global Object executeGET(){


        Integer pageIndex = getQueryParameter('pageIndex') != null ? Integer.valueOf(getQueryParameter('pageIndex')) :null;
        Integer pageSize = getQueryParameter('pageSize') != null  ? Integer.valueOf(getQueryParameter('pageSize')) : null;
      
        return  BL_ICON_Notification_Helper.getAllNotification(me, pageIndex, pageSize);
    }

    global Object executePATCH(){
        if(path == '/notifications/read-all' ){ 
            
            return  BL_ICON_Notification_Helper.UpdateAllNotifications(me);
        }
     

        List<Object> records =  new List<Object>();
        records = getRequestRecords();
        return BL_ICON_Notification_Helper.UpdateNotificationAsRead(records);

    }

}