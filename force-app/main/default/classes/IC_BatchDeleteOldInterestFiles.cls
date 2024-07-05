global class IC_BatchDeleteOldInterestFiles implements Database.Batchable<sObject> {
	
	String query;

	
	global IC_BatchDeleteOldInterestFiles() {
		query = 'select Id From Document WHERE Name Like \'interest%\' And  Description  Like \'%Processed\' AND CreatedDate < YESTERDAY Order by CreatedDate desc';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

         return Database.getQueryLocator(query);

	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		List<Document> documentsTodelete = new List<Document>();
   		for(Document doc : (List<Document>) scope){
   			documentsTodelete.add(doc);
   		}

   		if(documentsTodelete.size()>0){
   			system.debug(documentsTodelete);
   			Database.delete(documentsTodelete,false);
   		}
	
	}
	
	global void finish(Database.BatchableContext BC) {
	}	
	
}