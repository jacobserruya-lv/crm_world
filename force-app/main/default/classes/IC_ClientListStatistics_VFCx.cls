public with sharing class IC_ClientListStatistics_VFCx {
    
    
    private static final Integer ClientList_PER_PAGE = 25;
    
    public String ClientListId;
    public String AccountId;
    public static List<RecordData> datas;
    public CLI_CliList__c CltList;
    public List<CLI_CliList__c> lstOfAllCltLst;
    public String pageTitle{ get; set; }
    
    public static Integer nbClientListMb_TOTAL { get; set; }
    public static Integer nbContactedClientListMb_TOTAL { get; set; }
    public static Double perCent_GLOBAL { get; set; }
    
    
    public IC_ClientListStatistics_VFCx(){
        
        System.debug('#### constructeur call');
        nbClientListMb_TOTAL = 0;
        nbContactedClientListMb_TOTAL = 0;
        datas = new List<RecordData>();
        ClientListId = ApexPages.currentPage().getParameters().get('Id');
        CltList = [SELECT Id, Name, Description__c, Active__c, createdDate FROM CLI_CliList__c WHERE Id = :ClientListId limit 1];
        pageTitle =  String.format(Label.IC_ClientListStatisticsTitle, new String[] {CltList.Name});
        
    }
    
    
    public PageReference doAction(){
        return null;
    }
    
    
    
        // instantiate the StandardSetController from a query locator
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                String reqSOQL = 'SELECT Id, OwnerId, Owner.Name, CreatedDate FROM CLI_CliList__c WHERE Name Like \''+String.escapeSingleQuotes(CltList.Name)+'\'';
                lstOfAllCltLst = Database.query(reqSOQL);
                con = new ApexPages.StandardSetController(lstOfAllCltLst);
                // sets the number of records in each page set
                con.setPageSize(ClientList_PER_PAGE);
            }
            return con;
        }
        set;
    }

    // returns a list of wrapper objects for the sObjects in the current page set
    public List<RecordData> getDatas() {
        datas = new List<RecordData>();
        for (CLI_CliList__c cl : (List<CLI_CliList__c>)con.getRecords()){
            RecordData r = new RecordData(cl); 
            r.calculateStat();
            datas.add(r);
        } 
        return datas;
    }
    
    
    
    
    
    
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
    
    
     // returns the first page of records
     public void first() {
         con.first();
     }

     // returns the last page of records
     public void last() {
         con.last();
     }

     // returns the previous page of records
     public void previous() {
         con.previous();
     }

     // returns the next page of records
     public void next() {
         con.next();
     }
    
    
    
    
    // Wrapper class
    public class RecordData {

        public String linkTo {get;set;}
        public String sa { get; set; }
        public Integer nbClientListMb { get; set; }
        public Integer nbContactedClientListMb { get; set; }
        public Double perCent { get; set; }
        public CLI_CliList__c clientList{ get; set; }
        public List<CLM_CliListMember__c> clientListMembers{ get; set; }
        public DateTime createDate {get;set;}

        public RecordData(CLI_CliList__c cltList) {
            clientList = cltList;
            clientListMembers = new List<CLM_CliListMember__c>();
        }
        
        public RecordData(String sa, Integer nbClientListMb, Integer nbContactedClientListMb, Double perCent) {
            this.sa = sa;
            this.nbClientListMb = nbClientListMb;
            this.nbContactedClientListMb = nbContactedClientListMb;
            this.perCent = perCent;
        }
        
        public void calculateStat(){
            System.Debug('##### : calculate');
            sa = clientList.Owner.Name;
            createDate = clientList.CreatedDate;
            linkTo = '/apex/IC_ClientListStatistics_ClientTask?Id='+clientList.Id + '&UserId=' + clientList.OwnerId;
            clientListMembers = [SELECT Id, Client__r.accountId FROM CLM_CliListMember__c  WHERE ClientList__c = :clientList.Id  and IsDeleted = false];
            nbClientListMb = clientListMembers.size();
            nbContactedClientListMb = 0;
            
            List<Id> listAccountId_CltListMbr = new List<Id>();
            for(CLM_CliListMember__c CltListMbr : clientListMembers){
                listAccountId_CltListMbr.add(CltListMbr.Client__r.accountId);
            }
            String ownerId = clientList.OwnerId;
            String queryCCLM = 'Select Name, Id' 
                                + ', (Select Id, ActionType__c, CreatedDate, Subject, Status from Tasks Where '
                                + ' CreatedDate >= :createDate AND '
                                + ' CreatedDate = LAST_N_DAYS:90 AND ' 
                                + ' ActionType__c IN (\'Email\',\'Phone\',\'SMS\',\'Mobile Chat\',\'Postal Mail\') AND '
                                + ' OwnerId =:ownerId ' 
                                + ') From Account c WHERE Id IN :listAccountId_CltListMbr';
            
            List<Account> contactedCltMembers = Database.query(queryCCLM);
            for(Account a : contactedCltMembers){
                if(a.Tasks.size() != 0){    
                    nbContactedClientListMb = nbContactedClientListMb + 1;
                }
            }
            
            if(nbClientListMb != null && nbClientListMb != 0)
                perCent = (Double)(nbContactedClientListMb*100/nbClientListMb);     
        }
        
    }
}