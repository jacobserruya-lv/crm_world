/**
 * This is a test class for class SO_Template_CTRL
 * @lastModifiedBy      Ester Mendelson, 10-01-2015
 */

@isTest
private class SO_Template_TEST  {
    
   private static final String OPP_NAME = 'Test Class Opp';
    
  /**
  * [Set database]
  * @scenario       [insert objects to the system]
  * @result           [database to work with]
  * @createdBy      
  * @lastModifiedBy    Ester Mendelson, 28-12-2015
  */

  @testSetup
  private static void settigData() {

    SO_TestObjectCreator model = new SO_TestObjectCreator();
    model.initialization_one(false, true);
  }

  @isTest static void so_ClientSearch() {

    PageReference cPage = System.Page.SO_ClientSearch;
        Test.setCurrentPageReference(cPage);
    SO_Template_CTRL contrl = new SO_Template_CTRL();
  }

  @isTest static void so_productsearchPage() {

    PageReference cPage = System.Page.SO_productsearch;
        Test.setCurrentPageReference(cPage);
    SO_Template_CTRL contrl = new SO_Template_CTRL();
  }

  @isTest static void so_productspe() {

    PageReference cPage = System.Page.so_productspe;
        Test.setCurrentPageReference(cPage);
    SO_Template_CTRL contrl = new SO_Template_CTRL();
  }

  @isTest static void so_brieforder() {

    PageReference cPage = System.Page.so_brieforder;
        Test.setCurrentPageReference(cPage);
    SO_Template_CTRL contrl = new SO_Template_CTRL();
  }

  @isTest static void so_neweditclient() {

    PageReference cPage = System.Page.so_neweditclient;
        Test.setCurrentPageReference(cPage);
    SO_Template_CTRL contrl = new SO_Template_CTRL();
  }

  @isTest static void so_viewclient() {
    PageReference cPage = System.Page.so_viewclient;
        Test.setCurrentPageReference(cPage);
    SO_Template_CTRL contrl = new SO_Template_CTRL();
  }

  @isTest static void so_choosepath() {

    PageReference cPage = System.Page.so_choosepath;
        Test.setCurrentPageReference(cPage);
    SO_Template_CTRL contrl = new SO_Template_CTRL();
  }

  @isTest static void so_search() {

    PageReference cPage = System.Page.so_search;
        Test.setCurrentPageReference(cPage);
    SO_Template_CTRL contrl = new SO_Template_CTRL();
  }

  @isTest static void so_notifications() {

    PageReference cPage = System.Page.so_notifications;
        Test.setCurrentPageReference(cPage);
    SO_Template_CTRL contrl = new SO_Template_CTRL();
  } 

  @isTest static void opportunityWithNullValues() {
    
    
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
	opp[0].SPO_DisplayOrder__c = false;
	opp[0].AccountId = null;
	opp[0].SPO_BaseSKURefmodelSKU__c = null;
    update opp;
	SO_Session.startSession(opp[0]);
    
    PageReference cPage = System.Page.so_choosepath;
        Test.setCurrentPageReference(cPage);
        cPage.getParameters().put('id', opp[0].Id);
    SO_Template_CTRL contrl = new SO_Template_CTRL();
    contrl.validateNoBriefId();
    opp[0].SPO_DisplayOrder__c = true;
    update opp[0];
  } 
  @isTest static void so_choosepathWithOpportunity() {

    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: OPP_NAME];
    PageReference cPage = System.Page.so_choosepath;
        Test.setCurrentPageReference(cPage);
        cPage.getParameters().put('id', opp.Id);
    SO_Template_CTRL contrl = new SO_Template_CTRL();
    contrl.validateNoBriefId();
  } 
  
  @isTest static void so_quotationPageName() {

    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: OPP_NAME];
        
    PageReference ref =  new PageReference('/apex/quotation');
	Test.setCurrentPageReference(ref);
	ref.getParameters().put('id', opp.Id);
	
    SO_Template_CTRL contrl = new SO_Template_CTRL();
    contrl.validateNoBriefId();
  }
}