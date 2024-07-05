/* Initiated by Anthony Buisson - BW - 13/03/2020 - Last modified 8/10/2020
Delete account and linkend record with the account field ToDelete__c = '1'
and a few conditions are verified (no special orders or perso in the last 10 days, no transaction in the last 5 years, no repair in the last 3 year, no iOT, not a identity user,
no social binding in the last 5 years, no SFDC email in the last 30 days, no case in the last 3 years)

If ICONSettings.ClientAnonymizationLimit__c > 0 : Search for a maximum of records
Not useful : If ICONSettings.ClientAnonymizationDaysLimit__c > 0 : delete if not anonymized and the created date before Now - n days

IC_BatchClientAnonymization cl = new IC_BatchClientAnonymization();
Id batchInstanceId = Database.executeBatch(cl,200);
*/

global class IC_BatchClientAnonymization implements Database.Batchable<sObject>, Database.Stateful {

    private final String query;
    private final Integer nbMax;
    private final DateTime dateMax;
    private Integer nb = 0;

    global IC_BatchClientAnonymization() {
        Integer nbDays = Integer.valueOf((Decimal)ICONSettings__c.getOrgDefaults().get('ClientAnonymizationDaysLimit__c'));
        nbMax = Integer.valueOf((Decimal)ICONSettings__c.getOrgDefaults().get('ClientAnonymizationLimit__c'));
        dateMax = nbDays != null && nbDays > 0 ? DateTime.Now().addDays(-nbDays) : null;

        query = 'SELECT ID, Name, PersonContactId, ToDelete__c, DreamId__c FROM Account WHERE ToDelete__c= \'1\' AND DreamIdMasterClient__c = null AND Date_Identity__pc=null'
            + (dateMax != null ? ' AND (LastName like \'Anonymize%\' or createdDate <= :dateMax)' : '')
            + (nbMax != null && nbMax > 0 ? ' limit ' + nbMax : '');
        System.debug('********** Query : ' + query);
    }

    global database.querylocator start(Database.BatchableContext CD){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext CD, List<sObject> scope){

        Set<ID> setClientIds = new Set<ID>();
        Set<ID> setContactIds = new Set<Id>();
        Map<Id, Account> fullAccMap = new Map<Id, Account>();
        List<Deleted_record_log__c> logs = new List<Deleted_record_log__c>();

        for(sObject o:scope){
            Account client = (Account)o;
            fullAccMap.put(client.Id, client);
            setClientIds.add(client.Id);
            setContactIds.add(Client.PersonContactId);
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
        for (case c : [select AccountId from case where ContactId IN :setContactIds AND createdDate > :DateTime.Now().addYears(-3)]) {
            accWithCase.add(c.AccountId);
        }
        setClientIds.removeAll(accWithCase);

        // Repair
        Set<Id> accWithRepair = new Set<Id>();
        for (CareService__c c : [select Client__c from CareService__c where Client__c IN :setClientIds AND createdDate > :DateTime.Now().addYears(-3)]) {
            accWithRepair.add(c.Client__c);
        }
        setClientIds.removeAll(accWithRepair);

        // order
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

        // iOT
        Set<Id> accWithIOT = new Set<Id>();
        for (Asset a : [select AccountId from Asset where AccountId IN :setClientIds]) {
            accWithIOT.add(a.AccountId);
        }
        setClientIds.removeAll(accWithIOT);

        // social binding
        Set<Id> accWithSB = new Set<Id>();
        for (Social_Media_identifier__c sb : [Select Client__c from Social_Media_identifier__c where Client__c in :setClientIds AND CreatedDate > :Date.today().addYears(-5)]) {
            accWithSB.add(sb.Client__c);
        }
        setClientIds.removeAll(accWithSB);

        if (!setClientIds.isEmpty()) {
            // DELETIONS
            Try {
                // DELETE CLIENT LIST MEMBERS
                delete [SELECT Id FROM CLM_CliListMember__c WHERE Client__r.AccountId IN :setClientIds];

                // DELETE PROGRAMS
                delete [SELECT Id FROM Program__c WHERE AccountId__c IN :setClientIds];

                // DELETE MARKETING EMAILS
                delete [SELECT et4ae5__Contact__c, et4ae5__Contact__r.AccountId FROM et4ae5__IndividualEmailResult__c WHERE et4ae5__Contact__r.AccountId IN :setClientIds];

                // DELETE OPP
                delete [select id from Opportunity where AccountId in :setClientIds];

                // DELETE PURCHASE PRODUCTS
                //delete [Select id from PPR_PurchProduct__c where Client__c in :setClientIds];

                // DELETE TASK
                delete [Select id from Task where AccountId in :setClientIds and isDeleted = false ALL ROWS];

                // DELETE EVENT
                delete [Select id from Event where AccountId in :setClientIds and isDeleted = false ALL ROWS];

                // DELETE CASE and EMAILS
                delete [select Id from EmailMessage where Parent.Id IN :setClientIds];
                List<Case> lCases = [Select id from Case where AccountId in :setClientIds];
                if (!lCases.isEmpty()) {
                    Map<Id, Case> m = new Map<Id, Case>(lCases);
                    delete [Select id from EmailMessage where ParentId in :m.keySet()];
                    delete lCases;
                }

                // DELETE LIVECHAT
                delete [select id from LiveChatTranscript where Contact.AccountId in :setClientIds];

                // DELETE SURVEY
                delete [Select id from VO_Survey__c where ClientDreamID__c in :setClientIds];

                // DELETE NOTIFICATION
                delete [Select id from Notification__c where Client__c in :setClientIds];

                // DELETE SOCIAL MEDIA
                delete [Select id from Social_Media_identifier__c where Client__c in :setClientIds];

                // CARE SERVICE
                delete [SELECT Id FROM CareService__c WHERE Client__c IN :setClientIds];

                // DELETE ACCOUNTS
                delete [select Id from Account where Id IN :setClientIds];

                // Add logs
                // Account.ToDelete__c = '' if not deleted
                for (Id accId : setClientIds) {
                    Account acc = fullAccMap.get(accId);
                    logs.add (new Deleted_record_log__c(Object_type__c = 'Account', Object_name__c = acc.Name, ObjectId__c = accId, DreamId__c = acc.DreamId__c, Deleted__c = true));
                }
                if (!logs.isEmpty()) insert logs;
                nb = nb + setClientIds.size();
                System.debug('========= ' + setClientIds.size() + ' / Total ' + nb);
            }
            catch (DmlException e) {
                // Process exception here
                System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
            }
        }
    }

    global void finish(Database.BatchableContext CD){
        System.debug('xxxxxxxxxxxx Total : ' + nb);
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :CD.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {a.CreatedBy.Email});
        mail.setSubject('Batch for purge and anonymized account deletion');
        mail.setPlainTextBody ('The batch is finished with ' + a.NumberOfErrors + ' error(s) and ' + nb + ' accounts deleted');
        if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}