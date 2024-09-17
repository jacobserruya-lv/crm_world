public with sharing class CT_CampaignController {
    @AuraEnabled(cacheable=true)
    public static List<Campaign__c> getAllCampaigns() {
      return [
        SELECT Id, Name
        FROM Campaign__c
        WHERE Status__c = 'New' OR Status__c = 'Ongoing'
      ];
    }

    @AuraEnabled
    public static Map<Id, CampaignMember__c> getCampaignMembersByAccountIds(
      String campaignId,
      List<String> dreamIds
    ) {
      Map<Id, CampaignMember__c> campaignMembersByAccountIds =  new Map<Id, CampaignMember__c>();
      List<CampaignMember__c> members = [
        SELECT Id, Member__c, AssignedCA__c, AssignedCA__r.Name
        FROM CampaignMember__c 
        WHERE Campaign__c =: campaignId
        AND Member__r.DREAMID__c IN :dreamIds
      ];

      for (CampaignMember__c m : members) {
        campaignMembersByAccountIds.put(m.Member__c, m);
      }

      return campaignMembersByAccountIds;
    }
    
    @AuraEnabled
    public static Map<String, String> pushClientsToCampaignFromBatch(
        String campaignId,
        Map<String, String> assignedCaByDreamId
    ) {
    ContentVersion cv = new ContentVersion();
    cv.ContentLocation = 'S'; //denotes it resides on Salesforce
    cv.Title = 'Event_Error_File'; //title of the file
    cv.PathOnClient = 'Event_Error_File'; // full path within Salesforce this can just be the name of file to be in the library
    cv.VersionData = Blob.valueOf('DreamId, Message' + '\n'); //file data
    cv.IsMajorVersion = false;
    insert cv;

    ContentVersion cvObj = [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
    String errorFileId = cvObj.ContentDocumentId;

    CT_PushClientsToCampaignBatch capmaignBatch = new CT_PushClientsToCampaignBatch(assignedCaByDreamId, campaignId, errorFileId);
    String jobId = Database.executeBatch(capmaignBatch, 200);

    return new Map<String, String> {
      'jobId' => jobId,
      'errorFileId' => errorFileId
    };
  }

  @AuraEnabled
  public static Id assignCampaignMembersToCA(
    List<String> clientIdsList,
    String caId,
    String campaignId
  ) {
    List<CampaignMember__c> campaignMembers = [SELECT Id FROM CampaignMember__c WHERE Campaign__c =: campaignId AND Member__c IN :clientIdsList];
    for (CampaignMember__c m : campaignMembers) {
      m.AssignedCA__c = caId;
    }

    CT_UpdateClientsQueue updateMembersQueue = new CT_UpdateClientsQueue(campaignMembers);
    return System.enqueueJob(updateMembersQueue);
  }

  @AuraEnabled(cacheable=true)
  public static Map<string,Integer> getNumberOfClientsAttachedToCA(List<string> caIdsList, String campaignId) {
    Map<String, Integer> caMap = new Map<String, Integer>();
    List<CampaignMember__c> membersList = [
      SELECT AssignedCA__c 
      FROM CampaignMember__c
      WHERE Campaign__c = :campaignId
      AND AssignedCA__c in :caIdsList
    ];

    for (CampaignMember__c m : membersList) {
      Integer accGroupSize = 0;
      if (caMap.containsKey(m.AssignedCA__c)) {
        accGroupSize = caMap.get(m.AssignedCA__c);
        caMap.remove(m.AssignedCA__c);
      }
      accGroupSize++;
      caMap.put(m.AssignedCA__c, accGroupSize);
    }
    
    return caMap;
  }
}