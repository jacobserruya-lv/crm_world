@IsTest
private class BL_Experience_TEST {
    @isTest
    static void executeGET_TEST(){
        BL_AppSettings.setAppSettings('Experience');

        BL_Experience controller = new BL_Experience();
        controller.path = '/experience/v1/experiences/test?limit=2&offset=0';
        controller.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
        controller.pathParameters = new Map<String, String> {'clubname' => 'test'};
        controller.queryParams = new Map<String, String> {
            'limit' => '1',
            'offset' => '0'
        };

        Test.startTest();  
        try {
            controller.executeGET();
        } catch (Exception e) {
            System.debug('Expected error');
        }
        Test.stopTest();
    }  

    @isTest
    static void executePATCH_TEST() {
        BL_AppSettings.setAppSettings('Experience');

        BL_Experience controller = new BL_Experience();
        controller.path = 'experience/v1/experiences/members/test';
        controller.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
        controller.pathParameters = new Map<String, String> {'id' => 'test'};
        controller.requestBody = new Map<String, String> {
            'test' => '1'
        };

        Test.startTest();    
        try {
            controller.executePATCH();
        } catch (Exception e) {
            System.debug('Expected error');
        }
        Test.stopTest();
    } 
}