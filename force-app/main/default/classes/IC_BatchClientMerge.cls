/*
About
-----
Description: Batch for Merging Client
Created for: ICON 2.5
Create date: Dec 2014

Details
-------


Update History
--------------
03/08/2016 MTOU - adding perfume infos on client merge
18/08/2016 MTOU - bug fixing: merging clients with surveys
02/09/2016 RMOU - PIPA Law enhancements
22/09/2016 RMOU - Campaign History fix
21/12/2016 RMOU - DML Exception fix
22/11/2021 IALSID - Add New Object Transfer Campaign History For DECO DREAM
10/10/2023 ALAM - Add murge of MyLV (Club_MemberShip__c,Badge_Collection__c, Favorite_Club_Member__c, Brand_Experience_Variation_Member__c )

Issues / TODOs
--------------
*/

global class IC_BatchClientMerge implements Database.Batchable<sObject> {
    
   
    private String accountId;  
    private List<Account> absorbedClients;
    private List<Account> absorbedClientsWithExistingMaster; 
    private List<Account> masterClients;
    private List<Account> masterClientsAC;
    private Set<Id> masterAccountsIds = new Set<Id>();
    private Map<String, Account> mapMasterDreamIdClientAC = new Map<String, Account>();
    private Map<String, String>  mapMasterWhoIdActionPlan = new Map<String, String>();
    
    private List<Event> absorbedEvents;
    private List<Event> absorbedEventsActionPlan;
    private List<Task> absorbedTask;
    private List<Task> absorbedTaskActionPlan;
    private List<Asset> absorbedAssets;
    private List<Interests__c> absorbedInterests;
    private List<ActionPlan__c> absorbedActionPlans;
    private List<ActionPlan__c> lstForMap = new List<ActionPlan__c>();
    private List<Account> lstAccount = new List<Account>();
    
    private List<CLM_CliListMember__c> clientListMemberList;
    private List<CLM_CliListMember__c> clientListMemberToDelete = new List<CLM_CliListMember__c>();
    private List<CLM_CliListMember__c> clientListMemberToUpdate = new List<CLM_CliListMember__c>();
    
    private List<MergedClients__c> mergedClient;
    
    public String query;
    public Integer clientMergeLimit;
    public static List<Account> lstClients; 
    
    private Map<String, Account> mapAccIdClient = new Map<String, Account>();
    private Map<String, Account> mapAccDreamIdClient = new Map<String, Account>();
    private Map<String, Account> mapAccMasterDreamIdClient = new Map<String, Account>();
    private Map<String, Account> mapAccPersonContactIdClient = new Map<String, Account>();
    private Map<String, Account> mapMasterDreamIdClient = new Map<String, Account>();
    
    
    private List<String> lstabsorbedAccWithExistingMasterID = new List<String>();
    private List<String> lstAccDreamId = new List<String>();
    private List<String> lstAccMasterDreamId = new List<String>();
    private List<String> lstAccPersonContactId = new List<String>();
    
    private List<String> lstActionPlanId = new List<String>();
    private List<String> lstIdMaster = new List<String>(); 
    
    List<MergedClients__c> mergeClientList = new List<MergedClients__c>();
    
    private List<VO_Survey__c> absorbedSurvey;
    private List<et4ae5__IndividualEmailResult__c> absorbedIndividualEmailResult;
    private List<et4ae5__SMSDefinition__c> absorbedSMSDefinition; 
    private List<Opportunity> absorbedOpportunity;
    
    private Map<ID, List<Campaign_History__c>> absorbedCampaignHistoryMap = new Map<ID, List<Campaign_History__c>>();
    private List<Campaign_History__c> transferedCampaignHistory = new List<Campaign_History__c>();
    
    private Map<ID, List<Transac_Notification_History__c>> absorbedTranNotHistMap = new Map<ID, List<Transac_Notification_History__c>>();
    private List<Transac_Notification_History__c> transferedTranNotHist= new List<Transac_Notification_History__c>();
    
    private Map<ID, List<Program__c>> absorbedProgramsMap = new Map<ID, List<Program__c>>();
    private List<Program__c> transferedPrograms = new List<Program__c>();
    
    private List<Case> absorbedCases;
    
    private List<Calling_Campaign__c> absorbedCallingCampaigns;
    
    // ICON
    private List<CareService__c> absorbedCareServices;
    private List<Look_Share__c> absorbedLookShare;    
    
    // NOTIFICATION
    private List<Notification__c> absorbedNotifications;
    
    // SOCIAL MEDIA
    private List<Social_Media_identifier__c> socialMediaIdentifiers;
    private List<Social_Media_identifier__c> socialMediaIdentifiersToUpdate = new List<Social_Media_identifier__c>();
    private List<Social_Media_identifier__c> socialMediaIdentifiersToDelete = new List<Social_Media_identifier__c>();
    
    // EXCLUSIVE EXPERIENCE
    private List<Exclusive_Experience__c> exclusiveExperiences;
    private List<Exclusive_Experience__c> masterExclusiveExperiences;
    private List<Exclusive_Experience__c> exclusiveExperiencesToUpdate = new List<Exclusive_Experience__c>();
    private List<Exclusive_Experience__c> exclusiveExperiencesToDelete = new List<Exclusive_Experience__c>();
    
    // EXCLUSIVE EXPERIENCE ORDER
    private List<Exclusive_Campaign_Order__c> exclusiveCampaignOrder;
    private List<Exclusive_Campaign_Order__c> exclusiveCampaignOrderToUpdate = new List<Exclusive_Campaign_Order__c>();
    
    // ORDER
    private List<Order__c> absorbedOrders;
    
    // COLLECTIBLE WALLET
    private List<Collectible_Wallet__c> absorbedCollectibleWallet = new List<Collectible_Wallet__c>();
    
    //New objects to merge - By Hamza
    
    private List<Alias_Member__c> absorbedAliasMembers = new List<Alias_Member__c>();    
    private List<Family_Member__c> absorbedFamilyMembers = new List<Family_Member__c>();
    private List<TR_MyLV_Diamond__c> absorbedTRMyLVDiamond = new List<TR_MyLV_Diamond__c>();
    private List<Tag__c> absorbedTags = new List<Tag__c>();
    
    //LV clubMemberShip - By Ayoub
	// lvclub#features
    private List<Club_MemberShip__c> clubMemberShipToUpdate = new List<Club_MemberShip__c>();
    private List<Club_MemberShip__c> absorbedClubMembership = new List<Club_MemberShip__c>();
    private List<Club_MemberShip__c> mastersClubMembership = new List<Club_MemberShip__c>();
    private List<Club_MemberShip__c> absorbedANDmastersClubMembership = new List<Club_MemberShip__c>();
    private List<Badge_Collection__c> badgeToUpdate = new List<Badge_Collection__c>();
    private List<Favorite_Club_Member__c> favoriteToUpdate = new List<Favorite_Club_Member__c>();
    private List<Brand_Experience_Variation_Member__c> brandToUpdate = new List<Brand_Experience_Variation_Member__c>();

    Set<Id> clubMemberShipsIds = new Set<Id>();
    Map<String, List<Club_MemberShip__c>> dreamIdToClubs = new Map<String, List<Club_MemberShip__c>>();
    Map<Id, Club_MemberShip__c> idToClub = new Map<Id, Club_MemberShip__c>();
    List<Club_MemberShip__c> lstclubsAbsorbed = new List<Club_MemberShip__c>();
    List<String> clubsMasterID = new List<String>();
    List<String> clubsAbsorbedID = new List<String>();
	
    global IC_BatchClientMerge() {
        clientMergeLimit = Integer.valueOf((Decimal)ICONSettings__c.getOrgDefaults().get('clientMergeLimit__c'));
        query = 'SELECT ID, DreamID__c, DreamIdMasterClient__c, MasterClientSFID__c, PrimaryCountry__pc, PersonContactId,  ' +
            'Gender__pc, Jacket__pc , Dress__pc , Knit__pc , Pant__pc , Shirt__pc , Skirt__pc , ' +
            'Suit__pc , Belt__pc , Shoes__pc , Ring__pc , Spouse__pc , ' +
            'AnniversaryMonth__pc , AnniversaryDay__pc , AnniversaryYear__pc , Children__pc , Pets__pc , ShopsFor__pc , ' +
            'PersonalInterest1__pc , PersonalInterest2__pc , PersonalInterest3__pc , FoodPreferences__pc , BeveragePreferences__pc , ' +
            'PersonAssistantName , PersonAssistantPhone , AccessoriesInterest__pc , JewelleryInterest__pc , LeatherGoodsInterest__pc , ' +
            'RTWInterest__pc , ShoesInterest__pc , WatchesInterest__pc , OtherInterest__pc , ServiceInterest__pc , EventInterest__pc, PerfumesInterest__pc, ' + 
            'PersonEmail, Unsubscribe__pc, UnsubscribeDate__pc, PersonHasOptedOutOfEmail, DoNotSMS__pc, DoNotContactbyPost__pc ' +
            'FROM Account WHERE ToDelete__c=\'1\' AND DreamIdMasterClient__c!=null AND  Date_Identity__pc=null';
        if(clientMergeLimit != null)
            query = query + ' Limit :clientMergeLimit';
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account> lstClients = new List<Account>();
        
        for(sObject o:scope){
            Account client = (Account)o;
            lstClients.add(client);
        }
        this.mergeClient(lstClients);
    } 
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    
    /*  \return: void 
*  \brief: Merge Client, 
*/
    private void mergeClient(List<Account> lstClients) {
        
        //List<MergedClients__c> mergeClientList = new List<MergedClients__c>();
        
        // Querying
        initAbsorbedClients(lstClients);
        // Checking if there is available absorbedClients
        if(absorbedClients == null || absorbedClients.size() == 0){
            System.debug('#### Probleme : Pas de clients selectionnés !');
            return;
        }
        for(Account account : absorbedClients) 
        {
            //initialize the list of all master dream ids
            if(account.DreamIdMasterClient__c!=null)lstAccMasterDreamId.add(account.DreamIdMasterClient__c);
        }
        initMasterClients();
        initAbsorbedClientsWithExistingMaster(); // added by MTOU
        for(Account account : absorbedClientsWithExistingMaster) {
            //initialize the map on Account Id
            mapAccIdClient.put(account.Id, account);
            //initialize the map on Account DreamID
            mapAccDreamIdClient.put(account.dreamID__c, account);
            //initialize the map on Account Master dream id
            mapAccMasterDreamIdClient.put(account.DreamIdMasterClient__c, account);
            //initialize the map on Person Contact id
            mapAccPersonContactIdClient.put(account.PersonContactId, account);
            //initialize the list of all account ids
            lstabsorbedAccWithExistingMasterID.add(account.id);
            //initialize the list of all dream ids
            lstAccDreamId.add(account.dreamID__c);
            //initialize the list of all master dream ids
            //lstAccMasterDreamId.add(account.DreamIdMasterClient__c); // deactivated by MTOU
            //initialize the list of all person contact ids (personcontactid = contactId of the account)
            lstAccPersonContactId.add(account.PersonContactId);
        }
        
        // initMasterClients(); deactivated by MTOU
        
        initAbsorbedActivities();
        initMergedClients();
        initClientListMemberList();
        initCampaignHistory();
        initTranNotHist();
        initPrograms();
        
        
        //for(Account account : absorbedClients) {
        for(Account account : absorbedClientsWithExistingMaster) {
            // Creating the Merged CLient Object
            mergeClientList.add(createMergedClientObject(account));
            // Transfering private data from account to master
            transfertPrivateData(account, masterClients);
            transferCampaignHistory(account);
            transferTranNotHist(account);
            transferPrograms(account);
        }
        // Transfering Events & Task & ActionPlans
        //transfertEvents(absorbedClients, absorbedEvents);// deactivated by MTOU
        transfertEvents(absorbedClientsWithExistingMaster, absorbedEvents);
        //transfertTask(absorbedClients, absorbedTask);// deactivated by MTOU
        transfertTask(absorbedClientsWithExistingMaster, absorbedTask);
        transfertActionPlan(absorbedActionPlans);
        initActionPlanMap();
        transfertEventForActionPlan();
        transfertTaskForActionPlan();
        // Updating the current Merged Client Objects
        //transfertMergedClient(absorbedClients, mergedClient); // deactivated by MTOU
        transfertMergedClient(absorbedClientsWithExistingMaster, mergedClient);
        // Updating the Client List by updating the Client List Member Object
        //transfertClientList(absorbedClients, clientListMemberList, masterClients); // deactivated by MTOU
        transfertClientList(absorbedClientsWithExistingMaster, clientListMemberList, masterClients);
        //transferring assets and interests
        absorbedInterests = transfertInterests(absorbedClientsWithExistingMaster,absorbedInterests);
        transfertAssets(absorbedClientsWithExistingMaster,absorbedAssets);
        //Evol Voice
        transfertSurvey (absorbedSurvey);
        transfertIndividualEmailResult(absorbedIndividualEmailResult);
        transfertSMSDefinition(absorbedSMSDefinition);
        transfertOpportunity(absorbedOpportunity);
        transferCase(absorbedCases);
        transferCallingcampaign(absorbedCallingCampaigns);
        transferCareService(absorbedCareServices);
        transferLookShare(absorbedLookShare);
        
        
        // NOTIFICATION
        transferNotification(absorbedNotifications);
        
        transferOrders(absorbedOrders);
        transferCollectibleWallets();

        
        //SOCIAL MEDIA 
        transferSocialMediaIdentifier(socialMediaIdentifiers);
        transferExclusiveExperience(exclusiveExperiences, masterExclusiveExperiences);
        transferExclusiveCampaignOrder(exclusiveCampaignOrder);
        //Alias Member & Family Member & Tags & Lv Diamond
        transferAliasMembre();
        transferMyLvDiamond();
        transferFamilyMember();
        transferTags();
        
        // lvclub#features
        transferFavoritClubMember();
        transferBrandExperience();
        transferClubMemberShip();
        
        // deactivated by MTOU: moved to finish method
        //try  { 
        if(masterClients               != null && masterClients.size()               > 0) update masterClients;       
        if(absorbedEvents              != null && absorbedEvents.size()              > 0) update absorbedEvents;
        if(absorbedEventsActionPlan      != null && absorbedEventsActionPlan.size()      > 0) update absorbedEventsActionPlan;     
        if(absorbedTask                != null && absorbedTask.size()                > 0) update absorbedTask;
        if(absorbedTaskActionPlan        != null && absorbedTaskActionPlan.size()        > 0) update absorbedTaskActionPlan;
        if(absorbedActionPlans         != null && absorbedActionPlans.size()         > 0) update absorbedActionPlans;          
        if(absorbedInterests         != null && absorbedInterests.size()         > 0) upsert absorbedInterests;          
        if(absorbedAssets         != null && absorbedAssets.size()         > 0) update absorbedAssets;          
        if(mergeClientList             != null && mergeClientList.size()             > 0) insert mergeClientList;              
        if(mergedClient                != null && mergedClient.size()                > 0) update mergedClient;        
        if(clientListMemberToDelete        !=null &&  clientListMemberToDelete.size()        > 0) delete clientListMemberToDelete;
        if(clientListMemberToUpdate        != null && clientListMemberToUpdate.size()        > 0) update clientListMemberToUpdate;
        //Evol Voice
        if(absorbedSurvey          != null && absorbedSurvey.size()          > 0) update absorbedSurvey;
        if(absorbedIndividualEmailResult   != null && absorbedIndividualEmailResult.size()   > 0) update absorbedIndividualEmailResult;
        if(absorbedSMSDefinition       != null && absorbedSMSDefinition.size()       > 0) update absorbedSMSDefinition;
        if(absorbedOpportunity         != null && absorbedOpportunity.size()         > 0) update absorbedOpportunity;
        //Fix RMOU
        if(transferedCampaignHistory   != null) update transferedCampaignHistory;
        //Fix IALSID
        if(transferedTranNotHist        != null) update transferedTranNotHist;
        if(transferedPrograms          != null) update transferedPrograms;
        // ICONiCS
        if(absorbedCases             != null && absorbedCases.size()         > 0)        update absorbedCases;
        //Calling Campaign
        if(absorbedCallingCampaigns  != null && absorbedCallingCampaigns.size() > 0)     update absorbedCallingCampaigns;
        // ICON
        if(absorbedCareServices             != null && absorbedCareServices.size()         > 0)        update absorbedCareServices;
        if(absorbedLookShare             != null && absorbedLookShare.size()         > 0)        update absorbedLookShare;
        // ICON
        if(absorbedNotifications             != null && absorbedNotifications.size()         > 0)        update absorbedNotifications;
        
        if(absorbedOrders != null && absorbedOrders.size() > 0) update absorbedOrders;
        
        // SOCIAL MEDIA
        if(socialMediaIdentifiersToDelete             != null && socialMediaIdentifiersToDelete.size()         > 0)        delete socialMediaIdentifiersToDelete;
        if(socialMediaIdentifiersToUpdate             != null && socialMediaIdentifiersToUpdate.size()         > 0)        update socialMediaIdentifiersToUpdate;
        
        // EXCLUSIVE EXPERIENCE
        if(exclusiveExperiencesToDelete             != null && exclusiveExperiencesToDelete.size()         > 0)        delete exclusiveExperiencesToDelete;
        if(exclusiveExperiencesToUpdate             != null && exclusiveExperiencesToUpdate.size()         > 0)        update exclusiveExperiencesToUpdate;
        
        // EXCLUSIVE CAMPAIGN ORDER
        if(exclusiveCampaignOrderToUpdate             != null && exclusiveCampaignOrderToUpdate.size()         > 0)        update exclusiveCampaignOrderToUpdate;

        if(absorbedAliasMembers != null && absorbedAliasMembers.size() > 0) update absorbedAliasMembers;
        if(absorbedTags != null && absorbedTags.size() > 0) update absorbedTags;
        if(absorbedTRMyLVDiamond != null && absorbedTRMyLVDiamond.size() > 0) update absorbedTRMyLVDiamond;
        if(absorbedFamilyMembers != null && absorbedFamilyMembers.size() > 0) update absorbedFamilyMembers;
        if(!absorbedCollectibleWallet.isEmpty()) update absorbedCollectibleWallet;    

        //Lv CLUB
        //lvclub#features
        if(badgeToUpdate != null && badgeToUpdate.size() > 0) update badgeToUpdate;
        if(favoriteToUpdate != null && favoriteToUpdate.size() > 0) update favoriteToUpdate;
        if(brandToUpdate != null && brandToUpdate.size() > 0) update brandToUpdate;
        if(clubMemberShipToUpdate != null && clubMemberShipToUpdate.size() > 0) update clubMemberShipToUpdate;
        
        
        // Begin MTOU: only delete accounts with a master
        //if(absorbedClients             != null && absorbedClients.size()             > 0) delete absorbedClients;
        if(absorbedClientsWithExistingMaster != null && absorbedClientsWithExistingMaster.size() > 0) delete absorbedClientsWithExistingMaster; 
        
        
        
        //} catch (DmlException e) {
        //     System.debug('*** Error DML - mergeClient : ' + e);
        //}
    }
    
    
    private void initAbsorbedClients(List<Account> lstClients) {
        // Initialize associed list
        absorbedClients  =  lstClients;
    }
    
    private void initMasterClients() {
        masterClients    = [SELECT ID, Firstname, Lastname, Salutation, DreamID__c, DreamIdMasterClient__c, MasterClientSFID__c, PrimaryCountry__pc, PersonContactId, Gender__pc, 
                            Jacket__pc , Dress__pc , Knit__pc , Pant__pc , Shirt__pc , Skirt__pc , Suit__pc , Belt__pc , Shoes__pc , 
                            Ring__pc , Spouse__pc , AnniversaryMonth__pc , AnniversaryDay__pc , AnniversaryYear__pc , Children__pc , 
                            Pets__pc , ShopsFor__pc , PersonalInterest1__pc , PersonalInterest2__pc , PersonalInterest3__pc , 
                            FoodPreferences__pc , BeveragePreferences__pc , PersonAssistantName , PersonAssistantPhone , 
                            AccessoriesInterest__pc , JewelleryInterest__pc , LeatherGoodsInterest__pc , RTWInterest__pc , ShoesInterest__pc , 
                            WatchesInterest__pc , OtherInterest__pc , ServiceInterest__pc , EventInterest__pc, PerfumesInterest__pc, 
                            PersonEmail, Unsubscribe__pc, UnsubscribeDate__pc, PersonHasOptedOutOfEmail, DoNotSMS__pc, DoNotContactbyPost__pc,
                            (SELECT id, isActive__c,Client__c,Categories__c FROM  May_Also_Likes__r )
                            FROM Account 
                            WHERE DreamID__c IN :lstAccMasterDreamId];
        
        masterClientsAC    = [SELECT ID, Firstname, Lastname, Salutation, DreamID__c, DreamIdMasterClient__c, MasterClientSFID__c, PrimaryCountry__pc, PersonContactId, Gender__pc, 
                              Jacket__pc , Dress__pc , Knit__pc , Pant__pc , Shirt__pc , Skirt__pc , Suit__pc , Belt__pc , Shoes__pc , 
                              Ring__pc , Spouse__pc , AnniversaryMonth__pc , AnniversaryDay__pc , AnniversaryYear__pc , Children__pc , 
                              Pets__pc , ShopsFor__pc , PersonalInterest1__pc , PersonalInterest2__pc , PersonalInterest3__pc , 
                              FoodPreferences__pc , BeveragePreferences__pc , PersonAssistantName , PersonAssistantPhone , 
                              AccessoriesInterest__pc , JewelleryInterest__pc , LeatherGoodsInterest__pc , RTWInterest__pc , ShoesInterest__pc , 
                              WatchesInterest__pc , OtherInterest__pc , ServiceInterest__pc , EventInterest__pc, PerfumesInterest__pc, 
                              PersonEmail, Unsubscribe__pc, UnsubscribeDate__pc, PersonHasOptedOutOfEmail, DoNotSMS__pc, DoNotContactbyPost__pc
                              FROM Account 
                              WHERE DreamID__c IN :lstAccMasterDreamId];
        
        
        
        for(Account a : masterClients){
            mapMasterDreamIdClient.put(a.DreamId__c,a);
            masterAccountsIds.add(a.id);
        }

        
        for(Account a : masterClientsAC){
            mapMasterDreamIdClientAC.put(a.DreamId__c,a);
        }
        
        
    }
    /** Added by MTOU
* Retrieving all absorbed accounts whose master exist in database  
* */
    private void initAbsorbedClientsWithExistingMaster()
    {
        absorbedClientsWithExistingMaster = new List<Account>();
        for(Account acc: absorbedClients)
        {
            if(mapMasterDreamIdClient.containsKey(acc.DreamIdMasterClient__c) && (acc.DreamID__c != acc.DreamIdMasterClient__c))  //CF-175: bypassing merge if DreamID__c and DreamIdMasterClient__c have the same value
            {
                absorbedClientsWithExistingMaster.add(acc) ;
            }
        }
    }
    
    private void initActionPlanMap (){
        
        lstAccount = [SELECT ID, PersonContactId  FROM Account WHERE Id IN :lstIdMaster];
        for(Account a : lstAccount){
            mapMasterWhoIdActionPlan.put(a.id, a.PersonContactId);
        }
    }
    
    
    private void initAbsorbedActivities() {
        absorbedEvents = [SELECT ID, WhatID, WhoID FROM Event WHERE Account.id IN :lstabsorbedAccWithExistingMasterID];
        absorbedTask = [SELECT ID, WhatID, WhoID FROM Task WHERE Account.id IN :lstabsorbedAccWithExistingMasterID];
        absorbedActionPlans = [SELECT ID, AccountId__c, name, AccountId__r.PersonContactId FROM ActionPlan__c WHERE AccountId__c IN :lstabsorbedAccWithExistingMasterID];
        // Evol Voice
        absorbedSurvey = [SELECT ID, ClientDreamID__c, ClientName__c, ClientNameText__c, DreamIDText__c FROM VO_Survey__c where ClientDreamID__c IN :lstabsorbedAccWithExistingMasterID];
        absorbedIndividualEmailResult = [SELECT ID, et4ae5__Contact__c FROM et4ae5__IndividualEmailResult__c where et4ae5__Contact__c IN :lstAccPersonContactId];
        absorbedSMSDefinition = [SELECT ID, et4ae5__Contact__c FROM et4ae5__SMSDefinition__c where et4ae5__Contact__c IN :lstAccPersonContactId]; 
        absorbedOpportunity = [SELECT ID, AccountId FROM Opportunity where AccountId IN :lstabsorbedAccWithExistingMasterID];
        absorbedInterests = [Select Id,Client__c,Categories__c,Priority__c From Interests__c Where Client__c IN :lstabsorbedAccWithExistingMasterID];
        absorbedAssets = [Select Id, AccountId From Asset Where AccountId IN :lstabsorbedAccWithExistingMasterID];
        absorbedCases = [Select ID, AccountId, ContactID from Case where AccountId in : lstabsorbedAccWithExistingMasterID or ContactID in : lstAccPersonContactId];
        absorbedCallingCampaigns = [Select Id, Client__c From Calling_Campaign__c Where Client__c in : lstabsorbedAccWithExistingMasterID];
        absorbedCareServices = [Select ID, Client__c from CareService__c where Client__c in : lstabsorbedAccWithExistingMasterID];
        absorbedLookShare = [Select ID, Client__c from Look_Share__c where Client__c in : lstabsorbedAccWithExistingMasterID];
        absorbedOrders = [SELECT ID, Account__c FROM Order__c WHERE Account__c IN :lstabsorbedAccWithExistingMasterID];
        absorbedNotifications = [Select ID, Client__c from Notification__c where Client__c in : lstabsorbedAccWithExistingMasterID];
        socialMediaIdentifiers = [Select Id, Client__c,Social_Media_Type__c, CreatedDate FROM Social_Media_identifier__c where Client__c in : lstabsorbedAccWithExistingMasterID];
        exclusiveExperiences = [SELECT Id, Account_Id__c, Dream_Id__c, Typology__c, Offer_Code__c FROM Exclusive_Experience__c WHERE Account_Id__c IN : lstabsorbedAccWithExistingMasterID];
        masterExclusiveExperiences = [SELECT Id, Account_Id__c, Dream_Id__c, Typology__c, Offer_Code__c FROM Exclusive_Experience__c WHERE Dream_Id__c IN : lstAccMasterDreamId];
        exclusiveCampaignOrder = [SELECT Id, Client__c,TECH_UniqueOrderNumber__c FROM Exclusive_Campaign_Order__c WHERE Client__c IN : lstabsorbedAccWithExistingMasterID];
        absorbedTags = [SELECT Id, Client__c FROM tag__c WHERE Client__c IN : lstabsorbedAccWithExistingMasterID];
        absorbedAliasMembers = [Select id, Client__c from Alias_Member__c where Client__c in: lstabsorbedAccWithExistingMasterID];
        absorbedTRMyLVDiamond = [SELECT Id, Client__c FROM TR_MyLV_Diamond__c WHERE Client__c IN : lstabsorbedAccWithExistingMasterID];
        absorbedFamilyMembers = [SELECT Id, Client__c FROM Family_Member__c WHERE Client__c IN : lstabsorbedAccWithExistingMasterID];
        absorbedCollectibleWallet = [SELECT Id , Client__c FROM Collectible_Wallet__c WHERE Client__c IN :lstabsorbedAccWithExistingMasterID];
        
        // lvclub#features
        absorbedClubMembership = [SELECT Id, dreamId__c, clientId__c, Club_and_Seasons__c, Club_and_Seasons__r.Name, clientId__r.DREAMID__c FROM Club_MemberShip__c where clientId__c IN :lstabsorbedAccWithExistingMasterID];
        mastersClubMembership= [SELECT Id, dreamId__c, clientId__c, Club_and_Seasons__c, Club_and_Seasons__r.Name, clientId__r.DREAMID__c FROM Club_MemberShip__c where clientId__c IN :masterAccountsIds];
        
        absorbedANDmastersClubMembership.addAll(absorbedClubMembership);
        absorbedANDmastersClubMembership.addAll(mastersClubMembership);

        for(Club_MemberShip__c clubMemberShip : absorbedANDmastersClubMembership) 
        {
            clubMemberShipsIds.add(clubMemberShip.id);
            idToClub.put(clubMemberShip.id, clubMemberShip); // add to the map < id, clubMembership >
            if (lstabsorbedAccWithExistingMasterID.contains(clubMemberShip.clientId__c)) {lstclubsAbsorbed.add(clubMemberShip);}
            if (masterAccountsIds.contains(clubMemberShip.clientId__c)){clubsMasterID.add(clubMemberShip.id);}
            if (lstabsorbedAccWithExistingMasterID.contains(clubMemberShip.clientId__c)) {clubsAbsorbedID.add(clubMemberShip.id);}

            if(dreamIdToClubs.containsKey(clubMemberShip.dreamID__c)){
                dreamIdToClubs.get(clubMemberShip.dreamID__c).add(clubMemberShip);
            }
            else{
                dreamIdToClubs.put(clubMemberShip.dreamId__c, new List<Club_MemberShip__c>());
                dreamIdToClubs.get(clubMemberShip.dreamId__c).add(clubMemberShip);
            }
        }
		
        if (!IC_UTILS.empty(absorbedActionPlans)) {
            for (ActionPlan__c ac : absorbedActionPlans) {
                lstActionPlanId.add (ac.Id);
            }
        }
        
        absorbedEventsActionPlan = [SELECT ID, WhatID, WhoID FROM Event WHERE WhatID IN :lstActionPlanId];
        absorbedTaskActionPlan   = [SELECT ID, WhatID, WhoID FROM Task  WHERE WhatID IN :lstActionPlanId];
        
    }
    
    private void initMergedClients() {
        mergedClient = [SELECT ID, Absorbed_DreamId__c, MasterClient__c, Absorbed_SFID__c, Master_SFID__c FROM MergedClients__c 
                        WHERE MasterClient__c IN :lstabsorbedAccWithExistingMasterID];
    }
    
    private void initClientListMemberList() {
        clientListMemberList = [SELECT ID, Client__c, Client__r.AccountId, TECH_External_Id__c,ClientList__c FROM CLM_CliListMember__c 
                                WHERE Client__c IN :lstAccPersonContactId];
    }
    
    // Begin RMOU
    
    private void initCampaignHistory(){
        for (Campaign_History__c ch : [SELECT Client__c FROM Campaign_History__c WHERE Client__c IN :absorbedClientsWithExistingMaster])
            if (absorbedCampaignHistoryMap.containsKey (ch.Client__c))
            absorbedCampaignHistoryMap.get(ch.Client__c).add (ch);
        else
            absorbedCampaignHistoryMap.put(ch.Client__c, new List<Campaign_History__c>{ch});
    }
    
    private void transferCampaignHistory(Account a)
    {
        List<Campaign_History__c> lch = absorbedCampaignHistoryMap.get(a.id);
        Account master = mapMasterDreamIdClient.get(a.DreamIdMasterClient__c);
        if (lch != null && master != null)
            for (Campaign_History__c ch : lch)
        {
            ch.Client__c = master.id;
            transferedCampaignHistory.add(ch);
        }
    }
    // Begin IALSID 
    private void initTranNotHist(){
        for (Transac_Notification_History__c ch : [SELECT Client__c FROM Transac_Notification_History__c WHERE Client__c IN :absorbedClientsWithExistingMaster])
            if (absorbedTranNotHistMap.containsKey (ch.Client__c))
            absorbedTranNotHistMap.get(ch.Client__c).add (ch);
        else
            absorbedTranNotHistMap.put(ch.Client__c, new List<Transac_Notification_History__c>{ch});
    }
    
    private void transferTranNotHist(Account a)
    {
        List<Transac_Notification_History__c> lch = absorbedTranNotHistMap.get(a.id);
        Account master = mapMasterDreamIdClient.get(a.DreamIdMasterClient__c);
        if (lch != null && master != null)
            for (Transac_Notification_History__c ch : lch)
        {
            ch.Client__c = master.id;
            transferedTranNotHist.add(ch);
        }
    }
    private void initPrograms(){
        for (Program__c p : [SELECT AccountId__c FROM Program__c WHERE AccountId__c IN :absorbedClientsWithExistingMaster])
            if (absorbedProgramsMap.containsKey(p.AccountId__c))
            absorbedProgramsMap.get(p.AccountId__c).add(p);
        else
            absorbedProgramsMap.put(p.AccountId__c, new List<Program__c>{p});
    }
    
    private void transferPrograms(Account a)
    {
        List<Program__c> lp = absorbedProgramsMap.get(a.id);
        Account master = mapMasterDreamIdClient.get(a.DreamIdMasterClient__c);
        if(lp != null && master != null)
            for(Program__c p : lp)
        {
            p.AccountId__c = master.id;
            transferedPrograms.add(p);
        }
    }
    
    // End RMOU
    
    
    private MergedClients__c createMergedClientObject(Account account) {
        MergedClients__c mergeBuffer;
        
        mergeBuffer = new MergedClients__c();
        mergeBuffer.Absorbed_DreamId__c = account.DreamID__c;
        mergeBuffer.MasterClient__c = account.DreamIdMasterClient__c;
        mergeBuffer.Absorbed_SFID__c = account.Id;
        mergeBuffer.Master_SFID__c = account.MasterClientSFID__c;
        return mergeBuffer;
    }
    
    private void transfertPrivateData(Account account, List<Account> masterClients) {
        Account master;
        

        if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(account.DreamIdMasterClient__c))
            master = mapMasterDreamIdClient.get(account.DreamIdMasterClient__c);
        
        if(master == null) {
            return;
        }
        
        // PIPA Rule | If the absorbed client is linked to a PIPA country but the master record isn't linked to the same country then we don't copy private data
        if (IC_Factory.isPIPACountry(account.PrimaryCountry__pc) && account.PrimaryCountry__pc != master.PrimaryCountry__pc)
            return;
        
        // Size Information
        master.Gender__pc = (master.Gender__pc !=   null) ? master.Gender__pc : account.Gender__pc;
        master.Jacket__pc = (master.Jacket__pc !=   null) ? master.Jacket__pc : account.Jacket__pc;
        master.Dress__pc  = (master.Dress__pc  !=   null) ? master.Dress__pc  : account.Dress__pc;
        master.Knit__pc   = (master.Knit__pc   !=   null) ? master.Knit__pc   : account.Knit__pc;
        master.Pant__pc   = (master.Pant__pc   !=   null) ? master.Pant__pc   : account.Pant__pc;
        master.Shirt__pc  = (master.Shirt__pc  !=   null) ? master.Shirt__pc  : account.Shirt__pc;
        master.Skirt__pc  = (master.Skirt__pc  !=   null) ? master.Skirt__pc  : account.Skirt__pc;
        master.Suit__pc   = (master.Suit__pc   !=   null) ? master.Suit__pc   : account.Suit__pc;
        master.Belt__pc   = (master.Belt__pc   !=   null) ? master.Belt__pc   : account.Belt__pc;
        master.Shoes__pc  = (master.Shoes__pc  !=   null) ? master.Shoes__pc  : account.Shoes__pc;
        master.Ring__pc   = (master.Ring__pc   !=   null) ? master.Ring__pc   : account.Ring__pc;
        
        // Lifestyle & Family 
        master.Spouse__pc              = (master.Spouse__pc              != null) ? master.Spouse__pc              : account.Spouse__pc;
        master.AnniversaryMonth__pc    = (master.AnniversaryMonth__pc    != null) ? master.AnniversaryMonth__pc    : account.AnniversaryMonth__pc;
        master.AnniversaryDay__pc      = (master.AnniversaryDay__pc      != null) ? master.AnniversaryDay__pc      : account.AnniversaryDay__pc;
        master.AnniversaryYear__pc     = (master.AnniversaryYear__pc     != null) ? master.AnniversaryYear__pc     : account.AnniversaryYear__pc;
        master.Children__pc            = (master.Children__pc            != null) ? master.Children__pc            : account.Children__pc;
        master.Pets__pc                = (master.Pets__pc                != null) ? master.Pets__pc                : account.Pets__pc;
        master.ShopsFor__pc            = (master.ShopsFor__pc            != null) ? master.ShopsFor__pc            : account.ShopsFor__pc;
        master.PersonalInterest1__pc   = (master.PersonalInterest1__pc   != null) ? master.PersonalInterest1__pc   : account.PersonalInterest1__pc;
        master.PersonalInterest2__pc   = (master.PersonalInterest2__pc   != null) ? master.PersonalInterest2__pc   : account.PersonalInterest2__pc;
        master.PersonalInterest3__pc   = (master.PersonalInterest3__pc   != null) ? master.PersonalInterest3__pc   : account.PersonalInterest3__pc;
        master.FoodPreferences__pc     = (master.FoodPreferences__pc     != null) ? master.FoodPreferences__pc     : account.FoodPreferences__pc;
        master.BeveragePreferences__pc = (master.BeveragePreferences__pc != null) ? master.BeveragePreferences__pc : account.BeveragePreferences__pc;
        master.PersonAssistantName     = (master.PersonAssistantName     != null) ? master.PersonAssistantName     : account.PersonAssistantName;
        master.PersonAssistantPhone    = (master.PersonAssistantPhone    != null) ? master.PersonAssistantPhone    : account.PersonAssistantPhone;
        
        //LV Interests
        master.AccessoriesInterest__pc  = (master.AccessoriesInterest__pc  != null) ? master.AccessoriesInterest__pc  : account.AccessoriesInterest__pc;
        master.JewelleryInterest__pc    = (master.JewelleryInterest__pc    != null) ? master.JewelleryInterest__pc    : account.JewelleryInterest__pc;
        master.LeatherGoodsInterest__pc = (master.LeatherGoodsInterest__pc != null) ? master.LeatherGoodsInterest__pc : account.LeatherGoodsInterest__pc;
        master.RTWInterest__pc          = (master.RTWInterest__pc          != null) ? master.RTWInterest__pc          : account.RTWInterest__pc;
        master.ShoesInterest__pc        = (master.ShoesInterest__pc        != null) ? master.ShoesInterest__pc        : account.ShoesInterest__pc;
        master.WatchesInterest__pc      = (master.WatchesInterest__pc      != null) ? master.WatchesInterest__pc      : account.WatchesInterest__pc;
        master.OtherInterest__pc        = (master.OtherInterest__pc        != null) ? master.OtherInterest__pc        : account.OtherInterest__pc;
        master.ServiceInterest__pc      = (master.ServiceInterest__pc      != null) ? master.ServiceInterest__pc      : account.ServiceInterest__pc;
        master.EventInterest__pc        = (master.EventInterest__pc        != null) ? master.EventInterest__pc        : account.EventInterest__pc; 
        master.PerfumesInterest__pc     = (master.PerfumesInterest__pc     != null) ? master.PerfumesInterest__pc     : account.PerfumesInterest__pc; // added by MTOU
        
        // Evol Voice
        if (master.PersonEmail != null && account.PersonEmail != null && master.PersonEmail.equals(account.PersonEmail)) {
            
            master.UnsubscribeDate__pc      = (master.Unsubscribe__pc         == false && account.Unsubscribe__pc  == true)       ? account.UnsubscribeDate__pc   : master.UnsubscribeDate__pc;
            master.PersonHasOptedOutOfEmail   = (master.PersonHasOptedOutOfEmail    == false && account.PersonHasOptedOutOfEmail  == true)  ? true              : master.PersonHasOptedOutOfEmail;
            master.DoNotSMS__pc         = (master.DoNotSMS__pc          == false && account.DoNotSMS__pc  == true)        ? true              : master.DoNotSMS__pc;
            master.DoNotContactbyPost__pc     = (master.DoNotContactbyPost__pc      == false && account.DoNotContactbyPost__pc  == true)  ? true              : master.DoNotContactbyPost__pc;
            master.Unsubscribe__pc        = (master.Unsubscribe__pc         == false && account.Unsubscribe__pc  == true)       ? true              : master.Unsubscribe__pc;
            
        } else if (master.PersonEmail == null && account.PersonEmail != null) {
            master.PersonEmail        = account.PersonEmail;
            master.UnsubscribeDate__pc    = (account.UnsubscribeDate__pc        != null)                        ? account.UnsubscribeDate__pc   : master.UnsubscribeDate__pc;
            master.PersonHasOptedOutOfEmail = account.PersonHasOptedOutOfEmail;
            master.DoNotSMS__pc       = account.DoNotSMS__pc;
            master.DoNotContactbyPost__pc   = account.DoNotContactbyPost__pc;
            master.Unsubscribe__pc      = account.Unsubscribe__pc;
        }
        
    }
    
    // Transfering Events from absorbed clients to master clients | updating an 
    private void transfertEvents(List<Account> absorbedClients, List<Event> absorbedEvents) {
        Account absorbed;
        Account master;
        
        for(Event event : absorbedEvents) {
            if( mapAccIdClient != null && mapAccIdClient.containsKey(event.whatID) ) {
                absorbed =  mapAccIdClient.get(event.whatID);
                if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c)){
                    master   =  mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                    event.WhatID = master.ID;
                }
                
                if( mapAccPersonContactIdClient != null && mapAccPersonContactIdClient.containsKey(event.whoID) ) {
                    Account absorbedContact = mapAccPersonContactIdClient.get(event.whoID);
                    Account masterContact;
                    if( mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbedContact.DreamIdMasterClient__c)){
                        masterContact   = mapMasterDreamIdClient.get(absorbedContact.DreamIdMasterClient__c);
                        event.WhoID = masterContact.PersonContactId;
                    }
                }
            }
        }
    }
    
    // Transfering Events relative to an Action Plan from absorbed clients to master clients | updating an 
    private void transfertEventForActionPlan () {
        
        if (!IC_UTILS.empty(absorbedEventsActionPlan) && !IC_UTILS.empty(lstForMap)) {
            for (Event event : absorbedEventsActionPlan) {
                for (ActionPlan__c ac : lstForMap) {
                    if (event.whatId == ac.id) {
                        event.whoId = mapMasterWhoIdActionPlan.get(ac.AccountId__c);
                    }
                }
            }
        }
    }
    
    // Transfering Tasks from absorbed clients to master clients
    private void transfertTask(List<Account> absorbedClients, List<Task> absorbedTasks) {
        Account absorbed;
        Account master;
        
        for(Task task : absorbedTasks) {
            
            if( mapAccIdClient != null && mapAccIdClient.containsKey(task.whatID) ) {
                absorbed =  mapAccIdClient.get(task.whatID);
                if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c)){
                    master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                    task.WhatID = master.ID;
                }
                
                if( mapAccPersonContactIdClient != null && mapAccPersonContactIdClient.containsKey(task.whoID) ) {
                    Account absorbedContact = mapAccPersonContactIdClient.get(task.whoID);
                    Account masterContact;
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbedContact.DreamIdMasterClient__c)){
                        masterContact   = mapMasterDreamIdClient.get(absorbedContact.DreamIdMasterClient__c);
                        task.WhoID = masterContact.PersonContactId;
                    }
                }
            }
        }
    }
    
    // Transfering Tasks relative to an Action Plan from absorbed clients to master clients | updating an 
    private void transfertTaskForActionPlan () {
        if (!IC_UTILS.empty(absorbedTaskActionPlan) && !IC_UTILS.empty(lstForMap)) {
            for (Task task : absorbedTaskActionPlan) {
                for (ActionPlan__c ac : lstForMap) {
                    if (task.whatId==ac.id) {
                        task.whoId = mapMasterWhoIdActionPlan.get(ac.AccountId__c);
                    }
                }
            }
        }
    }
    
    // Transfering Action Plan from absorbed clients to master clients
    private void transfertActionPlan (List<ActionPlan__c> absorbedActionPlans) {
        
        Account absorbed;
        Account master;
        if (!IC_UTILS.empty(absorbedActionPlans) && absorbedActionPlans.size() > 0) {
            for (ActionPlan__c ac : absorbedActionPlans) {
                if( mapAccIdClient != null && mapAccIdClient.containsKey(ac.AccountId__c) ) {
                    absorbed =  mapAccIdClient.get(ac.AccountId__c);
                    if(mapMasterDreamIdClientAC != null && mapMasterDreamIdClientAC.containsKey(absorbed.DreamIdMasterClient__c)){
                        master = mapMasterDreamIdClientAC.get(absorbed.DreamIdMasterClient__c);
                    }
                }
                if (!IC_UTILS.empty(master)) {
                    ac.AccountId__c = master.id;
                    ac.name = master.Firstname + master.Lastname;
                    lstForMap.add (ac);
                    lstIdMaster.add(master.id);
                }  
                
            }
        }
    }
    
    
    // Updating outdated MergedClient (Obsolete Master DreamIDs which are now Abosorbed DreamID)
    private void transfertMergedClient(List<Account> absorbedClients, List<MergedClients__c> mergedClient) {
        
        for (MergedClients__c merged : mergedClient) {
            if( mapAccDreamIdClient != null && mapAccDreamIdClient.containsKey(merged.MasterClient__c) )
                merged.MasterClient__c = mapAccDreamIdClient.get(merged.MasterClient__c).DreamIdMasterClient__c;
        }
    }
    
    
    // Updating clients list members 
    private void transfertClientList(List<Account> absorbedClients, List<CLM_CliListMember__c> clientListMemberList, List<Account> masterClients) {
        Set<String> clientMemberListExtIds = new Set<String>();
        Map<String,CLM_CliListMember__c> mapMasterClientMemberListExtId = new Map<String,CLM_CliListMember__c>();
        Map<String,CLM_CliListMember__c> mapMembersToUpdate = new Map<String,CLM_CliListMember__c>();
        Account master;
        for (CLM_CliListMember__c member : clientListMemberList) {
            String temp = '';
            if( mapAccPersonContactIdClient != null && mapAccPersonContactIdClient.containsKey(member.Client__c))
                temp = mapAccPersonContactIdClient.get(member.Client__c).DreamIdMasterClient__c;
            if( temp != '' && mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(temp)) {
                master = mapMasterDreamIdClient.get(temp);
                clientMemberListExtIds.add(master.PersonContactId+'_'+member.ClientList__c);
            }
        }
        
        for(CLM_CliListMember__c clm : [SELECT Id, TECH_External_Id__c FROM CLM_CliListMember__c WHERE TECH_External_Id__c in: clientMemberListExtIds]){
            mapMasterClientMemberListExtId.put(clm.TECH_External_Id__c, clm);
        }
        
        for(CLM_CliListMember__c member : clientListMemberList){
            String temp = '';
            if(mapAccPersonContactIdClient != null && mapAccPersonContactIdClient.containsKey(member.Client__c))
                temp = mapAccPersonContactIdClient.get(member.Client__c).DreamIdMasterClient__c;
            if(temp != '' && mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(temp)) {
                master = mapMasterDreamIdClient.get(temp);
                if(mapMasterClientMemberListExtId != null && mapMasterClientMemberListExtId.containsKey(master.PersonContactId+'_'+member.ClientList__c)){
                    clientListMemberToDelete.add(member);
                }
                else {
                    if(mapMembersToUpdate.containsKey(master.PersonContactId+'_'+member.ClientList__c)){
                        clientListMemberToDelete.add(member);
                    }
                    else{
                        member.Client__c = master.PersonContactId;
                        clientListMemberToUpdate.add(member);
                        mapMembersToUpdate.put(master.PersonContactId+'_'+member.ClientList__c, member);
                    }       
                }
            }
        }
    }
    
    // Transfering VO_Survey__c from absorbed clients to master clients
    private void transfertSurvey (List<VO_Survey__c> absorbedSurvey) {
        Account absorbed;
        Account master;
        if (!IC_UTILS.empty(absorbedSurvey) && absorbedSurvey.size() > 0) {
            for (VO_Survey__c su : absorbedSurvey) {
                if( mapAccIdClient != null && mapAccIdClient.containsKey(su.ClientDreamID__c) ) {
                    absorbed =  mapAccIdClient.get(su.ClientDreamID__c);
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c)){
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        system.debug('## master: ' + master);
                        su.ClientDreamID__c = master.id; // added by MTOU
                        // --Begin MTOU: updating the former Dream ID and client text field-- //
                        su.DreamIDText__c = master.DREAMID__c;
                        List<Schema.PicklistEntry> salutationValues = Account.Salutation.getDescribe().getPicklistValues();
                        For(PicklistEntry pe : salutationValues)
                        {
                            if(pe.getValue() == master.Salutation)
                            {
                                su.ClientNameText__c = pe.getLabel();
                            }
                        }
                        su.ClientNameText__c +=  ' ' + master.LastName + ' ' + master.Firstname;
                        //su.ClientNameText__c = master.Name;
                        // --End MTOU-- //
                    }
                }
                //deactivated by MTOU --> fixing survey reassignment issues
                //su.ClientDreamID__c = master.id; 
            }
        }
    }
    
    // Transfering IndividualEmailResult from absorbed clients to master clients
    private void transfertIndividualEmailResult (List<et4ae5__IndividualEmailResult__c> absorbedIndividualEmailResult) {
        
        Account master;
        for (et4ae5__IndividualEmailResult__c em : absorbedIndividualEmailResult) {
            String temp = '';
            if( mapAccPersonContactIdClient != null && mapAccPersonContactIdClient.containsKey(em.et4ae5__Contact__c) )
                temp = mapAccPersonContactIdClient.get(em.et4ae5__Contact__c).DreamIdMasterClient__c;
            if( temp != '' && mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(temp)) {
                master = mapMasterDreamIdClient.get(temp) ;
                em.et4ae5__Contact__c = master.PersonContactId;
            }
        }
    }
    
    
    // Transfering SMSDefinition from absorbed clients to master clients     
    private void transfertSMSDefinition (List<et4ae5__SMSDefinition__c> absorbedSMSDefinition) {
        
        Account master;
        for (et4ae5__SMSDefinition__c sms : absorbedSMSDefinition) {
            String temp = '';
            if( mapAccPersonContactIdClient != null && mapAccPersonContactIdClient.containsKey(sms.et4ae5__Contact__c) )
                temp = mapAccPersonContactIdClient.get(sms.et4ae5__Contact__c).DreamIdMasterClient__c;
            if( temp != '' && mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(temp)) {
                master = mapMasterDreamIdClient.get(temp) ;
                sms.et4ae5__Contact__c = master.PersonContactId;
            }
        }
    }
    
    
    // Transfering Opportunity from absorbed clients to master clients
    private void transfertOpportunity (List<Opportunity> absorbedOpportunity) {
        
        Account absorbed;
        Account master;
        if (!IC_UTILS.empty(absorbedOpportunity) && absorbedOpportunity.size() > 0) {
            for (Opportunity op : absorbedOpportunity) {
                if( mapAccIdClient != null && mapAccIdClient.containsKey(op.AccountId) ) {
                    absorbed =  mapAccIdClient.get(op.AccountId);
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c)){
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        op.AccountId = master.id; // added by MTOU
                    }
                }
                //op.AccountId = master.id; deactivated by MTOU --> fixing potential Null pointer error
            }
        }
    }
    
    //Transfering Interests
    
    private List<Interests__c > transfertInterests(List<Account> absorbedClients, List<Interests__c > absorbedInterests) {
        Account absorbed;
        Account master;
        List<Interests__c> newInterests = new List<Interests__c>();
        
        for(Interests__c interest : absorbedInterests) {
            
            if( mapAccIdClient != null && mapAccIdClient.containsKey(interest.Client__c) ) {
                absorbed =  mapAccIdClient.get(interest.Client__c);
                if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c)){
                    master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                    if (master.May_Also_Likes__r.size() == 0) {
                        Interests__c newInt = new Interests__c (Client__c = master.ID, Categories__c = interest.Categories__c,
                                                                Priority__c = interest.Priority__c);
                        newInterests.add(newInt);
                    }
                }
            }
        }
        return newInterests;
    }
    
    //Transfering Assets
    
    private void transfertAssets(List<Account> absorbedClients, List<Asset> absorbedAssets) {
        Account absorbed;
        Account master;
        
        for(Asset asset : absorbedAssets) {
            
            if( mapAccIdClient != null && mapAccIdClient.containsKey(asset.AccountId) ) {
                absorbed =  mapAccIdClient.get(asset.AccountId);
                if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c)){
                    master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                    asset.AccountId = master.ID;
                }
            }
        }
    }
    
    // Transfering Cases from absorbed accounts to master
    private void transferCase(List<Case> absorbedCases)
    {
        Account absorbed;
        Account master;
        if (!IC_UTILS.empty(absorbedCases) && absorbedCases.size() > 0)
        {
            for(Case ca: absorbedCases)
            {
                if( mapAccIdClient != null && mapAccIdClient.containsKey(ca.AccountId) )
                {
                    absorbed =  mapAccIdClient.get(ca.AccountId);
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c))
                    {
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        // reapparent accounts
                        ca.AccountId = master.id;   
                    }
                }
                if (mapAccPersonContactIdClient != null && mapAccPersonContactIdClient.containsKey(ca.ContactId))
                {
                    absorbed = mapAccPersonContactIdClient.get(ca.ContactId);
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c))
                    {
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        // reapparent contacts
                        ca.ContactId = master.PersonContactId; 
                    }
                }
            }
        }   
    }
    
    //Transfering CallingCampaigns from absorbed accounts to master
    private void transferCallingcampaign(List<Calling_Campaign__c> absorbedCallingCampaigns)
    {
        Account absorbed;
        Account master;
        if(!IC_UTILS.empty(absorbedCallingCampaigns) && absorbedCallingCampaigns.size() > 0)
        {
            for(Calling_Campaign__c cc : absorbedCallingCampaigns)
            {
                if(mapAccIdClient != null && mapAccIdClient.containsKey(cc.Client__c))
                {
                    absorbed = mapAccIdClient.get(cc.Client__c);
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c))
                    {
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        cc.Client__c = master.Id;
                    }
                }
            }
        }
    }
    
    // Transfering CareServices from absorbed to master account
    private void transferCareService(List<CareService__c> absorbedCareServices)
    {
        Account absorbed;
        Account master;
        if (!IC_UTILS.empty(absorbedCareServices) && absorbedCareServices.size() > 0)
        {
            for(CareService__c care: absorbedCareServices)
            {
                if( mapAccIdClient != null && mapAccIdClient.containsKey(care.Client__c) )
                {
                    absorbed =  mapAccIdClient.get(care.Client__c);
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c))
                    {
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        // reapparent accounts
                        care.Client__c = master.id; 
                    }
                }
            }
        }   
    }
    
    private void transferLookShare(List<Look_Share__c> absorbedLookShare) {
        Account absorbed;
        Account master;
        
        if (!IC_UTILS.empty(absorbedLookShare) && absorbedLookShare.size() > 0) {
            for(Look_Share__c lookShare : absorbedLookShare) {
                if( mapAccIdClient != null && mapAccIdClient.containsKey(lookShare.Client__c)) {
                    absorbed =  mapAccIdClient.get(lookShare.Client__c);
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c)) {
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        // reapparent accounts
                        lookShare.Client__c = master.id; 
                    }
                }
            }
        }
    }
    
    
    // Transfering Orders from absorbed to master account
    private void transferOrders(List<Order__c> absorbedOrders)
    {
        Account absorbed;
        Account master;
        if (!IC_UTILS.empty(absorbedOrders) && absorbedOrders.size() > 0)
        {
            for(Order__c order : absorbedOrders)
            {
                if( mapAccIdClient != null && mapAccIdClient.containsKey(order.Account__c) )
                {
                    absorbed =  mapAccIdClient.get(order.Account__c);
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c))
                    {
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        // reapparent accounts
                        order.Account__c = master.id; 
                    }
                }
            }
        }   
    }


     // Transfering Collectible from absorbed to master account
    private void transferCollectibleWallets(){

      Account absorbed;
      Account master;

      for(Collectible_Wallet__c c : absorbedCollectibleWallet){

          if( mapAccIdClient != null && mapAccIdClient.containsKey(c.Client__c)){

              absorbed = mapAccIdClient.get(c.Client__c);

              if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c)){

                  master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                  // reapparent accounts
                  c.Client__c = master.id;
              }
          }
      }
    }
    
    // Transfering Notifications from absorbed to master account
    private void transferNotification(List<Notification__c> absorbedNotifications)
    {
        Account absorbed;
        Account master;
        if (!IC_UTILS.empty(absorbedNotifications) && absorbedNotifications.size() > 0)
        {
            for(Notification__c notif: absorbedNotifications)
            {
                if( mapAccIdClient != null && mapAccIdClient.containsKey(notif.Client__c) )
                {
                    absorbed =  mapAccIdClient.get(notif.Client__c);
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c))
                    {
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        // reapparent accounts
                        notif.Client__c = master.id; 
                    }
                }
            }
        }   
    }
    
    // Transfering SocialMediaIdentifer from absorbed to master account
    private void transferSocialMediaIdentifier(List<Social_Media_identifier__c> socialMediaIdentifiers)
    {
        Set<String> socialMediaIdentifierExtIds = new Set<String>();
        Map<String,Social_Media_identifier__c> mapMasterSocialMediatExtId = new Map<String,Social_Media_identifier__c>(); 
        Map<String,Social_Media_identifier__c> mapSocialsToUpdate = new Map<String,Social_Media_identifier__c>();
        Account master = new Account();
        
        //Set<String
        if (!IC_UTILS.empty(socialMediaIdentifiers) && socialMediaIdentifiers.size() > 0) {
            for(Social_Media_identifier__c smi : socialMediaIdentifiers) {
                String temp = '';
                if(mapAccIdClient != null && mapAccIdClient.containsKey(smi.Client__c)) 
                    temp = mapAccIdClient.get(smi.Client__c).DreamIdMasterClient__c;
                if(temp != '' && mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(temp)){
                    master = mapMasterDreamIdClient.get(temp);
                    socialMediaIdentifierExtIds.add(smi.Social_Media_Type__c+'_'+master.Id);               
                }
            }
            
            
            for(Social_Media_identifier__c social : [SELECT Id, CreatedDate, TECH_Type_Client__c FROM Social_Media_identifier__c WHERE TECH_Type_Client__c in:socialMediaIdentifierExtIds]){
                mapMasterSocialMediatExtId.put(social.TECH_Type_Client__c, social);
            }
            
            for(Social_Media_identifier__c smi : socialMediaIdentifiers) {
                String temp = '';
                Social_Media_identifier__c masterSocial = new Social_Media_identifier__c();
                Social_Media_identifier__c tempSocial = new Social_Media_identifier__c();
                if(mapAccIdClient != null && mapAccIdClient.containsKey(smi.Client__c)) 
                    temp = mapAccIdClient.get(smi.Client__c).DreamIdMasterClient__c;
                if(temp != '' && mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(temp)){
                    master = mapMasterDreamIdClient.get(temp);
                    if(mapMasterSocialMediatExtId != null && mapMasterSocialMediatExtId.containsKey(smi.Social_Media_Type__c+'_'+master.Id)){
                        masterSocial = mapMasterSocialMediatExtId.get(smi.Social_Media_Type__c+'_'+master.Id);
                        
                        if(masterSocial.CreatedDate >= smi.CreatedDate) {
                            socialMediaIdentifiersToDelete.add(smi);
                        }
                        else{
                            if(mapSocialsToUpdate != null && mapSocialsToUpdate.containsKey(smi.Social_Media_Type__c+'_'+master.Id)) {
                                tempSocial = mapSocialsToUpdate.get(smi.Social_Media_Type__c+'_'+master.Id);
                                if(tempSocial.CreatedDate >= smi.CreatedDate) {
                                    socialMediaIdentifiersToDelete.add(smi);
                                }
                                else {
                                    mapSocialsToUpdate.remove(smi.Social_Media_Type__c+'_'+master.Id);
                                    socialMediaIdentifiersToDelete.add(tempSocial);
                                    smi.Client__c = master.Id;
                                    mapSocialsToUpdate.put(smi.Social_Media_Type__c+'_'+master.Id, smi);
                                }
                            }
                            else {
                                socialMediaIdentifiersToDelete.add(masterSocial);
                                smi.Client__c = master.id; 
                                mapSocialsToUpdate.put(smi.Social_Media_Type__c+'_'+master.Id, smi);
                            }
                        }
                    }
                    else {
                        if(mapSocialsToUpdate != null && mapSocialsToUpdate.containsKey(smi.Social_Media_Type__c+'_'+master.Id)) {
                            tempSocial = mapSocialsToUpdate.get(smi.Social_Media_Type__c+'_'+master.Id);
                            if(tempSocial.CreatedDate >= smi.CreatedDate) {
                                socialMediaIdentifiersToDelete.add(smi);
                            }
                            else {
                                mapSocialsToUpdate.remove(smi.Social_Media_Type__c+'_'+master.Id);
                                socialMediaIdentifiersToDelete.add(tempSocial);
                                smi.Client__c = master.Id;
                                mapSocialsToUpdate.put(smi.Social_Media_Type__c+'_'+master.Id, smi);
                            }
                        }
                        else {
                            smi.Client__c = master.id;
                            mapSocialsToUpdate.put(smi.Social_Media_Type__c+'_'+master.Id, smi);
                        }
                    }
                }
            }
        }
        if(mapSocialsToUpdate.values().size() > 0){
            socialMediaIdentifiersToUpdate = mapSocialsToUpdate.values();
        }
    }
    
    // Transfering ExclusiveExperience from absorbed to master account
    private void transferExclusiveExperience(List<Exclusive_Experience__c> exclusiveExperiences, List<Exclusive_Experience__c> masterExclusiveExperiences)
    {        
        
        Account absorbed;
        Account master;
        
        if (!IC_UTILS.empty(exclusiveExperiences) && exclusiveExperiences.size()>0)
        {    
            for(Exclusive_Experience__c xxpr : exclusiveExperiences) 
            {                
                // check if an xxpr already exists for Master Dream ID
                Boolean masterXxprExists = false;
                if(masterExclusiveExperiences.size()>0){
                    for(Exclusive_Experience__c masterXxpr : masterExclusiveExperiences){
                        if(masterXxpr.Typology__c == xxpr.Typology__c && masterXxpr.Offer_Code__c == xxpr.Offer_Code__c){
                            masterXxprExists = true;
                            break;
                        }
                    }  
                }                
                
                if(masterXxprExists){
                    exclusiveExperiencesToDelete.add(xxpr);
                }
                else{                    
                    if( mapAccIdClient != null && mapAccIdClient.containsKey(xxpr.Account_Id__c) ){
                        absorbed =  mapAccIdClient.get(xxpr.Account_Id__c);
                        if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c)){
                            master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                            xxpr.Account_Id__c = master.id; // Master Acc ID
                            xxpr.Dream_Id__c = master.DreamID__c; // Master Dream ID
                            exclusiveExperiencesToUpdate.add(xxpr);
                        }
                        else{
                            exclusiveExperiencesToDelete.add(xxpr);
                        }
                    }
                    else{
                        exclusiveExperiencesToDelete.add(xxpr);
                    }
                }                
            }
        }
        
    }
    // Transfering ExclusiveCampaignOrder from absorbed to master account
    private void transferExclusiveCampaignOrder(List<Exclusive_Campaign_Order__c> exclusiveCampaignOrder)
    {        
        System.debug('Start Transfert');
        System.debug('exclusiveCampaign: '+exclusiveCampaignOrder);
        
        Account absorbed;
        Account master;
        
        if (!IC_UTILS.empty(exclusiveCampaignOrder) && exclusiveCampaignOrder.size()>0)
        {    
            for(Exclusive_Campaign_Order__c ecoa : exclusiveCampaignOrder) 
            {                
                if(String.isNotBlank(ecoa.Client__c) && mapAccIdClient != null && mapAccIdClient.containsKey(ecoa.Client__c)){
                    absorbed =  mapAccIdClient.get(ecoa.Client__c);  
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c))
                    {
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        ecoa.Client__c = master.id; 
                        exclusiveCampaignOrderToUpdate.add(ecoa);
                    }
                    
                }
            }                
        }
    }
    
    
    // NEW v2.0
    private void transferTags()
    {        
        System.debug('Start Transfert');
        System.debug('Tags : '+absorbedTags);
        
        Account absorbed;
        Account master;
        
        if (!IC_UTILS.empty(absorbedTags) && absorbedTags.size()>0)
        {    
            for(Tag__c tag : absorbedTags) 
            {                
                if(String.isNotBlank(tag.Client__c) && mapAccIdClient != null && mapAccIdClient.containsKey(tag.Client__c)){
                    absorbed =  mapAccIdClient.get(tag.Client__c);  
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c))
                    {
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        tag.Client__c = master.id; 
                    }
                    
                }
            }                
        }
    }
    
    // NEW v2.0
    private void transferFamilyMember()
    {        
        System.debug('Start Transfert');
        System.debug('Family Members: '+absorbedFamilyMembers);
        
        Account absorbed;
        Account master;
        
        if (!IC_UTILS.empty(absorbedFamilyMembers) && absorbedFamilyMembers.size()>0)
        {    
            for(Family_Member__c fmember : absorbedFamilyMembers) 
            {                
                if(String.isNotBlank(fmember.Client__c) && mapAccIdClient != null && mapAccIdClient.containsKey(fmember.Client__c)){
                    absorbed =  mapAccIdClient.get(fmember.Client__c);  
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c))
                    {
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        fmember.Client__c = master.id; 
                    }
                    
                }
            }                
        }
    }
    
    // NEW v2.0
    private void transferMyLvDiamond()
    {        
        System.debug('Start Transfert');
        System.debug('TRMyLVDiamond: '+absorbedTRMyLVDiamond);
        
        Account absorbed;
        Account master;
        
        if (!IC_UTILS.empty(absorbedTRMyLVDiamond) && absorbedTRMyLVDiamond.size()>0)
        {    
            for(TR_MyLV_Diamond__c lvDiamond : absorbedTRMyLVDiamond) 
            {                
                if(String.isNotBlank(lvDiamond.Client__c) && mapAccIdClient != null && mapAccIdClient.containsKey(lvDiamond.Client__c)){
                    absorbed =  mapAccIdClient.get(lvDiamond.Client__c);  
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c))
                    {
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        lvDiamond.Client__c = master.id; 
                    }
                    
                }
            }                
        }
    }
    
    // NEW v2.0
    private void transferAliasMembre()
    {
        System.debug('Start Transfert');
        System.debug('Alias Members : '+absorbedAliasMembers);
        
        Account absorbed;
        Account master;
        
        if (!IC_UTILS.empty(absorbedAliasMembers) && absorbedAliasMembers.size()>0)
        {    
            for(Alias_Member__c aliasMember : absorbedAliasMembers) 
            {                
                if(String.isNotBlank(aliasMember.Client__c) && mapAccIdClient != null && mapAccIdClient.containsKey(aliasMember.Client__c)){
                    absorbed =  mapAccIdClient.get(aliasMember.Client__c);  
                    if(mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c))
                    {
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        aliasMember.Client__c = master.id; 
                    }
                    
                }
            }                
        }
    }

     
    // lvclub#features NEW v2.0
    private void transferClubMemberShip()
    {
        System.debug('Start transferClubMemberShip');
        System.debug('Absorbed Club_MemberShip__c : '+absorbedClubMembership);
        System.debug('Masters Club_MemberShip__c : '+mastersClubMembership);
        
        Account absorbed;
        Account master;
        List<Badge_Collection__c> badges = new List<Badge_Collection__c>();
        Map<String, List<Badge_Collection__c>> mapClubToBadges = new Map<String, List<Badge_Collection__c>>();


        badges = [SELECT Id, Name, member_Id__c, badgeId__c, badgeFlag__c, isFavorite__c, UniqueKey__c FROM Badge_Collection__c where member_Id__c IN :clubMemberShipsIds];
        
        for(Badge_Collection__c badge : badges) 
        {
            if (mapClubToBadges.containsKey(badge.member_Id__c)){
                mapClubToBadges.get(badge.member_Id__c).add(badge);
            }
            else{
                mapClubToBadges.put(badge.member_Id__c, new List<Badge_Collection__c>());
                mapClubToBadges.get(badge.member_Id__c).add(badge);
            }
        }
        
        if (!IC_UTILS.empty(absorbedANDmastersClubMembership) && absorbedANDmastersClubMembership.size()>0)
        {

            System.debug('LOOP OVER SLAVE CLUBS');
            for(Club_MemberShip__c clubMemberShip : absorbedClubMembership)
            {   //check if the current club's slave exists on the list of absorbedClientsWithExistingMaster else don't do a transfer
                System.debug('inside loop for Slave Club '+clubMemberShip);
                if (mapAccIdClient != null && mapAccIdClient.containsKey(clubMemberShip.Clientid__c) )
                {   //store the slave on a account variable
                    absorbed =  mapAccIdClient.get(clubMemberShip.Clientid__c);
                    System.debug('store the slave client on a account variable '+absorbed);
                    //check if the map contains the master account
                    if (mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c))
                    {   //store the master client on a account variable
                        master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);
                        System.debug('store the master on a account variable '+master);
                        Boolean notFound=true;
                        //check if the master dream id exists on the map of all accounts with clubs
                        System.debug('check if the master dream id exists on the map of all accounts with clubs');
                        if(dreamIdToClubs.containsKey(absorbed.DreamIdMasterClient__c)){

                            List< Club_MemberShip__c> masterClubs = new List< Club_MemberShip__c>();
                            //masterClubs: get all ClubMemberShips of the master
                            masterClubs = dreamIdToClubs.get(master.dreamID__c);
                            Club_MemberShip__c masterClub =null;
                            //loop to check if the master clubs contains a club with the same Club_and_Seasons__c of the current Salve Club
                            for (Club_MemberShip__c currentClubMemberShip : masterClubs) {
                                if (currentClubMemberShip.Club_and_Seasons__c == clubMemberShip.Club_and_Seasons__c) {
                                    masterClub=currentClubMemberShip;
                                    notFound=false;
                                    System.debug('FOUND ! A master CM with the same slave CM clubANDseason  '+masterClub);
                                    break;                         
                                }
                            }
                            if (masterClub != null && mapClubToBadges.containsKey(clubMemberShip.Id)){
                                System.debug('COMPARE MASTER CM BADGES WITH SLAVE CM BADGES');
                                for (Badge_Collection__c badgeAbsorbed : mapClubToBadges.get(clubMemberShip.Id)){
                                    Boolean exist = false;
                                    for (Badge_Collection__c badgeMaster : mapClubToBadges.get(masterClub.Id)){
                                        if (badgeAbsorbed.badgeId__c == badgeMaster.badgeId__c){
                                            exist = true;
                                            if ((badgeAbsorbed.badgeFlag__c && !badgeMaster.badgeFlag__c) || (badgeAbsorbed.isFavorite__c && !badgeMaster.isFavorite__c)){
                                                if (badgeAbsorbed.badgeFlag__c && !badgeMaster.badgeFlag__c) badgeMaster.badgeFlag__c = badgeAbsorbed.badgeFlag__c;
                                                if (badgeAbsorbed.isFavorite__c && !badgeMaster.isFavorite__c) badgeMaster.isFavorite__c = badgeAbsorbed.isFavorite__c;
                                                badgeToUpdate.add(badgeMaster);
                                            }
                                        }
                                    }
                                    if (exist == false){
                                        badgeAbsorbed.member_Id__c = masterClub.id;
                                        badgeToUpdate.add(badgeAbsorbed);
                                    }
                                }
                            }
                        }if(notFound){
                            System.debug('the master clubs doesn\'t contains a club with the same Club_and_Seasons__c of the current Salve Club');
                            System.debug('link the absorbed CM to the master : '+clubMemberShip);
                        
                            clubMemberShip.Clientid__c = master.id;
                            clubMemberShip.dreamId__c = master.DreamID__c;
                            clubMemberShip.Unique_Key__c = master.DREAMID__c+ '_' + clubMemberShip.Club_and_Seasons__r.Name;
                            clubMemberShipToUpdate.add(clubMemberShip); 
                        }
                    }
                }
            }                
        }
    }

    // NEW v2.0    
    private void transferFavoritClubMember()
    {
        System.debug('Start transferFavoritClubMember');
        System.debug('Favorite_Club_Member__c of absorbed ClubMembership : '+absorbedClubMembership);
        
        Account absorbed;
        Account master;
        Club_MemberShip__c absorbedClub;
        List<Favorite_Club_Member__c > favorites = new List<Favorite_Club_Member__c >();
        List<String> favoriteConcatenatedMaster = new List<String>();
        List<Favorite_Club_Member__c> favoritesFromAbsorbed = new List<Favorite_Club_Member__c >();
        
        if (absorbedANDmastersClubMembership.size() > 0){
            
            favorites = [SELECT Id, Name, clubMemberId__c, clubMemberId__r.Club_and_Seasons__c, favoriteClubMemberId__c, favoriteClubMemberId__r.Club_and_Seasons__c, isFavoriteIsClubEligible__c, isFavoriteIsMember__c, UniqueKey__c FROM Favorite_Club_Member__c where clubMemberId__c IN :clubMemberShipsIds or favoriteClubMemberId__c IN :clubMemberShipsIds];
            if (favorites != null && favorites.size() > 0){
                for (Favorite_Club_Member__c favorite : favorites)
                {   
                    System.debug('favorite: '+favorite);
                    if (clubsMasterID.contains(favorite.clubMemberId__c) || clubsMasterID.contains(favorite.favoriteClubMemberId__c)) {
                        favoriteConcatenatedMaster.add('_'+favorite.clubMemberId__c + favorite.favoriteClubMemberId__c); 
                        }
                    if (clubsAbsorbedID.contains(favorite.clubMemberId__c) || clubsAbsorbedID.contains(favorite.favoriteClubMemberId__c)) {
                        favoritesFromAbsorbed.add(favorite); 
                        }
                }
            }
            for (Favorite_Club_Member__c favorite : favoritesFromAbsorbed)
            {
                if (idToClub != null && (idToClub.containsKey(favorite.clubMemberId__c) || idToClub.containsKey(favorite.favoriteClubMemberId__c)))
                {
                    Boolean clubMemberId;
                    if (clubsAbsorbedID.contains(favorite.clubMemberId__c)){
                        idToClub.get(favorite.clubMemberId__c);
                        clubMemberId = true;
                        absorbedClub =  idToClub.get(favorite.clubMemberId__c); 
                    } 
                    else if (clubsAbsorbedID.contains(favorite.favoriteClubMemberId__c)){
                        idToClub.get(favorite.favoriteClubMemberId__c);
                        clubMemberId = false;
                        absorbedClub =  idToClub.get(favorite.favoriteClubMemberId__c);
                    }//Si la MAP des id client AVEC EXISTING MASTER contient le client slave F.CM OU F.FCM 
                    if (mapAccIdClient != null && mapAccIdClient.containsKey(absorbedClub.clientid__c))
                    {   //get the absorbed 'SLAVE' account
                        absorbed =  mapAccIdClient.get(absorbedClub.clientId__c);
                        //check if the MASTER CLIENT Map contains the master Dream Id
                        if (mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c))
                        {   //Get the Master account
                            master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c);

                            if (clubsMasterID.contains(favorite.favoriteClubMemberId__c) || clubsMasterID.contains(favorite.clubMemberId__c)
                                ||clubsAbsorbedID.contains(favorite.favoriteClubMemberId__c) || clubsAbsorbedID.contains(favorite.clubMemberId__c)){
                                if (clubMemberId){
                                    //get the ClubMembership with the same Club "Club_and_Seasons__c" of the Slave"
                                    for(Club_MemberShip__c club : dreamIdToClubs.get(master.DreamID__c)){
                                        if (favorite.clubMemberId__r.Club_and_Seasons__c==club.Club_and_Seasons__c) {
                                            favorite.clubMemberId__c = club.Id;                                           
                                        }
                                    }
                                    if (!favoriteConcatenatedMaster.contains('_'+favorite.clubMemberId__c + favorite.favoriteClubMemberId__c)){
                                        favoriteToUpdate.add(favorite);
                                    }
                                }
                                else {
                                    //get the ClubMembership with the same Club "Club_and_Seasons__c" of the Slave"
                                    for(Club_MemberShip__c club : dreamIdToClubs.get(master.DreamID__c)){
                                        if (favorite.favoriteClubMemberId__r.Club_and_Seasons__c==club.Club_and_Seasons__c) {
                                            favorite.favoriteClubMemberId__c = club.Id;                                    
                                        }
                                    }
                                    if (!favoriteConcatenatedMaster.contains('_'+favorite.clubMemberId__c + favorite.favoriteClubMemberId__c)){ 
                                        favoriteToUpdate.add(favorite);
                                        System.debug('favoriteToUpdate add' +favorite);
                                        
                                    }
                                }
                                
                            }
                            
                        }
                    }
                }
            }
        }    
    }

    // NEW v2.0    
    private void transferBrandExperience()
    {
        Account absorbed;
        Account master;
        Map<String, List<Brand_Experience_Variation_Member__c>> mapClubToExp = new Map<String, List<Brand_Experience_Variation_Member__c>>();
        
        
        if (absorbedClubMembership.size() > 0){

            List<Brand_Experience_Variation_Member__c> expers = [SELECT Id, IsDeleted, Name, Client__c, Brand_Experience_Variation__c, ClubMember__c, ClubMember__r.Club_and_Seasons__c, IsSelected__c, ParticipationEndDateTime__c, ParticipationStartDateTime__c, Status__c, rsvpDateTime__c, rsvpState__c  FROM Brand_Experience_Variation_Member__c WHERE ClubMember__c IN :clubMemberShipsIds];
            //Adding Brand_Experience_Variation_Member__c to the Map of < ClubMemberShip , List <Brand_Experience_Variation_Member__c> >
            if (expers != null && expers.size() > 0){
                for(Brand_Experience_Variation_Member__c exper : expers) 
                {
                    if (mapClubToExp.containsKey(exper.ClubMember__c)){
                        mapClubToExp.get(exper.ClubMember__c).add(exper);
                    }
                    else{
                        mapClubToExp.put(exper.ClubMember__c, new List<Brand_Experience_Variation_Member__c>());
                        mapClubToExp.get(exper.ClubMember__c).add(exper);
                    }
                }

                for (Club_MemberShip__c currentAbsorbedClub : lstclubsAbsorbed){                
                    Club_MemberShip__c clubMaster;
                    //Check if the Map of slave account with EXISTING MASTER contains the slave account of the club
                    if (mapAccIdClient != null && mapAccIdClient.containsKey(currentAbsorbedClub.clientId__c)){
                        absorbed = mapAccIdClient.get(currentAbsorbedClub.clientId__c); //store the slave on the absorbed account variable
                        //check if the mapMasterDreamIdClient contains the slave's master dream Id
                        if (mapMasterDreamIdClient != null && mapMasterDreamIdClient.containsKey(absorbed.DreamIdMasterClient__c)){
                            master = mapMasterDreamIdClient.get(absorbed.DreamIdMasterClient__c); // store the slave's master account on the master account variable
                            //get the ClubMembership with the same Club "Club_and_Seasons__c" of the Slave"
                            Boolean masterClubExists=false;
                            if(dreamIdToClubs.get(master.DreamID__c) != null){
                                for(Club_MemberShip__c clubMemb : dreamIdToClubs.get(master.DreamID__c)){
                                    if (currentAbsorbedClub.Club_and_Seasons__c==clubMemb.Club_and_Seasons__c) {
                                        clubMaster = clubMemb;
                                        masterClubExists=true;
                                    }
                                }
                                //check if the master exists AND DreamIdToClub contains the same club as Salve AND DreamIdToClub contains the DreamId of the slave and the mapClubToExp contains a club with Exp for the slave and master
                                if (master != null && masterClubExists  && mapClubToExp.get(currentAbsorbedClub.id) != null){ // REMOVED from condition: &&  mapClubToExp.get(clubMaster.id) != null
                                    compareBrandExperience(mapClubToExp.get(clubMaster.id),  mapClubToExp.get(currentAbsorbedClub.id),clubMaster);
                                }
                            } 
                        }
                    }
                }
            }
        }
    }
    
    // NEW v2.0    
    private void compareBrandExperience(List<Brand_Experience_Variation_Member__c> mastersExps, List<Brand_Experience_Variation_Member__c> absorbedExps, Club_MemberShip__c masterClub)
    {
        Map<String, Integer> m2 = new Map<String, Integer>();
        List<CF_MergeBrandExpStatus__c> brandExperienceStatus= CF_MergeBrandExpStatus__c.getAll().values();
        for (CF_MergeBrandExpStatus__c value : brandExperienceStatus) {
            if (value.Field__c=='Status__c') {
                m2.put(value.Status__c,integer.valueOf(value.Order__c));
            }
        }
        if (absorbedExps.size() > 0){
            for (Brand_Experience_Variation_Member__c absorbedExp :absorbedExps){
                Boolean toUpdate = false;
                Boolean exists = false;
                if (mastersExps.size() > 0){
                    for (Brand_Experience_Variation_Member__c masterExp :mastersExps)
                    {
                        if (masterExp.Brand_Experience_Variation__c == absorbedExp.Brand_Experience_Variation__c){
                            exists = true;
                            if (m2.get(absorbedExp.Status__c) > m2.get(masterExp.Status__c))
                            {
                                masterExp.Status__c = absorbedExp.Status__c;
                                masterExp.rsvpState__c = absorbedExp.rsvpState__c;
                                masterExp.rsvpDateTime__c = absorbedExp.rsvpDateTime__c;
                                masterExp.IsSelected__c = absorbedExp.IsSelected__c;
                                masterExp.ParticipationStartDateTime__c = absorbedExp.ParticipationStartDateTime__c;
                                masterExp.ParticipationEndDateTime__c = absorbedExp.ParticipationEndDateTime__c;
                                
                                masterExp.Attendance__c = absorbedExp.Attendance__c;
                                masterExp.NominationStatus__c = absorbedExp.NominationStatus__c;
                                masterExp.NominationSource__c = absorbedExp.NominationSource__c;
                                masterExp.Assigned_CA__c = absorbedExp.Assigned_CA__c;

                                toUpdate = true;
                            }
                            if (toUpdate){
                                brandToUpdate.add(masterExp);
                            }
                        }
                    }
                    if (!exists){
                        absorbedExp.ClubMember__c = masterClub.id;
                        absorbedExp.Client__c = masterClub.clientId__c;
                        brandToUpdate.add(absorbedExp);
                    }
                }
                
            }
        }
    }
	

}