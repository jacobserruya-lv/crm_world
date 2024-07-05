/**
* @description: Batchable class used to send ICON notification (task) to CA whose orders have been untouched for 21 days
*               This batchable will run every day (is called in the schedulable class named SPO_SchedulerPendingBriefNotification)
*
* @modification history:
 * */

global class SPO_BatchPendingBriefNotification implements Database.Batchable<sObject> {
    
    public String query;
    public Datetime lastDate;
	
    global SPO_BatchPendingBriefNotification()
    {
        // get all orders in stage Brief in Progress or Quotatin available or Quotation accepted that have been left untouched for 21 days
        lastDate = System.now().adddays(-Integer.valueOf(System.Label.SO_PendingBriefDuration));
        query = 'SELECT id, StageName, ownerid, ordernumber__c from Opportunity where stagename in (\'Brief in progress\', \'Quotation submitted\', \'Quotation accepted\') ' +
            	'and applicationSource__c = \'SPO\' and ' ;
        if(Test.isRunningTest())
        {
            query += 'createddate <=:lastDate';    
        }
        else
        {
 			query+=	'lastmodifieddate <=:lastDate';
        }
        
    } 
    
    global Database.QueryLocator start(database.BatchableContext CD)
    {
        system.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        String tDescription = '';
        List<Task> taskToCreate = new List<Task>();
    	for(SObject o: scope)
        {
            // create a task for each pending brief. Task description depends on order stage
            Opportunity opp = (Opportunity)o;
            if(opp.stagename == 'Brief in progress')
            {
                tDescription =  String.format(System.Label.SO_PendingBriefDescription, new String[]{string.valueOf(opp.ordernumber__c)});
            }
            else
            {
                tDescription = String.format(System.Label.SO_PendingQuotationDescription, new String[]{string.valueOf(opp.ordernumber__c)});
            }
            Task t = new Task(Description = tDescription,
                 			OwnerId = opp.ownerid,
                 			Priority = System.Label.SO_PendingBriefPriority,
                 			Status = System.Label.SO_PendingBriefStatus,
                 			Subject = System.label.SO_PendingBriefSubject,
                            ActionType__c = System.label.SO_PendingBriefActionType,
                            ActivityDate = System.today().adddays(Integer.valueOf(System.Label.SO_PendingBriefDueDate)),
                 			WhatId = opp.id);
			taskToCreate.add(t);
        }
        
        try
        {
           if(taskToCreate.size() > 0)
           {
               Database.insert(taskToCreate, false); 
               // Perform a dummy update on orders. This will the bacth from processing the same orders on next schedule
               Database.update(scope, false); 
           }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //no further processing
    }
    



}