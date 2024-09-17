global class CT_PushClientsToCampaignBatch implements Database.Batchable<sObject>, Database.Stateful {
    Map<String, List<String>> errors = new Map<String, List<String>>();
    String csvErrorContentString;
    Set<String> dreamIds = new Set<String>();
    Map<String, String> assignedCaByDreamId = new Map<String, String>();
    Map<String, String> userByLVMId = new  Map<String, String>();
    String campaignId;
    String errorFileId;

    public CT_PushClientsToCampaignBatch(Map<String, String> assignedCaByDreamIdMap, String campaign, String errorFile) {
      dreamIds = assignedCaByDreamIdMap.keySet();
      assignedCaByDreamId = assignedCaByDreamIdMap;
      campaignId = campaign;
      errorFileId = errorFile;

      List<User> users = [
        SELECT Id, WWEmployeeNumber__c
        FROM User
        WHERE WWEmployeeNumber__c != null
        AND WWEmployeeNumber__c 
          IN :assignedCaByDreamId.values()
      ];
      for (User u : users) {
        userByLVMId.put(u.WWEmployeeNumber__c, u.Id);
      }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator([SELECT Id, DREAMID__c FROM Account WHERE DREAMID__c IN :dreamIds]);
    }

    global void execute(Database.BatchableContext BC, List<Account> clients) {
      Map<String, CampaignMember__c> campaignMembers = new Map<String, CampaignMember__c>();
  
      for (Account c : clients) {
        String assignedCaLVMId = assignedCaByDreamId.get(c.DREAMID__c);
        String assignedCaSFId = assignedCaLVMId != null ? userByLVMId.get(assignedCaLVMId) : null;

        campaignMembers.put(
          c.DREAMID__c,
          new CampaignMember__c(
            Member__c = c.Id,
            Campaign__c = campaignId,
            AssignedCA__c = assignedCaSFId != null ? assignedCaSFId : assignedCaLVMId
          )
        );
      }

      List<Database.SaveResult> results = Database.insert(campaignMembers.values(), false);
      List<String> resultDreamIds = new List<String>(campaignMembers.keySet());

      for (Integer i = 0; i < results.size(); i++) {
        Database.SaveResult result = results[i];
        String resultDreamId = resultDreamIds[i];

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
        System.debug('Campaign clients finish');
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