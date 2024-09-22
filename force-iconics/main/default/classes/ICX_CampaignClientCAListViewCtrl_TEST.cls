@isTest
public class ICX_CampaignClientCAListViewCtrl_TEST {

     @testSetup
    public static void setupData(){
        Id profileManagerId = [SELECT Id FROM Profile WHERE Name = 'ICONiCS_SA_Manager' LIMIT 1][0].Id;
        User testUser = ICX_TestFactory.createUser(profileManagerId);
        insert testUser;
        
		Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        Id AccId = [SELECT Id FROM Account LIMIT 1][0].Id;
        
        Campaign__c cam = ICX_TestFactory.createCampaign();
        insert cam;
        
        Campaign__c camTest = [SELECT Id FROM Campaign__c LIMIT 1];   
		User caTest = [SELECT Id FROM User LIMIT 1];    
        
        CampaignMember__c camMember = ICX_TestFactory.createCampaignMember(camTest.Id, caTest.Id, AccId);
        insert camMember;
    }
    
    @isTest
    public static void getCAList_TEST(){
        Campaign__c camTest = [SELECT Id FROM Campaign__c LIMIT 1];  
        
        List<Map<String, String>> caList = new List<Map<String, String>>();
        Test.startTest();
        ICX_CampaignClientCAListViewController.getCAList(camTest.Id);
        Test.stopTest();
        
        
    }
}