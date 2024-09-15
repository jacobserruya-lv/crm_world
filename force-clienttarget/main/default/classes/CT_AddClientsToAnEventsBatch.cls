global class CT_AddClientsToAnEventsBatch implements Database.Batchable<sObject>, Database.Stateful {
    Map<String, List<String>> errors = new Map<String, List<String>>();
    String csvErrorContentString;
    List<String> dreamIds = new List<String>();
    String variationId;
    String eventId;
    String errorFileId;

    public CT_AddClientsToAnEventsBatch(List<String> dreamIdsList, String event, String variation, String errorFile) {
        dreamIds = dreamIdsList;
        eventId = event;
        variationId = variation;
        errorFileId = errorFile;
    }

    global Database.QueryLocator  start(Database.BatchableContext BC) {
      return Database.getQueryLocator([SELECT Id, OwnerId, Store__pr.RetailStoreId__c, Owner.DefaultStore__c, DREAMID__c FROM Account WHERE DREAMID__c IN :dreamIds]);
    }

    global void execute(Database.BatchableContext BC, List<Account> clients) {
        System.debug('clients: ' + clients.size());

        Map<String, Brand_Experience_Variation_Member__c> members = new Map<String, Brand_Experience_Variation_Member__c>();
        Map<String, Brand_Experience_Variation__c> variationByStore = new Map<String, Brand_Experience_Variation__c>();
        Map<String, String> storeRetailIdByClient = new Map<String, String>();

        for (Account client : clients) {
          String clientStoreRetailId = client.Store__pr.RetailStoreId__c != null ? client.Store__pr.RetailStoreId__c : client.Owner.DefaultStore__c;
          storeRetailIdByClient.put(client.DREAMID__c, clientStoreRetailId);
        }

        List<Brand_Experience_Variation__c> variations = new List<Brand_Experience_Variation__c>();

        if (variationId == null) {   
          variations = [
            SELECT Id, Name, Store__r.RetailStoreId__c
            FROM Brand_Experience_Variation__c
            WHERE RecordType.DeveloperName = 'Physical_Event'
            AND Brand_Experience__c = :eventId
            AND Store__r.RetailStoreId__c IN :storeRetailIdByClient.values()
            AND Store__r.RetailStoreId__c != NULL
          ];
        } else {
          variations = [SELECT Id, Name, Store__r.RetailStoreId__c FROM Brand_Experience_Variation__c WHERE Id = :variationId];
        }

        for (Brand_Experience_Variation__c v : variations) {
          variationByStore.put(v.Store__r.RetailStoreId__c, v);
        }

        Map<String, String> storeNameByRetailId = new Map<String, String>();
        List<Store__c> stores = [SELECT RetailStoreId__c, Name FROM Store__c WHERE RetailStoreId__c IN :storeRetailIdByClient.values() AND RetailStoreId__c != NULL];
        for (Store__c store : stores) {
          storeNameByRetailId.put(store.RetailStoreId__c, store.Name);
        }

        for (Account client : clients) {
          String clientStoreRetailId = client.Store__pr.RetailStoreId__c != null ? client.Store__pr.RetailStoreId__c : client.Owner.DefaultStore__c;
          String variation = variationId != null ? variationId : variationByStore.get(clientStoreRetailId)?.Id;

            if (String.isBlank(variation)) {
              addRowToCsvFile(client.DREAMID__c, 'No event in client\'s attached store: ' + storeNameByRetailId.get(clientStoreRetailId));
            } else {          
              members.put(
                client.DREAMID__c,
                new Brand_Experience_Variation_Member__c(
                  Client__c = client.Id,
                  Brand_Experience_Variation__c = variation,
                  Assigned_CA__c = client.OwnerId,
                  Status__c = 'Draft',
                  NominationStatus__c = 'Approved',
                  NominationSource__c = 'Client_target'
                )
              );
            }
        }

        List<Database.SaveResult> results = Database.insert(members.values(), false);
        List<String> resultDreamIds = new List<String>(members.keySet());

        System.debug('storeRetailIdByClient:' + storeRetailIdByClient);
        System.debug('variationByStore: ' + variationByStore);
        for (Integer i = 0; i < results.size(); i++) {
          Database.SaveResult result = results[i];
          String resultDreamId = resultDreamIds[i];

          if (!result.isSuccess()) {
            List<String> errorList = new List<String>();
    
            for(Database.Error err : result.getErrors()) {
              String error = err.getStatusCode() + ': ' + err.getMessage();
              
              if (err.getStatusCode() == StatusCode.DUPLICATE_VALUE) {
                String storeRetailId = storeRetailIdByClient.get(resultDreamId);
                String variationName = variationByStore.get(storeRetailId)?.Name;
                String storeName = storeNameByRetailId.get(storeRetailId);

                error = 'Duplicate client for ' + variationName + ' - ' + storeName;
                System.debug('error: ' + error);
              }

              errorList.add(error);
            }

            System.debug('errorList: ' + errorList);

            addRowToCsvFile(resultDreamId, String.Join(errorList, ','));
          }
        }
    }  

    global void finish(Database.BatchableContext BC) {
        System.debug('Event clients finish');
        System.debug('csvErrorContentString: ' + csvErrorContentString);

        List<ContentVersion> objVersionList = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :errorFileId];

        System.debug('objVersionList: ' + objVersionList);
        if (objVersionList.size() > 0 && String.isNotBlank(csvErrorContentString)) {
          ContentVersion cv = objVersionList[0];
          String titles = 'DreamId, Message' + '\n';
          cv.VersionData = Blob.valueOf(titles + csvErrorContentString);
          update cv;
        }
    }

    private void addRowToCsvFile(String dreamId, String error) {
        if (csvErrorContentString == null) {
            csvErrorContentString = '';
        }
        csvErrorContentString += dreamId + ',' + error + '\n';
    }
}