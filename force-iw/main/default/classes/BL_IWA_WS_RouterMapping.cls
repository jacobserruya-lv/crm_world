public class BL_IWA_WS_RouterMapping extends BL_WS_RouteMapping {

    public override Map < String,String > routesMapping() {
        return new Map < String,String > {
            '/translation' => 'BL_ICON_Translation',
            '/me' => 'BL_ICON_Me',
            '/config' => 'BL_IWA_Config',
            '/clients/{clientId}' => 'BL_IWA_Client',
            '/clients' => 'BL_IWA_SearchClient',
            '/activities/tasks' => 'BL_IWA_Task',
            '/products' =>'BL_IWA_Products', 
            '/users' =>'BL_IWA_Users', 
            '/ns-files-info' =>'BL_IWA_files'
        };
    }
}