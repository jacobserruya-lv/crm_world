@isTest
public class ICX_CaseQualificationLC_TEST {

    @isTest
    public static void getPicklistMap_Task_Test() {

        // Test
        Test.startTest();
        String result = ICX_CaseQualificationLC.getPicklistMap('Task', 'Nature__c', 'Category__c');
        Test.stopTest();
        System.debug('result=' + result);

        Map<String, List<Schema.PicklistEntry>> resultMap = (Map<String, List<Schema.PicklistEntry>>) JSON.deserialize(result, Map<String, List<Schema.PicklistEntry>>.class);

        // Check
        System.assert(resultMap.get('Transfer') != null && resultMap.get('Transfer').isEmpty());
      //  System.assert(resultMap.get('Product Information') != null && !resultMap.get('Product Information').isEmpty()); //dependency deleted FOR THE NEW FLOW
    }

	@isTest
    public static void getRecordTypeId_Task_Test() {

        Task call = ICX_TestFactory.creatCallTaskOnAccount(null);
        insert call;

        Test.startTest();
        Id result = ICX_CaseQualificationLC.getRecordTypeId(call.Id, 'Task');
        Test.stopTest();

        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call_Case').getRecordTypeId();
		System.assertEquals(recordTypeId, result);
    }

	@isTest
    public static void getRecordTypeId_Case_Test() {

        Case cas = ICX_TestFactory.createCase(null);
        insert cas;

        Test.startTest();
        Id result = ICX_CaseQualificationLC.getRecordTypeId(cas.Id, 'Case');
        Test.stopTest();

		Id recTypeId = [SELECT RecordTypeId FROM Case WHERE Id = :cas.Id].RecordTypeId;
        System.assertEquals(recTypeId, result);
    }

	@isTest
    public static void getRecordTypeId_LiveChatTranscript_Test() {

        LiveChatTranscript chat = ICX_TestFactory.createLiveChatTranscript();
        insert chat;

        Test.startTest();
        Id result = ICX_CaseQualificationLC.getRecordTypeId(chat.Id, 'LiveChatTranscript');
        Test.stopTest();

        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Chat').getRecordTypeId();
		System.assertEquals(recordTypeId, result);
    }
	/*
	// TODO recordTypeId is still empty
	@isTest
    public static void getRecordTypeId_LiveChatTranscript_Test() {

        LiveChatTranscript chat = ICX_TestFactory.createLiveChatTranscript();
        insert chat;

        Test.startTest();
        Id result = ICX_CaseQualificationLC.getRecordTypeId(chat.Id, 'LiveChatTranscript');
        Test.stopTest();

		Id recTypeId = [SELECT RecordTypeId FROM LiveChatTranscript WHERE Id = :chat.Id].RecordTypeId;
        System.assertEquals(recTypeId, result);
    }*/
    @isTest
    public static void getPicklist_Test() {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call_Case').getRecordTypeId();
        ICX_CaseQualificationLC.getPicklist(devRecordTypeId, 'Case');
    }
    @isTest
    public static void getFieldList_Test() {
        ICX_CaseQualificationLC.getFieldList('', new List<String>(), new List<Boolean>());
    }
}