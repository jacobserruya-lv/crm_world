/**
    @Author : 	ouramdane.aouci
    Desc 	:   test class for TR_BatchC360DataCatchUp class 
    V 1.0 	:   27/09/2023
*/
@isTest
private class TR_BatchC360DataCatchUp_TEST {

    @TestSetup
    private static void setup(){
        Transverse_Batchs_Setup__c setting = new Transverse_Batchs_Setup__c();
        setting.name = 'Batch_C360_Data_Catch_Up';
        setting.Where_Clause__c = 'HomeAddressCountryCode__pc = null AND AttachedStoreCountry__pc != null AND DREAMID__c = null';
        setting.Created_After__c = DateTime.newInstance(2023,03,01);
        setting.Limit__c = '200';
        INSERT setting;
        
        List<Account> accList = new List<Account>();
        
        //These two records will not be processed normally
        Account acc0 = IC_TestFactory.createAccount();
        acc0.HomeAddressCountryCode__pc = '';
        acc0.AttachedStoreCountry__pc = 'ITA';
        acc0.CreatedDate = DateTime.newInstance(2023,01,01);
        accList.add(acc0);
        
        Account acc1 = IC_TestFactory.createAccount();
        acc1.HomeAddressCountryCode__pc = 'UK';
        acc1.CreatedDate = DateTime.newInstance(2023,04,02);
        accList.add(acc1);

        for(Integer i=1; i<=10; i++){                       //Tested also with 200 records
            Account acc = IC_TestFactory.createAccount();
            acc.HomeAddressCountryCode__pc = '';
            acc.AttachedStoreCountry__pc = 'FRA';
            acc.DREAMID__c = '';
            acc.CreatedDate = DateTime.newInstance(2023,04,03).addSeconds(i);
            accList.add(acc);
        }

        INSERT accList;
    }
    
    @isTest
    private static void batchTest(){
        Test.startTest();
        TR_SchedulerC360DataCatchUp myScheduler = new TR_SchedulerC360DataCatchUp();
        String cron = '0 0 23 L * ?';
        System.schedule('TR_BatchC360DataCatchUp', cron, myScheduler);
        myScheduler.execute(null);
        Test.stopTest();
        
        //Check the results
        System.assertEquals(12, [SELECT count() FROM Account], 'Account');
        System.assertEquals(10, [SELECT count() FROM TECH_IntegrationManager__c WHERE Done__c = true], 'TECH Integration Manager');
        
        //Get the last treated Account Created Date
        DateTime createdAfter = Transverse_Batchs_Setup__c.getAll().get('Batch_C360_Data_Catch_Up').Created_After__c;
        List<Account> actList = [SELECT createdDate FROM Account ORDER BY createdDate DESC];
        System.assertEquals(createdAfter, actList[0].get('createdDate'), 'Equal Dates');
        System.debug('Saved setting createdAfter: ' + createdAfter + ' VS actList, last record createdDate: ' + actList[0].get('createdDate'));

        //Test on a reduced list of Accounts - Ajust the loop counter (it was ok)
        /*for(Account acc : [SELECT CreatedDate, HomeAddressCountryCode__pc, AttachedStoreCountry__pc FROM Account]){
            System.debug(acc);
        }
        
        System.debug('=========================================================================+===================');
        
        for(TECH_IntegrationManager__c tim : [SELECT Object_Name__c, AccountId__c, Trigger_Event__c, StartTime__c, 
                                             Error__c, Done__c, Operation__c, Object_Id__c FROM TECH_IntegrationManager__c]){
            System.debug(tim);
        }*/
    }
}