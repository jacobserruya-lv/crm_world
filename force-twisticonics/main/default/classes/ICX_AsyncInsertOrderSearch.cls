global class ICX_AsyncInsertOrderSearch implements Schedulable {
    static Integer maxJobsToCreate = 50;

    global void execute(SchedulableContext SC) {
        // Are there other instances of the job running.
        List<CronTrigger> cronTriggerList = [SELECT Id 
                                            FROM CronTrigger 
                                            WHERE state in ('ACQUIRED', 'EXECUTING', 'PAUSED', 'BLOCKED', 'PAUSED_BLOCKED')
                                              AND id != :SC.getTriggerId()
                                              AND CronJobDetail.name like 'Init Order Search at%'];

        if (cronTriggerList.size() == 0) {
            insertOrderSearch(2000); 
        }
        else {
            system.debug('ICX_AsyncInsertOrderSearch-aborted-Other Scheduled Job is running : '+cronTriggerList);
        }
  
     }

    public static void insertOrderSearch(Integer nbRecordsByJob) {
        List<AsyncApexjob> l = [SELECT id, ApexClass.Name, status from AsyncApexJob where JobType = 'Future' AND Status in ('Preparing', 'Processing', 'Pending', 'Queued') and ApexClass.Name = 'ICX_AsyncInsertOrderSearch' limit 200];

        if (l.size() == 0 ) {
        
            Integer maxRecords = Math.Min(nbRecordsByJob * maxJobsToCreate, 49000);
            

            // query
            // 1 query : shippings not existing in order_search__c (/!\ more than 10 millions records today /!\)

            String query = 'SELECT Id FROM OrderLine__c WHERE id not in (Select order_line__c From order_search__c) and OrderShipping__r.StatusDate__c >= LAST_N_MONTHS:6 and OrderShipping__r.Status__c = \'fulfilled\'';
            query = query + ' LIMIT '+maxRecords;
            // Query data to insert into OrderSearch__c

            List<OrderLine__c> orderLineList = Database.query(query);
            List<String> orderLineIds = new List<String>();

            List<ICX_ChangeEventWrapper> changeEventList = new List<ICX_ChangeEventWrapper>();
            EventBus.ChangeEventHeader header = new EventBus.ChangeEventHeader();
            SObject event;

            header.entityName = 'OrderLine__c';
            header.changeType = 'CREATE';

            for (OrderLine__c orderLine : orderLineList) {            
                orderLineIds.add(String.valueof(orderLine.get('Id')));
                
                if (orderLineIds.size() == nbRecordsByJob) {
                    insertOrderSearch(orderLineIds);
                    orderLineIds = new List<String>();
                }            
            }

            if (orderLineIds.size() > 0) {
                insertOrderSearch(orderLineIds);
            }
        } else {
            system.debug('ICX_AsyncInsertOrderSearch - aborted - previous job not ended.');
        }


    }

    private static List<ICX_ChangeEventWrapper> getChangeEventWrapper(List<String> orderLineIds) {
        List<ICX_ChangeEventWrapper> changeEventList = new List<ICX_ChangeEventWrapper>();
        EventBus.ChangeEventHeader header = new EventBus.ChangeEventHeader();
        SObject event;

        header.entityName = 'OrderLine__c';
        header.changeType = 'CREATE';
            
        header.recordIds = new List<String>(orderLineIds);
        changeEventList.add(new ICX_ChangeEventWrapper(header, event));

        return changeEventList;
    }

     /**
     * Determine if wether or not the method can be executed as a @future method
     */
    public static void insertOrderSearch(List<String> orderLineIds) {
        if (System.isFuture() || System.isBatch()) {
            system.debug('JGU-ICX_OrderSearch_Helper.onChangeEvent => synchronous');
            ICX_OrderSearch_Helper.onChangeEvent(getChangeEventWrapper(orderLineIds));
        }
        else {
            system.debug('JGU-ICX_OrderSearch_Helper.onChangeEvent => @future');
            insertOrderSearchFuture(orderLineIds);
        }
    }
    
    @future
    private static void insertOrderSearchFuture(List<String> orderLineIds) {
        
        ICX_OrderSearch_Helper.onChangeEvent(getChangeEventWrapper(orderLineIds));
    }
}