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

      List<String> membersDreamIds = new List<String>();
      List<Brand_Experience_Variation_Member__c> members = new List<Brand_Experience_Variation_Member__c>();
      List<Brand_Experience_Variation__c> variations = [
        SELECT Id, Name, Store__r.RetailStoreId__c
        FROM Brand_Experience_Variation__c
        WHERE Brand_Experience__c = :eventId
        AND Status__c != 'Ended'
      ];


      for (Brand_Experience_Variation__c variation : variations) {
        for (Account client : clients) {
          String clientStoreRetailId = client.Store__pr.RetailStoreId__c != null ? client.Store__pr.RetailStoreId__c : client.Owner.DefaultStore__c;

          if (variation.Store__r.RetailStoreId__c == null || variation.Store__r.RetailStoreId__c == clientStoreRetailId) {
            membersDreamIds.add(client.DREAMID__C);
            members.add(
              new Brand_Experience_Variation_Member__c(
                Client__c = client.Id,
                Brand_Experience_Variation__c = variation.Id,
                Assigned_CA__c = client.OwnerId,
                Status__c = 'Draft',
                NominationStatus__c = 'Approved',
                NominationSource__c = 'Client_target'
              )
            );
          }
        }
      }

      System.debug('members[0]: ' + members[0]);
      System.debug('members.size(): ' + members.size());

      List<Database.SaveResult> results = Database.insert(members, false);
      System.debug('results.size(): ' + results.size());

      for (Integer i = 0; i < results.size(); i++) {
        Database.SaveResult result = results[i];
        String resultDreamId = membersDreamIds[i];

        System.debug('resultDreamId: ' + resultDreamId);
        System.debug('result: ' + result);
        System.debug('result.isSuccess(): ' + result.isSuccess());

        if (!result.isSuccess()) {
          List<String> errorList = new List<String>();
  
          for(Database.Error err : result.getErrors()) {
            String error = err.getStatusCode() + ': ' + err.getMessage();
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