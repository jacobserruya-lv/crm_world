global with sharing class BL_ICON_Me extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET {
    global Object executeGET(){
        return new BL_WS_Response(me.userDetails); 
    }
}