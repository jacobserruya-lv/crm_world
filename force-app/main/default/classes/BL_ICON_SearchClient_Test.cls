@isTest
public class BL_ICON_SearchClient_Test {

    @TestSetup
    static void createTestData() {
        
    
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = 'A06';
        u.WWEmployeeNumber__c = 'WW198765467';
        u.Country__c = 'Los Angeles';

        insert u;

        Map<String, RecordType> recordTypeByDevMap = SO_UTIL.retRecordTypeByDevMap(new Set<String>{'ACC_PersonAccount'});
        RecordType personAccRT = IC_Test_Common.GetPersonAccountRT();

        Account account = new Account(LastName = 'LEE', OwnerId = u.id,AttachedStore__pc = u.DefaultStore__c, PrimaryCountry__pc = u.Country__c, FirstName = 'JOY');
        account.recordType = personAccRT;
        insert account;

        Account acc2 = new Account(LastName = 'LEE2', OwnerId = u.id,AttachedStore__pc = u.DefaultStore__c, PrimaryCountry__pc = u.Country__c, FirstName = 'JOY2');
        insert acc2;
        Tag__c tag = new Tag__c(client__c = acc2.id, ownerId = u.id, Value_MP__c='Test');
        insert tag;

    }


     @isTest static void getSearchClientWECHAT() {
        Id [] fixedResults = new Id[2];
        Account account = [SELECT id ,LastName FROM Account  LIMIT 1];
        Tag__c tag = [SELECT id from Tag__c LIMIT 1];
        fixedResults[0]= account.Id;
        fixedResults[1]= tag.Id;
        Test.setFixedSearchResults(fixedResults);

        BL_WS_Router.clientPlatform = 'WECHAT';

        BL_AppSettings.setAppSettings('Clienteling');
        BL_ICON_SearchClient client = new BL_ICON_SearchClient();
        User u = [SELECT id,DefaultStore__c FROM user WHERE WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            client.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();

            client.recordId = account.Id;
            client.queryParams = new Map<String, String>{'searchterm'=>'LEE', 'filters' => 'myStore;myCountry;attachedToMe'};
       		
            client.executeGET();
        }
     }
     @isTest static void getSearchClientByTagWECHAT() {
        Id [] fixedResults = new Id[1];
        Account account = [SELECT id ,LastName FROM Account  LIMIT 1];
        fixedResults[0]= account.Id;
        Test.setFixedSearchResults(fixedResults);

        BL_WS_Router.clientPlatform = 'WECHAT';

        BL_AppSettings.setAppSettings('Clienteling');
        BL_ICON_SearchClient client = new BL_ICON_SearchClient();
        User u = [SELECT id,DefaultStore__c FROM user WHERE WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            client.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();

            client.recordId = account.Id;
            client.queryParams = new Map<String, String>{'searchterm'=>'balck', 'filters' => 'tag'};
       		
            client.executeGET();
        }
     }

     @isTest static void getSearchClient() {
        Id [] fixedResults = new Id[1];
        Account account = [SELECT id ,LastName FROM Account  LIMIT 1];
        fixedResults[0]= account.Id;
        Test.setFixedSearchResults(fixedResults);


        BL_AppSettings.setAppSettings('Clienteling');
        BL_ICON_SearchClient client = new BL_ICON_SearchClient();
        User u = [SELECT id,DefaultStore__c FROM user WHERE WWEmployeeNumber__c = 'WW198765467'];

        system.runAs(u){
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            client.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();

            client.recordId = account.Id;
            client.queryParams = new Map<String, String>{'searchterm'=>'LEE', 'filters' => 'myStore;myCountry;attachedToMe'};
       		
            client.executeGET();
        }
     }

}