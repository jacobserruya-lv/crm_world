/**
*  @About
*  Contains handler methods (logic to implement) for case trigger
*
*/
public with sharing class CaseTriggerHandler {
    
    // avoid the recursion https://help.salesforce.com/articleView?id=000133752
    private static boolean run = true;
    private static List<String> shippingGroupApprovalType = new List<String>();

    //===================================================//
    // Here go the handler methods
    public static boolean runOnce() {
        System.debug('runOnce=' + run);
        if (run) {
            run = false;
            return true;
        } else {
            return run;
        }
    }
    
    public static void beforeInsert(List<Case> newCaseList, Map<id, case> newCaseMap) {
        Id dpcaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId();  
        Id operationExceptionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Operation_Exception').getRecordTypeId();
        //setOwnerOnNewCaseWithCloseParent(newCaseList);
        List<Id> contactIds = new List<Id>();
        List<Id> accountIds = new List<Id>();
        Set<Id> setAccountDPCA = new Set<Id>();
        Set<Id> setAccountDPCAWithoutCountry = new Set<Id>();
        List<Case> newDPCAList = new List<Case>();
        List<Case> newDPCAListWithoutCountry = new List<Case>();
        
        checkOEDuplicate(newCaseList,false,null);
        checkSpam(newCaseList);
        // Set In_Store_Status__c as New if new CA
        for(Case caseRecord : newCaseList){
            if(caseRecord.CA_Name__c != null){
                caseRecord.In_Store_Status__c = 'New';
            }
            
            if(String.isNotBlank(caseRecord.accountId)) {
                accountIds.add(caseRecord.accountId);
            } else if(String.isNotBlank(caseRecord.ContactId)) {
                contactIds.add(caseRecord.ContactId);
            }
            if(caseRecord.RecordTypeId == dpcaRecordTypeId){
                newDPCAList.add(caseRecord);
                // set DPCA follow up date for creation
                if(caseRecord.First_Follow_Up__c != null)
                    caseRecord.First_Follow_Up_Date__c = system.now();
                
                if(caseRecord.Second_Follow_Up__c != null)
                    caseRecord.Second_Follow_Up_Date__c = system.now();
                
                //Set case origin for manual creation              
                if(String.isEmpty(caseRecord.origin))             
                    caseRecord.Origin = 'Manual Creation';
                
                if(caseRecord.AccountId != null)
                    setAccountDPCA.add(caseRecord.AccountId);
                
                if(caseRecord.Country__c == null && caseRecord.AccountId != null){
                    setAccountDPCAWithoutCountry.add(caseRecord.AccountId);
                    newDPCAListWithoutCountry.add(caseRecord);
                }
               /*
                if(caseRecord.Coming_Action__c == null ){
                    caseRecord.Coming_Action__c = date.today() ;
                }
                */
            }    
            
            // NI-1866 : [DCS] - OE - Enahancement - Create two new fields (Update Last OE Status Change Date (TECHLastOEStatusChangeDate__c))
            if (caseRecord.Status == 'New' && caseRecord.RecordTypeId == operationExceptionRecordTypeId )
                caseRecord.TECHLastOEStatusChangeDate__c = system.now();
        }
        
        if(setAccountDPCA.size()>0 && newDPCAList.size()>0)
            checkDuplicateDPCA(setAccountDPCA,newDPCAList);
        
        if(setAccountDPCAWithoutCountry.size()>0 && newDPCAListWithoutCountry.size()>0)   
            prefilledCountryDPCA(setAccountDPCAWithoutCountry,newDPCAListWithoutCountry);
        
        
        //update the TECH_ChinaVisibility on request according to the related account  - Data China Isolation 
        Map<Id, String> accounts = getRelatedAccount(contactIds ,accountIds);        
        for(Case caseRecord : newCaseList){
            if(String.isNotBlank(caseRecord.accountID) ){
                caseRecord.TECH_ChinaVisibility__c = accounts.get(caseRecord.accountId);
            }else if(String.isNotBlank(caseRecord.ContactId) ){
                caseRecord.TECH_ChinaVisibility__c = accounts.get(caseRecord.ContactId);
            }
        }
        
        updateFieldOEToStore(newCaseList);
        
        
    }
    
    
    
    public static void beforeUpdate(List<Case> newCaseList, Map<id, case> newCaseMap, List<Case> oldCaseList, Map<id, case> oldCaseMap) {
        
        List<Id> contactIds = new List<Id>();
        List<Id> accountIds = new List<Id>();
        Id approvalRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Approval').getRecordTypeId();    
        
        // Set In_Store_Status__c as New if new CA
        for(Case caseRecord : newCaseList){
            if(caseRecord.CA_Name__c != null && caseRecord.CA_Name__c != oldCaseMap.get(caseRecord.Id).CA_Name__c && caseRecord.In_Store_Status__c != 'Closed'){
                caseRecord.In_Store_Status__c = 'New';
            } 
            if(String.isNotBlank(caseRecord.accountId) && caseRecord.accountId != oldCaseMap.get(caseRecord.Id).accountId){
                accountIds.add(caseRecord.accountID);
            }else if(String.isNotBlank(caseRecord.ContactId) && caseRecord.ContactId != oldCaseMap.get(caseRecord.Id).ContactId){
                contactIds.add(caseRecord.ContactId);
            }
            // update DPCA follow up date
            if(caseRecord.First_Follow_Up__c != null && caseRecord.First_Follow_Up__c != oldCaseMap.get(caseRecord.Id).First_Follow_Up__c){
                caseRecord.First_Follow_Up_Date__c = system.now();
            } 
            if(caseRecord.Second_Follow_Up__c != null && caseRecord.Second_Follow_Up__c != oldCaseMap.get(caseRecord.Id).Second_Follow_Up__c){
                caseRecord.Second_Follow_Up_Date__c = system.now();
            }  
            
            // NI-1866 : [DCS] - OE - Enahancement - Create two new fields (Update Last OE Status Change Date (TECHLastOEStatusChangeDate__c))
            Id operationExceptionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Operation_Exception').getRecordTypeId();
            if (caseRecord.Status != oldCaseMap.get(caseRecord.Id).Status && caseRecord.RecordTypeId == operationExceptionRecordTypeId ){
                caseRecord.TECHLastOEStatusChangeDate__c = system.now();
            } 
            
            //approbation process - naomi fev 2023
            
            if(caseRecord.Status != oldCaseMap.get(caseRecord.Id).Status &&  oldCaseMap.get(caseRecord.Id).Status!='New' && caseRecord.RecordTypeId==approvalRTId)
            {
                caseRecord.addError('Cannot change the status of an Approval Request Closed');
            }
            else if(caseRecord.Status=='Rejected' && caseRecord.Rejection_Type__c==null)
            {
                
                caseRecord.Rejection_Type__c='Manual';
            }
            
        }
        
        //update the TECH_ChinaVisibility on request according to the related account  - Data China Isolation 
        Map<Id, String> accounts = getRelatedAccount(contactIds ,accountIds);
        for(Case caseRecord : newCaseList){
            if(String.isNotBlank(caseRecord.accountId) && caseRecord.accountId != oldCaseMap.get(caseRecord.Id).accountId){
                caseRecord.TECH_ChinaVisibility__c = accounts.get(caseRecord.accountId);
            }
            else if(String.isNotBlank(caseRecord.ContactId) && caseRecord.ContactId != oldCaseMap.get(caseRecord.Id).ContactId ){
                caseRecord.TECH_ChinaVisibility__c = accounts.get(caseRecord.ContactId);
            }
        }
        
        // createCaseComment(newCaseList, oldCaseMap);
        checkChildrenClosedBeforeClosingEscalation(newCaseList, oldCaseMap);

        //naomi 07/11 for search case by shipping group
        checkOEDuplicate(newCaseList,true,oldCaseMap);
    }
    
    
    public static void afterUpdate(List<Case> newCaseList, Map<id, case> newCaseMap, List<Case> oldCaseList, Map<id, case> oldCaseMap)
    {
        
        List<String> casesId = new List<String>();
        List<Case> caseApproval = new List<Case>();
        List<Task> tasksToUpdate = new List<Task>();
        Case caseTagToUpdate = null;
        Set<Id> setAccountIdNoDPCA= new Set<Id>();
        Set<Id> setAccountIdDPCA= new Set<Id>();
        
        Id dpcaRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId();  
        Id approvalRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Approval').getRecordTypeId();    
        Id OE_RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Operation_Exception').getRecordTypeId();

        for(Case caseRecord : newCaseList){
            if(caseRecord.Status == 'Closed' && caseRecord.Status != oldCaseMap.get(caseRecord.Id).Status){
                casesId.add(caseRecord.id);
            }
            
            if(caseRecord.Categories__c != oldCaseMap.get(caseRecord.Id).Categories__c){
                caseTagToUpdate = caseRecord;                
            }
            if(caseRecord.Status != oldCaseMap.get(caseRecord.Id).Status && caseRecord.RecordTypeId == dpcaRTId){
                // NI-2299 - update flag "Subscribed To DPCA Services" - Basile novembre 2023
                if (caseRecord.Status =='Interested') {
                    setAccountIdDPCA.add(caseRecord.AccountId);
                } else {
                    setAccountIdNoDPCA.add(caseRecord.AccountId);
                }
            }           
            //approbation process - naomi fev 2023
            if((caseRecord.Status =='Approved' || (caseRecord.Status=='Rejected' && caseRecord.Rejection_Type__c =='Manual')) && caseRecord.Status != oldCaseMap.get(caseRecord.Id).Status && caseRecord.RecordTypeId==approvalRTId)
            {
                
                
                caseApproval.add(caseRecord);
            }
            // Run Flow to send notif to the user Store 
            if(caseRecord.RecordTypeId == OE_RTId && caseRecord.Status == 'Store New' && caseRecord.store__c != null && (caseRecord.store__c != oldCaseMap.get(caseRecord.Id).store__c || caseRecord.Status != oldCaseMap.get(caseRecord.Id).Status)) {
                invokeFlowNotificationEmailForOE(caseRecord.id);
            }
            
        }
        
        //approbation process - naomi fev 2023
        
        if(caseApproval.size()>0)
        {
            // TWIST-30762 : Johan Guinot
            TraceabilityService.insertFromCases(caseApproval);            
            foundRelatedCaseApprovalPending(caseApproval);
        }
        
        //Update Account DPCA
        updateAccountDPCA(setAccountIdNoDPCA,setAccountIdDPCA);
        createCaseComment(newCaseList, oldCaseMap); // change from before to after update (proccess builder triggered after after triggers) naomi nov 2022
        //Update Tag DPCA
        if(caseTagToUpdate != null)
            updateTags (caseTagToUpdate);
        
        
        for(Task t : [SELECT Id, Status, ClosedByIS__c FROM Task WHERE WhatId IN : casesId AND IsClosed = false]){
            t.Status = 'Completed';
            //t.ClosedByIS__c = true;
            tasksToUpdate.add(t);
        }
        
        if(!tasksToUpdate.isEmpty()){
            update tasksToUpdate;
        }
        // if was executed during the same context / avoid recursion
        if(runOnce()) {
            
            if(IC_Utils.canTrigger('CASE_PROSPECTINFO'))
            {
                setProspectStoreInfo(newCaseList, oldCaseMap);
            } 
            
            // isFuture necesary otherwise the email received an exception: "CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, CaseTrigger: execution of AfterUpdate caused by: System.AsyncException: Future method cannot be called from a future or batch method"
            // isBatch necesary otherwise problem with IC_BatchClientMerge_TEST class (IC_BatchClientMerge batch class)
            //if(!System.isFuture() && !System.IsBatch()) {
            //    // after update as the prospect is created and linked to the Case in the 'Email To Case Prospect Creation' Flow 
            //    ICX_Case_Web2Case.updateCaseList(newCaseMap.keySet());//newCaseList);
            //}
            
            // Send Push 
            List<Case> caseTosendPush = new List<Case>();
            if (Schema.sObjectType.IconSetting__mdt.isAccessible()) {
                List<IconSetting__mdt> iconSettings = [Select Text__c
                                                       FROM IconSetting__mdt 
                                                       WHERE MasterLabel ='CaseStatusPush'];
                
                if(iconSettings.size()>0) {
                    for(Case caseRecord : newCaseList){
                        if(caseRecord.CA_Name__c != null && caseRecord.CA_Name__c != oldCaseMap.get(caseRecord.Id).CA_Name__c && caseRecord.Resolution__c == iconSettings[0].Text__c){
                            caseTosendPush.add(caseRecord);
                        } else if ( caseRecord.CA_Name__c == null && caseRecord.High_Priority__c == true && caseRecord.High_Priority__c != oldCaseMap.get(caseRecord.Id).High_Priority__c && caseRecord.Resolution__c == iconSettings[0].Text__c){
                            caseTosendPush.add(caseRecord);
                        }
                    }
                }
            }
            
            if(caseTosendPush.size()>0){
                IM_SendPushNotifications.CaseSendPush(caseTosendPush);
            }
            
        }
    }
    
    
    public static void afterInsert(List<Case> newCaseList, Map<Id, Case> newCaseMap) {
        
        //Jira NI-2535
        Id dpcaRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId();
        Id OE_RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Operation_Exception').getRecordTypeId();
        Set<Id> setAccountIdDPCA = new Set<Id> ();
        
        for(Case caseRecord : newCaseList) {
            if(caseRecord.RecordTypeId == dpcaRTId && caseRecord.Status == 'Interested') {        
                setAccountIdDPCA.add(caseRecord.AccountId);
            } else if(caseRecord.RecordTypeId == OE_RTId && caseRecord.Status == 'Store New' && caseRecord.store__c != null) {
                invokeFlowNotificationEmailForOE(caseRecord.id);
            }
        }
        //Update Account DPCA
        if (setAccountIdDPCA.size() > 0) {
            updateAccountDPCA(null,setAccountIdDPCA);
        }

        //ICX_Case_Web2Case.updateCaseList(newCaseList);
        
        applyAssignmentRules(newCaseList);
        
        // Send Push 
        List<Case> caseTosendPush = new List<Case>();
        List<IconSetting__mdt> iconSettings = [Select Text__c
                                               FROM IconSetting__mdt 
                                               WHERE MasterLabel ='CaseStatusPush'];
        
        if(iconSettings.size()>0) {
            for(Case caseRecord : newCaseList){
                if(caseRecord.CA_Name__c != null && caseRecord.Resolution__c == iconSettings[0].Text__c){
                    caseTosendPush.add(caseRecord);
                } else if ( caseRecord.CA_Name__c == null && caseRecord.High_Priority__c == true && caseRecord.Resolution__c == iconSettings[0].Text__c){
                    caseTosendPush.add(caseRecord);
                }
            }
        }
        
        if(caseTosendPush.size()>0){
            IM_SendPushNotifications.CaseSendPush(caseTosendPush);
        }
    }
     
    // NI-2299 - Basile novembre 2023 (If caseRecord is deleted, remove flag "Subscribed To DPCA Services" on Related Account)
    public static void afterDelete(List<Case> oldCaseList, Map<id, case> oldCaseMap){

        Id dpcaRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId(); 
        Set<Id> setAccountIdNoDPCA= new Set<Id>();

        for (Case caseRecord : oldCaseList) {
            if (caseRecord.RecordTypeId == dpcaRTId) {
                setAccountIdNoDPCA.add(caseRecord.AccountId);
            }
        }

        //Update Account DPCA
        updateAccountDPCA(setAccountIdNoDPCA,null);
   }
    
    //===================================================//
    // Here go the private methods
    //approbation process - naomi fev 2023
        private static void foundRelatedCaseApprovalPending(List<Case> caseApproval)
    {
        Id approvalRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Approval').getRecordTypeId();    
        List<Id> caseId = new List<Id>();
        Map<Id,List<Case>> mapOrderCase = new Map<Id,List<Case>>();
        
        
        Map<Id,String> mapOrderStatus = new Map<Id,String>();
        Map<Id,String> mapOrderStatusRelated = new Map<Id,String>();
        Map<Id,List<Case>> mapOrderCasesRelated = new Map<Id,List<Case>>();
        List<Case> caseToReject = new List<Case>();
        List<Case> caseToApproved = new List<Case>();
        
        Map<Id,List<Case>> mapOrderApprovedCase = new Map<Id,List<Case>>();
        Map<Id,List<Case>> mapOrderRejectedCase = new Map<Id,List<Case>>();

        
        
        for(Case currentCase : caseApproval)
        {      
            caseId.add(currentCase.Id);
                        if(mapOrderCase.get(currentCase.Order__c)==null)
            {
                mapOrderCase.put(currentCase.Order__c,new List<Case>());
            }
            mapOrderCase.get(currentCase.Order__c).add(currentCase);
            
            if(!mapOrderStatus.containskey(currentCase.Order__c))
            {
                mapOrderStatus.put(currentCase.Order__c,'Approved');
            }
            if(mapOrderStatus.get(currentCase.Order__c)!='Rejected')
            {
                
                if(currentCase.Status=='Approved' || (currentCase.Status=='Rejected' &&  shippingGroupApprovalType.contains(currentCase.Approval_Type__c)))

                {
                    mapOrderStatus.put(currentCase.Order__c,'Approved');
                    
                }
                else
                {
                    mapOrderStatus.put(currentCase.Order__c,'Rejected');
                }
            }
// }
            // else
            // {
            //     if(currentCase.Status=='Approved' || (currentCase.Status=='Rejected' && shippingGroupApprovalType.contains(currentCase.Approval_Type__c)))
            //     {
            //         mapOrderStatus.put(currentCase.Order__c,'Approved');
                    
            //     }
            //     else
            //     {
            //         mapOrderStatus.put(currentCase.Order__c,'Rejected');
            //     }            
            // }
        }
        
        System.debug(' mapOrderStatus ' + mapOrderStatus);
        System.debug(' mapOrderCase ' + mapOrderCase);
        
        
        List<Case> relatedCaseApprovalPending = [SELECT Id,Status,Approval_Type__c,Order__c,Approval_Submitter__c,AccountId,Order_Shipping__c,ContactId,Rejection_Type__c,Comment__c  FROM Case WHERE RecordTypeId =:approvalRTId AND Order__c IN:mapOrderStatus.keySet() AND Id NOT IN:caseId];
        
        for(Case currentCase:relatedCaseApprovalPending)
        {
            
            System.debug(' currentRelatedCase order id ' +  currentCase.Order__c);
            if(mapOrderCasesRelated.get(currentCase.Order__c)==null)
            {
                mapOrderCasesRelated.put(currentCase.Order__c,new List<Case>());
            }
            mapOrderCasesRelated.get(currentCase.Order__c).add(currentCase);
            
            if(mapOrderStatusRelated.containskey(currentCase.Order__c))
            {
                if(mapOrderStatusRelated.get(currentCase.Order__c)!='Rejected' && mapOrderStatusRelated.get(currentCase.Order__c)!='New')
                {
                    
                    if(currentCase.Status=='Approved' || (currentCase.Status=='Rejected' && shippingGroupApprovalType.contains(currentCase.Approval_Type__c)))
                    {
                        mapOrderStatusRelated.put(currentCase.Order__c,'Approved');
                        
                    }
                    else if(currentCase.Status=='New')
                    {
                        mapOrderStatusRelated.put(currentCase.Order__c,'New');
                    }
                    else{
                        mapOrderStatusRelated.put(currentCase.Order__c,'Rejected');
                        
                    }
                }
            }
            else
            {
                if(currentCase.Status=='Approved' || (currentCase.Status=='Rejected' && shippingGroupApprovalType.contains(currentCase.Approval_Type__c)))
                {
                    mapOrderStatusRelated.put(currentCase.Order__c,'Approved');
                    
                }
                else if(currentCase.Status=='New')
                {
                    mapOrderStatusRelated.put(currentCase.Order__c,'New');
                }
                else{
                    mapOrderStatusRelated.put(currentCase.Order__c,'Rejected');
                    
                }        
            }
            
            
        }
        
        System.debug(' mapOrderStatusRelated ' + mapOrderStatusRelated);
        
        for(Id orderId : mapOrderStatus.keySet())
        {
            
            
            
            if(mapOrderStatus.get(orderId)=='Approved')
            {
                if(mapOrderStatusRelated.get(orderId)==null)
                {
                    caseToApproved.addAll(mapOrderCase.get(orderId));
                    mapOrderApprovedCase.put(orderId,mapOrderCase.get(orderId));
                }
                else if(mapOrderStatusRelated.get(orderId)=='Approved')
                {
                    caseToApproved.addAll(mapOrderCase.get(orderId));
                    caseToApproved.addAll(mapOrderCasesRelated.get(orderId));
                    
                    List<Case> orderCaseList = new List<Case>();
                    orderCaseList.addAll(mapOrderCase.get(orderId));
                    orderCaseList.addAll(mapOrderCasesRelated.get(orderId));
                    System.debug(' orderCaseList ' + orderCaseList);
                    
                    mapOrderApprovedCase.put(orderId,orderCaseList);
                    
                }
            }
            else if(mapOrderStatus.get(orderId)=='Rejected' )
            {
                
                caseToReject.addAll(mapOrderCase.get(orderId));
                if(mapOrderCasesRelated.get(orderId)!=null){ caseToReject.addAll(mapOrderCasesRelated.get(orderId));}
                // if(mapOrderCasesRelated.get(orderId)!=null){mapOrderRejectedCase.put(orderId,mapOrderCasesRelated.get(orderId));}
                
            }
        }
        
        
        System.debug(' caseToReject ' + caseToReject);
        
        if(caseToReject.size()>0)
        {
            
            rejectRelatedCase(caseToReject);
        }
        
        System.debug(' caseToApproved ' + caseToApproved);
        
        if(mapOrderApprovedCase.size()>0)
        {
            
            KBRWapprovedOrder(mapOrderApprovedCase,caseToApproved);
        }
        
        
        
    }
    
    
    
    //approbation process - naomi fev 2023
    private static void rejectRelatedCase (List<Case> caseToReject)
    {
        if(caseToReject.size()>0)
        {
            List<Case> caseToUpdateRejected = new List<Case>();
            List<Case> caseToCreateTaskRejected = new List<Case>();
            
            for(Case currentCase : caseToReject)
            {
                
                
                if(currentCase.Status=='New')
                {
                    currentCase.Status = 'Rejected';
                    currentCase.Rejection_Type__c ='Automatic';
                    caseToUpdateRejected.add(currentCase);
                    
                }
            }
            
            if(caseToUpdateRejected.size()>0)
            {
                update caseToUpdateRejected;
                
            }
            createTaskApproval(caseToReject);
        }    
        
    }
    
    
    //approbation process - naomi fev 2023
    private static void KBRWapprovedOrder(Map<Id,List<Case>> mapOrderApprovedCase,List<Case> caseToApproved)
    {
        System.debug(' in KBRWapprovedOrder ');
        
        if(mapOrderApprovedCase.size()>0)
        {
            Set<Id> shippingGroupToCancel = new Set<Id>();
            List<Case> caseToTaskReject = new List<Case>();
            
            createTaskApproval(caseToApproved);
            for(Case currentCase : caseToApproved)
            {
                if(currentCase.Status == 'Rejected' && shippingGroupApprovalType.contains(currentCase.Approval_Type__c))
                {
                    shippingGroupToCancel.add(currentCase.Order_Shipping__c);
                }
            }
            
            //  sendActionKBRW(mapOrderApprovedCase.keySet(),shippingGroupToCancel);
            
            Set<Id> OrderApprovedCase = mapOrderApprovedCase.keySet();
            List<OrderLine__c> orderLine =[SELECT Id,OrderShipping__c,OrderShipping__r.ShippingNumber__c,SKU__c FROM OrderLine__c WHERE Order__c IN:OrderApprovedCase];
            for(OrderLine__c currentOrderLine : orderLine)
            {
                if(!shippingGroupToCancel.contains(currentOrderLine.OrderShipping__c))
                {
                    
                    sendActionKBRW(currentOrderLine.Id);
                }
                
            }
            
        }
    }
    
    
    //approbation process - naomi fev 2023
    @future(callout=true)
    private static void sendActionKBRW(Id orderLineId)
    {
        OrderLine__c orderLine =[SELECT Id,OrderShipping__c,OrderShipping__r.ShippingNumber__c,SKU__c FROM OrderLine__c WHERE Id =:orderLineId LIMIT 1];
        
        Map<String,Object> bodyTosend  = new Map<String,Object> {
            'id' => orderLine.OrderShipping__r.ShippingNumber__c.split('-')[0],
                'requesting_system' => 'ICONiCS',
                'item_id' => orderLine.SKU__c,
                'line_number' => Integer.valueOF(orderLine.OrderShipping__r.ShippingNumber__c.split('-')[1]),
                'action_message' =>  'approve',
                'action' => 'confirm_approval'
                };
                    WS_OrderAction.sendOrderDetails(bodyTosend,orderLine.OrderShipping__c,false);
    }
    
    
    //approbation process - naomi fev 2023
    /*   @future(callout=true)
private static void sendActionKBRW(Set<Id> OrderApprovedCase,Set<Id> shippingGroupToCancel)
{ 

System.debug(' in sendActionKBRW ');

List<OrderLine__c> orderLine =[SELECT Id,OrderShipping__c,OrderShipping__r.ShippingNumber__c,SKU__c FROM OrderLine__c WHERE Order__c IN:OrderApprovedCase];
for(OrderLine__c currentOrderLine : orderLine)
{
if(!shippingGroupToCancel.contains(currentOrderLine.OrderShipping__c))
{
System.debug(' in sendActionKBRW order Line id' + currentOrderLine.Id);

System.debug(' in sendActionKBRW order Line ' + currentOrderLine.OrderShipping__r);

Map<String,Object> bodyTosend  = new Map<String,Object> {
'id' => currentOrderLine.OrderShipping__r.ShippingNumber__c.split('-')[0],
'requesting_system' => 'ICONiCS',
'item_id' => currentOrderLine.SKU__c,
'line_number' => Integer.valueOF(currentOrderLine.OrderShipping__r.ShippingNumber__c.split('-')[1]),
'action_message' =>  'approve',
'action' => 'confirm_approval'
};
WS_OrderAction.sendOrderDetails(bodyTosend,currentOrderLine.OrderShipping__c);
}

}
}*/
    
    //approbation process - naomi fev 2023
    private static void createTaskApproval(List<Case> caseWithTaskApprovalToCreate)
    {
        if(caseWithTaskApprovalToCreate.size()>0)
        {
            List<Task> taskApprovalToInsert = new List<Task>();
            Id approvalRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Approval').getRecordTypeId(); 
            
            
            
            for(Case currentCase :caseWithTaskApprovalToCreate)
            {
                Task currentTask = new Task(); 
                currentTask.OwnerId = currentCase.Approval_Submitter__c;
                currentTask.ActivityDate = Date.today();
                currentTask.recordTypeId = approvalRTId;
                currentTask.WhoId = currentCase.ContactId;

                if (currentCase.Order_Shipping__c == null) {
                    currentTask.WhatId =currentCase.Order__c;
                }
                else {
                    currentTask.WhatId =currentCase.Order_Shipping__c;
                }
                currentTask.Subject = String.valueOF(currentTask.WhatId)+' '+ currentCase.Approval_Type__c;


                if(currentCase.Status=='Approved')
                {
                    currentTask.Subject+=' Approved';
                    currentTask.Priority = 'Low';
                    currentTask.Status = 'Completed';
                }
                else if(currentCase.Status=='Rejected')
                {
                    if(currentCase.Rejection_Type__c =='Automatic')
                    {
                        currentTask.Subject += ' Rejected' ;
                        currentTask.Priority ='Low';
                        currentTask.Status = 'Completed';
                        currentTask.Description = 'Automatic Rejection';
                    }
                    else {
                        
                        currentTask.Subject += ' Rejected' ;
                        currentTask.Priority ='High';
                        currentTask.Status = 'New';
                        currentTask.Description = currentCase.Comment__c;
                    }
                    
                }
                taskApprovalToInsert.add(currentTask);
                
            }
            if(taskApprovalToInsert.size()>0)
            {
                insert taskApprovalToInsert;
            }
            
        }
        
    }
    /**
* When CA takes ownership on a case linked to a prospect for the first time,
* he becomes the preferred CA of the attached prospect
* and his store becomes the default store of the prospect:
* prospect owner = CA
* propect store = CA store
* prospect store country = CA country
**/
    
    private static Map<id, String> getRelatedAccount(List<id> contactIds ,List<id> accountIds){
        
        Map<Id, String> accounts = new Map<Id, String>();
        for(Account acc : [SELECT Id, TECH_ChinaVisibility__c ,PersonContactId  FROM Account WHERE PersonContactId IN :contactIds OR Id in:accountIds ]){
            accounts.put(acc.id , acc.TECH_ChinaVisibility__c);
            accounts.put(acc.PersonContactId , acc.TECH_ChinaVisibility__c);
        }
        
        return accounts;
        
    }
    
    private static void setProspectStoreInfo(List<Case> newCaseList, Map<id, case> oldCaseMap)
    {
        
        List<Case> casesToProcess = new List<Case>();
        List<id> caseOwnerIDs = new List<id>();
        List<id> caseAccountIDs = new List<id>();
        List<String> ownerStoreCodes = new List<String>();
        Map<id, Account> prospectsToUpdate = new Map<id, Account>();
        for(Case ca: newCaseList)
        {
            caseAccountIDs.add(ca.AccountId);
            caseOwnerIDs.add(ca.ownerid);
        }
        
        
        Map<id, Account> caseAccounts =  new Map<id, Account>([SELECT id, ownerid, isProspect__pc, AttachedStore__pc, store__pc
                                                               FROM Account where id in:caseAccountIDs AND isProspect__pc = true]);
        
        Map<id, User> caseOwners = new Map<id, User>([SELECT id, name, defaultstore__c, country__c FROM user WHERE id in: caseOwnerIDs]);
        
        
        // only process cases related to a prospect, on which the owner has changed and currently assigned to automated case user
        if(!caseAccounts.isEmpty() && !caseOwners.isEmpty())
        {
            Id automatedUserId = IconicsSettings__c.getInstance().SystemUserId__c;
            
            for(Case ca: newCaseList)
            {
                
                if(caseAccounts.get(ca.accountid)!= null && caseOwners.get(ca.OwnerId) != null)
                {
                    if(ca.OwnerId != oldCaseMap.get(ca.id).ownerid  && caseAccounts.get(ca.accountid).isProspect__pc && caseOwners.get(ca.OwnerId).defaultStore__c != null 
                       && caseAccounts.get(ca.accountid).ownerid == automatedUserId)
                        //&& caseAccounts.get(ca.accountid).ownerid == System.Label.ICX_Automated_Case_User)
                    {
                        casesToProcess.add(ca);
                    } 
                }
                
            }
            
            
            
            // get owners default store and country and set prospect store and country
            for(Case ca: casesToProcess)
            {
                Account pros = caseAccounts.get(ca.AccountId);
                String ownerStoreCode = caseOwners.get(ca.ownerid).defaultstore__c;
                if(ownerStoreCode != null)
                {
                    pros.OwnerId = ca.ownerid;
                    pros.AttachedStore__pc = ownerStoreCode;
                    ownerStoreCodes.add(ownerStoreCode); 
                    prospectsToUpdate.put(pros.id, pros);
                }
                
            }
            
            //get owner store and set prospect store
            if (Schema.sObjectType.Store__c.isAccessible()) {
                List<Store__c> storeList = [SELECT id, RetailStoreId__c from Store__c where RetailStoreId__c in:ownerStoreCodes];
                
                Map<String, Store__c> retailCodeAndStore = new Map<String, Store__c>();
                for(Store__c st: storeList)
                {
                    if(!retailCodeAndStore.containsKey(st.RetailStoreId__c))
                    {
                        retailCodeAndStore.put(st.RetailStoreId__c, st);
                    }
                }
                
                for(Case ca: casesToProcess)
                {
                    if(caseOwners.get(ca.OwnerId) != null )
                    {
                        if(retailCodeAndStore.get(caseOwners.get(ca.OwnerId).defaultStore__c) != null)
                        {
                            Account pros = caseAccounts.get(ca.AccountId);
                            if(!test.isRunningTest()){pros.Store__pc = retailCodeAndStore.get(caseOwners.get(ca.OwnerId).defaultStore__c).id;}  
                            prospectsToUpdate.put(pros.id, pros); 
                        }
                    }
                    
                }
            }
            
            System.debug('casesToProcess: ' + casesToProcess);
            if(prospectsToUpdate.values().size() > 0)
            {
                update prospectsToUpdate.values();
            } 
        }
    }
    
    public static void checkSpam(List<Case> newCaseList) {
        Map<Case, ICX_EmailSpam.SpamWrapper> spamMap = ICX_EmailSpam.checkSpam(newCaseList);
        for (Case request : spamMap.keySet()) {
            ICX_EmailSpam.SpamWrapper wrapper = spamMap.get(request);
            if (wrapper != null && wrapper.createCase != null && wrapper.createCase) {
                request.Spam__c = true;
                request.SpamReason__c = wrapper.reason;
            } else {
                System.debug('Email is considered as a spam: ' + request.SuppliedEmail + ' / ' + request.Subject);
                request.Spam__c.addError('Email is considered as a spam: ' + request.SuppliedEmail + ' / ' + request.Subject);
            }
        }
    }
    
    
    
    
    
    /* replace by Process Builder // Change the SYSTEM owner by the Queue Id
// Used when a new Case is created when a message is sent from a Closed Case
private static void setOwnerOnNewCaseWithCloseParent(List<Case> newCaseList) {
for (Case cas : newCaseList) {
System.debug('cas.TECH_Queue_ID__c' + cas.TECH_Queue_ID__c);
if (String.isNotBlank(cas.TECH_Queue_ID__c)) {
cas.OwnerId = cas.TECH_Queue_ID__c;
}
}
}*/
    
    // create CaseComment
    // Note: not possible to create CaseComment in Process Builder or Workflow without code
    // https://success.salesforce.com/ideaView?id=08730000000DklUAAS
    private static List<CaseComment> createCaseComment(List<Case> caseList, Map<id, case> oldCaseMap) {
        List<CaseComment> caseCommentList = new List<CaseComment>();
        
        System.debug('caseList=' + caseList);
        // Set<Id> caseReassignedIdSet = new Set<Id>();
        Set<Case> caseReassignedIdSet = new Set<Case>();
        for (Case cas : caseList) {
            // Process Builder updates from "Reassign to CSC" to blank. So the code is called beforeUpdate
            if ('Reassign to CSC'.equals(cas.In_Store_Action__c) && !'Reassign to CSC'.equals(oldCaseMap.get(cas.Id).In_Store_Action__c)) {
                caseReassignedIdSet.add(cas);
            }
        }
        System.debug('caseReassignedIdSet=' + caseReassignedIdSet);
        
        if (!caseReassignedIdSet.isEmpty()) {
            for(Case cas : caseReassignedIdSet) {
                System.debug('cas=' + cas.Id);
                CaseComment comment = new CaseComment();
                comment.CommentBody = 'Request updated by store:\nIn store action: \'' + cas.In_Store_Action__c + '\'' + 
                    (String.isNotBlank(cas.Store__r.Name) ? '\nStore: ' + cas.Store__r.Name : '') + 
                    (String.isNotBlank(cas.CA_Name__r.Name) ? '\nCA Name: ' + cas.CA_Name__r.Name : '');
                comment.ParentId = cas.Id;
                caseCommentList.add(comment); 
            }
        }
        
        if (!caseCommentList.isEmpty() && Schema.sObjectType.CaseComment.isCreateable()) {
            insert caseCommentList;
        }
        
        return caseCommentList;
    }
    
    
    private static void checkChildrenClosedBeforeClosingEscalation(List<Case> newCaseList, Map<id, case> oldCaseMap) {
        
        //check if children are closed before closing the case when there is an escalation manual - Naomi Baroghel 02.2022
        
        
        Set<Id> caseEscalatedSet = new Set<Id>();
        List<String> resolution = new List<String> {'Reply Made','Immediate Response','No Response Required','Transfer to Headquarters','Transfer to Store', 'Sent Catalogue_Brochure_TYC_Invitation'};
            Map<String, Integer> mapCasesParentChildren = new Map<String, Integer>() ;
        Map<String, Integer> mapCareServicesParentChildren = new Map<String, Integer>() ;
        
        for(Case caseRecord : newCaseList){
            if(caseRecord.Escalation_Type__c=='Manual' && ((caseRecord.Resolution__c != oldCaseMap.get(caseRecord.Id).Resolution__c &&  resolution.contains(caseRecord.Resolution__c)) || (caseRecord.Escalation_Status__c !=oldCaseMap.get(caseRecord.Id).Escalation_Status__c && caseRecord.Escalation_Status__c =='Closed' ))) {
                caseEscalatedSet.add(caseRecord.Id);
            }
        }
        
        for(AggregateResult aggCase : [SELECT ParentId,COUNT(Id) nbRecords FROM Case WHERE ParentId  IN: caseEscalatedSet AND (NOT Status IN ('Cancelled', 'Successful', 'Closed','My Product on Demand (with sku) created'))  GROUP BY ParentId])
        {
            mapCasesParentChildren.put(String.valueOf(aggCase.get('ParentId')) ,Integer.valueOf(aggCase.get('nbRecords')));
        }
        
        for(AggregateResult aggCareService : [SELECT Parent_Request__c,COUNT(Id) nbRecords FROM CareService__c WHERE Parent_Request__c  IN: caseEscalatedSet AND  RecordType.DeveloperName = 'DistantCareService' AND (NOT ICONiCS_Status_Detail__c IN ('Delivered to Client', 'Cancelled'))  GROUP BY Parent_Request__c])
        {
            mapCareServicesParentChildren.put(String.valueOf(aggCareService.get('Parent_Request__c')) ,Integer.valueOf(aggCareService.get('nbRecords')));
        }
        
        for(Case caseRecord : newCaseList){
            if(mapCasesParentChildren.get(caseRecord.id) > 0 || mapCareServicesParentChildren.get(caseRecord.id) > 0){
                caseRecord.adderror('To close the status of the escalation request (parent), please close first the related request (child)');
            }
        }
    }
    
    private static void applyAssignmentRules(List<Case> caseList) {
        System.debug('applyAssignmentRules > caseList=' + caseList);
        
        Id recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('Operation_Exception').getRecordTypeId();
        if (caseList != null && String.isNotBlank(recordTypeId)) {
            // Problem to apply Assignment Rules on Flow (Flow + Class OR Process Builder/Apex => KO). Workaround : Trigger
            List<Case> operationExceptionList = new List<Case>();
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            
            for (Case cas : caseList) {
                if (recordTypeId.equals(cas.RecordTypeId)) {
                    // Avoid CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, CaseTrigger: execution of AfterInsert
                    Case newCaseAfterInsert = new Case(Id = cas.Id);
                    newCaseAfterInsert.setOptions(dmo);
                    operationExceptionList.add(newCaseAfterInsert);
                }
            }
            if (!operationExceptionList.isEmpty() && Schema.sObjectType.Case.isUpdateable()) {
                System.debug('Operation Exception. operationExceptionList.size=' + operationExceptionList.size());
                update operationExceptionList;
            }
        }
    }
    
    // After insert
    //@future
    private static void onlineReturnEmail(List<Case> caseList) {
        
        Map<String, Case> caseByEmailMap = new Map<String, Case>();
        for (Case cas : caseList) {
            if ('Email'.equals(cas.Origin) && 'ams_digital.fr@louisvuitton.com'.equals(cas.SuppliedEmail)) {
                
                cas.Type = 'Sales';
                cas.Category__c = 'Exchange/Return';
                String email = '';
                if(!test.isRunningTest()){email = cas.Description.substringBetween('Client email :','- Client phone number');}
                System.debug('email=' + email);
                if (String.isNotBlank(email)) {
                    caseByEmailMap.put(email.trim(), cas);
                    //String emailTrim = email.trim();
                    //List<Account> accList = [SELECT Id FROM Account WHERE PersonEmail = :emailTrim ORDER BY LastTrans__pc, LastModifiedDate DESC];
                    //cas.AccountId = (!accList.isEmpty() ? accList[0].Id : null);
                }
                
                //String sku = cas.Description.substringBetween('Reference of the product to return :','- Quantity').trim();
                //System.debug('sku=' + sku);
                //String orderId = cas.Description.substringBetween('Order ID : ','- Shipping group').trim();
                //System.debug('orderId=' + orderId);
                //String shippingGroup = cas.Description.substringBetween('Shipping group : ','- Product name to return').trim();
                //System.debug('shippingGroup=' + shippingGroup);
                
                //ProductCatalogue__c  prod = new ProductCatalogue__c(SKU__c = 'xxx');
                //cas.Product_Sku__r = prod;
                
                
            }
        }
        
        if (!caseByEmailMap.isEmpty()) {
            for (Account acc : [SELECT Id, PersonEmail FROM Account WHERE PersonEmail IN :caseByEmailMap.keySet() ORDER BY LastTrans__pc, LastModifiedDate DESC]) {
                if (caseByEmailMap.get(acc.PersonEmail) != null) {
                    caseByEmailMap.get(acc.PersonEmail).AccountId = acc.Id;
                }
            }
            
        }
        
    }
    
    // Update Interests__c linked to Account if Tags change in DPCA Request
    private static void updateTags(Case mycase){          
        List<Interests__c> lstTagsToInsert = new List<Interests__c> ();
        List<Interests__c> lstTagsToDelete = new List<Interests__c> ();
        List<String> tagsDPCA = new List<String>();
        String strTags = mycase.Categories__c ;
        system.debug('mycase.Categories__c : '+mycase.Categories__c);
        if(strTags != null)
            tagsDPCA = strTags.split(';');
        
        system.debug('tagsDPCA : '+tagsDPCA);
        List<String> tagsClient = new List<String> ();
        List<Interests__c> lstTags  = [SELECT id, Categories__c FROM Interests__c WHERE Client__c=:mycase.AccountId AND isActive__c = true AND source__c = 'DPCA'];
        for(Interests__c tag : lstTags ){
            tagsClient.add(tag.Categories__c);
        }
        
        //Add Tag
        for(String oneStrTag : tagsDPCA){
            If(tagsClient.contains(oneStrTag)==false){
                Interests__c newTag = new Interests__c (Categories__c = oneStrTag, Client__c = mycase.AccountId,isActive__c = true, source__c = 'DPCA');
                lstTagsToInsert.add(newTag);
            }    
        }
        if(lstTagsToInsert.size()>0)
            insert lstTagsToInsert;
        
        Set<String> setTag = new Set<String> ();
        //Delete Tag
        for(String oneStrTag : tagsClient){
            If(tagsDPCA.contains(oneStrTag)==false){
                setTag.add(oneStrTag);             
            }    
        }
        if(setTag.size()>0){
            lstTagsToDelete = [SELECT Id FROM Interests__c WHERE Client__c =:mycase.AccountId AND Categories__c IN :setTag AND source__c = 'DPCA' AND isActive__c = true ];
            
            delete lstTagsToDelete;
        }
        
    }
    
    private static void updateAccountDPCA(Set<Id> setAccountIdNoDPCA, Set<Id> setAccountIdDPCA){
        List<Account> accountToUpdate = new List<Account>();
        
        String query = 'SELECT Id, Subscribed_to_Digital_Concierge__c FROM Account WHERE';
        if(setAccountIdNoDPCA != null) {
            query += ' Id IN : setAccountIdNoDPCA';
            if(setAccountIdDPCA != null) {
                query += ' or Id IN : setAccountIdDPCA';
            }
        }
        else if(setAccountIdDPCA != null) {
            query += ' Id IN : setAccountIdDPCA';
        }
        
        if(setAccountIdNoDPCA != null || setAccountIdDPCA != null) {
            for(Account acc : Database.query(query)) {
                if (setAccountIdNoDPCA != null && setAccountIdNoDPCA.contains(acc.Id)) {
                    acc.Subscribed_to_Digital_Concierge__c = false;
                } else if(setAccountIdDPCA != null) {
                    acc.Subscribed_to_Digital_Concierge__c = true;
                }
                accountToUpdate.add(acc);
            }
        }
        
        if(!accountToUpdate.isEmpty()) {
            update accountToUpdate;
        }
    }
    
    
    private static void checkDuplicateDPCA(Set<Id> setAccount, List<Case> newDPCAList){
        List<Case> oldDPCAList = [SELECT Id,Account.Name,AccountId FROM Case WHERE AccountId IN:setAccount AND RecordType.DeveloperName ='Digital_Private_CA' AND Status != 'Not Interested'];
        if(oldDPCAList.size()>0){
            for(Case existingDPCA : oldDPCAList){
                for(Case myCase:newDPCAList){  
                    if (myCase.AccountId == existingDPCA.AccountId) {
                        myCase.addError('An active DPCA Request exist already for the client ' + existingDPCA.Account.Name);
                    }             
                }
            }
        }
    }
    //NI-2214 Prefilled "Country" field for DPCA requests  28/06/2023 By Keman WU
    private static void prefilledCountryDPCA(Set<Id> setAccount, List<Case> newDPCAList){
        Map<ID, Account> mapAccount = new Map<ID, Account>([SELECT Id, PrimaryCountry__pc From Account WHERE Id in:setAccount]); 
        
        for(Case newDPCA : newDPCAList){
            
            if(mapAccount.get(newDPCA.AccountId).PrimaryCountry__pc != null){
                newDPCA.Country__c = mapAccount.get(newDPCA.AccountId).PrimaryCountry__pc;
            }else{
                newDPCA.addError('Please fill in the "Country/Region" field on client page before');
            } 
            
        }       
    }


    

    //OE Duplicate - naomi 10/2023
    private static void checkOEDuplicate(List<Case> caseNewList, Boolean isOnlyShippingGroupNumberUpdate, Map<Id,Case> oldCaseMap)
    {
        
        if(!caseNewList.isEmpty())
        {

            Id OERecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operation Exception').getRecordTypeId();
            
            List<String> OECaseOrderShippingNumber = new List<String>();
            List<Id> OrderShippingIds = new List<Id>();
            List<Id> OrderShippingIdsToAdd = new List<Id>();

            Map<Case,Id> mapCaseOrderShipping = new Map<Case,Id>();
            Map<Case,Id> mapCaseOrderShippingToAdd = new Map<Case,Id>();

            Map<Id,String> mapOrderShippingShippingNumber = new Map<Id,String>();
            Map<Case,String> mapCaseShippingNumber = new Map<Case,String>();

            for(Case currentCase : caseNewList)
            {
                if(currentCase.RecordTypeId==OERecordTypeId  ) 
                {
                    if(currentCase.Order_Shipping__c!=null)
                    {
                        if(!currentCase.IgnoreDuplicateOE__c && !isOnlyShippingGroupNumberUpdate)
                        {

                            
                            System.debug(' Order_Shipping__c '+ currentCase.Order_Shipping__c);
                            System.debug(' Order_Shipping__r.ShippingNumber__c '+ currentCase.Order_Shipping__r.ShippingNumber__c);
                            
                            OrderShippingIds.add(currentCase.Order_Shipping__c);
                            mapCaseOrderShipping.put(currentCase,currentCase.Order_Shipping__c);
                            System.debug(' mapCaseOrderShipping '+ mapCaseOrderShipping);
                        }
                        mapCaseOrderShippingToAdd.put(currentCase,currentCase.Order_Shipping__c);
                        OrderShippingIdsToAdd.add(currentCase.Order_Shipping__c);


                }

                }
            }


            //temporary solution because we need a hybride solution with lookup OrderShipping__c and Shipping_group__c on Operation Exception Case
            if(!OrderShippingIds.isEmpty() || !OrderShippingIdsToAdd.isEmpty())
            {
                List<OrderShipping__c> orderShippingList = [SELECT Id, ShippingNumber__c FROM OrderShipping__c WHERE ID IN:OrderShippingIds OR ID IN:OrderShippingIdsToAdd];
                for(OrderShipping__c currentOrderShipping: orderShippingList )
                {
                    mapOrderShippingShippingNumber.put(currentOrderShipping.Id,currentOrderShipping.ShippingNumber__c);
                    System.debug(' mapOrderShippingShippingNumber '+ mapOrderShippingShippingNumber);

                }
            }

            if(!isOnlyShippingGroupNumberUpdate)
            {

            

            for(Case currentCase : mapCaseOrderShipping.keySet())
            {
                if(mapOrderShippingShippingNumber.get(mapCaseOrderShipping.get(currentCase))!=null)
                {
                    String shippingNumber = mapOrderShippingShippingNumber.get(mapCaseOrderShipping.get(currentCase));
                    mapCaseShippingNumber.put(currentCase,shippingNumber);
                    System.debug(' mapCaseShippingNumber '+ mapCaseShippingNumber);
                    OECaseOrderShippingNumber.add(shippingNumber);
                    System.debug(' OECaseOrderShippingNumber '+ OECaseOrderShippingNumber);


                }
            }

            Map<String,String> mapShippingNumberCaseNumber = new Map <String,String>();
            if(!mapCaseShippingNumber.isEmpty())
            {
                List<Case> duplicateOE = [SELECT Id,CaseNumber,Order_Shipping__c,Order_Shipping__r.ShippingNumber__c,Shipping_group__c FROM Case WHERE RecordTypeId=:OERecordTypeId AND ((Order_Shipping__r.ShippingNumber__c IN: OECaseOrderShippingNumber AND Order_Shipping__c!=null) OR (Shipping_group__c IN: OECaseOrderShippingNumber AND Shipping_group__c!=null)) AND Status!='Closed'];
                if(!duplicateOE.isEmpty())
                {

                    String separator=' ';
                    for(Case currentCase : duplicateOE)
                    {
                        String currentShippingNumber;
                        if(currentCase.Order_Shipping__c!=null)
                        {
                            currentShippingNumber=currentCase.Order_Shipping__r.ShippingNumber__c;

                        }
                        else if(!String.isBlank(currentCase.Shipping_group__c))
                        {
                            currentShippingNumber=currentCase.Shipping_group__c;
                        }
                        if(!String.isBlank(currentShippingNumber))
                        {

                            System.debug(' currentShippingNumber '+ currentShippingNumber);

                            if(mapShippingNumberCaseNumber.get(currentShippingNumber)==null)
                            {
                                mapShippingNumberCaseNumber.put(currentShippingNumber,'');
                            }

                            mapShippingNumberCaseNumber.put(currentShippingNumber,mapShippingNumberCaseNumber.get(currentShippingNumber)+separator+currentCase.CaseNumber);
                            separator=' , ';
                            System.debug(' mapShippingNumberCaseNumber '+ mapShippingNumberCaseNumber);
                        }
                    }
                }

            }

            if(!mapShippingNumberCaseNumber.isEmpty() && !mapCaseShippingNumber.isEmpty() && !isOnlyShippingGroupNumberUpdate)
            {
                for(Case currentCase : mapCaseShippingNumber.keySet())
                {
                    String newShippingNumber = mapCaseShippingNumber.get(currentCase);
                    System.debug(' newShippingNumber '+ newShippingNumber);

                    if(mapShippingNumberCaseNumber.containsKey(newShippingNumber))
                    {
                        currentCase.addError('There is other(s) Operation Exception with the same Shipping Number : ' + mapShippingNumberCaseNumber.get(newShippingNumber) + '. To continue with the Operation Exception, check the IgnoreDuplicateOE field.');
                    }
                    
                }

            }
        }

            //add shipping number into case for search purpose

            for(Case currentCase : caseNewList)
            {
                if(oldCaseMap==null) //at creation
                {
                    if(!mapOrderShippingShippingNumber.isEmpty())
                    {
                        if(mapOrderShippingShippingNumber.get(mapCaseOrderShippingToAdd.get(currentCase))!=null)
                        {
                            currentCase.Shipping_Group_Number__c =mapOrderShippingShippingNumber.get(mapCaseOrderShippingToAdd.get(currentCase));
                        }
                    }
                }
                else
                {
                    if(oldCaseMap.get(currentCase.Id).Order_Shipping__c != currentCase.Order_Shipping__c)
                    {
                        if(currentCase.Order_Shipping__c==null)
                        {
                            currentCase.Shipping_Group_Number__c='';

                        }
                        else if(mapOrderShippingShippingNumber.get(mapCaseOrderShippingToAdd.get(currentCase))!=null)
                        {
                            currentCase.Shipping_Group_Number__c =mapOrderShippingShippingNumber.get(mapCaseOrderShippingToAdd.get(currentCase));
                        }
                        
                    }
                }
            }
           
        
        }
    }

    //OE assigned to Store, with status__c = 'Store New', change the field isOEAssignedToStore__c to true
    private static void updateFieldOEToStore(List<Case> caseNewList) {
        if(!caseNewList.isEmpty()){
            Id OERecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operation Exception').getRecordTypeId();

            for(Case currentCase : caseNewList){
                if(currentCase.RecordTypeId == OERecordTypeId  ) {
                    if(((currentCase.Status == 'Store New') && (String.IsNotEmpty(currentCase.Store__c)))) {
                        currentCase.isOEAssignedToStore__c = true;
                    }

                }
            }
        }
    }

    @future(callout=true)
    public static void invokeFlowNotificationEmailForOE(Id recordId) {
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('recordId', recordId);

        Flow.Interview.ICX_OE_Store_Notification notifFlow = new Flow.Interview.ICX_OE_Store_Notification(Params);

        if(!Test.isRunningTest()) notifFlow.start();
    }
        
}