global class IC_BatchAnniversaryReminder implements Database.Batchable<sObject>{

    public String query;   
    public List<Task> lstTask=new List<Task>();
    Integer thisMonth;
    Integer year;
    String nextMonth;
    List<String> indexedAnniversaryDays;
    
    //public static final String userId = UserInfo.getUserId();
         
    global IC_BatchAnniversaryReminder(){      
   		thisMonth = Date.today().month();
   		year =Date.today().year();
   		if(thisMonth==12){thismonth = 1; year = year+1;}
   		else {thismonth = thisMonth + 1;}
		nextMonth=String.valueOf(thisMonth);
		indexedAnniversaryDays = IC_Utils.getIndexedDays_AR();
		System.debug('### indexed Days size : ' + indexedAnniversaryDays.size());
    	
    	if(indexedAnniversaryDays.size() > 0)
        	query = 'SELECT Id,ownerid, AnniversaryMonth__pc, AnniversaryDay__pc FROM Account Where (IsDream__c = false and AnniversaryMonth__pc = :nextMonth and AnniversaryDay__pc IN :indexedAnniversaryDays )';
        else
        	query = 'SELECT Id,ownerid, AnniversaryMonth__pc, AnniversaryDay__pc FROM Account Where (IsDream__c = false and AnniversaryMonth__pc = :nextMonth and AnniversaryDay__pc != null )';
     }
      
      
        
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - IC_BatchAnniversaryReminder');
        System.debug('#### query : ' + query);
        return Database.getQueryLocator(query);   
    }
    
    
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
    	
		System.debug('### try');
				
        try{
        	System.debug('### try2');
        	
           for(sObject o:scope){
                Account client = (Account)o;
                String annifDay=client.AnniversaryDay__pc;
                Integer day=Integer.valueOf(annifDay); 

                	Task task =new Task();
                	task.WhatId=client.Id;
                	task.OwnerId=client.OwnerId;
                	task.status ='new';
                	task.Subject=Label.IC_Anniversary_Reminder;
                	task.priority='Normal';
                	task.ActivityDate=date.newInstance(year, thisMonth, day);
                	task.isAnniversaryReminder__c = true;
                	task.TECH_is_AutoSave__c = true;
                	lstTask.add(task);
                	System.debug('### task added to the list of task');
               
            }
            Database.SaveResult[] resultats = database.insert(lstTask, false);
            for(Database.SaveResult sr : resultats){
            	if (!sr.isSuccess()) {
        			// Operation was not successful, so get the ID of the record that was processed
        			for(Database.Error err : sr.getErrors()) {
            			System.debug('### an error has occurred where inserting task : ' + 
            						err.getStatusCode() + '  :  ' + err.getMessage() + 
            						', task fields that affected this error: ' + err.getFields());
        			}
    			}
            } 
            System.debug('tasks inserted');
    		//insert lstTask;
    		  		
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext CD){}

}