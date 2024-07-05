/** * File Name: IC_ClientView_VFCx
* Description : Client View controller
* @author : UNKNOWN
* Modification Log =============================================================== 
* 	RMOU 20/06/16 : added isProspect__pc in Account query, removed isCancelled in Program query
*   RMOU 02/09/16 : PIPA Law enhancements
* */
public without sharing class IC_ClientView_VFCx {
    
    
    public String clientName{get;set;}
    private ApexPages.StandardController stdController;
    public Account client{get;set;}
    private User currentUser;
    public List<OpenActivity> openActivities{get;set;}
    public List<ActivityHistory> ActivityHistories{get;set;}
    public Boolean canEditClient
    {
        get
        {
            return IC_Factory.canPIPACountryEditClient(currentUser.Country__c);
        }
    }
    //public Boolean isPersonAccount{get;set;}
    //public Boolean isStarAccount{get;set;}
    //public Boolean isInStarApp{get;set;}    
    //public String NameApp{get;set;}
    
    
    
    public String openActivitiesLabel{
        get{
            return openActivitiesLabel = Schema.SObjectType.OpenActivity.getLabelPlural();
        }
        set;
    }
    public String openActivityHistoriesLabel{
        get{
            return openActivitiesLabel = Schema.SObjectType.ActivityHistory.getLabel();
        }
        set;
    }
    public Boolean TECH_OwnerManuallyChanged{get;set;}
    
    public IC_ClientView_VFCx(ApexPages.StandardController standardController)
    {
        stdController = standardController;
        client = (Account)standardController.getRecord();
        
        this.client = [Select 
                    //Client Information
                    Id, DreamId__c,OwnerId, owner.name,FirstName, DreamSA__pc,LastName, Segmentation__pc,PersonBirthdate,Occupation__pc,Nationality__pc, 
                    Company__pc,Typology__pc, PreferredContactChannel__pc, AttachedStore__pc, PassportNumber__pc, Title__pc, 
                    // Begin RMO
                    //isProspect
                    isProspect__pc,
                    // End RMO
                    //RecordTypeId, 
                    // Address Information
                    PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryAddressLine3__pc,PrimaryCity__pc,PrimaryZipCode__pc,PrimaryStateProvince__pc, PrimaryCountry__pc,
                    // Contact Information
                    PersonDoNotCall,DoNotSMS__pc,PersonHomePhone,PersonMobilePhone,Phone,PersonEmail,PersonHasOptedOutOfEmail,DoNotContactbyPost__pc, PreferredLanguage__pc, Can_Be_Contacted_By_Phone__pc, Can_Be_Contacted_By_SMS__pc, Can_Be_Contacted_By_Email__pc, Can_Be_Contacted_By_Mail__pc,Invited__pc,Gifts_offered_for_this_clilent__c,

                    //Size informaiton
                    Gender__pc, Belt__pc, Jacket__pc,Shoes__pc, Dress__pc, Ring__pc, Knit__pc, Pant__pc, Shirt__pc, Skirt__pc, Suit__pc,
                    //Accessories Purchase History
                    YTDAccessoriesSpendYUAN__pc, HistoricalAccessoriesNbrProducts__pc, YTDAccessoriesSpendYEN__pc,HistoricalAccessoriesSpendEUR__pc,YTDAccessoriesSpendUSD__pc,HistoricalAccessoriesSpendUSD__pc,
                    YTDAccessoriesSpendEUR__pc, HistoricalAccessoriesSpendYEN__pc,YTDAccessoriesNbrProducts__pc, HistoricalAccessoriesSpendYUAN__pc,  
                    //Jewelry Purchase History
                    YTDJewelryNbrProducts__pc, HistoricalJewelryNbrProducts__pc, YTDJewelrySpendEUR__pc, HistoricalJewelrySpendEUR__pc, YTDJewelrySpendUSD__pc, HistoricalJewelrySpendUSD__pc, 
                    YTDJewelrySpendYEN__pc, HistoricalJewelrySpendYEN__pc, YTDJewelrySpendYUAN__pc, HistoricalJewelrySpendYUAN__pc,
                    //Leather Purchase History
                    YTDLeatherGoodSpendYUAN__pc, HistoricalLeatherGoodSpendYUAN__pc, YTDLeatherGoodSpendYEN__pc, HistoricalLeatherGoodNbrProducts__pc,YTDLeatherGoodSpendUSD__pc, 
                    HistoricalLeatherGoodSpendEUR__pc, YTDLeatherGoodSpendEUR__pc, HistoricalLeatherGoodSpendUSD__pc, YTDLeatherGoodNbrProducts__pc, HistoricalLeatherGoodSpendYEN__pc, 
                    //Wear Purchase History
                    YTDReadyToWearSpendYUAN__pc,HistoricalReadyToWearNbrProducts__pc,YTDReadyToWearNbrProducts__pc, HistoricalReadyToWearSpendEUR__pc, YTDReadyToWearSpendEUR__pc,
                    HistoricalReadyToWearSpendUSD__pc, YTDReadyToWearSpendUSD__pc, HistoricalReadyToWearSpendYEN__pc, YTDReadyToWearSpendYEN__pc, HistoricalReadyToWearSpendYUAN__pc, 
                    //Shoes Purchase History
                    YTDShoesNbrProducts__pc, HistoricalShoesNbrProducts__pc, YTDShoesSpendEUR__pc, HistoricalShoesSpendEUR__pc,YTDShoesSpendUSD__pc, HistoricalShoesSpendUSD__pc, 
                    YTDShoesSpendYEN__pc, HistoricalShoesSpendYEN__pc, YTDShoesSpendYUAN__pc, HistoricalShoesSpendYUAN__pc,  
                    //Watch Purchase History
                    HistoricalWatchNbrProducts__pc, YTDWatchNbrProducts__pc, HistoricalWatchSpendEUR__pc, YTDWatchSpendEUR__pc, HistoricalWatchSpendYUAN__pc, YTDWatchSpendUSD__pc,
                    HistoricalWatchSpendYEN__pc, YTDWatchSpendYEN__pc,HistoricalWatchSpendUSD__pc, YTDWatchSpendYUAN__pc,
                    //Perfume Purchase History
                    HistoricalPerfumeNbrProducts__pc, YTDPerfumeNbrProducts__pc, HistoricalPerfumeSpendEUR__pc, YTDPerfumeSpendEUR__pc, HistoricalPerfumeSpendYUAN__pc, YTDPerfumeSpendUSD__pc,
                    HistoricalPerfumeSpendYEN__pc, YTDPerfumeSpendYEN__pc,HistoricalPerfumeSpendUSD__pc, YTDPerfumeSpendYUAN__pc,
                    //Purchase History
                    LastTrans__pc, FirstTrans__pc, YTDSpendEUR__pc, HistoricalSpendEUR__pc,YTDSpendUSD__pc, HistoricalSpendUSD__pc, YTDSpendYUAN__pc, HistoricalSpendYUAN__pc, 
                    YTDSpendYEN__pc, HistoricalSpendYEN__pc, YTDNbrProducts__pc, HistoricalNbrProducts__pc,
                    //Lifestyle & Family
                    Spouse__pc,  Anniversary__pc, PersonalInterest1__pc, AnniversaryDay__pc, PersonalInterest2__pc, AnniversaryMonth__pc, AnniversaryYear__pc, PersonalInterest3__pc, Children__pc, FoodPreferences__pc, 
                    Pets__pc, BeveragePreferences__pc, ShopsFor__pc, PersonAssistantName, PersonAssistantPhone, 
                    // LV Interests                 
                    AccessoriesInterest__pc, JewelleryInterest__pc, LeatherGoodsInterest__pc, RTWInterest__pc, ShoesInterest__pc, WatchesInterest__pc, PerfumesInterest__pc, OtherInterest__pc,
                    ServiceInterest__pc, EventInterest__pc, 
                    // System Information
                    TECH_DreamIdSA__pc, IsDream__c, TECH_ManualReassignmentDate__c, TECH_OwnerManuallyChanged__c,CreatedById, CreatedDate,LastModifiedById,LastModifiedDate,
                    // Last 36 Month Fields
                    Last36MNbrProducts__pc, Last36MAccessoriesNbrProducts__pc, Last36MAccessoriesSpendEUR__pc, Last36MAccessoriesSpendUSD__pc, Last36MAccessoriesSpendYEN__pc, Last36MAccessoriesSpendYUAN__pc, Last36MJewelryNbrProducts__pc, Last36MJewelrySpendEUR__pc, Last36MJewelrySpendUSD__pc, Last36MJewelrySpendYEN__pc, Last36MJewelrySpendYUAN__pc, Last36MLeatherGoodNbrProducts__pc, Last36MLeatherGoodSpendEUR__pc, Last36MLeatherGoodSpendUSD__pc, Last36MLeatherGoodSpendYEN__pc, Last36MLeatherGoodSpendYUAN__pc, Last36MReadyToWearNbrProducts__pc, Last36MReadyToWearSpendEUR__pc, Last36MReadyToWearSpendUSD__pc, Last36MReadyToWearSpendYEN__pc, Last36MReadyToWearSpendYUAN__pc, Last36MShoesNbrProducts__pc, Last36MShoesSpendEUR__pc, Last36MShoesSpendUSD__pc, Last36MShoesSpendYEN__pc, Last36MShoesSpendYUAN__pc, Last36MSpendEUR__pc, Last36MSpendUSD__pc, Last36MSpendYEN__pc, Last36MSpendYUAN__pc, Last36MWatchNbrProducts__pc, Last36MWatchSpendEUR__pc, Last36MWatchSpendUSD__pc, Last36MWatchSpendYEN__pc, Last36MWatchSpendYUAN__pc, 
                    // Other
                    LastModifierStoreCountry__pc,isPersonAccount,FlowerFlagIcon__pc,Name,
                    //Client OInformation STAR
                    account.salutation,
                    // STAR Dietary Requirements   
                    Star_Allergy__pc, Star_AllergyDetails__pc, Star_FoodPreferences__pc, Star_Beveragepreferences__pc, Star_DetailsDietaryReq__pc, Star_ContactPrefDetails__pc, Star_LVInterestsDetails__pc, Star_CommentPhotoBook__pc,
                    // STAR Lifestyle / LV Interest
                    BirthdateDay__pc, BirthdateMonth__pc, BirthdateYear__pc,
                    // STAR Contact
                    HomePhoneCountrycode__pc
                    From Account  
                    Where Id = :client.Id];
         Account tempClient = [SELECT Name, Salutation,isPersonAccount  from Account where Id = :client.Id];
         clientName = translateClientName(tempClient.Salutation)+' '+tempClient.Name;
         // Set TECH_OwnerManuallyChanged__c flag
         if(client != null)
            TECH_OwnerManuallyChanged = client.TECH_OwnerManuallyChanged__c;
         else
            TECH_OwnerManuallyChanged = false;
        // Retrieve the current user information to check LV Interest, Lifestyle and Size information visibility
        currentUser  = [SELECT Id, country__c,ProfileId FROM USER WHERE Id = :UserInfo.getUserId() limit 1];
        // Check the user is not admin
        
            if(!IC_Factory.isAdmin() && IC_Factory.isPIPACountry(client.LastModifierStoreCountry__pc) && IC_Factory.getPIPACountryCode(currentUser.Country__c) != client.LastModifierStoreCountry__pc)
            {
                client.PreferredContactChannel__pc = null;
                
                // Size Information
                client.Jacket__pc = null;
                client.Dress__pc = null;
                client.Knit__pc = null;
                client.Pant__pc = null;
                client.Shirt__pc = null;
                client.Skirt__pc = null;
                client.Suit__pc = null;
                client.Belt__pc = null;
                client.Shoes__pc = null;
                client.Ring__pc = null;
                
                // Lifestyle & Family
                client.Spouse__pc = null;
                client.AnniversaryMonth__pc = null;
                client.AnniversaryDay__pc = null;
                client.Children__pc = null;
                client.Pets__pc = null;
                client.ShopsFor__pc = null;
                client.PersonalInterest1__pc = null;
                client.PersonalInterest2__pc = null;
                client.PersonalInterest3__pc = null;
                client.FoodPreferences__pc = null;
                client.BeveragePreferences__pc = null;
                client.PersonAssistantName = null;
                client.PersonAssistantPhone = null;
                
                //LV Interests
                client.AccessoriesInterest__pc = null;
                client.JewelleryInterest__pc = null;
                client.LeatherGoodsInterest__pc = null;
                client.RTWInterest__pc = null;
                client.ShoesInterest__pc = null;
                client.WatchesInterest__pc = null;
                client.PerfumesInterest__pc = null;
                client.OtherInterest__pc = null;
                client.ServiceInterest__pc = null;
                client.EventInterest__pc = null;            
            }
        
        
        retrieveActivityHistories();
        retrieveOpenActivities();
        
        /**
        String QueryNameApp = 'SELECT id, Name FROM AppMenuItem';
        String name = Database.query(QueryNameApp );
        
        if(name =='STAR'){
            isPersonAccount = false;
            isStarAccount = true;
        }else
        {
            isPersonAccount = true;
            isStarAccount = false;
        }
        **/
        
               
        //system.debug('##### NameApp :'+NameApp);
        //isPersonAccount = (this.client.RecordTypeId == IC_UTILS.getPersonAccountRT());
        //isStarAccount = (this.client.RecordTypeId == IC_UTILS.getStarAccountRT());
        //system.debug('####### isPersonAccount :' +isPersonAccount);
        //system.debug('####### isStarAccount :' +isStarAccount);
        //isInStarApp = IC_UTILS.inStarApp();
        //system.debug('##### isInStarApp:' +isInStarApp);
        
        
    }
    
     
    public void retrieveOpenActivities()
    {   // The current user infos to filter querries result
        User currentUser = [ Select Id, Country__c,ProfileId From User Where Id = :UserInfo.getUserId()];
        Id myObjectId = String.valueOf(client.get('Id')); 
        String queryOpenActivities = 'select (select Id,WhoId,who.Name, WhatId,what.Name, Subject, IsTask, ActivityType, ActivityDate,  Status, Priority, OwnerId, Owner.Name  FROM OpenActivities ';

        // Check the user is not admin        
        if(!IC_Factory.isAdmin())
        {
            List<String>listCountryCodes = IC_Factory.getListPIPACountryNamesToHide(currentUser.Country__c);
            String countryCodeList = '(\'' + String.join(listCountryCodes, '\',\'') +'\')';
            queryOpenActivities += ' WHERE OwnerId NOT IN (select Id from User where Country__c IN ' + countryCodeList + ')';
        } 
        
        String orderby = ' order by ActivityDate ASC, LastModifiedDate DESC LIMIT 100) FROM Account where Id=:myObjectId';
        String orderbyAC = ' order by ActivityDate ASC, LastModifiedDate DESC LIMIT 100) FROM ActionPlan__c where AccountId__c=:myObjectId';
        System.debug('### query: '+ queryOpenActivities + orderby);
        System.debug('### query: '+ queryOpenActivities + orderbyAC);
        try{
            
            // Get tasks
            Account a = Database.query(queryOpenActivities + orderby);
            openActivities = a.OpenActivities;
            
            // Get tasks created by actionPlan
    //      ActionPlan__c ap;
    //      if(Database.countQuery('Select COUNT() From ActionPlan__c Where AccountId__c=:myObjectId') > 0)
    //          ap = Database.query(queryOpenActivities + orderbyAC);
            
    //        if(!IC_UTILS.empty(ap))
    //          openActivities.addAll(ap.OpenActivities);
            
        }catch(Exception e){
            System.debug('## Error: '+e.getMessage());
        }
    }
    
    public void retrieveActivityHistories()
    {   // The current user infos to filter querries result
        User currentUser = [ Select Id, Country__c,ProfileId From User Where Id = :UserInfo.getUserId()];
        Id myObjectId = String.valueOf(client.get('Id')); 
        String queryActivityHistories = 'select (select Id,WhoId,who.Name, WhatId,what.Name, Subject, IsTask, ActivityType, ActivityDate,  Status, Priority, OwnerId, Owner.Name  FROM  ActivityHistories ';
        // Check the user is not admin
        
        if(!IC_Factory.isAdmin())
        {
            List<String>listCountryCodes = IC_Factory.getListPIPACountryNamesToHide(currentUser.Country__c);
            String countryCodeList = '(\'' + String.join(listCountryCodes, '\',\'') +'\')';
            queryActivityHistories += ' WHERE OwnerId NOT IN (select Id from User where Country__c IN ' + countryCodeList + ')';
        } 
        
        String orderby = ' order by ActivityDate DESC, LastModifiedDate DESC LIMIT 100) FROM Account where Id=:myObjectId';
        String orderbyAC = ' order by ActivityDate DESC, LastModifiedDate DESC LIMIT 100) FROM ActionPlan__c where AccountId__c=:myObjectId';
        System.debug('### query: '+ queryActivityHistories + orderby);
        try{
            Account a = Database.query(queryActivityHistories + orderby);
            ActivityHistories = a.ActivityHistories;
            
            // Get tasks created by actionPlan
    //      ActionPlan__c ap;
    //      if(Database.countQuery('Select COUNT() From ActionPlan__c Where AccountId__c=:myObjectId') > 0)
    //          ap = Database.query(queryActivityHistories + orderbyAC);
                
    //      if(!IC_UTILS.empty(ap))
    //              ActivityHistories.addAll(ap.ActivityHistories);
            
            System.debug('### AH size: '+ActivityHistories.size());
        }catch(Exception e){
            System.debug('## Error: '+e.getMessage());
        }
    }
    
    public List<PPR_PurchProduct__c> PProducts{
        get{
            if(PProducts == null)   // The current user infos to filter querries result
            {
                User currentUser = [ Select Id, Country__c,ProfileId From User Where Id = :UserInfo.getUserId()];
                Id myObjectId = String.valueOf(client.get('Id')); 
                String queryProduct = 'select Name,PurchasedDate__c,SKU__c,Amount__c,CurrencyCode__c,ConvertedAmountUSD__c,ConvertedAmountEUR__c from PPR_PurchProduct__c where Client__c=:myObjectId';
                // Check the user is not admin
                
                if(!IC_Factory.isAdmin())
                {
                    List<String>listCountryCodes = IC_Factory.getListPIPACountryCodesToHide(currentUser.Country__c);
                    String countryCodeList = '(\'' + String.join(listCountryCodes, '\',\'') +'\'';
                    queryProduct += ' AND PurchaseCountry__c NOT IN ' + countryCodeList + ')';
                } 
                
                String orderby = ' order by PurchasedDate__c DESC LIMIT 1000';
                System.debug('### query: '+queryProduct + orderby);
                try{
                    PProducts = Database.query(queryProduct + orderby); 
                }catch(Exception e){
                    System.debug('## Error: '+e.getMessage());
                    return null;
                }
            }
            return PProducts;
        }
        set;
    }
    
    // PPurchurchProduct for STAR Client Detail 
    public ApexPages.StandardSetController setCon 
    {
        get {  
            if(setCon == null) {
                User currentUser = [ Select Id, Country__c,ProfileId From User Where Id = :UserInfo.getUserId()];
                Id myObjectId = String.valueOf(client.get('Id')); 
                String queryProduct = 'select Name,PurchasedDate__c,SKU__c,Amount__c,CurrencyCode__c,ConvertedAmountUSD__c,ConvertedAmountEUR__c from PPR_PurchProduct__c where Client__c=:myObjectId';
                // Check the user is not admin
                
                if(!IC_Factory.isAdmin())
                {
                    List<String>listCountryCodes = IC_Factory.getListPIPACountryCodesToHide(currentUser.Country__c);
                    String countryCodeList = '(\'' + String.join(listCountryCodes, '\',\'') +'\')';
                    queryProduct += ' AND PurchaseCountry__c NOT IN ' + countryCodeList + ')';
                } 
                
                String orderby = ' order by PurchasedDate__c DESC LIMIT 1000';
                System.debug('### query: '+queryProduct + orderby);
                
                setCon = new ApexPages.StandardSetController(Database.Query(queryProduct + orderby));
                      
                 }
             
            return setCon;
          }
          set;
    }
    
    public List<PPR_PurchProduct__c> getPurchProducts() {
    	     	
         	setCon.setpagesize(10);
         
         return (List<PPR_PurchProduct__c>) setCon.getRecords();
     
    }
     public List<ActionPlan__c> getActionPlans() {
        
        String clientId = client.Id;
        String queryList = 'select c.name, c.id, c.Comments__c, c.DueDate__c, c.IsClosed__c, c.AccountId__c, c.Subject__c, c.AccountId__r.Name, c.AccountId__r.FirstName, c.AccountId__r.LastName from ActionPlan__c c WHERE c.AccountId__c = :clientId '; 
        String orderby = ' Order by c.DueDate__c asc';
        List<ActionPlan__c> actionLists = Database.query(queryList + orderby); 
        System.debug ('*** Action Plan List size = ' + actionLists.size());
        return actionLists;
        
    }
    
    
    //Event Based on the object Program 
    public List<Program__c> getEventProg(){
               
        String clientId = client.Id;
        // Begin MTO: correction classe de tests suite aux evos sur le photo book
        //String queryEventProg = 'select id, Name, Cancelled__c, Car_required__c, AccountId__c, EventId__c, EventId__r.name, Visit_from__c, Visit_to__c, Flight_paid__c, Status__c from Program__c where AccountId__c=:clientId';
        //---
        // Begin RMO: Removing deleted field Cancelled__c from query [Icon Star Evol]
        //String queryEventProg = 'select id, Name, Cancelled__c, Car_required__c, AccountId__c, EventId__c, EventId__r.name, Visit_from__c, Visit_to__c, Flight_paid__c, Status__c from Program__c where AccountId__c=:clientId';
        String queryEventProg = 'select id, Name, Car_required__c, AccountId__c, EventId__c, EventId__r.name, Visit_from__c, Visit_to__c, Flight_paid__c, Status__c from Program__c where AccountId__c=:clientId';
        // End RMO
        // End MTO
        List<Program__c> progLists =  Database.query(queryEventProg );        
        return  progLists;
                
    }
    
    
    public Pagereference logACall()
    {
        return new Pagereference('/00T/e?title=Call&who_id='+client.Id+'&what_id='+client.Id+'&followup=1&tsk5=Call&retURL=%2F'+client.Id);
    }
    public Pagereference newToDo()
    {
        return new Pagereference('/00T/e?who_id='+client.Id+'&what_id='+client.Id+'&retURL=%2F'+client.Id);
    }
    
    public Pagereference newAppointment()
    {
        return new Pagereference('/00U/e?who_id='+client.Id+'&what_id='+client.Id+'&retURL=%2F'+client.Id);
    }
    
    public Pagereference editClient()
    {
        return stdController.edit();
    }
    
    public Pagereference deleteClient()
    {
        return stdController.delete();
    }
    
    public static String translateClientName(String clientNameCode){
        return IC_UTILS.getTranslationPicklistValue('Contact', 'Salutation', clientNameCode);
    }
    
}