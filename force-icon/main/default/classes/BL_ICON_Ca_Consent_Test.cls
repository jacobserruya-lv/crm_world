@isTest
public class BL_ICON_Ca_Consent_Test {
    
    @isTest
    static void testGetConsent(){
        BL_AppSettings.setAppSettings('Icon');
        User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {

			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
            BL_ICON_Ca_Consent config = new BL_ICON_Ca_Consent();
            config.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();

            config.queryParams = new Map < String, String > ();

            Test.startTest();        
            config.executeGET();
            Test.stopTest();
        }
    }  

    @isTest
    static void testPostConsent(){
        BL_AppSettings.setAppSettings('Icon');
        User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
            BL_ICON_Ca_Consent config = new BL_ICON_Ca_Consent();
            config.requestBody = new Map<String, Object> {'consent'=>'true','user'=> System.UserInfo.getUserId()};
            Test.startTest();        
            config.executePOST();

            Id consentId = [SELECT ID FROM Ca_Consent__c LIMIT 1]?.id;
            config.pathParameters = new Map<String, String> {'id'=> consentId  };
            config.requestBody = new Map<String, Object> {'consent'=>'false','id'=> consentId  };
            config.executePUT();

            Test.stopTest();
        }

    }  
}