/* BW - 2/10/2020
Flag account ToDelete__c = '1'
if
- Account Id > idmin and < idmax (to allow screaning all the table)
- CreatedDate before 5 years (default) or the number of years given as a parameters
- a few conditions are verified (no special orders or perso in the last 10 days, no transaction in the last 5 years, no repair in the last 3 year, no iOT, not a identity user, no social binding in the last 5 years, no SFDC email in the last 30 days, no case in the last 3 years)

BatchAccountSelectForPurge cl = new BatchAccountSelectForPurge('idmin', 'idmax', null);
Id batchInstanceId = Database.executeBatch(cl,200);
*/

global class BatchAccountSelectForPurge implements Database.Batchable<sObject>, Database.Stateful {
    public final String query;
    private final DateTime creationDate;
    private Integer nb = 0;

    public BatchAccountSelectForPurge(Id idmin, Id idmax, Integer yearsBefore) {
        creationDate = DateTime.now().addYears(yearsBefore == null ? -5 : -yearsBefore);
        query = 'SELECT Id, createdDate FROM Account Where Id >= \'' + idmin + '\' and Id <= \'' + idmax + '\' and ToDelete__c != \'1\' AND Date_Identity__pc=null AND createdDate < :creationDate';
        System.debug('xxxxxxxxxxxx createddate < ' + creationDate);
        System.debug('xxxxxxxxxxxx query : ' + query);
	 }

	global database.querylocator start(Database.BatchableContext CD){
        return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext CD, List<sObject> scope){
        Set<ID> setClientIds = new Set<ID>();

        for(sObject o:scope){
          Account client = (Account)o;
          setClientIds.add(client.Id);
          System.debug('=========== ' + client.Id + ' - ' + client.CreatedDate);
        }

        // OPP
        Set<Id> accWithOpp = new Set<Id>();
        for (Opportunity o : [SELECT AccountId FROM Opportunity WHERE AccountId IN :setClientIDs and (IsClosed=false OR IsWon=true) AND createdDate > :DateTime.Now().addYears(-10)]) {
            accWithOpp.add(o.AccountId);
        }
        setClientIds.removeAll(accWithOpp);

        // Email (to keep the account with surveys during 30 days)
        Set<Id> accWithEmail = new Set<Id>();
        for (et4ae5__IndividualEmailResult__c em : [SELECT et4ae5__Contact__c, et4ae5__Contact__r.AccountId FROM et4ae5__IndividualEmailResult__c WHERE et4ae5__Contact__r.AccountId IN :setClientIds AND createdDate > :DateTime.Now().addDays(-30)]) {
            accWithEmail.add(em.et4ae5__Contact__r.AccountId);
        }
        setClientIds.removeAll(accWithEmail);

        // Case
        Set<Id> accWithCase = new Set<Id>();
        for (case c : [select AccountId from case where AccountId IN :setClientIds AND createdDate > :DateTime.Now().addYears(-3)]) {
            accWithCase.add(c.AccountId);
        }
        setClientIds.removeAll(accWithCase);

        // Repairs
        Set<Id> accWithRepair = new Set<Id>();
        for (CareService__c c : [select Client__c from CareService__c where Client__c IN :setClientIds AND createdDate > :DateTime.Now().addYears(-3)]) {
            accWithRepair.add(c.Client__c);
        }
        setClientIds.removeAll(accWithRepair);

        // orders
        Set<Id> accWithOrder = new Set<Id>();
        for (Order__c c : [select Account__c from Order__c where Account__c IN :setClientIds AND createdDate > :DateTime.Now().addYears(-5)]) {
            accWithOrder.add(c.Account__c);
        }
        setClientIds.removeAll(accWithOrder);

        // purchase products
        Set<Id> accWithPP = new Set<Id>();
        for (PPR_PurchProduct__c p : [select Client__c from PPR_PurchProduct__c where Client__c IN :setClientIds AND PurchasedDate__c > :Date.today().addYears(-5)]) {
            accWithPP.add(p.Client__c);
        }
        setClientIds.removeAll(accWithPP);

        // social binding
        Set<Id> accWithSB = new Set<Id>();
        for (Social_Media_identifier__c sb : [Select Client__c from Social_Media_identifier__c where Client__c in :setClientIds AND CreatedDate > :Date.today().addYears(-5)]) {
            accWithSB.add(sb.Client__c);
        }
        setClientIds.removeAll(accWithSB);

        // iOT
        Set<Id> accWithIOT = new Set<Id>();
        for (Asset a : [select AccountId from Asset where AccountId IN :setClientIds]) {
            accWithIOT.add(a.AccountId);
        }
        setClientIds.removeAll(accWithIOT);

        if (setClientIds.isEmpty()) return;

        List<Account> accUpdate = new List<Account>();
        for (Account acc : [select Id, ToDelete__c from account where Id in :setClientIds]) {
            acc.ToDelete__c = '1';
            System.debug('========== ' + acc.Id);
            accUpdate.Add(acc);
        }

        if (!accUpdate.isEmpty()) {
            update accUpdate;
            nb = nb + accUpdate.size();
            System.debug('xxxxxxxx updated : ' + nb);
        }
    }

    global void finish(Database.BatchableContext CD) {
        System.debug('xxxxxxxxxxxx Total : ' + nb);
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :CD.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {a.CreatedBy.Email});
        mail.setSubject('Batch select for purge');
        mail.setPlainTextBody ('The batch is finished with ' + a.NumberOfErrors + ' error(s) and ' + nb + ' accounts selected');
        if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}