public with sharing class IC_ClientListStatistics_ClientTask_VFCx {

    public String ClientListId {get;set;}
    public String OwnerId {get;set;}
    CLI_CliList__c CltList {get;set;}
    public List<ClientData> clientTask {get;set;}
    public String pageSectionTitle{ get; set; }
    

    public IC_ClientListStatistics_ClientTask_VFCx(){

        ClientListId = ApexPages.currentPage().getParameters().get('Id');
        OwnerId = ApexPages.currentPage().getParameters().get('UserId');
        User clientListOwner = [Select Id, Name From User Where Id = :OwnerId Limit 1][0];
        CltList = [SELECT Id, Name, Description__c, Active__c, createdDate FROM CLI_CliList__c WHERE Id = :ClientListId limit 1];
        pageSectionTitle =  String.format(Label.IC_ListOfClientFor, new String[] {clientListOwner.Name});
        
        clientTask = calculClientTask();
    }
    
    
    public class ClientData{
        public String clientName{get;set;}
        public String actionType{get;set;}
        public DateTime createdDate{get;set;}
        public String subject{get;set;}
        public String status{get;set;}
        
        public ClientData(String clientName, String actionType, DateTime createdDate, String subject, String status){
            this.clientName = clientName;
            this.actionType = actionType;
            this.createdDate = createdDate;
            this.subject = subject;
            this.status = status;
        }
        
        public ClientData(){
        }
    }
    
    public List<ClientData> calculClientTask(){
        System.debug('**************getClientTask**********************');
        List<ClientData> lstClientTask = new List<ClientData>();
        DateTime createDate = CltList.CreatedDate;
        List<CLM_CliListMember__c> clientListMembers = [SELECT Id, Client__r.accountId FROM CLM_CliListMember__c  WHERE ClientList__c = :ClientListId  and IsDeleted = false];
        List<Id> listAccountId_CltListMbr = new List<Id>();
        for(CLM_CliListMember__c CltListMbr : clientListMembers){
            listAccountId_CltListMbr.add(CltListMbr.Client__r.accountId);
        }
        System.debug('ListMember : '+listAccountId_CltListMbr);
        String queryCCLM = 'Select Name, Id' 
                            + ', (Select Id, ActionType__c, CreatedDate, Subject, Status from Tasks Where '
                            //+ ' CreatedDate >= :createDate AND '
                            + ' CreatedDate = LAST_N_DAYS:90 and ActionType__c IN (\'Email\',\'Phone\',\'SMS\',\'Mobile Chat\',\'Postal Mail\') AND OwnerId =:OwnerId) ' 
                            + ' From Account c WHERE Id IN :listAccountId_CltListMbr';
    
        List<Account> contactedCltMembers = Database.query(queryCCLM);
        System.debug('ListContacted : '+contactedCltMembers);
        for(Account a : contactedCltMembers){
            System.debug('Account : '+a.Id + ' - ' + a.Name + ' - ' + a.Tasks.Size());
            for(Task t:a.Tasks){
                ClientData c = new ClientData(a.Name, t.ActionType__c, t.createdDate, t.subject, t.status);
                lstClientTask.add(c);
            }
            if(a.Tasks.size() == 0){
                ClientData c = new ClientData(a.Name, '', null, '', '');
                lstClientTask.add(c);
            }
        }
        return lstClientTask;
    }

}