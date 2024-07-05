@isTest
private class IC_SchedulerAnniversaryReminder_TEST {

  @TestSetup
    public static void setup() {
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
    }

        static testMethod void testBatch() {
       	
       	Integer thisDay;
       	Integer thisMonth;
    	Integer year;
    	String nextMonth;
    	
    	thisDay = Date.today().day();
    	thisMonth = Date.today().month();
   		year =Date.today().year();
   		if(thisMonth==12){thismonth = 1; year = year+1;}
   		else {thismonth = thisMonth + 1;}
		nextMonth=String.valueOf(thisMonth);
		
       	ICONSettings__c stt = new ICONSettings__c();
      	stt.AnniversaryScheduledDays__c = String.valueOf(thisDay) + ', 13';
        stt.batchAnniversaryScope__c = 500;
      	insert stt;
       	
       	
        User usr = IC_TestFactory.createUser('TestLVBacthCLCreation@lvtest.com');
        usr.profileId = IC_UTILS.getSAProfile();
        usr.DREAMID__C='123456';    
        insert usr;
         
        Account acc = IC_TestFactory.createAccount();
        acc.TECH_DreamIdSA__pc = '123456';
        acc.AnniversaryMonth__pc = nextMonth;
        acc.AnniversaryDay__pc = '11';
        insert acc;                 
           
        IC_SchedulerAnniversaryReminder myScheduler = new IC_SchedulerAnniversaryReminder();
        
        Test.startTest();
        String sch = '0 0 23 L * ?';
        system.schedule('Test check', sch, myScheduler);
        Test.stopTest();

    }

}