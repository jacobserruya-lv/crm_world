@isTest
private class IC_BatchDeleteOldInterestFiles_TEST {
    
    @isTest
    static void Class_Test_Method()
    {
        List<Document> testDocuments = new List<Document>();
        
        For(integer i=0; i<5; i++){
            Document doc = new Document();
            doc.Name = 'interest'+i;
            doc.Description = i+'Processed';
            doc.FolderId = UserInfo.getUserId();
            testDocuments.add(doc);
        }
		
        Document oldDoc1 = new Document();
        oldDoc1.Name = 'interestOld1';
        oldDoc1.Description = 'Old1Processed';
        oldDoc1.FolderId = UserInfo.getUserId();
        
        Document oldDoc2 = new Document();
        oldDoc2.Name = 'interestOld2';
        oldDoc2.Description = 'Old2Processed';
        oldDoc2.FolderId = UserInfo.getUserId();
        
        testDocuments.add(oldDoc1);
        testDocuments.add(oldDoc2);

        insert(testDocuments);
        
        For(Document doc: testDocuments){
        	Test.setCreatedDate(doc.Id, System.now().addDays(-3));
        }
        
        List<Document> testDocuments_final = [select Id, name, description, createdDate From Document];
        //System.debug('Test Documents: '+testDocuments);

        System.debug('test Documents_final: '+testDocuments_final);
        
/*        
        Database.update(testDocuments);
        System.debug('Test Documents: '+testDocuments);
*/
        IC_BatchDeleteOldInterestFiles batch = new IC_BatchDeleteOldInterestFiles();
        
        Test.startTest();


        ID batchJobId = Database.executeBatch(batch);
        
        Test.stopTest();
        
        List<Document> remainingDocuments = [Select Id FROM Document WHERE Id IN :testDocuments_final];
        System.assertEquals(0, remainingDocuments.size(), 'all old interest documents are deleted');
        
    }
}