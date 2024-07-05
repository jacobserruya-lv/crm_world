public class BL_SITE_WS_RouterMapping extends BL_WS_RouteMapping {

    public override Map < String,String > routesMapping() {
        return new Map < String,String > {
            '/translation' => 'BL_SITE_Translation'
        };
    }
}