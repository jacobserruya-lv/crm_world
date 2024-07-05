/*
VB 22/04/2021
Update all user that have taken an OSA 30 days earlier if:
- the user has no cases
- the user has no other appointments
- the user is IsProspect__pc = true and Source__c ='On App' and Date_Identity__pc = null

if user can be contacted by email --> delete phone number and send to dream.
if user cannot be contacted by email --> send to dream as candidate to deletion.

To run the batch:
BatchAccountFromOSA bscl = new BatchAccountFromOSA();
Database.executeBatch(bscl, 10);
*/

global class BatchAccountFromOSA implements Database.Batchable<sObject> {
    
    private String myQuery;
    
    public BatchAccountFromOSA() {
        myQuery = 'select id, AccountId, ActivityDate from event where Recordtype.DeveloperName=\'Online_Appointment\'  and activityDate = :dt';
    }
    
    public List<sObject> start(Database.BatchableContext BC){
        Date dt = System.today().addDays(-30);
        System.debug(myQuery);
        List<Event> ev = Database.query(myQuery);
        System.debug(ev.size());
        return ev;
    }
    
    public void execute(Database.BatchableContext info, List<sObject> scope){
        Set<Id> acc = setAccounts(scope);
        List<Account> accList = getAcc(acc);
        if(accList.size()>0) {
            for (Account a: accList) {
                if (a.Can_Be_Contacted_By_Email__pc == false) {
                    a.ProspectForDream__c = true;
                    a.TECH_CandidateToDeletion__c = true;
                } else {
                    a.PersonMobilePhone = null;
                    a.ProspectForDream__c = true;
                }
            }
            system.debug('FINAL LIST SIZE '+accList.size());
            DateTime qryStart = DateTime.now();
        	update accList;
            DateTime qryEnd = DateTime.now();
        	system.debug(qryStart+' / '+qryEnd);
            
        }  
    }
    
    global void finish(Database.BatchableContext CD){
        
    }
    
    private Set<Id> setAccounts(List<Event> ev) {
        system.debug('SetAccounts started');
        Set<Id> acc = new Set<Id>();
        if(ev.size()>0){
            for (Event e: ev) {
                if(String.isNotBlank(e.AccountId)){
                    acc.add(e.AccountId);
                }
            }
        }
        system.debug('accountAtStart: '+acc.size());
        
        List<Case> cases = getCases(acc);
        if(cases.size()>0){
            for (Case e: cases) {
                if (acc.contains(e.AccountId)) {
                    acc.remove(e.AccountId);
                }
            }
        }
        
        system.debug('accountAfterCases: '+acc.size());
        
        List<Event> events = getApps(acc);
        for (Event e: events) {
            if (acc.contains(e.AccountId)) {
                acc.remove(e.AccountId);
            }
        }
        
        system.debug('accountWithoutCaseOrApp: '+acc.size());
        return acc;
    }
    
    private List<Account> getAcc(Set<Id> acc) {
        DateTime qryStart = DateTime.now();
        List<Account> acct = [SELECT Id, Can_Be_Contacted_By_Email__pc FROM Account WHERE Id in :acc and IsProspect__pc = true and Source__c ='On App' and Date_Identity__pc = null];
        DateTime qryEnd = DateTime.now();
        system.debug(qryStart+' / '+qryEnd);
        return acct; 
    }
    
    private List<Case> getCases(Set<Id> acc) {
        List<Case> cas = [SELECT Id, AccountId FROM Case WHERE  AccountId IN :acc and isClosed = False];
        return cas; 
    }
    
    private List<event> getApps(Set<Id> acc) {
        Date dt = System.today().addDays(-30);
        system.debug(dt);
        List<event> evt = [SELECT Id, AccountId FROM event WHERE  AccountId IN :acc and activityDate > :dt];
        return evt; 
    }
}