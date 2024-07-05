/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class ICX_BatchRelateTransactionToCase implements Database.Batchable<sObject> {
	
	public class DateFormatException extends Exception {}
	String query;
	
	//Non-parameterized constructor
	global ICX_BatchRelateTransactionToCase() {
	
		List<String> ListOfCaseRecordTypesId= new list<String>{
		'\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call_Case').getRecordTypeId() +'\'',
		'\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Web_Email_Case').getRecordTypeId()+'\''
		};
		query = 'SELECT Id,Transaction_Id__c,PurchasedProduct__c,AccountId,Sku_Number__c,CreatedDate ' +
			' FROM Case WHERE PurchasedProduct__c = null AND CreatedDate>=LAST_N_DAYS:7 AND Sku_Number__c != null AND ( Transaction_Id__c != null OR AccountId != null ) AND RecordTypeId IN'+ ListOfCaseRecordTypesId ;
	}

	//Constructor that takes a DateTime formated String
	global ICX_BatchRelateTransactionToCase(String dateInputByUser) {

		// Check if the input date is in the correct format
		String dateTimeRegex = '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z';
		if (!Pattern.matches(dateTimeRegex, dateInputByUser)) {
			throw new DateFormatException('Invalid datetime format. Expected format is "YYYY-MM-DDTHH:mm:ssZ".');
		}
	
		List<String> ListOfCaseRecordTypesId= new list<String>{
		'\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call_Case').getRecordTypeId() +'\'',
		'\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Web_Email_Case').getRecordTypeId()+'\''
		};
		query = 'SELECT Id,Transaction_Id__c,PurchasedProduct__c,AccountId,Sku_Number__c,CreatedDate ' +
			' FROM Case WHERE PurchasedProduct__c = null AND CreatedDate >= ' + dateInputByUser + ' AND Sku_Number__c != null AND ( Transaction_Id__c != null OR AccountId != null ) AND RecordTypeId IN'+ ListOfCaseRecordTypesId ;
	}

	//Constructor that takes 2 DateTime formated String as a start and end date
	global ICX_BatchRelateTransactionToCase(String startDateInputByUser, String endDateInputByUser) {

		// Check if the input dates are in the correct format
		String dateTimeRegex = '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z';
		if (!Pattern.matches(dateTimeRegex, startDateInputByUser) || !Pattern.matches(dateTimeRegex, endDateInputByUser)) {
			throw new DateFormatException('Invalid datetime format. Expected format is "YYYY-MM-DDTHH:mm:ssZ".');
		}
	
		List<String> ListOfCaseRecordTypesId= new list<String>{
		'\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call_Case').getRecordTypeId() +'\'',
		'\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Web_Email_Case').getRecordTypeId()+'\''
		};
		query = 'SELECT Id,Transaction_Id__c,PurchasedProduct__c,AccountId,Sku_Number__c,CreatedDate ' +
			' FROM Case WHERE PurchasedProduct__c = null AND CreatedDate >= ' + startDateInputByUser + ' AND CreatedDate < ' + endDateInputByUser + ' AND Sku_Number__c != null AND ( Transaction_Id__c != null OR AccountId != null ) AND RecordTypeId IN'+ ListOfCaseRecordTypesId ;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('#### query - ICX_BatchRelateTransactionToCase: ' + query);
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
		Set<Id> caseIds = new Set<Id>();
		Set<String> distantOrderNumbers = new Set<String>();
		Set<Id> clients = new Set<Id>();
		Set<String> skus = new Set<String>();

		Map<Id,PPR_PurchProduct__c> transactionMap = new Map<Id,PPR_PurchProduct__c>();
		List<Case> casesToUpdate = new List<Case>();

		for(Case c : cases) {
			
			if(String.isNotBlank(c.Transaction_Id__c) && String.isNotBlank(c.Sku_Number__c)) {
				String transactionId = c.Transaction_Id__c.toLowerCase().trim();
				distantOrderCasesMap.put(transactionId+c.Sku_Number__c, c);
				distantOrderNumbers.add(transactionId);
			}
			clientCasesMap.put(c.AccountId+c.Sku_Number__c, c);
			if(String.isNotBlank(c.AccountId) ) {
				clients.add(c.AccountId);
			}
			if(String.isNotBlank(c.Sku_Number__c)) {
				skus.add(c.Sku_Number__c);
			}
		}

		List<PPR_PurchProduct__c> transactions = [SELECT Id,Client__c,SKU__c,RMSSKUCode__c,PurchasedDate__c,TechTransactionId__c
		FROM PPR_PurchProduct__c
		WHERE Quantity__c>0 AND ((OrderATGId__c IN:distantOrderNumbers OR TransactionRMSId__c IN:distantOrderNumbers) OR Client__c IN:clients)
		AND (SKU__c IN:skus OR RMSSKUCode__c IN:skus) AND PurchasedDate__c>=LAST_N_DAYS:7 AND ICX_ContactChannel__c=null AND ICX_ContactChannel_RecordId__c=null
		AND ICX_CSCUser__c=null AND ICX_CSCContactDate__c=null  AND createdDate < TODAY AND TransactionStoreType__c in ('CSC','WEB', 'Store')];
		Case currentCase;
		Date currentCaseCreatedDate;

		for(PPR_PurchProduct__c t : transactions) {
			string skuORrmssku='';
			if(distantOrderCasesMap!=null && (distantOrderCasesMap.containsKey(t.TechTransactionId__c+t.SKU__c)||distantOrderCasesMap.containsKey(t.TechTransactionId__c+t.RMSSKUCode__c))) {

				skuORrmssku =  distantOrderCasesMap.containskey(t.TechTransactionId__c+t.SKU__c) ? t.SKU__c :(distantOrderCasesMap.containskey(t.TechTransactionId__c+t.RMSSKUCode__c) ? t.RMSSKUCode__c: '') ;

				if(!String.isBlank(skuORrmssku)){
					currentCase = distantOrderCasesMap.get(t.TechTransactionId__c+skuORrmssku);
					currentCaseCreatedDate = Date.newInstance(currentCase.CreatedDate.year(), currentCase.CreatedDate.month(), currentCase.CreatedDate.day());
					if(t.PurchasedDate__c <= currentCaseCreatedDate.addDays(7) && t.PurchasedDate__c >= currentCaseCreatedDate) {
						currentCase.PurchasedProduct__c = t.Id;
						if(!caseIds.contains(currentCase.Id)) {
							casesToUpdate.add(currentCase);
							caseIds.add(currentCase.Id);
							distantOrderCasesMap.remove(t.TechTransactionId__c+skuORrmssku);
						}
						if(clientCasesMap!=null && clientCasesMap.containsKey(t.Client__c+skuORrmssku)) {
							clientCasesMap.remove(t.Client__c+skuORrmssku);
						}
					}
				}
			}
			else if(clientCasesMap!=null && (clientCasesMap.containsKey(t.Client__c+t.SKU__c)||clientCasesMap.containsKey(t.Client__c+t.RMSSKUCode__c))) {

				skuORrmssku =  clientCasesMap.containskey(t.Client__c+t.SKU__c) ? t.SKU__c :(clientCasesMap.containskey(t.Client__c+t.RMSSKUCode__c) ? t.RMSSKUCode__c: '') ;
	
				if(!String.isBlank(skuORrmssku)){
					currentCase = clientCasesMap.get(t.Client__c+skuORrmssku);
					currentCaseCreatedDate = Date.newInstance(currentCase.CreatedDate.year(), currentCase.CreatedDate.month(), currentCase.CreatedDate.day());

					if(t.PurchasedDate__c <= currentCaseCreatedDate.addDays(7) && t.PurchasedDate__c >= currentCaseCreatedDate) {
						currentCase.PurchasedProduct__c = t.Id;
						if(!caseIds.contains(currentCase.Id)){
							casesToUpdate.add(currentCase);
							caseIds.add(currentCase.Id);
							clientCasesMap.remove(t.Client__c+skuORrmssku);
						}
					}
				}
			}
		}

		if(casesToUpdate.size() > 0) {
			update casesToUpdate;
		}
	}
}