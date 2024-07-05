global class ICX_DeletePurchasesExportBatch implements Database.Batchable<sObject>, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        DateTime last24Hours = DateTime.now().addDays(-1);
        // DateTime lastHours = DateTime.now().addHours(-1);

    //    List<ContentDocument> cd= [select Id, Title, ParentId from ContentDocument where ParentId IN (select Id from ContentWorkspace where Name ='ICX Export Transactions')];
    // CreatedDate >: last24Hours And 
     
          List<Export_Purchases_Tracability__c> cd= [SELECT versionId__c, Status__c ,contentDocumentId__c,CreatedDate FROM  Export_Purchases_Tracability__c Where versionId__c!= null];
        //   List<Export_Purchases_Tracability__c> cd= [SELECT versionId__c, Status__c FROM Export_Purchases_Tracability__c ];
        System.debug('cd --> '+cd);
        // return Database.getQueryLocator([select Id, Title, ParentId,LatestPublishedVersionId from ContentDocument where ParentId IN (select Id from ContentWorkspace where Name ='ICX Export Transactions')]);
        return Database.getQueryLocator([SELECT versionId__c,contentDocumentId__c, Status__c FROM Export_Purchases_Tracability__c Where versionId__c!= null]);
        
    }
    global void execute(Database.BatchableContext BC, List<Export_Purchases_Tracability__c > scope)
    {
         List<String>idsOfPurchasesList = new List<String>();
         for(Export_Purchases_Tracability__c s:scope)
         {
            idsOfPurchasesList.add(s.contentDocumentId__c);
         }
         System.debug('idsOfPurchasesList --> ' + idsOfPurchasesList);
         List<ContentDocument>ContentDocumentListToDelete = new List<ContentDocument>();
         List<ContentDocument>ContentDocumentRetrieved = [select Id from ContentDocument Where Id IN:idsOfPurchasesList];
         for(ContentDocument CDR:ContentDocumentRetrieved)
         {
            ContentDocumentListToDelete.add(CDR);
         }
         delete ContentDocumentListToDelete;
      
        System.debug('scope --> '+scope);
        List<Export_Purchases_Tracability__c>exportListtoUpdate = new List<Export_Purchases_Tracability__c>();
        for(Export_Purchases_Tracability__c updateExportState:scope)
        {
           if(updateExportState.Status__c =='Ready To Download')
           {
               updateExportState.Status__c = 'Expired';
               exportListtoUpdate.add(updateExportState);
            }
        }
        update exportListtoUpdate;
    }
    global void finish(Database.BatchableContext BC) {
    }


    global void execute(SchedulableContext sc) {
        ICX_DeletePurchasesExportBatch b = new ICX_DeletePurchasesExportBatch(); 
        database.executebatch(b);
    }

}