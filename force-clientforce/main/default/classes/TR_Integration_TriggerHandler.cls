/**
    * @File Name          : TR_C360Integration_TriggerHandler.trigger
    * @Description        : 
    * @Author             : Imad.alsidchikh.ext@louisvuitton.com
    * @Group              : 
    * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
    * @Last Modified On   : 06-20-2023
    * @Modification Log   : 
    * Ver       Date            Author      		                     Modification
    * 1.0       01-04-2022      Imad.alsidchikh.ext@louisvuitton.com     Initial Version
    **/
    public class TR_Integration_TriggerHandler {
        public static void handleTrigger(List<TECH_IntegrationManager__c> newList, Map<Id, TECH_IntegrationManager__c> newMap, List<TECH_IntegrationManager__c> oldList, Map<Id, TECH_IntegrationManager__c> oldMap, System.TriggerOperation triggerEvent) {
            switch on triggerEvent {
                when AFTER_INSERT{
                    handleAfterInsert(newList);
                }
                when AFTER_UPDATE{
                    handleAfterUpdate(oldMap ,newList);
                }
                
            }
        }
        public static void handleAfterInsert(List<TECH_IntegrationManager__c> newList) { 
            //Get Account Id
            Set<Id> acctIds = New Set<Id>();
            Set<Id> smiIds = New Set<Id>();
            Set<Id> timIds = New Set<Id>();
            if(newList.size()>0){
                for(TECH_IntegrationManager__c TIM : newList){
                    switch on TIM.Object_Name__c {
                        when 'ACCOUNT'{
                            timIds.add(TIM.Id);
                            if(String.isNotBlank(TIM.Object_Id__c) && ! TIM.is_Flow_testing__c){
                                acctIds.Add(TIM.Object_Id__c);         
                            }
                        }
                        when 'Social_Media_Identifier__c'{
                            timIds.add(TIM.Id);
                            if(String.isNotBlank(TIM.AccountId__c)){
                                acctIds.Add(TIM.AccountId__c);         
                            }
                        }
                        when 'Manual_Merge' {
                            ICX_WS_Manual_Merge.ManualMerge(TIM.Id);
                        }
                        when 'Some Object API Name'{
                            //DO Something
                        }
                    }
                }
                if(timIds.size()>0){
                    TR_C360_IntegrationManager_Utils.initSendMethod(acctIds,timIds);
                }
            }
        }
        
        public static void handleAfterUpdate(Map<Id, TECH_IntegrationManager__c> oldMap ,List<TECH_IntegrationManager__c> newList) {
            //system.debug('Trigger handleAfterUpdate TECH INTEG MANAGER');
            //TR_Integration_Manager_Setting__c exSetupSync =  TR_Constants.getClientSyncSetup;
            //List<String> errorCodes = exSetupSync.codeErrorToRetry__c.split(';');
            ////System.debug('errorCodes: ' + errorCodes);
            //Set<Id> acctSyncUpdateIds = New Set<Id>(); // CF-489
            //Set<Id> timSyncUpdateIds = New Set<Id>();// CF-489
            if(newList.size()>0){
                for(TECH_IntegrationManager__c TIM : newList){
                    switch on TIM.Object_Name__c {
                        //when 'ACCOUNT'{
                            //System.debug('DO A resend to C360 SYNC ? -> ' + (TIM.is_C360_Synchronous__c && TIM.Error__c && exSetupSync!=null && TIM.Retry__c <= Integer.valueOF(exSetupSync.Retry__c) 
                            //&& errorCodes.contains(String.valueOf(TIM.Error_Status__c))));
                            //if (TIM.is_C360_Synchronous__c && TIM.Error__c && exSetupSync!=null && TIM.Retry__c < Integer.valueOF(exSetupSync.Retry__c) 
                                //&& errorCodes.contains(String.valueOf(TIM.Error_Status__c))) {// CF-489
                                //timSyncUpdateIds.add(TIM.Id);
                                //if(String.isNotBlank(TIM.Object_Id__c) && ! TIM.is_Flow_testing__c){
                                //    acctSyncUpdateIds.Add(TIM.Object_Id__c);         
                                //}
                            //}
                        //}
                        when 'Manual_Merge' {
                            ICX_WS_Manual_Merge.ManualMerge(TIM.Id);
                        }
                    }
                }
                //if(timSyncUpdateIds.size()>0){
                //    //CF_WS_C360SyncClientCreationUpdate.initSendMethod(acctSyncUpdateIds,timSyncUpdateIds);
                //    //TR_C360_IntegrationManager_Utils.initSendMethod(acctSyncUpdateIds,timSyncUpdateIds);
                //}
            }
        }
    }