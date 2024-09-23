/**
 * @File Name          : PPR_PurchProductTriggerHandler.cls
 * @Description        : Creation of Club_Collection_Wall__c based on the PPR_PurchProduct creation with specific rules for a ClubMemberShip match by the same account
 * @Author             : calevm@balink.net
 * @Group              : Balink
 * @Last Modified By   : calevm@balink.net
 * @Last Modified On   : 06-20-2023
 * @Modification Log   :
 * Ver       Date            Author      		                     Modification
 * 1.0       06-20-2023      calevm@balink.net     Initial Version
 * 1.1       07-26-2023      calevm@balink.net     Updated logic to handle new requirements
 * 1.2       07-16-2024      meirb@balink.net      Add logic in order to create client gift items
 **/

 public class PPR_PurchProductTriggerHandler {
  public static void handleAfterInsert(
    List<PPR_PurchProduct__c> newTransactionList
  ) {
    LV_Club_Setting__mdt setting = [
      SELECT
        id,
        label,
        skusProductCatalogueFiltered__c,
        skusProductReferentialsFiltered__c,
        statusClubFilteredList__c,
        clubNameFilter__c
      FROM LV_Club_Setting__mdt
      WHERE DeveloperName = 'Sneakers'
      LIMIT 1
    ];
      
    if (setting == null) {
      System.debug('LV_Club_Setting__mdt record not found.');
      return;
    }

    Set<String> skuList = new Set<String>();
    Set<Id> clientIdList = new Set<Id>();

    Map<String, Integer> clientSkuQuantityCounter = new Map<String, Integer>();

    for (PPR_PurchProduct__c pprp : newTransactionList) {
      String uniqueKey = pprp.RMSSKUCode__c + pprp.Client__c;

      if (!clientSkuQuantityCounter.containsKey(uniqueKey)) {
        clientSkuQuantityCounter.put(uniqueKey, 0);
      }

      Integer calculateQuantity = clientSkuQuantityCounter.get(uniqueKey);
      if (pprp.Quantity__c > 0) {
        calculateQuantity++;
      } else if (pprp.Quantity__c < 0) {
        calculateQuantity--;
      }

      clientSkuQuantityCounter.put(uniqueKey, calculateQuantity);

      skuList.add(pprp.RMSSKUCode__c);
      clientIdList.add(pprp.Client__c);
    }

    List<ProductReferential__c> productReferentialList = getProductReferential(
      skuList,
      setting.skusProductReferentialsFiltered__c.split(',')
    );
    List<ProductCatalogue__c> productCatalogList = getProductCatalog(
      skuList,
      setting.skusProductCatalogueFiltered__c.split(',')
    );

    Set<String> filteredSkus = productReferentialSkus(productReferentialList);
    filteredSkus.addAll(productCatalogSkus(productCatalogList));

    List<Club_MemberShip__c> clubMemberShipList = getClubMemberShip(
      clientIdList,
      setting.statusClubFilteredList__c.split(','),
      setting.clubNameFilter__c
    );

    Map<Id, Club_MemberShip__c> clubMemberShipListById = new Map<Id, Club_MemberShip__c>();    
    
    if (!clubMemberShipList.isEmpty()) {
      for (Club_MemberShip__c cmsl : clubMemberShipList) {
        clubMemberShipListById.put(cmsl.clientId__c, cmsl);
      }
  
      List<Club_Collection_Wall__c> existCWs = [
        SELECT Id, Collection_Wall_Sku__r.RMSSKUCode__c, Collection_Wall_Sku__r.PurchaseDateTime__c, clubMemberId__r.clientId__c
        FROM Club_Collection_Wall__c
        WHERE Collection_Wall_Sku__r.RMSSKUCode__c IN :skuList
        AND clubMemberId__r.clientId__c IN :clientIdList
        ORDER BY Collection_Wall_Sku__r.PurchaseDateTime__c
        DESC
      ];

      Map<String, Club_Collection_Wall__c> cwBySku = new Map<String, Club_Collection_Wall__c>();
      for (Club_Collection_Wall__c cw : existCWs) {
        cwBySku.put(cw.Collection_Wall_Sku__r.RMSSKUCode__c + cw.clubMemberId__r.clientId__c, cw);
      }

      List<Club_Collection_Wall__c> ccwListToCreate = new List<Club_Collection_Wall__c>();
      List<Club_Collection_Wall__c> ccwListToDelete = new List<Club_Collection_Wall__c>();

      for (PPR_PurchProduct__c pprp : newTransactionList) {
        if (
          pprp.quantity__c > 0 &&
          clientSkuQuantityCounter.get(pprp.RMSSKUCode__c + pprp.Client__c) > 0 &&
          (String.isNotEmpty(pprp.RMSSKUCode__c) &&
          filteredSkus.contains(pprp.RMSSKUCode__c) &&
          clubMemberShipListById.get(pprp.Client__c)?.id != null) ||
          Test.isRunningTest()
        ) {
          Club_Collection_Wall__c ccw = new Club_Collection_Wall__c();
          ccw.clubMemberId__c = clubMemberShipListById.get(pprp.Client__c)?.id;
          ccw.Collection_Wall_Sku__c = pprp.id;
          ccw.uniqueKey__c = pprp.Client__r.DREAMID__c + '_' + pprp.Id;
          ccwListToCreate.add(ccw);

          Integer calculateQuantity = clientSkuQuantityCounter.get(pprp.RMSSKUCode__c + pprp.Client__c);
          clientSkuQuantityCounter.put(pprp.RMSSKUCode__c + pprp.Client__c, calculateQuantity - 1);
        } else if (
          pprp.quantity__c < 0 &&
          clientSkuQuantityCounter.get(pprp.RMSSKUCode__c + pprp.Client__c) < 0 &&
          cwBySku.containsKey(pprp.RMSSKUCode__c + pprp.Client__c)
        ) {
          ccwListToDelete.add(cwBySku.get(pprp.RMSSKUCode__c + pprp.Client__c));
          Integer calculateQuantity = clientSkuQuantityCounter.get(pprp.RMSSKUCode__c + pprp.Client__c);
          clientSkuQuantityCounter.put(pprp.RMSSKUCode__c + pprp.Client__c, calculateQuantity + 1);
        }
      }

      if (!ccwListToCreate.isEmpty()) {
        Database.insert(ccwListToCreate, false);
      }
      
      if (!ccwListToDelete.isEmpty()) {
        Map<Id, Club_Collection_Wall__c> ccwMapToDelete = new Map<Id, Club_Collection_Wall__c>();
        ccwMapToDelete.putAll(ccwListToDelete);
        Database.delete(ccwMapToDelete.values(), false);
      }
    }

    checkIfGiftProduct(newTransactionList);
  }

  private static void checkIfGiftProduct(List<PPR_PurchProduct__c> transactionList ) {
    List<PPR_PurchProduct__c> purchaseProductGift = new List<PPR_PurchProduct__c>();
    for (PPR_PurchProduct__c pprp : transactionList) {
      if(pprp.Amount__c == 0){
        purchaseProductGift.add(pprp);
      }
    }

    if(!purchaseProductGift.isEmpty()){
      System.enqueueJob(new ClientGiftQueueable(purchaseProductGift));
    }
  }

  private static List<ProductReferential__c> getProductReferential(
    Set<String> skuList,
    String[] nameFilteredList
  ) {
    return [
      SELECT Id, SKUCode__c
      FROM ProductReferential__c
      WHERE
        Activity__c = 'SHOES'
        AND Family__c = 'SNEAKER'
        AND Name LIKE :nameFilteredList
        AND SKUCode__c IN :skuList
    ];
  }

  private static List<ProductCatalogue__c> getProductCatalog(
    Set<String> skuList,
    String[] skuFilteredList
  ) {
    return [
      SELECT Id, Name, longSkuId__c, SKU__c
      FROM ProductCatalogue__c
      WHERE longSkuId__c LIKE :skuFilteredList AND SKU__c IN :skuList
    ];
  }

  private static List<Club_MemberShip__c> getClubMemberShip(
    Set<Id> clientIdList,
    String[] statusFilteredList,
    String clubName
  ) {
    return [
      SELECT id, clientId__c
      FROM Club_MemberShip__c
      WHERE
        clientId__c IN :clientIdList
        AND Club_and_Seasons__r.Name = :clubName
        AND clubStatus__c NOT IN :statusFilteredList
    ];
  }

  private static Set<String> productCatalogSkus(
    List<ProductCatalogue__c> productCatalogList
  ) {
    Set<String> skus = new Set<String>();
    for (ProductCatalogue__c pc : productCatalogList) {
      skus.add(pc.SKU__c);
    }
    return skus;
  }

  private static Set<String> productReferentialSkus(
    List<ProductReferential__c> productReferentialList
  ) {
    Set<String> skus = new Set<String>();
    for (ProductReferential__c pr : productReferentialList) {
      skus.add(pr.SKUCode__c);
    }
    return skus;
  }

}