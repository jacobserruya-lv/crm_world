@isTest
private class BL_EMAIL_Config_TEST {
    @isTest
    static void getConfigEmail() {
        BL_AppSettings.setAppSettings('Email');
        BL_EMAIL_Config config = new BL_EMAIL_Config();
        
        Test.startTest();
            config.queryParams = new Map<String, String>{'features' => null};     
            config.executeGET();
        Test.stopTest();
    }

    @isTest
    static void getOrgWideAddress() {
        BL_EMAIL_Config_Helper.getSenderAddressByEmail('test@email.com');
    }
}