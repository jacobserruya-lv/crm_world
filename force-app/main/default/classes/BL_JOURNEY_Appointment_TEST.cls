@isTest
public with sharing class BL_JOURNEY_Appointment_TEST {
   
    @isTest
    static void testMethodGet(){
    
        BL_AppSettings.setAppSettings('Journey');
        
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.WWEmployeeNumber__c = 'w123';
        insert u;

        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06');
		insert store;
        
        system.runAs(u){

            DateTime currentDT = System.now();
            String strUnixTimeStamp = String.valueof( currentDT.getTime() );


            Account acc = IC_TestFactory.createAccount();
            insert acc;
            Event ev = IC_TestFactory.createEvent(acc);
            ev.startDatetime = currentDT;
            ev.Store_Location__c = store.Id;
    
            Event ev2 = IC_TestFactory.createEvent(acc);
            ev.startDatetime = currentDT;
            ev.Store_Location__c = store.Id;

            insert new List<Event> {ev, ev2};

            Test.startTest();
            BL_JOURNEY_Appointment journeyAppointment = new BL_JOURNEY_Appointment();
      
            journeyAppointment.queryParams =  new Map<String, String> {'storeCode' =>'A06', 
                                                             'from' =>  strUnixTimeStamp, 
                                                             'to' => strUnixTimeStamp, 
                                                             'caUniqueId'=>'w123'};
            

            try{journeyAppointment.executeGET();}
            catch(Exception e){}

            Test.stopTest();
        }
    }
}