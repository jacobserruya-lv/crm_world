public with sharing class ICX_PurchasesExport {
  public ICX_PurchasesExport() {
  }

  //@AuraEnabled(cacheable=true)
  @AuraEnabled
  @future(callout=true)
  public static void createExportPurchase(String dreamId) {
    System.debug('createExportPurchase dreamId : ' + dreamId);
    String exportDateFormated = JSON.serialize(System.today())
      .replaceAll('-', '');
    String nameFormated = 'Transactions_' + dreamId + '_' + exportDateFormated;

    Export_Purchases_Tracability__c record = new Export_Purchases_Tracability__c(
      DreamId__c = dreamId,
      Status__c = 'New',
      Name = nameFormated.replaceAll('"', '')
    );

    insert record;
    System.debug('createExportPurchase after insert: ' + record);
  }

  public static String Client360_ExportPurchases(
    String dreamId,
    String newSearch,
    String scrollType,
    String refSaleID,
    String numTrans
  ) {
    String endPoint =
      'callout:MULESOFT_CLIENT_360_VISION/cst-eu/icn-client-vision-eapi/v1/clients/' +
      dreamId +
      '/purchases';

    try {
      HttpResponse response = ICX_WS_Client360.Client360_GetPurchases(
        endpoint,
        dreamId,
        newSearch,
        scrollType,
        refSaleID,
        numTrans
      );

      String statusCode = String.valueOf(response.getStatusCode());

      if (response.getStatusCode() == 200) {
        System.debug('The purchases response' + response.getBody());
        return response.getBody();
      } else {
        ICX_Utils.createIconicsLogs(
          'ICONICS - C360',
          'ICX_PurchasesExport',
          endPoint,
          response.getBody(),
          null,
          'ERROR',
          statusCode
        );
        ICX_Client360_API_Helper.errorObj errorObj = (ICX_Client360_API_Helper.errorObj) JSON.deserialize(
          response.getBody(),
          ICX_Client360_API_Helper.errorObj.class
        );
        throw new ICX_Client360_API_Helper.Client360Exception(
          ICX_WS_Client360.HandleError(
            statusCode,
            errorObj?.data?.errorType + ' ' + errorObj?.data?.errorDescription
          )
        );
      }
    } catch (Exception e) {
      System.debug('Error message : ' + e.getMessage());
      throw new ICX_Client360_API_Helper.Client360Exception(e.getMessage());
    }
  }

  public static List<ICX_Client360_API_Helper.data> getAllPurchasesClient(
    String dreamId
  ) {
    String newSearch = '1';
    String scrollType = 'NEXT';
    String refSaleID;
    String numTrans = '50';
    Boolean isMoreTransaction = true;
    List<ICX_Client360_API_Helper.data> finalPurchasesObj = new List<ICX_Client360_API_Helper.data>();

    while (isMoreTransaction) {
      try {
        String purchasesResult = Client360_ExportPurchases(
          dreamId,
          newSearch,
          scrollType,
          refSaleID,
          numTrans
        );
        ICX_Client360_API_Helper.purchasesObj purchasesObj = (ICX_Client360_API_Helper.purchasesObj) JSON.deserialize(
          purchasesResult,
          ICX_Client360_API_Helper.purchasesObj.class
        );
        List<ICX_Client360_API_Helper.data> data = new List<ICX_Client360_API_Helper.data>(
          purchasesObj.data
        );
        finalPurchasesObj.addAll(data);

        if (!finalPurchasesObj.isEmpty()) {
          if (
            Integer.valueOf(purchasesObj.data.size()) <
            Integer.valueOf(numTrans)
          ) {
            isMoreTransaction = false;
          }
          if (isMoreTransaction) {
            newSearch = '0';

            refSaleID = purchasesObj.data[data.size() - 1].wwsid;
          }
        } else
          break;
      } catch (Exception e) {
        system.debug('getAllPurchasesClient error: ' + e);
        throw new ICX_Client360_API_Helper.Client360Exception(e.getMessage());
      }
    }

    System.debug(
      'getAllPurchasesClient finalPurchasesObj: ' + finalPurchasesObj
    );
    ICX_Utils.createIconicsLogs(
      'ICONICS - C360',
      'ICX_PurchasesExport',
      'API-Vision/getPurchases',
      JSON.serialize(finalPurchasesObj),
      null,
      'INFO',
      '200'
    );
    return finalPurchasesObj;
  }

  public static void actionsForExportPurchases(
    string dreamId,
    string exportRecordId
  ) {
    Export_Purchases_Tracability__c record = [
      SELECT Id, Name
      FROM Export_Purchases_Tracability__c
      WHERE Id = :exportRecordId
    ];

    try {
      List<ICX_Client360_API_Helper.data> purchasesObj = getAllPurchasesClient(
        dreamId
      );

      if (!purchasesObj.isEmpty()) {
        record.Status__c = 'Export In Progress';
        update record;

        Set<String> listStoreNameUsed = new Set<String>();

        for (ICX_Client360_API_Helper.data purchase : purchasesObj) {
          listStoreNameUsed.add(purchase.purchaseStoreCode);
        }

        System.debug('listStoreNameUsed : ' + listStoreNameUsed);

        List<Store__c> listStoreName = [
          SELECT Id, Name, RetailStoreId__c
          FROM Store__c
          WHERE RetailStoreId__c IN :listStoreNameUsed
        ];

        Map<String, String> mapStore = new Map<String, String>();

        for (Store__c store : listStoreName) {
          mapStore.put(store.RetailStoreId__c, store.name);
        }

        List<String> csvRowValues = new List<String>();

        for (ICX_Client360_API_Helper.data purchase : purchasesObj) {
          String formattedDate = purchase.purchaseDate;
          String purchaseStoreCode = purchase.purchaseStoreCode != null
            ? mapStore.get(purchase.purchaseStoreCode)
            : null;
          String SKU;
          String productName;
          Integer quantity;
          Integer amountTTC;
          if (
            purchase.purchaseDetail != null &&
            purchase.purchaseDetail[0] != null
          ) {
            SKU = purchase.purchaseDetail[0].productSKU;
            productName = purchase.purchaseDetail[0].product.name;
            quantity = purchase.purchaseDetail[0].quantity;
            amountTTC = purchase.purchaseDetail[0].amountTTC;
          }

          String rowStr =
            '"' +
            formattedDate +
            '"' +
            ',' +
            '"' +
            purchaseStoreCode +
            '"' +
            ',' +
            '"' +
            SKU +
            '"' +
            ',' +
            '"' +
            productName +
            '"' +
            ',' +
            '"' +
            quantity +
            '"' +
            ',' +
            '"' +
            amountTTC +
            '"';
          csvRowValues.add(rowStr);
        }

        String separator = 'sep=,\n';
        String csvColumnHeader = 'Date, Store, SKU, Article, Quantity, Amount\n';
        String csvFile =
          separator +
          csvColumnHeader +
          String.join(csvRowValues, '\n');

        ContentVersion fileContent = new ContentVersion(
          VersionData = Blob.valueOf(csvFile),
          Title = record.Name,
          PathOnClient = 'Client Purchases_' + dreamId + '.csv'
        );

        insert fileContent;

        List<ContentDocument> contDoc = [
          SELECT Id
          FROM ContentDocument
          WHERE LatestPublishedVersionId = :fileContent.Id
          LIMIT 1
        ];

        record.versionId__c = fileContent.Id;
        record.contentDocumentId__c = contDoc[0].Id;
        update record;

        ContentDistribution conDis = new ContentDistribution(
          Name = fileContent.Title,
          ContentVersionId = fileContent.Id,
          PreferencesAllowViewInBrowser = true
        );

        insert conDis;

        List<ContentDistribution> publicLink = [
          SELECT Id, ContentDownloadUrl
          FROM ContentDistribution
          WHERE ContentVersionId = :fileContent.Id
          LIMIT 1
        ];

        record.Public_File_Link__c = publicLink[0].ContentDownloadUrl;
        record.Status__c = 'Ready To Download';
        update record;
        System.debug('actionsForExportPurchases record at the end : ' + record);
      } else {
        record.Status__c = 'Failed';
        record.API_Error_Message__c = 'API return an empty response : No data for this client';
        update record;
        System.debug(
          'actionsForExportPurchases record at the end else else : ' + record
        );
      }
    } catch (Exception e) {
      record.Status__c = 'Failed';
      record.API_Error_Message__c = 'Error API : ' + string.valueOf(e);
      update record;
      System.debug(
        'actionsForExportPurchases record at the end catch: ' + record
      );
    }
  }
}