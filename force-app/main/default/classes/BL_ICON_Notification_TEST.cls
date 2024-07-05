@isTest
public class BL_ICON_Notification_TEST {
    
    static void createTestData() {
        
        List<Push_Notification_Item__c> listPush  = new  List<Push_Notification_Item__c>();

        Account acc =  IC_TestFactory.createAccount();
        insert acc;
        Case request = IC_TestFactory.createCase(acc);
        insert request ; 
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = '1234';
        u.WWEmployeeNumber__c = 'WW198765467';
        insert u;
        
        Integer counter = 0 ;
        while(counter <= 11){
            listPush.add(new Push_Notification_Item__c(UserRecipient__c  = u.id ,body__c = 'test Notification',ObjectId__c = request.id,Type__c = 'Request'));
            counter++; 
        }
        
        //Test.startTest();
  		insert listPush;
        //Test.stopTest();
        
    }
    
	@isTest
    static void testGetNotification(){
        createTestData();
        //AsyncSendNotification.splitAndSendNotification();
      
        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_Notification blNotification = new BL_ICON_Notification();
        
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467'];
        system.runAs(u){
            
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            blNotification.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blNotification.queryParams = new Map<String, String>();
           
           
            Test.startTest();
            	blNotification.requestBody = new Map<String,Object>{}; 
                blNotification.pathParameters = new Map<String, String>{};
                blNotification.executeGET();
            Test.stopTest();
        }

    }
    
    @isTest
    static void testPatchNotification(){
      
        createTestData();
        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_Notification blNotification = new BL_ICON_Notification();
        
        User u = [SELECT id ,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765467' limit 1];
        id userId = u.id ;
        Push_Notification_Item__c p = [SELECT id FROM Push_Notification_Item__c WHERE UserRecipient__c=: userId limit 1 ];
       
        system.runAs(u){
            
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = '1234');
            insert store;
            blNotification.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blNotification.queryParams = new Map<String, String>();
           
			String key = p.id+''+ userId;
           
            Map<String,Object> push = new Map<String,Object>{'isRead'=> true , 'exKey' =>key };
            Test.startTest();
            
            	blNotification.requestBody =  new Map<String,Object>{'records'=>new List<Object>{push}};
                blNotification.executePATCH();
            Test.stopTest();
        }

    }

}