@isTest
global class IDENTITY_RemoveSessionHandlerCA_TEST {
    global class MockConnectedAppPlugin extends Auth.ConnectedAppPlugin {
        private Boolean isAdminApproved;
        
        public MockConnectedAppPlugin(Boolean isAdminApproved) {
            this.isAdminApproved = isAdminApproved;
        }
        
        global override Boolean authorize(Id userId, Id connectedAppId, Boolean isAdminApproved, Auth.InvocationContext context) {
            return this.isAdminApproved;
        }
    }
    
    @isTest
    static void testAuthorize() {
        IDENTITY_RemoveSessionHandlerCA handler = new IDENTITY_RemoveSessionHandlerCA();
        String clientId = UserInfo.getOrganizationId().substring(0, 15);
        Boolean result = handler.authorize(UserInfo.getUserId(), clientId, false, null);
        System.assertNotEquals(null, result);
    }
}