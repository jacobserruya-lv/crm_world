/**
 * @description       :  
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-03-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-10-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class BL_ICON_KPI_Helper {
    static String OnlineAppointmentRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
    static String EventAppointmentRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Event_Appointment').getRecordTypeId();
    static String AvailabilityRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Availability').getRecordTypeId();
    static String AppointmentsRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Appointments').getRecordTypeId();
    static String GoldenAppointmentsRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Golden').getRecordTypeId();



    static List<String> ListOfAppointmentRecordTypesId= new list<String>{
		'\''+ OnlineAppointmentRecordTypeId +'\'',
        '\''+AppointmentsRecordTypeId+'\'' ,
        '\''+GoldenAppointmentsRecordTypeId+'\'' ,
        '\''+EventAppointmentRecordTypeId+'\'' 
		};

    static List<String> ListOfTaskRecordTypesId= new list<String>{
		'\''+Schema.SObjectType.Task.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CSC_Call').getRecordTypeId() +'\'',
		'\''+Schema.SObjectType.Task.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CSC_Email').getRecordTypeId()+'\'' ,
		'\''+Schema.SObjectType.Task.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('ICONICS_Clienteling').getRecordTypeId()+'\'',
        '\''+Schema.SObjectType.Task.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('ICONiCS_Messaging').getRecordTypeId() +'\'',
		'\''+Schema.SObjectType.Task.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('ICONICS_Chat').getRecordTypeId()+'\'' ,
		'\''+Schema.SObjectType.Task.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('TSK_To_Do').getRecordTypeId()+'\''
		};

    
    static Datetime now = System.now();
    static String formatedDt = now.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    static Map<String, List<String>> userStoreMap;
    static Map<String, List<Event>> appointmentsMap;
    static Map<String, List<Task>> tasksMap;
    static Map<String, Set<String>> contactedClientsMap;
    public static Map<String, Object> GetFollowUpObject(List<String> teamIds,String period,String storeId,Integer pageSize,Integer pageIndex,String queryId,Boolean s){
        return new Map<String,Object>
        {
            BL_ICON_Constants.JSONRoot_outreaches 				    =>  getTasksWithPagination(teamIds,period,storeId,pageSize,pageIndex),
            BL_ICON_Constants.JSONRoot_appointments	                =>  appointments(teamIds,period,storeId,pageSize,pageIndex),
            BL_ICON_Constants.JSONRoot_purchasedProductsList	    =>  PurchasedProductsList(teamIds,period,storeId, pageSize, pageIndex),
            BL_ICON_Constants.JSONRoot_clientsContacted	            =>  clientsContacted(teamIds,period, storeId,pageSize, pageIndex,queryId,s),
            BL_ICON_Constants.JSONRoot_myClients10K                 =>  getClients10k(teamIds,storeId, pageSize, pageIndex), 
            BL_ICON_Constants.JSONRoot_myClientsPotential10K		=>  getClientsPotential10k(teamIds,storeId, pageSize, pageIndex),
            BL_ICON_Constants.JSONRoot_myClientsConfirmed10K 	    =>  getClientsConfirmed10k(teamIds,storeId, pageSize, pageIndex),
            BL_ICON_Constants.JSONRoot_myClientsConfirmed50K 	    =>  getClientsConfirmed50k(teamIds,storeId, pageSize, pageIndex),
            BL_ICON_Constants.JSONRoot_myClients10KLifestyle 	    =>  getClients10kLifestyle(teamIds,storeId, pageSize, pageIndex),
            BL_ICON_Constants.JSONRoot_myClientsConfirmed50KYTD  	=>  getClients50kYTD(teamIds,storeId, pageSize, pageIndex),
            BL_ICON_Constants.JSONRoot_appointmentsToCome	        =>  appointmentsToCome(teamIds,period,storeId,pageSize, pageIndex)
        };      
    }
    public static Map<String, Object> GetCountFollowUpObject(List<String> teamIds,String period,String storeId,Integer pageSize,Integer pageIndex){
        return new Map<String,Object>
        {
            BL_ICON_Constants.JSONRoot_tasksCount 				                =>  totalTasks(teamIds,period,storeId),
            BL_ICON_Constants.JSONRoot_appointmentsCount 				        =>  totalAppointments(teamIds,period,storeId),
            BL_ICON_Constants.JSONRoot_appointmentsToComeCount 	                =>  totalAppointmentToCome(teamIds,period,storeId),
            BL_ICON_Constants.JSONRoot_appointmentsWithPurchaseCount 	        =>  appointmentsWithPurshase(teamIds,period,storeId),
            BL_ICON_Constants.JSONRoot_myWardrobingTasksCount	                =>  wardrobingTasksCount(teamIds,period,storeId),
            BL_ICON_Constants.JSONRoot_currency 	                            =>  getCurrency(teamIds,period,storeId),
            BL_ICON_Constants.JSONRoot_my10K 	                                =>  my10K(teamIds,period, storeId),
            BL_ICON_Constants.JSONRoot_myPotential10K			                =>  myPotential10K(teamIds,period,storeId),
            BL_ICON_Constants.JSONRoot_myConfirmed10K 	                        =>  myConfirmed10K(teamIds,period,storeId),
            BL_ICON_Constants.JSONRoot_myConfirmed50K 	                        =>  myConfirmed50K(teamIds,period,storeId),
            BL_ICON_Constants.JSONRoot_my10KLifestyle	                        =>  my10KLifestyle(teamIds,period,storeId),
            BL_ICON_Constants.JSONRoot_myConfirmed50KYTD	                    =>  my50KYTD(teamIds,period,storeId),
            BL_ICON_Constants.JSONRoot_countClientsContacted                    => totalClientsContacted(teamIds,period,storeId)  
        };     
    }
    public static Object getKPIByFeatures(List<String> teamIds,String period, String storeId,String features,Integer pageSize,Integer pageIndex,String queryId,Boolean s){
        Map<String, Object> result = new Map<String, Object>();
        List<String> featuresList = features.split(';');
        for(String f : featuresList){
            switch on f{
                when 'tasksCount' {
                    result.put(BL_ICON_Constants.JSONRoot_tasksCount, totalTasks(teamIds,period,storeId));
                }
                when 'appointmentsToComeCount' {
                    result.put(BL_ICON_Constants.JSONRoot_appointmentsToComeCount, totalAppointmentToCome(teamIds,period,storeId));
                }
                when 'appointmentsWithPurchaseCount' {
                    result.put(BL_ICON_Constants.JSONRoot_appointmentsWithPurchaseCount, appointmentsWithPurshase(teamIds,period,storeId));
                }
                when 'appointmentsToCome' {
                    result.put(BL_ICON_Constants.JSONRoot_appointmentsToCome, appointmentsToCome(teamIds,period,storeId,pageSize,pageIndex));
                }
                when 'wardrobingOutreach'{
                    result.put(BL_ICON_Constants.JSONRoot_myWardrobingTasksCount,  wardrobingTasksCount(teamIds,period,storeId));
                }
                when 'currency' {
                    result.put(BL_ICON_Constants.JSONRoot_currency, getCurrency(teamIds,period,storeId));
                }
                when 'my10K' {
                    result.put(BL_ICON_Constants.JSONRoot_my10K, my10K(teamIds,period,storeId));
                }
                when 'myPotential10K' {
                    result.put(BL_ICON_Constants.JSONRoot_myPotential10K, myPotential10K(teamIds,period,storeId));
                }
                when 'myConfirmed10K' {
                    result.put(BL_ICON_Constants.JSONRoot_myConfirmed10K , myConfirmed10K(teamIds,period, storeId));
                }  
                when 'myConfirmed50K' {
                    result.put(BL_ICON_Constants.JSONRoot_myConfirmed50K , myConfirmed50K(teamIds,period, storeId));
                } 
                when 'my10KLifestyle' {
                    result.put(BL_ICON_Constants.JSONRoot_my10KLifestyle , my10KLifestyle(teamIds,period, storeId));
                }
                when 'myConfirmed50KYTD' {
                    result.put(BL_ICON_Constants.JSONRoot_myConfirmed50KYTD , my50KYTD(teamIds,period, storeId));
                }
                when 'outreaches' {
                    result.put(BL_ICON_Constants.JSONRoot_outreaches ,getTasksWithPagination(teamIds,period,storeId,pageSize,pageIndex));
                } 
                when 'appointments' {
                    result.put(BL_ICON_Constants.JSONRoot_appointments ,  appointments(teamIds,period,storeId,pageSize,pageIndex));
                } 
                when 'appointmentsCount' {
                    result.put(BL_ICON_Constants.JSONRoot_appointmentsCount , totalAppointments(teamIds,period,storeId));
                } 
                when 'purchasesProduct' {
                    result.put(BL_ICON_Constants.JSONRoot_purchasedProductsList , PurchasedProductsList(teamIds,period, storeId,pageSize, pageIndex));
                } 
                when 'clientsContacted' {
                    result.put(BL_ICON_Constants.JSONRoot_clientsContacted , clientsContacted(teamIds,period,storeId, pageSize, pageIndex,queryId,s));
                } 
                when 'myClients10k' {
                    result.put(BL_ICON_Constants.JSONRoot_myClients10K, getClients10k(teamIds,storeId, pageSize, pageIndex));
                } 
                when 'myClientsPotential10k' {
                    result.put(BL_ICON_Constants.JSONRoot_myClientsPotential10K , getClientsPotential10k(teamIds,storeId, pageSize, pageIndex));
                } 
                when 'myClientsConfirmed10k' {
                    result.put(BL_ICON_Constants.JSONRoot_myClientsConfirmed10k , getClientsConfirmed10k(teamIds,storeId, pageSize, pageIndex));
                } 
                when 'myClientsConfirmed50k' {
                    result.put(BL_ICON_Constants.JSONRoot_myClientsConfirmed50k , getClientsConfirmed50k(teamIds,storeId, pageSize, pageIndex));
                } 
                when 'myClients10kLifestyle' {
                    result.put(BL_ICON_Constants.JSONRoot_myClients10kLifestyle , getClients10kLifestyle(teamIds,storeId, pageSize, pageIndex));
                }
                when 'myClientsConfirmed50KYTD' {
                    result.put(BL_ICON_Constants.JSONRoot_myClientsConfirmed50KYTD , getClients50kYTD(teamIds,storeId, pageSize, pageIndex));
                }
                when 'countClientsContacted' {
                    result.put(BL_ICON_Constants.JSONRoot_clientsContacted , totalClientsContacted(teamIds,period,storeId));
                } 
                when ''{
                    return GetCountFollowUpObject(teamIds,period,storeId,pageSize,pageIndex);
                }
            }
        }
 
        return result;
    } 

    public static Object getTasksWithPagination(List<String> teamIds,string period,String storeId,Integer pageSize,Integer pageIndex){ 
        return new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_TASK_KPI)
        .condition(conditionForTask(teamIds,period,storeId))
        .orderBy('ActivityDate DESC')
        .pagination(pageIndex, pageSize)
        .executeQuery()
        .getSObjects();

    }

    public static Integer wardrobingTasksCount(List<String> teamIds,string period,String storeId){ 
        String condition = ' RecordTypeId IN '+ ListOfTaskRecordTypesId + ' AND ActivityDate <= TODAY AND ActivityDate = '+ calculatePeriod(period) +' AND IsWardrobing__c = TRUE  AND OwnerId IN '+ conditionForStoreId(teamIds,storeId);
        system.debug('*********'+condition);
        return new BL_EasyQuery()
                .objectName('Task')
                .condition(condition)
                .executeCount()
                .getTotalSize();
    }

    public static object totalTasks(List<String> teamIds,string period, String storeId){
       return new BL_EasyQuery()
                .objectName('Task')
                .condition(conditionForTask(teamIds,period,storeId))
                .executeCount()
                .getTotalSize();
    }

    public static Object getCurrency(List<String> teamIds,string period,String storeId){
        Set<String> pprsRMSIDS =  new Set<String>();
        Map<String,Decimal> pprMapCurrency = new Map<String,Decimal>();
        List<Event> events = getappointments(teamIds, period,storeId);
        for (Event appointment:events){
            if(appointment.RelatedTicketNumber__c != null){
                pprsRMSIDS.addAll(appointment.RelatedTicketNumber__c.split(';'));
            }
        }
        if(pprsRMSIDS.size() > 0){

            String[] fields = BL_WS_Router.clientPlatform != 'WECHAT' ? new String[]{'SUM(Amount__c) sumAmount','CurrencyCode__c' }: new String[]{'SUM(ConvertedAmountYUAN__c) sumAmount'};
            String condition = BL_WS_Router.clientPlatform != 'WECHAT' ? 'TransactionRMSId__c IN' + '('+listToString(pprsRMSIDS)+')'+' GROUP BY CurrencyCode__c' : 'TransactionRMSId__c IN' + '('+listToString(pprsRMSIDS)+')' ; 
           
            List<AggregateResult> aggregateResults = new BL_EasyQuery()
            .objectName('PPR_PurchProduct__c')
            .fields(fields)
            .condition(condition)
            .executeQuery()
            .getSObjects();
            
            if(BL_WS_Router.clientPlatform != 'WECHAT'){

                for(AggregateResult ar : aggregateResults){
                    pprMapCurrency.put(String.valueOf(ar.get('CurrencyCode__c')), (Decimal) ar.get('sumAmount'));
                } 

                return pprMapCurrency;
            }
            else if(aggregateResults.size() > 0 &&  BL_WS_Router.clientPlatform == 'WECHAT'){
                return aggregateResults[0].get('sumAmount') != null ? (Decimal) aggregateResults[0].get('sumAmount') : 0;
            }  
        }
        return (BL_WS_Router.clientPlatform != 'WECHAT') ? null : 0; 
    }
    public static Object PurchasedProductsList(List<String> teamIds,string period,String storeId,Integer pageSize, Integer pageIndex){	
        List<Map<String,Object>> pprs = new List<Map<String,Object>>();
        List<String> pprsRMSIDS =  new List<String>();
        List<Event> events = getappointments(teamIds, period,storeId);
        for (Event appointment:events){
            if(appointment.RelatedTicketNumber__c != null){
                pprsRMSIDS.addAll(appointment.RelatedTicketNumber__c.split(';'));
            }
        }
        if(pprsRMSIDS.size() > 0){
            pprs = new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_PURCHASE_PRODUCT)
                .condition('TransactionRMSId__c IN ' + '('+listToString(pprsRMSIDS)+')')
                .orderBy('TransactionRMSId__c, PurchasedDate__c')
                .pagination(pageIndex,pageSize)
                .executeQuery()
                .getMappedObjects();
        }
        return pprs;
    }
    public static Object  clientsContacted(List<String> teamIds,string period,String storeId,Integer pageSize, Integer pageIndex,String queryId,Boolean s){ 
        
        String contacted = contactedList(teamIds,period,storeId); 

        BL_EasyQuery clientsContactedObject  = new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_CLIENTMEMBERS)
        .condition('Id In '+'('+ contacted +')')
        .addInnerSelect('(select Owner.FirstName,Owner.LastName,ActivityDate from tasks  order by ActivityDate desc  NULLS last limit 1)')
        .addInnerSelect('(select Owner.FirstName,Owner.LastName,ActivityDate,StartDateTime, EndDateTime from events  order by StartDatetime desc NULLS last limit 1)');
    

    
        Map<string,object> mapContacted = new Map<string,object>();

        if(s == true){
        
            return clientsContactedObject
                .pagination(pageIndex,pageSize)
                .queryId(queryId)
                .executeRestQuery()
                .getResponseSObjects();
           
        } else{
            if( BL_WS_Router.clientPlatform != 'WECHAT'){
                        
                List<Object> mapContacted2 =  clientsContactedObject
                                .executeQuery()
                                .getSObjects();
            
               BL_ICON_ClientList_Helper.setOwnerDetails(null, mapContacted2);
                
                return new BL_WS_Response(mapContacted2);
                
            } else{
                mapContacted = clientsContactedObject
                                    .pagination(pageIndex,pageSize)
                                    .executeRestQuery()
                                    .getResponseSObjects() ;     
                        
            }
            return mapContacted;
        } 
    }

    public static Object  getClients10k(List<String> teamIds,String storeId,Integer pageSize, Integer pageIndex){ 
         List<Map<String, Object>> members = new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_CLIENTMEMBERS)
                .condition(getClientOwnerCondition(teamIds,storeId)+' AND (Segmentation__c IN (\'10k_local\',\'10k_non_local\') OR Flag_10K_12mr__c = TRUE)')
                .pagination(pageIndex,pageSize)
                .executeQuery()
                .getMappedObjects();
         
        // return BL_WS_Router.clientPlatform != 'WECHAT' ? setOwnerDetailsMapped(members) : members;
         return members;

        
    }
    public static Object  getClientsPotential10k(List<String> teamIds,String storeId,Integer pageSize, Integer pageIndex){ 
         List<Map<String, Object>> members = new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_CLIENTMEMBERS)
                .condition(getClientOwnerCondition(teamIds,storeId)+' AND Segmentation__c IN (\'potential_10k_local\', \'potential_10k_non_local\')' )
                .pagination(pageIndex,pageSize)
                .executeQuery()
                .getMappedObjects(); 
         //return BL_WS_Router.clientPlatform != 'WECHAT' ? setOwnerDetailsMapped(members) : members;
         return members;
    }
    public static Object  getClientsConfirmed10k(List<String> teamIds,String storeId,Integer pageSize, Integer pageIndex){ 
         List<Map<String, Object>> members = new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_CLIENTMEMBERS)
                .condition(getClientOwnerCondition(teamIds,storeId)+' AND Flag_10K_YTM__c = TRUE ')
                .pagination(pageIndex,pageSize)
                .executeQuery()
                .getMappedObjects(); 
         
         //return BL_WS_Router.clientPlatform != 'WECHAT' ? setOwnerDetailsMapped(members) : members;
         return members;

    }
    public static Object  getClientsConfirmed50k(List<String> teamIds,String storeId,Integer pageSize, Integer pageIndex){ 
         List<Map<String, Object>> members = new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_CLIENTMEMBERS)
                .condition(getClientOwnerCondition(teamIds,storeId)+' AND Flag_50K__c = TRUE  ')
                .pagination(pageIndex,pageSize)
                .executeQuery()
                .getMappedObjects();
        
         //return BL_WS_Router.clientPlatform != 'WECHAT' ? setOwnerDetailsMapped(members) : members;
		 return members;
        
    }
    
    public static Object  getClients10kLifestyle(List<String> teamIds,String storeId,Integer pageSize, Integer pageIndex){ 
         List<Map<String, Object>> members = new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_CLIENTMEMBERS)
                .condition(getClientOwnerCondition(teamIds,storeId)+' AND IsLifestyle__c = TRUE')
                .pagination(pageIndex,pageSize)
                .executeQuery()
                .getMappedObjects();
        
         //return BL_WS_Router.clientPlatform != 'WECHAT' ? setOwnerDetailsMapped(members) : members;
		 return members;
        
    }
    
    public static Object  getClients50kYTD(List<String> teamIds,String storeId,Integer pageSize, Integer pageIndex){ 
        List<Map<String, Object>> members = new BL_EasyQuery()
               .useCase(BL_ICON_Constants.USE_CASE_CLIENTMEMBERS)
               .condition(getClientOwnerCondition(teamIds,storeId)+' AND Flag_50K_12mr__c = TRUE')
               .pagination(pageIndex,pageSize)
               .executeQuery()
               .getMappedObjects();
       
        //return BL_WS_Router.clientPlatform != 'WECHAT' ? setOwnerDetailsMapped(members) : members;
        return members;
       
   }
    public static List<Map<String, Object>> setOwnerDetailsMapped(List<Map<String, Object>> members) {
        
        Set<String> ownerIdsList = new Set<String>();
        //List<Map<String, Object>> clients = (List<Map<String, Object>>) members.get('records');
        for(Map<String, Object> client : members){
            ownerIdsList.add((String)client.get('ownerId'));
        }
        
        if(!ownerIdsList.isEmpty()){
            
            Map<String, User> owners = new Map<String, User>();
            for(User u: [SELECT Id, Name, IsTechnicalUser__c FROM User WHERE Id IN:ownerIdsList]) {
                owners.put(u.Id,u);
            }
            for(Map<String, Object> client : members){
                
                String ownerId = (String)client.get('ownerId');
				client.put('ownerInfo',owners.get(ownerId));
                
			}
            //members.put('records',(Object) clients);
        }
        
         return members  ;
    }
    
    
    
    public static object totalClientsContacted(List<String> teamIds,string period,String storeId){
        String contacted = contactedList(teamIds,period,storeId); 
        return new BL_EasyQuery()
                 .objectName('Account')
                 .condition('Id In '+'('+ contacted +')')
                 .executeCount()
                 .getTotalSize();
     }
    public static Object appointmentsToCome(List<String> teamIds,string period,String storeId,Integer pageSize,Integer pageIndex){

        return  new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_EVENT)
            .condition( 'RecordTypeId IN ' + ListOfAppointmentRecordTypesId + ' AND Status__c IN (\'Assigned\', NULL, \'Not Assigned\') AND StartDateTime > '+formatedDt+' AND OwnerId IN ' + conditionForStoreId(teamIds,storeId))
            .pagination(pageIndex,pageSize)
            .executeQuery()
            .getSObjects();                                   
    }

    public static Integer appointmentsWithPurshase(List<String> teamIds,string period,String storeId){
        if(appointmentsMap != null && appointmentsMap.get(getMapKey(teamIds, period, storeId)) != null ){
            Integer appointmentsWithPurchaseCount = 0;   
            List<Event> events = getappointments(teamIds, period,storeId);
            for (Event appointment:events){
                if(appointment.RelatedTicketNumber__c != null){
                    appointmentsWithPurchaseCount ++;
                }
            }
            return appointmentsWithPurchaseCount;     
        } else {
            return new BL_EasyQuery()
            .objectName('Event')
            .condition(conditionForEvent(teamIds,period,storeId) + ' AND RelatedTicketNumber__c != null')
            .executeCount()
            .getTotalSize();
        }                                
    }
    public static object totalAppointmentToCome(List<String> teamIds,string period,String storeId){ 
        return new BL_EasyQuery()
                    .objectName('Event')
                    .condition( 'RecordTypeId IN  ' + ListOfAppointmentRecordTypesId + ' AND Status__c IN (\'Assigned\', NULL, \'Not Assigned\') AND StartDateTime > '+formatedDt+' AND OwnerId IN ' + conditionForStoreId(teamIds,storeId))
                    .executeCount()
                    .getTotalSize();
     }
    public static Object  appointments(List<String> teamIds,string period,String storeId,Integer pageSize, Integer pageIndex){    	                                    
        return  getappointments(teamIds, period,storeId);
    }
    public static object totalAppointments(List<String> teamIds,string period,String storeId){
        return new BL_EasyQuery()
                 .objectName('Event')
                 .condition(conditionForEvent(teamIds,period,storeId))
                 .executeCount()
                 .getTotalSize();
     }
    public static object my10K(List<String> teamIds,string period,String storeId){
       Map<String, Object> ret = new Map<String, Object>();
       Integer my10KContacted = 0;
        if(String.isNotBlank(contactedList(teamIds,period, storeId))){
            my10KContacted =  Database.countQuery('SELECT COUNT() FROM ACCOUNT WHERE ' + getClientOwnerCondition(teamIds,storeId) + ' AND ID In '+'('+contactedList(teamIds,period,storeId)+')' +' AND (Segmentation__c IN (\'10k_local\',\'10k_non_local\') OR Flag_10K_12mr__c = TRUE)');
        }
        Decimal myTotal10K = 0;
        if(String.isNotBlank(storeId) && ICONSettings__c.getInstance().useOneData__c){
            myTotal10K = [SELECT tenKCount__c from Store__c where RetailStoreId__c =: storeId]?.tenKCount__c;
            BL_WS_Log.addLogNotes('myTotal10K COUNT FROM ONEDATA');

        } else {
            myTotal10K =  Database.countQuery('SELECT COUNT() FROM ACCOUNT WHERE ' + getClientOwnerCondition(teamIds,storeId) + ' AND (Segmentation__c IN (\'10k_local\',\'10k_non_local\') OR Flag_10K_12mr__c = TRUE)');
        }
        ret.put('my10KContacted',my10KContacted);
        ret.put('myTotal10K',myTotal10K);
        return ret;
    }
    public static object myPotential10K(List<String> teamIds,string period,String storeId){
        Map<String, Object> ret = new Map<String, Object>();
        Integer myPotential10KContacted = 0;
        if(String.isNotBlank(contactedList(teamIds,period, storeId))){
            myPotential10KContacted = Database.countQuery('SELECT COUNT() FROM ACCOUNT WHERE ' + getClientOwnerCondition(teamIds,storeId) + 'AND ID In'+'('+contactedList(teamIds, period, storeId)+')'+' AND Segmentation__c IN (\'potential_10k_local\', \'potential_10k_non_local\')' );
        }
       
        Decimal myTotalPotential10K = 0;
        if(String.isNotBlank(storeId) &&  ICONSettings__c.getInstance().useOneData__c){
           myTotalPotential10K = [SELECT potentialTenKCount__c from Store__c where RetailStoreId__c =: storeId]?.potentialTenKCount__c;
           BL_WS_Log.addLogNotes('myTotalPotential10K COUNT FROM ONEDATA');

        } else {
            myTotalPotential10K =  Database.countQuery('SELECT COUNT() FROM ACCOUNT WHERE ' + getClientOwnerCondition(teamIds,storeId) + ' AND Segmentation__c IN (\'potential_10k_local\', \'potential_10k_non_local\')' );
        }
        ret.put('myPotential10KContacted',myPotential10KContacted);
        ret.put('myTotalPotential10K',myTotalPotential10K);
        return ret;
    }
    public static object myConfirmed10K(List<String> teamIds,string period, String storeId){ 
        Map<String, Object> ret = new Map<String, Object>();
        Integer myConfirmed10KContacted = 0;
        if(String.isNotBlank(contactedList(teamIds,period, storeId))){
            myConfirmed10KContacted = Database.countQuery('SELECT COUNT() FROM ACCOUNT WHERE ' + getClientOwnerCondition(teamIds,storeId) + ' AND ID In '+'('+contactedList(teamIds,period, storeId)+') AND Flag_10K_YTM__c = TRUE  ');
        }
        Decimal myTotalConfirmed10K = 0;
         if(String.isNotBlank(storeId) &&  ICONSettings__c.getInstance().useOneData__c){
             myTotalConfirmed10K = [SELECT tenKYTMCount__c from Store__c where RetailStoreId__c =: storeId]?.tenKYTMCount__c;
             BL_WS_Log.addLogNotes('myTotalConfirmed10K COUNT FROM ONEDATA');

        } else {
            myTotalConfirmed10K = Database.countQuery('SELECT COUNT() FROM ACCOUNT WHERE ' + getClientOwnerCondition(teamIds,storeId) + ' AND Flag_10K_YTM__c = TRUE ');
        }
                
        ret.put('myConfirmed10KContacted',myConfirmed10KContacted);
        ret.put('myTotalConfirmed10K',myTotalConfirmed10K);
        return ret;
    }

    public static object myConfirmed50K(List<String> teamIds,string period, String storeId){ 
        Map<String, Object> ret = new Map<String, Object>();
        Integer myConfirmed50KContacted = 0;
        if(String.isNotBlank(contactedList(teamIds,period, storeId))){
            myConfirmed50KContacted = Database.countQuery('SELECT COUNT() FROM ACCOUNT WHERE ' + getClientOwnerCondition(teamIds,storeId) + ' AND ID In '+'('+contactedList(teamIds,period, storeId)+') AND Flag_50K__c = TRUE');
        }

        Decimal myTotalConfirmed50K = 0;
        if(String.isNotBlank(storeId) && ICONSettings__c.getInstance().useOneData__c){
            myTotalConfirmed50K = [SELECT fiftyKCount__c from Store__c where RetailStoreId__c =: storeId]?.fiftyKCount__c;
            BL_WS_Log.addLogNotes('myTotalConfirmed50K COUNT FROM ONEDATA');

        } else {
            myTotalConfirmed50K =  Database.countQuery('SELECT COUNT() FROM ACCOUNT WHERE ' + getClientOwnerCondition(teamIds,storeId) + ' AND Flag_50K__c = TRUE');
        }
        
        ret.put('myConfirmed50KContacted',myConfirmed50KContacted);
        ret.put('myTotalConfirmed50K',myTotalConfirmed50K);
        return ret;
    }
    public static object my10KLifestyle (List<String> teamIds,string period, String storeId){ 
        Map<String, Object> ret = new Map<String, Object>();
        Integer my10KLifestyleContacted = 0;
        if(String.isNotBlank(contactedList(teamIds,period, storeId))){
            my10KLifestyleContacted = Database.countQuery('SELECT COUNT() FROM ACCOUNT WHERE ' + getClientOwnerCondition(teamIds,storeId) + ' AND ID In '+'('+contactedList(teamIds,period, storeId)+') AND IsLifestyle__c = TRUE  ');
        }

        Decimal myTotal10KLifestyle = 0;
        if(String.isNotBlank(storeId) && ICONSettings__c.getInstance().useOneData__c){
            myTotal10KLifestyle = [SELECT tenKLifestyleCount__c  from Store__c where RetailStoreId__c =: storeId]?.tenKLifestyleCount__c;
            BL_WS_Log.addLogNotes('myTotal10KLifestyle COUNT FROM ONEDATA');

        } else {
            myTotal10KLifestyle =  Database.countQuery('SELECT COUNT() FROM ACCOUNT WHERE ' + getClientOwnerCondition(teamIds,storeId) + ' AND IsLifestyle__c = TRUE  ');
        }
        
        ret.put('my10KLifestyleContacted',my10KLifestyleContacted);
        ret.put('myTotal10KLifestyle',myTotal10KLifestyle);
        return ret;
    }
    
     public static object my50KYTD (List<String> teamIds,string period, String storeId){ 
        Map<String, Object> ret = new Map<String, Object>();
        Integer myConfirm50KYTDContacted = 0;
        if(String.isNotBlank(contactedList(teamIds,period, storeId))){
            myConfirm50KYTDContacted = Database.countQuery('SELECT COUNT() FROM ACCOUNT WHERE ' + getClientOwnerCondition(teamIds,storeId) + ' AND ID In '+'('+contactedList(teamIds,period, storeId)+') AND FLAG_50K_12mr__c = TRUE  ');
        }

        Decimal myTotalConfirmed50KYTD = 0;
        if(String.isNotBlank(storeId) && ICONSettings__c.getInstance().useOneData__c){
            myTotalConfirmed50KYTD = [SELECT fiftyKYTDCount__c  from Store__c where RetailStoreId__c =: storeId]?.fiftyKYTDCount__c;
            BL_WS_Log.addLogNotes('myTotalConfirmed50KYTD COUNT FROM ONEDATA');

        } else {
            myTotalConfirmed50KYTD =  Database.countQuery('SELECT COUNT() FROM ACCOUNT WHERE ' + getClientOwnerCondition(teamIds,storeId) + ' AND FLAG_50K_12mr__c = TRUE  ');
        }
        
        ret.put('myConfirm50KYTDContacted',myConfirm50KYTDContacted);
        ret.put('myTotalConfirmed50KYTD',myTotalConfirmed50KYTD);
        return ret;
    }
    public static String listToString (List<String> obj){
        return '\'' + String.join((obj), '\',\'') + '\'';
    }
      public static String listToString (Set<String> stringSet){
          List<String> stringList = new List<String>();
          stringList.addAll(stringSet);
          return '\''+ String.join(stringList, '\',\'') + '\'';
    }
    public static String conditionForEvent(List<String> teamIds,String period,String storeId){
        return  'RecordTypeId IN ' + ListOfAppointmentRecordTypesId + ' AND Status__c IN (\'Assigned\', NULL, \'Not Assigned\') AND ActivityDate = '+calculatePeriod(period)+' AND StartDateTime <= '+formatedDt+' AND OwnerId IN ' + conditionForStoreId(teamIds,storeId);
    }
    public static String conditionForTask(List<String> teamIds,String period,String storeId){
        return ' RecordTypeId IN '+ ListOfTaskRecordTypesId + '  AND ActivityDate <= TODAY AND ActivityDate = '+calculatePeriod(period)+'  AND ActionType__c IN ( \'WeChat\' ,\'Email\' ,\'Phone\' ,\'SMS\' ,\'Mobile Chat\',\'Postal Mail\' ,\'WhatsApp\',\'Card\',\'Social\' ,\'Chat\' ,\'Line, KakaoChat, WeChat\' ,\'Other Messenger and Social Media apps\',\'Other\') AND OwnerId IN '+ conditionForStoreId(teamIds,storeId);
    }
    
    public static String conditionForStoreId(List<String> teamIds,String storeId){
       List<String> usersIds = new List<String>();
        if(String.isNotBlank(storeId)){
           if(userStoreMap == null) {

                userStoreMap = new Map<String, list<String>>();
           } 
           if(userStoreMap.get(storeId) == null){
                List<User> users = [Select Id From User Where defaultstore__c =:storeId];
                for(User u : users){
                    usersIds.add(u.id);
                }
                userStoreMap.put(storeId, usersIds);
           } 
           usersIds = userStoreMap.get(storeId);
               
        }
        else{
            usersIds = teamIds;
        }
        
        return '('+ listToString(usersIds)+')';
       /*return storeId !=null && storeId !='' ? '(Select Id From User Where defaultstore__c =\''+storeId+'\')': '('+ listToString(teamIds)+')';*/
    }

    public static String getClientOwnerCondition(List<String> teamIds,String storeId){
        if(String.isNotBlank(storeId)){
            return 'AttachedStore__pc =\''+storeId+'\'';
        } 
        return 'OwnerId IN ('+ listToString(teamIds)+')';
    }
    public static String contactedList(List<String> teamIds,string period,String storeId){
        Set<String> contactedList =  new Set<String>();
        if(contactedClientsMap != null && contactedClientsMap.get(getMapKey(teamIds, period, storeId)) != null ){
            return listToString(contactedClientsMap.get(getMapKey(teamIds, period, storeId)));
        }
        contactedClientsMap = new Map<String, Set<String>>();
        List<Task> tasks = (List<Task>) getTasks(teamIds, period, storeId); 
        for (Task task:tasks){
            contactedList.add(task.WhatId); 
        }
        contactedClientsMap.put(getMapKey(teamIds, period, storeId), contactedList);
        return listToString(contactedList);
    }
    public static List<Event> getappointments (List<String> teamIds,string period,String storeId){
        if(appointmentsMap != null && appointmentsMap.get(getMapKey(teamIds, period, storeId)) != null ){
            return appointmentsMap.get(getMapKey(teamIds, period, storeId));
        }
        appointmentsMap = new Map<String, List<Event>>();
        List<Event> evs = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_EVENT)
            .condition(conditionForEvent(teamIds,period,storeId))
            .orderBy('ActivityDate DESC')
            .executeQuery()
            .getSObjects();

        appointmentsMap.put(getMapKey(teamIds, period, storeId), evs);
        return evs;
    }
    public static List<Task> getTasks (List<String> teamIds,string period,String storeId){
        if(tasksMap != null && tasksMap.get(getMapKey(teamIds, period, storeId)) != null ){
            return tasksMap.get(getMapKey(teamIds, period, storeId));
        }
        tasksMap = new Map<String, List<Task>>();
        List<Task> tasks = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_TASK_KPI)
            .condition(conditionForTask(teamIds,period,storeId))
            .orderBy('ActivityDate DESC')
            .executeQuery()
            .getSObjects();

        tasksMap.put(getMapKey(teamIds, period, storeId), tasks);
        return tasks;  
    }

    public static String getMapKey(List<String> teamIds,string period,String storeId){
        return '' + teamIds.hashCode() + period + storeId;
    }
    
    public static String calculatePeriod (string period){
        switch on period {
            when 'week' {	
                return 'THIS_WEEK';
            }
            when 'lastMonth' {		
                return 'LAST_MONTH';
            }
            when else {		  	
                return 'THIS_MONTH';
            }
        }

    }
}