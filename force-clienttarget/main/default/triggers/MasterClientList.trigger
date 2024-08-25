trigger MasterClientList on CLI_CliList__c (after update, before delete) {
  switch on Trigger.operationType {
    when BEFORE_DELETE {
      ClientListTriggerHandler.handleBeforeDelete(Trigger.old);
    }
    when AFTER_UPDATE {
      ClientListTriggerHandler.handleAfterUpdate(Trigger.new);
    }
  }
}