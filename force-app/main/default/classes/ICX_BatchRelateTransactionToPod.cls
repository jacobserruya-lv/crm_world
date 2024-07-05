/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class ICX_BatchRelateTransactionToPod implements Database.Batchable<sObject> {
	
	public class DateFormatException extends Exception {}
	String query;

	//Non-parameterized constructor
	global ICX_BatchRelateTransactionToPod() {

		Id podRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Product_On_Demand_with_sku').getRecordTypeId();
		query = 'SELECT Id,Transaction_Id__c,PurchasedProduct__c,AccountId,Sku_Number__c,Store__r.RetailStoreId__c,CreatedDate ' +
			' FROM Case WHERE RecordTypeId=\'' + podRecordTypeId +'\' AND PurchasedProduct__c=null AND CreatedDate >= LAST_N_MONTHS:8';
	}
	
	//Constructor that takes a DateTime formated String
	global ICX_BatchRelateTransactionToPod(String dateInputByUser) {

		// Check if the input date is in the correct format
		String dateTimeRegex = '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z';
		if (!Pattern.matches(dateTimeRegex, dateInputByUser)) {
			throw new DateFormatException('Invalid datetime format. Expected format is "YYYY-MM-DDTHH:mm:ssZ".');
		}

		Id podRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Product_On_Demand_with_sku').getRecordTypeId();
		query = 'SELECT Id,Transaction_Id__c,PurchasedProduct__c,AccountId,Sku_Number__c,Store__r.RetailStoreId__c,CreatedDate ' +
			' FROM Case WHERE RecordTypeId=\'' + podRecordTypeId +'\' AND PurchasedProduct__c=null AND CreatedDate >= ' + dateInputByUser;
	}

	//Constructor that takes 2 DateTime formated String as a start and end date
	global ICX_BatchRelateTransactionToPod(String startDateInputByUser, String endDateInputByUser) {

		// Check if the input dates are in the correct format
		String dateTimeRegex = '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z';
		if (!Pattern.matches(dateTimeRegex, startDateInputByUser) || !Pattern.matches(dateTimeRegex, endDateInputByUser)) {
			throw new DateFormatException('Invalid datetime format. Expected format is "YYYY-MM-DDTHH:mm:ssZ".');
		}

		Id podRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Product_On_Demand_with_sku').getRecordTypeId();
		query = 'SELECT Id,Transaction_Id__c,PurchasedProduct__c,AccountId,Sku_Number__c,Store__r.RetailStoreId__c,CreatedDate ' +
			' FROM Case WHERE RecordTypeId=\'' + podRecordTypeId +'\' AND PurchasedProduct__c=null AND CreatedDate >= ' + startDateInputByUser + ' AND CreatedDate < ' + endDateInputByUser;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('#### START - ICX_BatchRelateTransactionToPod');
        System.debug('#### query : ' + query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		try{
            if(scope.size() > 0){
                this.setTransactions((List<Case>) scope);
            }
            
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}

	private void setTransactions(List<Case> cases) {
		Map<String,Case> distantOrderCasesMap = new Map<String,Case>();
		Map<String,Case> clientCasesMap = new Map<String,Case>();
		Set<Id> casesId = new Set<Id>();
		Set<String> distantOrderNumbers = new Set<String>();
		Set<Id> clients = new Set<Id>();
		Set<String> skus = new Set<String>();
		Set<String> storeCodes = new Set<String>();

		Map<Id,PPR_PurchProduct__c> transactionMap = new Map<Id,PPR_PurchProduct__c>();
		List<Case> casesToUpdate = new List<Case>();

		for(Case c : cases){
			
			if(String.isNotBlank(c.Transaction_Id__c) && String.isNotBlank(c.Sku_Number__c)){ 
				String transactionId = c.Transaction_Id__c.toLowerCase().trim();
				distantOrderCasesMap.put(transactionId+c.Sku_Number__c, c); 
				distantOrderNumbers.add(transactionId);
			}
			clientCasesMap.put(c.AccountId+c.Sku_Number__c+c.Store__r.RetailStoreId__c, c); 
			if( String.isNotBlank(c.AccountId)) {
				clients.add(c.AccountId);
			}
			if(String.isNotBlank(c.Sku_Number__c)) {
				skus.add(c.Sku_Number__c);
			}
			if(String.isNotBlank(c.Store__r.RetailStoreId__c)) {
				storeCodes.add(c.Store__r.RetailStoreId__c);
			}
		}
			
		List<PPR_PurchProduct__c> transactions = [SELECT Id,Client__c,SKU__c,RMSSKUCode__c,Store__c,PurchasedDate__c,TechTransactionId__c,OrderATGId__c
		FROM PPR_PurchProduct__c
		WHERE Quantity__c >0 AND ((OrderATGId__c IN:distantOrderNumbers OR TransactionRMSId__c IN:distantOrderNumbers) OR (Client__c IN:clients AND Store__c IN:storeCodes)) 
		AND  (SKU__c IN:skus OR RMSSKUCode__c IN:skus)  AND PurchasedDate__c>=LAST_N_MONTHS:8 AND ICX_ContactChannel__c=null AND ICX_ContactChannel_RecordId__c=null
		AND ICX_CSCUser__c=null AND ICX_CSCContactDate__c=null ];
		Case currentCase;
       
		for(PPR_PurchProduct__c t : transactions) {
			string skuORrmssku = '';
			if(distantOrderCasesMap != null && (distantOrderCasesMap.containsKey(t.TechTransactionId__c+t.SKU__c)||distantOrderCasesMap.containsKey(t.TechTransactionId__c+t.RMSSKUCode__c))){
	
				skuORrmssku =  distantOrderCasesMap.containskey(t.TechTransactionId__c+t.SKU__c) ? t.SKU__c :(distantOrderCasesMap.containskey(t.TechTransactionId__c+t.RMSSKUCode__c) ? t.RMSSKUCode__c: '') ;

				if(String.isNotBlank(skuORrmssku)){
					currentCase = distantOrderCasesMap.get(t.TechTransactionId__c+skuORrmssku);
					if(t.PurchasedDate__c <= currentCase.CreatedDate.addMonths(8).date() && t.PurchasedDate__c >= currentCase.CreatedDate.date()) {
						currentCase.PurchasedProduct__c = t.Id;
						if(!casesId.contains(currentCase.Id)){
							casesToUpdate.add(currentCase);
							casesId.add(currentCase.Id);
							distantOrderCasesMap.remove(t.TechTransactionId__c+skuORrmssku);
						}
						if (clientCasesMap != null && clientCasesMap.containskey(t.Client__c+skuORrmssku+t.Store__c)) {
							clientCasesMap.remove(t.Client__c+skuORrmssku+t.Store__c);
						}
					}
				}			
			}
			else if (clientCasesMap != null ){
				
				skuORrmssku =  clientCasesMap.containskey(t.Client__c+t.SKU__c+t.Store__c) ? t.SKU__c :(clientCasesMap.containskey(t.Client__c+t.RMSSKUCode__c+t.Store__c) ? t.RMSSKUCode__c: '') ;

				if(String.isNotBlank(skuORrmssku)){
					currentCase = clientCasesMap.get(t.Client__c+skuORrmssku+t.Store__c);
					if(t.PurchasedDate__c <= currentCase.CreatedDate.addMonths(8).date() && t.PurchasedDate__c >= currentCase.CreatedDate.date()) {
						currentCase.PurchasedProduct__c = t.Id;
						if(!casesId.contains(currentCase.Id)) {
							casesToUpdate.add(currentCase);
							casesId.add(currentCase.Id);
							clientCasesMap.remove(t.Client__c+skuORrmssku+t.Store__c);
						}
					}
				}
			}
		}
        System.debug(LoggingLevel.ERROR, 'casesToUpdate=' + casesToUpdate);

		if(casesToUpdate.size() > 0){
			update casesToUpdate;
		}
	}
}