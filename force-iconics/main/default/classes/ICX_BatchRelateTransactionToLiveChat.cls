/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class ICX_BatchRelateTransactionToLiveChat implements Database.Batchable<sObject> {
	
	public class DateFormatException extends Exception {}
	String query;
	
	//Non-parameterized constructor
	global ICX_BatchRelateTransactionToLiveChat() {
		query = 'SELECT Id,Transaction_Id__c,AccountId,SKU_Number__c,Purchased_Product__c,CreatedDate ' + 
		' FROM LiveChatTranscript WHERE Purchased_Product__c=null AND CreatedDate>=LAST_N_DAYS:7 AND Sku_Number__c != null AND ( Transaction_Id__c != null OR AccountId != null )';
	}

	//Constructor that takes a DateTime formated String
	global ICX_BatchRelateTransactionToLiveChat(String dateInputByUser) {

		// Check if the input date is in the correct format
		String dateTimeRegex = '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z';
		if (!Pattern.matches(dateTimeRegex, dateInputByUser)) {
			throw new DateFormatException('Invalid datetime format. Expected format is "YYYY-MM-DDTHH:mm:ssZ".');
		}

		query = 'SELECT Id,Transaction_Id__c,AccountId,SKU_Number__c,Purchased_Product__c,CreatedDate ' + 
		' FROM LiveChatTranscript WHERE Purchased_Product__c=null AND CreatedDate >= ' + dateInputByUser + ' AND Sku_Number__c != null AND ( Transaction_Id__c != null OR AccountId != null )';
	}

	//Constructor that takes 2 DateTime formated String as a start and end date
	global ICX_BatchRelateTransactionToLiveChat(String startDateInputByUser, String endDateInputByUser) {

		// Check if the input dates are in the correct format
		String dateTimeRegex = '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z';
		if (!Pattern.matches(dateTimeRegex, startDateInputByUser) || !Pattern.matches(dateTimeRegex, endDateInputByUser)) {
			throw new DateFormatException('Invalid datetime format. Expected format is "YYYY-MM-DDTHH:mm:ssZ".');
		}

		query = 'SELECT Id,Transaction_Id__c,AccountId,SKU_Number__c,Purchased_Product__c,CreatedDate ' + 
		' FROM LiveChatTranscript WHERE Purchased_Product__c=null AND CreatedDate >= ' + startDateInputByUser + ' AND CreatedDate < ' + endDateInputByUser + ' AND Sku_Number__c != null AND ( Transaction_Id__c != null OR AccountId != null )';
	}	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('#### query - ICX_BatchRelateTransactionToLiveChat: ' + query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		try{
            if(scope.size() > 0){
                this.setTransactions((List<LiveChatTranscript>) scope);
            }
            
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}

	private void setTransactions(List<LiveChatTranscript> liveChats) {
		Map<String,LiveChatTranscript> distantOrderLiveChatsMap = new Map<String,LiveChatTranscript>();
		Map<String,LiveChatTranscript> clientLiveChatsMap = new Map<String,LiveChatTranscript>();
		Set<Id> liveChatIds = new Set<Id>();
		Set<String> distantOrderNumbers = new Set<String>();
		Set<Id> clients = new Set<Id>();
		Set<String> skus = new Set<String>();

		Map<Id,PPR_PurchProduct__c> transactionMap = new Map<Id,PPR_PurchProduct__c>();
		List<LiveChatTranscript> liveChatsToUpdate = new List<LiveChatTranscript>();

		for(LiveChatTranscript liveChat : liveChats) {
		
			if(String.isNotBlank(liveChat.Transaction_Id__c) && String.isNotBlank(liveChat.Sku_Number__c)){
				String transactionId = liveChat.Transaction_Id__c.toLowerCase().trim();
				distantOrderLiveChatsMap.put(transactionId+liveChat.Sku_Number__c, liveChat);
				distantOrderNumbers.add(transactionId);
			}
			clientLiveChatsMap.put(liveChat.AccountId+liveChat.Sku_Number__c, liveChat);
			if(String.isNotBlank(liveChat.AccountId)) {
				clients.add(liveChat.AccountId);
			}
			if(String.isNotBlank(liveChat.Sku_Number__c)) {
				skus.add(liveChat.Sku_Number__c);
			}
		}

		List<PPR_PurchProduct__c> transactions = [SELECT Id,Client__c,SKU__c,PurchasedDate__c,TechTransactionId__c,RMSSKUCode__c,TransactionStoreType__c
		FROM PPR_PurchProduct__c
		WHERE Quantity__c>0 AND ((OrderATGId__c IN:distantOrderNumbers OR TransactionRMSId__c IN:distantOrderNumbers) OR Client__c IN:clients)
		AND (SKU__c IN:skus OR RMSSKUCode__c IN:skus) AND PurchasedDate__c>=LAST_N_DAYS:7 AND ICX_ContactChannel__c=null AND ICX_ContactChannel_RecordId__c=null
		AND ICX_CSCUser__c=null AND ICX_CSCContactDate__c=null  AND createdDate < TODAY AND TransactionStoreType__c in ('CSC','WEB', 'Store')];

		LiveChatTranscript currentLiveChat;
		Date currentLiveChatCreatedDate;

		for(PPR_PurchProduct__c t : transactions) {
			System.debug(t);

			//we can match the sku by the field RMSSKUCode__c or SKU__c that on the purchased product 
			string skuORrmssku='';
			if(distantOrderLiveChatsMap!=null && (distantOrderLiveChatsMap.containsKey(t.TechTransactionId__c+t.SKU__c)||distantOrderLiveChatsMap.containsKey(t.TechTransactionId__c+t.RMSSKUCode__c))) {

				skuORrmssku =  distantOrderLiveChatsMap.containskey(t.TechTransactionId__c+t.SKU__c) ? t.SKU__c :(distantOrderLiveChatsMap.containskey(t.TechTransactionId__c+t.RMSSKUCode__c) ? t.RMSSKUCode__c: '') ;

				if(!String.isBlank(skuORrmssku)){
					currentLiveChat = distantOrderLiveChatsMap.get(t.TechTransactionId__c+skuORrmssku);
					currentLiveChatCreatedDate = Date.newInstance(currentLiveChat.CreatedDate.year(), currentLiveChat.CreatedDate.month(), currentLiveChat.CreatedDate.day());
					if(t.PurchasedDate__c <= currentLiveChatCreatedDate.addDays(7) && t.PurchasedDate__c >= currentLiveChatCreatedDate) {
						currentLiveChat.Purchased_Product__c = t.Id;
						if(!liveChatIds.contains(currentLiveChat.Id)) {
							liveChatsToUpdate.add(currentLiveChat);
							liveChatIds.add(currentLiveChat.Id);
							distantOrderLiveChatsMap.remove(t.TechTransactionId__c+skuORrmssku);
						}
						if(clientLiveChatsMap!=null && clientLiveChatsMap.containsKey(t.Client__c+skuORrmssku)) {
							clientLiveChatsMap.remove(t.Client__c+skuORrmssku);
						}
					}
				}
			}
			else if(clientLiveChatsMap!=null && (clientLiveChatsMap.containsKey(t.Client__c+t.SKU__c)||clientLiveChatsMap.containsKey(t.Client__c+t.RMSSKUCode__c))) {

				skuORrmssku =  clientLiveChatsMap.containskey(t.Client__c+t.SKU__c) ? t.SKU__c :(clientLiveChatsMap.containskey(t.Client__c+t.RMSSKUCode__c) ? t.RMSSKUCode__c: '') ;

				
				if(!String.isBlank(skuORrmssku)){
					currentLiveChat = clientLiveChatsMap.get(t.Client__c+skuORrmssku);
					currentLiveChatCreatedDate = Date.newInstance(currentLiveChat.CreatedDate.year(), currentLiveChat.CreatedDate.month(), currentLiveChat.CreatedDate.day());
					if(t.PurchasedDate__c <= currentLiveChatCreatedDate.addDays(7) && t.PurchasedDate__c >= currentLiveChatCreatedDate) {
						currentLiveChat.Purchased_Product__c = t.Id;
						if(!liveChatIds.contains(currentLiveChat.Id)) {
							liveChatsToUpdate.add(currentLiveChat);
							liveChatIds.add(currentLiveChat.Id);
							clientLiveChatsMap.remove(t.Client__c+skuORrmssku);
						}
					}
				}
			}
		}


		if(liveChatsToUpdate.size() > 0) {
			update liveChatsToUpdate;
		}
	}
}