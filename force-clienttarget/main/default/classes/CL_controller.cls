// CI CD Test
public with sharing class CL_controller {
  public class CustomException extends Exception {}

  public class MTEngineContact {
    public String dream_id;
    public String first_transaction_date_hist;
    public Boolean contactable_by_email;
  }

  public class MTEngineResponse {
    public List<MTEngineContact> Contacts;
  }

  @AuraEnabled(cacheable=true)
  public static List<AggregateResult> getManagementZoneLevel() {
    return [
      SELECT MANAGEMENT_ZONE_LEVEL_TECH__c, MANAGEMENT_ZONE_LEVEL__c
      FROM store__c
      WHERE status__c = 'Open' AND MANAGEMENT_ZONE_LEVEL_TECH__c != NULL
      GROUP BY MANAGEMENT_ZONE_LEVEL__c, MANAGEMENT_ZONE_LEVEL_TECH__c
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<AggregateResult> getManagementZoneSubLevel1(
    String selectedManagementZoneLevel
  ) {
    return [
      SELECT MGMT_ZONE_SUB_LEVEL1_TECH__c, MGMT_ZONE_SUB_LEVEL1__c
      FROM store__c
      WHERE
        status__c = 'Open'
        AND MANAGEMENT_ZONE_LEVEL__c = :selectedManagementZoneLevel
      GROUP BY MGMT_ZONE_SUB_LEVEL1_TECH__c, MGMT_ZONE_SUB_LEVEL1__c
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<AggregateResult> getManagementZoneSubLevel2(
    String selectedManagementZoneSubLevel1
  ) {
    return [
      SELECT MGMT_ZONE_SUB_LEVEL2_TECH__c, MGMT_ZONE_SUB_LEVEL2__c
      FROM store__c
      WHERE
        status__c = 'Open'
        AND MGMT_ZONE_SUB_LEVEL1__c = :selectedManagementZoneSubLevel1
      GROUP BY MGMT_ZONE_SUB_LEVEL2_TECH__c, MGMT_ZONE_SUB_LEVEL2__c
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<AggregateResult> getManagementZoneSubLevel3(
    String selectedManagementZoneSubLevel2
  ) {
    return [
      SELECT MGMT_ZONE_SUB_LEVEL3_TECH__c, MGMT_ZONE_SUB_LEVEL3__c
      FROM store__c
      WHERE
        status__c = 'Open'
        AND MGMT_ZONE_SUB_LEVEL2__c = :selectedManagementZoneSubLevel2
      GROUP BY MGMT_ZONE_SUB_LEVEL3_TECH__c, MGMT_ZONE_SUB_LEVEL3__c
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<AggregateResult> getDefaultStore(
    String selectedManagementZoneSubLevel3
  ) {
    return [
      SELECT Name, RetailStoreId__c
      FROM store__c
      WHERE
        status__c = 'Open'
        AND MGMT_ZONE_SUB_LEVEL3__c = :selectedManagementZoneSubLevel3
      GROUP BY Name, RetailStoreId__c
    ];
  }

  @AuraEnabled(cacheable=true)
  public static String getIsAllClientsInMyZone(
    String zone, List<String> dreamIds
  ) {
    String baseQuery = 'SELECT COUNT() FROM Account WHERE DREAMID__c IN :dreamIds AND Store__pr.MANAGEMENT_ZONE_LEVEL__c != :zone';
    Integer clientsCount = Database.countQuery(baseQuery);
    
    if (clientsCount > 0) {
      return 'false';
    } else {
      return 'true';
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<SObject> getIsAllClientsInMyPerimeter(
    String type, String zone, List<String> dreamIds
  ) {
    if (String.isBlank(zone) || String.isBlank(type)) {
      return new List<SObject>();
    }

    Map<String, String> clientOwnerZone = getZoneParameterByType(type);
    String zoneParameter = clientOwnerZone.get('zoneParameter');
    String caZoneParameter = clientOwnerZone.get('caZoneParameter');
    String baseQuery = 'SELECT DREAMID__c FROM Account WHERE DREAMID__c IN :dreamIds AND ((' + 
                                                    zoneParameter + ' != :zone AND ' +
                                                    zoneParameter + ' != null) OR (' +
                                                    zoneParameter + ' = null AND ' +
                                                    caZoneParameter + ' != :zone AND ' +
                                                    caZoneParameter + ' != null))';
    List<SObject> clients = Database.query(baseQuery);

    System.debug('getIsAllClientsInMyPerimeter => baseQuery: ' + baseQuery);
    System.debug('getIsAllClientsInMyPerimeter => clientsCount: ' + clients.size());

    return clients;
  }

  public static Map<String, String> getZoneParameterByType(String type) {
    String zoneParameter;
    String caZoneParameter;

    switch on type {
      when 'store'{
        zoneParameter = 'Store__pr.RetailStoreId__c';
        caZoneParameter = 'Owner.DefaultStore__c';
      }
      when 'level3' {
        zoneParameter = 'Store__pr.MGMT_ZONE_SUB_LEVEL3__c';
        caZoneParameter = 'Owner.MGMT_ZONE_SUB_LEVEL3__c';
      }
      when 'level2' {
        zoneParameter = 'Store__pr.MGMT_ZONE_SUB_LEVEL2__c';
        caZoneParameter = 'Owner.MGMT_ZONE_SUB_LEVEL2__c';
      }
      when 'level1' {
        zoneParameter = 'Store__pr.MGMT_ZONE_SUB_LEVEL1__c';
        caZoneParameter = 'Owner.MGMT_ZONE_SUB_LEVEL1__c';
      }
      when 'level' {
        zoneParameter = 'Store__pr.MANAGEMENT_ZONE_LEVEL__c';
        caZoneParameter = 'Owner.MANAGEMENT_ZONE_LEVEL__c';
      }
    }

    return new Map<String, String> {
      'zoneParameter' => zoneParameter,
      'caZoneParameter' => caZoneParameter
    };
  }

  public static List<Account> getClientsByZoneQuery(String type, String zone, List<String> dreamIds ,List<String> ownerIds) {
    if (String.isBlank(zone)) {
      return getBasicClientList(dreamIds);
    }

    Map<String, String> clientOwnerZone = getZoneParameterByType(type);
    String zoneParameter = clientOwnerZone.get('zoneParameter');
    String caZoneParameter = clientOwnerZone.get('caZoneParameter');
    String baseQuery = 'SELECT Id, Name, DREAMID__c FROM Account WHERE DREAMID__c != null AND DREAMID__c IN :dreamIds AND ((' +
                  zoneParameter + ' = :zone) OR (' +
                  zoneParameter + ' = null AND ' +
                  caZoneParameter + ' = :zone))';

    if (ownerIds.size() > 0) {
      baseQuery += ' AND owner.WWEmployeeNumber__c IN :ownerIds';
      System.debug('getClientsByZoneQuery => ownerIds: ' + ownerIds);
    }

    List<Account> accounts = Database.query(baseQuery);

    System.debug('getClientsByZoneQuery => baseQuery: ' + baseQuery);
    System.debug('getClientsByZoneQuery => dreamIds before: ' + dreamIds.size());
    System.debug('getClientsByZoneQuery => accounts after: ' + accounts.size());

    return accounts;
  }

  @AuraEnabled(cacheable=true)
  public static List<User> getAssignedCA(String selectedDefaultStore, List<String> technicalUsers) {
    return [
      SELECT Id, Name, WWEmployeeNumber__c
      FROM user
      WHERE (DefaultStore__c = :selectedDefaultStore AND IsActive = TRUE)
      OR Name IN :technicalUsers
    ];
  }

  @AuraEnabled(cacheable=true)
  public static Integer getNumberofClientsForCA(String caId) {
    return [
      SELECT COUNT()
      FROM Account
      WHERE OwnerId = :caId
    ];
  }

  @AuraEnabled(cacheable=true)
  public static Map<string,Integer> getNumberofClientsForCAList(List<string> caIdsList) {
    Map<String, Integer> caMap = new Map<String, Integer>();
    List<Account> accountsList = [SELECT Id, OwnerId FROM Account WHERE OwnerId in :caIdsList];

    for (Account a : accountsList) {
      Integer accGroupSize = 0;
      if (caMap.containsKey(a.OwnerId)) {
        accGroupSize = caMap.get(a.OwnerId);
        caMap.remove(a.OwnerId);
      }
      accGroupSize++;
      caMap.put(a.OwnerId, accGroupSize);
    }
    
    return caMap;
  }

  @AuraEnabled(cacheable=true)
  public static List<Account> getClientList(list<String> dreamIds, String ignoreCache) {
    return [
      SELECT Id,
            Name,
            Segmentation_To_Display__c,
            LastTrans__pc, DREAMID__c,
            Owner.Name,
            Owner.LastName,
            Owner.DefaultStore__c,
            Store__pr.Name,
            Store__pr.RetailStoreId__c,
            Owner.Currency__c,
            Turnover12mrTaxInclCNY__pc,
            Turnover12mrTaxInclEUR__pc,
            Turnover12mrTaxInclUSD__pc,
            Turnover12mrTaxInclJPY__pc,
            PrimaryCountry__pc
      FROM Account
      WHERE DREAMID__c != null AND DREAMID__c IN :dreamIds
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Account> getBasicClientList(list<String> dreamIds) {
    return [
      SELECT Id, Name, DREAMID__c
      FROM Account
      WHERE DREAMID__c != null AND DREAMID__c IN :dreamIds
    ];
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, String> getAllStores() {
    Map<String, String> storesMap = new Map<String, String>();
    List<Store__c> storesList = [SELECT Name, RetailStoreId__c FROM Store__c];

    for (Store__c s : storesList) {
      if (s.RetailStoreId__c != null && s.RetailStoreId__c != '') {
        storesMap.put(s.RetailStoreId__c, s.Name);
      }
    }
    
    return storesMap;
  }

  @AuraEnabled(cacheable=true)
  public static List<Account> getClientsByFilters(String filters, String type, String zone, String ignoreCache, List<String> ownerIds) {
    System.debug('getClientsByFilters => props: ' + type + '--' + zone);
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:CLIENT_TARGET_ONEDATA' + '/get-dream-ids');
    req.setHeader('client_id', '{!$Credential.UserName}');
    req.setHeader('client_secret', '{!$Credential.Password}');
    req.setHeader('Content-Type', 'application/json');
    req.setMethod('POST');
    req.setBody(filters);
    req.setTimeout(120000);
    Http http = new Http();

    if (Test.IsRunningTest()) { //TestMethod do not support Web service callouts
      return new List<Account>{};
    }

    HTTPResponse res = http.send(req);
    if (res.getStatus() != 'OK') {
      System.debug('getClientsByFilters => error res: ' + res);
      throw new CustomException(res.getStatus());
    }

    List<String> dreamIds = (List<String>) JSON.deserialize(res.getBody(), List<String>.class);
    return getClientsByZoneQuery(type, zone, dreamIds, ownerIds);
  }

  @AuraEnabled(cacheable=true)
  public static Object getClientsByEngineFilters(String filters, String type, String zone, String ignoreCache, List<String> ownerIds) {
    System.debug('getClientsByFilters => props: ' + filters);

    String currentUserCountry = [SELECT Country__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Country__c;
    Boolean isChinaUser = currentUserCountry?.toUpperCase() == 'CHINA';
    String calloutName = isChinaUser ? 'CLIENT_TARGET_MT_ENGINE_CN' : 'CLIENT_TARGET_MT_ENGINE';

    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:'  + calloutName);
    req.setHeader('client_id', '{!$Credential.UserName}');
    req.setHeader('client_secret', '{!$Credential.Password}');
    req.setHeader('Content-Type', 'application/json');
    req.setMethod('POST');
    req.setBody(filters);
    req.setTimeout(120000);
    Http http = new Http();

    if (Test.IsRunningTest()) { //TestMethod do not support Web service callouts
      return '{ "Contacts": [ { "dream_id": 216392371, "first_transaction_date_hist": "09/23/2023 00:00:00", "contactable_by_email": true }]}';
    }

    HTTPResponse res = http.send(req);
    System.debug('res:' + res);
    if (res.getStatus() != 'OK') {
      System.debug('getClientsByEngineFilters => error res: ' + res);
      throw new CustomException(res.getStatus());
    }

    return res.getBody();
  }

  @AuraEnabled
  public static AsyncApexJob getClientListJobDetails(Id jobId) {
    List<AsyncApexJob> job = [
      SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus
      FROM AsyncApexJob
      WHERE Id = :jobId
    ];

    return job.size() > 0 ? job[0] : null;
  }

  @AuraEnabled
  public static Parent_Child_job_id__c getChildJobId(Id parentJobId) {
    List<Parent_Child_job_id__c> childJob = [
      SELECT Job_Id__c
      FROM Parent_Child_job_id__c
      WHERE Parent_Job_Id__c = :parentJobId
    ];

    return childJob.size() > 0 ? childJob[0] : null;
  }

  @AuraEnabled
  public static void deleteChildJob(Id jobId) {
    List<Parent_Child_job_id__c> PCJ = [
      SELECT Job_Id__c
      FROM Parent_Child_job_id__c
      WHERE Job_Id__c = :jobId
    ];

    if (PCJ.size() > 0)
      delete PCJ[0];
  }

  @AuraEnabled(cacheable=true)
  public static list<String> getMissingEmailDreamIds(list<String> dreamIds) {
    list<String> missingEmail = new list<String>();
    list<Contact> contacts = [
      SELECT Account.DREAMID__c
      FROM Contact
      WHERE Account.DREAMID__c in :dreamIds
      AND Email = null
    ];

    if (contacts.size() > 0) {
      for (Contact c : contacts) {
        missingEmail.add(c.Account.DREAMID__c);
      }
    }

    return missingEmail;
  }

  @AuraEnabled(cacheable=true)
  public static List<Map<String, String>> getNotContactableClients(list<String> dreamIds, List<String> phoneCountries) {
    List<Map<String, String>> notContactableClients = new List<Map<String, String>> ();
    
    List<Contact> contacts = [
      SELECT Account.DREAMID__c, PrimaryCountry__c, Email
      FROM Contact
      WHERE Account.DREAMID__c in :dreamIds
      AND (
        (
          PrimaryCountry__c IN :phoneCountries
          AND Account.PersonMobilePhone = NULL
        ) OR (
          PrimaryCountry__c NOT IN :phoneCountries
          AND Email = NULL 
        )
      )
    ];

    if (contacts.size() > 0) {
      for (Contact c : contacts) {
        notContactableClients.add( 
          new Map<String, String> {
            'DREAMID__c' => c.Account.DREAMID__c,
            'PrimaryCountry__c' => c.PrimaryCountry__c,
            'Comments' =>  phoneCountries.contains(c.PrimaryCountry__c) ? 'Missing Phone' : 'Missing Email'
          }
        );
      }
    }

    return notContactableClients;
  }

  @AuraEnabled(cacheable=true)
  public static CT_exclusiveOffer__c getExclusiveOfferSettings() {
    return [SELECT isDisplay__c FROM CT_exclusiveOffer__c];
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, String> getUnlockStoreProfilesSettings() {
    Id profileId = UserInfo.getProfileId();
    List<Profile> profiles = [SELECT Name FROM Profile WHERE Id = :profileId LIMIT 1];
    String profileName = profiles[0].Name;
    CT_unlockAuthorizedProfiles__c unlockStoreSettings = [SELECT profiles__c FROM CT_unlockAuthorizedProfiles__c];

    return new Map<String, String> {
      'unlockStoreProfiles' => unlockStoreSettings.profiles__c,
      'currentProfileName' => profileName
    };
  }

  @AuraEnabled(cacheable=true)
  public static User getCurrentUserSettings() {
    return [
      SELECT MANAGEMENT_ZONE_LEVEL__c,
             MGMT_ZONE_SUB_LEVEL1__c,  
             MGMT_ZONE_SUB_LEVEL2__c,
             MGMT_ZONE_SUB_LEVEL3__c,
             TECH_DefaultStoreName__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];
  }


  @AuraEnabled(cacheable=true)
  public static CT_Query_Config__mdt getQueryConfig() {
    return [
      SELECT data__c 
      FROM CT_Query_Config__mdt 
      LIMIT 1
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Brand_Experience__c> getAllPublishedEvents() {
    return [
      SELECT Id, Name, Description__c,  StartDate__c, EndDate__c
      FROM Brand_Experience__c
      WHERE Status__c = 'Ready'
      AND RecordType.DeveloperName != 'Club_Experience'
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Brand_Experience_Variation__c> getAllEventVariationById(Id id) {
    List<String> statusFilterList = new List<String> { 'Ready', 'Draft' };

    return [
      SELECT Id, Name, Description__c, StartDateTime__c, EndDateTime__c, Store__r.Name, Store__r.RetailStoreId__c
      FROM Brand_Experience_Variation__c
      WHERE Brand_Experience__c = :id 
      AND Status__c IN :statusFilterList
      AND RecordType.DeveloperName = 'Physical_Event'
    ];
  }

  @AuraEnabled
  public static Map<String, String> addClientsToAnEventFromBatch(
    String eventId,
    String variationId,
    List<String> dreamIdsList
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

    CT_AddClientsToAnEventsBatch eventBatch = new CT_AddClientsToAnEventsBatch(dreamIdsList, eventId, variationId, errorFileId);
    String jobId = Database.executeBatch(eventBatch, 200);

    return new Map<String, String> {
      'jobId' => jobId,
      'errorFileId' => errorFileId
    };
  }
}