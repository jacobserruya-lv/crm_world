@isTest
public class ICX_EmailUploadedFiles_TEST {
    @testSetup static void setup(){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Penguins';
        contentVersion.PathOnClient = 'Penguins.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        contentVersion.origin = 'H';
        insert contentVersion;
    }

    @isTest static void testMethod1(){
      List<ContentDocument> documents = [SELECT Id FROM ContentDocument limit 1];
      boolean status = ICX_EmailUploadedFiles.deleteAttachments(documents[0].id);
      system.assertEquals(status,true);
    }
    @isTest static void testMethod2(){
      boolean status = ICX_EmailUploadedFiles.deleteAttachments(null);
      system.assertEquals(status,false);
    }


}