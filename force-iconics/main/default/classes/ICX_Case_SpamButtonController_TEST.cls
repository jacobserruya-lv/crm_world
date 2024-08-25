@isTest
public class ICX_Case_SpamButtonController_TEST {

    @isTest
    public static void updateCaseTest() {
        Group queue = [SELECT Id FROM Group WHERE Type='Queue' LIMIT 1];

        Case cas = ICX_TestFactory.createCase(null);
        cas.OwnerId = queue.Id;
        insert cas;

        ApexPages.StandardController sc = new ApexPages.StandardController(cas);
        ICX_Case_SpamButtonController ctrl = new ICX_Case_SpamButtonController(sc);

        Test.startTest();
        ctrl.updateCase();
        Test.stopTest();
        
        Case result = [SELECT Spam__c, SpamReason__c FROM Case LIMIT 1];
        System.assertEquals(true, result.Spam__c);
        System.assertEquals('Manual', result.SpamReason__c);
    }

    @isTest
    public static void updateCase_CaseAlreadySpammedTest() {
        Case cas = ICX_TestFactory.createCase(null);
        cas.Spam__c = true;
        insert cas;

        ApexPages.StandardController sc = new ApexPages.StandardController(cas);
        ICX_Case_SpamButtonController ctrl = new ICX_Case_SpamButtonController(sc);

        Test.startTest();
        ctrl.updateCase();
        Test.stopTest();
        
        Case result = [SELECT CreatedDate, LastModifiedDate, Spam__c FROM Case LIMIT 1];
        System.assertEquals(true, result.Spam__c);
        // No change
        //System.assertEquals(result.CreatedDate, result.LastModifiedDate);
    }


    @isTest
    public static void updateCase_CaseClosedTest() {
        Case cas = ICX_TestFactory.createCase(null);
        cas.Resolution__c = 'Immediate Response';
        cas.Type = ICX_CaseDataServiceControllerLC.CASE_TYPE_COMPLAINTS;
        cas.Category__c = 'Process';
        cas.Status = 'Closed';
        insert cas;

        ApexPages.StandardController sc = new ApexPages.StandardController(cas);
        ICX_Case_SpamButtonController ctrl = new ICX_Case_SpamButtonController(sc);

        Test.startTest();
        ctrl.updateCase();
        Test.stopTest();
        
        Case result = [SELECT Spam__c FROM Case LIMIT 1];
        System.assertEquals(false, result.Spam__c);
    }

}