public with sharing class WRDB_CreateAsset_Controller {
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
  public static List<AggregateResult> getManagementCountryLevel(
    String selectedZone
  ) {
    return [
      SELECT StoreCountry__c
      FROM store__c
      WHERE
        status__c = 'Open'
        AND MANAGEMENT_ZONE_LEVEL__c = :selectedZone
      GROUP BY StoreCountry__c
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<AggregateResult> getManagementStoreLevel(
    String selectedCountry
  ) {
    return [
      SELECT Name, RetailStoreId__c
      FROM store__c
      WHERE
        status__c = 'Open'
        AND StoreCountry__c = :selectedCountry
      GROUP BY Name, RetailStoreId__c
    ];
  }
  
  @AuraEnabled
  public static List<WRDB_Asset__c> createAsset(List<Map<String,Object>> assets) {
    try {
      System.debug('assets: '  + assets);
      List<WRDB_Asset__c> wardAssets = new List<WRDB_Asset__c>();

      for (Map<String,Object> asset : assets) {
        WRDB_Asset__c wardrob = new WRDB_Asset__c(
          zone__c = (String) asset.get('zone'),
          country__c = (String) asset.get('country'),
          store__c = (String) asset.get('store'),
          Name = (String) asset.get('name'),
          type__c = (String) asset.get('type'),
          url__c = (String) asset.get('url'),
          scope__c = (String) asset.get('scope'),
          azureId__c = (String) asset.get('id'),
          collectionId__c = (String) asset.get('collectionId'),
          gender__c = (String) asset.get('gender'),
          relatedSkus__c = (String) asset.get('skus')
        );

        wardAssets.add(wardrob);
      }
      System.debug('wardAssets: ' + wardAssets);

      insert wardAssets;
      return wardAssets;
    } catch (DmlException e) {
        System.debug('Faild to create wardrobing asset: ' + e);
    }        

    return null;
  }

  public static String createFileEncryptedPath(String filePath) {
    String mimeType = filePath.substring(filePath.indexOf('.') + 1);
    String fileName = filePath.substring(0, filePath.indexOf('.'));
    Blob fileIdMd5Hash = Crypto.generateDigest('MD5', Blob.valueOf(fileName));
    String fileIdMd5 = EncodingUtil.convertToHex(fileIdMd5Hash);
    String fileBucket = fileIdMd5.substring(fileIdMd5.length() - 4);
    String forwardName = EncodingUtil.convertToHex(Blob.valueOf(fileName));
    String forwardDir = fileBucket.substring(0, 2) + '/' + fileBucket.substring(2, 4);
    return forwardDir + '/' + forwardName + '.' + mimeType;
  }

  @AuraEnabled 
  public static Map<String, String> createAkamaiHeaders(String originalFileName, String method) {
    Third_Party_Settings__mdt NSMetadata = [
        SELECT Custom_Settings__c, EndPoint__c
        FROM Third_Party_Settings__mdt 
        WHERE DeveloperName = 'NetStorage' LIMIT 1
    ];

    Map<String,String> settings = (Map<String, String>) JSON.deserialize(NSMetadata.Custom_Settings__c, Map<String, String>.class);
    String netStoragekey = settings.get('netStoragekey');
    String netStorageKeyName = settings.get('netStorageKeyName');
    String netStorageAddress = settings.get('netStorageAddress');
    String netStorageGet = settings.get('netStorageGet');
    String netStorageEndPoint = NSMetadata.EndPoint__c;

    System.debug(netStoragekey + netStorageKeyName + netStorageAddress + netStorageGet);
    
    String fileName = DateTime.now().getTime() + '_' + originalFileName.deleteWhitespace();
    String encryptedPath = createFileEncryptedPath(fileName);
    String netStoragePath = method == 'delete' ? originalFileName : netStorageAddress + encryptedPath;
    String fileFolder = encryptedPath.substring(
      0, encryptedPath.lastIndexOf('/')
    );
    
    String deleteAction = 'version=1&action=delete&format=xml';
    String uploadAction = 'version=1&action=upload&format=xml&upload-type=binary';
    String action = method == 'delete' ? deleteAction : uploadAction;
    String authData = '5, 0.0.0.0, 0.0.0.0,' + Integer.valueOf(DateTime.now().getTime() / 1000) + ',' + Integer.valueof((Math.random() * 100000)) + ', ' + netStorageKeyName;
    String signString = netstoragePath + '\nx-akamai-acs-action:' + action + '\n';

    Blob HmacSHA256 = crypto.generateMac('HmacSHA256', Blob.valueOf(authData + signString), Blob.valueOf(netStoragekey));
    String authSign = EncodingUtil.base64Encode(HmacSHA256);

    return new Map<String, String> {
      'fileAddress' => netstoragePath,
      'accessUrl' => netStorageGet + '/media/' + fileFolder + '/' + fileName,
      'action' => action,
      'authData' => authData,
      'authSign' => authSign,
      'endPoint' => netStorageEndPoint
    };
  }

  // Get All Collections Names
  @AuraEnabled(cacheable=true) 
  public static Object getAllCollections() {
    String accessToken = 'Bearer ' + getSessionId();
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:WARDROBING_MULESOFT' + '/collections');
    req.setHeader('client_id', '{!$Credential.UserName}');
    req.setHeader('client_secret', '{!$Credential.Password}');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', accessToken);
    req.setMethod('GET');
    req.setTimeout(120000);

    Http http = new Http();
    HTTPResponse res = http.send(req);
    if (res.getStatus() != 'OK') {
      System.debug('getAllCollections => error res: ' + res.getBody());
      throw new BL_Exceptions.QueryException(res.getBody(), res.getBody());
    }

    String decodeResponseBody = EncodingUtil.urlDecode(res.getBody(), 'UTF-8'); // for special characters
    System.debug('getAllCollections => res: ' + decodeResponseBody);
    
    return decodeResponseBody;
  }

  // Create Collection with /collection route >> Looks
  @AuraEnabled 
  public static Object createAzureCollection(String body, String id) {
    String decodeRequestBody = EncodingUtil.urlDecode(body, 'UTF-8'); // for special characters
    System.debug('Azure body: ' + decodeRequestBody);

    String accessToken = 'Bearer ' + getSessionId();
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:WARDROBING_MULESOFT' + '/collections' + (String.isBlank(id) ? '' : '/' + id)); 
    req.setHeader('client_id', '{!$Credential.UserName}');
    req.setHeader('client_secret', '{!$Credential.Password}');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', accessToken);
    req.setMethod(String.isBlank(id) ? 'POST' : 'PUT');
    req.setBody(decodeRequestBody);
    req.setTimeout(120000);
    
    Http http = new Http();
    HTTPResponse res = http.send(req);
    if (res.getStatus() != 'Created' && res.getStatus() != 'OK') {
      System.debug('createAzureCollection => error res: ' + res.getBody());
      throw new BL_Exceptions.QueryException(res.getBody(), res.getBody());
    }

    String decodeResponseBody = EncodingUtil.urlDecode(res.getBody(), 'UTF-8'); // for special characters
    System.debug('createAzureCollection => res: ' + decodeResponseBody);

    return decodeResponseBody;
  }


  @AuraEnabled 
  public static Object createAzureCustomAssetByUrl(String body) { 
    String decodeRequestBody = EncodingUtil.urlDecode(body, 'UTF-8'); // for special characters
    System.debug('Azure body: ' + decodeRequestBody);

    String accessToken = 'Bearer ' + getSessionId();
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:WARDROBING_MULESOFT' + '/custom-asset/create-by-url'); 
    req.setHeader('client_id', '{!$Credential.UserName}');
    req.setHeader('client_secret', '{!$Credential.Password}');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', accessToken);
    req.setMethod('POST');
    req.setBody(decodeRequestBody);
    req.setTimeout(120000);
    
    Http http = new Http();
    HTTPResponse res = http.send(req);
    if (res.getStatus() != 'Created') {
      System.debug('createAzureCustomAsset => error res: ' + res.getBody());
      throw new BL_Exceptions.QueryException(res.getBody(), res.getBody());
    }

    String decodeResponseBody = EncodingUtil.urlDecode(res.getBody(), 'UTF-8'); // for special characters
    System.debug('createAzureCustomAsset => res: ' + decodeResponseBody);
    
    return decodeResponseBody;
  }

  @future (callout=true)
  public static void deleteAzureCustomAsset(String id) { 
    String accessToken = 'Bearer ' + getSessionId();

    System.debug('accessToken: ' + accessToken);
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:WARDROBING_MULESOFT' + '/custom-asset/' + id);
    req.setHeader('client_id', '{!$Credential.UserName}');
    req.setHeader('client_secret', '{!$Credential.Password}');
    req.setHeader('Authorization', accessToken);
    req.setMethod('DELETE');
    req.setTimeout(120000);
    
    Http http = new Http();
    HTTPResponse res = http.send(req);
    if (res.getStatus() != 'OK') {
        System.debug('deleteAzureCustomAsset => error res: ' + res.getBodyDocument());
        throw new BL_Exceptions.QueryException('Error during delete asset: ' , res.getBody());
    }

    System.debug('deleteAzureCustomAsset - successfuly => res: ' + res.getBody());
  }

  @future(callout=true)
  public static void futureDeleteAzureCustomAssets(List<String> ids) {
    deleteAzureCustomAssets(ids, false);
  }

  @AuraEnabled
  public static void deleteAzureCustomAssets(List<String> ids, Boolean retry) { 
    Set<string> idsSet = new Set<string>(ids);
    idsSet.remove(null);
    System.debug('Mass Delete: ' + idsSet);

    String accessToken = 'Bearer ' + getSessionId();
    Map<String, Set<String>> bodyMap = new Map<String, Set<String>> {
      'ids' => idsSet
    };
    String jsonBody = JSON.serialize(bodyMap);
    System.debug(jsonBody);
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:WARDROBING_MULESOFT' + '/custom-asset/remove-many');
    req.setHeader('client_id', '{!$Credential.UserName}');
    req.setHeader('client_secret', '{!$Credential.Password}');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', accessToken);
    req.setMethod('POST');
    req.setBody(jsonBody);
    req.setTimeout(120000);
    
    Http http = new Http();
    HTTPResponse res = http.send(req);

    Map<String,Object> resBody = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
    Integer deletedCount = (Integer) resBody.get('deletedCount');

    if (deletedCount < ids.size()) {
      Logs__c log = new Logs__c( 	
        ClassName__c = 'WRDB_CreateAsset_Controller',
        Level__c = 'ERROR',
        Response__c = 'Some of these assets were not deleted: ' +  ids
      );

      insert log;
    }

    if (res.getStatus() != 'Created') {
      System.debug('deleteAzureCustomAssets => error statusCode: ' + res.getStatus());
      System.debug('deleteAzureCustomAssets => error res: ' + res.getBody());
      if (!retry) {
        deleteAzureCustomAssets(ids, true);
      } else {
        Logs__c log = new Logs__c( 	
          ClassName__c = 'WRDB_CreateAsset_Controller',
          Level__c = 'ERROR',
          Response__c = 'Failed to delete assets on azure: ' +  ids
        );

        insert log;

        throw new BL_Exceptions.QueryException(
          String.valueOf(res.getStatusCode()),
          'Error during delete asset',
          res.getBody()
        );
      }
    }

    System.debug('deleteAzureCustomAssets - successfuly => res: ' + res.getBody());
  }

  @future(callout=true)
  public static void futureUpdateAzureCustomAssets(List<String> assetIds) {
    List<WRDB_Asset__c> assets = [SELECT Name, url__c, type__c, relatedSkus__c, scope__c, azureId__c, gender__c, zone__c, country__c, store__c FROM WRDB_Asset__c WHERE Id IN :assetIds];
    List<String> relatedSkus = new   List<String>();

    for (WRDB_Asset__c asset : assets) {
      List<String> assetSkus = String.isBlank(asset.relatedSkus__c) ? new List<String>() : asset.relatedSkus__c.split(',');
      relatedSkus.addAll(assetSkus);
    }

    List<ProductCatalogue__c> catalogueProducts = getProductsBySkus(relatedSkus);
    Map<String,Map<String, String>> productsMap = new Map<String,Map<String, String>>();

    for (ProductCatalogue__c p : catalogueProducts) {
      Map<String,String> product = new Map<String,String> {
        'name' => p.Name,
        'contentUrl' => String.isNotBlank(p.Image1Url__c) ? p.Image1Url__c : 'https://www.louisvuitton.com/images/is/image/lv/1/PP_VP_L/louisvuitton--' + p.SKU__c + '_PM2_Front%20view.png',
        'sku' => p.SKU__c
      };

      productsMap.put(p.SKU__c, product);
    }

    for (WRDB_Asset__c asset : assets) {
      List<Map<String, String>> azureProducts = new List<Map<String, String>>();
      List<String> assetSkus = String.isBlank(asset.relatedSkus__c) ? new List<String>() : asset.relatedSkus__c.split(',');
      
      for (String sku : assetSkus) {
        azureProducts.add(
          productsMap.get(sku)
        );
      }

      updateAzureCustomAsset(asset, azureProducts, false);
    }
  }

  public static void updateAzureCustomAsset(WRDB_Asset__c asset, List<Map<String, String>> azureProducts, Boolean retry) { 
    Map<String,Object> azureAsset = new Map<String,Object> {
      'zone' => asset.zone__c,
      'country'=> asset.country__c,
      'store' => asset.store__c,
      'name' => asset.Name,
      'type' => asset.type__c,
      'url' => asset.url__c,
      'scope' => asset.scope__c,
      'gender' => asset.gender__c,
      'products' => azureProducts
    };

    for(String key : azureAsset.keySet()) {
      Object item = azureAsset.get(key);
      if (item == null) {
        azureAsset.remove(key);
      }
    }

    String accessToken = 'Bearer ' + getSessionId();
    HttpRequest req = new HttpRequest();
    String body = JSON.serialize(azureAsset);
    System.debug('azureAsset; ' +  body);
    req.setEndpoint('callout:WARDROBING_MULESOFT' + '/custom-asset/' + asset.azureId__c);
    req.setHeader('client_id', '{!$Credential.UserName}');
    req.setHeader('client_secret', '{!$Credential.Password}');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', accessToken);
    req.setMethod('PUT');
    req.setBody(body);
    req.setTimeout(120000);
    
    Http http = new Http();
    HTTPResponse res = http.send(req);
    if (res.getStatus() != 'Ok') {
      System.debug('updateAzureCustomAsset => error res: ' + res.getBody());
     
      if (!retry) {
        updateAzureCustomAsset(asset, azureProducts, true);
      } else {
        Logs__c log = new Logs__c( 	
          ClassName__c = 'WRDB_CreateAsset_Controller',
          Level__c = 'ERROR',
          Response__c = 'Failed to update asset on azure: ' +  asset.azureId__c
        );

        insert log;

        throw new BL_Exceptions.QueryException(res.getBody(), res.getBody());
      }
    }

    System.debug('updateAzureCustomAsset => res: ' + res.getBody());
  }

  private static String getSessionId() {
    return !Test.IsRunningTest() ? Page.BL_ApiSessionId.getContent().toString().trim() :  UserInfo.getSessionId();
  }

  @AuraEnabled(cacheable=true)
  public static List<WRDB_Asset_Csv_Config__mdt> getAssetInfoSettings() {
    return [SELECT Label, Type__c, Enum__c, IsRequired__c FROM WRDB_Asset_Csv_Config__mdt];
  }

  @AuraEnabled(cacheable=true)
  public static List<ProductCatalogue__c> getProductsBySkus(List<String> skus) {
    return [SELECT id, Name, SKU__c, Image1Name__c, Image1Url__c FROM ProductCatalogue__c WHERE SKU__c IN :skus];
  }

  public static List<String> getUserScopeAssets(List<WRDB_Asset__c> assets) {
    Id userId = UserInfo.getUserId();
    User user = [SELECT ToLabel(MANAGEMENT_ZONE_LEVEL__c) zoneName, ToLabel(MGMT_ZONE_SUB_LEVEL1__c) countryName, Country__c, DefaultStore__c, Profile.Name  FROM User WHERE Id = :userId limit 1];
    List<String> assetsIds = new List<String>();

    for (WRDB_Asset__c asset : assets) {
      Boolean isInScope = getIsAssetInUserScope(asset, user);

      if (isInScope) {
        assetsIds.add(asset.Id);
      } else {
        asset.addError('Asset not in your scope!');
      } 
    }

    return assetsIds;
  }

  public static Boolean getIsAssetInUserScope(WRDB_Asset__c asset, User user) {
    Boolean isAdmin = user.Profile.Name == 'System Administrator';
    Boolean isCorporate = user.Profile.Name == 'ICON_Corporate';
    Boolean isSaManager = user.Profile.Name == 'ICON_SA Manager';

    String zoneName = (String) user.get('zoneName');
    String countryName = (String) user.get('countryName');

    return (user.Id == asset.OwnerId) || 
          isAdmin ||
          isCorporate && (
            (String.isNotBlank(zoneName) && String.isBlank(countryName) && asset.Zone__c == zoneName) ||
            (String.isNotBlank(zoneName) && String.isNotBlank(countryName) && asset.country__c == countryName)
          ) ||
          isSaManager && asset.store__c == user.DefaultStore__c;
  }
}