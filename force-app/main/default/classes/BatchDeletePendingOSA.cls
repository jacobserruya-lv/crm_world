/*
BW 21/02/2020
To run the batch:
BatchDeletePendingOSA cl = new BatchDeletePendingOSA();
Id batchInstanceId = Database.executeBatch(cl, 10000);
*/

global class BatchDeletePendingOSA implements Database.Batchable<sObject>, Schedulable {

    global void execute (SchedulableContext SC)
        {
            BatchDeletePendingOSA bscl = new BatchDeletePendingOSA();
    
            Database.executeBatch(bscl, 10000);
        }
    
    public final String myQuery;

    // Constructor
    public BatchDeletePendingOSA () {
        	myquery = 'select id from event where Recordtype.name=\'Online Appointment\' and status__c=\'Pending\' and createdDate < :dt';
    }

    public List<sObject> start(Database.BatchableContext BC){
        dateTime dt = System.now();
        if (!Test.isRunningTest()){
            dt = dt.addMinutes(-30);
            List<event> l = Database.query(myQuery);
            return l;
        }
        else {
            List<event> l = Database.query(myQuery);
            return l;
        }
        
    }

    public void finish(Database.BatchableContext info){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id = :info.getJobId()];

        if (a.NumberOfErrors != 0) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	string[] toAddresses = new string[] {a.CreatedBy.Email}; 
       		mail.setToAddresses(toAddresses); 
        	mail.setSubject('Pending appointments have been deleted successfully');
        	mail.setPlainTextBody ('The batch ended with ' + a.NumberOfErrors + ' error(s).');
        	if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    public void execute(Database.BatchableContext info, List<sObject> scope){
        List<event> li = new List<event>();
        for (sObject o : scope) {
            event PendingOSA = (event)o;
            li.add(PendingOSA);
        }   
        delete li;     
    }

}