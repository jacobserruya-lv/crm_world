/**
* @File Name          : TR_SocialMediaIdentifierHandler.cls
* @Description        : 
* @Author             : Imad.alsidchikh.ext@louisvuitton.com
* @Group              : 
* @Last Modified By   : Imad.alsidchikh.ext@louisvuitton.com
* @Last Modified On   : 01-11-2022
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       01-11-2022      Imad.alsidchikh.ext@louisvuitton.com     Initial Version
* Updates 
  Sept 2024 / By ouramdane.aocui : 	Handle the Exclude_SFMC__c value (Exclude or not the account for SFMC) - CF-1570
									Conditioned by the client's contactability via smi
**/
public class TR_SocialMediaIdentifierHandler {
    public static void handleTrigger(List<Social_Media_Identifier__c> newList, Map<Id, Social_Media_Identifier__c> newMap, List<Social_Media_Identifier__c> oldList, Map<Id, Social_Media_Identifier__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug(triggerEvent);
        switch on triggerEvent {
            when BEFORE_INSERT{
                SM_TRG_SocialMediaIdentifier.setUniqueKeys(newList, true);
            }
            when BEFORE_UPDATE{
                SM_TRG_SocialMediaIdentifier.setUniqueKeys(newList, false);
            }
            when AFTER_INSERT{
                handleAfterInsert(newList,TR_Constants.CREATE_CL360);
            }
            when AFTER_UPDATE{
                handleAfterUpdate(oldMap ,newMap,newList, TR_Constants.UPDATE_CL360);
            }        
        }
    }
    public static void handleAfterInsert(List<Social_Media_Identifier__c> newList,String FirstOP) {  
        System.debug('fonction AfterInsert START');
        List<TECH_IntegrationManager__c> vInManags = new List<TECH_IntegrationManager__c>();
        try{
            TR_Integration_Manager_Setting__c cSetup =  TR_Constants.getSMISetup;
            If(newList.size()>0 && cSetup != null &&  cSetup.Is_Active_C360_Integration__c){
                for(Social_Media_Identifier__c smi: newList){
                    if(String.isNotBlank(smi.Client__c)){
                        TECH_IntegrationManager__c vInManag = new TECH_IntegrationManager__c();
                        vInManag.Object_Name__c = TR_Constants.OBJECT_SOCIALMEDIA;
                        vInManag.Object_Id__c = smi.Id;
                        vInManag.Operation__c = TR_Constants.CREATE_CL360;
                        vInManag.Trigger_Event__c = FirstOP;
                        vInManag.AccountId__c = smi.Client__c;
                        vInManag.StartTime__c = TR_Constants.startTime;
                        vInManags.Add(vInManag);   
                    }
                }  
                If(vInManags.Size()>0){
                    List<Database.SaveResult> saveResult = Database.insert(vInManags, false);
                    System.debug('INSERT INT Manager DML Operation result ==> ' + saveResult);
                }
            }
        }catch(Exception e) {
            Map<String, String> logParams = new Map<String, String>{
                'apex_class'=>'TR_SocialMediaIdentifierHandler',
                    'apex_Method'=>'AfterInsert', 
                    'apex_Limits' => TR_C360_IntegrationManager_Utils.getCurrentOrgLimits(),
                    'application'=>TR_Constants.APPEVENT,
                    'logLevel'=>'ERROR',
                    'hasError'=>'true',
                    'error_Message'=>e.getStackTraceString() + '\n\n' + e.getMessage() + '\n\nlineNumber:' + e.getLineNumber(),
                    'Object_Type'=>'Social_Media_Identifier__c',
                    'logType'=>'Outgoing_flow'};
                        database.insert(TR_C360_Utils.CreateLog(logParams));
        }
        
        If(IC_Utils.canTrigger('ACCOUNT_FLAG_FOR_SFMC')){
        	updateSFMCFlag(newList, null);
        }
    }
    public static void handleAfterUpdate(Map<Id, Social_Media_Identifier__c> oldMap ,Map<Id, Social_Media_Identifier__c> newMap,List<Social_Media_Identifier__c> newList,String FirstOP) {
        System.debug('fonction AfterUpdate START');
        //Get C360 custom setting
        TR_Integration_Manager_Setting__c exSetup = TR_Constants.getSMISetup;
        try{
            String profileName = TR_Constants.getProfile();
            if(exSetup != null && exSetup.Is_Active_C360_Integration__c){
                if((String.isBlank(exSetup.Excluded_Profile__c) && String.isBlank(exSetup.Excluded_UserId__c)) ||
                   ((String.isNotBlank(exSetup.Excluded_Profile__c)  && !exSetup.Excluded_Profile__c.containsIgnoreCase(profileName))  ||                      
                    (String.isNotBlank(exSetup.Excluded_UserId__c)  && !exSetup.Excluded_UserId__c.containsIgnoreCase(userinfo.getUserId())))){
                        if(newList.Size()>0){
                            Boolean isSocialToSend = false;
                            List<TR_C360_Field_Mapping__mdt > mappingRecords = TR_Constants.mappingSmi;
                            Social_Media_Identifier__c accObject = new Social_Media_Identifier__c(); 
                            List<TECH_IntegrationManager__c> vUpManagers = new List<TECH_IntegrationManager__c>();
                            for (Social_Media_Identifier__c smi : newList) {
                                TECH_IntegrationManager__c vUpManager = new TECH_IntegrationManager__c();
                                SObject oSmi = oldMap.get(smi.Id);
                                SObject nSmi = newMap.get(smi.Id);
                                for (TR_C360_Field_Mapping__mdt mappingRecord: mappingRecords) {
                                    Object v1 = oSmi.get(mappingRecord.SF_Field__c);
                                    Object v2 = nSmi.get(mappingRecord.SF_Field__c);
                                    if (TR_IntegrationManagerHandler.didFieldChange(v1, v2)) {
                                        isSocialToSend =true;
                                        Break;
                                    }  
                                }
                                if(isSocialToSend){
                                    vUpManager.Object_Name__c = TR_Constants.OBJECT_SOCIALMEDIA;
                                    vUpManager.Object_Id__c = smi.Id;
                                    vUpManager.Operation__c = TR_Constants.UPDATE_CL360;
                                    vUpManager.Trigger_Event__c = FirstOP;
                                    vUpManager.AccountId__c = smi.Client__c;
                                    vUpManager.StartTime__c = TR_Constants.startTime;
                                    vUpManagers.Add(vUpManager);  
                                }
                            }
                            If(vUpManagers.Size()>0){
                                list<Database.SaveResult> saveResult = Database.insert(vUpManagers, false);
                                System.debug('UPDATE INT Manager DML Operation result ==> ' + saveResult);
                            }
                        }
                    }
            }
        }catch(Exception e) {
            Map<String, String> logParams = new Map<String, String>{
                'apex_class'=>'TR_SocialMediaIdentifierHandler',
                    'apex_Method'=>'AfterUpdate', 
                    'apex_Limits' => TR_C360_IntegrationManager_Utils.getCurrentOrgLimits(),
                    'application'=>TR_Constants.APPEVENT,
                    'logLevel'=>'ERROR',
                    'hasError'=>'true',
                    'error_Message'=>e.getStackTraceString() + '\n\n' + e.getMessage() + '\n\nlineNumber:' + e.getLineNumber(),
                    'Object_Type'=>'Social_Media_Identifier__c',
                    'logType'=>'Outgoing_flow'};
                        database.insert(TR_C360_Utils.CreateLog(logParams));
        }
        
        If(IC_Utils.canTrigger('ACCOUNT_FLAG_FOR_SFMC')){
        	updateSFMCFlag(newList, oldMap);
        }
    }
    
    //Handle the Exclude_SFMC__c value (Exclude or not the account for SFMC) - CF-1570
    //Conditioned by the client's contactability via smi
    private static void updateSFMCFlag(List<Social_Media_Identifier__c> newList, Map<Id, Social_Media_Identifier__c> oldMap){
        
        Set<Id> setAccountIds = new Set<Id>();
        List<Account> accountList = new List<Account>();
        List<Account> accountList2 = new List<Account>();
        
        if (oldMap == null) {
            //On CREATION
            System.debug('SMI - ON CREATION ..');
            
            for(Social_Media_Identifier__c smi : newList){
                if(smi.Client__c != null){
                    setAccountIds.add(smi.Client__c);
                }
            }
            
        } else {
            //On UPDATE
            System.debug('SMI - ON UPDATE ..');
            
            for(Social_Media_Identifier__c smi : newList){
                if(smi.Opt_In__c != oldMap.get(smi.Id).Opt_In__c){
                    //Opt_In__c has changed value
                    System.debug('Old: ' + oldMap.get(smi.Id).Opt_In__c +  ' VS New: ' + smi.Opt_In__c);
                    setAccountIds.add(smi.Client__c);
                }
            }
        }
        
        if(setAccountIds.size() > 0){
            System.debug('setAccountIds Size: ' + setAccountIds.size());
            //Check the current status of Exclude_SFMC__c for these clients
            for(Account acc : [SELECT Id, Exclude_SFMC__c, ParallelMarket_Status__pc, Anonymization_date__c, 
                               Can_Be_Contacted_By_Email__pc, Can_Be_Contacted_By_SMS__pc, Can_Be_Contacted_By_Phone__pc, 
                               Can_Be_Contacted_By_Mail__pc, Can_Be_Contacted_By_LVApp__c, 
                               (SELECT Id FROM Social_Media_Identifiers__r WHERE Opt_In__c = true LIMIT 1) 
                               FROM Account WHERE Id IN :setAccountIds]){
                                   
                                   if(acc.ParallelMarket_Status__pc != 'Blue' && acc.ParallelMarket_Status__pc != 'Red' && acc.Anonymization_date__c == null){
                                       //Not excluded, check the contactability ..
                                       if(acc.Can_Be_Contacted_By_Email__pc == false && acc.Can_Be_Contacted_By_SMS__pc == false 
                                          && acc.Can_Be_Contacted_By_Phone__pc == false && acc.Can_Be_Contacted_By_Mail__pc == false 
                                          && acc.Can_Be_Contacted_By_LVApp__c == false){
                                              
                                              //Check the client contactability through SMI
                                              if(acc.Social_Media_Identifiers__r.size() == 0 && acc.Exclude_SFMC__c == false){
                                                  //Client not contactable, so to be excluded
                                                  System.debug('Case1. Acc will be excluded: ' + acc.Id);
                                                  accountList.add(acc); //Accounts will be excluded
                                                  
                                              } else if (acc.Social_Media_Identifiers__r.size() > 0 && acc.Exclude_SFMC__c == true){
                                                  //Client contactable by at least one SMI, therefore, the client will not be excluded
                                                  System.debug('Case2. Acc will not be excluded: ' + acc.Id);
                                                  accountList2.add(acc); //Accounts will not be excluded
                                              }
                                          }
                                   }
            }
            
            if(accountList.size() > 0){
                //To be excluded
                for(Account acc : accountList){
                    System.debug('Case1, list1'); 
                    acc.Exclude_SFMC__c = true;
                }
                UPDATE accountList;
            }
            
            if(accountList2.size() > 0){
                //Will not be excluded
                for(Account acct : accountList2){
                    System.debug('Case2, list2');
                    acct.Exclude_SFMC__c = false;
                }
                UPDATE accountList2;
            }
        }
    }
}