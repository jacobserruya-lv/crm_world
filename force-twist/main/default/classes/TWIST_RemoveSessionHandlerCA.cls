global class TWIST_RemoveSessionHandlerCA extends Auth.ConnectedAppPlugin {
	// Authorize the app if the user has achieved quota tracked in a custom field
    global override Boolean authorize(Id userId, Id connectedAppId, Boolean isAdminApproved, Auth.InvocationContext context) 
    {
        TWIST_Settings__c setting = TWIST_Settings__c.getInstance();
         String exType = setting.Session_Type__c;
        delete [select Id from AuthSession where Users.Id =: userId and sessionType !=: exType];
        return isAdminApproved;
    }
}