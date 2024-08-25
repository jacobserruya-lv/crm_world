/*	 * @author Keman WU
* @date creation 04/11/2021
* @description test class for ICX_OnlineAppointmentController
*/
@isTest
public class ICX_OnlineAppointmentController_TEST {
    @isTest static void testChangeOwner() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();     	
        Id onlineAppointmentRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();    
        Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
		insert store1;      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        ProductCatalogue__c product = new ProductCatalogue__c(SKU__c ='M55555');
        insert product;
        CareService__c dcs = new CareService__c(recordTypeId = DistantCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id, IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
        insert dcs;       
        Set<Id> setCareId = new Set<Id>();
        setCareId.add(dcs.id);
        Event appointment = new Event(recordTypeId=onlineAppointmentRTId,My_Repairs__c =dcs.id,StartDateTime = System.now() + 5, DurationInMinutes=30);
        insert appointment;
       
        test.startTest();
        ICX_OnlineAppointmentController.changeOnlineAppointmentOwner(dcs.id,userInfo.getUserId());
        ICX_OnlineAppointmentController.massChangeOnlineAppointmentOwner(setCareId,userInfo.getUserId());
        test.stopTest();
        Event currentAppointment = [select Status__c,OwnerId from Event limit 1 ];
        System.assertEquals('Assigned',currentAppointment.Status__c);
        System.assertEquals(userInfo.getUserId(),currentAppointment.OwnerId);
    }

    @isTest static void testCancel() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();     	
        Id onlineAppointmentRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId(); 
        set<ID> setCareId = new set<ID> ();
        Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
		insert store1;      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        ProductCatalogue__c product = new ProductCatalogue__c(SKU__c ='M55555');
        insert product;
        CareService__c dcs = new CareService__c(recordTypeId = DistantCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id, IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
        insert dcs;
        setCareId.add(dcs.id);
        Event appointment = new Event(recordTypeId=onlineAppointmentRTId,My_Repairs__c =dcs.id,StartDateTime = System.now() + 5, DurationInMinutes=30);
        insert appointment;
        test.startTest();
        ICX_OnlineAppointmentController.cancelOnlineAppointment(setCareId);
        test.stopTest();
        Event currentAppointment = [select Status__c from Event limit 1 ];
        System.assertEquals('Cancelled',currentAppointment.Status__c);
    }

    @isTest static void fetchRecords() {
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();     	
        Id onlineAppointmentRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId(); 
        set<ID> setCareId = new set<ID> ();
        Store__c store1= new Store__c(RetailStoreId__c = 'UE4');
		insert store1;      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        ProductCatalogue__c product = new ProductCatalogue__c(SKU__c ='M55555');
        insert product;
        CareService__c dcs = new CareService__c(recordTypeId = DistantCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store1.Id, IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
        insert dcs;
        setCareId.add(dcs.id);
        Event appointment = new Event(recordTypeId=onlineAppointmentRTId,My_Repairs__c =dcs.id,StartDateTime = System.now() + 5, DurationInMinutes=30);
        insert appointment;
        test.startTest();
        ICX_OnlineAppointmentController.fetchRecords(dcs.id + '-Event-My_Repairs__c-RecordType.Name-Online Appointment-String-=-Owner.Name,Status__c,StartDateTime,Appointment_Type_Icon__c,Attendance__c');
        ICX_OnlineAppointmentController.updateAppointment(appointment.id,'Cancelled');
        test.stopTest();
        Event currentAppointment = [select Status__c from Event limit 1 ];
        System.assertEquals('Cancelled',currentAppointment.Status__c);
    }
}