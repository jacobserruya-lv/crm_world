@IsTest
public class BL_ICON_Look_Test {
     @IsTest static void testExecuteGet() {
        try{
            Test.startTest();
            User u = IC_Test_Common.prepareTestUser('System Administrator');
       	    u.DefaultStore__c = '1234';
             insert u;
            System.runAs(u){                
                BL_AppSettings.setAppSettings('Wechat');
                BL_ICON_Look look = new BL_ICON_Look();
                Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            	insert store;
            	look.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            	BL_WS_QueryMergeFields.init(look.me.userMergeFields);
                Look__c l = new Look__c(Name = 'MY COFFRET 8 MONTRES MONOGRAM ECLIPSE  Look', store__c = store.id, ownerId = u.id, SKUs__c = 'P00957;');
            	insert l;
                look.pathParameters = new Map<String, String>{'lookId' =>l.id};
                look.queryParams = new Map<String, String>();
                look.executeGET();
                look.pathParameters = new Map<String, String>{'lookId' =>null};
                look.executeGET();
                Test.stopTest();
            }
        }
        catch (Exception ex){
            
        }     
    }
     @IsTest static void testExecutePost() {
        try{
            Test.startTest();
            User u = IC_Test_Common.prepareTestUser('System Administrator');
       	    u.DefaultStore__c = '1234';
             insert u;
            System.runAs(u){                
                BL_AppSettings.setAppSettings('Wechat');
                BL_ICON_Look look = new BL_ICON_Look();
                Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            	insert store;
            	look.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            	BL_WS_QueryMergeFields.init(look.me.userMergeFields);
                Look__c l = new Look__c(Name = 'MY COFFRET 8 MONTRES MONOGRAM ECLIPSE  Look', store__c = store.id, ownerId = u.id, SKUs__c = 'P00957;');
            	insert l;
                Account acc =  new Account(LastName = 'test');
        		insert acc;
                look.pathParameters = new Map<String, String>{'lookId' =>l.id};
                look.queryParams = new Map<String, String>();
                string s = ' "records": [{"ownerId" : "'+u.id+'","channel": "A06","clientId" : "'+acc.id+'","lookId" : "'+l.id+'"}]';
                look.requestBody = new Map<String,Object>();
                look.requestBody.put('channel','A06');
                look.requestBody.put('ownerId',u.id);
                look.requestBody.put('clientId',acc.id);
                look.requestBody.put('lookId',l.id);
                look.path = '/looks/share';
                look.executePOST();
                Test.stopTest();
            }
        }
        catch (Exception ex){
            
        }     
    }
}