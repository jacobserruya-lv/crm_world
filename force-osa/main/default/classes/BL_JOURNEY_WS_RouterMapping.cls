public class BL_JOURNEY_WS_RouterMapping extends BL_WS_RouteMapping {

    public override Map < String,String > routesMapping() {
        return new Map < String,String > {
           '/appointments' => 'BL_JOURNEY_Appointment'
        };
    } 

}