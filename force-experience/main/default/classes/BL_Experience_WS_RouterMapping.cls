public class BL_Experience_WS_RouterMapping extends BL_WS_RouteMapping {
    public override Map < String,String > routesMapping() {
        return new Map < String,String > {
            '/experiences/{clubname}' => 'BL_Experience',
            '/experiences/members/{id}' => 'BL_Experience',
            '/badges/{clubname}' => 'BL_Experience', 
            '/experience-variations' => 'BL_Experience_Variation',
            '/experience-variations/{id}' => 'BL_Experience_Variation',
            '/experience-variations/{id}/members' => 'BL_Experience_Variation',
            '/experience-variations/members/{id}' => 'BL_Experience_Variation',
            '/experience-variations/{id}/evites' => 'BL_Experience_Variation',
            '/experience-variations/{id}/kpi' => 'BL_Experience_Variation',
            '/experience-variations/members/{id}/guests' => 'BL_Experience_Variation',
            '/experience-variations/members/{id}/save' => 'BL_Experience_Variation'
        };
    }
}