/**
     * Batch for PPurchase_AfterInsert 
     * Create Exceptional Purchases Tasks
     * Create by KCA
     * 08/2015
     */


global class IC_BatchExceptionalPurchase implements Database.Batchable<sObject> {
	
	private String query;
	private Integer intervalleDay = Integer.valueOf((Decimal)ICONSettings__c.getOrgDefaults().get('ExcepPurchaseFrequence__c'));
	private Date dateT = Date.today().addDays(-intervalleDay);
	
	global IC_BatchExceptionalPurchase() {
	//    Integer intervalleDay = Integer.valueOf((Decimal)ICONSettings__c.getOrgDefaults().get('ExcepPurchaseFrequence__c'));
	//	Date dateT = Date.today().addDays(-intervalleDay);
	
		query = 'SELECT id, ConvertedAmountUSD__c, ConvertedAmountEUR__c, SA__c, TicketNumber__c, ConvertedAmountYEN__c,  ConvertedAmountYUAN__c, PurchasedDate__c, Client__c FROM PPR_PurchProduct__c';
		query += ' WHERE CreatedDate >= :dateT';
		system.debug('###query = '+ query);
	    	
    }    

    global Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator(query);
    }
    
    global void finish(Database.BatchableContext BC){    
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	
    	List<PPR_PurchProduct__c> newValues = new List<PPR_PurchProduct__c>();	  
   		for(sObject o:scope){
        	PPR_PurchProduct__c purchaseP = (PPR_PurchProduct__c)o;
        	newValues.add(purchaseP);        	
       	}
       	ExcepPurchases(newValues);
    } 
    
    
     private void ExcepPurchases(List<PPR_PurchProduct__c> newValues) {
        	
        List<Task> tasks = new List<Task>();
        Integer exceptPurchase = integer.valueof(ICONSettings__c.getOrgDefaults().get('ExcepPurchaseUSD__c'));
        system.debug('###AKK exceptPurchase = '+ exceptPurchase);
        // Add a currency variable
        String CurrentCurrency = String.valueof(ICONSettings__c.getOrgDefaults().get('Exceptional_Purchase_Currency__c')) ;
        system.debug('###AKK CurrentCurrency = '+ CurrentCurrency);
        
        Set<String> purchaseTicketsNumber = new Set<String>(); // ticket number
        Set<String> userIds = new Set<String>();
        Map<ID, User> activeUsers =   new Map<ID,User>();
        
        for(PPR_PurchProduct__c PPR : newValues) {
          
           if(CurrentCurrency.equals('USD')){ 
                  system.debug('###AKK PPR.ConvertedAmountUSD__c = '+ PPR.ConvertedAmountUSD__c);      
             if(PPR.ConvertedAmountUSD__c >= exceptPurchase){
                if(!IC_UTILS.empty(PPR.SA__c))
                    userIds.add(PPR.SA__c);
                purchaseTicketsNumber.add(PPR.TicketNumber__c);  // get all the ticket number form new purchacse products
              }
            } else if (CurrentCurrency.equals('EUR')){
                system.debug('###AKK PPR.ConvertedAmountEUR__c = '+PPR.ConvertedAmountEUR__c);
                if(PPR.ConvertedAmountEUR__c >= exceptPurchase){
                    if(!IC_UTILS.empty(PPR.SA__c))
                       userIds.add(PPR.SA__c);
                    purchaseTicketsNumber.add(PPR.TicketNumber__c);  // get all the ticket number form new purchacse products
                    }
            } else if (CurrentCurrency.equals('YEN')){
                if(PPR.ConvertedAmountYEN__c >= exceptPurchase){
                    if(!IC_UTILS.empty(PPR.SA__c))
                       userIds.add(PPR.SA__c);
                    purchaseTicketsNumber.add(PPR.TicketNumber__c);  // get all the ticket number form new purchacse products
                }
            } else if (CurrentCurrency.equals('YUAN')){
               if(PPR.ConvertedAmountYUAN__c >= exceptPurchase){
                    if(!IC_UTILS.empty(PPR.SA__c))
                       userIds.add(PPR.SA__c);
                    purchaseTicketsNumber.add(PPR.TicketNumber__c);  // get all the ticket number form new purchacse products
               }
                        
             }
        }
        
        System.Debug('#########Current Currency :'+CurrentCurrency);
        Set<String> PPR2Exclude = new Set<String>();
        if(purchaseTicketsNumber.size()>0){
            for(Task task : [SELECT Id, RelatedTicketNumber__c FROM Task WHERE recordtypeid=:IC_UTILS.getTaskRT() AND RelatedTicketNumber__c!=null AND RelatedTicketNumber__c IN :purchaseTicketsNumber])
                PPR2Exclude.add(task.RelatedTicketNumber__c);
            //Retrieve users to check if they are active or not 
            activeUsers =   new Map<ID,User>([select ID, IsActive from user Where isActive = true and ID in :userIds]);
        }

        System.debug('##AKK activeUsers='+activeUsers);
        
        for(PPR_PurchProduct__c PPR : newValues)
        {
            System.debug('##AKK PPR='+PPR);
            if(((PPR.ConvertedAmountUSD__c >= exceptPurchase && CurrentCurrency =='USD') || (PPR.ConvertedAmountEUR__c >= exceptPurchase && CurrentCurrency == 'EUR') || (PPR.ConvertedAmountYEN__c >= exceptPurchase && CurrentCurrency == 'YEN') || (PPR.ConvertedAmountYUAN__c >= exceptPurchase && CurrentCurrency == 'YUAN') ) && !PPR2Exclude.contains(PPR.TicketNumber__c))
            {
                System.debug('##AKK exclude ='+  !PPR2Exclude.contains(PPR.TicketNumber__c));
                if(PPR.SA__c != NULL && !IC_UTILS.empty(activeUsers.get(PPR.SA__c)) && PPR.PurchasedDate__c >= system.today().adddays(-14))
                {
                    
                    tasks.add(new task(
                        RelatedTicketNumber__c=PPR.TicketNumber__c,
                        //Exceptional Purchase - Follow Up Call To Do
                        subject=System.Label.IC_ExPPR_FU,
                        ownerid=PPR.SA__c,
                        activitydate=PPR.PurchasedDate__c.adddays(30),
                        whatid=PPR.Client__c,
                        Status=System.Label.IC_New,
                        Priority=System.Label.IC_Normal,
                        TECH_is_AutoSave__c = true,
                        recordtypeid=IC_UTILS.getTaskRT()));
                
                    tasks.add(new task(
                        RelatedTicketNumber__c=PPR.TicketNumber__c,
                        //Exceptional Purchase - Thank You Note To Do
                        subject=System.Label.IC_ExPPR_TY,
                        ownerid=PPR.SA__c,
                        activitydate=PPR.PurchasedDate__c.adddays(5),
                        whatid=PPR.Client__c,
                        Status=System.Label.IC_New,
                        Priority=System.Label.IC_High,
                        TECH_is_AutoSave__c = true,
                        recordtypeid=IC_UTILS.getTaskRT()));
                }
            }
        }
        if (tasks.size() > 0) {
            insert tasks;
        }
    }  
     

}