@isTest
private class IC_SchedulerBirthdayReminder_TEST {

    @TestSetup
    public static void setup() {
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
    }

        static testMethod void testBatch() {
        
        String nextMonth;
        
        Integer thisDay = Date.today().day();
        Integer thisMonth = Date.today().month();
        Integer year =Date.today().year();
        if(thisMonth==12){thismonth = 1; year = year+1;}
        else {thismonth = thisMonth + 1;}
        nextMonth=String.valueOf(thisMonth);
        
        ICONSettings__c stt = new ICONSettings__c();
      	stt.BirthdateScheduledDays__c = String.valueOf(thisDay) + ', 13';
      	stt.batchBirthdayReminderScope__c=500;
      	insert stt;
        
        User usr = IC_TestFactory.createUser('TestLVBacthCLCreation@lvtest.com');
        usr.profileId = IC_UTILS.getSAProfile();
        usr.DREAMID__C='123456';    
        insert usr;
         
        Account acc = IC_TestFactory.createAccount();
        acc.TECH_DreamIdSA__pc = '123456';
        acc.BirthdateMonth__pc =nextMonth;
        acc.BirthdateDay__pc = '11';
        insert acc;                 
           
        IC_SchedulerBirthdayReminder myScheduler = new IC_SchedulerBirthdayReminder();
        
        Test.startTest();
        String sch = '0 0 23 L * ?';
        system.schedule('Test check', sch, myScheduler);
        Test.stopTest();
    }

}