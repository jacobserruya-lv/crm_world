@isTest
public with sharing class SO_ProductSpe_CTRL_TEST {
    @testSetup
    static void testSetup(){
        SPO_Colors__c color1 = new SPO_Colors__c(Name = 'Monogram Empreinte Terre');
        SPO_Colors__c color2 = new SPO_Colors__c(Name = 'Agneau Bleu Canard');
        SPO_Colors__c color3 = new SPO_Colors__c(Name = 'BLACK SATIN', SPO_CodeCouleur__c = '000');
        SPO_Colors__c color4 = new SPO_Colors__c(Name = 'BLACK SATIN');
        List<SPO_Colors__c> colorList = new List<SPO_Colors__c>{color1, color2, color3, color4};
        insert colorList;

        Account account = LV_TestFactory.createAccount();
        insert account;

        Opportunity opp = new Opportunity(Name = 'setupOpp', StageName = 'Creation in progress', closeDate = Date.today());
        insert opp;

        Blob attachmentTestBody = Blob.valueOf('attachmentTestBody');
        Attachment attachment = new Attachment(ParentId = opp.Id, Name = 'attachmentTestName', Body = attachmentTestBody);
        insert attachment;

        SO_ProductSpe_CTRL.ColorPicker colorPicker1 = new SO_ProductSpe_CTRL.ColorPicker('colorCode', 'colorImage', 'colorObjName', 'valueInPicklist', 1);
        SO_ProductSpe_CTRL.ColorPicker colorPicker2 = new SO_ProductSpe_CTRL.ColorPicker( 'colorCode', 'colorImage', 'colorObjName', 'valueInPicklist', 0);
        Integer compareToResult = colorPicker1.compareTo(colorPicker2);
        System.assertEquals(compareToResult, 1);
    }

    @isTest
    static void test_init(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
        testOpp.SPO_Exo__c = 'Yes';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();

        ctrl.pReferential = new ProductReferential__c();
        ctrl.targetField = 'testTargetField';
        ctrl.leatherGood_Creation = false;
	    ctrl.leatherGood_Creation_OrderDisplay = false;
	    ctrl.leatherGood_HarsidedOutOfMyPerso = false;
	    ctrl.leatherGood_HarsidedOutOfMyPerso_OrderDisplay = false;
	    ctrl.watch_SpoMto = false;
	    ctrl.accessory_Creation = false;
	    ctrl.seeTranslation = 0;
	    ctrl.exteriorCntr = 0;
	    ctrl.liningCntr = 0;
	    ctrl.toRemoveAttId = 'toRemoveAttId';
	    ctrl.selectValuePainting = 'selectValuePainting';

        String getOpportunityOrderType = ctrl.opportunityOrderType;
        String getRole = ctrl.role;
        String getBaseRole = ctrl.baseRole;
        Boolean getIsReadonlyMode = ctrl.isReadonlyMode;
    }

    @isTest
    static void test_retColorNameToCodeMap(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
        testOpp.SPO_Exo__c = 'Yes';
        testOpp.SPO_StrapColor__c = 'BLACK SATIN';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();

        Map<String, String> retColorNameToCodeMap = ctrl.retColorNameToCodeMap();
        System.assertEquals(2, retColorNameToCodeMap.size());
        System.assertEquals(true, retColorNameToCodeMap.keySet().contains('BLACK SATIN'));
    }

    @isTest
    static void test_refreshAttachmentList(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
        testOpp.SPO_Exo__c = 'Yes';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();

        PageReference pageReference = ctrl.refreshAttachmentList();
        System.assertEquals(null, pageReference);
    }

    @isTest
    static void test_removeAttachment(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
        testOpp.SPO_Exo__c = 'Yes';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();
        Attachment attachment = [SELECT Id FROM Attachment WHERE Name = 'attachmentTestName'];
        ctrl.toRemoveAttId = attachment.Id;

        PageReference pageReference = ctrl.removeAttachment();
        System.assertEquals(null, pageReference);
    }

    @isTest
    static void test_addFormAttachment(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
        testOpp.SPO_Exo__c = 'Yes';
        testOpp.SPO_Painting__c = 'Heritage';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();
        ctrl.selectValuePainting = '1';

        Blob testBlob = Blob.valueof('test');
        Document document = new Document(Name = 'Heritage', Body = testBlob, Type = 'testType', FolderId = '00l0H000002B5o0QAC');
        insert document;

        PageReference pageReference = ctrl.addFormAttachment();
        System.assertEquals(null, pageReference);
    }

    @isTest
    static void test_cleanButton(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG;
        testOpp.SPO_Exo__c = 'Yes';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();

        ctrl.cleanButton();
        System.assertEquals(1, ctrl.exteriorCntr);
        System.assertEquals(1, ctrl.liningCntr);
    }

    @isTest
    static void test_clearOppFields(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG;
        testOpp.SPO_Exo__c = 'Yes';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();

        PageReference pageReference = ctrl.clearOppFields();
        System.assertEquals(null, pageReference);
    }

    @isTest
    static void test_saveAndNext(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG;
        testOpp.SPO_Exo__c = 'No';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();

        PageReference pageReference = ctrl.saveAndNext();
        System.assertEquals(true, pageReference.getUrl().startsWith('/apex/so_brieforder?id='));
    }

    @isTest
    static void test_initExteriorMaterialFieldMethods(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
        testOpp.SPO_Exo__c = 'Yes';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();

        ctrl.initExteriorMaterial1Field();
        System.assertEquals(1, ctrl.quotationContainer.colorNameToCodeMap.size());
        System.assertEquals(true, ctrl.quotationContainer.colorNameToCodeMap.keySet().contains('Other (free text)'));

        ctrl.initExteriorMaterial2Field();
        System.assertEquals(1, ctrl.quotationContainer.colorNameToCodeMap.size());
        System.assertEquals(true, ctrl.quotationContainer.colorNameToCodeMap.keySet().contains('Other (free text)'));

        ctrl.initExteriorMaterial3Field();
        System.assertEquals(1, ctrl.quotationContainer.colorNameToCodeMap.size());
        System.assertEquals(true, ctrl.quotationContainer.colorNameToCodeMap.keySet().contains('Other (free text)'));
    }

    @isTest
    static void test_initLiningInteriorMaterialFieldMethods(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
        testOpp.SPO_Exo__c = 'Yes';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();

        ctrl.initLiningInteriorMaterial1Field();
        System.assertEquals(1, ctrl.quotationContainer.colorNameToCodeMap.size());
        System.assertEquals(true, ctrl.quotationContainer.colorNameToCodeMap.keySet().contains('Other (free text)'));

        ctrl.initLiningInteriorMaterial2Field();
        System.assertEquals(1, ctrl.quotationContainer.colorNameToCodeMap.size());
        System.assertEquals(true, ctrl.quotationContainer.colorNameToCodeMap.keySet().contains('Other (free text)'));
    }

    @isTest
    static void test_ExteriorCntrMethods(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
        testOpp.SPO_Exo__c = 'Yes';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();

        ctrl.exteriorCntr = 2;
        ctrl.incExteriorCntr();
        System.assertEquals(3, ctrl.exteriorCntr);

        ctrl.decExteriorCntr();
        System.assertEquals(2, ctrl.exteriorCntr);

        ctrl.decExteriorCntr();
        System.assertEquals(1, ctrl.exteriorCntr);
    }

    @isTest
    static void test_backToClient(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
        testOpp.SPO_Exo__c = 'Yes';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();

        PageReference pageReference1 = ctrl.backToClient();
        System.assertEquals(pageReference1.getParameters().get('id'), ctrl.quotationContainer.oneOpportunity.AccountId);

        ctrl.quotationContainer.oneOpportunity.AccountId = null;
        PageReference pageReference2 = ctrl.backToClient();
        System.assertEquals(pageReference2.getParameters().get('bid'), ctrl.srcObjId);
    }

    @isTest
    static void test_updateExo(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
        testOpp.SPO_Exo__c = 'Yes';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();

        ctrl.updateExo();
        System.assertEquals('Yes', ctrl.quotationContainer.oneOpportunity.SPO_Exo__c);

        ApexPages.currentPage().getParameters().put('exo', '"');
        ctrl.updateExo();
        System.assertEquals('&quot;', ctrl.quotationContainer.oneOpportunity.SPO_Exo__c);
    }

    @isTest
    static void test_initCreationTypeDependentFields(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
        testOpp.SPO_Exo__c = 'Yes';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();
    
        PageReference pageReference = ctrl.initCreationTypeDependentFields();
        System.assertEquals(null, pageReference);
    }

    @isTest
    static void test_initStrapColorField(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
        testOpp.SPO_Exo__c = 'Yes';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();

        ctrl.initStrapColorField();
        System.assertEquals(1, ctrl.quotationContainer.colorNameToCodeMap.size());
        System.assertEquals(true, ctrl.quotationContainer.colorNameToCodeMap.keySet().contains('Other (free text)'));
    }

    @isTest
    static void test_LiningCntrMethods(){
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true, true);
		Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];
		testOpp.SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		testOpp.SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
        testOpp.SPO_Exo__c = 'Yes';
		update testOpp;

        SO_Session.startSession(testOpp);
		ApexPages.StandardController standardController = new ApexPages.StandardController(testOpp);

		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(standardController);
        ctrl.srcObjId = standardController.getId();
        ctrl.init();

        ctrl.liningCntr = 2;
        ctrl.decLiningCntr();
        System.assertEquals(1, ctrl.liningCntr);

        ctrl.incLiningCntr();
        System.assertEquals(2, ctrl.liningCntr);
    }

    // ====================================== STATIC METHODS ====================================== 

    @isTest
    static void test_retOpportunityById(){
        Opportunity opp1 = [SELECT Id FROM Opportunity WHERE Name = 'setupOpp'];

        Opportunity opp2 = SO_ProductSpe_CTRL.retOpportunityById(opp1.Id);
        System.assertEquals(opp1.Id, opp2.Id);
    }

    @isTest
    static void test_retAttachmentListByOppId(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'setupOpp'];
        Attachment attachment = [SELECT Id FROM Attachment WHERE Name = 'attachmentTestName'];
        
        List<Attachment> attachmentList = SO_ProductSpe_CTRL.retAttachmentListByOppId(opp.Id);
        System.assertEquals(attachmentList.size(), 1);
        System.assertEquals(attachment.Id, attachmentList[0].Id);
    }

    @isTest
    static void test_getColorsRgbHexMapByNames(){
        List<String> colorsNames = new List<String>{'Monogram Empreinte Terre', 'Agneau Bleu Canard'};
        String colorsRgbHex = SO_ProductSpe_CTRL.getColorsRgbHexMapByNames(colorsNames);

        List<SO_ProductSpe_CTRL.ColorPicker> colorsRgbHexObjects = (List<SO_ProductSpe_CTRL.ColorPicker>)JSON.deserialize(colorsRgbHex, List<SO_ProductSpe_CTRL.ColorPicker>.class);
        List<String> colorsRgbHexNames = new List<String>();
        for(SO_ProductSpe_CTRL.ColorPicker colorsRgbHexObj : colorsRgbHexObjects){
            colorsRgbHexNames.add(colorsRgbHexObj.colorObjName);
        }

        colorsNames.sort();
        System.assertEquals(colorsRgbHexNames, colorsNames);
    }

    @isTest
    static void test_retColorListByName(){
        List<String> colorsNames = new List<String>{'Monogram Empreinte Terre', 'Agneau Bleu Canard'};
        List<SPO_Colors__c> colorsList = SO_ProductSpe_CTRL.retColorListByName(colorsNames);

        List<String> colorsNamesList = new List<String>();
        for(SPO_Colors__c color : colorsList){
            colorsNamesList.add(color.Name);
        }
        System.assertEquals(colorsNames, colorsNamesList);
    }

    @isTest
    static void test_doUploadAttachment(){
        Account account = [SELECT Id FROM Account WHERE FirstName = 'Louis'];

        Blob testBlob = Blob.valueof('test');
        Attachment attachment = new Attachment(Name = 'attachment', ParentId = account.Id, Body = testBlob);
        insert attachment;

        String uploadAttachment1 = SO_ProductSpe_CTRL.doUploadAttachment(null, 'attachmentBody', 'attachmentName', 'attachmentId');
        System.assertEquals(uploadAttachment1, 'Account Id was null');

        String uploadAttachment2 = SO_ProductSpe_CTRL.doUploadAttachment(account.Id, null, 'attachmentName', 'attachmentId');
        System.assertEquals(uploadAttachment2, 'Attachment Body was null');
        
        String uploadAttachment3 = SO_ProductSpe_CTRL.doUploadAttachment(account.Id, 'attachmentBody', 'attachmentName', attachment.Id);
        System.assertEquals(uploadAttachment3, attachment.Id);
        
        String uploadAttachment4 = SO_ProductSpe_CTRL.doUploadAttachment('123', 'attachmentBody', 'attachmentName', 'attachmentId');
        System.assertEquals(uploadAttachment4, 'Account could not be found');
        
        String uploadAttachment5 = SO_ProductSpe_CTRL.doUploadAttachment(account.Id, 'attachmentBody', 'testingAttachmentName', null);
        Attachment attachmentToCompare = [SELECT Name FROM Attachment WHERE Name =: 'testingAttachmentName'];
        System.assertNotEquals(attachmentToCompare, null);
    }

    @isTest
    static void test_extractImage(){
        String extractedImage = SO_ProductSpe_CTRL.extractImage('test');
        System.assertEquals('test', extractedImage);
    }

    @isTest
    static void test_doSubmitForm(){
        Account account = [SELECT Id FROM Account WHERE FirstName = 'Louis'];

        String submittedForm1 = SO_ProductSpe_CTRL.doSubmitForm(null, 'description', 'website', 'phone');
        System.assertEquals(submittedForm1, 'Account Id was null');

        String submittedForm2 = SO_ProductSpe_CTRL.doSubmitForm(account.Id, null, 'website', 'phone');
        System.assertEquals(submittedForm2, 'Success');

        String submittedForm3 = SO_ProductSpe_CTRL.doSubmitForm('123', 'description', 'website', 'phone');
        System.assertEquals(submittedForm3, 'Account could not be found');
    }
}