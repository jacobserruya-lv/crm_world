@isTest
public class ICX_CampaignGeneralInformationCtrl_TEST {


    @isTest 
    public static void getContentVersion_TEST() {

        Campaign__c currentCampaign = new Campaign__c();
        insert currentCampaign;

        


        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Penguins';
        contentVersion.PathOnClient = 'Penguins.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        contentVersion.origin = 'H';
        insert contentVersion;

        ContentVersion currentContentVersion = [SELECT ID,ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id];


        ContentDocumentLink currentContentLink = new ContentDocumentLink();
        currentContentLink.ContentDocumentId = currentContentVersion.ContentDocumentId;
        currentContentLink.LinkedEntityId = currentCampaign.Id;
        insert currentContentLink;

        Test.startTest();
        List<ContentVersion> contentVersionList = ICX_CampaignGeneralInformationController.getContentVersion(new List<String>{currentContentVersion.ContentDocumentId});
        Test.stopTest();
        System.assertEquals(contentVersion.Id,contentVersionList[0].Id);
    }


}