/**
    @Author : 	ouramdane.aouci
    Desc 	:   test class for CF_FlagAccountNotSyncWithSFMC class 
    V 1.0   : 	10/04/2024
	V 2.0   : 	22/08/2024 : Set a flag (Exclude_SFMC__c=true) according to certain criteria (CF-1494)
*/
@isTest
private class CF_BatchFlagAccountNotSyncWithSFMC_TEST {
	
    @TestSetup
    private static void setup(){
        Transverse_Batchs_Setup__c setting = new Transverse_Batchs_Setup__c();
        setting.name = 'Batch_C360_Data_Catch_Up';
        setting.Created_After__c = DateTime.newInstance(2023,01,01);
        setting.Limit__c = '200';
        INSERT setting;
        
        //Create some test Accounts
        List<Account> accList = new List<Account>();
        
        Account acc1 = IC_TestFactory.createAccount();
        acc1.CreatedDate = DateTime.newInstance(2024,04,01);
        acc1.ParallelMarket_Status__pc = 'Blue'; acc1.FirstName = 'Account_1';
        accList.add(acc1);
        
        Account acc2 = IC_TestFactory.createAccount();
        acc2.CreatedDate = DateTime.newInstance(2024,04,03);
        acc2.Anonymization_date__c = DateTime.newInstance(2024,04,25); acc2.FirstName = 'Account_2';
        accList.add(acc2);
        
        Account acc3 = IC_TestFactory.createAccount();
        acc3.CreatedDate = DateTime.newInstance(2024,04,05);
        acc3.ParallelMarket_Status__pc = 'Red'; acc3.FirstName = 'Account_3';
        accList.add(acc3);
        
        //Account Can Be Contacted .. (Will not be excluded)
        Account acc4 = IC_TestFactory.createAccount();
        acc4.CreatedDate = DateTime.newInstance(2023,05,04); acc4.FirstName = 'Account_4 Not Excl'; 
        acc4.Can_Be_Contacted_By_Phone__pc = true;                   
        accList.add(acc4);
        
        //Contactability = false .. (will be flagged)
        Account acc5 = IC_TestFactory.createAccount();
        acc5.CreatedDate = DateTime.newInstance(2023,05,05); acc5.FirstName = 'Account_5'; //Not contactable    
        accList.add(acc5);
        
        //Can Be Contacted .. (smi) .. (will not be flagged)
        Account acc6 = IC_TestFactory.createAccount();
        acc6.CreatedDate = DateTime.newInstance(2024,08,23); acc6.FirstName = 'Account_6'; //Have smi             
        accList.add(acc6);
        
        //Contactability = false, have smi, Opt_In__c = false => Will be flagged
        Account acc7 = IC_TestFactory.createAccount();
        acc7.CreatedDate = DateTime.newInstance(2024,08,15); acc7.FirstName = 'Account_7';         
        accList.add(acc7);
        
        //No need to treat it (Already excluded)
        Account acc8 = IC_TestFactory.createAccount();
        acc8.CreatedDate = DateTime.newInstance(2024,08,15); acc8.FirstName = 'Account_8';
        acc8.ParallelMarket_Status__pc = 'Blue'; acc8.Exclude_SFMC__c = true;
        accList.add(acc8);

        INSERT accList;
        
        //Create a Social_Media_Identifier__c records
        Social_Media_Identifier__c smi = IC_TestFactory.createSocialMediaIdentifier(acc6.Id, 'Line');
        INSERT smi;
        
        Social_Media_Identifier__c smi2 = IC_TestFactory.createSocialMediaIdentifier(acc6.Id, 'WeChat');
        smi2.Opt_In__c = true;
        INSERT smi2;
        
        Social_Media_Identifier__c smi3 = IC_TestFactory.createSocialMediaIdentifier(acc7.Id, 'Line');
        INSERT smi3;
        
        //To cover Batch ex
        acc1.Exclude_SFMC__c = false;
        UPDATE acc1;
    }
    
    @isTest
    private static void testBatchFlagAccount(){
        Test.startTest();
        CF_SchedulerFlagAccountNotSyncWithSFMC myScheduler = new CF_SchedulerFlagAccountNotSyncWithSFMC();
        String cron = '0 0 23 L * ?';
        System.schedule('CF_BatchFlagAccountNotSyncWithSFMC', cron, myScheduler);
        myScheduler.execute(null);
        Test.stopTest();
        
        List<Account> accList = [SELECT Id, FirstName, Exclude_SFMC__c FROM Account WHERE Exclude_SFMC__c = true];
        System.assertEquals(accList.size(), 6, 'Nbr of flagged:True Accounts');
        System.debug('----------------------------- Test class: Flagged accounts -----------------------------');
        for(Account ac : accList){
            System.debug(ac.FirstName + ' - ' + ac.Exclude_SFMC__c);
        }
    }
}