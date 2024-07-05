/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
// public with sharing class ICX_BatchRelateTransactionToAppointment {
//     public ICX_BatchRelateTransactionToAppointment() {

//     }
// }


///////////////////////////////////////////////////////////////////////////////////////////
global class ICX_BatchRelateTransactionToAppointment implements Database.Batchable<sObject> {
	
	public class DateFormatException extends Exception {}
	String query;
	
	//Non-parameterized constructor
	global ICX_BatchRelateTransactionToAppointment() {
        query = 'SELECT Id, AccountId, CreatedDate ' + 
				'FROM Event WHERE AccountId != null AND CreatedBy.Profile.Name IN (\'ICONiCS_SA\', \'ICONiCS_SA_Manager\', \'ICONiCS_Corporate\', \'System Administrator\') ' + 
				'AND CreatedDate >= LAST_N_DAYS:10 AND Purchased_Product__c = null ORDER BY CreatedDate ASC';
	}

	//Constructor that takes a DateTime formated String
	global ICX_BatchRelateTransactionToAppointment(String dateInputByUser) {

		// Check if the input date is in the correct format
		String dateTimeRegex = '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z';
		if (!Pattern.matches(dateTimeRegex, dateInputByUser)) {
			throw new DateFormatException('Invalid datetime format. Expected format is "YYYY-MM-DDTHH:mm:ssZ".');
		}

        query = 'SELECT Id, AccountId, CreatedDate ' + 
				'FROM Event WHERE AccountId != null AND CreatedBy.Profile.Name IN (\'ICONiCS_SA\', \'ICONiCS_SA_Manager\', \'ICONiCS_Corporate\', \'System Administrator\') ' + 
				'AND CreatedDate >= ' + dateInputByUser + ' AND Purchased_Product__c = null ORDER BY CreatedDate ASC';
	}

	//Constructor that takes 2 DateTime formated String as a start and end date
	global ICX_BatchRelateTransactionToAppointment(String startDateInputByUser, String endDateInputByUser) {

		// Check if the input dates are in the correct format
		String dateTimeRegex = '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z';
		if (!Pattern.matches(dateTimeRegex, startDateInputByUser) || !Pattern.matches(dateTimeRegex, endDateInputByUser)) {
			throw new DateFormatException('Invalid datetime format. Expected format is "YYYY-MM-DDTHH:mm:ssZ".');
		}

		query = 'SELECT Id, AccountId, CreatedDate ' + 
				'FROM Event WHERE AccountId != null AND CreatedBy.Profile.Name IN (\'ICONiCS_SA\', \'ICONiCS_SA_Manager\', \'ICONiCS_Corporate\', \'System Administrator\') ' + 
				'AND CreatedDate >= ' + startDateInputByUser + ' AND CreatedDate < ' + endDateInputByUser + ' AND Purchased_Product__c = null ORDER BY CreatedDate ASC';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		try {
            if(scope.size() > 0){
                this.setTransactions((List<Event>) scope);
            }
        } catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
	}
	
	global void finish(Database.BatchableContext BC) {}

	private void setTransactions(List<Event> events) {
		 Set<Id> eventIds = new Set<Id>();
		 Set<Id> clients = new Set<Id>();
		 List<Event> eventsToUpdate = new List<Event>();
		 Map<String,Event> clientEventsMap = new Map<String,Event>();

		 for(Event event : events) {
		 	if(event.AccountId != null && String.valueOf(event.AccountId) != '' && !clients.contains(event.AccountId) ) {
				 clients.add(event.AccountId);
				 clientEventsMap.put(Event.AccountId, Event);
			}
		 }

		List<PPR_PurchProduct__c> transactions = [SELECT Id,Client__c,PurchasedDate__c
		FROM PPR_PurchProduct__c
		WHERE Quantity__c > 0 AND Client__c IN:clients AND TransactionStoreType__c in ('CSC','WEB', 'Store')
		AND PurchasedDate__c >= LAST_N_DAYS:10 AND ICX_ContactChannel__c = null AND ICX_ContactChannel_RecordId__c = null
		AND ICX_CSCUser__c = null AND ICX_CSCContactDate__c = null AND createdDate < TODAY ORDER BY CreatedDate ASC];

		Event currentEvent;
		Date currentEventCreatedDate;

		for(PPR_PurchProduct__c t : transactions) {
			if (clients != null && clients.contains(t.Client__c) && clientEventsMap.get(t.Client__c) != null) {
				currentEvent = clientEventsMap.get(t.Client__c);

				currentEventCreatedDate = Date.newInstance(currentEvent.CreatedDate.year(), currentEvent.CreatedDate.month(), currentEvent.CreatedDate.day());

				if(t.PurchasedDate__c <= currentEventCreatedDate.addDays(10) && t.PurchasedDate__c >= currentEventCreatedDate) {
					currentEvent.Purchased_Product__c = t.Id;
					// t.TransactionRMSId__c ? currentEvent.RelatedTicketNumber__c = t.TransactionRMSId__c : false;
					// t.Amount__c ? currentEvent.SaleAmount__c = t.Amount__c : false;
					// t.CurrencyCode__c ? currentEvent.Currency__c = t.CurrencyCode__c : false;
					// t.ConvertedAmountEUR__c ? currentEvent.Transaction_Total_Converted_Amount_EUR__c = t.ConvertedAmountEUR__c : false;

					if(!eventIds.contains(currentEvent.Id)) {
						eventsToUpdate.add(currentEvent);
						eventIds.add(currentEvent.Id);
						clientEventsMap.remove(t.Client__c);
					}
				}
			}
		}

		System.debug(LoggingLevel.ERROR, 'eventsToUpdate=' + eventsToUpdate);

		if(eventsToUpdate.size() > 0) {
			update eventsToUpdate;
		}
	}
}