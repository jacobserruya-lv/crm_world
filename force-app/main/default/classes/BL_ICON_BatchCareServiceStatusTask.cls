global with sharing class BL_ICON_BatchCareServiceStatusTask implements Database.Batchable<sObject>{

    public String query;
    public Map<String,String>  technicalUsers = new Map<String,String>() ;
    
    global BL_ICON_BatchCareServiceStatusTask(){	
      technicalUsers = ICON_Todos_Helper.getTechnicalUsers();


       // SELECT id ,MyRepairStatus__c ,StoreRetailCode__c,IsToDo__c, Store__c,Store__r.ISO3_Code__c ,CA__c,CA_Code__c, Client__c ,Client__r.PersonContactId
      
        query = 'SELECT Id, MyRepairStatus__c, Last_MyRepair_Status_Changed_Date__c, StoreRetailCode__c,IsToDo__c, Store__c,Store__r.ISO3_Code__c ,CA__c,CA_Code__c, Client__c ,Client__r.PersonContactId, RepairInProgressDayFlag__c FROM CareService__c WHERE MyRepairStatus__c = \'repairInProgress\' AND IsClosed__c = false ';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try {
            List<CareService__c> careServices = new List<CareService__c>();

            Map<String, CareService__c> mapCareService = new  Map<String, CareService__c>();
            List<Task> tasksToUpdate = new list<Task>();
            List<Task> taskToCreate = new list<Task>();
            
            for(sObject cs : scope){
                CareService__c careService = (CareService__c) cs;
                careServices.add(careService);
            }
            

            if (!careServices.isEmpty()){
                String subject = '';
                for(CareService__c care : careServices){
                    Date startDate = care.Last_MyRepair_Status_Changed_Date__c;
                    Date endDate = Date.today();
                    Integer noOfDays = startDate.daysBetween( endDate );
                    system.debug( 'Output is ' + noOfDays );
                    system.debug( 'Date us: ' + startDate );

                    if (noOfDays >= 45 && noOfDays < 90 && care.RepairInProgressDayFlag__c != 45){
                        care.RepairInProgressDayFlag__c = 45;
                        mapCareService.put(care.Id, care);
                        subject = 'Repair in progress (45 days)';
                        //createtask -> helper
                        taskToCreate.add( ICON_Todos_Helper.createToDoTaskCareServiceInProgress(care, technicalUsers, subject, 'TD_CS_05'));
                    }
                    else if (noOfDays >= 90 && noOfDays < 135&& care.RepairInProgressDayFlag__c != 90){
                        care.RepairInProgressDayFlag__c = 90;
                        subject = 'Repair in progress (90 days)';
                        taskToCreate.add( ICON_Todos_Helper.createToDoTaskCareServiceInProgress(care, technicalUsers, subject,'TD_CS_06'));

                        mapCareService.put(care.Id, care);
                    }
                    else if (noOfDays >= 135 && noOfDays < 180 && care.RepairInProgressDayFlag__c != 135){
                        care.RepairInProgressDayFlag__c = 135;
                        subject = 'Repair in progress (135 days)';
                        taskToCreate.add( ICON_Todos_Helper.createToDoTaskCareServiceInProgress(care, technicalUsers, subject,'TD_CS_07'));

                        mapCareService.put(care.Id, care);
                    }
                    else if (noOfDays >= 180 && care.RepairInProgressDayFlag__c != 180){
                        care.RepairInProgressDayFlag__c = 180;
                        subject = 'Repair in progress (180 days)';
                        taskToCreate.add( ICON_Todos_Helper.createToDoTaskCareServiceInProgress(care, technicalUsers, subject,'TD_CS_08'));
                        mapCareService.put(care.Id, care);
                    }
                }
            }
            if (!mapCareService.keySet().isEmpty()) {
                for(Task t : [SELECT Id, CareServiceRepairInProgressFlag__c, ClosedByIS__c FROM Task WHERE CareServiceRepairInProgressFlag__c = TRUE AND WhatId IN :mapCareService.keySet()]){
                    t.CareServiceRepairInProgressFlag__c = false;
                    t.ClosedByIS__c = true;
                    tasksToUpdate.add(t);
                }
                if(!tasksToUpdate.isEmpty()){
                    update tasksToUpdate;
                }
                Database.update(mapCareService.values(), false);
            }
            if(!taskToCreate.isEmpty()){
                Database.insert(taskToCreate);
            }

        } catch(Exception e) {
            System.debug('#### ' + e.getTypeName() + ' Exception:' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext CD){}
}