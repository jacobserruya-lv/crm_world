/*
* Test Class of the LTN_FileContent Class
* @createdBy   Ahlem AYARI
*/
@isTest
public class LTN_FileContent_TEST {

    @isTest
    public static void getFileContentTest(){
        //ContentDocumentLink exists
        Account testAccount = IC_TestFactory.createAccount();
        insert(testAccount);
        String emptyFileContent = LTN_FileContent.getFileContent(testAccount.Id);
        System.assertEquals(null, emptyFileContent, 'fileContent is null');

        ContentVersion testContentVersion = createContentVersion('Test File Content');
        insert testContentVersion;

        testContentVersion = [Select ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id Limit 1];
        createContentDocumentLink(testAccount.Id, testContentVersion.ContentDocumentId);
        
        
        String fileContent = LTN_FileContent.getFileContent(testAccount.Id);
        
        
        System.assertEquals('Test File Content', fileContent);
        
    }
    
    @isTest
    public static void testUpdateFileContent(){
        Account testAccount2 = IC_TestFactory.createAccount();
        insert testAccount2;

        ContentVersion testContentVersion2 = createContentVersion('Updated File Content');
        insert testContentVersion2;
        testContentVersion2 = [Select ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion2.Id Limit 1];

        createContentDocumentLink(testAccount2.Id, testContentVersion2.ContentDocumentId);
                
        LTN_FileContent.updateFileContent(testAccount2.Id, 'Updated File Content');
        
        String updatedFileContent = LTN_FileContent.getFileContent(testAccount2.Id);
        System.assertEquals('Updated File Content', updatedFileContent);
    }

    private static ContentVersion createContentVersion(String content){
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.VersionData = Blob.valueOf(content);
        contentVersion.Title = 'File';
        contentVersion.PathOnClient = 'File.txt';

        return contentVersion;
    }
       
    private static void createContentDocumentLink(Id recordId, Id contentDocumentId){
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.LinkedEntityId = recordId;
        contentDocumentLink.ContentDocumentId = contentDocumentId;
        contentDocumentLink.ShareType = 'V';
        contentDocumentLink.Visibility = 'AllUsers';
        
        insert(contentDocumentLink);
    }
    /*
    @isTest
    static void testUpdateFileContent_Exception(){
        
        Account testAccount3 = IC_TestFactory.createAccount();
        insert testAccount3;
        
        ContentVersion testContentVersion3 = createContentVersion('TestException File Content');
        insert testContentVersion3;
        testContentVersion3 = [Select ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion3.Id Limit 1];

        createContentDocumentLink(testAccount3.Id, testContentVersion3.ContentDocumentId);
        Test.startTest();
        try{
        	LTN_FileContent.updateFileContent('', '');
            
        }catch(Exception e){
            String resultMessage = e.getMessage();
            System.assertEquals('Invalid id', resultMessage);
        }
        Test.stopTest();
    }
*/
    
}