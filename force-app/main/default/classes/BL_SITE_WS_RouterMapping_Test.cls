@isTest
public class BL_SITE_WS_RouterMapping_Test  {
    @isTest
   public static void testMethod1(){
        BL_SITE_WS_RouterMapping router = new BL_SITE_WS_RouterMapping();
        Map<String,String> mapRouting = router.routesMapping();
        if(!mapRouting.keySet().isEmpty()){
            String firstelement = new list<string>(mapRouting.keySet())[0];
            router.getCurrentRoute(firstelement);
            router.getCurrentRoute('');
            System.assertEquals(false, maprouting.isEmpty());
        }
        BL_WS_RouteMapping routerInterface = new BL_WS_RouteMapping();
        Map<String,String> mapRouting1 = routerInterface.routesMapping();
    }
}