@isTest
public class BL_ICON_Me_Test {
   @isTest 
    static void testExecuteGET(){
        BL_AppSettings.setAppSettings('Clienteling');
        BL_ICON_Me test = new BL_ICON_Me();
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = '1234';
        insert u;
        system.runAs(u){
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            test.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            BL_WS_QueryMergeFields.init(test.me.userMergeFields);
     	   test.executeGET();
        }
    }
}