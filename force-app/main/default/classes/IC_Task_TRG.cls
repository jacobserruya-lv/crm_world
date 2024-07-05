/*
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
    Oct 2017 / updateActionTypeAsEmail / Created by LEL 
    Fev 2023  /  taskApprovalRejected  / Naomi Baroghel
    Feb 2024 / Add new params to Notification/Notification Parameter / ouramdane.a (SV-256, SV-276)
    Issues / TODOs
    --------------
*/
public class IC_Task_TRG {

    /**
    * Method for trigger Task_BeforeInsert, Task_BeforeUpdate 
    * This trigger is fired only when the user profile is equal to "Interface Dream" the user that can load
    * Data from Dream, It sets the account and contact Id  in fields WhatId and WhoId  
    */
    public static void taskSetWhatId(List<Task> newValues) {
        Set<String> dreamIds = new Set<String>(); 
        Map<String, String> mapByDreamId = new Map<String, String>();
        for (Task t : newValues){
            if (String.isNotBlank(t.DREAMIDCLIENT__c) && t.SourceType__c == 'ONEDATA'){
                dreamIds.add(t.DREAMIDCLIENT__c);
            }
        }
        List<Account> accounts = [select ID, DREAMID__C from Account Where DREAMID__C in :dreamIds];
        for (Account a : accounts){
            if (mapByDreamId.get(a.DREAMID__c) == null)
                mapByDreamId.put(a.DREAMID__C, a.Id);
        }
        for (Task t : newValues){
            if (String.isNotBlank(t.DREAMIDCLIENT__c) && t.SourceType__c == 'ONEDATA'){
                System.debug(mapByDreamId.get(t.DREAMIDCLIENT__c));
                t.WhatId = mapByDreamId.get(t.DREAMIDCLIENT__c);
            }
        }
    }

    /**
     * Fill WhoId with ContactId linked to whatId record
     */
    public static void setWhoId(List<Task> tasks){
        setWhoId(tasks, null);
    }

    /**
     * Fill WhoId with ContactId linked to whatId record
     */
    /*
    public static void setWhoId(List<Task> tasks, Map<Id, Task> oldData){
        for(Task t : tasks) {
            if(oldData != null) {
                Task oldTask = oldData.get(t.Id);
                if(oldTask.WhatId == t.WhatId){
                    return;
                }
            }
            if(String.isNotBlank(t.whatId) && String.valueOf(t.WhatId).startsWith('001') && !t.TECH_CTI__c){
                Contact contact = [SELECT Id FROM Contact WHERE IsPersonAccount = true AND AccountId = :t.WhatId];
                t.WhoId = contact.Id;
            }
        }
    }*/
    
    public static void setWhoId(List<Task> tasks, Map<Id, Task> oldData){
        
        List<Task> tasksToUpdate = new List<Task>();       
        Set<Id> setIds = new Set<Id>();
        Map<Id, Id> mapIds = new Map<Id, Id>();
        
        // get all WhatId
        for(Task t : tasks) {
            Boolean isUpdated = oldData != null && oldData.get(t.Id).WhatId != t.WhatId;
            Boolean isNewOrUpdated = oldData == null || isUpdated;
            Boolean isValidId = String.isNotBlank(t.whatId) && String.valueOf(t.WhatId).startsWith('001') && !t.TECH_CTI__c;
            
            if(isNewOrUpdated && isValidId){
                tasksToUpdate.add(t);
                setIds.add(t.whatId);
            }        
        }
        
        // Create Map WhatId => WhoId
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact WHERE IsPersonAccount = true AND AccountId = :setIds];
        for(Contact contact : contactList){
            mapIds.put(contact.AccountId, contact.Id);
        }
        
        // Update WhoId Field
        for(Task t : tasksToUpdate) {
            t.WhoId = mapIds.get(t.WhatId); 
        }
    }

    public static void taskSetDreamIds(List<Task> newValues) {
        //Execute only if ProfileId = DREAM Interface ProfileID
        if(IC_UTILS.isInterfaceDream()){
            System.debug('================= oui');
            //Retrieve set of CLIENT DREAM IDs
            Set<String> dreamids = new Set<String>();
            for(Task T : newValues) {
                // j'ai changer le && en ||
                if( IC_UTILS.getTaskDreamRT()== T.recordTypeId || !IC_UTILS.empty(T.DREAMIDCLIENT__c)) dreamids.add(T.DREAMIDCLIENT__c);
            }
            //Retrieve contact list in function of CLIENT DREAM IDs
            Map<String, Contact> contactMap  = new Map<String, Contact>();
            List<Contact> contacts = [select ID, AccountId, Account.DREAMID__C from Contact Where Account.DREAMID__C in :dreamids];
            for(Contact c : contacts) {
                contactMap.put(c.Account.DREAMID__C, c); 
            } 
            //Set whatid and whoid of the tasks
            for(Task T : newValues) {
                if (IC_UTILS.getTaskDreamRT()== T.recordTypeId && !IC_UTILS.empty(contactMap.get(T.DREAMIDCLIENT__c))) {
                    T.whatid = contactMap.get(T.DREAMIDCLIENT__c).AccountId;
                    T.whoid = contactMap.get(T.DREAMIDCLIENT__c).Id; 
                }
            }
        }
        // Begin RMOU
        else if (!IC_UTILS.isInterfaceDataStage())
        {
            for (Task t : newValues){
                t.sendToOneClient__c = true;
            }
        }
       // End RMOU
    }
   
    /**
    * Method for trigger Task_BeforeInsert, Task_BeforeUpdate 
    * This trigger is fired only when the task comes from worflow after client list insertion
    */
    public static void taskSetAutoSaveFieldBis(List<Task> newValues) {
        for(Task T : newValues) {
            //if(T.What instanceof CLI_CliList__c && ((CLI_CliList__c)T.What).TECH_CreatedFromTCLScreen__c)
            //if(T.WhatId != null && T.What.Type == 'CLI_CliList__c')
            if(IC_Utils.CLL_CreatedBy_TCL(T.WhatId))
                T.TECH_is_AutoSave__c = true;
        }
   }
   
    /**
    * Method for trigger Task_BeforeInsert
    * update tasks TaskSubtype before insert trigger. 
    * Reason Before Insert : TaskSubType is not writable
    */
    public static void updateTypeAsCall(List<Task> tasks){
        for(Task T : tasks) {
            string tasubtype = T.tasksubtype; 
            system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@: subtype: ' + tasubtype);

            // Categorize CTI call as Call (more precise for Activity Timeline)
            if (String.isNotBlank(T.cnx__UniqueId__c) && (String.isEmpty(T.TaskSubtype) || !'Call'.equals(T.TaskSubtype))) {
                T.TaskSubtype = 'Call';
                T.ActionType__c = 'Phone';

            }
        }
    }

    /**
    * Method for trigger TaskAfterInsert
    * Workflow doesn't work for Task after an email sent from a Case. So Update the Record Type by WF is KO.
    * Workaround: update the Record Type by code
    * Reason After Insert : Before insert has TaskSubType empty for outbound email / After Insert has TaskSubType not empty
    * This trigger is called for each new task in order to set task as email when an outbound email is sent
    */
    public static void updateActionTypeAsEmail(List<Task> tasks){
        List<Task> tskToUpdateSet = new List<Task>();

        Id iconicsEmailRecordTypeId;
        try {
            iconicsEmailRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Email').getRecordTypeId();
        } catch (Exception e) {}

        for(Task T : [SELECT Id, Subject, tasksubtype, ActionType__c, TECH_IsWhatIdCase__c, RecordTypeId FROM Task WHERE Id = :tasks]) {
            string ta = T.Subject;
            system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@: Subject: ' + ta);
            string tasubtype = T.tasksubtype; 
            system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@: subtype: ' + tasubtype);
            if(String.isNotBlank(ta))
            {
                // adding 'Email' for tasksubtype as Subject can be 'E-Mail:' (as seen with Iconics users in Russia/Germany role)
                if('Email'.equals(tasubtype) || ta.startswith('Email:') ) {
                    T.ActionType__c = 'Email';
                    
                    if (T.TECH_IsWhatIdCase__c && String.isNotBlank(iconicsEmailRecordTypeId)) {
                        T.RecordTypeId = iconicsEmailRecordTypeId;
                    }
                    tskToUpdateSet.add(T);
                }
            }
        }

        if (!tskToUpdateSet.isEmpty()) {
            update tskToUpdateSet;
        }
    }

   /**
    * Method for trigger Task_BeforeInsert, Task_BeforeUpdate 
    * This trigger is fired only when the task comes from worflow after client list insertion
    */
        public static void taskSetAutoSaveField(List<Task> newValues) {
        System.debug ('newValues ' + newValues.size ());
        
        List<ID> listId = new List<Id>();
        for (Task T : newValues) {
            listId.add(T.WhatId);
        }       
        List<CLI_CliList__c> listt = [Select Id, TECH_CreatedFromTCLScreen__c From CLI_CliList__c Where Id IN :listId];
        
        Map<ID,CLI_CliList__c> mapCList = new Map<ID,CLI_CliList__c>();
        for(CLI_CliList__c c: listt){
            mapCList.put(c.Id,c);
        } 
        System.debug ('mapCList ' + mapCList.size ());      
        for(Task T : newValues) {
            boolean bool = false;
            if(mapCList.Keyset().contains(T.WhatId)) {
                CLI_CliList__c cll = mapCList.get(T.WhatId);            
                if(cll.TECH_CreatedFromTCLScreen__c){
                    bool = cll.TECH_CreatedFromTCLScreen__c;
                }                                
            }
            if (bool) {
                T.TECH_is_AutoSave__c = true;
            } 
        }
    }
    
    /**
    * Method for trigger Task_AfterInsert, Task_AfterUpdate 
    * Method for batch IC_BatchTaskLastContactDate
    * This trigger is fired only when==============================
    */
    public static void taskSetAccLastContactDate(List<Task> lstTask){  
        /*
            QUERY : 
            Select Id, AccountId, ActivityDate, Account.LastContactDate__pc from Tasks 
            Where (ActivityDate = TODAY or ActivityDate = LAST_N_DAYS:30) 
            and (ActionType__c IN ('Email','Phone','SMS','Mobile Chat')) 
            and RecordTypeId != IC_UTILS.getTaskDreamRT()
            
            ------------------------------------------------------------------
            IF task.activityDate > account.LastContactDate => update account
            IF task.activityDate <= account.LastContactDate => no update
        */
        
        Map<Id, Date> mapAcc = new Map<Id, Date>();
        List<task> caseTask = new List<Task>();
        List<Task> otherTask = new List<Task>();
        List<id> caseIds = new List<id>();

        for(Task t:lstTask){
            if(String.isNotBlank(t.whatid))
            {
                if(String.valueOf(t.whatid).startswith('500'))
                {
                    // Task is related to a Case 
                    caseIds.add(t.whatid);
                }
            }

        }
        // get cases attached to tasks
        Map<id, Case> parentCases = new Map<id, Case>([SELECT id, accountid, account.LastContactDate__pc from Case where id in: caseIds]);

        for(Task t: lstTask)
        {
            // for tasks related to Account, Opportunity or custom objects related to Account
            if(t.AccountId != null)
            {
                if(!mapAcc.containsKey(t.AccountId)){
                    if(t.ActivityDate > t.Account.LastContactDate__pc || t.Account.LastContactDate__pc==null){
                        mapAcc.put(t.accountId, t.ActivityDate);
                    }
                }else{
                    if(t.ActivityDate > mapAcc.get(t.AccountId)){
                        mapAcc.put(t.accountId, t.ActivityDate);
                    }
                } 
            }
            // for tasks related to Case
            else if(parentCases.containsKey(t.whatid))
            {
                // get the id of the parent account and its last contact date of the case
                String accID = parentCases.get(t.whatid).accountid;
                Date accLastContactDate = parentCases.get(t.whatid).account != null? parentCases.get(t.whatid).account.LastContactDate__pc: null;
                if(!mapAcc.containsKey(accID))
                {
                    if(t.ActivityDate > accLastContactDate || accLastContactDate==null)
                    {
                        mapAcc.put(accID, t.ActivityDate);
                    }
                }
                else
                {
                    if(t.ActivityDate > mapAcc.get(accID))
                    {
                        mapAcc.put(accID, t.ActivityDate); 
                    } 
                }

            }
            
        }
        System.debug('>>>> mapAcc: ' + mapAcc);
        List<Id> lstAccId = new List<Id>(mapAcc.keySet());
        System.debug ('lstAccId' + lstAccId);
        //builds list of accounts to update
        List<Account> lstAcc = new List<Account>();
        lstAcc = [Select id, LastContactDate__pc from Account where id in :lstAccId];
        System.debug ('lstAcc' + lstAcc);
        
        for(Account acc :lstAcc){
            acc.LastContactDate__pc = mapAcc.get(acc.id);
            System.debug ('acc.LastContactDate__pc CLS' + acc.LastContactDate__pc);
        // lstAcc.add(new Account(Id=i, LastContactDate__pc=mapAcc.get(i)));
        }
        // for(Id i:lstAccId){
        //    lstAcc.add(new Account(Id=i, LastContactDate__pc=mapAcc.get(i)));
        // } 
        update lstAcc;
    }
   
    public static List<Task> toFilterTaskList(List<Task> MyTasks){    
        List<Task> result = new List<Task>();
        Integer lastContactTimeRange = Integer.valueOf(ICONSettings__c.getOrgDefaults().get('AccLastContactTimeRange__c'));
        if (IC_UTILS.empty(lastContactTimeRange)) {
            lastContactTimeRange = 0;
        }
        Date dateOfToday = System.today(); 
        system.debug('lastContactTimeRange: '+lastContactTimeRange);
        for(Task tsk :  MyTasks){
            if((tsk.ActivityDate <= dateOfToday && tsk.ActivityDate > dateOfToday-lastContactTimeRange) 
                && (tsk.ActionType__c=='Email'||tsk.ActionType__c=='Phone'||tsk.ActionType__c=='SMS'||tsk.ActionType__c=='Mobile Chat'||tsk.ActionType__c=='Postal Mail' ||tsk.ActionType__c=='WhatsApp'||tsk.ActionType__c=='Card'||tsk.ActionType__c=='Social'||tsk.ActionType__c=='Chat'||tsk.ActionType__c=='Line, KakaoChat, WeChat'||tsk.ActionType__c=='Other Messenger and Social Media apps'||tsk.ActionType__c=='Gift'||tsk.ActionType__c=='Other')
                && tsk.RecordTypeId != IC_UTILS.getTaskDreamRT()){
                    result.add(tsk);
            }
        }
        system.debug('>>> Result: '+ result);
        return result; 
   }

    /**
     * @description
     * Helps to display tasks related to cases on account page. 
     * For this, the whoid field must hold the contact id
     * used before insert the Task + before update when the WhatId changed (CTI change the WhoId field but not the WhatId)
     * 
     * @param
     * taskList: list of newly created tasks
     **/
    public static void relatedCaseTaskToAccount(List<Task> taskList)
    {
        List<id> attachedCaseIDs = new List<id>();
        List<Id> accountIdTaskList = new List<Id>();
        
        List<Task> caseTasks = new List<Task>();
        for(Task t: taskList)
        {
            //System.debug('TRIGGER TASK > task=' + t);
            // if task is attached to a case then what id = case id + Not in a CTI call otherwise the AccountId will become empty
            if(String.isNotBlank(t.whatid) && String.valueOf(t.whatid).left(3) == '500' && !t.TECH_CTI__c)
            {
                attachedCaseIDs.add(t.whatid);
                caseTasks.add(t);
                //} else if (String.valueOf(t.whatid).left(3) == '001' && t.TECH_CTI__c) {
            } else if (t.TECH_CTI__c && String.isBlank(t.WhoId)) {
                // update if CTI connector (Bucher+Suter) sends AccountId instead of WhoId (when the WhatId changed from Account id to Case id, the AccountId became empty)
                //accountIdTaskList.add(t.whatId);
                Id accountId;
                if (String.isNotBlank(t.AccountId)) {
                    // During commit in insert / update, the AccountId is set by Salesforce (maybe because of Master/Detail relationship with WhatId: Account object is linked by an object as WhatId with M/D)
                    accountId = t.AccountId;
                } else {
                    accountId = ICX_CaseDataServiceControllerLC.getAccountId(t.whatid);
                }
                
                if (String.isNotBlank(accountId)) {
                    accountIdTaskList.add(accountId);
                    caseTasks.add(t);
                }
            }
        }
        //System.debug('accountIdTaskList=' + accountIdTaskList);

        //System.debug('caseTasks=' + caseTasks);
        if (!caseTasks.isEmpty()) {
            Map<id,Case> attachedCases = new Map<id,Case>( [SELECT id, contactid FROM Case where id in :attachedCaseIDs]);
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN :accountIdTaskList]);
            
            For (Task t: caseTasks)
            {
                // if the Name field (whoid) is empty then fill it with the contact id
                //if(t.whoid == null)
                //{
                if(attachedCases.containsKey(t.whatid))
                {
                    t.whoid = attachedCases.get(t.whatid).contactid;
                } else {
                    if (String.isNotBlank(t.AccountId)) {
                        t.whoid = accountMap.get(t.AccountId).PersonContactId;
                    }
                    if (accountMap.get(t.whatid) != null && String.isNotBlank(accountMap.get(t.whatid).PersonContactId)) {
                        t.whoid = accountMap.get(t.whatid).PersonContactId;
                    }
                }

                // clear the Contact Id in WhatId (to avoid confusion for users)
                if (t.TECH_CTI__c && String.isNotBlank(t.whatid) && String.valueOf(t.whatid).left(3) == '001') {
                    t.whatId = null;
                }
                //}
            }
        }
    } 

    /**
     * @description Set the In/Out field on tasks based on the Incoming field value on 
     * related EmailMessage. 
     * This is done only for tasks resulting from an email.
     * @param emailTaskMap: Map of tasks and related emails
    **/
    public static void setInOutOnTask(Map<Task, EmailMessage> emailTaskMap)  
    {
        Set<Task> taskList = emailTaskMap.keySet();
        List<Task> tasksToUpdate = new List<Task>();
        for(Task t: taskList)
        {
            // make sure task resut from an email
            if(t.ActionType__c == 'Email')
            {
                // set the In/Out field on task based on the Iconming value on email
                EmailMessage em = emailTaskMap.get(t);
                if(em != null)
                {
                    boolean incoming = emailTaskMap.get(t).Incoming;
                    t.inout__c = incoming? 'In': 'Out';
                    tasksToUpdate.add(t);  
                }
            }
        }
        if(tasksToUpdate.size() > 0)
        {
            update tasksToUpdate;
        }
        
    }

    /**
     *@description
     * Set the IsWardrobing__c field on tasks based on the textBody field value on 
     * related EmailMessage. 
     * This is done only for tasks resulting from an email.
     *@param
     * emailTaskMap: List of tasks and related emails
    **/
    public static void IsWardrobingTask(List<Task> taskList)  
    {
        List<Task> taskListToUpdate = new List<Task>();  
        for(Task t : taskList){
            system.debug('task: '+ t);
            t.IsWardrobing__c = true;
            taskListToUpdate.add(t);
        }
        if(taskListToUpdate.size() > 0){
            update taskListToUpdate;
        }
    }

    /**
     * Method for trigger Task_AfterUpdate 
     *  Creation of Notifications for Inbound Calls to send surveys after the call 
     * 
    */
    public static void createNotificationInboundCall(List<Task> newTaskList, Map<id, Task> oldTaskMap){
        Map<Id,Task> clientsId = new map<Id,Task>();
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Call').getRecordTypeId();
        Set<String> StoreCode = new Set<String>();
        Map<String,String> CountryCodeByStore = new map <String,String>();
        
        for (Task taskRecord: newTaskList) { 

            	//2023-04-04 : [JIRA Voice SV-109]
                if((String.isBlank(oldTaskMap.get(taskRecord.Id).Resolution__c) || String.isBlank(oldTaskMap.get(taskRecord.Id).AccountId))
                    && taskRecord.Resolution__c == 'Immediate Response' &&  taskRecord.CallType == 'Inbound'  &&  taskRecord.ClosedByIS__c == false 
                    && taskRecord.AccountId != null &&  taskRecord.recordTypeId == recordTypeId && taskRecord.ownerId == UserInfo.getUserId()){
                    
                    clientsId.put(taskRecord.AccountId, taskRecord);
                    /* if(String.isNotEmpty(taskRecord.Store_Code__c)){
                        StoreCode.add(taskRecord.Store_Code__c);
                    }*/
            }
        }
        /*if(!StoreCode.isEmpty()){

            for(Store__c store : [SELECT id, RetailStoreId__c,ISO3_Code__c FROM Store__c WHERE RetailStoreId__c in: StoreCode ]){
                CountryCodeByStore.put(store.RetailStoreId__c,store.ISO3_Code__c);
            }
        }*/

        if(!clientsId.isEmpty()){

            // BNG 2022-11-18 : [JIRA ICONICS NI-1789] 
            // Modify the post contact survey trigger to ignore call Task where Nature__c = 'complaints'
            for(String client_Id : clientsId.keySet()){
                Task taskRecordComp = clientsId.get(client_Id); 
                if(taskRecordComp.Nature__c != 'Complaints'){
                    //Check if the owner of the task send more than 3 per day
                    Integer notification = [SELECT count() FROM Notification__c WHERE ownerId =: UserInfo.getUserId() and Status__c = 'Closed' and createdDate=TODAY];
                    if(notification < 3){
                        try{
                            Map<String, Map<String,Object>> params = getDynamicParams(clientsId, CountryCodeByStore);
                            Notification_Sender.send(
                                new Map<String,Object> {
                                    'application' => 'POST CONTACT',
                                    'scenario' => 1,
                                    'channel' => 'EMAIL MARKETING CLOUD'
                                },
                                clientsId.keySet(), 
                                params
                            );
                        }
                        catch(Exception ex){
                            System.debug(ex.getMessage());
                            System.debug(ex.getStackTraceString());
                        }
                    }
                }
            }
        }   
    }

    public static Map<String, Map<String,Object>> getDynamicParams(Map<Id,Task> clientsId,Map<String,String> CountryCodeByStore){
        // CREATE PARAMS
        string CAName = '';
        List<User> user = [SELECT  Name, WWEmployeeNumber__c,RMS_ID__c, DefaultStore__c, UserRole.Name FROM user WHERE Id=:UserInfo.getUserId()];
        CAName = (user.get(0) != null ? user.get(0).Name+' ': '');
        CAName = (user.get(0) != null && user.get(0).RMS_ID__c != null? CAName +'('+ user.get(0).RMS_ID__c+')': CAName);
        CAName = (user.get(0) != null && user.get(0).WWEmployeeNumber__c != null? CAName +'('+ user.get(0).WWEmployeeNumber__c+')': CAName);
        Map<String, Map<String,Object>> params = new Map<String,Map<String,Object>>();

        for(String clientId : clientsId.keySet()){
            params.put(clientId, new Map<String,Object>());
            Task taskRecord = clientsId.get(clientId);
            params.get(clientId).put('FirstName',UserInfo.getFirstName());
            params.get(clientId).put('OwnerId',UserInfo.getUserId());
            params.get(clientId).put('what_id',taskRecord.id);
            params.get(clientId).put('CAName__c',CAName);
            params.get(clientId).put('Inbound_Contact_Date__c',System.today());
            //params.get(clientId).put('StoreCountryCode',CountryCodeByStore.get(taskRecord.Store_Code__c));

            params.get(clientId).put('Nature', taskRecord.Nature__C);
            params.get(clientId).put('Category', taskRecord.Category__c);
            
            String defaultStore = user.get(0) != null ? user.get(0).DefaultStore__c : '';
            params.get(clientId).put('default_store', defaultStore);
            String userRole = user.get(0) != null ? user.get(0).UserRole.Name : '';
            params.get(clientId).put('user_role', userRole);
            
            params.get(clientId).put('Country', taskRecord.Country__c);
            params.get(clientId).put('Country_code', taskRecord.ICX_Country__c); //(SV-256)
            
            String genesysQueue = taskRecord.Genesys_Queue__c;
            if(!String.isBlank(genesysQueue)){
                String[] genQueueList = genesysQueue.split('_');
            	String language = genQueueList[genQueueList.size() - 1];
            	params.get(clientId).put('Language', language); //(SV-276)
            }
            
        }
        return params;
    }


    //approbation process - naomi fev 2023
    public static void taskApprovalRejected(List<Task> newTask, Map<Id,Task> newTaskMap, Map<Id, Task> oldMap){
        Id approvalRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Approval').getRecordTypeId();    

        List<Task> taskApproval = new List<Task>();
       
        Set<Id> orderShippingToRejectPAId = new Set<Id>();
        Set<Id> orderShippingToRejectAtOrderLevel = new Set<Id>();
        Set<Id> orderToReject = new Set<Id>();


        for(Task currentTask : newTask)
        {
            if (currentTask.recordTypeId==approvalRTId && currentTask.Status=='Completed' && oldMap.get(currentTask.Id).Status!=currentTask.Status && currentTask.Priority=='High')
            {
                if(currentTask.Subject.contains('PRICE_ADJUSTMENT') || currentTask.Subject.contains('CLIENTELING_EXCEPTION'))
                {
                    orderShippingToRejectAtOrderLevel.add(currentTask.WhatId);
                }
                else{
                    orderToReject.add(currentTask.WhatId);
                }

                taskApproval.add(currentTask);
            }
        }
        
        if (orderShippingToRejectAtOrderLevel.size()>0) {
            List<OrderShipping__c> orderToRejectFromOrderShipping =[SELECT Id,Order__c 
                                                                        FROM OrderShipping__c 
                                                                        WHERE id IN:orderShippingToRejectAtOrderLevel];

            for(OrderShipping__c os: orderToRejectFromOrderShipping) {
                orderToReject.add(os.Order__c);
            }
        }
        
        if(orderShippingToRejectPAId.size()>0 || orderToReject.size()>0)
        {
            // TWIST-30762 : Johan Guinot
            TraceabilityService.insertFromTasks(taskApproval);  
            callKBRWForRejectedOrder(orderToReject,orderShippingToRejectPAId);
        }
   

    }

    //approbation process - naomi fev 2023
    public static void callKBRWForRejectedOrder(Set<Id> orderToReject, Set<Id> orderShippingToRejectPAId)
    {
        List<OrderLine__c> orderLine =[SELECT Id,OrderShipping__c,OrderShipping__r.ShippingNumber__c,SKU__c FROM OrderLine__c WHERE (Order__c IN:orderToReject OR OrderShipping__c IN:orderShippingToRejectPAId)];
        for(OrderLine__c currentOrderLine : orderLine)
        {
            sendActionKBRW(currentOrderLine.Id);
                    }
    }

          //approbation process - naomi fev 2023
          @future(callout=true)
          private static void sendActionKBRW(Id orderLineId)
          {
            //this soql is needed because we cannot send something other than an id in a future method
            OrderLine__c orderLine =[SELECT Id, order__r.orderNumber__c, OrderShipping__c,OrderShipping__r.ShippingNumber__c,SKU__c FROM OrderLine__c WHERE Id =:orderLineId LIMIT 1];
      
            Map<String,Object> bodyTosend  = new Map<String,Object> {
                        'id' => orderLine.OrderShipping__r.ShippingNumber__c.split('-')[0],
                        'requesting_system' => 'ICONiCS',
                        'item_id' => orderLine.SKU__c,
                        'line_number' => Integer.valueOF(orderLine.OrderShipping__r.ShippingNumber__c.split('-')[1]),
                        'action_message' =>  'rejected',
                        'action' => 'cancel_by_lv'
                    };
            WS_OrderAction.sendOrderDetails(bodyTosend,orderLine.OrderShipping__c,false);
            TraceabilityService.insertTraceability('cancel_by_lv', null, 'Automated - Approval reject', orderLine.order__r.orderNumber__c, orderLine.OrderShipping__r.ShippingNumber__c );
          }
}