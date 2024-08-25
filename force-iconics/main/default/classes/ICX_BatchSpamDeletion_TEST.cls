/**
* @description: Test class for the batchable ICX_BatchSpamDeletion
* @modification history:
*
*/

@isTest
private class ICX_BatchSpamDeletion_TEST {
    
    @isTest static void test_executeSpamDeletion() {

        // creating spam cases
        Account client = ICX_TestFactory.createAccount();
        insert client;

        List<Case> spamCases = new List<Case>();
        List<id> spamCaseId = new List<id>();

        for(Integer i=0; i<10; i++)
        {
            spamCases.add(ICX_TestFactory.createCase(client.id));
        }
        insert spamCases;

        //mark cases as spam
        for(Case ca: spamCases)
        {
        	spamCaseId.add(ca.id);
        	ca.spam__c = true;
            ca.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SPAM').getRecordTypeId();
        }
        update spamCases;

        // calling batch execute method
        Test.startTest();
        ICX_BatchSpamDeletion spamBatch = new ICX_BatchSpamDeletion();
        Database.executeBatch(spamBatch);
        Test.stopTest();

        // testing result
        System.assertEquals(Database.countquery('SELECT COUNT() from Case where id =:spamCaseId'), 0);
    }
    
    
}