trigger WRDB_DeleteAsset_Trigger on WRDB_Asset__c (before delete) {
    try {
        List<String> assetIds = WRDB_CreateAsset_Controller.getUserScopeAssets(trigger.old);
        List<String> azureIds = new List<String>();

        for (WRDB_Asset__c asset : trigger.old) {
            assetIds.contains(asset.Id);
            azureIds.add(asset.azureId__c);
        }

        WRDB_CreateAsset_Controller.futureDeleteAzureCustomAssets(azureIds);
    } catch (Exception e) {
        System.debug(e);
    }
}