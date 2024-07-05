/**
    About
    -----
    Description: Methodes for trigger classes 
    Created for: SOW: IC001 ICON project
    Create date: Feb 2013

    Details
    -------
    Class contains all static methodes for triggers

    Update History
    --------------
    Feb 2013 / IC001/ Created by Maroun IMAD
    
    Issues / TODOs
    --------------
*/
public class IC_PPurchase_TRG {

    /**
     * Method for trigger Purchase_BeforeInsert 
     * Check if SA Id is associated to actif User ... otherwise owned by DREAM
     */
     public static void checkIfActifSA(List<PPR_PurchProduct__c> newValues) {
        //Retrieve set of SA IDs from Account to update
        Set<String> sadreamids = new Set<String>();
        for(PPR_PurchProduct__c P : newValues) {
            if(!IC_UTILS.empty(P.DreamIdSA__c)) sadreamids.add(P.DreamIdSA__c);       
        }
        //Retrieve user list in function of saIcondreamids
        List<User> usersFound =  [select ID, DREAMID__C from user Where User.DREAMID__C in :sadreamids];
        Map<String, User> usersMap = new Map<String, User>();
        for (User userfound : usersFound ) {
           
            usersMap.put(userfound.DREAMID__C, userfound);
        }
       
        for(PPR_PurchProduct__c P : newValues) {
            User userId = usersMap.get(P.DreamIdSA__c);
            if(IC_UTILS.empty(userId) || IC_UTILS.empty(userId.DREAMID__C)) {
                P.SA__c = null;
            } else {
                P.SA__c = userId.Id;
            }
        }
    }
    
    /**
    * Method for trigger Purchase_BeforeInsert 
    * Delete same ticket number already loaded in system
    */
    public static void deleteDuplicatePurchProduct(List<PPR_PurchProduct__c> importRecords) {
        //Create ticketNumber list
        Set<String> ticketNumberList = new Set<String>();
        String loadingFileName = ''; 
        //Populate ticketNumber list with records to import
        for(PPR_PurchProduct__c P : importRecords) {
            if(!IC_UTILS.empty(P.TicketNumber__c)) ticketNumberList.add(P.TicketNumber__c); 
            loadingFileName = p.TECH_File__c;     
        }
        //Create record list to delete
        //Populate records list to delete with SOQL query
        List<PPR_PurchProduct__c> recordsToDelete = [select ID from PPR_PurchProduct__c 
                                                     Where PPR_PurchProduct__c.TicketNumber__c in :ticketNumberList
                                                        and TECH_File__c != :loadingFileName];
        //Delete record list    
        if (recordsToDelete.size() > 0) {
            delete recordsToDelete;
        }
    }
    
     /**
     * Method for trigger PPurchase_AfterInsert 
     * Create Exceptional Purchases Tasks
     * CPE - 25/06/2013 - R1.1
     */
    public static void ExcepPurchases(List<PPR_PurchProduct__c> newValues) {
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