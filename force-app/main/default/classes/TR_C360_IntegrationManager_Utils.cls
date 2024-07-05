/***************************************************************************************************
* @File Name          : TR_C360_IntegrationManager_Utils.cls
* @Description        : This class was created for the C360 project To manage all flux 
* @Author             : Imad.alsidchikh.ext@louisvuitton.com
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh.ext@louisvuitton.com
* @Last Modified On   : 02-22-2022
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       02-22-2022        Imad.alsidchikh.ext@louisvuitton.com     Initial Version
* 1.1       06-19-2023        hamza.bouzid.ext@louisvuitton.com Dynamic insert of json in log
* 1.2       11-13-2023        yann.aquilon.ext@louisvuitton.com take care of Null value from JSon
*****************************************************************************************************/
public without sharing class TR_C360_IntegrationManager_Utils {
    
    
    public static Map<String,List<Social_Media_Identifier__c>> smiRecordMap;
    public static Map<String, Contact> contRecordMap;
    
    public static void initSendMethod(Set<Id> accIds,Set<Id> timIds){
        if(System.IsBatch() == false && System.isFuture() == false){ 
            callSendMethodAs(accIds, timIds);
        }else{
            callSendMethodS(accIds,timIds);  
        }
    }
    @future
    public static void callSendMethodAs(Set<Id> accIds,Set<Id> timIds){
        sendChangeToClient360(accIds,timIds);   
    }
    public static void callSendMethodS(Set<Id> accIds,Set<Id> timIds){
        sendChangeToClient360(accIds,timIds);
    }
    public static void sendChangeToClient360(Set<Id> accIds,Set<Id> timIds){
        List<TECH_IntegrationManager__c> integManags = getTechManagerRecords(timIds);
        List<C360_Tech_Event__e> inkEvents = new List<C360_Tech_Event__e>();
        Map<String,Account> accts = new Map<String,Account>();
        Map<String, User> usersIdentityMap =new Map<String, User>();
        Map<String,TECH_IntegrationManager__c> intMan = new Map<String,TECH_IntegrationManager__c>();
        //INIT data from c360 event
        try{
            TR_C360_Utils.setSalutationVal();
            TR_C360_Utils.setCountryVal();
            TR_C360_Utils.setTitleVal();
            TR_C360_Utils.setPreLangVal();
            TR_C360_Utils.setDefaultStoreVal();
            TR_C360_Utils.setStoreCodeVal();
            
            accts = getAccountRecords(accIds);
            usersIdentityMap = getUsersIdentityMap(accIds);
            User currentUserRecords = TR_C360_Utils.getCurrentUserInfos();
            if(integManags != null){
                for(TECH_IntegrationManager__c TIM : integManags){
                    List<Account> accs = (List<Account>) getRecordsFromMap(accts,TIM.AccountId__c,TIM.Object_Name__c);
                    List<Social_Media_Identifier__c> smis =(List<Social_Media_Identifier__c>) getRecordsFromMaps(smiRecordMap,TIM.AccountId__c,TIM.Object_Name__c);
                    List<User> usIdentity =(List<User>) getRecordsFromMap(usersIdentityMap,TIM.AccountId__c,'User');
                    String bodyJson = TR_JSON_Generator.generateJSONContent(accs[0],usIdentity,smis,TIM,currentUserRecords);
                    inkEvents.add(new C360_Tech_Event__e(Body_Json__c=bodyJson,TR_Object_Id__c=TIM.Object_Id__c,TR_Object_Name__c=TIM.Object_Name__c,Tech_Integration_Id__c=TIM.Id));
                    intMan.put(TIM.Id, TIM);
                }
                // Call method to publish events
                List<Database.SaveResult> results = EventBus.publish(inkEvents);
                //System.debug('INSERT' + results);
            }
        }catch(Exception e) {
            Map<String, String> logParams = new Map<String, String>{
                'apex_class'=>'TR_C360_IntegrationManager_Utils',
                    'apex_Limits' => TR_C360_IntegrationManager_Utils.getCurrentOrgLimits(),
                    'application'=>TR_Constants.APPEVENT,
                    'duration'=>'',
                    'eventUuidLog'=>'',
                    'json'=> String.valueOf(inkEvents),
                    'logLevel'=>'ERROR',
                    'logMessage'=>'',
                    'hasError'=>'true',
                    'error_Message'=>e.getStackTraceString() + '\n\n' + e.getMessage() + '\n\nlineNumber:' + e.getLineNumber(),
                    'Object_Type'=>'Account',
                    'record_Id'=>'',
                    'logType'=>'Outgoing_flow'};
                        database.insert(TR_C360_Utils.CreateLog(logParams));
        }
    }
    public static void setAccountEventBus(C360_Tech_Event_Return_Flow__e evt ,DateTime startTime){
        List<Account> acctManagsById = new List<Account>();
        List<Account> acctManagsByDREAMID = new List<Account>();
        TR_Integration_Manager_Setting__c getLogSetup =TR_Constants.getLogSetup;
        World_Wide_Technical_User__mdt worldwideTechnicalUser = [select DeveloperName ,country__c, user_id__c from World_Wide_Technical_User__mdt where DeveloperName ='World_Wide_TU'  limit 1 ];
        String wwUserId = worldwideTechnicalUser.user_id__c;                
        List<C360_Logs__c> logs = new List<C360_Logs__c>();
        C360_Logs__c log = new C360_Logs__c();
        List<Database.UpsertResult> results1;
        try{
            List<TR_C360_Field_Mapping__mdt > mappingRds = TR_Constants.mappingRds;
            TR_Integration_Manager_Setting__c getClientSetup =TR_Constants.getClientSetup;
            String automatedprocessid = getClientSetup.Excluded_UserId__c;
            TR_C360_Wrapper cwp = new TR_C360_Wrapper();
            if(evt != null && String.isNotBlank(evt.Body_Json__c)){
                TR_C360_Wrapper obj = TR_C360_Wrapper.parse(evt.Body_Json__c);
                String DreamID = (obj.dreamId!=null?obj.dreamId:null);
                String SalesforceID = (obj.salesforceId!= null?obj.salesforceId:null);
                Map<String, String> logParams = new Map<String, String>{
                    'apex_class'=>'TR_C360_IntegrationManager_Utils',
                        'application'=>'C360',
                        'duration'=>String.valueOf((system.now().getTime() - startTime.getTime()) / 1000),
                        'eventUuidLog'=>evt.EventUuid,
                        'json'=> evt.Body_Json__c,
                        'logLevel'=>'DEBUG',
                        'logMessage'=>'',
                        'hasError'=>'false',
                        'error_Message'=>'',
                        'Object_Type'=>'C360_Tech_Event_Return_Flow__e',
                        'record_Id'=>evt.ReplayId,
                        'logType'=>'Incoming_flow', 
                        'DreamID'=> DreamID,
                        'SalesforceID' => SalesforceID};
                            log = TR_C360_Utils.CreateLog(logParams);
                //TR_C360_Wrapper obj = TR_C360_Wrapper.parse(evt.Body_Json__c);
                Map<String, Object> mObjct = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                 
                String stAcc = '{';
                for(TR_C360_Field_Mapping__mdt st :mappingRds){
                    if(mObjct.containskey(st.C360_Field__c) && st.Is_From_C360__c){
                        system.debug('### YAAAA  YAAA ' + st.C360_Field__c );
                        if (st.C360_Field__c == 'nationality_code') System.debug(' ## YAA ' + mObjct.get(st.C360_Field__c));
                        if(st.C360_Field__c != 'salesforceId'){
                            
                            if (mObjct.get(st.C360_Field__c) != null ){
                                 stAcc += '"'+st.SF_Field__c+'"'+':'+'"'+mObjct.get(st.C360_Field__c)+'"'+',';
                            }else {if (st.C360_Field__c != 'birthDate'){
                                stAcc += '"'+st.SF_Field__c+'"'+':'+'""'+',';
                            }
                                 
                            }
                        }else if(st.C360_Field__c == 'salesforceId'  && String.IsNotBlank(String.valueOf(mObjct.get(st.C360_Field__c)))){
                            stAcc += '"'+st.SF_Field__c+'"'+':'+'"'+mObjct.get(st.C360_Field__c)+'"'+',';   
                                                        
                        }
                    }
                }
                stAcc = stAcc.removeEnd(',')+'}';
                Account acc = (Account)JSON.deserialize(stAcc, Account.class); 
                if(String.isNotBlank(acc.SPO_Country_code__pc) && String.isBlank(acc.PrimaryCountry__pc)){
                    acc.PrimaryCountry__pc =  TR_C360_Utils.getCountry(acc.SPO_Country_code__pc);
                }
                // Update account according Dream Id                             
                                      
                if(acc.DREAMID__c != null && String.isNotBlank(acc.DREAMID__c) && String.isBlank(acc.Id)){
                    List<Account> accountOwners = [SELECT Id , ownerId from Account where DreamId__c =: acc.DREAMID__c LIMIT 1];
                    String accountOwner;
                    if(accountOwners.size()> 0){
                        accountOwner= accountOwners[0].ownerId;
                    }
                    if(wwUserId != null && (String.IsBlank(accountOwner) || accountOwner ==automatedprocessid)){
                        acc.OwnerId =  wwUserId; 
                    }
                    acc.RecordTypeId =(getClientSetup.Client_default_RecordType__c != null ? getClientSetup.Client_default_RecordType__c : TR_Constants.recordTypeClient);
                    acctManagsByDREAMID.add(acc); 
                }
                else {
                    String accountId = acc.Id;
                    // Update account according Salesforce Id
                    if(String.isNotBlank(accountId) && accountId !='null'){
                        acc.Id = accountId;
                    }
                    // Create Client
                    else {
                        // integrer ici le owner
                        if(wwUserId != null){   
                            acc.OwnerId =  wwUserId; 
                        }
                        acc.RecordTypeId =(getClientSetup.Client_default_RecordType__c != null ? getClientSetup.Client_default_RecordType__c : TR_Constants.recordTypeClient);
                        acc.Source__c = String.valueOf(mObjct.get('touchApplicationCode'));
                    }
                    acctManagsById.add(acc);
                }
            }
            if(logs.Size()>0){
                Database.insert(logs);
            }
            if(acctManagsById.Size()> 0){
                results1 = Database.upsert(acctManagsById);
            }
            if(acctManagsByDREAMID.Size()> 0){
                results1 = Database.upsert(acctManagsByDREAMID, Account.Fields.DREAMID__c);
            }
        }catch(Exception ex) {
            string errorStr = ex.getStackTraceString() + '\n\n' + ex.getMessage() + '\n\nlineNumber:' + ex.getLineNumber();
            log.TR_Has_Error__c = true;
            log.TR_Error__c = errorStr;
            log.TR_Level__c = 'ERROR';
        }
        if  (log.TR_Level__c != 'ERROR' && (getLogSetup != null && !getLogSetup.Json_Added__c)){
            log.TR_JSON__c = null;
        }
        
        log.TR_APEX_Limits__c = TR_C360_IntegrationManager_Utils.getCurrentOrgLimits();
        database.insert(log);
    }
    public static  Map<String, account> getAccountRecords(Set<Id> accountIds){
        List<Account> accountRecords = new List<Account>();
        Map<String, Account> acctRecordMap = new Map<String,Account>();
        smiRecordMap = new Map<String,List<Social_Media_Identifier__c>>();
        contRecordMap = new Map<String, Contact>();
        if(accountIds.size()>0){
            String query = 'SELECT ' + TR_Constants.getClientFields() + '(select '+ TR_Constants.getSocialFields() +' from Social_Media_Identifiers__r),(SELECT Name , tolabel(Title__c) from Contacts) from Account where Id IN : accountIds';
            accountRecords =  Database.query(query);
            If(accountRecords.size()>0){
                for(Account acct : accountRecords){
                    acctRecordMap.put(acct.Id, acct);
                    contRecordMap.put(acct.Id,acct.Contacts[0]);
                    if(acct.Social_Media_Identifiers__r!=null && !acct.Social_Media_Identifiers__r.isEmpty()){
                        smiRecordMap.put(acct.Id,acct.Social_Media_Identifiers__r);  
                    }  
                }
                if(acctRecordMap != null){
                    return acctRecordMap;
                }
            }
        }
        return Null;
    }
    public static List<TECH_IntegrationManager__c> getTechManagerRecords(Set<Id> techManagerIds){
        List<TECH_IntegrationManager__c> integManags = new List<TECH_IntegrationManager__c>();
        if(techManagerIds.size()>0){
            integManags = [SELECT Id, Object_Name__c, Object_Id__c,Operation__c,Trigger_Event__c,AccountId__c,CreatedDate from TECH_IntegrationManager__c where Id IN : techManagerIds];
        }
        If(integManags.size()>0){
            return integManags;
        }
        return Null;
    }
    public static Map<String,User> getUsersIdentityMap(Set<Id> accountIds){
        List<User> idenUsers = new List<User>();
        Map<String, User> usersIdentityMap = new Map<String,User>();
        if(accountIds.size()>0){
            idenUsers = [SELECT Id,UserName,TimeZoneSidKey,Name,AccountId,Email,CreatedDate,LastLoginDate  FROM User where AccountId IN : accountIds];
        }
        If(idenUsers.size()>0){
            for(User us : idenUsers){
                usersIdentityMap.put(us.accountId, us);
            }
            if(usersIdentityMap != null){
                return usersIdentityMap;
            }
        }
        return new Map<String,User>();
    }
    public static List<sObject> getRecordsFromMap(Map<String,sObject> sObj, String accId,String objName){
        List<sObject> records = new List<sObject>();
        if(!sObj.isEmpty()){
            records.add(sObj.get(accId));  
        }
        return records;
    }
    public static List<Sobject> getRecordsFromMaps(Map<String,List<sObject>> sObj, String accId,String objName){
        List<sObject> records = new List<sObject>();   
        if(!sObj.isEmpty()){
            records= sObj.get(accId);  
        }
        return records;
    }
    public static string getCurrentOrgLimits(){
        string limits = '****CURRENT LIMITS****\n' +
            'Maximum CPU time: ' + Limits.getCpuTime()+ ' out of ' + Limits.getLimitCpuTime() + '\n' +
            'Number of future calls: : ' + Limits.getFutureCalls()+ ' out of ' + Limits.getLimitFutureCalls() + '\n' +
            'Aggregate queries : ' + Limits.getAggregateQueries() + ' out of ' + Limits.getLimitAggregateQueries()+ '\n' +
            'Number of DML rows:  ' + Limits.getDMLRows() + ' out of ' + Limits.getLimitDMLRows()+ '\n' +
            'Number of DML statements ' + Limits.getDMLStatements() + ' out of ' + Limits.getLimitDMLStatements() + '\n' +
            'Number of SOQL queries: ' + Limits.getQueries() + ' out of ' + Limits.getLimitQueries() + '\n' +
            'Number of query rows: ' + Limits.getQueryRows() + ' out of ' + Limits.getLimitQueryRows() + '\n' +
            'Number of SOSL queries: ' + Limits.getSoslQueries() + ' out of ' + Limits.getLimitSoslQueries() + '\n' +
            'Maximum heap size: ' + Limits.getHeapSize() + ' out of ' + Limits.getLimitHeapSize() + '\n' +
            'Maximum Async Calls: ' + Limits.getAsyncCalls() + ' out of ' + Limits.getLimitAsyncCalls() + '\n' +
            'Maximum Publish DML(EventBus): ' + Limits.getPublishImmediateDML() + ' out of ' + Limits.getLimitPublishImmediateDML() + '\n' +
            'Number of Mobile Apex push calls:  ' + Limits.getMobilePushApexCalls() + ' out of ' + Limits.getLimitMobilePushApexCalls() + '\n';        
        return limits;
    }
    
}