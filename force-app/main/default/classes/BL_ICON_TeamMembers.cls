global class BL_ICON_TeamMembers extends BL_WS_Request implements BL_WS_Interfaces.DispatchablePOST{
	
    global Object executePOST(){
       Object record = getRequestRecord();
        return new BL_WS_Response(BL_ICON_TeamMembers_Helper.setTeamMembers((Map<String,Object>)record));   
     }
}