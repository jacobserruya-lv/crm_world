/**
    Description: Batch to update status on careservice__c
    Created for:  ICON project
    Create date: 26/07/2018
*/

global class IM_BatchCareServiceStatusFlow implements Database.Batchable<sObject>{
      
    public String query;
    

    List<CareServiceFlow__mdt> statusSettings = new List<CareServiceFlow__mdt>();
    Map<String, List<CareServiceFlow__mdt>> statusSettingsMap = new Map<String, List<CareServiceFlow__mdt>>();
    List<String> statusList = new List<String>();
    List<CareService__c> careToUpdate = new List<CareService__c>();
    
    global IM_BatchCareServiceStatusFlow(){

        statusSettings = [Select Id,DaysInStatus__c,ForManagerOnly__c,MyRepairStatus__c, To_do__c,MessageToCA__c FROM CareServiceFlow__mdt Order By DaysInStatus__c DESC];
        String statusConditions = '';
        for( CareServiceFlow__mdt statusSet : statusSettings){
            if(statusSettingsMap.get(statusSet.MyRepairStatus__c) == null){
                statusSettingsMap.put(statusSet.MyRepairStatus__c, new List<CareServiceFlow__mdt>());
            }
            statusSettingsMap.get(statusSet.MyRepairStatus__c).add(statusSet);

            if(statusConditions != ''){
                statusConditions += ' OR ';
            }
            String LimitDate = DateTime.now().addDays(-statusSet.DaysInStatus__c.intValue()).format('YYYY-MM-dd');
            statusConditions += ' ( MyRepairStatus__c = \'' + statusSet.MyRepairStatus__c + '\' AND Last_MyRepair_Status_Changed_Date__c =' + LimitDate + ' ) ';
        }

        statusList.addAll(statusSettingsMap.keySet());
       // statusList.addAll(new list<string>{'orderPendingValidation', 'waitingForClientDecision'});
        String LimitDate = DateTime.now().addDays(-7).format('YYYY-MM-dd');
        query = ' SELECT Id, MyRepairStatus__c, MyRepair_CreatedDate__c, MessageToCA__c,Is_Not_Repaired__c, IsToDo__c, Last_FollowUpStatus_Changed_Date__c,NS_Code__c, '+
        ' Yellow_Code__c, Red_Code__c, LastModifiedDate, CreatedDate, Followup_Status__c, ExternalId__c, Display_ToManagerOnly__c, CA__c, Store__c,Last_MyRepair_Status_Changed_Date__c ' +
        ' FROM  CareService__c Where MyRepair_CreatedDate__c = LAST_N_DAYS:365 AND ('+ statusConditions + ' OR (Followup_Status__c = \'Closed\' AND  Last_FollowUpStatus_Changed_Date__c = ' + LimitDate + ' ) '+
        ' OR (MyRepairStatus__c = \'shippedToStore\' AND Is_Not_Repaired__c = true)' +
        ' OR (MyRepairStatus__c NOT IN : statusList AND IsToDo__c = true))' ;
     }
        
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - IM_BatchCareServiceStatusFlow');
        System.debug('#### query : ' + query);
        return Database.getQueryLocator(query);   
    } 
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
        try{
            if(scope.size() > 0){
                this.setStatus((List<CareService__c>) scope);
            }
            
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }       
    }
    
    global void finish(Database.BatchableContext CD){
        Datetime sysTime = System.now();

       // this would increase the time to 1 hour after current time
        sysTime = sysTime.addHours(1);

        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
		String strJobName = 'CareServiceJOB-' + sysTime.getTime();
		System.schedule(strJobName, chron_exp, new IM_SchedulerCareServiceStatusFlow());
    }

    private void setStatus( List<CareService__c> careList ) {
        for( CareService__c care : careList ){
            List<CareServiceFlow__mdt>  statusSets =  statusSettingsMap.get(care.MyRepairStatus__c);
            Boolean closedToday = care.Followup_Status__c == 'Closed' && care.Last_FollowUpStatus_Changed_Date__c != null && care.Last_FollowUpStatus_Changed_Date__c == system.today();
            if( statusSets != null ){               
                Boolean toBeUpdated = false;
                for( CareServiceFlow__mdt statusSet : statusSets ){
                    if( care.Last_MyRepair_Status_Changed_Date__c != null &&  system.today().daysBetween(care.Last_MyRepair_Status_Changed_Date__c) == -statusSet.DaysInStatus__c && !toBeUpdated &&  !closedToday ){                  
                        care.IsToDo__c = care.IsToDo__c == true ? true : statusSet.To_do__c ;
                        care.Display_ToManagerOnly__c =  statusSet.ForManagerOnly__c; 
                        care.MessageToCA__c = String.isNotEmpty(statusSet.MessageToCA__c)  ? statusSet.MessageToCA__c : care.MessageToCA__c;
                        care.Followup_Status__c = care.Followup_Status__c != 'Closed' && care.Followup_Status__c!= null ? care.Followup_Status__c : 'New';
                        toBeUpdated = true;
                    } else if ( care.Last_FollowUpStatus_Changed_Date__c != null && system.today().daysBetween(care.Last_FollowUpStatus_Changed_Date__c) == - 7 && care.Followup_Status__c == 'Closed' && toBeUpdated == false){
                        care.IsToDo__c = false ;
                        care.Display_ToManagerOnly__c =  false; 
                        care.MessageToCA__c = null;
                        toBeUpdated = true;
                    } 
                }  
                if (toBeUpdated == true){
                    careToUpdate.add(care);
                }
            } else if (care.IsToDo__c == true){
                care.IsToDo__c = false ;
                care.Display_ToManagerOnly__c =  false; 
                care.MessageToCA__c = null;
                careToUpdate.add(care);
            }

            if(care.MyRepairStatus__c == 'shippedToStore' && care.Is_Not_Repaired__c == true){
                care.IsToDo__c = true;
                care.MessageToCA__c = 'Shipped to store but NOT REPAIRED';
                system.debug('Shipped to store but NOT REPAIRED' + care.Id);
                 careToUpdate.add(care);
            }
        }

        if (careToUpdate.size() > 0){
            update careToUpdate;
        }
    }
    
}