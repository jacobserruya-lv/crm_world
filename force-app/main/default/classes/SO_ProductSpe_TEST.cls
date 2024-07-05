@isTest
private class SO_ProductSpe_TEST {

	@testSetup static void setUp() {

		SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true,true);

		List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		opp[0].SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		opp[0].SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
		update opp[0];

		Document doc = new Document(Name='Heritage',AuthorId = UserInfo.getUserId(),FolderId = UserInfo.getUserId());
		insert doc;

		List<SPO_Colors__c> colors =new List<SPO_Colors__c>();
		colors.add(new SPO_Colors__c(name='Red',SPO_CodeCouleur__c ='#FFFFF'));
		colors.add(new SPO_Colors__c(name='white',SPO_CodeCouleur__c ='#FFFFF'));
		insert colors;

		Account acc = IC_TestFactory.createAccount();
		insert acc;

		Blob b = Blob.valueOf('Test Data');  
	    Attachment attachment = new Attachment();  
	    attachment.ParentId = acc.id;  
	    attachment.Name = 'Test Attachment for Parent';  
	    attachment.Body = b;   
	    insert(attachment);

	}

	@isTest static void LeatherProductCategoryTest() {

		PageReference ref =  new PageReference('/apex/SO_ProductSpe');
		Test.setCurrentPage(ref);

		List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(sc);
		opp[0].SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPO_MTO;
		opp[0].SPO_Exo__c ='Yes';
		opp[0].SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG;
		update opp[0];

		sc = new ApexPages.StandardController(opp[0]);
		ctrl = new SO_ProductSpe_CTRL(sc);
	}

	@isTest static void WatchProductCategoryTest() {

		PageReference ref =  new PageReference('/apex/SO_ProductSpe');
		Test.setCurrentPage(ref);

		List<Opportunity> opp =[SELECT ID,Name
										,OwnerId
										,StageName
										,AccountId
										,Account.Name
										,Account.LastName
										,toLabel(Account.Salutation)

										,SPO_OpportunityCloning__c
										
										,SPO_Store__c
										,SPO_Store__r.RetailStoreId__c
										,SPO_DisplayOrder__c
										,SPO_Session_State__c
										,SPO_BaseSKURefmodelSKU__c
										,SPO_BaseSKURefmodelSKU__r.Name
										,SPO_BaseSKURefmodelSKU__r.SKUCode__c
								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		
		opp[0].SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		opp[0].SPO_ProductCategory__c = SO_PicklistDependency.OPP_WATCH;
		opp[0].SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPO_MTO;
		opp[0].SPO_Exo__c ='Yes';
		update opp[0];
		SO_Session.startSession(opp[0]);

		ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(sc);

		ctrl.incExteriorCntr();
		ctrl.incLiningCntr();

		ctrl.saveAndNext();
        // added by MTOU
        Opportunity opp2 = ctrl.quotationContainer.oneOpportunity;
        opp2.name = 'This is a very very very long brief name';
        ctrl.saveAndNext();
        // end MTOU
        
		ctrl.initCreationTypeDependentFields();
		System.assertEquals(ctrl.exteriorCntr,1);
		System.assertEquals(ctrl.liningCntr,1);
		ctrl.backToClient();
        

	}
	@isTest static void HardsidedProductCategoryTest() {

		PageReference ref =  new PageReference('/apex/SO_ProductSpe');
		Test.setCurrentPage(ref);

		List<Opportunity> opp =[SELECT ID,Name
										,OwnerId
										,StageName
										,AccountId
										,Account.Name
										,Account.LastName
										,toLabel(Account.Salutation)

										,SPO_OpportunityCloning__c
										
										,SPO_Store__c
										,SPO_Store__r.RetailStoreId__c
										,SPO_DisplayOrder__c
										,SPO_Session_State__c
										,SPO_BaseSKURefmodelSKU__c
										,SPO_BaseSKURefmodelSKU__r.Name
										,SPO_BaseSKURefmodelSKU__r.SKUCode__c
								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		
		opp[0].SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		opp[0].SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG;
		opp[0].SPO_Exo__c ='Yes';
		update opp[0];
		SO_Session.startSession(opp[0]);


		ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(sc);

		ctrl.incExteriorCntr();
		ctrl.incLiningCntr();
		ctrl.cleanButton();
		ctrl.saveAndNext();
        // added by MTOU
        Opportunity opp2 = ctrl.quotationContainer.oneOpportunity;
        opp2.name = 'This is a very very very long brief name';
        ctrl.saveAndNext();
        // end MTOU
		ctrl.initCreationTypeDependentFields();

		System.assertEquals(ctrl.exteriorCntr,1);
		System.assertEquals(ctrl.liningCntr,1);

		ctrl.backToClient();
		ctrl.clearOppFields();
		ctrl.initStrapColorField();
	}

	@isTest static void AccessoryProductCategoryTest() {

		PageReference ref =  new PageReference('/apex/SO_ProductSpe');
		ref.getParameters().put('exo','test');
		Test.setCurrentPage(ref);

		List<Opportunity> opp =[SELECT ID,Name
										,OwnerId
										,StageName
										,AccountId
										,Account.Name
										,Account.LastName
										,toLabel(Account.Salutation)

										,SPO_OpportunityCloning__c
										
										,SPO_Store__c
										,SPO_Store__r.RetailStoreId__c
										,SPO_DisplayOrder__c
										,SPO_Session_State__c
										,SPO_BaseSKURefmodelSKU__c
										,SPO_BaseSKURefmodelSKU__r.Name
										,SPO_BaseSKURefmodelSKU__r.SKUCode__c
								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		
		opp[0].SPO_ProductCategory__c = SO_PicklistDependency.OPP_ACCESSORY;
		opp[0].SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
		update opp[0];
		SO_Session.startSession(opp[0]);

		ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(sc);
		ctrl.selectValuePainting = '1';
		ctrl.addFormAttachment();
		ctrl.selectValuePainting ='1';
		ctrl.refreshAttachmentList();
		ctrl.addFormAttachment();

		ctrl.saveAndNext();
        // added by MTOU
        Opportunity opp2 = ctrl.quotationContainer.oneOpportunity;
        opp2.name = 'This is a very very very long brief name';
        ctrl.saveAndNext();
        // end MTOU
		ctrl.updateExo();

		List<String> stringList = new List<String> {'Red','white'};
		SO_ProductSpe_CTRL.getColorsRgbHexMapByNames(stringList);
	}

	@isTest static void testAttachment() {

		PageReference ref =  new PageReference('/apex/SO_ProductSpe');
		ref.getParameters().put('exo','test');
		Test.setCurrentPage(ref);

		List<Opportunity> opp =[SELECT ID,Name
										,OwnerId
										,StageName
										,AccountId
										,Account.Name
										,Account.LastName
										,toLabel(Account.Salutation)

										,SPO_OpportunityCloning__c
										
										,SPO_Store__c
										,SPO_Store__r.RetailStoreId__c
										,SPO_DisplayOrder__c
										,SPO_Session_State__c
										,SPO_BaseSKURefmodelSKU__c
										,SPO_BaseSKURefmodelSKU__r.Name
										,SPO_BaseSKURefmodelSKU__r.SKUCode__c
								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		
		opp[0].SPO_ProductCategory__c = SO_PicklistDependency.OPP_ACCESSORY;
		opp[0].SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPECIAL_ORDER;
		update opp[0];
		SO_Session.startSession(opp[0]);

		ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(sc);
	
		List<String> stringList = new List<String> {'Red','white'};
		SO_ProductSpe_CTRL.getColorsRgbHexMapByNames(stringList);
		Integer a = ctrl.seeTranslation;
		String oppType = ctrl.opportunityOrderType;

		List<Account> acc = [SELECT id FROM Account WHERE FirstName='Louis' LIMIT 1];
		List<Attachment> attc = [SELECT ID FROM Attachment WHERE name ='Test Attachment for Parent' LIMIT 1];

		System.assertEquals(SO_ProductSpe_CTRL.doUploadAttachment(acc[0].id,null,'test',null),'Attachment Body was null');
		System.assertEquals(SO_ProductSpe_CTRL.doUploadAttachment(null,'test body','test',null),'Account Id was null');
		System.assertEquals(SO_ProductSpe_CTRL.doUploadAttachment(acc[0].id,null,'test',attc[0].id),'Attachment Body was null');

		SO_ProductSpe_CTRL.doUploadAttachment(acc[0].id,'test body','test',null);

		ctrl.toRemoveAttId =attc[0].id;
		SO_ProductSpe_CTRL.doUploadAttachment(acc[0].id,'test body','test',attc[0].id);

		ctrl.removeAttachment();
		attc = [SELECT ID FROM Attachment WHERE name ='Test Attachment for Parent' LIMIT 1];
		
		System.assertEquals(attc.size(),0);	

		SO_ProductSpe_CTRL.doSubmitForm(acc[0].id,'test desc','www.testweb.com','09878987');
		System.assertEquals(SO_ProductSpe_CTRL.doSubmitForm(null,'test desc','www.testweb.com','09878987'),'Account Id was null');
	}
}