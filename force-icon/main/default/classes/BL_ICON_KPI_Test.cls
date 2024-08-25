/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-18-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-12-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class BL_ICON_KPI_Test {
    @isTest 
    static void testMethodGet(){
        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_KPI blKPI = new BL_ICON_KPI();
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = '1234';
        insert u;
        Account acc =  new Account(LastName = 'test',Ind_10K__c = '10k',indic_10K_rank__c = '10k YTM');
        insert acc;
        Event ev= IC_TestFactory.createEvent(acc);
        ev.OwnerId = u.id;
        ev.StartDateTime = Date.today().addDays(-1);
        insert ev;
        Task tsk= IC_TestFactory.createTask();
        tsk.OwnerId = u.id;
        tsk.ActionType__c = 'Email';
        tsk.RecordTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('DREAMContact').getRecordTypeId();
        insert tsk;
        PPR_PurchProduct__c p = IC_TestFactory.createPurchaseProduct(acc.id);
        insert p;
        system.runAs(u){
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            blKPI.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            blKPI.queryParams = new Map<String, String>{'filters' => 'me','features' =>'purchasesProduct'};
            Test.startTest();        
              blKPI.executeGET();
              blKPI.queryParams = new Map<String, String>{'filters' => 'me','features' =>'tasksCount'};	
              blKPI.executeGET();
              blKPI.queryParams = new Map<String, String>{'filters' => 'me','features' =>'appointementsCount'};	
              blKPI.executeGET();
              blKPI.queryParams = new Map<String, String>{'filters' => 'me','features' =>'appointementsWithPurchaseCount'};	
              blKPI.executeGET();
              blKPI.queryParams = new Map<String, String>{'filters' => 'me','features' =>'wardrobingOutreach'};	
              blKPI.executeGET();
              blKPI.queryParams = new Map<String, String>{'filters' => 'me','features' =>'currency'};	
              blKPI.executeGET();
              blKPI.queryParams = new Map<String, String>{'filters' => 'me','features' =>'my10K'};	
              blKPI.executeGET();
              blKPI.queryParams = new Map<String, String>{'filters' => 'me','features' =>'myPotential10K'};	
              blKPI.executeGET();
              blKPI.queryParams = new Map<String, String>{'filters' => 'me','features' =>'myConfirmed10K'};	
              blKPI.executeGET();
              blKPI.queryParams = new Map<String, String>{'filters' => 'me','features' =>'outreaches'};	
              blKPI.executeGET();
              blKPI.queryParams = new Map<String, String>{'filters' => 'me','features' =>'appointements'};	
              blKPI.executeGET();
              blKPI.queryParams = new Map<String, String>{'filters' => 'me','features' =>'purchasesProduct'};
              blKPI.executeGET();
              blKPI.queryParams = new Map<String, String>{'filters' => 'me','features' => '' };
              blKPI.executeGET();
              

              blKPI.queryParams = new Map<String, String>{'filters' => 'me' };
              blKPI.path = '/kpi/count';
              blKPI.executeGET();
             


            Test.stopTest();
        }
      
    }
/*    static void testMethodGet2(){


        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_KPI blKPI = new BL_ICON_KPI();
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = '1234';
        insert u;
        Account acc =  new Account(LastName = 'test',Ind_10K__c = '10k',indic_10K_rank__c = '10k YTM');
        insert acc;
        Event ev= IC_TestFactory.createEvent(acc);
        ev.OwnerId = u.id;
        ev.StartDateTime = Date.today().addDays(-1);
        insert ev;
        
        //tsk.RecordTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('t').getRecordTypeId();
        PPR_PurchProduct__c p = IC_TestFactory.createPurchaseProduct(acc.id);
        insert p;
        system.runAs(u){
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;

            Task tsk= IC_TestFactory.createTask();
            tsk.WhatId = acc.id ;
            tsk.OwnerId = u.id;
            tsk.ActionType__c = 'Email'; 
            tsk.Store_Location__c = store.Id;

            insert tsk;
            blKPI.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            Test.startTest();        
             
              blKPI.isStandardRestApiRequired = true;
              blKPI.queryParams = new Map<String, String>{'filters' => 'me' ,'period' => 'week' ,'storeId' => '1234'};
              blKPI.executeGET();

              
            
            Test.stopTest();
        }

    }*/

    

}