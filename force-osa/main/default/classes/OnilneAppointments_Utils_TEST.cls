@isTest
private class OnilneAppointments_Utils_TEST
{
    
    @testSetup static void setUp() {
        Store__c store1= new Store__c(RetailStoreId__c = 'A06', Time_Zone_Id__c = 'Europe/Paris', AppointmentType__c = null);
        insert store1;
        IDENTITY_TestFactory.createSettings();
        
        DateTime myDateTime = DateTime.now();
        Date days5 = date.today().addDays(5);
        
        Map<String, Object> availabilitiesJSON = new Map<String, Object>{
            'startTimes' => new List<Object>{  myDateTime,  myDateTime.addDays(1),  myDateTime.addDays(2),  myDateTime.addDays(3) },
                'capacities' => 2,
                'IsRecurrence' => false,
                'DurationInMinutes' => 60,
                'StoreCode' => 'A06'
                };
                    
                    
                    Map<String, Object> availabilitiesMap =  (Map<String, Object> ) OnlineAppointments_Utils.createAvailabilities(availabilitiesJSON);
        
        Map<String, Object> availabilitiesJSON2 = new Map<String, Object>{
            'startTimes' => new List<Object>{  myDateTime,  myDateTime.addDays(1),  myDateTime.addDays(2),  myDateTime.addDays(3) },
                'capacities' => 2,
                'IsRecurrence' => true,
                'RecurrenceStartDateTime'=>myDateTime,
                'RecurrenceEndDateOnly' => System.today()+10,
                'RecurrenceType'=>'RecursDaily',
                'RecurrenceInterval'=>1,
                'DurationInMinutes' => 60,
                'StoreCode' => 'A06'
                };
                    
                    
                    Map<String, Object> availabilitiesMap2 =  (Map<String, Object> ) OnlineAppointments_Utils.createAvailabilities(availabilitiesJSON2);
        
    }
    
    @isTest
    static void test1(){
        DateTime myDateTime = DateTime.now();
        Date days5 = date.today().addDays(5);
        
        Map<String, Object> availabilitiesJSON = new Map<String, Object>{
            'startTimes' => new List<Object>{  myDateTime,  myDateTime.addDays(1),  myDateTime.addDays(2),  myDateTime.addDays(3) },
                'capacities' => 2,
                'IsRecurrence' => false,
                'DurationInMinutes' => 60,
                'StoreCode' => 'A06'
                };
                    
                    Map<String, Object> availabilitiesMap =  (Map<String, Object> ) OnlineAppointments_Utils.createAvailabilities(availabilitiesJSON);
        List<Event> availabilities = (List<Event>) availabilitiesMap.get('createdAvailabilities');
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        OnlineAppointments_Utils.getFreeAvailabilities( 'A06',  null,  null, null);
        OnlineAppointments_Utils.getAvailabilities( 'A06',  null,  null, null);
        Test.stopTest();
        
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{"values": [{ "label": "Agriculture",  "value": "Agriculture" }, {  "label": "Apparel", "value": "Apparel"}  ] }' 
            );   
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void test2(){
        
        DateTime myDateTime = DateTime.now();
        Date days5 = date.today().addDays(5);
        Map<String, Object> availabilitiesJSON2 = new Map<String, Object>{
            'startTimes' => new List<Object>{  myDateTime },
                'capacities' => 3,
                'IsRecurrence' => true,
                'RecurrenceType' => 'RecursDaily',
                'RecurrenceInterval' => 1,
                'RecurrenceStartDateTime' => myDateTime,
                'RecurrenceEndDateOnly' => days5,
                'DurationInMinutes' => 60,
                'StoreCode' => 'A06'
                };
                    
                    Account acc = new Account(LastName = 'dsafsd', FirstName = 'fdsfsd', PersonEmail = 'dfsd@dsfdfsdf.com');
        insert acc;
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Object availabilities2 =  OnlineAppointments_Utils.createAvailabilities(availabilitiesJSON2);
        //  OnlineAppointments_Utils.getFreeAvailabilities( 'A06',  null,  null, null);
        
        Test.stopTest();
        
        
    }
    
    @isTest
    static void test3(){
        try{
            OnlineAppointments_Utils.getOnlineAndTeamAppointments(false,false, null,  null, null, null);
            OnlineAppointments_Utils.getOnlineAndTeamAppointmentWrappers(false, true, null,  null,  null, 'A06');
        } catch(Exception e){
            system.debug(e.getMessage());
        }
    }
    
    @isTest
    static void test4(){
        list<Event> availabilities = [select Id, startdateTime, activityDate, Store_Location__r.RetailStoreId__c ,EndDatetime, Capacity__c, Store_Location__r.Time_Zone_Id__c,
                                      IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceType, Store_Location__r.Name, RecordType.DeveloperName,
                                      RecurrenceInterval, RecurrenceDayofWeekMask, RecurrenceTimeZoneSidKey, DurationInMinutes 
                                      From Event Where RecordType.DeveloperName = 'Availability'  AND IsRecurrence = false AND Store_Location__r.RetailStoreId__c = 'A06' LIMIT 3];
        
        
        Map<String, Object> onlineApptJSON = new Map<String, Object>{
            'availabilityId' => availabilities[0].Id
                };
                    Test.startTest();
        
        OnlineAppointments_Utils.AppointmentWrapper osa =  (OnlineAppointments_Utils.AppointmentWrapper) OnlineAppointments_Utils.upsertOnlineAppointment(onlineApptJSON);
        system.debug(osa);
        Account acc = new Account(LastName = 'test', FirstName = 'tstfn', PersonEmail = 'dfsd@jjj.com');
        insert acc;
        Map<String, Object> accountInfos = new Map<String, Object>{
            'LastName' => 'test',
                'FirstName' => 'tstfn',
                'PersonEmail' => 'dfsd@jjj.com'
                };
                    osa = (OnlineAppointments_Utils.AppointmentWrapper) OnlineAppointments_Utils.upsertOnlineAppointment(new Map<String, Object>{
                        'onlineAppointmentId' => osa.id,
                            'availabilityId' => availabilities[0].Id,
                            'accountInfos' => accountInfos,
                            'locale' => 'fra_fr'
                            });
        
        acc = OnlineAppointments_Utils.getProspect(acc);
        
        
        OnlineAppointments_Utils.assignAppointments(UserInfo.getUserId(), osa.id, false);
        
        
        OnlineAppointments_Utils.cancelOnlineAppointmnent(osa.id, acc.Id);
        Test.stopTest();
        OnlineAppointments_Utils.getClientAppointments(new Map<String,String> {'accountId' => acc.Id}, false);
        //OnlineAppointments_Utils.getClientAppointments(new Map<String,String> {'accountId' => acc.Id}, true);
        
    }
    
    @isTest
    static void test5(){
        Account acc = new Account(LastName = 'dsafsd', FirstName = 'fdsfsd', PersonEmail = 'dfsd@dsfdfsdf.com');
        insert acc;
        DateTime myDateTime = DateTime.now();
        Date days5 = date.today().addDays(5);
        
        
        list<Event> availabilities = [select Id, startdateTime, activityDate, Store_Location__r.RetailStoreId__c ,EndDatetime, Capacity__c, Store_Location__r.Time_Zone_Id__c,
                                      IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceType, Store_Location__r.Name, RecordType.DeveloperName,
                                      RecurrenceInterval, RecurrenceDayofWeekMask, RecurrenceTimeZoneSidKey, DurationInMinutes 
                                      From Event Where RecordType.DeveloperName = 'Availability'  AND IsRecurrence = false AND RecurrenceActivityId != null AND Store_Location__r.RetailStoreId__c = 'A06' LIMIT 10];
        
        
        Map<String, Object> onlineApptJSON = new Map<String, Object>{
            'availabilityId' => availabilities[0].Id,
                'accountId' => acc.Id
                };
                    Test.startTest();
        
        OnlineAppointments_Utils.AppointmentWrapper osa =  (OnlineAppointments_Utils.AppointmentWrapper) OnlineAppointments_Utils.upsertOnlineAppointmentDesktop(onlineApptJSON);
        Event newev = availabilities[1];
        newev.RecurrenceStartDateTime = myDateTime.addHours(5);
        newev.DurationInMinutes = 60;
        newev.EndDateTime = null;
        newev.RecurrenceType = 'RecursDaily';
        newev.RecurrenceInterval=1;
        newev.RecurrenceEndDateOnly = System.today()+8;
        OnlineAppointments_Utils.updateRecurringAvailability(newev, OnlineAppointments_Utils.RecurringEditMode.ALL);
        Event newev2 = availabilities[0];
        newev2.Capacity__c = 3;
        newev2.RecurrenceStartDateTime = myDateTime;
        newev2.DurationInMinutes = 60;
        newev2.EndDateTime = null;
        newev2.RecurrenceType = 'RecursDaily';
        newev2.RecurrenceInterval=1;
        newev2.RecurrenceEndDateOnly = System.today()+10;
        OnlineAppointments_Utils.updateRecurringAvailability(newev2, OnlineAppointments_Utils.RecurringEditMode.ALL);
        OnlineAppointments_Utils.deleteRecurringAvailability(newev2.Id, OnlineAppointments_Utils.RecurringEditMode.ALL);
        Test.stopTest();
        
    }
    
    @isTest
    static void test6(){
        
        list<Event> availabilities2 = [select Id, startdateTime, activityDate, Store_Location__r.RetailStoreId__c ,EndDatetime, Capacity__c, Store_Location__r.Time_Zone_Id__c,
                                       IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceType, Store_Location__r.Name, RecordType.DeveloperName,
                                       RecurrenceInterval, RecurrenceDayofWeekMask, RecurrenceTimeZoneSidKey, DurationInMinutes 
                                       From Event Where RecordType.DeveloperName = 'Availability'  AND IsRecurrence = false AND RecurrenceActivityId != null AND Store_Location__r.RetailStoreId__c = 'A06' LIMIT 10];
        
        OnlineAppointments_Utils.deleteRecurringAvailability(availabilities2[0].Id, OnlineAppointments_Utils.RecurringEditMode.CURRENT);
        
    }
    @isTest
    static void test7(){
        Account acc = new Account(LastName = 'test', FirstName = 'test1', PersonEmail = 'dfsd@dsfdfsdf.com');
        insert acc;
        Social_Media_Identifier__c smi = new Social_Media_Identifier__c(client__c = acc.id, social_Id__c='123456', social_Media_type__c='WECHAT');
        
        Test.startTest();
        insert smi;
        String acc2 = OnlineAppointments_Utils.getAccountBySocialId('123456', 'WECHAT');
        Test.stopTest();
        System.assertEquals(acc.id, acc2);
        
        OnlineAppointments_Utils.getAvalaibleStoresByCountry('FRANCE', 'A06');
        OnlineAppointments_Utils.getUsersByIds(new Set<Id> {UserInfo.getUserId()});
        
    }
    
}