global class ICX_RelateTransactionToOutboundCall implements Database.Batchable<sObject> {
	//NI-1021
    String query;
	
	global ICX_RelateTransactionToOutboundCall() {

		List<String> ListOfTaskRecordTypesId= new list<String>{
			'\''+Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Call').getRecordTypeId() +'\'',
			'\''+Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('ICONICS_Clienteling').getRecordTypeId()+'\'' 
			};

		query = 'SELECT Id,Transaction_Id__c,AccountId,Sku_Number__c,Purchased_Product__c,CreatedDate,CallType ' +
		        'FROM Task WHERE Purchased_Product__c=null AND CreatedDate>=LAST_N_DAYS:7 AND((Transaction_Id__c != null AND Sku_Number__c != null) OR AccountId != null) AND RecordTypeId IN '+ ListOfTaskRecordTypesId +
				' AND CallType = \'outbound\' order by CreatedDate DESC';
		
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

			if(!String.isBlank(call.Transaction_Id__c) && !String.isBlank(call.Sku_Number__c)) {
				String transactionId = call.Transaction_Id__c.toLowerCase().trim();
				distantOrderCallsMap.put(transactionId+call.Sku_Number__c, call);
				distantOrderNumbers.add(transactionId);
			}else{
				clientCallsMap.put(call.AccountId, call);
			}
			if(!String.isBlank(call.AccountId)) {
				clients.add(call.AccountId);
			}
			if(!String.isBlank(call.Sku_Number__c)) {
				skus.add(call.Sku_Number__c);
			}
		} 

		List<PPR_PurchProduct__c> transactions = [SELECT Id,Client__c,SKU__c,PurchasedDate__c,TechTransactionId__c,RMSSKUCode__c
		FROM PPR_PurchProduct__c
		WHERE Quantity__c >0 AND ((OrderATGId__c IN:distantOrderNumbers OR TransactionRMSId__c IN:distantOrderNumbers) OR Client__c IN:clients) 
		AND PurchasedDate__c>=LAST_N_DAYS:7 AND TransactionStoreType__c in ('CSC','WEB')
        AND ICX_ContactChannel__c=null AND ICX_ContactChannel_RecordId__c=null
		AND ICX_CSCUser__c=null AND ICX_CSCContactDate__c=null AND createdDate < TODAY];

		Task currentCall;
		Date currentCallCreatedDate;

		for(PPR_PurchProduct__c t : transactions) {
			string skuORrmssku='';
			//if there is a transaction with SKU__c OR RMSSKUCode__c
			if(distantOrderCallsMap!=null && (distantOrderCallsMap.containsKey(t.TechTransactionId__c+t.SKU__c)||distantOrderCallsMap.containsKey(t.TechTransactionId__c+t.RMSSKUCode__c))) {

				skuORrmssku =  distantOrderCallsMap.containskey(t.TechTransactionId__c+t.SKU__c) ? t.SKU__c :(distantOrderCallsMap.containskey(t.TechTransactionId__c+t.RMSSKUCode__c) ? t.RMSSKUCode__c: '') ;

				if(!String.isBlank(skuORrmssku)){
					currentCall = distantOrderCallsMap.get(t.TechTransactionId__c+skuORrmssku);
					currentCallCreatedDate = Date.newInstance(currentCall.CreatedDate.year(), currentCall.CreatedDate.month(), currentCall.CreatedDate.day());
					
					//if the PP date is in the 7 days of the Task's cretaeddate
					if(t.PurchasedDate__c <= currentCallCreatedDate.addDays(7) && t.PurchasedDate__c >= currentCallCreatedDate){
						currentCall.Purchased_Product__c = t.Id;
						if(!callIds.contains(currentCall.Id)) {
							callsToUpdate.add(currentCall); //add the Task to callsToUpdate list
							callIds.add(currentCall.Id);
							distantOrderCallsMap.remove(t.TechTransactionId__c+skuORrmssku); //remove the Task from distantOrderCallsMap list
						}
						if(clientCallsMap != null && clientCallsMap.containsKey(t.Client__c+skuORrmssku)) {
							clientCallsMap.remove(t.Client__c+skuORrmssku);
						}
					}
				}
			}
			else if (clientCallsMap.containskey(t.Client__c)) { //attach by Client	

                currentCall = clientCallsMap.get(t.Client__c);
				currentCallCreatedDate = Date.newInstance(currentCall.CreatedDate.year(), currentCall.CreatedDate.month(), currentCall.CreatedDate.day());
                
                if(t.PurchasedDate__c <= currentCallCreatedDate.addDays(7) && t.PurchasedDate__c >= currentCallCreatedDate) {
                    currentCall.Purchased_Product__c = t.Id;
                    if(!callIds.contains(currentCall.Id)) {
                        callsToUpdate.add(currentCall);
                        callIds.add(currentCall.Id);
                        clientCallsMap.remove(t.Client__c);
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