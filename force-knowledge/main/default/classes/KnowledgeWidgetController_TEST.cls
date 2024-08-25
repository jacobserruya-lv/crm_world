@isTest
public with sharing class KnowledgeWidgetController_TEST{
    
    @isTest
    static void searchKnowledgeArticles(){
        Test.startTest(); 
        
        List<RecordType> knowledgeRecordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND SobjectType = 'Knowledge__kav' ORDER BY DeveloperName ASC];
        
        system.debug('knowledgeRecordTypes  ==>  '+knowledgeRecordTypes);
        
        Id recordTypeExternalId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('External').getRecordTypeId();
		Id recordTypeInternalId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        
        system.debug('recordTypeExternalId  ==>  '+recordTypeExternalId);
        
       system.debug('recordTypeInternalId  ==>  '+recordTypeInternalId);
        
        Knowledge__kav aKnowledge = new Knowledge__kav();
            aKnowledge.Title='Test knowledge widget in action';
            aKnowledge.Summary='Searching article for Customer Agent';
            aKnowledge.Article_Body__c='Apex test article creation, is shown how to use knowledge Widget';
            aKnowledge.Themes__c='Services';
            aKnowledge.Client_Service__c='';
            aKnowledge.Website__c='en_e1;';
            aKnowledge.UrlName='test-knowledgewidget-in-action';
            aKnowledge.RecordTypeId=knowledgeRecordTypes[0].Id;
        insert aKnowledge;
        
       system.debug('knowledgeRecordTypes[0].Id  ==> '+knowledgeRecordTypes[0].Id + ' <==> knowledgeRecordTypes[0].DeveloperName  ==> '+knowledgeRecordTypes[0].DeveloperName);
        
        Knowledge__kav anInternalKnowledge = new Knowledge__kav();
        	anInternalKnowledge.Title='Test rank in action';
        	anInternalKnowledge.Summary='Searching article for Customer Agent';
        	anInternalKnowledge.Article_Body__c='Apex article creation, is shown how to use knowledge widget';
        	anInternalKnowledge.Themes__c='Orders';
        	anInternalKnowledge.Client_Service__c='Europe';
        	anInternalKnowledge.Website__c='';
            anInternalKnowledge.UrlName='test-widget-search';
        	anInternalKnowledge.RecordTypeId=knowledgeRecordTypes[1].Id; 
        insert anInternalKnowledge;
        
       system.debug('After Insertion <==> knowledgeRecordTypes[1].Id  ==> '+knowledgeRecordTypes[1].Id + ' <==> knowledgeRecordTypes[1].DeveloperName  ==> '+knowledgeRecordTypes[1].DeveloperName);
        
        // A Knowledge article inserted
        Knowledge__kav insertedKnowledge = [SELECT Id, Title,Themes__c, Client_Service__c, Website__c, RecordTypeId, RecordType.DeveloperName, CreatedDate FROM Knowledge__kav WHERE Id = :aKnowledge.Id];
        Knowledge__kav internalInsertedKnowledge = [SELECT Id, Title,Themes__c, Client_Service__c, Website__c, RecordTypeId, RecordType.DeveloperName, CreatedDate FROM Knowledge__kav WHERE Id = :anInternalKnowledge.Id];

        // A knowledge article not found
        List<SObject> foundArticles = KnowledgeWidgetController.knowledgeArticles('widget', knowledgeRecordTypes[0].DeveloperName, '');

        // A knowledge article found
        List<Knowledge__kav> kFoundArticles = KnowledgeWidgetController.knowledgeArticles('test', 'All', '');

        // A knowledge article found
        List<Knowledge__kav> internalFoundArticles = KnowledgeWidgetController.knowledgeArticles('rank', knowledgeRecordTypes[1].DeveloperName, 'Europe');  
        
        Test.stopTest();

        system.assertNotEquals(null, insertedKnowledge.Id);
        system.debug('External article inserted, is ===>>  ' +insertedKnowledge+ ' and Knowledge Id is ==>> ' +insertedKnowledge.Id);
        
        system.assertNotEquals(null, internalInsertedKnowledge.Id);
        system.debug('Internal article inserted ==>> ' +internalInsertedKnowledge + ' internal article knowledge Id ==>> ' +internalInsertedKnowledge.Id);

        system.assertNotEquals(1, foundArticles.size());
        system.debug('Found Articles size ==>> ' +foundArticles.size() + ' article ===>> ' +foundArticles.toString());
        
        system.assertNotEquals(1, kFoundArticles.size());
        system.debug('Found Articles size ==>> ' +kFoundArticles.size() + ' article ===>> ' +kFoundArticles.toString());

        system.assertNotEquals(1, internalFoundArticles.size());
        system.debug('Found Articles size ==>> ' +internalFoundArticles.size() + ' article ===>> ' +internalFoundArticles.toString()); 
    }
    
    @isTest
    static void searchKnowledgeRecordTypes(){
        // Existing RecordTypes
        List<String> knowledgeRecordTypesValues = KnowledgeWidgetController.knowledgeRecordTypes();
        system.assertEquals(2, knowledgeRecordTypesValues.size(),'Success');
        system.debug('Existing RecordTypes : knowledgeRecordTypesValues <===> ' +knowledgeRecordTypesValues);
    }
}