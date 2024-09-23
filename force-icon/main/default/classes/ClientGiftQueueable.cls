public class ClientGiftQueueable implements Queueable{
 	private List<PPR_PurchProduct__c> records;

  public ClientGiftQueueable( List<PPR_PurchProduct__c> records) {
    this.records = records;
  }

  public void execute(QueueableContext context) {

    List<String> rmsSkuCodeList = new List<String>();
    for(PPR_PurchProduct__c purchProd : records) {
      rmsSkuCodeList.add(purchProd.RMSSKUCode__c);
    }
  
    List<GiftCatalog__c> giftCatalogList = [
      SELECT
          Id,
          SKUGift__c
      FROM GiftCatalog__c
      WHERE SKUGift__c IN :rmsSkuCodeList
    ];
  
    Map<String, Id> skuGiftToIdMap = new Map<String, Id>();
    for (GiftCatalog__c giftItem : giftCatalogList) {
      skuGiftToIdMap.put(giftItem.SKUGift__c, giftItem.Id);
    }

    List<Client_Gift__c> clientGiftList = new List<Client_Gift__c>();

    for (PPR_PurchProduct__c purchaseProduct : records) {
      if (skuGiftToIdMap.containsKey(purchaseProduct.RMSSKUCode__c)) {
        User ca = new User(WWEmployeeNumber__c = purchaseProduct.WWEmployeeNumber__c);
        Store__c store = new Store__c(RetailStoreId__c = purchaseProduct.StoreRetailCode__c);
        Client_Gift__c clientGift = new Client_Gift__c();
        clientGift.Purchased_Product__c = purchaseProduct.Id;
        clientGift.Client__c = purchaseProduct.Client__c;
        clientGift.CA_Name__r = ca;
        clientGift.Gift_Item__c =  skuGiftToIdMap.get(purchaseProduct.RMSSKUCode__c);
        clientGift.Gift_Store__r = store;
        clientGift.Gift_Date__c = purchaseProduct.PurchasedDate__c;
        clientGiftList.add(clientGift);
      }
    }

    Database.insert(clientGiftList,false);
  }
  
}