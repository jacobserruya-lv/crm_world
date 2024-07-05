@isTest
public with sharing class WRDB_CreateAsset_Controller_TEST {
    

    @testsetup static void setupMethod(){
        Store__c st = LV_TestFactory.createStore('LV TEST STORE ', 'Store', 'A06', 'FRANCE', 'EUR', 'Open');
		
        st.MANAGEMENT_ZONE_LEVEL__c = '15';
        st.MGMT_ZONE_SUB_LEVEL1__c = '31';
        st.MGMT_ZONE_SUB_LEVEL2__c = '18';
        st.MGMT_ZONE_SUB_LEVEL3__c = '70';
        st.MANAGEMENT_ZONE_LEVEL_TECH__c = 'EMEA';
        st.MGMT_ZONE_SUB_LEVEL1_TECH__c  = 'EUROPE NORTH';
        st.StoreCountry__c =  'FRANCE';

		insert st;
        
        WRDB_Asset__c wardrob = new WRDB_Asset__c(
            zone__c = '15',
            country__c = 'france',
            store__c = 'A06',
            Name = 'TEST',
            type__c = 'picture',
            url__c ='http://',
            scope__c = 'icon',
            azureId__c =  '1234',
            relatedSkus__c = '213,234'
        );
        insert wardrob;
    }
   
   @istest static void createAsset() {
    //Store__c st - [SELECT Id FROM Store__c LIMIT 1];
     Test.startTest();
    
        WRDB_CreateAsset_Controller.getManagementZoneLevel();
        WRDB_CreateAsset_Controller.getManagementCountryLevel('15');
        WRDB_CreateAsset_Controller.getManagementStoreLevel('FRANCE');

        Map<String,String>  asset = new  Map<String,String>();
        asset.put('zone','15');
        asset.put('country','FRANCE');
        asset.put('store','A06');
        asset.put('name','Image');
        asset.put('type','picture');
        asset.put('url','http://');
        asset.put('scope','icon');
        asset.put('id','1234');
    
        WRDB_CreateAsset_Controller.createAsset(new List<Map<String,String>>{asset});
           
        Test.stopTest();
    }

    @istest static void createAkamaiHeaders() {
        Test.startTest();
            WRDB_CreateAsset_Controller.createAkamaiHeaders('blabla.png', 'upload');
        Test.stopTest();
    }

    @istest static void createAssetAzure() {
    	Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new CreateIWMockData());
            WRDB_CreateAsset_Controller.createAzureCustomAssetByUrl('blabla');
        Test.stopTest();
    }

    @istest static void createCollectionAzure() {
    	Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new CreateIWMockData());
            WRDB_CreateAsset_Controller.createAzureCollection('{}', null);
        Test.stopTest();
    }

    @istest static void getAllCollections() {
    	Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new GetIWMockData());
            WRDB_CreateAsset_Controller.getAllCollections();
        Test.stopTest();
    }
    
    @istest static void updateAssetAzure() {
    	Test.startTest();
            Test.setMock(HttpCalloutMock.class, new UpdateIWMockData());
            List<Map<String, String>> azureProducts = new List<Map<String, String>>();
            Map<String,String> product = new Map<String,String> {
                'name' => 'test',
                'contentUrl' => 'test',
                'sku' => 'test'
            };
            azureProducts.add(product);
            WRDB_Asset__c asset = [SELECT Name, url__c, type__c, OwnerId, relatedSkus__c, scope__c, azureId__c, gender__c, zone__c, country__c, store__c FROM WRDB_Asset__c LIMIT 1];
            WRDB_CreateAsset_Controller.updateAzureCustomAsset(asset, azureProducts, false);

            Test.setMock(HttpCalloutMock.class, new FailedIWMockData());
            try {
                WRDB_CreateAsset_Controller.updateAzureCustomAsset(asset, azureProducts, true);
            } catch (Exception e) {
                System.debug('Expected error');
            } 
        Test.stopTest();
    }

    @istest static void deleteAssetAzure() {
        Test.setMock(HttpCalloutMock.class, new DeleteIWMockData());
        Test.startTest();
            WRDB_CreateAsset_Controller.deleteAzureCustomAsset('1234');
        Test.stopTest();
        Test.setMock(HttpCalloutMock.class, new DeleteMassIWMockData());
        WRDB_CreateAsset_Controller.deleteAzureCustomAssets(new List<String>{'1234'}, false);
    }

    @istest static void deleteAssetAzureFailed() {
        try {
            Test.setMock(HttpCalloutMock.class, new FailedIWMockData());
            WRDB_CreateAsset_Controller.deleteAzureCustomAssets(new List<String>{'1234'}, true);
        } catch (Exception e) {
            System.debug('Expected error');
        } 
    }

    @istest static void deleteAsset() {
        Test.setMock(HttpCalloutMock.class, new DeleteMassIWMockData());
        WRDB_Asset__c wardrob = [SELECT Id FROM WRDB_Asset__c LIMIT 1];

        User adminUser = createUserProfile('System Administrator');
        User corporateUser = createUserProfile('ICON_Corporate');
        User saManagerUser = createUserProfile('ICON_SA Manager');

        System.runAs(adminUser) {
            delete wardrob;
        }
       
        System.runAs(corporateUser) {
            try {
                delete wardrob;
            } catch (Exception e) {
                System.debug('Expected error');
            }
        }

        System.runAs(saManagerUser) {
            try {
                delete wardrob;
            } catch (Exception e) {
                System.debug('Expected error');
            }
        }
    }

    
    @istest static void updateAsset() {
        Test.setMock(HttpCalloutMock.class, new UpdateIWMockData());
        //As admin
        WRDB_Asset__c wardrob = [SELECT Id FROM WRDB_Asset__c LIMIT 1];

        User adminUser = createUserProfile('System Administrator');
        User corporateUser = createUserProfile('ICON_Corporate');
        User saManagerUser = createUserProfile('ICON_SA Manager');

        System.runAs(adminUser) {
            update wardrob;
        }

        System.runAs(corporateUser) {
            try {
                update wardrob;
            } catch (Exception e) {
                System.debug('Expected error');
            }
        }

        System.runAs(saManagerUser) {
            try {
                update wardrob;
            } catch (Exception e) {
                System.debug('Expected error');
            }
        }
    }
    
    @istest static void getAssetInfoSettings() {
        WRDB_CreateAsset_Controller.getAssetInfoSettings();
    }

    @istest static void getIsAssetInUserScope() {
        List<WRDB_Asset__c> assets = [SELECT Id, OwnerId FROM WRDB_Asset__c LIMIT 1];
        WRDB_CreateAsset_Controller.getUserScopeAssets(assets);
    }
     
    static User createUserProfile(String profileName) {
        String uniqueUserName = 'user' + DateTime.now().getTime() + '@org.com';
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];

        return new User(
            UserName = uniqueUserName,
            ProfileId = p.Id,
            Alias = 'standt',
            Email = 'user@org.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
    }

    public class CreateIWMockData implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"animals": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}');
            response.setStatusCode(201);
            response.setStatus('Created');
            return response; 
        }
    }
         
    public class DeleteIWMockData implements HttpCalloutMock {
    
     	public HTTPResponse respond(HTTPRequest request) {
        	HttpResponse response = new HttpResponse();
        	response.setHeader('Content-Type', 'application/json');
        	response.setBody('{"animals": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}');
        	response.setStatusCode(200);
        	response.setStatus('OK'); 
        	return response; 
    	}
	}

    public class DeleteMassIWMockData implements HttpCalloutMock {
    
        public HTTPResponse respond(HTTPRequest request) {
           HttpResponse response = new HttpResponse();
           response.setHeader('Content-Type', 'application/json');
           response.setBody('{"animals": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}');
           response.setStatusCode(200);
           response.setStatus('Created'); 
           return response; 
       }
    }

    public class UpdateIWMockData implements HttpCalloutMock {
    
        public HTTPResponse respond(HTTPRequest request) {
           HttpResponse response = new HttpResponse();
           response.setHeader('Content-Type', 'application/json');
           response.setBody('{"animals": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}');
           response.setStatusCode(200);
           response.setStatus('OK');
           return response; 
       }
    }

    public class FailedIWMockData implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
           HttpResponse response = new HttpResponse();
           response.setHeader('Content-Type', 'application/json');
           response.setBody('{"animals": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}');
           response.setStatusCode(400);
           response.setStatus('Bad Request');
           return response; 
       }
    }

    public class GetIWMockData implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
           HttpResponse response = new HttpResponse();
           response.setHeader('Content-Type', 'application/json');
           response.setStatusCode(200);
           response.setStatus('OK');
           return response; 
       }
    }
}