/**
	Description: Batch scheduled to create Standard Client Lists automatically for new users

	Update History
	--------------
	19/10/2016 / Created By RMOU
	
	Issues / TODOs
	--------------
*/

global class BatchScheduledClientLists implements Database.Batchable<sObject>, Schedulable {

	global void execute (SchedulableContext SC)
	{
		BatchScheduledClientLists bscl = new BatchScheduledClientLists();

		Database.executeBatch(bscl, 200);
	}
	
	private String query;
	// Will hold the list of Client Lists Names by Country
	private Map<String, String> mapCountryToClientLists = new Map<String, String>();
	
	global BatchScheduledClientLists() {

		List<String> profilesList = new List<String>();
		// Will create Client Lists for both SA and Manager Profiles
		profilesList.add(IC_UTILS.getSAProfile());
		profilesList.add (IC_UTILS.getSAManagerProfile());

		query = 'SELECT id, Country__c FROM User WHERE isActive = true AND IsTechnicalUser__c = false AND Country__c <> \'\' AND (Primary_App__c = \'Icon\' OR Other_Apps__c INCLUDES (\'Icon\')) AND Profileid IN (\'' + String.join (profilesList, '\',\'') + '\') AND id NOT IN (SELECT Ownerid FROM CLI_CliList__c)';

		if (Test.isRunningTest())
			query += ' ORDER BY CreatedDate DESC LIMIT 200'; // Ensuring the test method does not launch several batches

		// Filling up the map
		for (ICON_Default_ClientList__c idcl : [SELECT Name, DefautClientList__c FROM ICON_Default_ClientList__c])
		{
			if (!idcl.Name.contains('_'))
				mapCountryToClientLists.put(idcl.Name.toUpperCase(), idcl.DefautClientList__c);
		}

		System.debug(mapCountryToClientLists);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		// If the map is empty, abort the job immediately
		if (mapCountryToClientLists.isEmpty())
			System.abortJob(BC.getJobId());

		System.debug(query);

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		List<CLI_CliList__c> cliListsToInsert = new List<CLI_CliList__c>();

   		System.debug ('*** size : ' + scope.size() + ' | ' + scope + ' ***');

   		for (sObject o : scope)
   		{
   			User u = (User)o;
   			if (mapCountryToClientLists.containsKey(u.Country__c))
   			{
	   			for (String cliListName : mapCountryToClientLists.get(u.Country__c).split(','))
	   			{
	   				cliListsToInsert.add(new CLI_CliList__c(Ownerid = u.id, Name = cliListName.trim(), Active__c = true));
	   			}
	   		}
   		}

   		insert cliListsToInsert;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}