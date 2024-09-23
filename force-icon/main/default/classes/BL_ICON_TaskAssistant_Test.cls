@isTest
public class BL_ICON_TaskAssistant_Test {
    @isTest
    static void testMethodPost() {
		List<Object> records = new List<Object>();
        List<Task> tasks = new List<Task>();
        Account acc =  new Account(LastName = 'test', DREAMID__c = '98765439');
        insert acc;
       
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = 'A06';
        u.WWEmployeeNumber__c = '246812345';
		insert u;
		Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
		insert store;
		TaskAssistant__c task = new TaskAssistant__c(DreamId__c = acc.DREAMID__c, ToDoType__c = 'first rtw purchase', WWEmployeeNumber__c = u.WWEmployeeNumber__c, DueDate__c = Date.today().addDays(-1), StoreCode__c = u.DefaultStore__c);
		insert task;

        Test.startTest();
        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_TaskAssistant blTasks = new BL_ICON_TaskAssistant();
		blTasks.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
		blTasks.pathParameters = new Map < String, String > {};
		blTasks.requestBody = new Map < String, Object > {
			'caId' => u.id
		};
		blTasks.executePOST();
		Test.stopTest();
	}

    @isTest
    static void testMethodPUT(){
        List<TaskAssistant__c> tasks = new List<TaskAssistant__c>();
        List<Map<String,Object>> tasksMap = new List<Map<String,Object>> ();

        Account acc =  new Account(LastName = 'test', DREAMID__c = '98765439');
        insert acc;
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06');
        insert store;
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.WWEmployeeNumber__c = '246812345';
        insert u;
       
        system.runAs(u){

        Test.startTest();  
        for(integer i = 0 ; i < 2; i++){
            tasks.add(new TaskAssistant__c(DreamId__c = acc.DREAMID__c, ToDoType__c= 'first rtw purchase',  StoreCode__c = 'A06', DueDate__c = Date.today().addDays(-1), IsArchieved__c = false , IsCompleted__c = false, WWEmployeeNumber__c = '246812345'));
		}
        insert tasks;

        for(TaskAssistant__c t:[ SELECT Client__c, Id, Store__c, IsCompleted__c, IsArchieved__c FROM TaskAssistant__c ]){
            Map<String, Object> taskToUpdate = new Map<String, Object> {
				'client' => t.id,
				'caId' => u.id
			};
            tasksMap.add(taskToUpdate) ;  
        } 

        

        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_TaskAssistant blTodos = new BL_ICON_TaskAssistant();

        blTodos.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
        blTodos.me.basicInfos.Id = u.id;               
        blTodos.requestBody = new Map<String,Object>();
        blTodos.requestBody.put('records',tasksMap);

        blTodos.executePUT();

        Test.stopTest();
        }    
    }
}