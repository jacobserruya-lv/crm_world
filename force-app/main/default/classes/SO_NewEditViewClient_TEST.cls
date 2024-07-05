@isTest
private class SO_NewEditViewClient_TEST {

    /**
    * [Set database]
    * @scenario         [insert objects to the system]
    * @result           [database to work with]
    * @createdBy      
    * @lastModifiedBy    Ester Mendelson, 28-12-2015
    */
    @testSetup static void settigData() {
      SO_TestObjectCreator model = new SO_TestObjectCreator();
      model.initialization_one(true, true);
    }
    
  @isTest static void saveClient()   {
    
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];

    PageReference pageRef = System.Page.SO_NewEditClient;
    pageRef.getParameters().put('bid', opp.Id);

    Test.setCurrentPage(pageRef);
    ApexPages.StandardController stdController = new ApexPages.StandardController(new Account());

    SO_NewEditViewClient_CTRL contr = new SO_NewEditViewClient_CTRL(stdController);

    PageReference pg = contr.saveClient();
    System.assertEquals(null, pg, 'dont throw exception !');
  }

  @isTest static void cloningUser()   {
    
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];

    PageReference pageRef = System.Page.SO_NewEditClient;
    pageRef.getParameters().put('bid', opp.Id);

    Test.setCurrentPage(pageRef);

    ApexPages.StandardController stdController = new ApexPages.StandardController(new Account());
    SO_NewEditViewClient_CTRL contr = new SO_NewEditViewClient_CTRL(stdController);
    contr.birthdateStr = Datetime.newInstance(1970, 10, 10).format();
    contr.client.LastName = 'Test Client 001';
    contr.isCloning = true;
    contr.initPageAction();
    contr.getUserRoleAndReadonlyMode();
    PageReference pg = contr.saveClient();
  }

  @isTest static void testNext()   {
    
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Class Opp'];

    PageReference pageRef = System.Page.SO_NewEditClient;
    pageRef.getParameters().put('bid', opp.Id);

    Test.setCurrentPage(pageRef);

    ApexPages.StandardController stdController = new ApexPages.StandardController(new Account());
    SO_NewEditViewClient_CTRL contr = new SO_NewEditViewClient_CTRL(stdController);
    PageReference pg = contr.next();
    System.assert(pg.getUrl().containsIgnoreCase('SO_BriefOrder'));
  }
  
  @isTest static void mandatoryParameter()   {
    
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'Test Class Opp' LIMIT 1];
    Account acc = [SELECT Id,BirthdateYear__pc FROM Account WHERE lastName = 'Data Model Tester 001' LIMIT 1];
    acc.BirthdateYear__pc = '1999';
    acc.BirthdateMonth__pc = '08';
    acc.BirthdateDay__pc = '01';
    //acc.PrimaryCountry__pc = 'brazil';
    acc.SPO_Country_code__pc = 'BRA';
    acc.PrimaryAddressLine1__pc = 'street,21';
    update acc;

    PageReference pageRef = System.Page.SO_ViewClient;

    System.debug('AccountId >> ' + opp.AccountId);

    pageRef.getParameters().put('id', opp.AccountId);
    pageRef.getParameters().put('bid', opp.Id);

    Test.setCurrentPage(pageRef);
    Account client = acc;
    ApexPages.StandardController stdController = new ApexPages.StandardController(client);
    SO_NewEditViewClient_CTRL contr = new SO_NewEditViewClient_CTRL(stdController);
    contr.setBirthdate();

    PageReference pg = contr.saveClient();
    contr.splitBirthdate();
    system.assertEquals(contr.isMandatory_VAT,true);
    system.assertEquals(contr.isMandatory_TAX,true);
    system.assertEquals(contr.showSearchClientBtn,true);
    system.assertEquals(contr.isMandatory_FiscalCode,false);
  }

  @isTest static void PrimaryCountryItaly()   {
    
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'Test Class Opp' LIMIT 1];
    Account acc = [SELECT Id,BirthdateYear__pc FROM Account WHERE lastName = 'Data Model Tester 001' LIMIT 1];
    acc.BirthdateYear__pc = '1999';
    acc.BirthdateMonth__pc = '08';
    acc.BirthdateDay__pc = '01';
    //acc.PrimaryCountry__pc = 'Italy';
    acc.SPO_Country_code__pc = 'ITA';
    acc.PrimaryAddressLine1__pc = 'street,21';
    update acc;

    PageReference pageRef = System.Page.SO_NewEditClient;

    pageRef.getParameters().put('id', opp.AccountId);
    pageRef.getParameters().put('bid', opp.Id);

    Test.setCurrentPage(pageRef);
    Account client = acc;
    ApexPages.StandardController stdController = new ApexPages.StandardController(client);
    SO_NewEditViewClient_CTRL contr = new SO_NewEditViewClient_CTRL(stdController);
    contr.setBirthdate();

    PageReference pg = contr.saveClient();
    contr.splitBirthdate();
    system.assertEquals(contr.isMandatory_FiscalCode,true);

    contr.isCloning = true;
    contr.initPageAction();
  }

   @isTest static void PrimaryCountryBrazil()   {
    
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'Test Class Opp' LIMIT 1];
    Account acc = [SELECT Id,BirthdateYear__pc FROM Account WHERE lastName = 'Data Model Tester 001' LIMIT 1];
    acc.BirthdateYear__pc = '1999';
    acc.BirthdateMonth__pc = '08';
    acc.BirthdateDay__pc = '01';
    //acc.PrimaryCountry__pc = 'brazil';
    acc.SPO_Country_code__pc = 'BRA';

    acc.PrimaryAddressLine1__pc = null;
    update acc;

    PageReference pageRef = System.Page.SO_NewEditClient;

    pageRef.getParameters().put('id', opp.AccountId);
    pageRef.getParameters().put('bid', opp.Id);

    Test.setCurrentPage(pageRef);
    Account client = acc;
    ApexPages.StandardController stdController = new ApexPages.StandardController(client);
    SO_NewEditViewClient_CTRL contr = new SO_NewEditViewClient_CTRL(stdController);
    contr.setBirthdate();

    PageReference pg = contr.saveClient();
    List<SO_NewEditViewClient_CTRL.OrderViewLine> openOrderViewLineList = contr.openOrderViewLineList;
  }   
}