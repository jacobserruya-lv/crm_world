public class Task_TriggerHandler {
      // avoid the recursion https://help.salesforce.com/articleView?id=000133752
      private static boolean run = true;
      private static final String ISDEFAULT = 'ISDEFAULT';
  
      //===================================================//
      // Here go the handler methods
    /*  public static boolean runOnce() {
          System.debug('runOnce=' + run);
          if (run) {
              run = false;
              return true;
          } 
          else {
              return run;
          }
      }
  
        public static void beforeInsert(List<Task> newTaskList, Map<id, Task> newTaskMap) {
        for(Task newTask : newTaskList){
  
        }
      }*/
  
public static void afterInsert(List<Task> newTaskList, Map<id, Task> newTaskMap) {
  Map<Id,Task> mapCaseTask = new Map<Id,Task>();
  for(Task newTask : newTaskList){
      // Coming action in DPCA case                
      mapCaseTask.put(newTask.WhatId,newTask);
      }
      if(mapCaseTask !=null)
      {
        updateActivityDateFromAllActivity(mapCaseTask);
      }
}
     
    /*  public static void beforeUpdate(List<Task> newTaskList, Map<id, Task> newTaskMap,
      List<Task> oldTaskList, Map<id, Task> oldTaskMap){
  
          
          for( Task e : newTaskList){
             
  
      }
    }

    */

public static void afterDelete(List<Task> newTaskList) {
  Map<Id,Task> mapCaseTask = new Map<Id,Task>();
  for(Task newTask : newTaskList){
    // Coming action in DPCA case                
      mapCaseTask.put(newTask.WhatId,newTask);
      }
      if(mapCaseTask !=null)
      {
        updateActivityDateFromAllActivity(mapCaseTask);
      }                              
}

public static void afterUpdate(List<Task> newTaskList, Map<id, Task> newTaskMap,
  List<Task> oldTaskList, Map<id, Task> oldTaskMap) {
  Map<Id,Task> mapCaseTask = new Map<Id,Task>();
  for(Task newTask : newTaskList){
      // Coming action in DPCA case                
      mapCaseTask.put(newTask.WhatId,newTask);
      }
      if(mapCaseTask !=null)
      {
        updateActivityDateFromAllActivity(mapCaseTask);
      }                              
}
       /* HELPER METHODS */
    // Orginal method before - /NI-1824
    //Updare comming acion date on DPCA case
    //   public static void updateDPCA(Map<Id,Task> mapDPCATask){
    //     List<Case> lstCaseToUpdate = new  List<Case> ();
    //     Id dpcaRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId();	
    //     List<Case> lstDPCA = [SELECT Id FROM Case WHERE Id in:mapDPCATask.keySet() AND RecordTypeId=:dpcaRTId];
    //     for(Case dpca : lstDPCA ){
    //     ///NI-1824
    //     if (mapDPCATask.get(dpca.Id).TaskSubtype != 'Email') {
    //       dpca.Coming_Action__c = mapDPCATask.get(dpca.Id).ActivityDate;
    //     }
    //         system.debug('ActivityDate' +mapDPCATask.get(dpca.Id).ActivityDate);
    //         lstCaseToUpdate.add(dpca);
    //     }
    //     Update lstCaseToUpdate;
    // }

public static void updateActivityDateFromAllActivity(Map<Id,Task> mapDPCATask){
  //Get all modified task (WhatId , task)
  List<Case> lstCaseToUpdate = new List<Case> ();
  Id dpcaRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId();	
  List<Case> getAllCase = [SELECT Id, Coming_Action__c FROM Case WHERE Id in:mapDPCATask.keySet() AND RecordTypeId=:dpcaRTId];
  List<id> listAllCaseId = new list <id>();
  Boolean flagForUpdt = False;
  //get all id of case
  for (Case var : getAllCase) {
    listAllCaseId.add(var.id);
  }

  //get all task with id
  List<Task> AlltasksList = [SELECT Id, Subject, Description, WhatId, ActivityDate, TaskSubtype FROM Task WHERE WhatId = :listAllCaseId];
  
  list<case> caseToupdate = new list <case>();
  for(Case currentCase : getAllCase ){
    flagForUpdt = False;
    // List<Task> tempListTask = AlltasksList.filter(tskCurrent => tskCurrent.WhatId == currentCase.Id);
    List<Task> tempListTask = new list<task>();
    Boolean isEmpty = true;
    //filter list with a case id
    for (task tskToFilter : AlltasksList) {
      if(tskToFilter.WhatId == currentCase.id)
      {
        tempListTask.add(tskToFilter);
        isEmpty = false;
      }
    }
    List<Date> allDateCurrent = new list<Date>();

    for (Task var : tempListTask) {
      //  NI-1824
      if (var.TaskSubtype != 'Email') {
        if (var.ActivityDate >= System.today()) {
          allDateCurrent.add(var.ActivityDate);
      }
    }
    }
    allDateCurrent.sort();

    if(allDateCurrent.isEmpty())
    {
      if (currentCase.Coming_Action__c != null) {
        flagForUpdt = TRUE;
      }
      currentCase.Coming_Action__c = null;
    }
    else
    {
      if (currentCase.Coming_Action__c != allDateCurrent[0]) {
        flagForUpdt = TRUE;
      }
      currentCase.Coming_Action__c = allDateCurrent[0];
    }
    caseToupdate.add(currentCase);
    
    //add all the dates;
    /*
    task => get all related case in a set / get all task relatated to each case ()
    */
  }
  if (flagForUpdt) 
  update caseToupdate;
}
}