@RestResource(urlMapping = '/experience/v1/*')
global class BL_Experience_WS_Router extends BL_WS_Router implements BL_WS_Interfaces.Routable {
    private static final String BASE_ENDPOINT = '/experience/v1';
    private static final String APPLICATION_NAME = 'experience';
    private static final String ROUTER_MAPPING_CLASSNAME = 'BL_Experience_WS_RouterMapping';
    private static final String USER_INFO_CLASSNAME = 'BL_ICON_UserInfo';

    @HTTPGet
    global static void doGET() {
        execute();
    }

    @HTTPPOST
    global static void doPOST() {
        execute();
    }
    @HTTPPATCH
    global static void doPATCH() {
        execute();
    }

    @HTTPPUT
    global static void doPUT() {
        execute();
    }

    @HTTPDELETE
    global static void doDELETE() {
        execute();
    }

    private static void execute(){
        executeRequest(BASE_ENDPOINT, APPLICATION_NAME, ROUTER_MAPPING_CLASSNAME, USER_INFO_CLASSNAME);
    }
}