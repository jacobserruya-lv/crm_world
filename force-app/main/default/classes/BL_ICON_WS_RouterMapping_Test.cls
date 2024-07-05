/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-07-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-07-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class BL_ICON_WS_RouterMapping_Test  {
    
    @isTest
   public static void testMethod1(){  
    /*
        BL_ICON_WS_Router route = new BL_ICON_WS_Router();
       	BL_ICON_WS_Router.doPOST();
       	BL_ICON_WS_Router.doPUT();
       	BL_ICON_WS_Router.doGET();
       	BL_ICON_WS_Router.doPATCH();
       	BL_ICON_WS_Router.doDELETE();
		BL_WS_Interfaces.RouterMapping routesMappingClass = (BL_WS_Interfaces.RouterMapping)Type.forName(routesMappingClassName).newInstance();
	*/  
      
       
      BL_ICON_WS_RouterMapping router = new BL_ICON_WS_RouterMapping();
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