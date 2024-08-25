@isTest
public class ICX_PicklistDataServiceControllerLC_Test {
   @isTest
   public static void test1(){
    Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call_Case').getRecordTypeId();
    Test.startTest();
    ICX_PicklistDataServiceControllerLC.getPicklist(recordTypeId, 'Case');
    Test.stopTest();
   }
   @isTest
   public static void test2(){
        String parser = '{\"picklistFieldValues\":{\"Category__c\":{\"controllerValues\":{\"Product Information\":0,\"Service and General Information\":1,\"Sales\":2,\"Complaints\":3,\"Events and Editorials\":4,\"Congratulations\":5,\"Transfer\":6,\"Service & Repair\":7,\"Missed\":8,\"No Response Required\":9},\"url\":\"/services/data/v46.0/ui-api/object-info/Case/picklist-values/0123D000000ZyolQAC/Category__c\",\"values\":[{\"label\":\"Reservation\",\"validFor\":[2],\"value\":\"Reservation\"},{\"label\":\"Order\",\"validFor\":[2],\"value\":\"Order\"},{\"label\":\"Exchange / Return\",\"validFor\":[2],\"value\":\"Exchange/Return\"},{\"label\":\"Delivery\",\"validFor\":[2],\"value\":\"Delivery\"},{\"label\":\"Packaging\",\"validFor\":[2],\"value\":\"Packaging\"},{\"label\":\"Credit note / Gift voucher\",\"validFor\":[2],\"value\":\"Credit note, gift voucher\"},{\"label\":\"Invoice duplicate\",\"validFor\":[2],\"value\":\"Invoice duplicate\"},{\"label\":\"Tax refund\",\"validFor\":[2],\"value\":\"Tax refund\"},{\"label\":\"Availability\",\"validFor\":[0],\"value\":\"Availability\"},{\"label\":\"Price\",\"validFor\":[0],\"value\":\"Price\"},{\"label\":\"Characteristics\",\"validFor\":[0],\"value\":\"Characteristics\"},{\"label\":\"Authentification\",\"validFor\":[0],\"value\":\"Authentification\"},{\"label\":\"Repair\",\"validFor\":[3,5],\"value\":\"Repair\"},{\"label\":\"Personalization\",\"validFor\":[1],\"value\":\"Personalization\"},{\"label\":\"Store information\",\"validFor\":[1],\"value\":\"Store information\"},{\"label\":\"Horizon assistance\",\"validFor\":[1],\"value\":\"Horizon assistance\"},{\"label\":\"Website&App\",\"validFor\":[1],\"value\":\"Website&App\"},{\"label\":\"Head office / Company information / LVMH\",\"validFor\":[1],\"value\":\"Head office, Company information, LVMH\"},{\"label\":\"Appointment\",\"validFor\":[1],\"value\":\"Appointment\"},{\"label\":\"Collaboration & Job opportunity\",\"validFor\":[1],\"value\":\"Collaboration & Job opportunity\"},{\"label\":\"Product quality\",\"validFor\":[3],\"value\":\"Product quality\"},{\"label\":\"Service web/CS\",\"validFor\":[3,5],\"value\":\"Service web/CS\"},{\"label\":\"Repair and Care advice\",\"validFor\":[1],\"value\":\"Repair and Care advice\"}]}}}';
        String fieldLevelList = '[\"Category__c\",\"Domaine__c\"]';
        String showParentWithChildrenList = '[false,false]';
		Test.startTest();
        String result = ICX_PicklistDataServiceControllerLC.getFieldList(parser, fieldLevelList, showParentWithChildrenList, new List<String>());
        Test.stopTest();
   }
}