/**
    About
    -----
    Description: Methodes for trigger classes 
    Created for: ICON project
    Create date: Sep 2015

    Details
    -------
    Class contains all static methodes for triggers

    Update History
    --------------
    Sep 2015 / Created by STI
    
    Issues / TODOs
    --------------
*/ 
public class IC_Event_TRG {

    /** 
    * Method for trigger Event_AfterInsert, Event_AfterUpdate 
    * Method for batch IC_BatchEventLastContactDate
    * This trigger is fired only when==============================
    */
    public static void eventSetAccLastContactDate(List<Event> lstEvent){
       
       /*
           QUERY : 
           Select Id, AccountId, ActivityDate, Account.LastContactDate__pc from Events
           Where (ActivityDate = TODAY or ActivityDate = LAST_N_DAYS:30) 
           
           ------------------------------------------------------------------
           IF event.activityDate > account.LastContactDate => update account
           IF event.activityDate <= account.LastContactDate => no update
       */
       
       Map<Id, Date> mapAcc = new Map<Id, Date>();
       for(Event e:lstEvent){
           System.debug(' ############ event : '+e);
           if(!mapAcc.containsKey(e.AccountId)){
               if(e.ActivityDate > e.Account.LastAppointmentDate__pc || e.Account.LastAppointmentDate__pc==null){
                   mapAcc.put(e.accountId, e.ActivityDate);
               }
           }else{
               if(e.ActivityDate > mapAcc.get(e.AccountId)){
                   mapAcc.put(e.accountId, e.ActivityDate);
               }
           }
       }
       
       List<Id> lstAccId = new List<Id>(mapAcc.keySet());
       //builds list of accounts to update with new date

       if(lstAccId.size() > 0){
        List<Account> lstAcc = new List<Account>();
        lstAcc = [Select id, LastAppointmentDate__pc from Account where id in :lstAccId];
        
        for(Account acc :lstAcc){
            acc.LastAppointmentDate__pc = mapAcc.get(acc.id);
            System.debug ('acc.LastAppointmentDate__pc CLS' + acc.LastAppointmentDate__pc);
        }
        /**
        for(Id i:lstAccId){
            lstAcc.add(new Account(Id=i, LastContactDate__pc=mapAcc.get(i)));
        }  **/
        System.debug('######### list account to update: '+lstAcc ); 
        update lstAcc;
       }
       
    }
   
   public static List<Event> toFilterEventList(List<Event> MyEvent){
       List<Event> result = new List<Event>();
       
       Integer lastContactTimeRange = Integer.valueOf(ICONSettings__c.getOrgDefaults().get('AccLastContactTimeRange__c'));
       if (IC_UTILS.empty(lastContactTimeRange)) {
           lastContactTimeRange = 0;
       }
       Date dateOfToday = System.today();
       for(Event evt: MyEvent){
           if(evt.ActivityDate != null){
               if((evt.activityDate <= dateOfToday) && (evt.activityDate > dateOfToday - lastContactTimeRange)){
                   result.add(evt);
               }
           }
       }
       System.debug('##### toFilterEventList result '+ result);
       return result; 
   }   
   
   /*
   Création d’un automatisme avec les conditions suivantes : 
   Dans appointement si le lookup purchased product est renseigné alors,

     appointement.salesAmount = purchasedProduct.montantTotalTransaction 
     Activity.SaleAmount__c = PPR_PurchProduct.TransactionTotalAmount__c
   Purchased_Product__c
     appointment.relatedticketNumber = purchasedProduct.transactionProduct    
     Activity.RelatedTicketNumber__c = PPR_PurchProduct.TechTransactionId__c
   */
   public static void PopulateTransAppointement(List<Event> e){
       System.debug ('allo');
       List<Id> listId = new List<Id>();
       
       For (event ev : e){
           if (ev.Purchased_Product__c != null) {
            listid.add(ev.Purchased_Product__c );
           }
       }
       List<PPR_PurchProduct__c> PPs = new List<PPR_PurchProduct__c>();
       if(listid.size() > 0) {
        PPs = [SELECT id, TransactionTotalAmount__c, TechTransactionId__c, CurrencyCode__c
        FROM PPR_PurchProduct__c 
        WHERE Id IN: (listId) ];
       }

       
       For (Event varEvent : e) {
           System.debug ('e -> ' + e);
           if (varEvent.Purchased_Product__c != null){
           
               PPR_PurchProduct__c pp = null;
               for (PPR_PurchProduct__c Purchp :PPs){
                   if (varEvent.Purchased_Product__c == Purchp.id){
                       pp = Purchp;
                   }
               }
               System.debug ('pp -> ' + pp);

               if (pp != null){
                   varEvent.RelatedTicketNumber__c=pp.TechTransactionId__c;
                   varEvent.SaleAmount__c=pp.TransactionTotalAmount__c;
                    varEvent.Currency__c=pp.CurrencyCode__c;
               } else{
                   varEvent.RelatedTicketNumber__c=null;
                   varEvent.SaleAmount__c=null;
                   varEvent.Currency__c=null;
               }
           }else{
               varEvent.RelatedTicketNumber__c=null;
               varEvent.SaleAmount__c=null;
               varEvent.Currency__c=null;
           }
           System.debug ('varEvent -> ' + varEvent);
       }
   }

   public static void setStoreAppointment(map<String, list<Event>> toAddStore){
       List<User> owners = [select Id, DefaultStore__c From User where Id IN :toAddStore.keySet()];
       Set<String > storeCodes = new Set<String>();
       for(User owner : owners){
            if(owner.DefaultStore__c != null){
                storeCodes.add(owner.DefaultStore__c);
            }
       }
       Map<String, Store__c> storeMap = storeCodeMap(storeCodes);
       for(User owner : owners){
           for(Event ev : toAddStore.get(owner.Id)){
               try{
                   if(owner.DefaultStore__c != null && storeMap.get(owner.DefaultStore__c) != null)
                       ev.Store_Location__c = storeMap.get(owner.DefaultStore__c).Id;
               } catch(Exception e){
                   system.debug(e.getMessage());
               }
               
           }
       }
   }

   public static void setStoreUserOwner(map<String, list<Event>> toAddStoreOwner){
    //    map<String, list<Event>> storeCodeAptMap = new map<String, list<Event>>();
    //    List<Store__c> stores = [select Id, RetailStoreId__c from store__c where Id IN :toAddStoreOwner.keySet() ];
    //    for(Store__c s :stores){
    //        storeCodeAptMap.put(s.RetailStoreId__c, toAddStoreOwner.get(s.Id));
    //    }
    //    List<User> owners = [select Id, DefaultStore__c From User where DefaultStore__c IN :storeCodeAptMap.keySet() AND username like 'store_%'];
    //    for(User owner : owners){
    //        for(Event ev : storeCodeAptMap.get(owner.DefaultStore__c)){
    //            try{
    //                if(owner.DefaultStore__c != null)
    //                    ev.OwnerId = owner.Id;
    //            } catch(Exception e){
    //                system.debug(e.getMessage());
    //            }
               
    //        }
    //    }

       Map<String, User> mapStoreIdUserStore =  getStoreUsers();
       for(String storeId : mapStoreIdUserStore.keySet()){
           if( toAddStoreOwner.get(storeId) != null ){
                for(Event ev : toAddStoreOwner.get(storeId)){
                    try{
                        if(mapStoreIdUserStore.get(storeId) != null)
                            ev.OwnerId = mapStoreIdUserStore.get(storeId).Id;
                    } catch(Exception e){
                        system.debug(e.getMessage());
                    }
                    
                }
           }
            
        }   

   }

   public static Map<String, User> getStoreUsers() {
        if(mapStoreIdUser != null) {
            return mapStoreIdUser;
        }
        Map<String, Store__c> storeCodeMap = storeCodeMap();
        List<User> owners = [select Id, DefaultStore__c From User where is_identity_user__c = false  AND username like 'store_%' ] ;
        Map<String, User> mapStoreIdUserStore = new  Map<String, User>();
        for(User o : owners){
            if(String.isNotBlank(o.DefaultStore__c) && storeCodeMap.get(o.DefaultStore__c) != null){
                mapStoreIdUserStore.put(storeCodeMap.get(o.DefaultStore__c).Id, o);
            }
        }

        mapStoreIdUser = mapStoreIdUserStore;
        return mapStoreIdUser;

   }

   public static Map<String, Store__c> storeCodeMap(){
    List<Store__c> stores = [select Id, RetailStoreId__c from store__c Where  status__c = 'Open' ];
    Map<String, Store__c> storeCodeMap = new Map<String, Store__c>();
    for(Store__c s : stores) {
        if(String.isNotBlank(s.RetailStoreId__c))
            storeCodeMap.put(s.RetailStoreId__c, s);
    }
    return storeCodeMap;
   }

   public static Map<String, Store__c> storeCodeMap(Set<String> storeCodes){
    List<Store__c> stores = [select Id, RetailStoreId__c from store__c Where  RetailStoreId__c IN : storeCodes ];
    Map<String, Store__c> storeCodeMap = new Map<String, Store__c>();
    for(Store__c s : stores) {
        if(String.isNotBlank(s.RetailStoreId__c))
            storeCodeMap.put(s.RetailStoreId__c, s);
    }
    return storeCodeMap;
   }

   public static  Map<String, User> mapStoreIdUser;
}