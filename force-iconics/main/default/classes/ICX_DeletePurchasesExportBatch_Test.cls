@isTest 
private class ICX_DeletePurchasesExportBatch_Test {

    @isTest static void deleteExportFiles()
    {
        Id profileId =[select Id from Profile where Name = 'ICONiCS_SA'].Id;

        User use = ICX_TestFactory.createUser(profileId);
        insert use;
        Id useId = use.id;

        system.runAs(use){

        // Account acct = ICX_TestFactory.createAccount();
        // insert acct;
        // Id acctId = acct.Id;
        Integer listLength = 1;

        List<ContentVersion> con = ICX_TestFactory.createContentVersion(listLength,useId);
        insert con;
        System.debug('Display the contentVersion'+con[0]);
        System.debug('Display the contentVersion==>>'+con[0].Id);
        Id versionId = con[0].Id;
        // System.debug('Display the contentVersion====>>>>'+con[0].ContentDocumentId);
        Id documentId = con[0].ContentDocumentId;
        documentId = [SELECT ContentDocumentId FROM ContentVersion Where Id =:versionId LIMIT 1].ContentDocumentId;
        System.debug('Display the contentVersion====>>>>>>>>>>>>>>>>>>'+  documentId);
       

        List<Export_Purchases_Tracability__c> ept = ICX_TestFactory.createExportPurchasesTracability(listLength,'1234',useId,versionId);
        System.debug('Display the contentVersion'+ept[0].DreamId__c);
        insert ept;

       
         Test.startTest();
         ICX_DeletePurchasesExportBatch dp = new ICX_DeletePurchasesExportBatch();
         Database.executeBatch(dp,3);
        //  DeletePurchasesExportBatch.execute(dp,contDoc);
         Test.stopTest();
        }
    }
}