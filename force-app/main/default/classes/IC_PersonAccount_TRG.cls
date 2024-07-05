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
June 2016 / IC002 / Updated by Romain Mouchel-Vallon
March 2020 / Denodo anonymisation BW

Issues / TODOs
--------------
May 13 / MIM / Issues / Take only active users, updated lines 47, 55, 91
Jan 14 / MTO / Client visibility -> automatic assignment to technical usrer
Mar 14 / STI / TECH_OwnerManuallyChanged__c is checked only by non-DREAM users
Apr 23 / YCW / checkManuallyChange -> assign attached store to accounts
Jul 16 / MTOU / ICON Owner: preventing DREAM from updating account owners and attachedStore when account is frozen
Jul 16 / MTOU / ICON OWNER: deactivating this function as account assignment to technical users is managed by DREAM
Sep 16 / RMO / PIPA Law enhancement
May 17 / YZ  / Update CA name if owner manually changed
March 19 /JM/ send push when reassigned manually
Feb-March 2020 / BW / Denodo - CLient anonymization
Nov 20 / DD / Add validity check to prevent Store__pc override
May 2021 / IASC / Add a control and delete transactions in some conditions For DataChinaIsolation
Feb 2024 / Modified By ouramdane.a : Catch Anonymization Errors (CF-86) & Anonymize Birthdate CF-18)
*/
// "with sharing" problem: Identity users can't do a SOQL in the User object => checkManuallyChange: line 123 (System.QueryException: List has no rows for assignment to SObject)
public without sharing class IC_PersonAccount_TRG {
    
    // avoid the recursion
    private static boolean run = true;
    public static boolean runC360 = true;
    private static final String anonymizedPhone = '+33977404077';
    private static final Date anonymizedBirthdate = Date.newInstance(1901,01,01);
    private static Map<String, String> accRelatedRecord = new Map<String, String>(); //(relatedRecordId, AccountId)
    
    //===================================================//
    // Here go the handler methods
    public static boolean runOnce() {
        if(run) {
            run = false;
            return true;
        } else {
            return run;
        }
    }
    public static boolean runOnceC360() {
        if(runC360) {
            runC360 = false;
            return true;
        } else {
            return runC360;
        }
    }
    public static boolean manageProspectAlreadyRun = false;
    
    public static void handleTrigger(List<Account> newList, Map<Id, Account> newMap, List<Account> oldList, Map<Id, Account> oldMap, System.TriggerOperation triggerEvent) {
        TR_Constants.startTime = System.now();
        switch on triggerEvent {
            when BEFORE_INSERT {
                handleBeforeInsert(newList);
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate(oldList, oldMap, newList, newMap);
            }
            when AFTER_UPDATE{
                handleAfterUpdate(oldMap ,newMap, newList);
            }
            when AFTER_INSERT{
                handleAfterInsert(newList);
            }
            when else {
                checkIsGoldenClient(oldMap);
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
    }
    
    public static void handleBeforeInsert(List<Account> newList) {
        If (IC_Utils.canTrigger('ACCOUNT')) {
            /* Deactivated by MTOU - ICON Owner
IC_PersonAccount_TRG.checkIfActifSA(Trigger.new);
*/
            If (IC_Utils.canTrigger('PROSPECT')){
                // Begin RMO
                // If accounts are created by a normal user, set isProspect flag to true
                if (!IC_UTils.isInterfaceDream()){
                    for (Account a : newList)
                        a.IsProspect__pc = true;
                }
                // End RMO
                // line commented as replaced by 'Account Process' Process Builder
                //IC_PersonAccount_TRG.manageProspectBySettingField(Trigger.new);
            }
        }
        
        // TRACKING SOURCE
        Tracking_Settings__mdt[] tracking_settings = [SELECT MasterLabel FROM Tracking_Settings__mdt WHERE Value__c =: UserInfo.getUserName()];
        if(!tracking_settings.isEmpty()){
            for(Account acc : newList){
                if(String.isEmpty(acc.Source__c)){
                    acc.Source__c = tracking_settings[0].MasterLabel;
                }
            }
        }
        
        updateCountry(newList, null);
    }
    
    // code from Account_BeforeUpdate trigger desactivated
    // handleBeforeUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.new, Trigger.newMap);
    public static void handleBeforeUpdate(List<Account> oldList, Map<Id, Account> oldMap, List<Account> newList, Map<Id, Account> newMap) {
        If (IC_Utils.canTrigger('ACCOUNT_MANUAL_CHANGE')) {
            IC_PersonAccount_TRG.checkManuallyChange(newList, oldMap);
        }
        If (IC_Utils.canTrigger('ACCOUNT')) {
            IC_PersonAccount_TRG.checkSAId(newList, oldMap);
            IC_PersonAccount_TRG.updateAnniversaryFields(newList, oldMap);
            If (IC_Utils.canTrigger('PROSPECT')){
                //IC_PersonAccount_TRG.manageProspectBySettingField(newList);
                //  IC_PersonAccount_TRG.manageProspect(Trigger.new);
            }
        }
        If (IC_Utils.canTrigger('ACCOUNT_LASTMODIFIEDCOUNTRY')) {
            IC_PersonAccount_TRG.updateLastModifiedCountry(newList, oldMap);
        }
        If (IC_Utils.canTrigger('BANNEDWORDS')) {
            List<String> bannedWords = IC_BannedWords.checkWords(newList, 'Account');
            if(!bannedWords.isEmpty())
                Trigger.new[0].addError(String.format(Label.IC_Banned_Words_Message, new String[] {String.join(bannedWords,',')}));
        }
        
        anonymizeUser(newList);
        greyMarket(newList, oldMap);
        updateCountry(newList, oldMap);
    }
    //Method for trigger Account_BeforeUpdate 
    public static void handleAfterUpdate(Map<Id, Account> oldMap ,Map<Id, Account> newMap ,List<Account> newList) {
        If (IC_Utils.canTrigger('ACCOUNT')) {
            IC_PersonAccount_TRG.cleanAccount(oldMap ,newList);

            TR_IntegrationManagerHandler.afterUpdate(oldMap ,newMap,newList,TR_Constants.UPDATE_CL360);
        }   
    }
    //Method for trigger Account_AfterInsert 
    public static void handleAfterInsert(List<Account> newList) {
        If ((IC_Utils.canTrigger('ACCOUNT') && runOnce()) || Test.isRunningTest()) {
            TR_IntegrationManagerHandler.afterInsert(newList,TR_Constants.CREATE_CL360);  
        }  
    }
    public static void checkIsGoldenClient( Map<Id, Account>  oldMap){
     
            for (id accid: oldMap.keySet()){
                if (Trigger.isDelete && oldMap.get(accid).Tech_ClientField__c == 'GoldenClient'){
                    throw new AccountException('You can not delete this client');
                }
            }
    

    }
    

    /**
* Method for trigger Account_BeforeUpdate
* Check if Account owner Id is manually changed and assign attached store to accounts
*/
    private static void checkManuallyChange(List<Account> newValues, Map<Id, Account> oldAccounts) {
        Set<String> retailStoresCode = new Set<String>();
        User dreamUser = [Select Id, username from User where CommunityNickname = 'dream' and  profileId = :IC_UTILS.getDreamProfile() Limit 1];
        if(UserInfo.getUserId() == dreamUser.Id)
            return;
        
        Set<String> ownerids = new Set<String>();
        List<String> accIdsToSendPush = new List<String>();
        for(Account A : newValues) {
            if(!IC_UTILS.empty(A.ownerId))
                ownerids.add(A.ownerId);
        }
        
        Map<Id,User> ownersMap = new Map<Id,User>([Select Id, DefaultStore__c,WWEmployeeNumber__c,Name From User where Id in :ownerids]);
        
        Boolean isOneDataProfile =  IC_UTILS.isInterfaceDatastage() ;
        for(Account A : newValues) {
            //if(oldAccounts.get(A.ID).ownerId != A.ownerid && isOneDataProfile && A.TECH_OwnerManuallyChanged__c){ 
            //    A.OwnerId = oldAccounts.get(A.ID).ownerId; 
            //}
            if(oldAccounts.get(A.ID).ownerId != A.ownerid){
                if(!isOneDataProfile){
                    if(a.IsProspect__pc) {
                        A.TECH_OwnerManuallyChangedForProspect__c = true;
                    } else {
                        
                        A.TECH_OwnerManuallyChanged__c = true;
                        A.TECH_ManualReassignmentDate__c = Date.today();
                        A.TECH_Reassigned_By__c = UserInfo.getUserId();
                    }
                    A.CAName__c = ownersMap.get(A.ownerId).Name;
                    //set attached store to the account
                    if (!IC_UTILS.empty(A.ownerId)) {
                        A.AttachedStore__pc= ownersMap.get(A.ownerId).DefaultStore__c;
                        retailStoresCode.add(ownersMap.get(A.ownerId).DefaultStore__c);
                    }
                    if (UserInfo.getUserId() != A.ownerid  && A.TECH_TEMP_ReassignedBYTCL__c != true){
                        accIdsToSendPush.add(A.Id);
                    }
                    A.TECH_TEMP_ReassignedBYTCL__c = false;
                } 
            }
            A.TECH_IsParallelMarket__pc = A.ParallelMarket_Status__pc == 'Red' || A.ParallelMarket_Status__pc == 'Blue';
        }
        Map<String, String> storeCodeToStoreId = new Map<String, String>();
        List<Store__c> stores = [SELECT Id, RetailStoreId__c FROM Store__c WHERE RetailStoreId__c IN :retailStoresCode];
        for (Store__c store : stores) {
            storeCodeToStoreId.put(store.RetailStoreId__c, store.Id);
        }
        
        for(Account acc : newValues) {
            if(acc.AttachedStore__pc != null && storeCodeToStoreId.get(acc.AttachedStore__pc) != null) {
                acc.Store__pc = storeCodeToStoreId.get(acc.AttachedStore__pc);
            }
        }
        if(accIdsToSendPush.size() > 0 && runOnce()){
            IM_SendPushNotifications.ClientReassignSendPush(accIdsToSendPush);
        }
    }
    
    /**
* @Babacar : Pape-Babacar@Capgemini.com
* Method for trigger Account_BeforeUpdate (RBD)
* If anniversary day, month or year is sent as empty but a value already exists in ICON base,
* current value has to be kept as is in ICON.
* A custom development will have to be implemented to handle this case

*/
    public static void updateAnniversaryFields(List<Account> newValues, Map<Id, Account> oldAccounts) {
        for(Account newA : newValues) {
            if(newA.AnniversaryDay__pc == null){
                Account oldA = oldAccounts.get(newA.ID);
                if(oldA.AnniversaryDay__pc != null)
                    newA.AnniversaryDay__pc = oldA.AnniversaryDay__pc;
            }
            if(newA.AnniversaryMonth__pc == null){
                Account oldA = oldAccounts.get(newA.ID);
                if(oldA.AnniversaryMonth__pc != null)
                    newA.AnniversaryMonth__pc = oldA.AnniversaryMonth__pc;
            }
            if(newA.AnniversaryYear__pc == null){
                Account oldA = oldAccounts.get(newA.ID);
                if(oldA.AnniversaryYear__pc != null)
                    newA.AnniversaryYear__pc = oldA.AnniversaryYear__pc;
            }
            
        }
    }
    
    /**
* Method for trigger Account_BeforeUpdate
* Check if Account owner Id is changed in Dream in Dream ....
*/
    public static void checkSAId(List<Account> newValues, Map<Id, Account> oldAccounts) {
        
        //User dreamUser = [Select Id, username from User where CommunityNickname = 'dream' and  profileId = :IC_UTILS.getDreamProfile() Limit 1];
        User oneDataUser  = [SELECT Id, username FROM User WHERE CommunityNickname = 'AMS_ICON.fr' AND profileId = :IC_UTILS.getInterfaceDatastageProfile() LIMIT 1];
        Date dateToday = Date.today();

        for(Account A : newValues) {
            if(oldAccounts.get(A.ID).ownerId != A.ownerid && UserInfo.getUserId() == oneDataUser.id) {
                if(A.TECH_ManualReassignmentDate__c != null && A.TECH_ManualReassignmentDate__c.daysBetween(dateToday) < 2) {
                    A.OwnerId = oldAccounts.get(A.ID).ownerId;
                    A.CAName__c = oldAccounts.get(A.ID).CAName__c;
                    A.WWEmployeeNumber__c = oldAccounts.get(A.ID).WWEmployeeNumber__c;
                } else {
                    A.TECH_OwnerManuallyChanged__c = false;
                    A.TECH_ManualReassignmentDate__c = null;
                }
            }
        }
    }
    
    /**
* Method for trigger Account_BeforeUptade
* Update the last modified country flag for pipa purpose
*/
    public static void updateLastModifiedCountry(List<Account> newValues, Map<Id,Account> oldValues) {
        
        User currentUser  = [SELECT Id, country__c FROM USER WHERE Id = :UserInfo.getUserId() limit 1];
        String currentUserCountry = IC_Factory.getPIPACountryCode(currentUser.Country__c);
        
        for(Account A : newValues) {
            //Check if the current user is in PIPA Country and information modification to update the flag
            Account oldA = oldValues.get(A.Id);
            if(
                // Size Information
                A.Jacket__pc != oldA.Jacket__pc ||
                A.Dress__pc != oldA.Dress__pc ||
                A.Knit__pc != oldA.Knit__pc ||
                A.Pant__pc != oldA.Pant__pc ||
                A.Shirt__pc != oldA.Shirt__pc ||
                A.Skirt__pc != oldA.Skirt__pc ||
                A.Suit__pc != oldA.Suit__pc ||
                A.Belt__pc != oldA.Belt__pc ||
                A.Shoes__pc != oldA.Shoes__pc ||
                A.Ring__pc != oldA.Ring__pc ||
                // Lifestyle & Family
                A.Spouse__pc != oldA.Spouse__pc ||
                A.AnniversaryMonth__pc != oldA.AnniversaryMonth__pc ||
                A.AnniversaryDay__pc != oldA.AnniversaryDay__pc ||
                A.Children__pc != oldA.Children__pc ||
                A.Pets__pc != oldA.Pets__pc ||
                A.ShopsFor__pc != oldA.ShopsFor__pc ||
                A.PersonalInterest1__pc != oldA.PersonalInterest1__pc ||
                A.PersonalInterest2__pc != oldA.PersonalInterest2__pc ||
                A.PersonalInterest3__pc != oldA.PersonalInterest3__pc ||
                A.FoodPreferences__pc != oldA.FoodPreferences__pc ||
                A.BeveragePreferences__pc != oldA.BeveragePreferences__pc ||
                A.PersonAssistantName != oldA.PersonAssistantName ||
                A.PersonAssistantPhone != oldA.PersonAssistantPhone ||
                //LV Interests
                A.AccessoriesInterest__pc != oldA.AccessoriesInterest__pc ||
                A.JewelleryInterest__pc != oldA.JewelleryInterest__pc ||
                A.LeatherGoodsInterest__pc != oldA.LeatherGoodsInterest__pc ||
                A.RTWInterest__pc != oldA.RTWInterest__pc ||
                A.ShoesInterest__pc != oldA.ShoesInterest__pc ||
                A.WatchesInterest__pc != oldA.WatchesInterest__pc ||
                A.OtherInterest__pc != oldA.OtherInterest__pc ||
                A.ServiceInterest__pc != oldA.ServiceInterest__pc ||
                A.EventInterest__pc != oldA.EventInterest__pc)
            {
                System.debug('###$$$ Data changed');
                if(IC_Factory.isPIPAUser(currentUser))
                    A.LastModifierStoreCountry__pc = currentUserCountry;
                else
                    A.LastModifierStoreCountry__pc = '';
            }
        }
    }
    
    // DENODO
    // For Accounts with users, anonymize the user and the Social Media records
    private static void anonymizeUser(List<Account> newAccountList) {
        Set<Id> accIds = new Set<Id>();
        Set<Id> contIds = new Set<Id>();
        Map<ID, Account> mapAcc = new Map<Id, Account>();
        
        for (Account acc : newAccountList) {
            // Anonymization by Denodo system (WebMethods interface)
            if (acc.Anonymization_date__c == null && (!String.isBlank(acc.Anonymization_key__c) || acc.LastName.startsWithIgnoreCase('anonymize_') || acc.LastName.startsWithIgnoreCase('anonymizeG_'))) {
                if (acc.Tech_ClientField__c == 'GoldenClient')  throw new AccountException('You can not Anonymize this client');
                if (String.isBlank(acc.Anonymization_key__c)) {
                    if (acc.LastName.startsWithIgnoreCase('anonymize_')) acc.Anonymization_key__c = acc.LastName.toLowerCase().trim().replace('anonymize_','');
                    if (acc.LastName.startsWithIgnoreCase('anonymizeG_')) acc.Anonymization_key__c = acc.LastName.toLowerCase().trim().replace('anonymizeg_','');
                }
                if (String.isBlank(acc.Anonymization_key__c)) return;
                
                accIds.add(acc.Id);
                contIds.add(acc.PersonContactId);
                mapAcc.put(acc.Id, acc);
            }
        }
        
        if (!accIds.isEmpty()) {
            System.debug('----------- => Anonymize the Related records <= --------------');
            //If an exception is thrown in the anonimization process, the entire transaction will be rolled back
            //The errors will be caught in the catch part
            //We also catch up the accounts of the current transaction
            
            List<CF_AnonymizationErrorLog__c> anErrLogList = new List<CF_AnonymizationErrorLog__c>();
            try{
                // Delete social records
                if (Schema.sObjectType.Social_Media_Identifier__c.isDeletable()) {
                    //delete [SELECT Id FROM Social_Media_Identifier__c WHERE Client__c IN :accIds];
                    List<Social_Media_Identifier__c> socMedList = [SELECT Id, Client__c FROM Social_Media_Identifier__c WHERE Client__c IN :accIds];
                    for (Social_Media_Identifier__c sm : socMedList) {
                        accRelatedRecord.put(sm.Id, sm.Client__c);
                    }
                    if (!socMedList.isEmpty()) DELETE socMedList;
                }
                
                // Delete Programs
                //delete [SELECT Id FROM Program__c WHERE AccountId__c IN :accIds];
                List<Program__c> progList = [SELECT Id, AccountId__c FROM Program__c WHERE AccountId__c IN :accIds];
                for(Program__c prog : progList){
                    accRelatedRecord.put(prog.Id, prog.AccountId__c);
                }
                if(!progList.isEmpty()) DELETE progList;
                
                // Delete Email Messages
                //delete [select Id from EmailMessage where Parent.Id IN :accIds];
                List<EmailMessage> emailMsgList = [SELECT Id, Parent.Id FROM EmailMessage WHERE Parent.Id IN :accIds];
                for(EmailMessage eMsg : emailMsgList){
                    accRelatedRecord.put(eMsg.Id, eMsg.Parent.Id);
                }				
				if(!emailMsgList.isEmpty()) DELETE emailMsgList;
                
                // Anonymize cases
                List<Case> cases = [SELECT Id, AccountId, SuppliedName, SuppliedPhone, SuppliedEmail FROM case where AccountId IN :accIds and (SuppliedName != null or SuppliedPhone != null or SuppliedEmail != null)];
                List<ID> caseIds = new List<ID>();
                for (Case c : cases) {
                    caseIds.add(c.Id);
                    accRelatedRecord.put(c.Id, c.AccountId);
                    anonymizeCaseRecord(c, mapAcc.get(c.AccountId));
                }
                if (!cases.isEmpty()) {
                    UPDATE cases;
                    
                    //delete [select Id from EmailMessage where ParentId in :caseIds];
                    List<EmailMessage> emMsgList = [SELECT Id, Parent.AccountId FROM EmailMessage WHERE ParentId IN :caseIds];
                    for(EmailMessage emMsg : emMsgList){
                        accRelatedRecord.put(emMsg.Id, emMsg.Parent.AccountId);
                    }
                    if(!emMsgList.isEmpty()) DELETE emMsgList;
                }
                
                // Anonymize tasks (future)
                anonymizeTaskRecord(accIds);
                
                // Anonymize users
                if (!System.isBatch() && Schema.sObjectType.User.isAccessible()) anonymizer(accIds, contIds);
                
            } catch (DMLException ex) {
                System.debug('----------- => DMLException <= --------------');
                System.debug(ex);
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    CF_AnonymizationErrorLog__c anErrLog = new CF_AnonymizationErrorLog__c();
                    anErrLog.CF_ApexClass__c = 'IC_PersonAccount_TRG';
                    anErrLog.CF_ErrorObjectId__c = ex.getDmlId(i);
                    anErrLog.CF_AccountId__c = accRelatedRecord.containsKey(anErrLog.CF_ErrorObjectId__c) ? accRelatedRecord.get(anErrLog.CF_ErrorObjectId__c) : '';
                    anErrLog.CF_ErrorMessage__c = ex.getDmlType(i) + ':\n' + ex.getDmlMessage(i) + ' - '+ ex.getDmlFields(i) + '\nlineNumber:' + ex.getStackTraceString();
                    anErrLogList.add(anErrLog);
                }
                
                //Loop through the Accounts of the current transaction to insert them in CF_AnonymizationErrorLog__c Obj
                for(Account acc : mapAcc.values()){
                    CF_AnonymizationErrorLog__c anErrLog = new CF_AnonymizationErrorLog__c();
                    anErrLog.CF_AccountId__c = acc.Id;
                    anErrLog.CF_FirstName__c = acc.FirstName;
                    anErrLog.CF_LastName__c = acc.LastName;
                    anErrLog.CF_AnonymizationKey__c = acc.Anonymization_key__c;
                    anErrLog.CF_AnonymizationDate__c = acc.Anonymization_date__c;
                    anErrLog.CF_ApexClass__c = 'IC_PersonAccount_TRG';          
                    anErrLogList.add(anErrLog);
                    
                    //We empty these Account fields to allow the anonymization process to be restarted if necessary
                    acc.Anonymization_key__c = '';
                    acc.Anonymization_date__c = null;
                }
                
            } finally {
                System.debug('----------- => Finally <= --------------');
                
                if(!anErrLogList.isEmpty()){
                    //If error -> save the transaction errors & all Account
                    System.debug('anErrLogList Size: ' + anErrLogList.size());
                    INSERT anErrLogList;
                    
                } else {
                    //No errors reported, so anonymize the Accounts
                    System.debug('No errors, so anonymize the Accounts' + mapAcc.values() );
                    System.debug('mapAcc Size: ' + mapAcc.size());
                    for (Account acc : mapAcc.values()) {
                        if (!acc.LastName.startsWithIgnoreCase('anonymize_') && !acc.LastName.startsWithIgnoreCase('anonymizeG_')) acc.LastName = 'ANONYMIZE_' + acc.Anonymization_key__c;
                        if (!acc.FirstName.startsWithIgnoreCase('anonymize')) acc.FirstName = 'Anonymize';
                        if (acc.Anonymization_date__c == null) acc.Anonymization_date__c = System.Now();
                        
                        acc.PersonEmail = (!String.isBlank(acc.Anonymization_key__c) ? acc.Anonymization_key__c : 'xxx')  + '@louisvuitton.com';
                        acc.Lastname2__pc = acc.LastName;
                        acc.Firstname2__pc = 'Anonymize';
                        acc.Phone = anonymizedPhone;
                        acc.PersonMobilePhone = anonymizedPhone;
                        acc.PersonHomePhone = anonymizedPhone;
                        acc.LocalMobilePhone__pc = anonymizedPhone;
                        acc.LocalHomePhone__pc = anonymizedPhone;
                        acc.LocalWorkPhone__pc = anonymizedPhone;
                        acc.LocalLoginPhone__pc = anonymizedPhone;
                        acc.LoginPhone__pc = anonymizedPhone;
                        acc.PassportNumber__pc = '';
                        acc.PrimaryZipCode__pc = '';
                        acc.PersonBirthdate = anonymizedBirthdate;
                        acc.ToDelete__c = '1';
                    }
                }
            }
        }
    }
    
    // future annotation is required as an update is done in User and Account object
    @future
    private static void anonymizer(Set<Id> accIds, Set<Id> contIds) {
        
        List<User> users = [SELECT Id, AccountId, LastName, FirstName, CommunityNickname, Email, MobilePhone, Username, IsActive, TECH_Email__c, Tracking_Identity_User__c, TECH_MobilePhone__c, Account.LastName, Account.FirstName, Account.PersonEmail
                            FROM User WHERE ContactId IN :contIds]; // Don't use this as standard field on User doesn't work: WITH SECURITY_ENFORCED]
        Map<Id, Account> mapAcc = new Map<Id, Account>([select Id, LastName, FirstName, PersonEmail, Anonymization_key__c from Account where Id in :accIds]);
        
        for (User usr : users) {
            accRelatedRecord.put(usr.Id, usr.AccountId);
            anonymizeUserRecord(usr, mapAcc.get(usr.AccountId));
        }
        if (!users.isEmpty()) update users;
    }
    
    private static void anonymizeUserRecord(User newUsr, Account acc) {
        
        String suffixe = (String)ICONSettings__c.getOrgDefaults().get('ClientAnonymizationSuffixe__c');
        
        newUsr.LastName =  'ANONYMIZE_' + acc.Anonymization_key__c; //acc.LastName;
        newUsr.FirstName =  'Anonymize'; //acc.FirstName;
        newUsr.CommunityNickname = 'ANONYMIZE_' + acc.Anonymization_key__c; //acc.LastName;
        newUsr.Email = (!String.isBlank(acc.Anonymization_key__c) ? acc.Anonymization_key__c : 'xxx')  + '@louisvuitton.com'; //acc.PersonEmail;
        newUsr.MobilePhone = null;
        newUsr.Phone = null;
        newUsr.Username = newUsr.Email + (String.isBlank(suffixe) ? '' : '.' + suffixe); //acc.PersonEmail + (String.isBlank(suffixe) ? '' : '.' + suffixe);
        newUsr.TECH_Email__c = newUsr.Email.left(80);
        newUsr.TECH_MobilePhone__c = newUsr.Email.left(40); // TECH_MobilePhone__c should be unique. Workaround: set Denodo sends an unique email on Account.PersonEmail
        newUsr.IsActive = false;
        newUsr.Tracking_Identity_User__c = null;
        return;
    }
    
    private static void anonymizeCaseRecord(Case c, Account acc) {
        c.SuppliedName = 'Anonymize ' + 'ANONYMIZE_' + acc.Anonymization_key__c; //acc.FirstName + ' ' + acc.LastName;
        c.SuppliedPhone = null;
        c.SuppliedEmail = (!String.isBlank(acc.Anonymization_key__c) ? acc.Anonymization_key__c : 'xxx')  + '@louisvuitton.com'; //acc.PersonEmail;
        return;
    }
    
    @future
    private static void anonymizeTaskRecord(Set<Id> accIds) {
        List<Task> tasks = [SELECT Id, AccountId, Phone_Calling_Number__c FROM task where AccountId IN :accIds and Phone_Calling_Number__c != null and isDeleted = false ALL ROWS];
        for (Task t : tasks) {
            t.Phone_Calling_Number__c = null;
            accRelatedRecord.put(t.Id, t.AccountId);
        }
        if (!tasks.isEmpty()) update tasks;
        return;
    }
    
    // Denodo service
    private static void greyMarket(List<Account> newList, Map<Id, Account> oldMap) {
        for (Account acc : newList) {
              if(  acc.ParallelMarket_Status__pc=='Blank' ){
                                acc.ParallelMarket_Status__pc='';
                            }
            if (oldMap.get(acc.Id).ParallelMarket_Status__pc != acc.ParallelMarket_Status__pc) {
                acc.ParallelMarket_StatusDate__pc = System.now();
            }
        }
    }
    
    // HomeAddressCountryCode__pc field should be the Master country field
    private static void updateCountry(List<Account> newList, Map<Id, Account> oldMap) {
        for (Account acc : newList) {
            if (oldMap == null) {
                // on creation
                if (String.isNotBlank(acc.HomeAddressCountryCode__pc)) {
                    acc.SPO_Country_code__pc = acc.HomeAddressCountryCode__pc;
                } else if (String.isNotBlank(acc.SPO_Country_code__pc)) {
                    acc.HomeAddressCountryCode__pc = acc.SPO_Country_code__pc;
                }
            } else {
                // on update
                if (acc.HomeAddressCountryCode__pc != oldMap.get(acc.Id).HomeAddressCountryCode__pc) {
                    acc.SPO_Country_code__pc = acc.HomeAddressCountryCode__pc;
                } else if (acc.SPO_Country_code__pc != oldMap.get(acc.Id).SPO_Country_code__pc) {
                    acc.HomeAddressCountryCode__pc = acc.SPO_Country_code__pc;
                }
            }
        }
    }
    //TECH_ChinaVisibility__c For ChinaDataIsolation if Value of flag equal to INT_CN_ATT Delete All  PPR_PurchProduct__c 
    public static void cleanAccount(Map<Id, Account> oldMap, List<Account> newList) {
        List<Account> acct = new List<Account>();
        Set<Id> accId = new Set<Id>();
        List<PPR_PurchProduct__c> ppr = new List<PPR_PurchProduct__c>();
        List<PPR_PurchProduct__c> pprToDelete = new List<PPR_PurchProduct__c>();
        String retailStoreId;
        Map<String, Store__c> mapStore = new Map<String, Store__c>();
        //get account Id
        for (Account ac : newList) {
            if(String.isNotBlank(ac.TECH_ChinaVisibility__c) && ac.TECH_ChinaVisibility__c == 'INT_CN_ATT'){
                accId.add(ac.Id); 
            }
        }
        if(accId.size()>0){
            List<Store__c> listST = [SELECT ISO3_Code__c ,RetailStoreId__c FROM Store__c];
            if(listST.Size()>0){
                for(Store__c st : listst){
                    mapStore.put(st.RetailStoreId__c, st);  
                }
            }
            ppr = [SELECT Id,PurchaseCountry__c,Store__c FROM PPR_PurchProduct__c WHERE Client__c IN : accId];  
            if(ppr.size()>0 && Schema.sObjectType.PPR_PurchProduct__c.isDeletable()){
                for(PPR_PurchProduct__c pp : ppr){
                    Store__c pprStore = mapStore.get(pp.Store__c);
                    if((String.isNotBlank(pp.PurchaseCountry__c) && pp.PurchaseCountry__c != 'CHN') 
                       || (pprStore != null && String.isNotBlank(pprStore.ISO3_Code__c) && pprStore.ISO3_Code__c != 'CHN') ){
                           pprToDelete.Add(pp);   
                       }
                }
            }
            delete pprToDelete;
        }
    }
    public class AccountException extends Exception{}
    
}