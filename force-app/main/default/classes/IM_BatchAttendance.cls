global class IM_BatchAttendance implements Database.Batchable<sObject> {

    public String query;

    global IM_BatchAttendance() {
        query = 'SELECT Id, Attendance__c, Sale__c, No_Transaction__c, ClientNoShow__c FROM Event Where EndDateTime = LAST_N_DAYS:30';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
	}

    global void execute(Database.BatchableContext BC, List<Event> scope) {
        System.debug('TTTTTTTTTTTT events: ' + scope);
        for(Event event : scope) {
            System.debug('YYYYYYYYYYYYYYY in the loop event: ' + event);
            if(!event.Sale__c && !event.No_Transaction__c && !event.ClientNoShow__c) {
                event.Attendance__c = 'None';
            }
            else if(event.ClientNoShow__c) {
                event.Attendance__c = 'No';
            }
            else if((event.No_Transaction__c || event.Sale__c) && !event.ClientNoShow__c) {
                event.Attendance__c = 'Yes';
            }
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
	}
}