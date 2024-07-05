@isTest
private class SFID_Utils_TEST {
        
    @isTest
    public static void test_getSalesforceAccessToken() {
        TWIST_Settings__c settings = TWIST_Settings__c.getInstance();
        String clientId = settings.AOB_Client_Id__c;
        String siteUrl = settings.AOB_Site_URL__c;
        String certifName = settings.AOB_Cert_Name__c;
        String authPath = settings.Auth_Path__c;
        SFID_Utils.getJWTAccessToken(Datetime.now().getTime() + 'test@test.com', clientId, siteUrl, certifName, authPath);
    }
}