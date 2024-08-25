/**
* @description: Batchable class used to hard delete cases created a month ago and considered as Spam.
*               This batchable will run every day (is called in the schedulable class named ICX_ShedulerSpamDeletion)
*
* @modification history:
*
*/

global class ICX_BatchSpamDeletion implements Database.Batchable<sObject> {
    
    public String query;
    public Datetime caseLastModifiedDate;
    public Id spamRT;
    
    global ICX_BatchSpamDeletion () {

        // Get Spam record type
        spamRT =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('SPAM').getRecordTypeId();

        // Get all cases created at least one month ago and flagged as spam
        if(Test.isRunningTest())
        {
        	caseLastModifiedDate = System.now();
        }
        else
        {
        	caseLastModifiedDate = System.today().adddays(-30);
        }
        query = 'SELECT id, CaseNumber, CreatedDate from Case where lastModifiedDate <=:caseLastModifiedDate and Spam__c = true and recordTypeId =:spamRT';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    
        System.debug('>> Nb Cases to be deleted: ' + scope.size());
        
        try
        {
            // Delete list of old spam cases
            Database.Delete(scope);

            // Hard delete the records by emptying out the recycle bin
            Database.emptyRecycleBin(scope);
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }

    }
    
    global void finish(Database.BatchableContext BC) {
        // no post processing
    }
    
}