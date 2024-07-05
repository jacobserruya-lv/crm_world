global class CampaignHistoryCleanerBatch_Scheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
		CampaignHistoryCleanerBatch b = new CampaignHistoryCleanerBatch(0);
		database.executebatch(b);
	}
}