@isTest
public class BL_IWA_WS_RouterMapping_TEST  {
@isTest
public static void testRouterMapping(){

    BL_IWA_WS_RouterMapping router = new BL_IWA_WS_RouterMapping();
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

public static void testRouterIWA(){  
    
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/iwa/v1'; //Request URL
    RestContext.request = req;
    RestContext.response= res;
    req.requestBody = Blob.valueof('{}');

    Test.startTest(); 

            Test.setMock(HttpCalloutMock.class, new CLT_CalloutMockInstance());
        BL_IWA_WS_Router.doGET();
        BL_IWA_WS_Router.doPOST();
        BL_IWA_WS_Router.doGET();
        BL_IWA_WS_Router.doPATCH();
        BL_IWA_WS_Router.doDELETE();
        BL_IWA_WS_Router.doPUT();

    Test.stopTest();
}

@isTest
public static void testGetClient(){  
    
    Account acc = new Account(LastName = 'test');
    insert acc;
    BL_AppSettings.setAppSettings('iwa');
    BL_IWA_Client blClient = new BL_IWA_Client();
    User u = IC_Test_Common.prepareTestUser('System Administrator');
    u.DefaultStore__c = '1234';
    insert u;
    system.runAs(u) {
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
        insert store;
        blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
        blClient.pathParameters = new Map < String, String > {
            'clientId' => acc.Id
        };
        blClient.queryParams = new Map < String, String > ();
        Test.startTest();
        blClient.executeGET();
        Test.stopTest();
    }
}

@isTest
public static void testSearchClient(){  
    
    Account acc = new Account(LastName = 'test');
    insert acc;
    BL_AppSettings.setAppSettings('iwa');
    BL_IWA_SearchClient blClient = new BL_IWA_SearchClient();
    User u = IC_Test_Common.prepareTestUser('System Administrator');
    u.DefaultStore__c = '1234';
    insert u;
    system.runAs(u) {
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
        insert store;
        blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
        blClient.queryParams = new Map < String, String > {
            'searchterm' => 'test'
        };
        Test.startTest();
        blClient.executeGET();
        Test.stopTest();
    }
}

@isTest
public static void testCreateTask(){  
    
    Test.startTest();
    User u = IC_Test_Common.prepareTestUser('Standard User');
    u.DefaultStore__c = '1234';
    insert u;
    System.runAs(u){ 
        BL_AppSettings.setAppSettings('iwa');
        BL_IWA_Task task = new BL_IWA_Task();
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
        insert store;
       
        Account acc =  new Account(LastName = 'test');
        insert acc;
        
        List<Map<String,Object>> listRecords= new List<Map<String,Object>>();
        listRecords.add(new Map<String,Object>{'subject'=>'Wardrobing','ownerId'=>u.id,'relatedTo'=>acc.id });

        task.requestBody = new Map<String,Object>{'records'=>listRecords};
        task.executePOST();
        Test.stopTest();
    }
       
}


@isTest
public static void testGetConfig(){  

    Store__c store = new Store__c(Name = 'test', RetailStoreId__c = '123' ,status__c='open' ,management_zone_level_tech__c='13' ,storecountry__c='FRANCE');
    Country__c country = new Country__c(Name = 'France',iso3code__c = 'FRA',tech_duplicate__c='France' ,iso2code__c ='FR', HasOtherValue__c=false);
    Language2__c language = new Language2__c(Name='FRANCE', Iso2Code__c = 'FR', Iso3Code__c = 'FRA');

    insert new List<SObject> {country ,language};
    CountryLanguage__c countryLang = new CountryLanguage__c(Name = 'France',   Default__c=true,   ATG_Locale__c = 'fra-fr', Salesforce_Locale__c = 'fr_FR' , Country__c =country.Id ,Language__c=language.id);

    insert new List<SObject> {countryLang  ,store};

    

    BL_AppSettings.setAppSettings('iwa');
    BL_IWA_Config config = new BL_IWA_Config();
    Test.startTest(); 
    config.queryParams = new Map<String, String>{'features' => null};       
    config.executeGET();
     
    config.queryParams = new Map<String, String>{'features' => 'sharing-channels'};       
    config.executeGET();
    Test.stopTest();

}



}