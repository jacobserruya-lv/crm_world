/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-06-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-10-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version  
**/
public with sharing class ICON_Todos_Helper {

   

    public static final Integer NUMBER_COMPLETED_TASK = 5;
    public static final Id TaskTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('To_Do_Assistant').getRecordTypeId();
    private static boolean run = true;

    //===================================================//
    // Here go the handler methods
    public static boolean runOnce() {
        System.debug('runOnce=' + run);
        if (run) {
            run = false;
            return true;
        } 
        else {
            return run;
        }
    }
        
    public static void afterInsertCareService(List<CareService__c> newCareServiceList, Map<id, CareService__c> newCareServiceMap){
        List<Task>tasks = new List<Task>();
        Map<String,String> TechnicalUsers = getTechnicalUsers();
        List<String> subjectList = new list<String> {'quotation to validate' ,'extra delay','shipped to store but not repaired','product available in store'};  
             
        for(CareService__c careRecord : [SELECT id ,MyRepairStatus__c ,StoreRetailCode__c,Store__c , Store__r.ISO3_Code__c ,IsToDo__c, MessageToCA__c ,Tolabel(MessageToCA__c) labelMessage ,CA__c, Client__r.PersonContactId FROM CareService__c WHERE id IN:newCareServiceList]){
        
            String message = String.isNotBlank(careRecord.MessageToCA__c) ? careRecord.MessageToCA__c.trim().toLowercase() : '' ;
            if(careRecord.IsToDo__c && subjectList.contains(message)){    

                string toDoCode = ''; 
                switch on careRecord.MessageToCA__c {
                    when 'extra delay'  {
                        toDoCode = 'TD_CS_01';
                    }
                    when  'quotation to validate'  {
                        toDoCode = 'TD_CS_02';
                    }
                    when  'shipped to store but not repaired'  {
                        toDoCode = 'TD_CS_03';
                    }
                    when  'product available in store'  {
                        toDoCode = 'TD_CS_04';
                    }
                }
                
                String CountryIsoCode = careRecord.Store__r.ISO3_Code__c ;
                String assignment = String.isNotBlank(careRecord.CA__c) ? 'CA' :'Reassigned';
                Task tsk = new Task(
                    To_do_type__c = 'Care Service',
                    SourceType__c = 'ICON',
                    Status = 'New',
                    Subject = careRecord.MessageToCA__c,
                    WhatId =  careRecord.Id,
                    WhoId = careRecord.Client__r.PersonContactId,
                    Store_Location__c =  careRecord.Store__c, 
                    Assignment__c = assignment,             
                    OwnerId =  (assignment != 'Reassigned' ? careRecord.CA__c: (TechnicalUsers.Containskey(CountryIsoCode) ? TechnicalUsers.get(CountryIsoCode) : TechnicalUsers.get('Other'))),
                    RecordTypeId = TaskTypeId,
                    Todo_Code__c = todoCode
                );
                tasks.add(tsk);
            }  
        }
        Database.insert(tasks ,false);
    }
    
    public static void afterUpdateCareService(List<CareService__c> newCareServiceList, Map<id, CareService__c> newCareServiceMap,List<CareService__c> oldCareServiceList, Map<id, CareService__c> oldCareServiceMap) {
        List<Task>tasks = new List<Task>();
        List<String> subjectList = new list<String> {'quotation to validate' ,'extra delay','shipped to store but not repaired','product available in store'};  
      
        Map<String,String> TechnicalUsers = getTechnicalUsers();
        
        if(runOnce()){
        
            for(CareService__c careRecord : [SELECT id ,MyRepairStatus__c ,StoreRetailCode__c,IsToDo__c, Store__c,Store__r.ISO3_Code__c ,  MessageToCA__c ,Tolabel(MessageToCA__c) labelMessage ,CA__c,CA_Code__c, Client__c ,Client__r.PersonContactId FROM CareService__c WHERE id IN:newCareServiceList]){
                
                String message = String.isNotBlank(careRecord.MessageToCA__c) ? careRecord.MessageToCA__c.trim().toLowercase() : '' ;

                if((careRecord.IsToDo__c  && !(oldCareServiceMap.get(careRecord.Id).IsToDo__c) && subjectList.contains(message)) 
                    || ((careRecord.IsToDo__c  && careRecord.MessageToCA__c != oldCareServiceMap.get(careRecord.Id).MessageToCA__c) && (subjectList.contains(message)))
                    || (careRecord.IsToDo__c && careRecord.CA__c != oldCareServiceMap.get(careRecord.Id).CA__c &&  subjectList.contains(message) )){    
                        
                        string toDoCode = ''; 
                switch on careRecord.MessageToCA__c {
                    when 'extra delay'  {
                        toDoCode = 'TD_CS_01';
                    }
                    when  'quotation to validate'  {
                        toDoCode = 'TD_CS_02';
                    }
                    when  'shipped to store but not repaired'  {
                        toDoCode = 'TD_CS_03';
                    }
                    when  'product available in store'  {
                        toDoCode = 'TD_CS_04';
                    }
                }
                        
                        String CountryIsoCode = careRecord.Store__r.ISO3_Code__c ;
                        String assignment = String.isNotBlank(careRecord.CA__c) ? 'CA' :'Reassigned';
                        Task tsk = new task(
                            To_do_type__c = 'Care Service',
                            SourceType__c ='ICON',
                            Status = 'New',
                            Subject = careRecord.MessageToCA__c,
                            WhatId = careRecord.Id,
                            WhoId = careRecord.Client__r.PersonContactId,
                            Store_Location__c = careRecord.Store__c, 
                            Assignment__c = assignment,                 
                            OwnerId = (assignment != 'Reassigned' ? careRecord.CA__c: (TechnicalUsers.Containskey(CountryIsoCode) ? TechnicalUsers.get(CountryIsoCode) : TechnicalUsers.get('Other'))),
                            RecordTypeId =TaskTypeId,
                            Todo_Code__c = todoCode
                    );
                    tasks.add(tsk);
                }
            }    
            Database.insert(tasks ,false);
        }
    }
    
    public static void afterInsertCase(List<Case> newCaseList, Map<Id, Case> newCaseMap) { 
        List<Task>tasks = new List<Task>();
        Map<String,String> TechnicalUsers = getTechnicalUsers();
        
        for(Case caseRecord : [SELECT Id ,Subject,Account.PersonContactId,AccountId,Store__c, Store__r.RetailStoreId__c ,Store__r.ISO3_Code__c ,CA_Name__c,Resolution__c,IsClosed FROM Case WHERE Id IN:newCaseList]){  
            if(caseRecord.Resolution__c == 'Request to Store' && !caseRecord.IsClosed){  
                String CountryIsoCode = caseRecord.Store__r.ISO3_Code__c ;
                String assignment = String.isNotBlank(caseRecord.CA_Name__c) ? 'CA' :'Reassigned';
                Task tsk = new Task(
                    To_do_type__c = 'Request',
                    SourceType__c = 'ICON',
                    Status = 'New',
                    Subject = caseRecord.Subject,
                    WhatId = caseRecord.Id,
                    WhoId = caseRecord.Account.PersonContactId,
                    Store_Location__c = caseRecord.Store__c,          
                    Assignment__c = assignment,       
                    OwnerId = (assignment != 'Reassigned' ? caseRecord.CA_Name__c: (TechnicalUsers.Containskey(CountryIsoCode) ? TechnicalUsers.get(CountryIsoCode) : TechnicalUsers.get('Other'))),   
                    RecordTypeId = TaskTypeId,
                    Todo_Code__c = 'TD_REQUEST'
                );

                tasks.add(tsk);
            }  
        }
        Database.insert(tasks ,false);
    }
    
    public static void afterUpdateCase(List<Case> newCaseList, Map<id, case> newCaseMap, List<Case> oldCaseList, Map<id, case> oldCaseMap){
        List<Task>tasks = new List<Task>();
        Map<String,String> TechnicalUsers = getTechnicalUsers();
       
        if(runOnce()){

        
            for(Case caseRecord : [SELECT Id ,Subject,AccountId,Account.PersonContactId,Store__c,Store__r.RetailStoreId__c, Store__r.ISO3_Code__c,CA_Name__c,Resolution__c,IsClosed FROM Case WHERE Id IN:newCaseList]){  
                    if((caseRecord.Resolution__c == 'Request to Store' && !caseRecord.IsClosed && caseRecord.Resolution__c!= oldCaseMap.get(caseRecord.Id).Resolution__c)
                ||(caseRecord.Resolution__c == 'Request to Store' && !caseRecord.IsClosed && caseRecord.CA_Name__c!= oldCaseMap.get(caseRecord.Id).CA_Name__c)){

                        String CountryIsoCode =  caseRecord.Store__r.ISO3_Code__c ;
                        String assignment = String.isNotBlank(caseRecord.CA_Name__c) ? 'CA' :'Reassigned';
                        Task tsk = new Task(
                            To_do_type__c ='Request',
                            SourceType__c ='ICON',
                            Status ='New',
                            Subject = caseRecord.Subject,
                            WhatId = caseRecord.Id,
                            WhoId = caseRecord.Account.PersonContactId,
                            Store_Location__c = caseRecord.Store__c,          
                            Assignment__c = assignment,      
                            OwnerId = (assignment != 'Reassigned' ? caseRecord.CA_Name__c: (TechnicalUsers.Containskey(CountryIsoCode) ? TechnicalUsers.get(CountryIsoCode) : TechnicalUsers.get('Other'))),         
                            RecordTypeId = TaskTypeId,
                            Todo_Code__c = 'TD_REQUEST'
                    );
                    tasks.add(tsk);
                }  
            }
        Database.insert(tasks ,false);
        }

    }

    public static void afterUpdateVO_Survey(List<VO_Survey__c> newVOSurveyList, Map<id, VO_Survey__c> newVOSurveyMap, List<VO_Survey__c> oldVOSurveyList, Map<id, VO_Survey__c> oldVOSurveyMap) {
        List<String> listUserIds = new List<String>();  
        List<String> listVoiceType = new List<String>{'VOICE Store Local Sales','VOICE Store After Sales', 'VOICE CSC Click And Collect', 'VOICE CSC Sales'};          
        
        List<Task> tasks = new List<Task>();
        Map<String,String> TechnicalUsers = getTechnicalUsers();
        Map<String,String> userIDS =  new Map<String,String> ();
        if(runOnce()){ 

            for(VO_Survey__c voRecord : newVOSurveyList){

                if (String.IsNotEmpty(voRecord.CAName__c) && listVoiceType.contains(voRecord.SurveyType__c)){
                    
                    listUserIds.add(voRecord.CAName__c);
                }
            }

            Set<String> WWEmployeeNumbers = getWWemployeeID(listUserIds);
            for(User usr :[SELECT Id ,Name,RMS_ID__c, WWEmployeeNumber__c  FROM User WHERE  WWEmployeeNumber__c IN:WWEmployeeNumbers]){

                userIDS.put(usr.WWEmployeeNumber__c ,usr.Id);
            }


            for(VO_Survey__c voRecord : [SELECT Name,id ,StoreID__c ,Store__c ,Store__r.ISO3_Code__c , SurveyType__c ,CAName__c,OwnerId,ClientDreamID__c,ClientDreamID__r.PersonContactId,Type__c,TECH_CAIds__c,Status__c FROM VO_Survey__c WHERE id IN:newVOSurveyList]){ 
                
                String userId = '' ; 
                if( string.isNotBlank(voRecord.Type__c)  && oldVOSurveyMap.get(voRecord.Id).Type__c != voRecord.Type__c && listVoiceType.contains(voRecord.SurveyType__c)){ 
                    
                   if (String.IsNotEmpty(voRecord.CAName__c)){

                        Pattern patternInBrackets = Pattern.compile('\\((.*?)\\)');
                        Matcher summaryQueryMatcher = patternInBrackets.matcher(voRecord.CAName__c);
                        while(summaryQueryMatcher.find()) { 
                            if(userIDS.containskey(summaryQueryMatcher.group(1))) {
                                
                                userId = userIDS.get(summaryQueryMatcher.group(1));
                            }
                        }
                    }
                    //List<String> usersIds = String.isnotBlank(voRecord.TECH_CAIds__c) ?  voRecord.TECH_CAIds__c.split(';') : new List<String>();
                    //userId = !usersIds.isEmpty() && usersIds.size() > 0 ? usersIds.get(0) :  '' ;
                    String CountryIsoCode = voRecord.Store__r.ISO3_Code__c ;
                    String assignment = (voRecord.Type__c == 'Recovery Act' || String.isBlank(userId) )? 'Manager' :  'CA' ;

                    Task tsk = new Task(
                        To_do_type__c = 'Voice',
                        SourceType__c = 'ICON',
                        Status = 'New',
                        Subject = voRecord.Name + ' ' + voRecord.Type__c,
                        WhatId = voRecord.Id,
                        WhoId = voRecord.ClientDreamID__r.PersonContactId,
                        Store_Location__c = voRecord.Store__c, 
                        Assignment__c = assignment,                     
                        OwnerId = (assignment != 'CA'  ? (TechnicalUsers.Containskey(CountryIsoCode) ? TechnicalUsers.get(CountryIsoCode) : TechnicalUsers.get('Other')) : userId),
                        RecordTypeId =TaskTypeId,
                        Todo_Code__c = 'TD_VOICE'
                    );

                    tasks.add(tsk);
                }
           
                Database.insert(tasks ,false);
            }
        }
    }

    public static void afterUpdateFirmOrderNowYours(List<SPO_FirmOrder__c> newOrderList, Map<id, SPO_FirmOrder__c> newOrderMap, List<SPO_FirmOrder__c> oldOrderList, Map<id, SPO_FirmOrder__c> oldOrderMap){
        List<Task> tasks = new List<Task>();
        Map<String,String> TechnicalUsers = getTechnicalUsers();


        for(SPO_FirmOrder__c orderRecord : [SELECT SPO_FirmOrderStatus__c ,Id , SPO_BriefName__r.Owner.Is_Store_User__c  ,SPO_BriefName__r.SPO_Store__r.ISO3_Code__c,SPO_BriefName__r.Owner.IsTechnicalUser__c ,SPO_RevisedDeliveryDate__c  ,Planned_Delivery_date__c ,SPO_BriefName__c, SPO_BriefName__r.ApplicationSource__c, SPO_BriefName__r.OwnerId,SPO_BriefName__r.SPO_Store__c, SPO_BriefName__r.Account.PersonContactId 
                                       FROM SPO_FirmOrder__c WHERE Id In: newOrderList ]){  
                
            if( orderRecord.Planned_Delivery_date__c != oldOrderMap.get(orderRecord.Id).Planned_Delivery_date__c
            && orderRecord.SPO_RevisedDeliveryDate__c > orderRecord.Planned_Delivery_date__c 
            && orderRecord.SPO_BriefName__r.ApplicationSource__c == 'PERSO'){
                
                tasks.add(createToDoTaskFirmOrderNowYours(orderRecord , TechnicalUsers , 'Delay On Order' ,'TD_NY_03'));
            }

            if(orderRecord.SPO_FirmOrderStatus__c != oldOrderMap.get(orderRecord.Id).SPO_FirmOrderStatus__c  && 
            ((orderRecord.SPO_FirmOrderStatus__c  == 'Cancelled by Production' &&  orderRecord.SPO_BriefName__r.ApplicationSource__c == 'PERSO') || 
            (orderRecord.SPO_FirmOrderStatus__c  == 'Quotation submitted' &&  orderRecord.SPO_BriefName__r.ApplicationSource__c == 'SPO') || orderRecord.SPO_FirmOrderStatus__c == 'Received in store')){

                string toDoCode = ''; 
                switch on orderRecord.SPO_FirmOrderStatus__c {
                    when 'Quotation submitted'  {
                        toDoCode = 'TD_NY_02';
                    }
                    when  'Cancelled by Production'  {
                        toDoCode = 'TD_NY_01';
                    }
                    when  'Received in store'  {
                        toDoCode = 'TD_NY_04';
                    }
                }

                
                tasks.add(createToDoTaskFirmOrderNowYours(orderRecord ,TechnicalUsers , orderRecord.SPO_FirmOrderStatus__c == 'Received in store' ? 'product available in store' : orderRecord.SPO_FirmOrderStatus__c,toDoCode));
            }
        }
        
       Database.insert(tasks ,false);
    }

    


    public static void afterUpdateOrderXstore(List<Order__c> newOrderList, Map<id, Order__c> newOrderMap, List<Order__c> oldOrderList, Map<id, Order__c> oldOrderMap){
        List<Task> tasks = new List<Task>();
        Map<String,String> TechnicalUsers = getTechnicalUsers();

        for(Order__c orderRecord : [SELECT id ,Account__r.PersonContactId  ,Store__c  ,OwnerId__c , Store__r.ISO3_Code__c  FROM Order__c WHERE Id In: newOrderList ]){  
                
            if( orderRecord.OwnerId__c != oldOrderMap.get(orderRecord.Id).OwnerId__c){
                
                tasks.add(createToDoTaskOrderXstore(orderRecord , TechnicalUsers , 'Order has been reassigned to you', 'TD_XSTO_04'));
            }
        }
        
       Database.insert(tasks ,false);
    }

    public static Set<String> getWWemployeeID(List<String> caNames){

        Set<String> employeeId = new Set<String>();
        Pattern patternInBrackets = Pattern.compile('\\((.*?)\\)');
        for(String caName : caNames){
            Matcher summaryQueryMatcher = patternInBrackets.matcher(caName);
            while(summaryQueryMatcher.find()) { 
                employeeId.add(summaryQueryMatcher.group(1));
            }
        }
       return employeeId ;
    }
    // return a map with the technical users 
    public static Map<String,String> getTechnicalUsers() {  
       Map<String,String> techUsersMap = new Map<String,String> ();
       for(World_Wide_Technical_User__mdt tu : [SELECT User_Id__c ,Country_Iso3Code__c , Country__c FROM World_Wide_Technical_User__mdt] ){
          if(String.isnotblank(tu.Country_Iso3Code__c)){
              for(String isocode : tu.Country_Iso3Code__c.split(';')){
                techUsersMap.put(isocode ,tu.User_Id__c);
              }
          }else{
                techUsersMap.put('Other' ,tu.User_Id__c);
          }
        }
        return techUsersMap;
    }
    

    public static Task createToDoTaskFirmOrderNowYours(SPO_FirmOrder__c order ,  Map<String,String> TechnicalUsers , String subject, String todoCode ){


        String assignment = order.SPO_BriefName__r.Owner.Is_Store_User__c || order.SPO_BriefName__r.Owner.IsTechnicalUser__c ? 'Reassigned' :'CA';
        String CountryIsoCode = order.SPO_BriefName__r.SPO_Store__r.ISO3_Code__c ;

        return new Task(
            To_do_type__c = 'NY Order',
            SourceType__c = 'ICON',
            Status = 'New',
            Subject = subject,
            WhatId =  order.SPO_BriefName__c,
            WhoId = order.SPO_BriefName__r.Account.PersonContactId,
            Store_Location__c =  order.SPO_BriefName__r.SPO_Store__c, 
            Assignment__c = assignment,
            OwnerId = (assignment != 'Reassigned' ? order.SPO_BriefName__r.OwnerId : (TechnicalUsers.Containskey(CountryIsoCode) ? TechnicalUsers.get(CountryIsoCode) : TechnicalUsers.get('Other'))),     
            RecordTypeId = TaskTypeId,
            Todo_Code__c = todoCode
         );
    }

    public static Task createToDoTaskXstore(OrderShipping__c order , Map<String,String> TechnicalUsers , String subject, String todoCode ){

        String assignment = String.isNotBlank(order.Order__r.OwnerId__c) ? 'CA' :'Reassigned';
        String CountryIsoCode = order.Order__r.Store__r.ISO3_Code__c ;

        return new Task(
            To_do_type__c = 'Xstore Order',
            SourceType__c = 'ICON',
            Status = 'New',
            Subject = subject,
            WhatId =  order.Order__c,
            WhoId = order.Order__r.Account__r.PersonContactId,
            Store_Location__c =  order.Order__r.Store__c, 
            Assignment__c = assignment,
            OwnerId = (assignment != 'Reassigned' ? order.Order__r.OwnerId__c : (TechnicalUsers.Containskey(CountryIsoCode) ? TechnicalUsers.get(CountryIsoCode) : TechnicalUsers.get('Other'))),         
            RecordTypeId = TaskTypeId,
            Todo_Code__c = todoCode
         );
    }

    public static Task createToDoTaskOrderXstore(Order__c order , Map<String,String> TechnicalUsers , String subject, String todoCode ){

        String assignment = String.isNotBlank(order.OwnerId__c) ? 'CA' :'Reassigned';
        String CountryIsoCode = order.Store__r.ISO3_Code__c ;

        return new Task(
            To_do_type__c = 'Xstore Order',
            SourceType__c = 'ICON',
            Status = 'New',
            Subject = subject,
            WhatId =  order.Id,
            WhoId = order.Account__r.PersonContactId,
            Store_Location__c =  order.Store__c, 
            Assignment__c = assignment,
            OwnerId = (assignment != 'Reassigned' ? order.OwnerId__c : (TechnicalUsers.Containskey(CountryIsoCode) ? TechnicalUsers.get(CountryIsoCode) : TechnicalUsers.get('Other'))),         
            RecordTypeId = TaskTypeId,
            Todo_Code__c = todoCode
         );
    }
    
    public static Task createToDoTaskCareServiceInProgress(CareService__c careService ,  Map<String,String> TechnicalUsers , String subject, String todoCode ){
             
        String CountryIsoCode = careService.Store__r.ISO3_Code__c ;
        String assignment = String.isNotBlank(careService.CA__c) ? 'CA' :'Reassigned';
        Task tsk = new Task(
            To_do_type__c = 'Care Service',
            SourceType__c = 'ICON',
            Status = 'New',
            Subject = subject,
            WhatId =  careService.Id,
            WhoId = careService.Client__r.PersonContactId,
            Store_Location__c =  careService.Store__c, 
            Assignment__c = assignment,             
            OwnerId =  (assignment != 'Reassigned' ? careService.CA__c: (TechnicalUsers.Containskey(CountryIsoCode) ? TechnicalUsers.get(CountryIsoCode) : TechnicalUsers.get('Other'))),
            RecordTypeId = TaskTypeId,
            CareServiceRepairInProgressFlag__c = true,
            Todo_Code__c = todoCode
        );
    
        return tsk;
    }

    
}