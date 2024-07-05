@IsTest
public class BL_ICON_Task_Test {
    
     @IsTest static void testExecuteGet() {
        try{
            Test.startTest();
            User u = IC_Test_Common.prepareTestUser('System Administrator');
       	    u.DefaultStore__c = '1234';
             insert u;
            System.runAs(u){ 
                BL_AppSettings.setAppSettings('Wechat');
                BL_ICON_Task task = new BL_ICON_Task();
                Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            	insert store;
            	task.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            	BL_WS_QueryMergeFields.init(task.me.userMergeFields);
                task.pathParameters = new Map<String, String>{'taskId' =>null};
                task.queryParams = new Map<String, String>();
                task.executeGET();
                Test.stopTest();
            }
        }
        catch (Exception ex){
            
        }     
    }
      @IsTest static void testExecuteGetById() {
        try{
            Test.startTest();
            User u = IC_Test_Common.prepareTestUser('System Administrator');
       	    u.DefaultStore__c = '1234';
             insert u;
            System.runAs(u){ 
                List<RecordType> listrecord = [SELECT Id FROM RecordType WHERE Name = 'To Do'];
                Task tsk= IC_TestFactory.createTask('Email',listrecord.get(0).id,System.today().addDays(-10));
                insert tsk;
                BL_AppSettings.setAppSettings('Wechat');
                BL_ICON_Task task = new BL_ICON_Task();
                Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            	insert store;
            	task.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            	BL_WS_QueryMergeFields.init(task.me.userMergeFields); 
                task.pathParameters = new Map<String, String>{'taskId' =>tsk.id};
                task.queryParams = new Map<String, String>();
                task.recordId = tsk.Id;
                task.executeGET();
                Test.stopTest();
            }
        }
        catch (Exception ex){
            
        }     
    }
    
   /*@IsTest static void testExecutePOST(){
        try{
            Test.startTest();
            User u = IC_Test_Common.prepareTestUser('Standard User');
       	    u.DefaultStore__c = '1234';
             insert u;
            System.runAs(u){ 
                BL_AppSettings.setAppSettings('Wechat');
                BL_ICON_Task task = new BL_ICON_Task();
                Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            	insert store;
            	task.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            	BL_WS_QueryMergeFields.init(task.me.userMergeFields);   
                Account acc =  new Account(LastName = 'test');
        		insert acc;
                string s = ' "records": [{"ownerId" : "'+u.id+'","subject": "Voice Local Sales - Neutral - Store Action Done","relatedTo" : "'+acc.id+'","activityDate" : "2020-07-10"}]';
                List<Map<String,Object>> listRecords= new List<Map<String,Object>>();
                listRecords.add(new Map<String,Object>{'subject'=>'Voice Local Sales - Neutral - Store Action Done','ownerId'=>u.id,'relatedTo'=>acc.id,'activityDate'=>'2020-07-10'});
                task.requestBody = new Map<String,Object>{'records'=>listRecords};
                task.executePOST();
                Test.stopTest();
            }
        }
        catch (Exception ex){
            
        }
        
    }*/
    
     @IsTest static void testExecuteDELETETask(){
       Test.startTest();
            User u = IC_Test_Common.prepareTestUser('System Administrator');
       	    u.DefaultStore__c = '1234';
             insert u;
            System.runAs(u){ 
                List<RecordType> listrecord = [SELECT Id FROM RecordType WHERE Name = 'To Do'];
                Task tsk= IC_TestFactory.createTask('Email',listrecord.get(0).id,System.today().addDays(-10));
                insert tsk;
                BL_AppSettings.setAppSettings('Wechat');
                BL_ICON_Task task = new BL_ICON_Task();
                Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            	insert store;
            	task.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            	BL_WS_QueryMergeFields.init(task.me.userMergeFields); 
                task.pathParameters = new Map<String, String>{'taskId' => tsk.Id};
                task.requestBody = new Map <String, Object>();
                task.executeDELETE();
            Test.stopTest();
        }
        
    }
    @IsTest static void testExecuteDELETETasks(){
       Test.startTest();
            User u = IC_Test_Common.prepareTestUser('System Administrator');
       	    u.DefaultStore__c = '1234';
             insert u;
            System.runAs(u){ 
                List<RecordType> listrecord = [SELECT Id FROM RecordType WHERE Name = 'To Do'];
                Task tsk= IC_TestFactory.createTask('Email',listrecord.get(0).id,System.today().addDays(-10));
                BL_AppSettings.setAppSettings('Wechat');
                BL_ICON_Task task = new BL_ICON_Task();
                Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            	insert store;
            	task.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            	BL_WS_QueryMergeFields.init(task.me.userMergeFields); 
            	string s = '{	"records" :[{	"id": "'+ tsk.Id +'"}  ]}';
            	task.pathParameters = new Map<String, String>{'taskId' => null};
                task.requestBody = (Map < String, Object >) JSON.deserializeUntyped(s);
            	task.executeDELETE();
            	Test.stopTest();
        }
        
    }
    
   @IsTest static void testExecutePATCH(){
        try{
            Test.startTest();
            User u = IC_Test_Common.prepareTestUser('Standard User');
       	    u.DefaultStore__c = '1234';
             insert u;
            System.runAs(u){ 
            List<RecordType> listrecord = [SELECT Id FROM RecordType WHERE Name = 'To Do'];
            Task tsk= IC_TestFactory.createTask('Email',listrecord.get(0).id,System.today().addDays(-10));
            BL_AppSettings.setAppSettings('Wechat');
            BL_ICON_Task task = new BL_ICON_Task();
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            task.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            BL_WS_QueryMergeFields.init(task.me.userMergeFields); 
            Account acc = IC_TestFactory.createAccount();
            insert acc;
            string s = ' "records": [{"subject": "Voice Local Sales - Neutral - Store Action Done","relatedTo" : "'+acc.id+'","activityDate" : "2020-07-10"}]';
            List<Map<String,Object>> listRecords= new List<Map<String,Object>>();
            listRecords.add(new Map<String,Object>{'subject'=>'Voice Local Sales - Neutral - Store Action Done','ownerId'=>u.id,'relatedTo'=>acc.id,'activityDate'=>'2020-07-10'});
            task.requestBody = new Map<String,Object>{'records'=>listRecords};
            task.pathParameters = new Map<String, String>{'taskId' => null};
            task.executePATCH();
            task.pathParameters = new Map<String, String>{'taskId' => tsk.id};
            task.executePATCH();
            Test.stopTest();
            }
        }
        catch (Exception ex){
            
        }
        
    }
    @IsTest static void testExecuteHelper(){
        try{
            Test.startTest();
            User u = IC_Test_Common.prepareTestUser('Standard User');
       	    u.DefaultStore__c = '1234';
            insert u;
            List<RecordType> listrecord = [SELECT Id FROM RecordType WHERE Name = 'To Do'];
            Task tsk= IC_TestFactory.createTask('Email',listrecord.get(0).id,System.today().addDays(-10));
            BL_AppSettings.setAppSettings('Wechat');
     		BL_ICON_Task_Helper.getQueryIdCondition(new List<Task>{tsk});
            Test.stopTest();
       }
      catch (Exception ex){}
    }
       @IsTest static void testExecutePUT(){
        try{
            Test.startTest();
            User u = IC_Test_Common.prepareTestUser('Standard User');
       	    u.DefaultStore__c = '1234';
             insert u;
            System.runAs(u){ 
            List<RecordType> listrecord = [SELECT Id FROM RecordType WHERE Name = 'To Do'];
            Task tsk= IC_TestFactory.createTask('Email',listrecord.get(0).id,System.today().addDays(-10));
            BL_AppSettings.setAppSettings('Wechat');
            BL_ICON_Task task = new BL_ICON_Task();
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            task.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            BL_WS_QueryMergeFields.init(task.me.userMergeFields); 
            Account acc = IC_TestFactory.createAccount();
            insert acc;
            string s = ' "records": [{"subject": "Voice Local Sales - Neutral - Store Action Done","relatedTo" : "'+acc.id+'","activityDate" : "2020-07-10"}]';
            
            List<Map<String,Object>> listRecords= new List<Map<String,Object>>();
            listRecords.add(new Map<String,Object>{'subject'=>'Voice Local Sales - Neutral - Store Action Done','ownerId'=>u.id,'relatedTo'=>acc.id,'activityDate'=>'2020-07-10'});
            task.requestBody = new Map<String,Object>{'records'=>listRecords};
            task.pathParameters = new Map<String, String>{'taskId' => null};
            task.executePUT();
            task.pathParameters = new Map<String, String>{'taskId' => tsk.id};
            task.executePUT();
            Test.stopTest();
            }
        }
        catch (Exception ex){
            
        }
        
    }

}