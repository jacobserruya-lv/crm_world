@RestResource(urlMapping = '/icon/v1/*')
global class BL_ICON_WS_Router extends BL_WS_Router implements BL_WS_Interfaces.Routable {

    //TO UPDATE FOR EACH NEW ROUTER
    private static final String BASE_ENDPOINT = '/icon/v1';
    private static final String APPLICATION_NAME = 'Icon';
    private static final String ROUTER_MAPPING_CLASSNAME = 'BL_ICON_WS_RouterMapping';
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