@IsTest
public class BL_ICON_RecentlyViewed_Test {
     @IsTest static void testExecuteGet() {
        try{
            Test.startTest();
            User u = IC_Test_Common.prepareTestUser('ICON_LV Administrator');
       	    u.DefaultStore__c = '1234';
             insert u;               
            BL_AppSettings.setAppSettings('Wechat');
            BL_ICON_RecentlyViewed look = new BL_ICON_RecentlyViewed();
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            look.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            BL_WS_QueryMergeFields.init(look.me.userMergeFields);
            look.pathParameters = new Map<String, String>{'objectName' =>null};
            look.executeGET();
            look.pathParameters = new Map<String, String>{'objectName' =>'clients'};
                look.executeGET();
            look.pathParameters = new Map<String, String>{'objectName' =>'care-services'};
                look.executeGET();
            look.pathParameters = new Map<String, String>{'objectName' =>'events'};
                look.executeGET();
            look.pathParameters = new Map<String, String>{'objectName' =>'look-shares'};
                look.executeGET();
            look.pathParameters = new Map<String, String>{'objectName' =>'purchase-products'};
                look.executeGET();
            Test.stopTest();
            
        }
        catch (Exception ex){
            
        }     
    }
}