trigger ProductCatalog on ProductCatalogue__c (after update) {
    if (Trigger.isAfter) {
	    	if (Trigger.isUpdate) {
     ProductCatalogTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            }
    }

}