/***************************************************************************************************
* @File Name          : TR_IntegrationManagerHandler.cls
* @Description        : This class was created for the C360 project 
* @Author             : @Imad.alsidchikh
* @Group              : Vuitton
* @Last Modified By   : @Imad.alsidchikh
* @Last Modified On   : 01-06-2022
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       01-06-2022         Imad.alsidchikh                   Initial Version
*****************************************************************************************************/

public without sharing class TR_IntegrationManagerHandler {
   public static Boolean run = true; 
   private static Boolean runMerge = true;
    
    public static void AfterInsert(List<Account> newList,String FirstOP){ 
        System.debug('fonction AfterInsert START');
        List<TECH_IntegrationManager__c> vInManags = new List<TECH_IntegrationManager__c>();
        //Get a custom Settings 
        try{
            TR_Integration_Manager_Setting__c cSetup =  TR_Constants.getClientSetup;
            String profileName = TR_Constants.getProfile();
            If(newList.size()>0 && cSetup != null && cSetup.Is_Active_C360_Integration__c){
                       for(Account acc: newList){
                           TECH_IntegrationManager__c vInManag = new TECH_IntegrationManager__c();
                           vInManag.Object_Name__c = TR_Constants.OBJECT_ACCOUNT;
                           vInManag.Object_Id__c = acc.Id;
                           vInManag.Operation__c = TR_Constants.CREATE_CL360;
                           vInManag.Trigger_Event__c = FirstOP;
                           vInManag.Error__c =true;
                           vInManag.AccountId__c = acc.Id;
                           vInManag.StartTime__c = TR_Constants.startTime;
                           vInManags.Add(vInManag);    
                       } 
                       If(vInManags.Size()>0){
                           List<Database.SaveResult> saveResult = Database.insert(vInManags, true);
                          // System.debug('INSERT ACC INT Manager DML Operation result ==> ' + TR_Constants.startTime);
                       }
            }
        }catch(Exception e) {
            Map<String, String> logParams = new Map<String, String>{
                'apex_class'=>'TR_IntegrationManagerHandler',
                    'apex_Method'=>'AfterInsert', 
                    'apex_Limits' => TR_C360_IntegrationManager_Utils.getCurrentOrgLimits(),
                    'application'=>TR_Constants.APPEVENT,
                    'logLevel'=>'ERROR',
                    'hasError'=>'true',
                    'error_Message'=>e.getStackTraceString() + '\n\n' + e.getMessage() + '\n\nlineNumber:' + e.getLineNumber(),
                    'Object_Type'=>'TECH_IntegrationManager__c',
                    'logType'=>'Outgoing_flow'};
                        database.insert(TR_C360_Utils.CreateLog(logParams));
        }
    }
    public static void AfterUpdate(Map<Id, Account> oldMap ,Map<Id, Account> newMap,List<Account> newList,String FirstOP){
        System.debug('fonction AfterUpdate START');
        //Get C360 custom setting
        TR_Integration_Manager_Setting__c exSetup =  TR_Constants.getClientSetup;
        Set<Id> acctToMergeIds = new Set<Id>();
        //Get Current User Profile Name
        try{
            String profileName = TR_Constants.getProfile();
            if(IC_Utils.canTrigger(TR_Constants.C360_ACCOUNT) && exSetup != null && exSetup.Is_Active_C360_Integration__c && run){
                if(newList.Size()>0){
                    if(!((String.isBlank(exSetup.Excluded_Profile__c) && String.isBlank(exSetup.Excluded_UserId__c)) ||                     
                       (String.isNotBlank(exSetup.Excluded_UserId__c )  && exSetup.Excluded_UserId__c.containsIgnoreCase(userinfo.getUserId()))
                       || (String.isNotBlank(exSetup.Excluded_Profile__c )  && exSetup.Excluded_Profile__c.containsIgnoreCase(TR_Constants.getProfile())))){
                           Boolean isAccToSend = false;
                           //Get list of C360 Fields
                           List<TR_C360_Field_Mapping__mdt > mappingRecords = TR_Constants.mappingRds;
                           Account accObject = new Account(); 
                           List<TECH_IntegrationManager__c> vUpManagers = new List<TECH_IntegrationManager__c>();
                           for (Account acct : newList) {                    
                               if (!(!String.isBlank(acct.Anonymization_key__c) || acct.LastName.startsWithIgnoreCase('anonymize_') || acct.LastName.startsWithIgnoreCase('anonymizeG_'))) {
                                   TECH_IntegrationManager__c vUpManager = new TECH_IntegrationManager__c();
                                   SObject oAcc = oldMap.get(acct.Id);
                                   SObject nAcc = newMap.get(acct.Id);
                                   for (TR_C360_Field_Mapping__mdt mappingRecord: mappingRecords) {
                                       Object v1 = oAcc.get(mappingRecord.SF_Field__c);
                                       Object v2 = nAcc.get(mappingRecord.SF_Field__c);
                                       if (didFieldChange(v1, v2) && mappingRecord.Is_Active__c) {
                                           run = false;
                                           isAccToSend =true;
                                           Break;
                                       }
                                   }
                                   if(isAccToSend){
                                       vUpManager.Object_Name__c = TR_Constants.OBJECT_ACCOUNT;
                                       vUpManager.Object_Id__c = acct.Id;
                                       vUpManager.Operation__c = TR_Constants.UPDATE_CL360;
                                       vUpManager.Trigger_Event__c = FirstOP;
                                       vUpManager.AccountId__c = acct.Id;
                                       vUpManager.Error__c =true;
                                       vUpManager.StartTime__c = TR_Constants.startTime;
                                       vUpManagers.Add(vUpManager); 
                                   }
                                   
                               }
                           }
                           If(vUpManagers.Size()>0){
                               list<Database.SaveResult> saveResult = Database.insert(vUpManagers, false);
                              // System.debug('UPDATE ACC INT Manager DML Operation result ==> ' + saveResult + ', nb records : '+ vUpManagers.size());
                           }
                       }
                    //Merge Client
                    if(exSetup.Is_Active_Merge__c && !System.IsBatch() && !System.isFuture() && runMerge){
                        for (Account acc : newList) {
                            if(String.isNotBlank(acc.MasterClientSFID__c) && String.isNotBlank(acc.Todelete__c) && acc.MasterClientSFID__c != null && acc.Todelete__c == '1'){
                                acctToMergeIds.add(acc.Id);
                            }
                        }
                        if(acctToMergeIds.Size()>0){
                            runMerge = false;
                            mergeCheck(acctToMergeIds);
                        }
                    }
                }
            } 
        }catch(Exception e) {
            Map<String, String> logParams = new Map<String, String>{
                'apex_class'=>'TR_IntegrationManagerHandler',
                    'apex_Method'=>'AfterUpdate', 
                    'apex_Limits' => TR_C360_IntegrationManager_Utils.getCurrentOrgLimits(),
                    'application'=>TR_Constants.APPEVENT,
                    'logLevel'=>'ERROR',
                    'hasError'=>'true',
                    'error_Message'=>e.getStackTraceString() + '\n\n' + e.getMessage() + '\n\nlineNumber:' + e.getLineNumber(),
                    'Object_Type'=>'TECH_IntegrationManager__c',
                    'logType'=>'Outgoing_flow'};
                        database.insert(TR_C360_Utils.CreateLog(logParams));
        } 
        
    }
    // Method to compare Old and new value off trigger
    public static Boolean didFieldChange(Object oldAcc, Object newAcc) {
        if (oldAcc == null && newAcc == null) {
            return false;
        }
        if (oldAcc != newAcc) {
            return true;
        }
        return false;
    }
    @future
    public static void mergeCheck(Set<Id> acctIds){
        system.debug('In merge');
        List<Account> lstClientsToSend = new List<Account>();
        List<Account> lstClientsTr = new List<Account>(); 
        if(acctIds.Size()>0){
            lstClientsTr = TR_ClientMerge_Utils.getAccountWithIds(acctIds);
            if(lstClientsTr.size()>0){
                for (Account acc : lstClientsTr) {
                    Account client = acc;
                    lstClientsToSend.add(client);
                }
                if(lstClientsToSend.size()>0){
                    TR_ClientMerge_Utils executeMerge = new TR_ClientMerge_Utils();
                    executeMerge.mergeClient(lstClientsToSend);
                }
            }
        }
    }
}