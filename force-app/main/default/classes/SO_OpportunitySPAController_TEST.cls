@isTest
public with sharing class SO_OpportunitySPAController_TEST {
    @TestSetup
    static void init() {
        Store__c st = LV_TestFactory.createStore('LV TEST STORE MIY', 'Store', 'A00', 'FRANCE', 'EUR', 'Open');
		st.MANAGEMENT_ZONE_LEVEL__c = '15';
		insert st;

		Account client = LV_TestFactory.createAccount();
        insert client;

        Profile p = [SELECT id FROM profile WHERE id=:IC_Utils.getSAProfile()];
        User u = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id,
				TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminUser@testlv.com');
        insert u;

        Opportunity mypOrder = LV_TestFactory.createOrder('MY Neverfull bag', 'Creation in progress', null, st.id, client.id, null, null, 'PERSO');
        mypOrder.ownerId = u.Id;
        insert mypOrder;
        
        SO_Settings__c setting = new SO_Settings__c(Name='NewOpportunityCloseDate', Value__c='0');
        insert setting;
        SO_Settings__c setting1 = new SO_Settings__c(Name='DummyProduct', Value__c='1');
        insert setting1;
        
        // ProductCatalogue__c pc = LV_TestFactory.createProductCatalog('MY NEVERFULL', 'P0001', 3, 15, 5, 'Leather Goods');
        // insert pc;
        
        ProductReferential__c pr = LV_TestFactory.createProductReferential('MY PRODUCT REF', 'P0001');
        insert pr;
    }
    
    @isTest
    static void test_getMethodes() {
        SO_OpportunitySPAController.getUser();
        SO_OpportunitySPAController.getStoreJson();
        SO_OpportunitySPAController.getSPAPersonalizationJson();
        SO_OpportunitySPAController.getUserProfile();
        SO_OpportunitySPAController.getSessionId();
        SO_OpportunitySPAController.getProductNotFound();
        SO_OpportunitySPAController.getIsMTOEnabled();
        SO_OpportunitySPAController.getNewFile();
        // SO_OpportunitySPAController.getAllUsersDB();
        SO_OpportunitySPAController.getOrderSettings();
        SO_OpportunitySPAController.getDummyProductDB();
    }

    @isTest
    static void test_saveOppWithFiles() {
        Account client = [SELECT Id, IsProspect__pc, ProspectForDream__c FROM Account LIMIT 1];
        Store__c st = [SELECT Id FROM Store__c LIMIT 1];
        User user = [SELECT Id FROM User LIMIT 1];

        Date closeDate = System.today().adddays(100);
		Opportunity opp1 = new Opportunity(Name = 'test',
											StageName = 'Creation in progress',
											ApplicationSource__c = 'SPO',
											SPO_BaseSKURefmodelSKU__c = null, // for SPO only
											AccountId = client.id, // for non display order
											SPO_Store__c = st.id,
											SPO_OrderType__c = null, // for SPO only
											SPO_ProductCategory__c = null, // for SPO only
                                            CloseDate = closeDate,
                                            ownerId = user.Id
										);

        Opportunity order = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];
        Id attachmentId1 = SO_OpportunitySPAController.createAttachment(order.Id, 'FILE_NAME', '0000000', 'jpg');

        SO_OpportunitySPAController.FileContent fileContent1 = SO_OpportunitySPAController.getNewFile(); 
        SO_OpportunitySPAController.FileContent fileContent2 = SO_OpportunitySPAController.getNewFile();
        fileContent1.base64Data = 'base64Data';
        fileContent1.contentType = 'fileContent';
        fileContent1.createdDate = System.now();
        fileContent1.fileId = attachmentId1;

        List<SO_OpportunitySPAController.FileContent> fileContentList = new List<SO_OpportunitySPAController.FileContent>{fileContent1, fileContent2};
        String listFilesJSON = JSON.serialize(fileContentList);

        Opportunity opp2 = SO_OpportunitySPAController.saveOppWithFiles(opp1, client, listFilesJSON, 'validate');

        try{
            Opportunity opp3 = SO_OpportunitySPAController.saveOppWithFiles(null, client, listFilesJSON, 'validate');
        }
        catch(Exception error){
            System.assertEquals('Script-thrown exception', error.getMessage());
        }
    }

    @isTest
    static void test_updateOpp() {
        Opportunity mypOrder = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];
        SO_OpportunitySPAController.updateOpp(mypOrder);
    }
    @isTest
    static void test_saveOpp() {
        Account client = [SELECT Id, IsProspect__pc, ProspectForDream__c FROM Account LIMIT 1];
        Store__c st = [SELECT Id FROM Store__c LIMIT 1];
        Date closeDate = System.today().adddays(100);
        
        Opportunity opp1 = new Opportunity(Name = 'test1',
                                    SPO_BaseSKURefmodelSKU__c = null, // for SPO only
                                    AccountId = client.id, // for non display order
                                    SPO_Store__c = st.id,
                                    SPO_OrderType__c = 'Creation (Hardsided & Soft)', // for SPO only
                                    SPO_ProductCategory__c = null, // for SPO only
                                    CloseDate = closeDate,
                                    SPO_DisplayOrder__c = false,
                                    SPO_LiningInteriorMaterial2__c = 'exo',
                                    SPO_Exo__c = 'Yes'
        );
        
        Opportunity opp2 = new Opportunity(Name = 'test2',
                                    SPO_BaseSKURefmodelSKU__c = null,
                                    AccountId = client.id,
                                    SPO_Store__c = st.id,
                                    SPO_ProductCategory__c = null,
                                    CloseDate = closeDate,
                                    SPO_OrderType__c = 'MTO on Catalog (Hardsided)',
                                    SPO_DisplayOrder__c = true,
                                    SPO_Exo__c = 'No'
        );

        Opportunity savedOpp1 = SO_OpportunitySPAController.saveOpp(LV_TestFactory.createOrder('MY Neverfull bag', 'Creation in progress', null, st.id, client.id, null, null, 'SPO'), client, 'validate');
        Opportunity savedOpp2 = SO_OpportunitySPAController.saveOpp(opp1, client, 'validate');
        // Opportunity savedOpp3 = SO_OpportunitySPAController.saveOpp(opp2, client, 'validate');
    }

    @isTest
    static void test_saveOpp2() {
        Account client = [SELECT Id, IsProspect__pc, ProspectForDream__c FROM Account LIMIT 1];
        Store__c st = [SELECT Id FROM Store__c LIMIT 1];
        Date closeDate = System.today().adddays(100);
        Opportunity opp4 = new Opportunity(Name = 'test4',
                                StageName = 'Creation in progress',
                                ApplicationSource__c = 'SPO',
                                SPO_BaseSKURefmodelSKU__c = null,
                                AccountId = client.id,
                                SPO_Store__c = st.id,
                                SPO_ProductCategory__c = null,
                                CloseDate = closeDate,
                                SPO_OrderType__c = 'Creation (Hardsided & Soft)'
                            );
        SO_OpportunitySPAController.saveOpp(opp4, client, 'validate and request for quataion');

    }

    @isTest
    static void test_getStore() {
        Store__c st = [SELECT Id, RetailStoreId__c FROM Store__c LIMIT 1];
        SO_OpportunitySPAController.getStore(st.RetailStoreId__c);
        SO_OpportunitySPAController.getStoreCurrency(st.RetailStoreId__c);
    }
    
    // @isTest
    // static void test_getFiles() {
    //     //Opportunity mypOrder = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];
    //     SO_OpportunitySPAController.saveTheChunk();
    // }

    @isTest
    static void test_getProductBySku() {
        ProductReferential__c pr = [SELECT id, SKUCode__c FROM ProductReferential__c LIMIT 1];
        SO_OpportunitySPAController.getProductBySku(pr.SKUCode__c);
    }
    // @isTest
    // static void test_getAccountFromRMS() { //error - to retest and correct
    //     Store__c st = [SELECT Id, RetailStoreId__c FROM Store__c LIMIT 1];
    //     Account client = [SELECT Id, RMSId__pc, WW_RMSId__c FROM Account LIMIT 1];
    //     SO_OpportunitySPAController.getAccountFromRMS(st.RetailStoreId__c, client.RMSId__pc, client.WW_RMSId__c);
    // }
    // @isTest
    // static void test_validateCACodeInRMS() { //Methods defined as TestMethod do not support Web service callouts !!
    //     Store__c st = [SELECT Id, RetailStoreId__c FROM Store__c LIMIT 1];
    //     //Account client = [SELECT Id, RMSId__pc, WW_RMSId__c FROM Account LIMIT 1];
    //     SO_OpportunitySPAController.validateCACodeInRMS(st.RetailStoreId__c, 'test');
    // }
    @isTest
    static void test_findOppById() {
        Opportunity mypOrder = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];
        SO_OpportunitySPAController.findOppById(mypOrder.Id);
        Account client = [SELECT Id, RMSId__pc, WW_RMSId__c FROM Account LIMIT 1];
        SO_OpportunitySPAController.saveAccountInRMS(client, 'test');
    }
    @isTest
    static void test_saveTheChunk() {
        Opportunity order = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];
        SO_OpportunitySPAController.saveTheChunk(order.Id, 'FILE_NAME', '0000000', 'jpg', '');
    }
    @isTest
    static void test_createAttachment() {
        Opportunity order = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];
        SO_OpportunitySPAController.createAttachment(order.Id, 'FILE_NAME', '0000000', 'jpg');
    }

    @isTest //test
    static void test_appendToFile() {
        Opportunity order = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];

        //------------------------------------
        //Attachment myAtt = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        Attachment myAtt = new Attachment(ParentId = order.Id, Name = 'Test_Attachment', Body = b);
        insert myAtt;
        //Attachment attachment = [SELECT id, name FROM Attachment LIMIT 1];
        //BL_AccountFileUpload controller=new BL_AccountFileUpload(new ApexPages.StandardController(acc));
        //controller.fileName='Unit Test Attachment';
        //controller.fileBody=Blob.valueOf('Unit Test Attachment Body');
        //controller.uploadFile();
        //List<Attachment> attachments=[select id, name from Attachment where parent.id=:acc.id];
        //System.assertEquals(1, attachments.size());
        //-----------------------------------

        SO_OpportunitySPAController.saveTheChunk(order.Id, 'FILE_NAME', '0000000', 'jpg', myAtt.Id);
        SO_OpportunitySPAController.getFiles(order);
    }
    @isTest
    static void test_getFiles() {
        Opportunity order = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];
        //ContentDocument cd = new ContentDocument();
        //insert cd;
        //ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = order.Id, ContentDocumentId = cd.Id);
        //insert cdl;
        
        //SO_OpportunitySPAController.getFiles(order);

        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;
        
        List<ContentVersion> docs = [Select Id,ContentDocumentId, Title From ContentVersion where Id =:cv.Id];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = order.id;
        contentLink.ContentDocumentId = docs[0].ContentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;

        SO_OpportunitySPAController.getFiles(order);
    }
    
    // @isTest //test
    // static void test_retrievePricesFromRMS() { //Methods defined as TestMethod do not support Web service callouts !!
    //     Store__c st = [SELECT Id, RetailStoreId__c FROM Store__c LIMIT 1];
    //     Account client = [SELECT Id, RMSId__pc, WW_RMSId__c FROM Account LIMIT 1];
    //     SO_OpportunitySPAController.retrievePricesFromRMS(st.RetailStoreId__c, client.RMSId__pc);
    // }
}