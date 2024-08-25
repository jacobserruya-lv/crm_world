global class ICX_OrderNoteCleanerBatch implements  Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts { 
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime dt = DateTime.Now().addHours(-1);

        return Database.getQueryLocator([SELECT Id, Type__c, CreatedDate FROM Order_Note__c WHERE (CreatedDate <: dt AND Type__c=:'PAYMENT_LINK') OR (CreatedDate<LAST_N_DAYS:14   AND Type__c=:'EXTENDED_PAYMENT_LINK') ORDER BY CreatedDate DESC  ]);

    }

    global void execute(Database.BatchableContext BC, list<Order_Note__c> scope){

        // for(Order_Note__c currentOrderNote : scope)
        // {
        //     system.debug(currentOrderNote);
        // }

        // system.debug('nb of order note to delete'+scope.size());
        try{

           delete scope;
        }
        catch(EXCEPTION e)
        {
            system.debug('ICX_OrderNoteCleanerBatch ERROR : ' + e.getMessage());

        }
    }
    global void finish(Database.BatchableContext BC){}

    global void execute(SchedulableContext sc) {
        ICX_OrderNoteCleanerBatch b = new ICX_OrderNoteCleanerBatch(); 
        database.executebatch(b,100);
    }

}