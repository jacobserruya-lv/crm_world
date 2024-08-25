@isTest
public class BL_ICON_BatchCareServiceStatusTask_TEST {
    static testMethod void  BL_ICON_BatchCareServiceStatusTask_TEST(){
        User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        testUser.BypassWF__c = true;
        testUser.BypassVR__c = true;
        testUser.Country__c = 'FRANCE';
        insert testUser;
        
        Account acc =  new Account(LastName = 'test');
        insert acc;
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        insert u;
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06');
        insert store;
        Id recordTypeId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('StoreCareService').getRecordTypeId();

        System.runAs(testUser){
        CareService__c c1 = new CareService__c(Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c,IsToDo__c=true,CA__c=u.id, MyRepairStatus__c = 'repairInProgress' ,RecordTypeId =recordTypeId );
        CareService__c c2 = new CareService__c(Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c,IsToDo__c=true,CA__c=u.id, MyRepairStatus__c = 'repairInProgress' ,RecordTypeId =recordTypeId);
		CareService__c c3 = new CareService__c(Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c,IsToDo__c=true,CA__c=u.id, MyRepairStatus__c = 'repairInProgress' ,RecordTypeId =recordTypeId );
		CareService__c c4 = new CareService__c(Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c,IsToDo__c=true,CA__c=u.id, MyRepairStatus__c = 'repairInProgress'  ,RecordTypeId =recordTypeId);

       
        List<CareService__c> careSer = new List<CareService__c>();
        careSer.add(c1);
        careSer.add(c2);
        careSer.add(c3);
        careSer.add(c4);
        insert careSer;
        c1.Last_MyRepair_Status_Changed_Date__c = date.newinstance(2021, 07, 28); 
        update c1;
        c2.Last_MyRepair_Status_Changed_Date__c = date.newinstance(2022, 02, 10); 
        update c2;
        c3.Last_MyRepair_Status_Changed_Date__c = date.newinstance(2021, 12, 28); 
        update c3;
        c4.Last_MyRepair_Status_Changed_Date__c = date.newinstance(2022, 04, 01); 
        update c4;
        
        
        
        Test.startTest(); 

        BL_ICON_BatchCareServiceStatusTask pp = new BL_ICON_BatchCareServiceStatusTask();
        Database.executeBatch(pp,100);
            
        Test.stopTest();
        }
    }
}