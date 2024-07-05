/*	 * @author Keman WU
* @date creation 07/06/2022
* @description test class for ShipmentTracking_TriggerHandler
*/


@isTest
public class ShipmentTracking_TriggerHandler_TEST {

    @testSetup static void setup() {
        Identity_TestFactory.createSettings();
        Account acc = Identity_TestFactory.createAccount('shipmentTracking', 'test', 'shipmentTracking@test.com', '123456789', '972', true);
        User u = Identity_Utils.createMylvClient(acc, 'HDtfqawdv5435!');


        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId(); 	 
       
        Store__c store= new Store__c(RetailStoreId__c = 'UE4');
		insert store;
       
        CareService__c dcs = new CareService__c(recordTypeId = DistantCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'UE4', Store__c = store.Id, IsToDo__c=false,Product_Family__c='test family',SKU__c='M9999',MyRepair_CreatedDate__c = system.today(),Last_MyRepair_Status_Changed_Date__c = system.today(),FollowupBy_Email__c=true,FollowupBy_Chat__c=true);
       insert dcs;       

    }

    @isTest static void testMethod1() {         
        
        CareService__c myDCS = [select id from CareService__c];

        test.startTest();  
        
        ShipmentTracking__c st = new ShipmentTracking__c(CareService__c = myDCS.Id, Delivery_Type__c = 'RC', Status__c = 'Carrier Pickup', Status_Code__c = '100', StatusDate__c = system.today(), Tracking_Number__c = 'testTrackingNumber', Carrier__c = 'UPS' );
        insert st; 

        ShipmentTracking__c myST = [select Id,OwnerId from ShipmentTracking__c ];

        Account myAcc = [select Id from Account];
       
        User identityUser = [select Id,AccountId from User where AccountId=:myAcc.Id ];
           
        system.assertEquals( myST.OwnerId, identityUser.Id);
       
        test.stopTest();
    
    }

}