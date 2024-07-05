public class UpdateOpportunityBatch implements Database.Batchable<SObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext context) {
        // Calculate the date and time 24 hours ago
        DateTime twentyFourHoursAgo = System.now().addDays(-1);
        String formattedDateTime = twentyFourHoursAgo.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
         System.debug('Formatted DateTime: ' + formattedDateTime);

        // Set your query here
        String query = 'SELECT Id FROM Opportunity WHERE SPO_Store__r.CheckXstoreDeposit__c = true AND CreatedDate <= '+formattedDateTime+' AND StageName = \'Creation in progress\' AND DepositReceived__c = false and ApplicationSource__c =\'PERSO\'';
        System.debug(' query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Opportunity> opportunities) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Opportunity opp : opportunities) {
            SPO_FirmOrderControllerLC.cancelFirmOrderDB(opp.Id,'Automated process','Production - Other','Deposit not received from Xstore after 24 hours') ;
            opportunitiesToUpdate.add(opp);
        }
        
        // Update the records
        update opportunitiesToUpdate;
    }

    public void finish(Database.BatchableContext context) {
        
    }

}