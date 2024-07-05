global class IC_BatchClientListMemberDuplicateDelete implements Database.Batchable<sObject> {
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
    system.debug('************** Batch START **************');
    String query = 'SELECT Id FROM CLM_CliListMember__c WHERE TECH_External_Id__c = null';
    System.debug(query);
    return  Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    if ( scope!= null && scope.size() > 0 ){
      system.debug('************** Duplicate(s) to delete : ' + scope.size());
      Database.DeleteResult[] drList = database.delete(scope);
      for(Database.DeleteResult dr : drList) {
        if (dr.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('Successfully deleted ClientListMember with ID: ' + dr.getId());
        }
        else {
          // Operation failed, so get all errors                
          for(Database.Error err : dr.getErrors()) {
              System.debug('The following error has occurred.');                    
              System.debug(err.getStatusCode() + ': ' + err.getMessage());
              System.debug('ClientListMember fields that affected this error: ' + err.getFields());
          }
        }
      }
    }
  }
  
  global void finish(Database.BatchableContext BC) {
    system.debug('************** Batch END **************');
  }
}