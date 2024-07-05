/********************************************************************************************************************************************/
/* Initiated by Anthony Buisson - BW - 13/03/2020 - Last modified 8/12/2021
Delete account and linkend record
if a few conditions are verified (not a identity user, no special orders or personalization in the last 10 years,
no transaction, no order, no social binding in the last 5 years, no repair and no case in the last 3 years, no iOT,
no social binding in the last 5 years, no SFDC email in the last 30 days)

####### Modified by Imad - 13/07/2021 for AutoLunch a new scheduler class "SchedulerAccountDeletion"  has been created for batch management


BatchAccountDeletion cl = new BatchAccountDeletion(0, 0);
Id batchInstanceId = Database.executeBatch(cl,200);
*/
/********************************************************************************************************************************************/
global class BatchAccountDeletion implements Database.Batchable<sObject>, Database.Stateful {
    
    private final String query;
    private final AccountDeletion__c setting;
    private Integer nbRun = 1;
    private Integer noRun = 0;
    private ID lastAccountId;
    private ID firstAccountId = '001000000000000000';
    private ID maxAccountId = '001z00000000000000';
    private Integer nbDeleted = 0;
    private Integer nbDeletedToday = 0;
    private Integer nbTreated = 0;
    private final DateTime dateMaxCreation;
    private final String[] recipients;
    private String error = ''; 
    private Set<Id> AccToDelete = new Set<ID>();

    global BatchAccountDeletion(Integer nbPreviousRun, Integer nbPreviousDeletions) {
        Integer nbMaxAnalyzedAccount = 0;
        
        nbDeletedToday = nbPreviousDeletions != null ? nbPreviousDeletions : 0;
        noRun = nbPreviousRun != null ? nbPreviousRun + 1 : 1;
        
        try {
            setting = AccountDeletion__c.getInstance('Account Deletion Batch');
            nbRun = setting.Nb_run_per_day__c != null ? ((Integer)setting.Nb_run_per_day__c) : 1;
            nbRun = nbRun > 2 ? 2 : nbRun;
            dateMaxCreation = DateTime.Now().addYears(-((Integer)setting.Created_before_years__c));
            firstAccountId = !String.isBlank(setting.Last_account_Id__c) ? setting.Last_Account_Id__c : firstAccountId;
            nbMaxAnalyzedAccount = setting.Max_number_of_analysed_accounts__c != null ? ((Integer)setting.Max_number_of_analysed_accounts__c) : nbMaxAnalyzedAccount;
            recipients = !String.isBlank(setting.Admin_emails__c) ? setting.Admin_emails__c.split(';') : new String[]{};
                }
        catch(Exception e) {
            // Job will not rune because the query is limited to 0 records
            error = 'No setting found - ' + e.getMessage();
        }
        
        try {
            maxAccountId = [select Id from account order by Id desc limit 1][0].Id;
        }
        catch(Exception e) {}
        
        query = 'SELECT Id, Name, PersonContactId, DreamId__c FROM Account '
            + 'WHERE Id > \'' + String.valueOf(firstAccountId) + '\' AND Date_Identity__pc=null AND DreamIdMasterClient__c = \'\' '
            + 'AND (LastName like \'Anonymize%\' OR createdDate <= :dateMaxCreation) '
            + 'AND Can_Be_Contacted_By_Email__pc = false AND Can_Be_Contacted_By_Phone__pc = false '
            + 'AND Can_Be_Contacted_By_SMS__pc = false and Can_Be_Contacted_By_Mail__pc = false order by Id '
            + 'limit ' + String.valueOf(nbMaxAnalyzedAccount);
    }
    
    global database.querylocator start(Database.BatchableContext CD){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
        Set<ID> setClientIds = new Set<ID>();
        Set<ID> setContactIds = new Set<Id>();
        Map<Id, Account> fullAccMap = new Map<Id, Account>();
        Map<Id, Id> fullAccContMap = new Map<Id, Id>();
         Map<Id, Id> fullContAccountMap = new Map<Id, Id>();
        List<Case> cases = new list<Case>();
        List<Deleted_record_log__c> logs = new List<Deleted_record_log__c>();
        nbTreated += scope.size();
        for(sObject o:scope){
            Account client = (Account)o;
            fullAccMap.put(client.Id, client);
            fullAccContMap.put(client.PersonContactId,client.Id);
            fullContAccountMap.put(client.Id,client.PersonContactId);
            setClientIds.add(client.Id);
            setContactIds.add(Client.PersonContactId);
            lastAccountId = (client.Id > lastAccountId && !client.Name.containsIgnoreCase('anonymize')) ? client.Id : lastAccountId; 
        }
        // Set Custom Settings for next run
        lastAccountId = lastAccountId < maxAccountId ? lastAccountId : '001000000000000000';
        setting.Last_account_Id__c = lastAccountId;
        setting.job_Id__c = CD.getJobId();
        
        // purchase products - No purchase product in the last 5 years
        Set<Id> accWithPP = new Set<Id>();
        for (PPR_PurchProduct__c p : [select Client__c from PPR_PurchProduct__c where Client__c IN :setClientIds AND PurchasedDate__c > :Date.today().addYears(-5)]) {
             accWithPP.add(p.Client__c);
        }
        setClientIds.removeAll(accWithPP);
        
        // Case - No case in the last 3 years
        Set<Id> accWithCase = new Set<Id>();
        List<Case> casesWithAccount = [select AccountId ,contactId, account.Name,Contact.Name from case where AccountId IN :setClientIds  AND createdDate > :DateTime.Now().addYears(-3)];
        List<Case> casesWithContact = [select Id,ContactId, AccountId,account.Name,Contact.Name from case where ContactId IN :setContactIds AND createdDate > :DateTime.Now().addYears(-3)];
        if(casesWithAccount.Size()>0){
            for (case c : casesWithAccount) {
                if(String.isNotBlank(c.Account.Name) && !c.Account.Name.containsIgnoreCase('anonymize') && String.isNotBlank(c.Contact.Name) && !c.Contact.Name.containsIgnoreCase('anonymize')){
                    accWithCase.add(c.AccountId);
                }
            }
        }
        if(casesWithContact.Size()>0){
            for (case c : casesWithContact ) {
                // accWithCase.add(c.AccountId);
                if(String.isNotBlank(c.Account.Name) &&  !c.Account.Name.containsIgnoreCase('anonymize') && String.isNotBlank(c.Contact.Name) && !c.Contact.Name.containsIgnoreCase('anonymize')){
                    if(fullAccContMap != null && fullContAccountMap.get(c.AccountId) != null){
                        c.ContactId = fullContAccountMap.get(c.AccountId);
                        cases.add(c);
                    }
                     accWithCase.add(c.AccountId);
                }
            }
            if(cases.size()>0){
            update cases;   
            }
        }
        setClientIds.removeAll(accWithCase);
        // Repair - No repair in the last 3 years
        Set<Id> accWithRepair = new Set<Id>();
        for (CareService__c c : [select Client__c from CareService__c where Client__c IN :setClientIds AND createdDate > :DateTime.Now().addYears(-3)]) {
             accWithRepair.add(c.Client__c);
        }
        setClientIds.removeAll(accWithRepair);
        
        // OPP - No opportunity in the last 10 years
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
        
        // Order - No order in the last 5 years
        Set<Id> accWithOrder = new Set<Id>();
        for (Order__c c : [select Account__c from Order__c where Account__c IN :setClientIds AND createdDate > :DateTime.Now().addYears(-5)]) {
             accWithOrder.add(c.Account__c);
        }
        setClientIds.removeAll(accWithOrder);
        
        // iOT - No iOT
        Set<Id> accWithIOT = new Set<Id>();
        for (Asset a : [select AccountId from Asset where AccountId IN :setClientIds]) {
            accWithIOT.add(a.AccountId);
        }
        setClientIds.removeAll(accWithIOT);
        
        // social binding - No social binding in the last 5 years
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
                
                // DELETE PURCHASE PRODUCTS : Cascade delete
                
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
                
                // DELETE EXCLUSIVE EXPERIENCES
                delete [SELECT Id FROM Exclusive_Experience__c WHERE Account_Id__c IN :setClientIds];
                
                // DELETE EXCLUSIVE CAMPAIGN ORDER
                delete [SELECT Id FROM Exclusive_Campaign_Order__c WHERE Client__c IN :setClientIds];
                
                // DELETE ACCOUNTS
                delete [select Id from Account where Id IN :setClientIds];
                
                // Add logs
                for (Id accId : setClientIds) {
                    Account acc = fullAccMap.get(accId);
                    logs.add (new Deleted_record_log__c(Object_type__c = 'Account', Object_name__c = acc.Name, ObjectId__c = accId, DreamId__c = acc.DreamId__c, Deleted__c = true));
                    
                }
                if (!logs.isEmpty()) insert logs;
                
                nbDeleted = nbDeleted + setClientIds.size();
                setting.Total_deleted_records__c = String.isNotBlank(String.valueOf(setting.Total_deleted_records__c)) ? setting.Total_deleted_records__c+setClientIds.size() : setClientIds.size();
                update setting;
            }
            catch (DmlException e) {
                // Process exception here
                error = 'Exception:' + e.getMessage() + '\r\n' + e.getStackTraceString();
                System.debug('====== '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
            }
        }
    }
    
    global void finish(Database.BatchableContext CD) {
        
        nbDeleted = nbDeleted + AccToDelete.size();
        
        nbDeletedToday += nbDeleted;
        Boolean nextRun = noRun < nbRun;
        if (recipients !=null && recipients.size() > 0) {
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :CD.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            String body = 'The batch is finished with:\n Error(s): ' + String.valueOf(a.NumberOfErrors) + '\n Treated accounts: ' + String.valueOf(nbTreated) + '\n Account Id: ' + firstAccountId + ' to ' + lastAccountId + '\n Deleted accounts per execution : ' + String.valueOf(nbDeleted) + '\n Deleted accounts per hour : ' + String.valueOf(nbDeletedToday) + '\n\n Total deleted records : '+setting.Total_deleted_records__c +  (!String.isBlank(error) ? '\n\n Error: ' + error : '');
            
            mail.setToAddresses(recipients);
            mail.setSubject('Batch for account deletion (' +  String.valueOf(noRun) + '/' + nbRun + ')');
            mail.setPlainTextBody(body);
            if(!Test.isRunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
        if (nextRun) {
            BatchAccountDeletion cl = new BatchAccountDeletion(noRun, nbDeletedToday);
            Database.executeBatch(cl,200);
        }
    }
}