/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-06-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-27-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class BL_ICON_Todos_Test {
    @isTest
    static void testMethodGet(){
     
            List<Object> records = new List<Object>();
            List<Task> tasks = new List<Task>();
            Account acc =  new Account(LastName = 'test');
            insert acc;
            BL_AppSettings.setAppSettings('Icon');
            BL_ICON_Todos blTodos = new BL_ICON_Todos();
            User u = IC_Test_Common.prepareTestUser('System Administrator');
        	u.DefaultStore__c = 'A06';
            insert u;
            system.runAs(u){
                Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06');
                insert store;
                
                blTodos.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
                CareService__c c = new CareService__c(Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c,MessageToCA__c='Quotation to validate',IsToDo__c=true,CA__c=u.id);
                insert c;
                Case ca = new Case(AccountId = acc.id, store__c = store.id,OwnerId=u.id,status='New',CA_Name__c=u.id,Resolution__c='Request to Store');
                insert ca;
                Test.startTest();   
                blTodos.queryParams = new Map<String, String>();
                blTodos.queryParams.put('pageIndex',null);
                blTodos.queryParams.put('pageSize',null);
                blTodos.executeGET();
                Test.stopTest();
            }
    }

    @isTest
    static void testMethodPUT(){

        Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');
        Account acc =  new Account(LastName = 'test');
        insert acc;
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06');
        insert store;
        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_Todos blTodos = new BL_ICON_Todos();
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        insert u;
        blTodos.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
        blTodos.me.basicInfos.Id = u.id;

            system.runAs(u){
        CareService__c c = new CareService__c(Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c,MessageToCA__c='Quotation to validate',IsToDo__c=false,CA__c=u.id);
        insert c;
        c.IsToDo__c = true;
        update c;

        
        Case ca = new Case(AccountId = acc.id, store__c = store.id,OwnerId=blTodos.me.basicInfos.Id,status='New',CA_Name__c=u.id,Resolution__c='Reply Made');
        insert ca;
        ca.Resolution__c = 'Request to Store';
        update ca;

      
        VO_Survey__c vo = new VO_Survey__c(ClientDreamID__c=acc.Id,AnswerDate__c=date.today(),Type__c='Neutral' ,Store__c = store.id,OwnerId = u.id);
        insert vo;
        vo.Type__c = 'Promoter';
        update vo;

     

        Test.startTest();  
        List<Task> taskList= [SELECT id,Status,Subject, Assignment__c ,AccountId,WhatId, WhoId,   OwnerId,Owner.Name ,format(CreatedDate),To_do_type__c 
                       FROM Task   
                       WHERE  WhatId=:vo.id OR  WhatId=:ca.id OR WhatId=:c.id];
        List<Map < String, Object >> taskId= new List<Map < String, Object >>();

        for(Task t:taskList){
           Map < String, Object > taskToUpdate = new Map < String, Object > {
				'client' => t.id,
				'status' => 'completed',
				'caId' => u.id
				
			};
             taskId.add(taskToUpdate) ;  
        }
		BL_ICON_Todos_Helper.updateStatusIsBadged(1,taskList);
        BL_ICON_Todos_Helper.createBadges(1,u.id);

                
        blTodos.requestBody = new Map<String,Object>();
        blTodos.requestBody.put('records',taskId);

        blTodos.queryParams = new Map<String, String>();
        blTodos.queryParams.put('status',null);

        blTodos.executePUT();

        Test.stopTest();
    }
   


    }
}