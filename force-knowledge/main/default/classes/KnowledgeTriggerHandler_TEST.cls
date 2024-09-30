@isTest
public with sharing class  KnowledgeTriggerHandler_TEST{
    @isTest 
    static void handleBeforeInsertTest_Case1LatinesWebsites(){
        Knowledge__kav aKnowledge = new Knowledge__kav();
        aKnowledge.Title='Création d\'un test pour un cœur malade en français';
        aKnowledge.Article_Body__c ='Apex test article création pour l\'usage d\'un cœur malade dans la vie.';
        aKnowledge.Client_Service__c='';
        aKnowledge.Themes__c ='Orders';
        aKnowledge.Website__c ='fr_fr;fr_ca';
        aKnowledge.UrlName= 'Création-un-test-pour-un-cœur-malade-en-français';
        insert aKnowledge;
        // A Knowledge inserted
        Knowledge__kav insertedKnowledge = [SELECT Id, UrlName, Themes__c, Client_Service__c, Website__c, CreatedDate FROM Knowledge__kav WHERE Id = :aKnowledge.Id];
        System.assertEquals(insertedKnowledge.Id, aKnowledge.Id);
        System.debug('<<==  UrlName of Latine Website inserted - in method handleBeforeInsertTest_Case1LatinesWebsites()-, is ===>>>  ' +insertedKnowledge.UrlName);
        System.debug('<<==  Inserted Knowledge Article on Latine Website - in method handleBeforeInsertTest()-, is ===>>>  ' +insertedKnowledge);  
    }
    @isTest 
    static void handleBeforeInsertTest_Case2NotLatinesWebsite(){
        Knowledge__kav knowledgeArticle = new Knowledge__kav();
        knowledgeArticle.Title='路易威登如何打擊假冒偽劣?';
        knowledgeArticle.Article_Body__c='打擊假冒偽劣是路易威登全球持續發展策略的重要一環。路易威登認為，反擊侵犯人權、環境和全球經濟的非法網路，對維持品牌世代傳承的專業知識和工匠的製作至關重要';
        knowledgeArticle.Client_Service__c='';
        knowledgeArticle.Themes__c='Corporate_information';
        knowledgeArticle.Website__c='zh_cn;zh_hk';
        knowledgeArticle.UrlName= 'Article-url-must-be-changed-on-latin-one';
        insert knowledgeArticle;
        Knowledge__kav anInsertedKnowledge = [SELECT Id, UrlName, Themes__c, Client_Service__c, Website__c, CreatedDate FROM Knowledge__kav WHERE Id = :knowledgeArticle.Id];
        System.assertEquals(knowledgeArticle.Id, anInsertedKnowledge.Id);
        System.debug('<<==  UrlName of Non Latine Website inserted - handleBeforeInsertTest_Case2NonLatinesWebsites()-, is ===>>>  ' +anInsertedKnowledge.UrlName);
        System.debug('<<==  Inserted Knowledge Article on Not Latine Website - in method handleBeforeInsertTest()-, is ===>>>  ' +anInsertedKnowledge);
    }
    @isTest 
    static void handleBeforeUpdateTest_CaseWebsite(){
        Knowledge__kav aKnowledgeToUpdate = new Knowledge__kav();
        aKnowledgeToUpdate.Title='Test Apex';
        aKnowledgeToUpdate.Article_Body__c='Apex test article creation';
        aKnowledgeToUpdate.Client_Service__c='';
        aKnowledgeToUpdate.Themes__c ='Orders';
        aKnowledgeToUpdate.Website__c ='en_sg;en_au;en_e1';
        aKnowledgeToUpdate.UrlName='Test-Apex';
        insert aKnowledgeToUpdate;
        // A Knowledge to update
        Knowledge__kav knowledgeToUpdate = [SELECT Id, UrlName, Themes__c, Client_Service__c, Website__c, CreatedDate FROM Knowledge__kav WHERE Id = :aKnowledgeToUpdate.Id LIMIT 1];
        knowledgeToUpdate.Id = aKnowledgeToUpdate.Id;
        knowledgeToUpdate.Title='Test Apex';
        knowledgeToUpdate.Article_Body__c='Apex test, update an existing article';
        knowledgeToUpdate.Client_Service__c='';
        knowledgeToUpdate.Themes__c='Corporate_information';
        knowledgeToUpdate.Website__c='en_sg;en_au';
        knowledgeToUpdate.UrlName='Test-Apex';
        update knowledgeToUpdate;
        // A Knowledge updated
        Knowledge__kav updatedKnowledge = [SELECT Id, UrlName, Themes__c, Client_Service__c, Website__c, CreatedDate FROM Knowledge__kav WHERE Id = :knowledgeToUpdate.Id];
        System.assertEquals(knowledgeToUpdate.Id, updatedKnowledge.Id);
        System.debug('<<==  UrlName of Not Latine Website updated - handleBeforeInsertTest_Case2NonLatinesWebsites()-, is ===>>>  ' +updatedKnowledge.UrlName);
        System.debug('<<==  Inserted Knowledge Article on Latine Website - in method handleBeforeInsertTest()-, is ===>>>  ' +updatedKnowledge);  
    }
    @isTest 
    static void handleBeforeUpdateTest_CaseOnLatineClientService(){
        Knowledge__kav aKnowledgeUpdated = new Knowledge__kav();
        aKnowledgeUpdated.Title='Test Apex Client Service';
        aKnowledgeUpdated.Article_Body__c='Apex test article internal creation';
        aKnowledgeUpdated.Client_Service__c='Australia';
        aKnowledgeUpdated.Themes__c ='Orders';
        aKnowledgeUpdated.Website__c ='';
        aKnowledgeUpdated.UrlName='Test-Apex-Client-Service';
        insert aKnowledgeUpdated;      
        // A Knowledge to update
        Knowledge__kav knowledgeForUpdate = [SELECT Id, UrlName, Themes__c, Client_Service__c, Website__c, CreatedDate FROM Knowledge__kav WHERE Id = :aKnowledgeUpdated.Id LIMIT 1];
        knowledgeForUpdate.Id = aKnowledgeUpdated.Id;
        knowledgeForUpdate.Title='Test Apex for Client Service';
        knowledgeForUpdate.Article_Body__c='Apex test, update an existing article';
        knowledgeForUpdate.Client_Service__c='Australia';
        knowledgeForUpdate.Themes__c='Services';
        knowledgeForUpdate.Website__c='';
        knowledgeForUpdate.UrlName='Test-Apex-For-Client-Service';
        update knowledgeForUpdate;
        // A Knowledge updated
        Knowledge__kav updatedKnowledgeCS = [SELECT Id, UrlName, Themes__c, Client_Service__c, Website__c, CreatedDate FROM Knowledge__kav WHERE Id = :knowledgeForUpdate.Id];
        System.assertEquals(knowledgeForUpdate.Id, updatedKnowledgeCS.Id);
        System.debug('<<==  UrlName of Latine Client Service updated - handleBeforeUpdateTest_CaseOnLatineClientService()-, is ===>>>  ' +updatedKnowledgeCS.UrlName);
        System.debug('<<==  Inserted Knowledge Article on Latine Client Service - in method handleBeforeUpdateTest_CaseOnLatineClientService()-, is ===>>>  ' +updatedKnowledgeCS);          
    }
    @isTest static void handleAfterInsertTest_Case1Website(){
        Knowledge__kav aKnowledge = new Knowledge__kav();
        aKnowledge.Title='Test Apex';
        aKnowledge.Article_Body__c='Apex test article creation';
        aKnowledge.Client_Service__c='';
        aKnowledge.Themes__c ='Orders';
        aKnowledge.Website__c ='en_sg;en_au;en_e1';
        aKnowledge.UrlName='Test-Apex';
        insert aKnowledge;
        // A Knowledge inserted
        Knowledge__kav insertedKnowledge = [SELECT Id, UrlName, Themes__c, Client_Service__c, Website__c, CreatedDate FROM Knowledge__kav WHERE Id = :aKnowledge.Id];
        System.assertEquals(insertedKnowledge.Id, aKnowledge.Id);
        System.debug('<<==  Knowledge inserted, is ===>>>  ' +insertedKnowledge+ ' and Knowledge Id is ==>>> ' +aKnowledge.Id);
    }
    @isTest static void handleAfterInsertTest_Case2ClientService(){
        Knowledge__kav aKnowledgeArticle = new Knowledge__kav();
        aKnowledgeArticle.Title='Test Apex article';
        aKnowledgeArticle.Article_Body__c='Apex test article creation';
        aKnowledgeArticle.Client_Service__c='USA';
        aKnowledgeArticle.Themes__c ='Orders';
        aKnowledgeArticle.Website__c ='';
        aKnowledgeArticle.UrlName='Test-Apex-article';
        insert aKnowledgeArticle;
        // A Knowledge inserted
        Knowledge__kav insertedKnowledgeArticle = [SELECT Id, UrlName, Themes__c, Client_Service__c, Website__c, CreatedDate FROM Knowledge__kav WHERE Id = :aKnowledgeArticle.Id];
        System.assertEquals(aKnowledgeArticle.Id, insertedKnowledgeArticle.Id);
        System.debug('<<==  Knowledge inserted, is ===>>>  ' +insertedKnowledgeArticle+ ' and Knowledge Id is ==>>> ' +insertedKnowledgeArticle.Id);
    }
    @isTest static void handleAfterUpdateTest(){
        Knowledge__kav aKnowledgeToUpdate = new Knowledge__kav();
        aKnowledgeToUpdate.Title='Test Apex';
        aKnowledgeToUpdate.Article_Body__c='Apex test article creation';
        aKnowledgeToUpdate.Client_Service__c='';
        aKnowledgeToUpdate.Themes__c ='Orders';
        aKnowledgeToUpdate.Website__c ='en_sg;en_au;en_e1';
        aKnowledgeToUpdate.UrlName='Test-Apex';
        insert aKnowledgeToUpdate;
        // A Knowledge to update
        Knowledge__kav knowledgeToUpdate = [SELECT Id, UrlName, Themes__c, Client_Service__c, Website__c, CreatedDate FROM Knowledge__kav WHERE Id = :aKnowledgeToUpdate.Id LIMIT 1];
        knowledgeToUpdate.Id = aKnowledgeToUpdate.Id;
        knowledgeToUpdate.Title='Test Apex';
        knowledgeToUpdate.Article_Body__c='Apex test, update an existing article';
        knowledgeToUpdate.Client_Service__c='Australia';
        knowledgeToUpdate.Themes__c='Corporate_information';
        knowledgeToUpdate.Website__c='';
        knowledgeToUpdate.UrlName='Test-Apex';
        update knowledgeToUpdate;
        // A Knowledge updated
        Knowledge__kav updatedKnowledge = [SELECT Id, UrlName, Themes__c, Client_Service__c, Website__c, CreatedDate FROM Knowledge__kav WHERE Id = :knowledgeToUpdate.Id];
        System.assertEquals(knowledgeToUpdate.Id, updatedKnowledge.Id);
    } 
    
    
    @isTest static void handleWorlwideArticlesBeforeInsert(){
        Id RCInternal = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Internal').getRecordTypeId();
        
        Knowledge__kav aKnowledgeToInsert = new Knowledge__kav();
        aKnowledgeToInsert.Title='Test Apex';
        aKnowledgeToInsert.Article_Body__c='Apex test article creation';
        aKnowledgeToInsert.Client_Service__c='Worldwide';
        aKnowledgeToInsert.Themes__c ='Orders';
        aKnowledgeToInsert.Website__c ='fr_fr';
        aKnowledgeToInsert.UrlName='Test-Apex';
        aKnowledgeToInsert.RecordTypeId = RCInternal;

        insert aKnowledgeToInsert;

    
        Knowledge__kav insertedKnowledge = [SELECT Id, UrlName, Themes__c, Client_Service__c, Website__c, CreatedDate FROM Knowledge__kav WHERE Id = :aKnowledgeToInsert.Id];

        System.assert(insertedKnowledge.Client_Service__c.split(';').contains('Europe'));

    }  

    @isTest static void handleWorlwideArticlesBeforeUpdate(){
        Id RCInternal = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Internal').getRecordTypeId();
    

        Knowledge__kav aKnowledgeToUpdate = new Knowledge__kav();
        aKnowledgeToUpdate.Title='Test Apex';
        aKnowledgeToUpdate.Article_Body__c='Apex test article creation';
        aKnowledgeToUpdate.Client_Service__c='Europe';
        aKnowledgeToUpdate.Themes__c ='Orders';
        aKnowledgeToUpdate.Website__c ='fr_fr';
        aKnowledgeToUpdate.UrlName='Test-Apex';
        aKnowledgeToUpdate.RecordTypeId = RCInternal;

        insert aKnowledgeToUpdate;

        // A Knowledge to update
        Knowledge__kav knowledgeToUpdate = [SELECT Id, UrlName, Themes__c, Client_Service__c, Website__c, CreatedDate FROM Knowledge__kav WHERE Id = :aKnowledgeToUpdate.Id LIMIT 1];
        knowledgeToUpdate.Id = aKnowledgeToUpdate.Id;
        knowledgeToUpdate.Article_Body__c='Apex test, update an existing article';
        knowledgeToUpdate.Client_Service__c='Worldwide';
        update knowledgeToUpdate;
        // A Knowledge updated

    
        Knowledge__kav updatedKnowledge = [SELECT Id, UrlName, Themes__c, Client_Service__c, Website__c, CreatedDate FROM Knowledge__kav WHERE Id = :knowledgeToUpdate.Id];

        System.assert(updatedKnowledge.Client_Service__c.split(';').contains('Europe'));

    }  

  /*   @isTest */
  /*   static void UpdatePublicVisibilityForExternal_TEST() */
  /*   { */
  /*       Id ExternalRTId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('External').getRecordTypeId(); */
  /*       Id InternalRTId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Internal').getRecordTypeId(); */

  /*       List<id> knowledgeListId = new List<id>(); */

  /*       Knowledge__kav aKnowledge = new Knowledge__kav(); */
  /*       aKnowledge.Title='Création d\'un test pour un cœur malade en français'; */
  /*       aKnowledge.Article_Body__c ='Apex test article création pour l\'usage d\'un cœur malade dans la vie.'; */
  /*       aKnowledge.Client_Service__c=''; */
  /*       aKnowledge.Themes__c ='Orders'; */
  /*       aKnowledge.Website__c ='fr_fr;fr_ca'; */
  /*       aKnowledge.UrlName= 'Création-un-test-pour-un-cœur-malade-en-français'; */
  /*       aKnowledge.recordTypeId=ExternalRTId; */

  /*       Knowledge__kav aKnowledge2 = new Knowledge__kav(); */
  /*       aKnowledge2.Title='Création d\'un test pour un cœur malade en français2'; */
  /*       aKnowledge2.Article_Body__c ='Apex test article création pour l\'usage d\'un cœur malade dans la vie.'; */
  /*       aKnowledge2.Client_Service__c=''; */
  /*       aKnowledge2.Themes__c ='Orders'; */
  /*       aKnowledge2.Website__c ='fr_fr;fr_ca'; */
  /*       aKnowledge2.UrlName= 'Création-un-test-pour-un-cœur-malade-en-français2'; */
  /*       aKnowledge2.recordTypeId=InternalRTId; */

  /*       Test.startTest(); */

  /*       insert aKnowledge; */
  /*       insert aKnowledge2; */
  /*       aKnowledge2.recordTypeId=ExternalRTId; */
  /*       update aKnowledge2; */
  /*       Test.stopTest(); */

  /*       knowledgeListId.add(aKnowledge.id); */
  /*       knowledgeListId.add(aKnowledge2.id); */

  /*       List<Knowledge__kav> newKnowledgeList = [SELECT ID,RecordTypeId,IsVisibleInPkb FROM Knowledge__kav WHERE Id IN:knowledgeListId]; */
  /*      // Knowledge__kav newKnowledge2 = [SELECT ID,RecordTypeId,IsVisibleInPkb FROM Knowledge__kav WHERE Id =:aKnowledge2.Id]; */

  /*       System.assertEquals(newKnowledgeList[0].IsVisibleInPkb,true); */
  /*       System.assertEquals(newKnowledgeList[1].IsVisibleInPkb,true); */

  /*   } */
}