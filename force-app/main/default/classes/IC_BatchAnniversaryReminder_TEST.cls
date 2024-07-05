@isTest
private class IC_BatchAnniversaryReminder_TEST {

  @TestSetup
    public static void setup() {
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
    }

	    static testMethod void testBatch() {
		//public void  testBatch() {
	
        ID batchprocessid;
        
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
      	insert stt;
      	
        
        User usr = IC_TestFactory.createUser('TestLVBacthCLCreation@lvtest.com');
		usr.profileId = IC_UTILS.getSAProfile();
		usr.DREAMID__C='123456';    
        insert usr;
               
        Account acc = IC_TestFactory.createAccount();
		acc.TECH_DreamIdSA__pc = '123456';
		acc.AnniversaryMonth__pc = nextMonth;
		acc.AnniversaryDay__pc = '3';
        insert acc;		
       
        Test.startTest();
        IC_BatchAnniversaryReminder myBatch = new IC_BatchAnniversaryReminder();
        batchprocessid = Database.executeBatch(myBatch,1000);
        Test.stopTest();


		List<Task> lst = [SELECT OwnerId,status,Subject,priority,ActivityDate FROM TASK WHERE WhatId = :acc.Id and Subject = :System.Label.IC_Anniversary_Reminder];
		Date actDate;
		Integer month=Integer.valueOf(acc.AnniversaryMonth__pc);
		Integer day=Integer.valueOf(acc.AnniversaryDay__pc);
		actDate = date.newInstance(year,month,day);	
		
		//System.assert(lst.size()>0);	
		//System.assertequals(lst[0].OwnerId,usr.Id);
		//System.assertequals(lst[0].status,'New');
		//System.assertequals(lst[0].priority,'Normal');
		//System.assertequals(lst[0].ActivityDate, actDate);
    }

}