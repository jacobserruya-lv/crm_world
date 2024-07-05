/*  
*** Balink January 2017
*** DESCRIPTION: WebService From LV to SF with goal to update the current loggedin User Identity
*/
@RestResource(urlMapping='/UpdateIdentity')
global with sharing class PASS_WS04_UpdateUserId2 {
	
	@HttpPost
	global static IDENTITY_Utils.ResponseHandler UpdateUserIdentity() {

		// INFO LOG
		new Logs(new Map<String,Object> {
            'level' => 'INFO', 
            'apexClass' => 'PASS_WS04_UpdateUserId2', 
            'category' => 'API',
            'message' => 'debug /UpdateIdentity WS'
        });
		
		return PASS_WS02_UpdateUserId.UpdateUserIdentity();
	}
}