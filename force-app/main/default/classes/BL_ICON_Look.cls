global with sharing class BL_ICON_Look extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET, BL_WS_Interfaces.DispatchablePOST{
    
    global Object executeGET(){
        
        String lookId = (getPathParameter('lookId') != null ? getPathParameter('lookId') : null);
        Integer pageIndex = (getQueryParameter('pageIndex') != null ? Integer.valueOf(getQueryParameter('pageIndex')) : null);
        Integer pageSize = (getQueryParameter('pageSize') != null ? Integer.valueOf(getQueryParameter('pageSize')) : null);
        Integer totalSize;

        if(lookId == null)
            return new BL_WS_Response(BL_ICON_Look_Helper.getLooks(pageIndex, pageSize, me));
        else
            return new BL_WS_Response(BL_ICON_Look_Helper.getLooksById(pageIndex, pageSize, me, lookId));  
    }

    global Object executePOST(){
        if(path == '/looks/share'){
            return BL_ICON_Look_Helper.shareLooks(requestBody);
        }
        return null;
    }
}