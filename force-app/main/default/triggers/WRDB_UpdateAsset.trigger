trigger WRDB_UpdateAsset on WRDB_Asset__c (before update) {
  try {
    List<String> assetIds = WRDB_CreateAsset_Controller.getUserScopeAssets(trigger.new);
    WRDB_CreateAsset_Controller.futureUpdateAzureCustomAssets(assetIds);
  } catch (Exception e) {
    System.debug(e);
  }
}