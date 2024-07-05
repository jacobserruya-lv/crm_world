@isTest
public class BL_ICON_Config_Test {
        
    @isTest
    static void testGetTranslations(){
        BL_AppSettings.setAppSettings('Clienteling');
        BL_ICON_Config config = new BL_ICON_Config();
        config.queryParams = new Map<String, String>{'features' =>'translations'};
        Test.startTest();        
        config.executeGET();
        Test.stopTest();
    }  
    
    @isTest
    static void testGetPicklists(){
        BL_AppSettings.setAppSettings('Clienteling');
        BL_ICON_Config config = new BL_ICON_Config();
        config.queryParams = new Map<String, String>{'features' =>'picklists'};
        Test.startTest();        
        config.executeGET();
        Test.stopTest();
    } 
    
    @isTest
    static void testGetEmailTemplates(){
        BL_AppSettings.setAppSettings('Clienteling'); 
        BL_ICON_Config config = new BL_ICON_Config();
        config.queryParams = new Map<String, String>{'features' =>'emailTemplatesFields'};
        Test.startTest();        
        config.executeGET();
        Test.stopTest();
    } 
    
  
    @isTest
    static void testGetAppSettings(){
        BL_AppSettings.setAppSettings('Clienteling');
        BL_ICON_Config config = new BL_ICON_Config();
        config.queryParams = new Map<String, String>{'features' =>'app-settings'};
        Test.startTest();        
        config.executeGET();
        Test.stopTest();
    }
    
    @isTest
    static void testDashboards(){
        BL_AppSettings.setAppSettings('Clienteling');
        BL_ICON_Config config = new BL_ICON_Config();
        config.queryParams = new Map<String, String>{'features' =>'dashboards'};
        Test.startTest();        
        config.executeGET();
        Test.stopTest();
    } 
    
    @isTest
    static void testGetAll(){
        BL_AppSettings.setAppSettings('Clienteling');
        BL_ICON_Config config = new BL_ICON_Config();
        config.queryParams = new Map<String, String>{'features' => null};
        Test.startTest();        
        config.executeGET();
        Test.stopTest();
    }     
    

}