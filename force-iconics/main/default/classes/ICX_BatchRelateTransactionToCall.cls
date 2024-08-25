/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class ICX_BatchRelateTransactionToCall implements Database.Batchable<sObject> {
	
	public class DateFormatException extends Exception {}
	String query;
	
	//Non-parameterized constructor
	global ICX_BatchRelateTransactionToCall() {
		Id CallRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Call').getRecordTypeId();

		query = 'SELECT Id,Transaction_Id__c,AccountId,Sku_Number__c,Purchased_Product__c,CreatedDate,CallType ' +
		        'FROM Task WHERE Purchased_Product__c=null AND CreatedDate>=LAST_N_DAYS:7 AND Sku_Number__c != null AND CallType in (\'Outbound\', \'Inbound\') AND ( Transaction_Id__c != null OR AccountId != null ) AND RecordTypeId = \'' + CallRecordTypeId + '\'' ;
	}

	//Constructor that takes a DateTime formated String as a start date
	global ICX_BatchRelateTransactionToCall(String dateInputByUser) {
		Id CallRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Call').getRecordTypeId();

		// // Date d;
		// DateTime dt;
		// try {
		// 	// d = Date.valueOf(dateInputByUser);
		// 	dt = DateTime.valueOf(dateInputByUser);
		// }
		// catch(TypeException e) {
		// 	// System.debug('Invalid date format. Please use the format YYYY-MM-DD');
		// 	System.debug('Invalid date format. Please use the format like 2023-02-12T08:42:41.333+02:00');
		// }
		// // String dateTimeFormatedInput = dateInputByUser + 'T00:00:00Z';
		// String dateTimeFormatedInput = dateInputByUser;

		// Check if the input date is in the correct format
		String dateTimeRegex = '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z';
		if (!Pattern.matches(dateTimeRegex, dateInputByUser)) {
			throw new DateFormatException('Invalid datetime format. Expected format is "YYYY-MM-DDTHH:mm:ssZ".');
		}
		
		query = 'SELECT Id,Transaction_Id__c,AccountId,Sku_Number__c,Purchased_Product__c,CreatedDate,CallType ' +
		        'FROM Task WHERE Purchased_Product__c=null AND CreatedDate >= ' + dateInputByUser + ' AND Sku_Number__c != null AND CallType in (\'Outbound\', \'Inbound\') AND ( Transaction_Id__c != null OR AccountId != null ) AND RecordTypeId = \'' + CallRecordTypeId + '\'' ;
	}

	//Constructor that takes 2 DateTime formated String as a start and end date
	global ICX_BatchRelateTransactionToCall(String startDateInputByUser, String endDateInputByUser) {
		Id CallRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Call').getRecordTypeId();

		// // Date d;
		// DateTime startDt;
		// DateTime endDt;
		// try {
		// 	// d = Date.valueOf(dateInputByUser);
		// 	startDt = DateTime.valueOf(startDateInputByUser);
		// 	endDt = DateTime.valueOf(endDateInputByUser);
		// }
		// catch(TypeException e) {
		// 	// System.debug('Invalid date format. Please use the format YYYY-MM-DD');
		// 	System.debug('Invalid date format. Please use the format like 2023-02-12T08:42:41.333+02:00');
		// }
		// String dateTimeFormatedInput = dateInputByUser + 'T00:00:00Z';
		// String dateTimeFormatedInput = dateInputByUser;

		// Check if the input dates are in the correct format
		String dateTimeRegex = '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z';
		if (!Pattern.matches(dateTimeRegex, startDateInputByUser) || !Pattern.matches(dateTimeRegex, endDateInputByUser)) {
			throw new DateFormatException('Invalid datetime format. Expected format is "YYYY-MM-DDTHH:mm:ssZ".');
		}
		
		query = 'SELECT Id,Transaction_Id__c,AccountId,Sku_Number__c,Purchased_Product__c,CreatedDate,CallType ' +
				'FROM Task WHERE Purchased_Product__c=null AND CreatedDate >= ' + startDateInputByUser + ' AND CreatedDate < ' + endDateInputByUser + 
				' AND Sku_Number__c != null AND CallType in (\'Outbound\', \'Inbound\') AND ( Transaction_Id__c != null OR AccountId != null ) AND RecordTypeId = \'' + CallRecordTypeId + '\'' ;
	}
	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		try{
            if(scope.size() > 0){
                this.setTransactions((List<Task>) scope);
            }
            
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}

	private void setTransactions(List<Task> calls) {
		Map<String,Task> distantOrderCallsMap = new Map<String,Task>();
		Map<String,Task> clientCallsMap = new Map<String,Task>();
		Set<Id> callIds = new Set<Id>();
		Set<String> distantOrderNumbers = new Set<String>();
		Set<Id> clients = new Set<Id>();
		Set<String> skus = new Set<String>();

		Map<Id,PPR_PurchProduct__c> transactionMap = new Map<Id,PPR_PurchProduct__c>();
		List<Task> callsToUpdate = new List<Task>();

		for(Task call : calls) {
			if(String.isNotBlank(call.Transaction_Id__c)&& String.isNotBlank(call.Sku_Number__c)) {
				String transactionId = call.Transaction_Id__c.toLowerCase().trim();
				distantOrderCallsMap.put(transactionId+call.Sku_Number__c, call);
				distantOrderNumbers.add(transactionId);
			}
			clientCallsMap.put(call.AccountId+call.Sku_Number__c, call);
			if(String.isNotBlank(call.AccountId)) {
				clients.add(call.AccountId);
			}
			if(String.isNotBlank(call.Sku_Number__c)) {
				skus.add(call.Sku_Number__c);
			}
		} 

		List<PPR_PurchProduct__c> transactions = [SELECT Id,Client__c,SKU__c,PurchasedDate__c,TechTransactionId__c,RMSSKUCode__c
		FROM PPR_PurchProduct__c
		WHERE Quantity__c >0 AND ((OrderATGId__c IN:distantOrderNumbers OR TransactionRMSId__c IN:distantOrderNumbers) OR Client__c IN:clients) 
		AND (SKU__c IN:skus OR RMSSKUCode__c IN:skus) AND PurchasedDate__c>=LAST_N_DAYS:7 AND ICX_ContactChannel__c=null AND ICX_ContactChannel_RecordId__c=null
		AND ICX_CSCUser__c=null AND ICX_CSCContactDate__c=null AND createdDate < TODAY AND TransactionStoreType__c in ('CSC','WEB', 'Store')] ;

		system.debug('DISTANT ORDER CALL MAP');

		system.debug(distantOrderCallsMap);
		system.debug(transactions);


		Task currentCall;
		Date currentCallCreatedDate;

		for(PPR_PurchProduct__c t : transactions) {
			string skuORrmssku = '';
			system.debug('DISTANT ORDER CALL MAP');

			system.debug(distantOrderCallsMap);

			if(distantOrderCallsMap!=null && (distantOrderCallsMap.containsKey(t.TechTransactionId__c+t.SKU__c)||distantOrderCallsMap.containsKey(t.TechTransactionId__c+t.RMSSKUCode__c))) {

				skuORrmssku =  distantOrderCallsMap.containskey(t.TechTransactionId__c+t.SKU__c) ? t.SKU__c :(distantOrderCallsMap.containskey(t.TechTransactionId__c+t.RMSSKUCode__c) ? t.RMSSKUCode__c: '') ;
				system.debug(skuORrmssku);

				if(!String.isBlank(skuORrmssku)){
					currentCall = distantOrderCallsMap.get(t.TechTransactionId__c+skuORrmssku);
					currentCallCreatedDate = Date.newInstance(currentCall.CreatedDate.year(), currentCall.CreatedDate.month(), currentCall.CreatedDate.day());

					if(t.PurchasedDate__c <= currentCallCreatedDate.addDays(7) && t.PurchasedDate__c >= currentCallCreatedDate){
						currentCall.Purchased_Product__c = t.Id;
						if(!callIds.contains(currentCall.Id)) {
							callsToUpdate.add(currentCall);
							callIds.add(currentCall.Id);
							distantOrderCallsMap.remove(t.TechTransactionId__c+skuORrmssku);
						}
						if(clientCallsMap != null && clientCallsMap.containsKey(t.Client__c+skuORrmssku)) {
							clientCallsMap.remove(t.Client__c+skuORrmssku);
						}
					}
				}
			}
			else if (clientCallsMap != null && (clientCallsMap.containsKey(t.Client__c+t.SKU__c)||clientCallsMap.containsKey(t.Client__c+t.RMSSKUCode__c))) {
				skuORrmssku =  clientCallsMap.containskey(t.Client__c+t.SKU__c) ? t.SKU__c :(clientCallsMap.containskey(t.Client__c+t.RMSSKUCode__c) ? t.RMSSKUCode__c: '') ;

				if(!String.isBlank(skuORrmssku)){
					currentCall = clientCallsMap.get(t.Client__c+skuORrmssku);
					currentCallCreatedDate = Date.newInstance(currentCall.CreatedDate.year(), currentCall.CreatedDate.month(), currentCall.CreatedDate.day());
					
					if(t.PurchasedDate__c <= currentCallCreatedDate.addDays(7) && t.PurchasedDate__c >= currentCallCreatedDate) {
						currentCall.Purchased_Product__c = t.Id;
						if(!callIds.contains(currentCall.Id)) {
							callsToUpdate.add(currentCall);
							callIds.add(currentCall.Id);
							clientCallsMap.remove(t.Client__c+skuORrmssku);
						}
					}
				}


			}
		}

		System.debug(LoggingLevel.ERROR, 'callsToUpdate=' + callsToUpdate);

		if(callsToUpdate.size() > 0) {
			update callsToUpdate;
		}
	}
}