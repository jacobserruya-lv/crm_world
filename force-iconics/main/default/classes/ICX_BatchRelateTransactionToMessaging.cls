/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class ICX_BatchRelateTransactionToMessaging implements Database.Batchable<sObject> { 
    
	public class DateFormatException extends Exception {}
	String query;

	//Non-parameterized constructor
	global ICX_BatchRelateTransactionToMessaging() {
		query = 'SELECT ID ,name,Purchased_Product__c,AcceptTime,Sku_Number__c, Product_SKU__c,Product_SKU__r.SKU__c,EndUserAccountId,CreatedDate,Transaction_Id__c ' +
            'FROM MessagingSession ' + 
            'WHERE  Purchased_Product__c = null and Product_SKU__c != null and (Transaction_Id__c!= null OR EndUserAccountId != null) and AcceptTime>=LAST_N_DAYS:7';
	}

	//Constructor that takes a DateTime formated String
	global ICX_BatchRelateTransactionToMessaging(String dateInputByUser) {

		// Check if the input date is in the correct format
		String dateTimeRegex = '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z';
		if (!Pattern.matches(dateTimeRegex, dateInputByUser)) {
			throw new DateFormatException('Invalid datetime format. Expected format is "YYYY-MM-DDTHH:mm:ssZ".');
		}

		query = 'SELECT ID ,name,Purchased_Product__c,AcceptTime,Sku_Number__c, Product_SKU__c,Product_SKU__r.SKU__c,EndUserAccountId,CreatedDate,Transaction_Id__c ' +
			'FROM MessagingSession ' + 
			'WHERE  Purchased_Product__c = null and Product_SKU__c != null and (Transaction_Id__c!= null OR EndUserAccountId != null) and AcceptTime >= ' + dateInputByUser;
	}

	//Constructor that takes 2 DateTime formated String as a start and end date
	global ICX_BatchRelateTransactionToMessaging(String startDateInputByUser, String endDateInputByUser) {

		// Check if the input dates are in the correct format
		String dateTimeRegex = '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z';
		if (!Pattern.matches(dateTimeRegex, startDateInputByUser) || !Pattern.matches(dateTimeRegex, endDateInputByUser)) {
			throw new DateFormatException('Invalid datetime format. Expected format is "YYYY-MM-DDTHH:mm:ssZ".');
		}

		query = 'SELECT ID ,name,Purchased_Product__c,AcceptTime,Sku_Number__c, Product_SKU__c,Product_SKU__r.SKU__c,EndUserAccountId,CreatedDate,Transaction_Id__c ' +
			'FROM MessagingSession ' + 
			'WHERE  Purchased_Product__c = null and Product_SKU__c != null and (Transaction_Id__c!= null OR EndUserAccountId != null) AND CreatedDate >= ' + startDateInputByUser + ' AND CreatedDate < ' + endDateInputByUser;
	}

	global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext bc, List<MessagingSession> records){


        Map<String,MessagingSession> distantOrderMessagingMap = new Map<String,MessagingSession>();
		Map<String,MessagingSession> clientMessagingsMap = new Map<String,MessagingSession>();
		Set<Id> MessagingIds = new Set<Id>();
		Set<String> distantOrderNumbers = new Set<String>();
        Set<Id> accountIdList = new set<Id> ();        
        Set<String> skuList = new set<String> ();
        List<MessagingSession> ListToUpdate = new List<MessagingSession>();


        for(MessagingSession msg : records) {
			if( String.isNotBlank(msg.Transaction_Id__c) && String.isNotBlank(msg.Sku_Number__c)) {
				String transactionId = msg.Transaction_Id__c.toLowerCase().trim();
				distantOrderMessagingMap.put(transactionId+msg.Sku_Number__c, msg);
				distantOrderNumbers.add(transactionId);
            }	
            if(String.isNotBlank(msg.EndUserAccountId)) {
			    clientMessagingsMap.put(msg.EndUserAccountId+msg.Sku_Number__c, msg);
                accountIdList.add(msg.EndUserAccountId);
			}
			if(String.isNotBlank(msg.Sku_Number__c)) {
				skuList.add(msg.Sku_Number__c);
			}
		}

       
        List<PPR_PurchProduct__c> purchasedProductList = [SELECT Id,Client__c,SKU__c,PurchasedDate__c,TechTransactionId__c,RMSSKUCode__c,TransactionRMSId__c
		FROM PPR_PurchProduct__c
		WHERE Quantity__c > 0 AND ((OrderATGId__c IN:distantOrderNumbers OR TransactionRMSId__c IN:distantOrderNumbers) OR Client__c IN:accountIdList)
		AND (SKU__c IN:skuList OR RMSSKUCode__c IN:skuList) AND PurchasedDate__c >= LAST_N_DAYS:7 AND ICX_ContactChannel__c = null AND ICX_ContactChannel_RecordId__c = null
        AND ICX_CSCUser__c = null AND ICX_CSCContactDate__c = null  AND createdDate < TODAY AND TransactionStoreType__c in ('CSC','WEB', 'Store')];

        MessagingSession currentMsg;
		Date currentMsgCreatedDate;
        
        for (PPR_PurchProduct__c t: purchasedProductList){
            string skuORrmssku = '';
			if(distantOrderMessagingMap != null && (distantOrderMessagingMap.containsKey(t.TechTransactionId__c+t.SKU__c)||distantOrderMessagingMap.containsKey(t.TechTransactionId__c+t.RMSSKUCode__c))) {

				skuORrmssku =  distantOrderMessagingMap.containskey(t.TechTransactionId__c+t.SKU__c) ? t.SKU__c :(distantOrderMessagingMap.containskey(t.TechTransactionId__c+t.RMSSKUCode__c) ? t.RMSSKUCode__c: '') ;

				if(!String.isBlank(skuORrmssku)){
					currentMsg = distantOrderMessagingMap.get(t.TechTransactionId__c+skuORrmssku);
					currentMsgCreatedDate = Date.newInstance(currentMsg.CreatedDate.year(), currentMsg.CreatedDate.month(), currentMsg.CreatedDate.day());
					if(t.PurchasedDate__c <= currentMsgCreatedDate.addDays(7) && t.PurchasedDate__c >= currentMsgCreatedDate) {
						currentMsg.Purchased_Product__c = t.Id;
						if(!MessagingIds.contains(currentMsg.Id)) {
							ListToUpdate.add(currentMsg);
							MessagingIds.add(currentMsg.Id);
							distantOrderMessagingMap.remove(t.TechTransactionId__c+skuORrmssku);
						}
						if(clientMessagingsMap!=null && clientMessagingsMap.containsKey(t.Client__c+skuORrmssku)) {
							distantOrderMessagingMap.remove(t.Client__c+skuORrmssku);
						}
					}
                }
            }else if(clientMessagingsMap!=null && (clientMessagingsMap.containsKey(t.Client__c+t.SKU__c)||clientMessagingsMap.containsKey(t.Client__c+t.RMSSKUCode__c))) {

				skuORrmssku =  clientMessagingsMap.containskey(t.Client__c+t.SKU__c) ? t.SKU__c :(clientMessagingsMap.containskey(t.Client__c+t.RMSSKUCode__c) ? t.RMSSKUCode__c: '') ;
               
				if(!String.isBlank(skuORrmssku)){
					currentMsg = clientMessagingsMap.get(t.Client__c+skuORrmssku);
					currentMsgCreatedDate = Date.newInstance(currentMsg.CreatedDate.year(), currentMsg.CreatedDate.month(), currentMsg.CreatedDate.day());

					if(t.PurchasedDate__c <= currentMsgCreatedDate.addDays(7) && t.PurchasedDate__c >= currentMsgCreatedDate) {
						currentMsg.Purchased_Product__c = t.Id;
						if(!MessagingIds.contains(currentMsg.Id)){
							ListToUpdate.add(currentMsg);
							MessagingIds.add(currentMsg.Id);
							clientMessagingsMap.remove(t.Client__c+skuORrmssku);
						}
					}
				}
			}

        }
        if(!ListToUpdate.isempty()){
            
            update ListToUpdate;
             system.debug('helloo: ' +ListToUpdate);

        }
    }    

    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}